import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_starter/core/storage/local_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._storage) : super(_loadInitialTheme(_storage));

  final LocalStorage _storage;

  static ThemeMode _loadInitialTheme(LocalStorage storage) {
    final saved = storage.getString(LocalStorageKey.themeMode);
    if (saved == null) return ThemeMode.system;
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setTheme(ThemeMode mode) async {
    if (state == mode) return;
    await _storage.setString(LocalStorageKey.themeMode, mode.name);
    emit(mode);
  }
}
