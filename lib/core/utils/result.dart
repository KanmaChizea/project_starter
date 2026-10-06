import 'app_exception.dart';
import 'app_logger.dart';

sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok._;

  const factory Result.error(AppException error) = Error._;
}

final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  final T value;

  @override
  String toString() => '$value';
}

final class Error<T> extends Result<T> {
  const Error._(this.error);
  final AppException error;

  @override
  String toString() => '$error';
}

extension ResultX<T> on Result<T> {
  R fold<R>(R Function(AppException error) onError, R Function(T value) onOk) =>
      switch (this) {
        Ok(:final value) => onOk(value),
        Error(:final error) => onError(error),
      };

  /// Transforms the value. If [transform] throws (e.g. a response that
  /// doesn't match the model), the result is a [ParseException].
  Result<R> map<R>(R Function(T value) transform) {
    switch (this) {
      case Ok(:final value):
        try {
          return Result.ok(transform(value));
        } catch (error, stackTrace) {
          AppLogger.log('ParseException: $error\n$stackTrace');
          return const Result.error(ParseException());
        }
      case Error(:final error):
        return Result.error(error);
    }
  }
}
