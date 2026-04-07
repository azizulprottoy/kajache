import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/storage/local_storage_service.dart';

class LocaleController extends GetxController {
  final _storage = Get.find<LocalStorageService>();

  final _locale = const Locale('en', 'US').obs;
  Locale get locale => _locale.value;

  // Supported locales
  static const List<Map<String, dynamic>> supportedLanguages = [
    {'name': 'English',  'nativeName': 'English',  'locale': Locale('en', 'US'), 'flag': '🇺🇸'},
    {'name': 'Bengali',  'nativeName': 'বাংলা',     'locale': Locale('bn', 'BD'), 'flag': '🇧🇩'},
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  void _loadSavedLocale() {
    final saved = _storage.language;
    switch (saved) {
      case 'bn':
        _locale.value = const Locale('bn', 'BD');
        break;
      default:
        _locale.value = const Locale('en', 'US');
    }
    Get.updateLocale(_locale.value);
  }

  void setEnglish() => _setLocale(const Locale('en', 'US'), 'en');
  void setBengali() => _setLocale(const Locale('bn', 'BD'), 'bn');

  void setLocaleByCode(String code) {
    switch (code) {
      case 'bn': setBengali(); break;
      default:   setEnglish();
    }
  }

  void _setLocale(Locale locale, String code) {
    _locale.value = locale;
    Get.updateLocale(locale);
    _storage.setLanguage(code);
  }

  String get currentLanguageCode => _locale.value.languageCode;

  bool get isBengali => currentLanguageCode == 'bn';
  bool get isEnglish => currentLanguageCode == 'en';
}