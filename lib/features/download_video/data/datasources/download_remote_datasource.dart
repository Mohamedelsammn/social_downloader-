import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';

abstract class DownloadRemoteDataSource {
  Future<void> downloadFile({
    required String url,
    required String savePath,
    Map<String, String> headers = const {},
    void Function(int received, int total)? onProgress,
  });
}

class DownloadRemoteDataSourceImpl implements DownloadRemoteDataSource {
  final Dio _dio;

  DownloadRemoteDataSourceImpl(this._dio);

  @override
  Future<void> downloadFile({
    required String url,
    required String savePath,
    Map<String, String> headers = const {},
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          receiveTimeout: const Duration(minutes: 10),
          headers: headers.isEmpty ? null : Map<String, String>.from(headers),
        ),
      );
    } on DioException catch (e) {
      throw DownloadException(
        e.message ?? 'Failed to download the file.',
      );
    }
  }
}
