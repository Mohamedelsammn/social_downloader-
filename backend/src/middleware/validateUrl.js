const ALLOWED_PROTOCOLS = new Set(['http:', 'https:']);

function isPrivateHost(hostname) {
  const h = hostname.toLowerCase();
  if (h === 'localhost' || h === '0.0.0.0' || h === '::1') return true;
  if (/^127\./.test(h)) return true;
  if (/^10\./.test(h)) return true;
  if (/^192\.168\./.test(h)) return true;
  if (/^169\.254\./.test(h)) return true;
  if (/^172\.(1[6-9]|2\d|3[01])\./.test(h)) return true;
  return false;
}

module.exports = function validateUrl(req, res, next) {
  const { url } = req.body || {};

  if (typeof url !== 'string' || url.trim().length === 0) {
    return res.status(400).json({
      success: false,
      code: 'INVALID_URL',
      message: 'A non-empty "url" string is required.',
    });
  }

  let parsed;
  try {
    parsed = new URL(url.trim());
  } catch {
    return res.status(400).json({
      success: false,
      code: 'INVALID_URL',
      message: 'The provided value is not a valid URL.',
    });
  }

  if (!ALLOWED_PROTOCOLS.has(parsed.protocol)) {
    return res.status(400).json({
      success: false,
      code: 'INVALID_URL',
      message: 'Only http and https URLs are accepted.',
    });
  }

  if (isPrivateHost(parsed.hostname)) {
    return res.status(400).json({
      success: false,
      code: 'INVALID_URL',
      message: 'Private / loopback hosts are not allowed.',
    });
  }

  req.parsedUrl = parsed;
  next();
};
