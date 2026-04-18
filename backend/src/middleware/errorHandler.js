const logger = require('../utils/logger');

// eslint-disable-next-line no-unused-vars
module.exports = function errorHandler(err, _req, res, _next) {
  logger.error('Unhandled error:', err.message || err);

  const status = err.status || 500;
  res.status(status).json({
    success: false,
    code: err.code || 'INTERNAL_ERROR',
    message: err.expose ? err.message : 'Something went wrong on the server.',
  });
};
