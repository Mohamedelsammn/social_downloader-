import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/either.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/library_repository.dart';

class DeleteDownloadUseCase implements UseCase<void, DeleteDownloadParams> {
  final LibraryRepository _repository;
  DeleteDownloadUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(DeleteDownloadParams params) {
    return _repository.delete(params.id);
  }
}

class DeleteDownloadParams extends Equatable {
  final String id;
  const DeleteDownloadParams(this.id);

  @override
  List<Object?> get props => [id];
}
