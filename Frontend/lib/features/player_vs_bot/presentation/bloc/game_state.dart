import 'package:equatable/equatable.dart';

const String kStartFEN =
    'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

class PlayerVsBotState extends Equatable {
  final String fen;
  final List<String> board;
  final bool isWhiteTurn;
  final bool isLoading;
  final bool isBotThinking;
  final int playerSeconds;
  final int botSeconds;
  final String sessionId;
  final int initialSeconds;

  final int? selectedIndex;
  final List<int> legalTargets;
  final int? pendingFrom;
  final int? pendingTo;

  final List<String> moveHistory;
  final String? errorMessage;
  final bool isGameOver;
  final String? gameResult;
  final String? gameWinner;
  final String? gameReason;
  final List<String> capturedWhitePieces; // Quân trắng bị ăn
  final List<String> capturedBlackPieces; // Quân đen bị ăn

  const PlayerVsBotState({
    required this.fen,
    required this.board,
    required this.isWhiteTurn,
    required this.isLoading,
    required this.isBotThinking,
    required this.playerSeconds,
    required this.botSeconds,
    required this.sessionId,
    required this.initialSeconds,
    this.isGameOver = false,
    this.gameResult,
    this.gameWinner,
    this.gameReason,
    required this.selectedIndex,
    required this.legalTargets,
    required this.pendingFrom,
    required this.pendingTo,
    required this.moveHistory,
    this.errorMessage,
    this.capturedWhitePieces = const [],
    this.capturedBlackPieces = const [],
  });

  factory PlayerVsBotState.initial({int initialSeconds = 300}) =>
      PlayerVsBotState(
        fen: kStartFEN,
        board: _boardFromFenLike(kStartFEN),
        isWhiteTurn: true,
        isLoading: false,
        isBotThinking: false,
        playerSeconds: 300, // Start with 5 minutes
        botSeconds: 300, // Start with 5 minutes
        sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
        initialSeconds: initialSeconds,
        selectedIndex: null,
        legalTargets: const [],
        pendingFrom: null,
        pendingTo: null,
        moveHistory: const [],
      );

  PlayerVsBotState copyWith({
    String? fen,
    List<String>? board,
    bool? isWhiteTurn,
    bool? isLoading,
    bool? isBotThinking,
    int? playerSeconds,
    int? botSeconds,
    int? initialSeconds,
    int? selectedIndex,
    bool clearSelectedIndex = false,

    List<int>? legalTargets,

    int? pendingFrom,
    int? pendingTo,
    bool clearPending = false,

    List<String>? moveHistory,

    String? errorMessage,
    bool clearError = false,
    bool? isGameOver,
    String? gameResult,
    String? gameWinner,
    String? gameReason,
    List<String>? capturedWhitePieces,
    List<String>? capturedBlackPieces,
  }) {
    return PlayerVsBotState(
      fen: fen ?? this.fen,
      board: board ?? this.board,
      isWhiteTurn: isWhiteTurn ?? this.isWhiteTurn,
      isLoading: isLoading ?? this.isLoading,
      isBotThinking: isBotThinking ?? this.isBotThinking,
      playerSeconds: playerSeconds ?? this.playerSeconds,
      botSeconds: botSeconds ?? this.botSeconds,
      sessionId: sessionId,
      initialSeconds: initialSeconds ?? this.initialSeconds,

      selectedIndex: clearSelectedIndex
          ? null
          : (selectedIndex ?? this.selectedIndex),

      legalTargets: legalTargets ?? this.legalTargets,

      pendingFrom: clearPending ? null : (pendingFrom ?? this.pendingFrom),
      pendingTo: clearPending ? null : (pendingTo ?? this.pendingTo),

      moveHistory: moveHistory ?? this.moveHistory,

      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isGameOver: isGameOver ?? this.isGameOver,
      gameResult: gameResult ?? this.gameResult,
      gameWinner: gameWinner ?? this.gameWinner,
      gameReason: gameReason ?? this.gameReason,
      capturedWhitePieces: capturedWhitePieces ?? this.capturedWhitePieces,
      capturedBlackPieces: capturedBlackPieces ?? this.capturedBlackPieces,
    );
  }

  @override
  List<Object?> get props => [
    fen,
    board,
    isWhiteTurn,
    isLoading,
    isBotThinking,
    playerSeconds,
    botSeconds,
    initialSeconds,
    selectedIndex,
    legalTargets,
    pendingFrom,
    pendingTo,
    moveHistory,
    errorMessage,
  ];
}

// hàm parse fen để render bàn cờ
List<String> _boardFromFenLike(String fen) {
  final List<String> out = [];
  final ranks = fen.split(' ').first.split('/');
  for (final rank in ranks) {
    for (final ch in rank.split('')) {
      if (RegExp(r'[1-8]').hasMatch(ch)) {
        final n = int.parse(ch);
        out.addAll(List.filled(n, ''));
      } else {
        final isWhite = ch.toUpperCase() == ch;
        final code = ch.toUpperCase();
        final piece = {
          'P': 'P',
          'R': 'R',
          'N': 'N',
          'B': 'B',
          'Q': 'Q',
          'K': 'K',
        }[code]!;
        out.add((isWhite ? 'w' : 'b') + piece);
      }
    }
  }
  if (out.length != 64) {
    return _boardFromFenLike(kStartFEN);
  }
  return out;
}
