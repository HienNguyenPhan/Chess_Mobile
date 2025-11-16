
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _isLoggedInKey = 'is_logged_in';
  final SharedPreferences _prefs;

  AuthService(this._prefs);

  Future<bool> isLoggedIn() async {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(_isLoggedInKey, value);
  }
}