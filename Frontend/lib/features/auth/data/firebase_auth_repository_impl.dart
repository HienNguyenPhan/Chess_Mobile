
import 'package:chess_app/features/auth/data/firebase_auth_service.dart';
import 'package:chess_app/features/auth/domain/auth_repository.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService service;

  FirebaseAuthRepositoryImpl(this.service);

  @override
  Future<void> signUp({required String email, required String password}) {
    return service.signUp(email: email, password: password);
  }

  @override
  Future<void> signIn({required String email, required String password}) {
    return service.signIn(email: email, password: password);
  }
}
