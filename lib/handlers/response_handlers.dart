class Result<T> {
  final T? data;
  final String? error;

  Result({this.data, this.error});

  bool get isSuccess => error == null;
  bool get isLoading => data == null && error == null;
}

sealed class BreezResult<S, E> {}

class Success<S, E> extends BreezResult<S, E> {
  final S value;
  Success(this.value);
}

class Failure<S, E> extends BreezResult<S, E> {
  final E error;
  Failure(this.error);
}