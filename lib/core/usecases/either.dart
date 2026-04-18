/// Minimal Either implementation so we don't pull in `dartz` just for this.
/// `Left` is used for failures, `Right` for success values.
sealed class Either<L, R> {
  const Either();

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  T fold<T>(T Function(L l) onLeft, T Function(R r) onRight) {
    final self = this;
    if (self is Left<L, R>) return onLeft(self.value);
    if (self is Right<L, R>) return onRight(self.value);
    throw StateError('Unreachable Either variant.');
  }
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
}
