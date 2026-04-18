const express = require('express');
const validateUrl = require('../middleware/validateUrl');
const { resolveVideoUrl } = require('../services/resolver');
const logger = require('../utils/logger');

const router = express.Router();

router.post('/', validateUrl, async (req, res, next) => {
  try {
    logger.info('Resolving:', req.parsedUrl.toString());
    const result = await resolveVideoUrl(req.parsedUrl);
    res.json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
