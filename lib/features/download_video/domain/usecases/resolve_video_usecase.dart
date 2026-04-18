import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/either.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/resolved_video.dart';
import '../repositories/download_repository.dart';

class ResolveVideoUseCase implements UseCase<ResolvedVideo, ResolveVideoParams> {
  final DownloadRepository _repository;

  ResolveVideoUseCase(this._repository);

  @override
  Future<Either<Failure, ResolvedVideo>> call(ResolveVideoParams params) {
    return _repository.resolve(params.url);
  }
}

class ResolveVideoParams extends Equatable {
  final String url;
  const ResolveVideoParams(this.url);

  @override
  List<Object?> get props => [url];
}
