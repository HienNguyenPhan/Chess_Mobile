import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';

class GameOverDialog extends StatelessWidget {
  final String message;

  const GameOverDialog({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ván cờ kết thúc'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Đóng dialog
          },
          child: const Text('Thoát'),
        ),
        FilledButton(
          onPressed: () {
            // Gửi event để bắt đầu ván mới
            context.read<PlayerVsBotBloc>().add(NewGameRequested());
            Navigator.of(context).pop(); // Đóng dialog
          },
          child: const Text('Chơi lại'),
        ),
      ],
    );
  }
}