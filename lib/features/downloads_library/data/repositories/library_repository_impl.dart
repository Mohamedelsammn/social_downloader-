import 'dart:io';

import 'package:share_plus/share_plus.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/either.dart';
import '../../domain/entities/download_item.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_local_datasource.dart';

typedef ShareFilesFn =
    Future<ShareResult> Function(List<XFile> files, {String? text});

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryLocalDataSource _local;
  final ShareFilesFn _shareFiles;

  LibraryRepositoryImpl(this._local, {ShareFilesFn? shareFiles})
    : _shareFiles = shareFiles ?? _defaultShare;

  static Future<ShareResult> _defaultShare(List<XFile> files, {String? text}) {
    return Share.shareXFiles(files, text: text);
  }

  @override
  Future<Either<Failure, List<DownloadItem>>> getAll() async {
    try {
      final items = await _local.getAll();
      return Right(items);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      final items = await _local.getAll();
      final target = items.where((e) => e.id == id).toList();
      await _local.remove(id);
      for (final item in target) {
        final file = File(item.localPath);
        if (await file.exists()) {
          try {
            await file.delete();
          } catch (_) {
            /* best effort */
          }
        }
      }
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> share(DownloadItem item) async {
    try {
      final file = File(item.localPath);
      if (!await file.exists()) {
        return const Left(
          CacheFailure('The file is no longer available on this device.'),
        );
      }
      await _shareFiles([XFile(item.localPath)], text: item.title);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
