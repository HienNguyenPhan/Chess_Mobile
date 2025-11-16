import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  static final _secure = const FlutterSecureStorage();
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  static Future<void> writeSecure(String key, String value) async {
    await _secure.write(key: key, value: value);
  }

  static Future<String?> readSecure(String key) async {
    return await _secure.read(key: key);
  }

  static Future<void> deleteSecure(String key) async {
    await _secure.delete(key: key);
  }

  static Future<void> clearAll() async {
    await _prefs?.clear();
    await _secure.deleteAll();
  }
}
