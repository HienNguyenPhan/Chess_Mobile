import 'package:chess_app/features/auth/data/firebase_auth_service.dart';

class ForgotPasswordUseCase {
  final FirebaseAuthService _authService;

  ForgotPasswordUseCase(this._authService);

  Future<void> call(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }
}