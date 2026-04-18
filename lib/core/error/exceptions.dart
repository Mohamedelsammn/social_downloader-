class ServerException implements Exception {
  final String message;
  final String? code;
  ServerException(this.message, {this.code});
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No internet connection.']);
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException([this.message = 'Request timed out.']);
}

class InvalidUrlException implements Exception {
  final String message;
  InvalidUrlException([this.message = 'Invalid URL.']);
}

class UnsupportedMediaException implements Exception {
  final String message;
  UnsupportedMediaException([
    this.message = 'Unsupported media type.',
  ]);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Local storage error.']);
}

class DownloadException implements Exception {
  final String message;
  DownloadException([this.message = 'Download failed.']);
}
