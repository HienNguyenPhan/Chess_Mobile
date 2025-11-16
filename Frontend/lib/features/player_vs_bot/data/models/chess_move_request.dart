class ChessMoveRequest {
  final String moveUci;
  final String sessionId;
  final bool autoBotResponse;
  final int botTimeLimit;

  ChessMoveRequest({
    required this.moveUci,
    this.sessionId = 'default',
    this.autoBotResponse = true,
    this.botTimeLimit = 5,
  });

  Map<String, dynamic> toJson() {
    return {
      'move_uci': moveUci,
      'session_id': sessionId,
      'auto_bot_response': autoBotResponse,
      'bot_time_limit': botTimeLimit,
    };
  }

  factory ChessMoveRequest.fromJson(Map<String, dynamic> json) {
    return ChessMoveRequest(
      moveUci: json['move_uci'] ?? '',
      sessionId: json['session_id'] ?? 'default',
      autoBotResponse: json['auto_bot_response'] ?? true,
      botTimeLimit: json['bot_time_limit'] ?? 5,
    );
  }
}
