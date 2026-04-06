import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocalStorageService extends GetxService {
  late final GetStorage _box;

  static const _keyOnboardingDone = 'onboarding_done';
  static const _keyThemeMode      = 'theme_mode';
  static const _keyLanguage       = 'language';
  static const _keyFcmToken       = 'fcm_token';

  Future<LocalStorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  // ── Onboarding ──────────────────────────────────────────────────────────────
  bool get isOnboardingDone => _box.read(_keyOnboardingDone) ?? false;
  void setOnboardingDone()  => _box.write(_keyOnboardingDone, true);

  // ── Theme ───────────────────────────────────────────────────────────────────
  String get themeMode => _box.read(_keyThemeMode) ?? 'light';
  void setThemeMode(String mode) => _box.write(_keyThemeMode, mode);

  // ── Language ────────────────────────────────────────────────────────────────
  String get language => _box.read(_keyLanguage) ?? 'en';
  void setLanguage(String lang) => _box.write(_keyLanguage, lang);

  // ── FCM Token ───────────────────────────────────────────────────────────────
  String? get fcmToken => _box.read(_keyFcmToken);
  void setFcmToken(String token) => _box.write(_keyFcmToken, token);

  // ── Generic ─────────────────────────────────────────────────────────────────
  void write(String key, dynamic value) => _box.write(key, value);
  T? read<T>(String key) => _box.read<T>(key);
  void remove(String key) => _box.remove(key);
  void clearAll() => _box.erase();
}