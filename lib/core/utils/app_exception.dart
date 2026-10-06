class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      '$runtimeType(${statusCode != null ? '$statusCode, ' : ''}$message)';
}

/// Data arrived but could not be parsed into the expected model.
final class ParseException extends AppException {
  const ParseException({super.statusCode})
    : super('Something went wrong. Please try again.');
}

final class UnknownException extends AppException {
  const UnknownException() : super('Something went wrong. Please try again.');
}
