import '../../../../core/error/failures.dart';
import '../../../../core/usecases/either.dart';
import '../../../downloads_library/domain/entities/download_item.dart';
import '../entities/download_progress.dart';
import '../entities/resolved_video.dart';

abstract class DownloadRepository {
  Future<Either<Failure, ResolvedVideo>> resolve(String url);

  Future<Either<Failure, DownloadItem>> downloadToLibrary({
    required ResolvedVideo video,
    required String sourceUrl,
    void Function(DownloadProgress progress)? onProgress,
  });
}
