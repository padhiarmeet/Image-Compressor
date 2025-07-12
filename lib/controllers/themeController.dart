import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
class ThemeController extends GetxController {
  // Storage instance for persistence
  final _storage = GetStorage();

  final _themeKey = 'isDarkMode';

  final RxBool _isDarkMode = false.obs;

  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
  }

  void _loadThemePreference() {
    final savedTheme = _storage.read(_themeKey);
    if (savedTheme != null) {
      _isDarkMode.value = savedTheme;
      _updateTheme();
    } else {
      _isDarkMode.value = Get.isDarkMode;
      _updateTheme();
    }
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    _updateTheme();
    _saveThemePreference();
  }

  void _updateTheme() {
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void _saveThemePreference() {
    _storage.write(_themeKey, _isDarkMode.value);
  }

  void setDarkMode(bool isDark) {
    _isDarkMode.value = isDark;
    _updateTheme();
    _saveThemePreference();
  }

  void setSystemTheme() {
    Get.changeThemeMode(ThemeMode.system);
    _isDarkMode.value = Get.isDarkMode;
    _saveThemePreference();
  }
}