import 'package:dio/dio.dart';

import '../constants/endpoints.dart';
import 'auth_tokens.dart';
import '../storage/secure_storage.dart';

/// Adds the bearer token, and on a 401 refreshes it once and retries.
///
/// Queued, so concurrent 401s are handled one at a time: the first refreshes,
/// the rest see the new token and just retry. Refresh and retry go through
/// [_plainDio] (no auth interceptor) so a second 401 can't deadlock the queue.
/// If the refresh token is rejected, [_onSessionExpired] is called; if the
/// refresh fails for any other reason (offline, 5xx) the session is kept.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({required this._plainDio, required this._onSessionExpired});

  static const _retried = 'authRetried';

  final _storage = SecureStorage();
  final Dio _plainDio;
  final Future<void> Function() _onSessionExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isOwnApi(options)) {
      final token = await _storage.read(SecureStorageKey.accessToken);
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    // Only a request that carried a token can have an expired session; a 401
    // without one (e.g. wrong password on login) is just an error.
    if (err.response?.statusCode != 401 ||
        _bearer(options) == null ||
        options.extra[_retried] == true) {
      return handler.next(err);
    }

    final current = await _storage.read(SecureStorageKey.accessToken);
    if (current == null) return handler.next(err);

    final String accessToken;
    if (_bearer(options) != current) {
      accessToken = current;
    } else {
      switch (await _refresh()) {
        case _Refreshed(:final tokens):
          accessToken = tokens.accessToken;
        case _Rejected():
          await _onSessionExpired();
          return handler.next(err);
        case _Failed():
          return handler.next(err);
      }
    }

    try {
      final data = options.data;
      final response = await _plainDio.fetch<Object?>(
        options.copyWith(
          // A sent FormData can't be re-sent; retry with a copy.
          data: data is FormData ? data.clone() : data,
          headers: {...options.headers, 'Authorization': 'Bearer $accessToken'},
          extra: {...options.extra, _retried: true},
        ),
      );
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  // TODO: match your backend's refresh request and response.
  Future<_RefreshOutcome> _refresh() async {
    final refreshToken = await _storage.read(SecureStorageKey.refreshToken);
    if (refreshToken == null) return const _Rejected();
    try {
      final response = await _plainDio.post<Map<String, Object?>>(
        Endpoints.refresh,
        data: {'refreshToken': refreshToken},
      );
      final tokens = AuthTokens.fromJson(response.data!);
      await _storage.saveTokens(tokens);
      return _Refreshed(tokens);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final rejected = status == 400 || status == 401 || status == 403;
      return rejected ? const _Rejected() : const _Failed();
    } on Object {
      return const _Failed();
    }
  }

  /// Full URLs to other hosts (presigned uploads, CDNs, third parties) never
  /// get our token.
  bool _isOwnApi(RequestOptions options) {
    final base = Uri.parse(options.baseUrl);
    final uri = options.uri;
    return uri.scheme == base.scheme &&
        uri.host == base.host &&
        uri.port == base.port;
  }

  String? _bearer(RequestOptions options) {
    final header = options.headers['Authorization'];
    return header is String && header.startsWith('Bearer ')
        ? header.substring('Bearer '.length)
        : null;
  }
}

sealed class _RefreshOutcome {
  const _RefreshOutcome();
}

final class _Refreshed extends _RefreshOutcome {
  const _Refreshed(this.tokens);
  final AuthTokens tokens;
}

/// The refresh token is invalid or missing: the session is over.
final class _Rejected extends _RefreshOutcome {
  const _Rejected();
}

/// Network or server trouble: keep the session, fail this request.
final class _Failed extends _RefreshOutcome {
  const _Failed();
}
