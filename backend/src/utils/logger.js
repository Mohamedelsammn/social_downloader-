const stamp = () => new Date().toISOString();

const write = (level, args) => {
  const line = args
    .map((arg) => (typeof arg === 'string' ? arg : JSON.stringify(arg)))
    .join(' ');
  // eslint-disable-next-line no-console
  console.log(`[${stamp()}] [${level}] ${line}`);
};

module.exports = {
  info: (...a) => write('INFO', a),
  warn: (...a) => write('WARN', a),
  error: (...a) => write('ERROR', a),
  debug: (...a) => {
    if (process.env.DEBUG === 'true') write('DEBUG', a);
  },
};
