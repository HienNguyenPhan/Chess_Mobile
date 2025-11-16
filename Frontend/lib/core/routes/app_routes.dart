import 'dart:async';

import 'package:chess_app/core/routes/route_constants.dart';
import 'package:chess_app/features/about/presentation/about_team_screen.dart';
import 'package:chess_app/features/auth/presentation/blocs/signin_bloc/signin_bloc.dart';
import 'package:chess_app/features/auth/presentation/blocs/signup_bloc/signup_bloc.dart';
import 'package:chess_app/features/auth/presentation/pages/signin_screen.dart';
import 'package:chess_app/features/forgot_password/presentation/bloc/forgot_password_bloc.dart';
import 'package:chess_app/features/forgot_password/presentation/forgot_pasword_screen.dart';
import 'package:chess_app/features/introduction/presentation/introduction_screen.dart';
import 'package:chess_app/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:chess_app/features/player_vs_bot/presentation/widgets/bot_game_setup_screen.dart';
import 'package:chess_app/features/player_vs_player/presentation/bloc/player_vs_player_bloc.dart';
import 'package:chess_app/features/player_vs_player/presentation/player_vs_player_screen.dart';
import 'package:chess_app/features/puzzle/presentation/bloc/puzzle_bloc.dart';
import 'package:chess_app/features/puzzle/presentation/bloc/puzzle_event.dart';
import 'package:chess_app/features/puzzle/presentation/screens/puzzle_screen.dart';
import 'package:chess_app/features/auth/presentation/pages/signup_screen.dart';
import 'package:chess_app/features/game_core/presentation/screens/game_mode_screen.dart';
import 'package:chess_app/features/profile/presentation/bloc/user_profile_bloc.dart';
import 'package:chess_app/features/profile/presentation/user_profile_screen.dart';
import 'package:chess_app/features/player_vs_bot/presentation/bloc/game_bloc.dart';
import 'package:chess_app/features/player_vs_bot/presentation/bloc/game_event.dart';
import 'package:chess_app/features/player_vs_bot/presentation/player_vs_bot_screen.dart';
import 'package:chess_app/features/settings/presentation/setting_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';

final sl = GetIt.instance;

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final router = GoRouter(
  debugLogDiagnostics: true,

  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),

  initialLocation: FirebaseAuth.instance.currentUser == null
      ? RouteConstants.intro
      : RouteConstants.home,

  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;

    final isAuthPage =
        state.matchedLocation == RouteConstants.signin ||
        state.matchedLocation == RouteConstants.signup ||
        state.matchedLocation == RouteConstants.intro ||
        state.matchedLocation == RouteConstants.forgotPassword;

    if (!isLoggedIn && !isAuthPage) return RouteConstants.intro;

    if (isLoggedIn && isAuthPage) return RouteConstants.home;

    return null;
  },

  routes: [
    GoRoute(
      path: RouteConstants.signin,
      name: RouteConstants.signin,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<SignInBloc>(),
        child: const SignInScreen(),
      ),
    ),
    GoRoute(
      path: RouteConstants.intro,
      name: RouteConstants.intro,
      builder: (context, state) => const IntroductionScreen(),
    ),
    GoRoute(
      path: RouteConstants.signup,
      name: RouteConstants.signup,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<SignUpBloc>(),
        child: const SignUpScreen(),
      ),
    ),
    GoRoute(
      path: RouteConstants.home,
      name: RouteConstants.home,
      builder: (context, state) => const GameModeScreen(),
    ),
    GoRoute(
      path: RouteConstants.botGameSetup,
      name: RouteConstants.botGameSetup,
      builder: (context, state) => const BotGameSetupScreen(),
    ),
    GoRoute(
      path: RouteConstants.singlePlayer,
      name: RouteConstants.singlePlayer,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => sl<PlayerVsBotBloc>()..add(NewGameRequested()),
          child: PlayerVsBotScreen(),
        );
      },
    ),
    GoRoute(
      path: RouteConstants.profile,
      name: RouteConstants.profile,
      builder: (context, state) => BlocProvider(
        create: (_) => UserProfileBloc()..add(LoadUserProfileEvent()),
        child: const UserProfileScreen(),
      ),
    ),
    GoRoute(
      path: RouteConstants.setting,
      name: RouteConstants.setting,
      builder: (context, state) => const SettingScreen(),
    ),
    GoRoute(
      path: RouteConstants.about,
      name: RouteConstants.about,
      builder: (context, state) => const AboutTeamScreen(),
    ),
    GoRoute(
      path: RouteConstants.puzzles,
      name: RouteConstants.puzzles,
      builder: (context, state) => BlocProvider(
        create: (context) => sl<PuzzleBloc>()..add(PuzzleStarted()),
        child: const PuzzleScreen(),
      ),
    ),
    GoRoute(
      path: RouteConstants.twoPlayer,
      name: RouteConstants.twoPlayer,
      builder: (context, state) => BlocProvider(
        create: (context) => sl<PlayerVsPlayerBloc>(),
        child: const PlayerVsPlayerScreen(),
      ),
    ),
    GoRoute(
      path: RouteConstants.forgotPassword,
      name: RouteConstants.forgotPassword,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<ForgotPasswordBloc>(),
        child: const ForgotPasswordScreen(),
      ),
    ),
    GoRoute(
      path: RouteConstants.leaderboard,
      builder: (context, state) => const LeaderboardScreen(),
    ),
  ],
);
