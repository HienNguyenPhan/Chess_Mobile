import 'package:chess_app/features/game_core/presentation/widgets/chess_board_widget.dart';
import 'package:chess_app/features/settings/bloc/setting_bloc.dart';
import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;
import 'package:flutter_bloc/flutter_bloc.dart';

class GameDetailScreen extends StatefulWidget {
  final int gameId;
  const GameDetailScreen({super.key, required this.gameId});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  late chess.Chess _chess;
  int _currentMoveIndex = 0;

  // Mock danh sách nước đi (đơn giản)
  final List<String> _moves = [
    'e4',
    'e5',
    'Nf3',
    'Nc6',
    'Bb5',
    'a6',
    'Ba4',
    'Nf6',
  ];

  @override
  void initState() {
    super.initState();
    _chess = chess.Chess();
  }

  List<String> _generateBoardState() {
    final board = List<String>.filled(64, '');
    final boardData = _chess.board;

    for (var index = 0; index < 64; index++) {
      final piece = boardData[index];
      if (piece != null) {
        final color = piece.color == chess.Color.WHITE ? 'w' : 'b';
        final type = piece.type.toUpperCase();
        board[index] = '$color$type';
      }
    }

    return board;
  }

  void _goNext() {
    if (_currentMoveIndex < _moves.length) {
      setState(() {
        _chess.move(_moves[_currentMoveIndex]);
        _currentMoveIndex++;
      });
    }
  }

  void _goPrev() {
    if (_currentMoveIndex > 0) {
      setState(() {
        _chess = chess.Chess();
        for (int i = 0; i < _currentMoveIndex - 1; i++) {
          _chess.move(_moves[i]);
        }
        _currentMoveIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final boardState = _generateBoardState();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi tiết trận ${widget.gameId}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ChessBoardWidget(
                  board: boardState,
                  selectedIndex: null,
                  legalTargets: const [],
                  onSquareTap: (_) {},
                  selectedColor: const Color(0xFFFFD54F),
                  pieceStyle: context.read<SettingBloc>().state.pieceStyle,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 📝 Thông tin nước đi hiện tại
            Text(
              _currentMoveIndex == 0
                  ? "Trạng thái ban đầu"
                  : "Nước ${_currentMoveIndex}: ${_moves[_currentMoveIndex - 1]}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            // 🎮 Nút điều khiển
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _goPrev,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Prev'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black,
                  ),
                ),
                Text(
                  '${_currentMoveIndex}/${_moves.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _goNext,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
