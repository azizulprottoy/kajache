import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/storage/local_storage_service.dart';

class ThemeController extends GetxController {
  final _storage = Get.find<LocalStorageService>();

  final _themeMode = ThemeMode.light.obs;
  ThemeMode get themeMode => _themeMode.value;

  bool get isDarkMode => _themeMode.value == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    _loadSavedTheme();
  }

  void _loadSavedTheme() {
    final saved = _storage.themeMode;
    _themeMode.value = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(_themeMode.value);
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