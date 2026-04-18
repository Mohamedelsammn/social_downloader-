import 'dart:io';

import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecases/either.dart';
import '../../../downloads_library/data/datasources/library_local_datasource.dart';
import '../../../downloads_library/data/models/download_item_model.dart';
import '../../../downloads_library/domain/entities/download_item.dart';
import '../../domain/entities/download_progress.dart';
import '../../domain/entities/resolved_video.dart';
import '../../domain/repositories/download_repository.dart';
import '../datasources/download_remote_datasource.dart';
import '../datasources/resolve_remote_datasource.dart';

class DownloadRepositoryImpl implements DownloadRepository {
  final ResolveRemoteDataSource _resolveDataSource;
  final DownloadRemoteDataSource _downloadDataSource;
  final LibraryLocalDataSource _libraryDataSource;
  final NetworkInfo _networkInfo;
  final Uuid _uuid;

  DownloadRepositoryImpl({
    required ResolveRemoteDataSource resolveDataSource,
    required DownloadRemoteDataSource downloadDataSource,
    required LibraryLocalDataSource libraryDataSource,
    required NetworkInfo networkInfo,
    Uuid? uuid,
  })  : _resolveDataSource = resolveDataSource,
        _downloadDataSource = downloadDataSource,
        _libraryDataSource = libraryDataSource,
        _networkInfo = networkInfo,
        _uuid = uuid ?? const Uuid();

  @override
  Future<Either<Failure, ResolvedVideo>> resolve(String url) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final model = await _resolveDataSource.resolve(url);
      return Right(model);
    } on InvalidUrlException catch (e) {
      return Left(InvalidUrlFailure(e.message));
    } on UnsupportedMediaException catch (e) {
      return Left(UnsupportedMediaFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DownloadItem>> downloadToLibrary({
    required ResolvedVideo video,
    required String sourceUrl,
    void Function(DownloadProgress progress)? onProgress,
  }) async {
    if (video.type == VideoStreamType.stream) {
      return const Left(
        UnsupportedMediaFailure(
          'HLS/DASH streams require transcoding and cannot be stored directly.',
        ),
      );
    }
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final dir = await _libraryDataSource.getDownloadsDirectory();
      final id = _uuid.v4();
      final fileName = _buildFileName(id, video);
      final savePath = '${dir.path}${Platform.pathSeparator}$fileName';

      await _downloadDataSource.downloadFile(
        url: video.downloadUrl,
        savePath: savePath,
        headers: video.httpHeaders,
        onProgress: (received, total) {
          onProgress?.call(
            DownloadProgress(received: received, total: total),
          );
        },
      );

      final file = File(savePath);
      final size = await file.length();

      final model = DownloadItemModel(
        id: id,
        title: video.title,
        localPath: savePath,
        sourceUrl: sourceUrl,
        sizeBytes: size,
        addedAt: DateTime.now(),
        contentType: video.contentType,
      );
      await _libraryDataSource.add(model);
      return Right(model);
    } on DownloadException catch (e) {
      return Left(DownloadFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  String _buildFileName(String id, ResolvedVideo video) {
    final raw = video.title.trim().isEmpty ? 'video' : video.title.trim();
    final cleaned = raw.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final short = cleaned.length > 60 ? cleaned.substring(0, 60) : cleaned;
    final hasExtension = RegExp(r'\.[a-zA-Z0-9]{2,4}$').hasMatch(short);
    final fallback = _extensionFor(video.contentType) ?? '.mp4';
    final base = hasExtension ? short : '$short$fallback';
    return '${id.substring(0, 8)}_$base';
  }

  String? _extensionFor(String? contentType) {
    if (contentType == null) return null;
    final ct = contentType.toLowerCase();
    if (ct.contains('mp4')) return '.mp4';
    if (ct.contains('webm')) return '.webm';
    if (ct.contains('quicktime')) return '.mov';
    if (ct.contains('x-matroska')) return '.mkv';
    return null;
  }
}
