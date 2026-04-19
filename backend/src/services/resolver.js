const axios = require('axios');
const path = require('path');
const logger = require('../utils/logger');
const { resolveWithYtDlp, YTDLP_ENABLED } = require('./ytdlpResolver');

const VIDEO_MIME_PREFIXES = ['video/'];
const STREAM_MIME_HINTS = [
  'application/vnd.apple.mpegurl',
  'application/x-mpegurl',
  'application/dash+xml',
];
const VIDEO_EXTENSIONS = new Set([
  '.mp4', '.mov', '.webm', '.mkv', '.m4v', '.avi', '.3gp',
]);
const STREAM_EXTENSIONS = new Set(['.m3u8', '.mpd']);

const HEAD_TIMEOUT_MS = 8000;
const GET_TIMEOUT_MS = 10000;

function extractTitle(parsedUrl, contentDisposition) {
  if (contentDisposition) {
    const match = /filename\*?=(?:UTF-8'')?"?([^";]+)"?/i.exec(contentDisposition);
    if (match) {
      try {
        return decodeURIComponent(match[1]).trim();
      } catch {
        return match[1].trim();
      }
    }
  }
  const last = path.basename(parsedUrl.pathname || '').split('?')[0];
  if (last) return decodeURIComponent(last);
  return parsedUrl.hostname;
}

function classify(contentType, pathname) {
  const ct = (contentType || '').toLowerCase().split(';')[0].trim();
  const ext = path.extname(pathname || '').toLowerCase();

  if (VIDEO_MIME_PREFIXES.some((p) => ct.startsWith(p))) return 'direct';
  if (STREAM_MIME_HINTS.includes(ct)) return 'stream';
  if (VIDEO_EXTENSIONS.has(ext)) return 'direct';
  if (STREAM_EXTENSIONS.has(ext)) return 'stream';
  return null;
}

async function probe(url) {
  const commonHeaders = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
    Accept: '*/*',
    Referer: 'https://www.google.com/',
  };

  try {
    const head = await axios.head(url, {
      timeout: HEAD_TIMEOUT_MS,
      maxRedirects: 5,
      headers: commonHeaders,
      validateStatus: (s) => s < 400,
    });
    return {
      status: head.status,
      headers: head.headers,
      finalUrl: head.request?.res?.responseUrl || url,
    };
  } catch (headErr) {
    logger.warn('HEAD failed, falling back to ranged GET:', headErr.message);
    const get = await axios.get(url, {
      timeout: GET_TIMEOUT_MS,
      maxRedirects: 5,
      headers: { ...commonHeaders, Range: 'bytes=0-0' },
      responseType: 'stream',
      validateStatus: (s) => s < 400,
    });
    get.data.destroy();
    return {
      status: get.status,
      headers: get.headers,
      finalUrl: get.request?.res?.responseUrl || url,
    };
  }
}

/**
 * Try the direct-URL path first (fast). If the URL points at an HTML page
 * (YouTube watch page, Instagram reel page, Facebook watch page, ...),
 * fall back to yt-dlp which knows how to extract the underlying media URL.
 */
async function resolveDirect(parsedUrl) {
  const url = parsedUrl.toString();
  const probed = await probe(url);
  const finalUrl = probed.finalUrl || url;
  const finalParsed = (() => {
    try { return new URL(finalUrl); } catch { return parsedUrl; }
  })();
  const contentType = probed.headers['content-type'];
  const type = classify(contentType, finalParsed.pathname);

  if (!type) return null;

  const title = extractTitle(finalParsed, probed.headers['content-disposition']);
  const contentLength = probed.headers['content-length']
    ? Number(probed.headers['content-length'])
    : null;

  return {
    title,
    downloadUrl: finalUrl,
    type,
    contentType: contentType || null,
    contentLength: Number.isFinite(contentLength) ? contentLength : null,
    source: 'direct',
  };
}

function _mapProbeError(err) {
  const code = err.code || '';
  if (code === 'ECONNABORTED' || /timeout/i.test(err.message)) {
    const e = new Error('The target server took too long to respond.');
    e.status = 504; e.code = 'TIMEOUT'; e.expose = true;
    return e;
  }
  if (code === 'ENOTFOUND' || code === 'EAI_AGAIN') {
    const e = new Error('The target host could not be resolved.');
    e.status = 502; e.code = 'HOST_UNREACHABLE'; e.expose = true;
    return e;
  }
  if (err.response) {
    const e = new Error(`Upstream responded with HTTP ${err.response.status}.`);
    e.status = 502; e.code = 'UPSTREAM_ERROR'; e.expose = true;
    return e;
  }
  const e = new Error('Failed to reach the target URL.');
  e.status = 502; e.code = 'NETWORK_FAILURE'; e.expose = true;
  return e;
}

async function resolveVideoUrl(parsedUrl) {
  // 1) Direct probe — cheap, works for `.mp4`, CDN links, open HLS, etc.
  let direct = null;
  let probeErr = null;
  try {
    direct = await resolveDirect(parsedUrl);
  } catch (err) {
    probeErr = err;
  }
  if (direct) return direct;

  // 2) Fall back to yt-dlp for embedded-media pages (YouTube, IG, FB, TikTok, ...).
  if (YTDLP_ENABLED) {
    try {
      return await resolveWithYtDlp(parsedUrl.toString());
    } catch (err) {
      logger.warn(`yt-dlp fallback failed [${err.code || 'ERR'}]: ${err.message}`);
      if (err.code === 'YTDLP_FAILED' || err.code === 'YTDLP_NO_FORMAT') {
        const e = new Error(`Extraction failed: ${err.message}`);
        e.status = 415; e.code = 'UNSUPPORTED_MEDIA'; e.expose = true;
        throw e;
      }
      if (err.code === 'YTDLP_MISSING') {
        const e = new Error(
          'yt-dlp is not installed on the server. Install it or set YTDLP_DISABLED=true.'
        );
        e.status = 500; e.code = 'YTDLP_MISSING'; e.expose = true;
        throw e;
      }
      if (err.code === 'YTDLP_TIMEOUT') {
        const e = new Error('The extractor took too long. Try again.');
        e.status = 504; e.code = 'TIMEOUT'; e.expose = true;
        throw e;
      }
    }
  }

  // 3) Neither path produced a downloadable URL.
  if (probeErr && (!direct)) {
    // If the direct probe itself failed with a network error, surface that
    // rather than a misleading "unsupported media" message.
    const looksLikeNetwork = probeErr.code === 'ECONNABORTED' ||
      probeErr.code === 'ENOTFOUND' ||
      probeErr.code === 'EAI_AGAIN' ||
      !probeErr.response;
    if (looksLikeNetwork && probeErr.code !== 'ECONNABORTED') {
      throw _mapProbeError(probeErr);
    }
  }

  const e = new Error(
    'Unsupported media type. The link is not a direct video file and no extractor could resolve it.'
  );
  e.status = 415; e.code = 'UNSUPPORTED_MEDIA'; e.expose = true;
  throw e;
}

module.exports = { resolveVideoUrl };
