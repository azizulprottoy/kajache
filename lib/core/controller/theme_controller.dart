import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../storage/local_storage_service.dart';

class ThemeController extends GetxController {
  final _storage = Get.find<LocalStorageService>();

  final _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;

  bool get isDarkMode => _themeMode.value == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    _loadSavedTheme();
  }

  void _loadSavedTheme() {
    // Read before GetMaterialApp builds, so app.dart passes it as themeMode.
    switch (_storage.themeMode) {
      case 'dark':
        _themeMode.value = ThemeMode.dark;
      case 'light':
        _themeMode.value = ThemeMode.light;
      default:
        _themeMode.value = ThemeMode.system;
    }
  }

  void toggleTheme() {
    if (isDarkMode) {
      setLight();
    } else {
      setDark();
    }
  }

  void setDark() {
    _themeMode.value = ThemeMode.dark;
    Get.changeThemeMode(ThemeMode.dark);
    _storage.setThemeMode('dark');
  }

  void setLight() {
    _themeMode.value = ThemeMode.light;
    Get.changeThemeMode(ThemeMode.light);
    _storage.setThemeMode('light');
  }

  void setSystem() {
    _themeMode.value = ThemeMode.system;
    Get.changeThemeMode(ThemeMode.system);
    _storage.setThemeMode('system');
  }
}