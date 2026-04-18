class UrlValidator {
  const UrlValidator();

  bool isValid(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return false;
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return false;
    if (!uri.hasScheme) return false;
    if (uri.scheme != 'http' && uri.scheme != 'https') return false;
    if (uri.host.isEmpty) return false;
    return true;
  }
}
