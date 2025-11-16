import 'package:chess_app/features/puzzle/data/models/puzzle_request.dart';
import 'package:chess_app/features/puzzle/data/models/puzzle_response.dart';
import 'package:dio/dio.dart';

class PuzzleRepository {
  static const String baseUrl = 'https://chess-mobile.onrender.com';
  final Dio _dio;

  PuzzleRepository() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
    responseType: ResponseType.json,
  ));

  Future<PuzzleResponse> fetchNewPuzzle(PuzzleRequest request) async {
    try {
      final response = await _dio.post(
        '/puzzle/new',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        print('Puzzle fetched successfully: ${response.data}');
        return PuzzleResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load puzzle: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Error fetching puzzle: ${e.message}');
    }
  }
}