import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/either.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../downloads_library/domain/entities/download_item.dart';
import '../entities/download_progress.dart';
import '../entities/resolved_video.dart';
import '../repositories/download_repository.dart';

class DownloadVideoUseCase
    implements UseCase<DownloadItem, DownloadVideoParams> {
  final DownloadRepository _repository;

  DownloadVideoUseCase(this._repository);

  @override
  Future<Either<Failure, DownloadItem>> call(DownloadVideoParams params) {
    return _repository.downloadToLibrary(
      video: params.video,
      sourceUrl: params.sourceUrl,
      onProgress: params.onProgress,
    );
  }
}

class DownloadVideoParams extends Equatable {
  final ResolvedVideo video;
  final String sourceUrl;
  final void Function(DownloadProgress progress)? onProgress;

  const DownloadVideoParams({
    required this.video,
    required this.sourceUrl,
    this.onProgress,
  });

  @override
  List<Object?> get props => [video, sourceUrl];
}
