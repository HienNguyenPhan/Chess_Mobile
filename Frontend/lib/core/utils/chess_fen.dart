List<String> boardFromFenLike(String fen) {
  final List<String> out = [];
  final parts = fen.split(' ');
  final rankParts = parts.first.split('/');
  for (final rank in rankParts) {
    for (final chh in rank.split('')) {
      if (RegExp(r'[1-8]').hasMatch(chh)) {
        final n = int.parse(chh);
        out.addAll(List.filled(n, ''));
      } else {
        final isWhite = chh.toUpperCase() == chh;
        final code = chh.toUpperCase();
        final piece = {'P': 'P', 'R': 'R', 'N': 'N', 'B': 'B', 'Q': 'Q', 'K': 'K'}[code] ?? 'P';
        out.add((isWhite ? 'w' : 'b') + piece);
      }
    }
  }
  if (out.length != 64) {
    // fallback: start position
    return boardFromFenLike('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');
  }
  return out;
}