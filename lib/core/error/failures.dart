import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'The request took too long.']);
}

class InvalidUrlFailure extends Failure {
  const InvalidUrlFailure([super.message = 'The URL is invalid.']);
}

class UnsupportedMediaFailure extends Failure {
  const UnsupportedMediaFailure([
    super.message =
        'This link does not point to a downloadable video file.',
  ]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error.']);
}

class DownloadFailure extends Failure {
  const DownloadFailure([super.message = 'Failed to download the file.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong.']);
}
