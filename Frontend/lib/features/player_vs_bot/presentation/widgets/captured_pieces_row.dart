import 'package:flutter/material.dart';

class CapturedPiecesRow extends StatelessWidget {
  final List<String> pieces;
  final bool isWhitePieces;
  final double pieceSize;

  const CapturedPiecesRow({
    super.key,
    required this.pieces,
    required this.isWhitePieces,
    this.pieceSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (pieces.isEmpty) {
      return SizedBox(height: pieceSize);
    }

    return Container(
      height: pieceSize + 8,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isWhitePieces ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pieces.length,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final piece = pieces[index];
          // Piece là 'bP' hoặc 'wQ' -> chuyển thành 'p_black.png' hoặc 'q_white.png'
          final pieceType = piece[1].toLowerCase(); // p, r, n, b, q, k
          final color = piece[0] == 'w' ? 'white' : 'black';
          return Image.asset(
            'assets/images/${pieceType}_$color.png',
            width: pieceSize,
            height: pieceSize,
          );
        },
      ),
    );
  }
}