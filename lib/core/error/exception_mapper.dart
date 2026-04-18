import 'package:dio/dio.dart';

import 'exceptions.dart';

/// Converts low-level Dio errors into the domain-oriented exceptions used
/// across the data layer. Kept in one place so repositories and datasources
/// stay free of transport concerns.
class DioExceptionMapper {
  const DioExceptionMapper();

  Exception map(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();

      case DioExceptionType.connectionError:
        return NetworkException();

      case DioExceptionType.badResponse:
        return _mapBadResponse(error.response);

      case DioExceptionType.cancel:
        return DownloadException('Request was cancelled.');

      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ServerException(
          error.message ?? 'Unexpected server error.',
        );
    }
  }

  Exception _mapBadResponse(Response? response) {
    if (response == null) {
      return ServerException('Empty response from server.');
    }

    String? code;
    String? message;
    final data = response.data;
    if (data is Map) {
      code = data['code']?.toString();
      message = data['message']?.toString();
    }

    switch (code) {
      case 'INVALID_URL':
        return InvalidUrlException(message ?? 'Invalid URL.');
      case 'UNSUPPORTED_MEDIA':
        return UnsupportedMediaException(
          message ?? 'Unsupported media type.',
        );
      case 'TIMEOUT':
        return TimeoutException(message ?? 'Upstream timeout.');
      case 'HOST_UNREACHABLE':
      case 'UPSTREAM_ERROR':
      case 'NETWORK_FAILURE':
        return NetworkException(message ?? 'Network failure.');
      default:
        return ServerException(
          message ?? 'Server error (${response.statusCode}).',
          code: code,
        );
    }
  }
}
