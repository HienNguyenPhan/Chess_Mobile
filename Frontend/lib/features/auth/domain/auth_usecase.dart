
import 'package:chess_app/features/auth/domain/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  Future<void> call(String email, String password) {
    return repository.signUp(email: email, password: password);
  }
}

class SignInUseCase {
  final AuthRepository repository;
  SignInUseCase(this.repository);

  Future<void> call(String email, String password) {
    return repository.signIn(email: email, password: password);
  }
}