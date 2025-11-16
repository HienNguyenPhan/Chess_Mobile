import 'package:flutter/material.dart';

class ChessBoardWidget extends StatelessWidget {
  final List<String> board; // 64 items, '' for empty, else like 'wP', 'bK'
  final int? selectedIndex;
  final List<int> legalTargets; // indices to highlight
  final void Function(int index) onSquareTap;
  final Color lightColor;
  final Color darkColor;
  final Color targetColor;
  final Color selectedColor;
  final String pieceStyle;

  const ChessBoardWidget({
    super.key,
    required this.board,
    required this.selectedIndex,
    required this.legalTargets,
    required this.onSquareTap,
    this.lightColor = const Color(0xFFEEEED2),
    this.darkColor = const Color(0xFF769656),
    this.targetColor = const Color(0x8057BCFF),
    this.selectedColor = const Color(0xE6FFC107),
    required this.pieceStyle,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemCount: 64,
        itemBuilder: (context, index) {
          final row = index ~/ 8;
          final col = index % 8;
          final isDark = (row + col).isOdd;
          final isSelected = selectedIndex == index;
          final isTarget = legalTargets.contains(index);

          return InkWell(
            onTap: () => onSquareTap(index),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? selectedColor
                    : isTarget
                    ? targetColor
                    : (isDark ? darkColor : lightColor),
                border: Border.all(color: Colors.black12, width: 0.5),
              ),
              child: _PieceGlyph(code: board[index], pieceStyle: pieceStyle),
            ),
          );
        },
      ),
    );
  }
}

class _PieceGlyph extends StatelessWidget {
  final String code;
  final String pieceStyle;
  const _PieceGlyph({required this.code, required this.pieceStyle});

  @override
  Widget build(BuildContext context) {
    if (code.isEmpty) return const SizedBox.shrink();

    final isWhite = code.startsWith('w');
    final kind = code.substring(1);

    // Map loại quân cờ sang tên file ảnh
    final pieceName = switch (kind) {
      'K' => 'King',
      'Q' => 'Queen',
      'R' => 'Rook',
      'B' => 'Bishop',
      'N' => 'Knight',
      _ => 'Pawn',
    };

    final side = isWhite ? 'w' : 'b';
    final assetPath = 'assets/images/$pieceStyle/$side$pieceName.png';
    return Center(
      child: Image.asset(
        assetPath,
        width: 40,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }
}
