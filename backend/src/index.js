require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');

const resolveRouter = require('./routes/resolve');
const errorHandler = require('./middleware/errorHandler');
const logger = require('./utils/logger');

const app = express();
const PORT = process.env.PORT || 4000;

app.use(cors());
app.use(express.json({ limit: '64kb' }));
app.use(morgan('tiny'));

app.get('/health', (_req, res) => {
  res.json({ success: true, status: 'ok', uptime: process.uptime() });
});

app.use('/resolve', resolveRouter);

app.use((_req, res) => {
  res.status(404).json({ success: false, code: 'NOT_FOUND', message: 'Route not found.' });
});

app.use(errorHandler);

app.listen(PORT, () => {
  logger.info(`Luminescent Vault resolver listening on :${PORT}`);
});

module.exports = app;
