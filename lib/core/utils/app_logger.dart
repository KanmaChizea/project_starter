import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static const _top =
      '╔═══════════════════════════════════════════════════════════════';
  static const _mid =
      '╠═══════════════════════════════════════════════════════════════';
  static const _bottom =
      '╚═══════════════════════════════════════════════════════════════';

  // Comment out locally if you need to see them while debugging.
  static const _sensitiveHeaders = {'authorization', 'cookie', 'set-cookie'};

  static void log(String message) {
    if (!kDebugMode) return;
    _print([_top, '║ $message', _bottom]);
  }

  static void logRequest(RequestOptions options) {
    if (!kDebugMode) return;
    _print([
      _top,
      '║ 📤 REQUEST',
      _mid,
      '║ Method: ${options.method}',
      '║ URL: ${options.uri}',
      if (options.queryParameters.isNotEmpty)
        '║ Query: ${options.queryParameters}',
      if (options.headers.isNotEmpty)
        '║ Headers: ${_sanitizeHeaders(options.headers)}',
      if (options.data != null) '║ Body: ${_formatData(options.data)}',
      _bottom,
    ]);
  }

  static void logResponse(Response<dynamic> response) {
    if (!kDebugMode) return;
    final statusCode = response.statusCode ?? 0;
    final isSuccess = statusCode >= 200 && statusCode < 300;
    _print([
      _top,
      '║ ${isSuccess ? '✅' : '⚠️'} RESPONSE',
      _mid,
      '║ Status: $statusCode',
      '║ URL: ${response.requestOptions.uri}',
      if (response.headers.map.isNotEmpty)
        '║ Headers: ${_sanitizeHeaders(response.headers.map)}',
      '║ Data: ${_formatData(response.data)}',
      _bottom,
    ]);
  }

  static void logError(DioException error) {
    if (!kDebugMode) return;
    _print([
      _top,
      '║ ❌ ERROR',
      _mid,
      '║ Type: ${error.type}',
      '║ URL: ${error.requestOptions.uri}',
      if (error.response != null) '║ Status: ${error.response?.statusCode}',
      if (error.response?.data != null)
        '║ Response: ${_formatData(error.response?.data)}',
      _bottom,
    ]);
  }

  /// Android's logcat truncates lines around 4 KB, and debugPrint only wraps
  /// at spaces, so long lines are split into fixed-size chunks. debugPrint
  /// throttles output, so nothing is dropped.
  static const _chunk = 800;

  static void _print(List<String> lines) {
    for (final line in lines.expand((l) => l.split('\n'))) {
      for (var i = 0; i < line.length; i += _chunk) {
        final end = i + _chunk < line.length ? i + _chunk : line.length;
        debugPrint(
          i == 0 ? line.substring(i, end) : '║ ${line.substring(i, end)}',
        );
      }
      if (line.isEmpty) debugPrint(line);
    }
  }

  static String _formatData(Object? data) => data?.toString() ?? 'null';

  static Map<String, Object?> _sanitizeHeaders(Map<String, Object?> headers) =>
      {
        for (final MapEntry(:key, :value) in headers.entries)
          key: _sensitiveHeaders.contains(key.toLowerCase())
              ? '***HIDDEN***'
              : value,
      };
}
