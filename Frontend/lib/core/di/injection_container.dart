import 'package:chess_app/core/data/local_repository_impl.dart';
import 'package:chess_app/core/repositories/local_repository.dart';
import 'package:chess_app/features/auth/data/firebase_auth_repository_impl.dart';
import 'package:chess_app/features/auth/data/firebase_auth_service.dart';
import 'package:chess_app/features/auth/domain/auth_repository.dart';
import 'package:chess_app/features/auth/domain/auth_usecase.dart';
import 'package:chess_app/features/auth/presentation/blocs/signin_bloc/signin_bloc.dart';
import 'package:chess_app/features/forgot_password/domain/forgot_password_usecase.dart';
import 'package:chess_app/features/forgot_password/presentation/bloc/forgot_password_bloc.dart';
import 'package:chess_app/features/player_vs_bot/data/services/chess_move_service.dart';
import 'package:chess_app/features/player_vs_bot/domain/chess_repository.dart';
import 'package:chess_app/core/services/audio_service.dart';
import 'package:chess_app/core/services/auth_service.dart';
import 'package:chess_app/features/player_vs_bot/presentation/bloc/game_bloc.dart';
import 'package:chess_app/features/puzzle/domain/puzzle_repository.dart';
import 'package:chess_app/features/puzzle/presentation/bloc/puzzle_bloc.dart';
import 'package:chess_app/features/settings/bloc/setting_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/presentation/blocs/signup_bloc/signup_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Firebase
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Dio (cho toàn app)
  sl.registerLazySingleton<Dio>(() => Dio(
        BaseOptions(
          baseUrl: 'https://chess-mobile.onrender.com',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      ));

  // Initialize SharedPreferences
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPrefs);

  // Data source
  sl.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService(sl(), sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => FirebaseAuthRepositoryImpl(sl()));
  sl.registerLazySingleton<LocalRepository>(() => LocalRepositoryImpl());
  sl.registerLazySingleton<ChessRepository>(() => ChessRepository(sl()));
  sl.registerLazySingleton<PuzzleRepository>(() => PuzzleRepository());
  
  // Bloc
  sl.registerLazySingleton(() {
    final bloc = SettingBloc();
    bloc.add(LoadSettingsEvent());
    return bloc;
  });

  // Services
  sl.registerLazySingleton<AudioService>(() => AudioService());
  sl.registerLazySingleton<ChessMoveService>(() => ChessMoveService(sl<Dio>()));
  
  // Register AuthService with async initialization
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<AuthService>(() => AuthService(prefs));

  // UseCases
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));

  // Bloc
  sl.registerFactory(() => SignUpBloc(sl()));
  sl.registerFactory(() => SignInBloc(sl(), sl()));
  sl.registerFactory(() => PlayerVsBotBloc(sl<ChessRepository>()));
  sl.registerFactory(() => ForgotPasswordBloc(forgotPasswordUseCase: sl()));
  sl.registerFactory(() => PuzzleBloc(sl<PuzzleRepository>()));
}
