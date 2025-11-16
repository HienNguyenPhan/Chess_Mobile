import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth;
  final SharedPreferences _prefs;
  static const String _isLoggedInKey = 'is_logged_in';
  
  FirebaseAuthService(this._auth, this._prefs);

  Future<void> signUp({required String email, required String password}) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await setLoggedIn(true);
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await setLoggedIn(true);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await setLoggedIn(false);
  }

  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(_isLoggedInKey, value);
  }

  bool get isLoggedIn => _prefs.getBool(_isLoggedInKey) ?? false;
}
