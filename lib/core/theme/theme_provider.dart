import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  final SharedPreferences? prefs;
  bool _disposed = false;

  ThemeProvider({this.prefs}) {
    _loadTheme();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _loadTheme() {
    final localPrefs = prefs;
    if (localPrefs == null) return;
    final saved = localPrefs.getString(AppConstants.prefThemeMode);
    if (saved == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = (_themeMode == ThemeMode.dark)
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
    final localPrefs = prefs;
    if (localPrefs != null) {
      await localPrefs.setString(
        AppConstants.prefThemeMode,
        _themeMode == ThemeMode.light ? 'light' : 'dark',
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final localPrefs = prefs;
    if (localPrefs != null) {
      await localPrefs.setString(
        AppConstants.prefThemeMode,
        mode == ThemeMode.light ? 'light' : 'dark',
      );
    }
  }
}
