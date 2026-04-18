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

app.get('/health', (req, res) => {
  res.json({ success: true, status: 'ok', environment: 'production' });
});

app.use('/resolve', resolveRouter);

app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

app.use(errorHandler);

const server = app.listen(PORT, '0.0.0.0', () => {
  const { address, port } = server.address();
  logger.info(`Server listening on ${address}:${port}`);
});

module.exports = app;
