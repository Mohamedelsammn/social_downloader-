import '../../../../core/error/failures.dart';
import '../../../../core/usecases/either.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/download_item.dart';
import '../repositories/library_repository.dart';

class GetDownloadsUseCase
    implements UseCase<List<DownloadItem>, NoParams> {
  final LibraryRepository _repository;
  GetDownloadsUseCase(this._repository);

  @override
  Future<Either<Failure, List<DownloadItem>>> call(NoParams params) {
    return _repository.getAll();
  }
}
