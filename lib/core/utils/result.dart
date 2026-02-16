import '../errors/failures.dart';

/// Result type for operations that can fail
/// Inspired by functional programming patterns
sealed class Result<T> {
  const Result();
}

/// Success result containing a value
class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

/// Failure result containing an error
class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);
}

/// Extension methods for Result
extension ResultExtensions<T> on Result<T> {
  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;

  /// Get value if success, null otherwise
  T? get valueOrNull => this is Success<T> ? (this as Success<T>).value : null;

  /// Get error if failure, null otherwise
  AppError? get errorOrNull =>
      this is Failure<T> ? (this as Failure<T>).error : null;

  /// Map the value if success
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success(value: final v) => Success(transform(v)),
      Failure(error: final e) => Failure(e),
    };
  }

  /// Flat map for chaining operations
  Result<R> flatMap<R>(Result<R> Function(T value) transform) {
    return switch (this) {
      Success(value: final v) => transform(v),
      Failure(error: final e) => Failure(e),
    };
  }

  /// Get value or throw error
  T getOrThrow() {
    return switch (this) {
      Success(value: final v) => v,
      Failure(error: final e) => throw e,
    };
  }

  /// Get value or return default
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success(value: final v) => v,
      Failure() => defaultValue,
    };
  }

  /// Execute callback on success
  Result<T> onSuccess(void Function(T value) callback) {
    if (this is Success<T>) {
      callback((this as Success<T>).value);
    }
    return this;
  }

  /// Execute callback on failure
  Result<T> onFailure(void Function(AppError error) callback) {
    if (this is Failure<T>) {
      callback((this as Failure<T>).error);
    }
    return this;
  }
}
