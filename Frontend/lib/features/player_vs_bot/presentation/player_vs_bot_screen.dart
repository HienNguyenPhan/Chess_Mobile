import 'package:chess_app/core/routes/route_constants.dart';
import 'package:chess_app/features/settings/bloc/setting_bloc.dart';
import 'package:chess_app/features/settings/data/board_themes.dart';
import 'package:chess_app/gen/assets.gen.dart';
import 'package:chess_app/core/services/audio_service.dart';
import 'package:chess_app/features/player_vs_bot/presentation/widgets/captured_pieces_row.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chess_app/features/player_vs_bot/presentation/bloc/game_bloc.dart';
import 'package:chess_app/features/player_vs_bot/presentation/bloc/game_event.dart';
import 'package:chess_app/features/player_vs_bot/presentation/bloc/game_state.dart';
import 'package:chess_app/features/game_core/presentation/widgets/chess_board_widget.dart';
import 'package:chess_app/features/player_vs_bot/presentation/widgets/game_over_dialog.dart';
import 'package:go_router/go_router.dart';

class PlayerVsBotScreen extends StatefulWidget {

  const PlayerVsBotScreen({
    super.key,
  });

  @override
  State<PlayerVsBotScreen> createState() => _PlayerVsBotScreenState();
}

class _PlayerVsBotScreenState extends State<PlayerVsBotScreen> {
  @override
  void initState() {
    super.initState();
    GetIt.I<AudioService>().playBackgroundMusic();
  }

  @override
  void dispose() {
    GetIt.I<AudioService>().stopBackgroundMusic();
    context.read<PlayerVsBotBloc>().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C4DFF);

    return BlocListener<PlayerVsBotBloc, PlayerVsBotState>(
      listener: (context, state) {
        if (state.isGameOver) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => GameOverDialog(
              message: state.errorMessage ?? 'Ván cờ kết thúc',
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'CHESS',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Assets.svgs.chessLogo.svg(width: 30),
            ],
          ),
        ),
        body: BlocBuilder<SettingBloc, SettingState>(
          builder: (context, state) {
            final (light, dark) = BoardThemes.getColors(state.boardTheme);
            print(state.boardTheme);
            return SafeArea(
              child: Column(
                children: [
                  // 🧠 AI Row + Captured White Pieces
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: BlocBuilder<PlayerVsBotBloc, PlayerVsBotState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                const _AvatarWithLabel(label: 'AI'),
                                const Spacer(),
                                _TimerBadge(
                                  text: _formatTime(state.botSeconds),
                                  isThinking: state.isBotThinking,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Builder(
                              builder: (context) {
                                return CapturedPiecesRow(
                                  pieces: state.capturedWhitePieces,
                                  isWhitePieces: true,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ♟️ Chess Board
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: BlocBuilder<PlayerVsBotBloc, PlayerVsBotState>(
                        builder: (context, state) {
                          return Center(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: ChessBoardWidget(
                                board: state.board,
                                selectedIndex: state.selectedIndex,
                                legalTargets: state.legalTargets,
                                onSquareTap: (i) => context
                                    .read<PlayerVsBotBloc>()
                                    .add(SquareTapped(i)),
                                lightColor: light,
                                darkColor: dark,
                                targetColor: purple.withOpacity(0.45),
                                selectedColor: const Color(0xFFFFD54F),
                                pieceStyle: context
                                    .read<SettingBloc>()
                                    .state
                                    .pieceStyle, // ✅ lấy trực tiếp từ SettingBloc
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // 👤 Player Row + Actions
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BlocBuilder<PlayerVsBotBloc, PlayerVsBotState>(
                          builder: (context, state) {
                            return Column(
                              children: [
                                Builder(
                                  builder: (context) {
                                    return CapturedPiecesRow(
                                      pieces: state.capturedBlackPieces,
                                      isWhitePieces: false,
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const _AvatarWithLabel(label: 'Player'),
                                    const Spacer(),
                                    _TimerBadge(
                                      text: _formatTime(state.playerSeconds),
                                      isThinking:
                                          !state.isWhiteTurn &&
                                          !state
                                              .isBotThinking, // highlight when waiting
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _ActionIcon(
                              text: 'menu'.tr(),
                              icon: Icons.menu,
                              onTap: () => context.push(RouteConstants.setting),
                            ),
                            _ActionIcon(
                              text: 'Restart',
                              icon: Icons.refresh,
                              onTap: () async {
                                final shouldReset = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.8,
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Avatar Game
                                            CircleAvatar(
                                              radius: 36,
                                              backgroundColor: const Color(
                                                0xFF7C4DFF,
                                              ).withOpacity(0.15),
                                              child: const Icon(
                                                Icons.restart_alt,
                                                color: Color(0xFF7C4DFF),
                                                size: 36,
                                              ),
                                            ),
                                            const SizedBox(height: 16),

                                            // Title
                                            const Text(
                                              'Chơi lại ván mới?',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF3D2C8D),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),

                                            // Message
                                            Text(
                                              'Nước đi hiện tại sẽ bị xoá.\nBạn có chắc chắn muốn bắt đầu lại không?',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                                height: 1.4,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 24),

                                            // Buttons
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    style: OutlinedButton.styleFrom(
                                                      side: const BorderSide(
                                                        color: Color(
                                                          0xFF7C4DFF,
                                                        ),
                                                      ),
                                                      foregroundColor:
                                                          const Color(
                                                            0xFF7C4DFF,
                                                          ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Không',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                            0xFF7C4DFF,
                                                          ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Có',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );

                                if (shouldReset == true && context.mounted) {
                                  context.read<PlayerVsBotBloc>().add(
                                    NewGameRequested(),
                                  );
                                }
                              },
                            ),
                            _ActionIcon(
                              text: 'Resign',
                              icon: Icons.flag,
                              onTap: () async {
                                final confirmResign =
                                    await _showConfirmResignDialog(context);
                                if (confirmResign == true && context.mounted) {
                                  final acknowledged =
                                      await _showResignNoticeDialog(context);
                                  if (acknowledged == true && context.mounted) {
                                    context.read<PlayerVsBotBloc>().add(
                                      NewGameRequested(),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool?> _showConfirmResignDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: _ConfirmDialogContent(
            title: 'Xác nhận đầu hàng?',
            message:
                'Bạn có chắc chắn muốn đầu hàng không?\nĐối thủ sẽ được tính là thắng.',
            confirmText: 'Đồng ý',
            cancelText: 'Huỷ',
            icon: Icons.flag,
            iconColor: Colors.redAccent,
          ),
        );
      },
    );
  }

  Future<bool?> _showResignNoticeDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.redAccent.withOpacity(0.15),
                  child: const Icon(
                    Icons.flag,
                    color: Colors.redAccent,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bạn đã đầu hàng!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Đối thủ được tính là thắng.\nNhấn xác nhận để bắt đầu ván mới.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Xác nhận',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _TimerBadge extends StatelessWidget {
  final String text;
  final bool isThinking;
  const _TimerBadge({required this.text, this.isThinking = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF5E5E5E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (isThinking)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          if (isThinking) const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarWithLabel extends StatelessWidget {
  final String label;
  const _AvatarWithLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onTap; // 👈 thêm callback

  const _ActionIcon({required this.text, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkResponse(onTap: onTap, radius: 24, child: Icon(icon, size: 28)),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ConfirmDialogContent extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final IconData icon;
  final Color iconColor;

  const _ConfirmDialogContent({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: iconColor.withOpacity(0.15),
            child: Icon(icon, color: iconColor, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3D2C8D),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: iconColor),
                    foregroundColor: iconColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    cancelText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    confirmText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
