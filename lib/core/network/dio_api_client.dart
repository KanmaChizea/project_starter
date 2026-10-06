import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env_config.dart';
import '../utils/result.dart';
import 'api_client.dart';
import 'auth_interceptor.dart';
import 'dio_exception_mapper.dart';
import 'logging_interceptor.dart';

class DioApiClient implements ApiClient {
  DioApiClient({required Future<void> Function() onSessionExpired}) {
    final options = BaseOptions(
      baseUrl: EnvConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );
    final plainDio = Dio(options);
    _dio = Dio(options);
    _dio.interceptors.add(
      AuthInterceptor(plainDio: plainDio, onSessionExpired: onSessionExpired),
    );
    if (!kReleaseMode) {
      plainDio.interceptors.add(LoggingInterceptor());
      _dio.interceptors.add(LoggingInterceptor());
    }
  }

  late final Dio _dio;

  @override
  Future<Result<Response<T>>> get<T>(
    String path, {
    Map<String, Object?>? query,
  }) => _guard(() => _dio.get<T>(path, queryParameters: query));

  @override
  Future<Result<Response<T>>> post<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
  }) => _guard(() => _dio.post<T>(path, data: data, queryParameters: query));

  @override
  Future<Result<Response<T>>> put<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
  }) => _guard(() => _dio.put<T>(path, data: data, queryParameters: query));

  @override
  Future<Result<Response<T>>> patch<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
  }) => _guard(() => _dio.patch<T>(path, data: data, queryParameters: query));

  @override
  Future<Result<Response<T>>> delete<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
  }) => _guard(() => _dio.delete<T>(path, data: data, queryParameters: query));

  @override
  Future<Result<Response<T>>> upload<T>(
    String path, {
    required FormData data,
    String method = 'POST',
    ProgressCallback? onSendProgress,
  }) => _guard(
    () => _dio.request<T>(
      path,
      data: data,
      onSendProgress: onSendProgress,
      options: Options(method: method),
    ),
  );

  @override
  Future<Result<Response<Object?>>> download(
    String path,
    String savePath, {
    Map<String, Object?>? query,
    ProgressCallback? onReceiveProgress,
  }) => _guard(
    () => _dio.download(
      path,
      savePath,
      queryParameters: query,
      onReceiveProgress: onReceiveProgress,
    ),
  );

  Future<Result<Response<T>>> _guard<T>(
    Future<Response<T>> Function() request,
  ) async {
    try {
      return Result.ok(await request());
    } on DioException catch (e) {
      return Result.error(e.toAppException());
    }
  }
}
