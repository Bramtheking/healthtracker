// theme_notifier.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;
  late Box settingsBox;

  bool get isDarkMode => _isDarkMode;

  ThemeNotifier() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    settingsBox = await Hive.openBox('settings');
    _isDarkMode = settingsBox.get('theme', defaultValue: false);
    notifyListeners();
  }

  void toggleTheme(bool isDark) {
    _isDarkMode = isDark;
    settingsBox.put('theme', _isDarkMode);
    notifyListeners();
  }

  ThemeData get themeData => _isDarkMode ? ThemeData.dark() : ThemeData.light();
}
