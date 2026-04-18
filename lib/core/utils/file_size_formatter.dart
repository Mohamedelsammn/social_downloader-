class FileSizeFormatter {
  const FileSizeFormatter();

  String format(int? bytes) {
    if (bytes == null || bytes <= 0) return '—';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    final formatted = value >= 10 || unit == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return '$formatted ${units[unit]}';
  }
}
