import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage service for local data persistence
class StorageService {
  late final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _userKey = 'user';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Initialize the storage service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ============ Secure Storage (Tokens) ============

  /// Save access token securely
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// Save refresh token securely
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  // ============ Regular Storage (User Data) ============

  /// Save user data as JSON
  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _prefs.setString(_userKey, jsonEncode(userData));
  }

  /// Get user data
  Map<String, dynamic>? getUser() {
    final userString = _prefs.getString(_userKey);
    if (userString == null) return null;
    return jsonDecode(userString) as Map<String, dynamic>;
  }

  /// Clear user data
  Future<void> clearUser() async {
    await _prefs.remove(_userKey);
  }

  // ============ General Methods ============

  /// Save a string value
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  /// Get a string value
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Save a boolean value
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  /// Get a boolean value
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Remove a value
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  /// Clear all data (logout)
  Future<void> clearAll() async {
    await clearTokens();
    await clearUser();
  }
}
