import 'package:chess_app/features/player_vs_bot/data/models/chess_move_request.dart';
import 'package:chess_app/features/player_vs_bot/data/models/chess_move_response.dart';
import 'package:chess_app/features/player_vs_bot/data/services/chess_move_service.dart';

class ChessRepository {
  final ChessMoveService _apiService;

  ChessRepository(this._apiService);

  Future<ChessMoveResponse> fetchBotMove(ChessMoveRequest req) {
    return _apiService.getBotMove(req);
  }
}
