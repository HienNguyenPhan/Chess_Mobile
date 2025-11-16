abstract class LocalRepository {
  Future<void> saveLoginInfo(String email);
  Future<void> clearLoginInfo();
  Future<bool> isLoggedIn();
  Future<String?> getUserEmail();
}
