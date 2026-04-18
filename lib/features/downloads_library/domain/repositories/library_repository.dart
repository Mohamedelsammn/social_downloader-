import '../../../../core/error/failures.dart';
import '../../../../core/usecases/either.dart';
import '../entities/download_item.dart';

abstract class LibraryRepository {
  Future<Either<Failure, List<DownloadItem>>> getAll();
  Future<Either<Failure, void>> delete(String id);
  Future<Either<Failure, void>> share(DownloadItem item);
}
