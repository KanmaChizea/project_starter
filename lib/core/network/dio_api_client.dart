import 'package:dio/dio.dart';

import '../config/env_config.dart';
import '../utils/app_exception.dart';
import '../utils/app_logger.dart';
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
    plainDio.interceptors.add(LoggingInterceptor());
    _dio.interceptors.add(LoggingInterceptor());
  }

  late final Dio _dio;

  @override
  Future<Result<T>> get<T>(String path, {Map<String, Object?>? query}) =>
      _guard(() => _dio.get(path, queryParameters: query));

  @override
  Future<Result<T>> post<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
  }) => _guard(() => _dio.post(path, data: data, queryParameters: query));

  @override
  Future<Result<T>> put<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
  }) => _guard(() => _dio.put(path, data: data, queryParameters: query));

  @override
  Future<Result<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
  }) => _guard(() => _dio.patch(path, data: data, queryParameters: query));

  @override
  Future<Result<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
  }) => _guard(() => _dio.delete(path, data: data, queryParameters: query));

  @override
  Future<Result<T>> upload<T>(
    String path, {
    required FormData data,
    String method = 'POST',
    ProgressCallback? onSendProgress,
  }) => _guard(
    () => _dio.request(
      path,
      data: data,
      onSendProgress: onSendProgress,
      options: Options(method: method),
    ),
  );

  @override
  Future<Result<void>> download(
    String path,
    String savePath, {
    Map<String, Object?>? query,
    ProgressCallback? onReceiveProgress,
  }) => _guard<void>(
    () => _dio.download(
      path,
      savePath,
      queryParameters: query,
      onReceiveProgress: onReceiveProgress,
    ),
  );

  /// Returns the response body as [T]. A body that isn't a [T] (e.g. null
  /// for a non-nullable type) is a [ParseException].
  Future<Result<T>> _guard<T>(Future<Response> Function() request) async {
    final Response response;
    try {
      response = await request();
    } on DioException catch (e) {
      return Result.error(e.toAppException());
    }
    final data = response.data;
    if (data is T) return Result.ok(data);
    AppLogger.log(
      'ParseException: expected $T, got ${data.runtimeType} '
      'from ${response.requestOptions.uri}',
    );
    return Result.error(ParseException(statusCode: response.statusCode));
  }
}
