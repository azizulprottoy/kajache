import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../features/home/views/home_page.dart';
import '../../features/menu/views/menu_page.dart';
import '../../features/services/views/all_services_list.dart';

class LocaleController extends GetxController {
  final _storage = Get.find<LocalStorageService>();
  final RxInt currentIndex = 1.obs;

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

  void changeNavIndex(int index) {
    if (currentIndex.value == index) return;

    currentIndex.value = index;

    if (index == 0) {
      Get.offNamed('/all-services');
    } else if (index == 1) {
      Get.offNamed('/home');
    } else if (index == 2) {
      Get.offNamed('/menu');
    }
  }
  String get currentLanguageCode => _locale.value.languageCode;

  bool get isBengali => currentLanguageCode == 'bn';
  bool get isEnglish => currentLanguageCode == 'en';
}