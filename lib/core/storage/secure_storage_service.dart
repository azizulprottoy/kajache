import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class SecureStorageService extends GetxService {
  late final FlutterSecureStorage _storage;

  static const _keyToken        = 'auth_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId       = 'user_id';
  static const _keyUserRole     = 'user_role';

  Future<SecureStorageService> init() async {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
    return this;
  }

  // ── Token ───────────────────────────────────────────────────────────────────
  Future<void> saveToken(String token) async =>
      _storage.write(key: _keyToken, value: token);

  Future<String?> getToken() async =>
      _storage.read(key: _keyToken);

  Future<void> saveRefreshToken(String token) async =>
      _storage.write(key: _keyRefreshToken, value: token);

  Future<String?> getRefreshToken() async =>
      _storage.read(key: _keyRefreshToken);

  // ── User ────────────────────────────────────────────────────────────────────
  Future<void> saveUserId(String id) async =>
      _storage.write(key: _keyUserId, value: id);

  Future<String?> getUserId() async =>
      _storage.read(key: _keyUserId);

  Future<void> saveUserRole(String role) async =>
      _storage.write(key: _keyUserRole, value: role);

  Future<String?> getUserRole() async =>
      _storage.read(key: _keyUserRole);

  // ── Generic ─────────────────────────────────────────────────────────────────
  Future<void> write(String key, String value) async =>
      _storage.write(key: key, value: value);

  Future<String?> read(String key) async =>
      _storage.read(key: key);

  Future<void> delete(String key) async =>
      _storage.delete(key: key);

  // ── Clear all (logout) ──────────────────────────────────────────────────────
  Future<void> clearAll() async => _storage.deleteAll();
}