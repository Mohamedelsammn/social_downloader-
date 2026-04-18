import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/either.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/download_item.dart';
import '../repositories/library_repository.dart';

class ShareDownloadUseCase implements UseCase<void, ShareDownloadParams> {
  final LibraryRepository _repository;
  ShareDownloadUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ShareDownloadParams params) {
    return _repository.share(params.item);
  }
}

class ShareDownloadParams extends Equatable {
  final DownloadItem item;
  const ShareDownloadParams(this.item);

  @override
  List<Object?> get props => [item];
}
