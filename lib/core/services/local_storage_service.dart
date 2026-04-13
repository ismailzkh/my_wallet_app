import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A simple local key–value storage service based on SharedPreferences.
/// All data stays on the device – no network, no accounts.
class LocalStorageService {
  LocalStorageService._(this._prefs);

  final SharedPreferences _prefs;

  static LocalStorageService? _instance;

  /// Initialize the service. Call this once at app startup (bootstrap).
  static Future<LocalStorageService> init() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = LocalStorageService._(prefs);
    return _instance!;
  }

  /// Get the already initialized instance.
  static LocalStorageService get instance {
    final instance = _instance;
    if (instance == null) {
      throw StateError(
        'LocalStorageService not initialized. Call LocalStorageService.init() first.',
      );
    }
    return instance;
  }

  /// Reload from disk to avoid stale cached values.
  Future<void> reload() async {
    await _prefs.reload();
  }

  // ---------- Basic primitives ----------

  Future<bool> setString(String key, String value) async {
    return _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<bool> setInt(String key, int value) async {
    return _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<bool> setDouble(String key, double value) async {
    return _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  Future<bool> remove(String key) async {
    return _prefs.remove(key);
  }

  Future<bool> clear() async {
    return _prefs.clear();
  }

  // ---------- JSON helpers (for lists / objects) ----------

  Future<bool> setJson(String key, Object value) async {
    final encoded = jsonEncode(value);
    return _prefs.setString(key, encoded);
  }

  dynamic getJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<bool> setStringList(String key, List<String> value) async {
    return _prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }
}