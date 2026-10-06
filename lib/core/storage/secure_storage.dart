import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'local_storage.dart';

enum SecureStorageKey { accessToken, refreshToken, cachedUser }

class SecureStorage {
  SecureStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(iOptions: _iosOptions);

  // Readable after the first unlock, so background work (e.g. push handling)
  // can still read tokens.
  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  final FlutterSecureStorage _storage;

  Future<String?> read(SecureStorageKey key) async {
    try {
      return await _storage.read(key: key.name);
    } on PlatformException {
      await delete(key);
      return null;
    }
  }

  Future<void> write(SecureStorageKey key, String value) =>
      _storage.write(key: key.name, value: value);

  Future<void> delete(SecureStorageKey key) async {
    try {
      await _storage.delete(key: key.name);
    } on PlatformException {
      //
    }
  }

  Future<void> clear() async {
    for (final key in SecureStorageKey.values) {
      await delete(key);
    }
  }

  /// iOS keeps Keychain items after uninstall but deletes preferences, so a
  /// missing launch flag means a fresh install: drop any leftover secrets.
  Future<void> clearOnFirstLaunch(LocalStorage localStorage) async {
    if (localStorage.getBool(LocalStorageKey.hasLaunchedBefore) ?? false) {
      return;
    }
    await clear();
    await localStorage.setBool(LocalStorageKey.hasLaunchedBefore, true);
  }
}
