import 'package:chess_app/features/game_core/presentation/widgets/chess_board_widget.dart';
import 'package:chess_app/features/player_vs_player/presentation/bloc/player_vs_player_bloc.dart';
import 'package:chess_app/features/player_vs_bot/presentation/widgets/game_over_dialog.dart';
import 'package:chess_app/features/settings/bloc/setting_bloc.dart';
import 'package:chess_app/features/settings/data/board_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerVsPlayerScreen extends StatelessWidget {
  const PlayerVsPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C4DFF);

    return BlocProvider(
      create: (_) => PlayerVsPlayerBloc()..add(ScreenOpened()),
      child: BlocListener<PlayerVsPlayerBloc, PlayerVsPlayerState>(
        listener: (context, state) {
          if (state.isGameOver) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => GameOverDialog(
                message: state.errorMessage ?? 'Trò chơi kết thúc!',
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(title: const Text('Player vs Player')),
          body: BlocBuilder<SettingBloc, SettingState>(
            builder: (context, settingState) {
              final (light, dark) =
                  BoardThemes.getColors(settingState.boardTheme);
              return SafeArea(
                child: Column(
                  children: [
                    _playerRow(
                      'Black',
                      context.watch<PlayerVsPlayerBloc>().state.blackSeconds,
                    ),
                    Expanded(
                      child:
                          BlocBuilder<PlayerVsPlayerBloc, PlayerVsPlayerState>(
                        builder: (context, state) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: ChessBoardWidget(
                                board: state.board,
                                selectedIndex: state.selectedIndex,
                                legalTargets: state.legalTargets,
                                onSquareTap: (i) => context
                                    .read<PlayerVsPlayerBloc>()
                                    .add(SquareTapped(i)),
                                lightColor: light,
                                darkColor: dark,
                                targetColor: purple.withOpacity(0.45),
                                selectedColor: const Color(0xFFFFD54F),
                                pieceStyle: settingState.pieceStyle,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    _playerRow(
                      'White',
                      context.watch<PlayerVsPlayerBloc>().state.whiteSeconds,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _playerRow(String name, int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const CircleAvatar(radius: 16, child: Icon(Icons.person)),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$m:$s',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
