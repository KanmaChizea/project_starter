import 'dart:io';

import 'package:dio/dio.dart';

import '../utils/app_exception.dart';
import 'network_exception.dart';

extension DioExceptionMapper on DioException {
  AppException toAppException() {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final status = response?.statusCode;
        final hadToken = requestOptions.headers['Authorization'] != null;
        if (status == 401 && hadToken) {
          return const UnauthorizedException();
        }
        return ServerException(status, serverMessage ?? _fallbackMessage);
      case DioExceptionType.unknown:
        return error is SocketException
            ? const NetworkException()
            : const UnknownException();
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
        return const UnknownException();
    }
  }

  /// The error message from the response body, if any.
  // TODO: match your backend's error body.
  String? get serverMessage {
    final body = response?.data;
    return body is Map && body['message'] is String
        ? body['message'] as String
        : null;
  }

  static const _fallbackMessage = 'Something went wrong. Please try again.';
}
