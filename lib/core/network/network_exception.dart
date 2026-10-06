import '../utils/app_exception.dart';

/// No connection, DNS failure or timeout.
final class NetworkException extends AppException {
  const NetworkException() : super('No internet connection. Please try again.');
}

/// 401 after a failed token refresh. The session has already been cleared.
final class UnauthorizedException extends AppException {
  const UnauthorizedException()
    : super('Your session has expired.', statusCode: 401);
}

/// Any other non-2xx response. The message comes from the body when present.
final class ServerException extends AppException {
  const ServerException(int? statusCode, super.message)
    : super(statusCode: statusCode);
}
