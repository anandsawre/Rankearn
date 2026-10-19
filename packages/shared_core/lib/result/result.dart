/// Sealed Result type for functional error handling across data layers.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success(data: final d) => d,
        Failure() => null,
      };

  String? get errorOrNull => switch (this) {
        Success() => null,
        Failure(message: final m) => m,
      };

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String message, dynamic error) onFailure,
  }) {
    return switch (this) {
      Success(data: final d) => onSuccess(d),
      Failure(message: final m, error: final e) => onFailure(m, e),
    };
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final dynamic error;
  const Failure(this.message, [this.error]);
}
