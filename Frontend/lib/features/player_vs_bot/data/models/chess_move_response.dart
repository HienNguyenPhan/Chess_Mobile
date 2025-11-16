class GameStatus {
  final bool gameOver;
  final String? result;
  final String? reason;
  final String? winner;
  final bool inCheck;

  GameStatus({
    required this.gameOver,
    this.result,
    this.reason,
    this.winner,
    required this.inCheck,
  });

  factory GameStatus.fromJson(Map<String, dynamic> json) {
    return GameStatus(
      gameOver: json['game_over'] ?? false,
      result: json['result'],
      reason: json['reason'],
      winner: json['winner'],
      inCheck: json['in_check'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'game_over': gameOver,
      'result': result,
      'reason': reason,
      'winner': winner,
      'in_check': inCheck,
    };
  }
}

class ChessMoveResponse {
  final String fen;
  final GameStatus gameStatus;
  final String sessionId;
  final String? botMove;
  final double botEvaluation;
  final bool botFromBook;

  ChessMoveResponse({
    required this.fen,
    required this.gameStatus,
    required this.sessionId,
    this.botMove,
    required this.botEvaluation,
    required this.botFromBook,
  });

  factory ChessMoveResponse.fromJson(Map<String, dynamic> json) {
    return ChessMoveResponse(
      fen: json['fen'] ?? '',
      gameStatus: GameStatus.fromJson(json['game_status'] ?? {}),
      sessionId: json['session_id'] ?? '',
      botMove: json['bot_move'],
      botEvaluation: (json['bot_evaluation'] ?? 0.0).toDouble(),
      botFromBook: json['bot_from_book'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fen': fen,
      'game_status': gameStatus.toJson(),
      'session_id': sessionId,
      'bot_move': botMove,
      'bot_evaluation': botEvaluation,
      'bot_from_book': botFromBook,
    };
  }
}
