import 'package:chess_app/core/services/local_storage_service.dart';
import 'package:chess_app/core/repositories/local_repository.dart';

class LocalRepositoryImpl implements LocalRepository {
  @override
  Future<void> saveLoginInfo(String email) async {
    await LocalStorageService.setBool('isLoggedIn', true);
    await LocalStorageService.writeSecure('userEmail', email);
  }

  @override
  Future<void> clearLoginInfo() async {
    await LocalStorageService.clearAll();
  }

  @override
  Future<bool> isLoggedIn() async {
    return LocalStorageService.getBool('isLoggedIn');
  }

  @override
  Future<String?> getUserEmail() async {
    return await LocalStorageService.readSecure('userEmail');
  }
}
