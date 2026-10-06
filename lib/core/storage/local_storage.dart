import 'package:shared_preferences/shared_preferences.dart';

enum LocalStorageKey { themeMode }

class LocalStorage {
  LocalStorage._(this._prefs);

  static Future<LocalStorage> create() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(
        allowList: {for (final key in LocalStorageKey.values) key.name},
      ),
    );
    return LocalStorage._(prefs);
  }

  final SharedPreferencesWithCache _prefs;

  bool? getBool(LocalStorageKey key) => _prefs.getBool(key.name);

  Future<void> setBool(LocalStorageKey key, bool value) =>
      _prefs.setBool(key.name, value);

  String? getString(LocalStorageKey key) => _prefs.getString(key.name);

  Future<void> setString(LocalStorageKey key, String value) =>
      _prefs.setString(key.name, value);

  Future<void> remove(LocalStorageKey key) => _prefs.remove(key.name);
}
