const { spawn } = require('child_process');
const logger = require('../utils/logger');

console.log('--- PRODUCTION DEBUG INFO ---');
console.log('PATH:', process.env.PATH);
console.log('YTDLP_BIN Variable:', process.env.YTDLP_BIN);
console.log('Current Directory:', process.cwd());
console.log('-----------------------------');

const YTDLP_BIN = process.env.YTDLP_BIN || 'yt-dlp';
const YTDLP_TIMEOUT_MS = Number(process.env.YTDLP_TIMEOUT_MS || 30000);
const YTDLP_ENABLED = process.env.YTDLP_DISABLED !== 'true';

/**
 * Runs `yt-dlp --dump-single-json` on a URL and resolves with the parsed JSON.
 * Rejects with an Error that carries `.code` so the caller can map it to an
 * API error shape.
 */
function runYtDlp(url) {
  return new Promise((resolve, reject) => {
    const args = [
      '--dump-single-json',
      '--no-warnings',
      '--no-playlist',
      '--no-check-certificate',
      '--skip-download',
      '--format', 'best',
      '--user-agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
      '--add-header', 'Accept-Language: en-US,en;q=0.9',
      '--add-header', 'Referer: https://www.google.com/',
      '--geo-bypass',
      url,
    ];

    let child;
    try {
      child = spawn(YTDLP_BIN, args, { windowsHide: true });
    } catch (err) {
      const e = new Error(
        `yt-dlp is not installed or not in PATH (${YTDLP_BIN}).`
      );
      e.code = 'YTDLP_MISSING';
      return reject(e);
    }

    let stdout = '';
    let stderr = '';
    let killed = false;

    const killTimer = setTimeout(() => {
      killed = true;
      try { child.kill('SIGKILL'); } catch (_) {}
    }, YTDLP_TIMEOUT_MS);

    child.stdout.on('data', (chunk) => { stdout += chunk.toString(); });
    child.stderr.on('data', (chunk) => { stderr += chunk.toString(); });

    child.on('error', (err) => {
      clearTimeout(killTimer);
      if (err.code === 'ENOENT') {
        const e = new Error(
          `yt-dlp is not installed or not in PATH (${YTDLP_BIN}).`
        );
        e.code = 'YTDLP_MISSING';
        return reject(e);
      }
      reject(err);
    });

    child.on('close', (code) => {
      clearTimeout(killTimer);
      if (killed) {
        const e = new Error('yt-dlp timed out.');
        e.code = 'YTDLP_TIMEOUT';
        return reject(e);
      }
      if (code !== 0) {
        const message = _extractYtDlpError(stderr) ||
          `yt-dlp exited with code ${code}.`;
        const e = new Error(message);
        e.code = 'YTDLP_FAILED';
        e.stderr = stderr;
        return reject(e);
      }
      try {
        const json = JSON.parse(stdout);
        resolve(json);
      } catch (err) {
        const e = new Error('Could not parse yt-dlp output.');
        e.code = 'YTDLP_PARSE';
        reject(e);
      }
    });
  });
}

function _extractYtDlpError(stderr) {
  if (!stderr) return null;
  // Just return the raw stderr clipped to a reasonable length for debugging
  return stderr.length > 500 ? stderr.substring(0, 500) + '...' : stderr;
}

/**
 * Normalises the yt-dlp JSON into the shape our `/resolve` endpoint returns.
 * Picks a single-URL format (no HLS/DASH manifest) so the Flutter client can
 * stream it straight to disk.
 */
function _headersFrom(obj) {
  if (!obj || typeof obj !== 'object') return {};
  return Object.fromEntries(
    Object.entries(obj).filter(([, v]) => typeof v === 'string' && v.length > 0)
  );
}

function pickBestFormat(info) {
  if (!info) return null;

  const topHeaders = _headersFrom(info.http_headers);

  if (typeof info.url === 'string' && info.url.length > 0) {
    const protocol = (info.protocol || '').toLowerCase();
    const isManifest = protocol.includes('m3u8') ||
      protocol.includes('dash') ||
      info.url.includes('.m3u8') ||
      info.url.includes('.mpd');
    if (!isManifest) {
      return {
        url: info.url,
        ext: info.ext || 'mp4',
        type: 'direct',
        headers: topHeaders,
      };
    }
  }

  const formats = Array.isArray(info.formats) ? info.formats : [];

  const progressive = formats
    .filter((f) =>
      f.url &&
      f.vcodec && f.vcodec !== 'none' &&
      f.acodec && f.acodec !== 'none' &&
      (f.ext === 'mp4' || f.ext === 'webm' || f.ext === 'mov')
    )
    .sort((a, b) => (b.height || 0) - (a.height || 0));

  if (progressive.length > 0) {
    const best = progressive[0];
    return {
      url: best.url,
      ext: best.ext || 'mp4',
      type: 'direct',
      headers: { ...topHeaders, ..._headersFrom(best.http_headers) },
    };
  }

  const manifest = formats.find((f) =>
    f.url && (f.protocol === 'm3u8_native' ||
              f.protocol === 'm3u8' ||
              f.ext === 'm3u8' ||
              f.ext === 'mpd')
  );
  if (manifest) {
    return {
      url: manifest.url,
      ext: manifest.ext || 'm3u8',
      type: 'stream',
      headers: { ...topHeaders, ..._headersFrom(manifest.http_headers) },
    };
  }

  return null;
}

async function resolveWithYtDlp(url) {
  if (!YTDLP_ENABLED) {
    const e = new Error('yt-dlp fallback is disabled.');
    e.code = 'YTDLP_DISABLED';
    throw e;
  }

  // TikTok specialized handling
  if (url.includes('tiktok.com')) {
    try {
      logger.info('Using TikTok specialized API for:', url);
      const response = await fetch(`https://www.tikwm.com/api/?url=${encodeURIComponent(url)}`);
      const data = await response.json();
      if (data.code === 0 && data.data) {
        return {
          title: data.data.title || 'TikTok Video',
          downloadUrl: data.data.play, // Unwatermarked
          type: 'direct',
          contentType: 'video/mp4',
          contentLength: null,
          httpHeaders: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36'
          },
          source: 'tiktok-api',
        };
      }
    } catch (err) {
      logger.warn('TikTok specialized API failed, trying yt-dlp...', err);
    }
  }

  logger.info('Falling back to yt-dlp for:', url);
  const info = await runYtDlp(url);
  const picked = pickBestFormat(info);
  if (!picked) {
    const e = new Error(
      'yt-dlp could not extract a playable single-file URL for this link.'
    );
    e.code = 'YTDLP_NO_FORMAT';
    throw e;
  }

  return {
    title: (info.title || info.id || 'video').trim(),
    downloadUrl: picked.url,
    type: picked.type,
    contentType: picked.type === 'stream'
      ? 'application/vnd.apple.mpegurl'
      : `video/${picked.ext}`,
    contentLength: typeof info.filesize === 'number'
      ? info.filesize
      : (typeof info.filesize_approx === 'number'
          ? info.filesize_approx
          : null),
    httpHeaders: picked.headers || {},
    source: 'yt-dlp',
  };
}

module.exports = { resolveWithYtDlp, YTDLP_ENABLED };
