import 'package:dio/dio.dart';
import 'package:chess_app/features/player_vs_bot/data/models/chess_move_request.dart';
import 'package:chess_app/features/player_vs_bot/data/models/chess_move_response.dart';

class ChessMoveService {
  final Dio _dio;
  ChessMoveService(this._dio);

  Future<ChessMoveResponse> getBotMove(ChessMoveRequest request) async {
    try {
      print('Requesting bot move with data: ${request.toJson()}');
      final response = await _dio.post('/move', data: request.toJson());
      
      // Log chi tiết response
      print('Raw response: ${response.data}');
      
      if (response.data == null) {
        throw Exception('Empty response from server');
      }

      final moveResponse = ChessMoveResponse.fromJson(response.data);
      
      // Kiểm tra dữ liệu response
      print('Processed response:');
      print('- FEN: ${moveResponse.fen}');
      print('- Bot move: ${moveResponse.botMove}');
      print('- Game status: ${moveResponse.gameStatus.toJson()}');
      print('- Session ID: ${moveResponse.sessionId}');

      if (moveResponse.fen.isEmpty) {
        throw Exception('Invalid FEN in response');
      }

      return moveResponse;
    } on DioException catch (e) {
      print('API error details: ${e.response?.data}');
      if (e.response?.data is Map && e.response?.data['detail'] != null) {
        throw Exception(e.response?.data['detail']);
      }
      throw Exception('API error: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('Parsing error: $e');
      throw Exception('Failed to process response: $e');
    }
  }
}
