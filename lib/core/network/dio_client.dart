import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../error/exception_mapper.dart';

/// Thin Dio wrapper that centralises base URL, timeouts, logging, a basic
/// retry policy for transient failures, and error mapping.
class DioClient {
  final Dio _dio;
  final DioExceptionMapper _mapper;

  DioClient._(this._dio, this._mapper);

  factory DioClient.create({DioExceptionMapper? mapper}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.connectTimeout,
        responseType: ResponseType.json,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(_LoggingInterceptor());
    return DioClient._(dio, mapper ?? const DioExceptionMapper());
  }

  Dio get raw => _dio;

  Future<Response<T>> postJson<T>(
    String path,
    Map<String, dynamic> body, {
    int maxRetries = 1,
  }) async {
    return _withRetry<T>(
      () => _dio.post<T>(path, data: body),
      maxRetries: maxRetries,
    );
  }

  Future<Response<T>> _withRetry<T>(
    Future<Response<T>> Function() request, {
    required int maxRetries,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        return await request();
      } on DioException catch (e) {
        final retryable = _isRetryable(e);
        if (!retryable || attempt >= maxRetries) {
          throw _mapper.map(e);
        }
        attempt++;
        final delay = Duration(milliseconds: 400 * attempt);
        developer.log('Retry $attempt after ${delay.inMilliseconds}ms',
            name: 'DioClient');
        await Future.delayed(delay);
      }
    }
  }

  bool _isRetryable(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError;
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log('→ ${options.method} ${options.uri}', name: 'Dio');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log('← ${response.statusCode} ${response.requestOptions.uri}',
        name: 'Dio');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '✖ ${err.requestOptions.uri} :: ${err.type} :: ${err.message}',
      name: 'Dio',
    );
    handler.next(err);
  }
}
