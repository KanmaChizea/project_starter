import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/app_logger.dart';

enum SecureStorageKey { accessToken, refreshToken, cachedUser }

class SecureStorage {
  factory SecureStorage() => _instance;

  SecureStorage._();

  static final _instance = SecureStorage._();

  // Readable after the first unlock, so background work (e.g. push handling)
  // can still read tokens.
  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  final _storage = const FlutterSecureStorage(iOptions: _iosOptions);

  /// A key that is present but null means "known to have no value".
  final _cache = <SecureStorageKey, String?>{};

  Future<String?> read(SecureStorageKey key) async {
    if (_cache.containsKey(key)) return _cache[key];
    final String? value;
    try {
      value = await _storage.read(key: key.name);
    } on PlatformException {
      await delete(key);
      return null;
    }
    return _cache.putIfAbsent(key, () => value);
  }

  Future<void> write(SecureStorageKey key, String value) async {
    try {
      await _storage.write(key: key.name, value: value);
    } on PlatformException catch (error) {
      AppLogger.log('SecureStorage write ${key.name} failed: $error');
    }
    _cache[key] = value;
  }

  Future<void> delete(SecureStorageKey key) async {
    try {
      await _storage.delete(key: key.name);
    } on PlatformException {
      //
    }
    _cache[key] = null;
  }

  /// For tests that swap the underlying storage between cases.
  @visibleForTesting
  void resetCache() => _cache.clear();

  Future<void> clear() async {
    for (final key in SecureStorageKey.values) {
      await delete(key);
    }
  }
}
