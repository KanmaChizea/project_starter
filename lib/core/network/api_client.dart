import 'package:dio/dio.dart';

import '../utils/result.dart';

abstract interface class ApiClient {
  Future<Result<T>> get<T>(String path, {Map<String, Object?>? query});

  Future<Result<T>> post<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
  });

  Future<Result<T>> put<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
  });

  Future<Result<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
  });

  Future<Result<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
  });

  /// Multipart upload. Dio sets the multipart content type and boundary.
  Future<Result<T>> upload<T>(
    String path, {
    required FormData data,
    String method = 'POST',
    ProgressCallback? onSendProgress,
  });

  /// Streams the response body to [savePath].
  Future<Result<void>> download(
    String path,
    String savePath, {
    Map<String, Object?>? query,
    ProgressCallback? onReceiveProgress,
  });
}
