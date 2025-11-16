import 'package:chess_app/core/services/local_storage_service.dart';
import 'package:chess_app/features/auth/data/firebase_auth_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/di/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalStorageService.init();

  // ✅ Chỉ gọi một lần duy nhất
  await di.initDependencies();

  // Kiểm tra token để đồng bộ trạng thái đăng nhập
  final firebaseUser = FirebaseAuth.instance.currentUser;
  final token = await LocalStorageService.readSecure('token');
  final isLoggedIn = firebaseUser != null && token != null && token.isNotEmpty;

  await GetIt.I<FirebaseAuthService>().setLoggedIn(isLoggedIn);

  // Lắng nghe thay đổi auth, xóa token khi đăng xuất
  FirebaseAuth.instance.authStateChanges().listen((user) async {
    final token = await LocalStorageService.readSecure('token');
    if (user == null || token == null || token.isEmpty) {
      await LocalStorageService.deleteSecure('token');
    }
  });

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('vi'),
      child: ChessApp(isLoggedIn: isLoggedIn),
    ),
  );
}