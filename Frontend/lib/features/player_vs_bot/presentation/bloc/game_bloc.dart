import 'dart:async';
import 'package:chess_app/core/services/audio_service.dart';
import 'package:chess_app/core/utils/chess_fen.dart';
import 'package:chess_app/features/player_vs_bot/data/models/chess_move_request.dart';
import 'package:chess_app/features/player_vs_bot/domain/chess_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chess/chess.dart' as ch;
import 'game_event.dart';
import 'game_state.dart';

class PlayerVsBotBloc extends Bloc<PlayerVsBotEvent, PlayerVsBotState> {
  final ChessRepository _repo;
  Timer? _playerTimer;
  Timer? _botTimer;
  static const int initialTimeInSeconds = 300;

  PlayerVsBotBloc(
    this._repo, {
    int initialSeconds = 300,
  }) : super(PlayerVsBotState.initial(initialSeconds: initialSeconds)) {
    on<ScreenOpened>(_onScreenOpened);
    on<NewGameRequested>(_onNewGame);
    on<SquareTapped>(_onSquareTapped);
    on<SubmitPlayerMove>(_onSubmitPlayerMove);
    on<BotMoveArrived>(_onBotMoveArrived);
    on<ErrorOccurred>(_onError);
    on<UpdatePlayerTime>(_onUpdatePlayerTime);
    on<UpdateBotTime>(_onUpdateBotTime);
  }

  void _onUpdatePlayerTime(
    UpdatePlayerTime event,
    Emitter<PlayerVsBotState> emit,
  ) {
    final newSeconds = state.playerSeconds - 1;
    if (newSeconds <= 0) {
      _stopTimers();
      emit(
        state.copyWith(
          playerSeconds: 0,
          errorMessage: 'Game Over! Player ran out of time',
        ),
      );
      return;
    }
    emit(state.copyWith(playerSeconds: newSeconds));
  }

  void _onUpdateBotTime(UpdateBotTime event, Emitter<PlayerVsBotState> emit) {
    final newSeconds = state.botSeconds - 1;
    if (newSeconds <= 0) {
      _stopTimers();
      emit(
        state.copyWith(botSeconds: 0, errorMessage: 'Bot đã hết thời gian!'),
      );
      return;
    }
    emit(state.copyWith(botSeconds: newSeconds));
  }

  @override
  Future<void> close() async {
    _stopTimers();
    super.close();
  }

  void _startPlayerTimer() {
    _playerTimer?.cancel(); // hủy cái cũ
    _botTimer?.cancel(); // đảm bảo chỉ 1 timer sống cùng lúc
    _playerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isClosed) {
        final s = state;
        if (!s.isWhiteTurn || s.isBotThinking) return;
        add(UpdatePlayerTime(s.playerSeconds + 1));
      }
    });
  }

  void _startBotTimer() {
    _playerTimer?.cancel(); // đảm bảo chỉ 1 timer tồn tại
    _botTimer?.cancel();

    if (state.isBotThinking) {
      _botTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!isClosed && state.isBotThinking) {
          add(UpdateBotTime(state.botSeconds));
        } else {
          timer.cancel();
        }
      });
    }
  }

  void _stopTimers() {
    _playerTimer?.cancel();
    _botTimer?.cancel();
  }

  void _onScreenOpened(ScreenOpened event, Emitter<PlayerVsBotState> emit) {
    emit(PlayerVsBotState.initial(initialSeconds: state.initialSeconds));
    _startPlayerTimer();
  }

  void _onNewGame(NewGameRequested event, Emitter<PlayerVsBotState> emit) {
    _stopTimers();
    emit(PlayerVsBotState.initial(initialSeconds: state.initialSeconds));
    _startPlayerTimer();
  }

  void _onSquareTapped(SquareTapped event, Emitter<PlayerVsBotState> emit) {
    final idx = event.index;
    final s = state;

    if (s.isBotThinking) return;

    if (s.selectedIndex == null) {
      final piece = s.board[idx];
      if (piece.isEmpty) return;
      final isWhitePiece = piece.startsWith('w');
      if (isWhitePiece != s.isWhiteTurn) return;

      final legalTargets = _legalTargetsFromFen(s.fen, idx);
      emit(
        s.copyWith(
          selectedIndex: idx,
          legalTargets: legalTargets,
          pendingFrom: idx,
          pendingTo: null,
          clearError: true,
        ),
      );
      return;
    }

    if (s.selectedIndex == idx) {
      emit(
        s.copyWith(
          clearSelectedIndex: true,
          clearPending: true,
          legalTargets: const [],
          clearError: true,
        ),
      );
      return;
    }

    if (s.legalTargets.contains(idx)) {
      emit(
        s.copyWith(
          pendingFrom: s.pendingFrom,
          pendingTo: idx,
          clearError: true,
        ),
      );
      add(SubmitPlayerMove());
      return;
    }

    emit(
      s.copyWith(
        clearSelectedIndex: true,
        clearPending: true,
        legalTargets: const [],
        clearError: true,
      ),
    );
  }

  void _onSubmitPlayerMove(
    SubmitPlayerMove event,
    Emitter<PlayerVsBotState> emit,
  ) async {
    PlayerVsBotState s = state; // Make s mutable
    final from = s.pendingFrom;
    final to = s.pendingTo;
    if (from == null || to == null) return;

    final fromSq = _toAlgebraic(from);
    final toSq = _toAlgebraic(to);
    final moveUci = '$fromSq$toSq';

    // Check if it's a capture move
    final isCapture = s.board[to].isNotEmpty;
    final capturedPiece = isCapture ? s.board[to] : null;

    // First update the UI with player's move
    final game = ch.Chess.fromFEN(s.fen);
    game.move({'from': fromSq, 'to': toSq});
    final newFen = game.fen;
    final newBoard = boardFromFenLike(newFen);

    // Update state with captured piece if any
    if (isCapture) {
      await GetIt.I<AudioService>().playCaptureSound();
      if (capturedPiece!.startsWith('b')) {
        s = s.copyWith(
          capturedBlackPieces: [...s.capturedBlackPieces, capturedPiece],
        );
      }
    } else {
      await GetIt.I<AudioService>().playMoveSound();
    }

    // Emit state with all updates
    emit(
      s.copyWith(
        fen: newFen,
        board: newBoard,
        isWhiteTurn: false,
        isLoading: true,
        isBotThinking: true,
        clearSelectedIndex: true,
        legalTargets: const [],
        clearPending: true,
        moveHistory: [...s.moveHistory, '$fromSq→$toSq'],
      ),
    );

    _startBotTimer();

    try {
      // Send player's move and get response with bot's move included
      final response = await _repo.fetchBotMove(
        ChessMoveRequest(
          moveUci: moveUci,
          sessionId: s.sessionId,
          autoBotResponse: true,
          botTimeLimit: 5,
        ),
      );

      // Update the board with new state
      final newBoard = boardFromFenLike(response.fen);

      // Process bot's move
      String? botMoveNotation;
      List<String> capturedPieces = [...s.capturedWhitePieces];

      if (response.botMove != null) {
        final fromSq = response.botMove!.substring(0, 2);
        final toSq = response.botMove!.substring(2, 4);
        botMoveNotation = '$fromSq→$toSq';

        // Check for capture by comparing boards
        final toIdx = _fromAlgebraic(toSq);
        if (toIdx != null) {
          final pieceAtTarget = s.board[toIdx];
          if (pieceAtTarget.startsWith('w')) {
            // Bot captured a white piece
            capturedPieces = [pieceAtTarget];
            await GetIt.I<AudioService>().playCaptureSound();
          }
        }
      }

      // Create move history
      final moveHistory = [...s.moveHistory, '$fromSq→$toSq'];
      if (botMoveNotation != null) {
        moveHistory.add('[BOT] $botMoveNotation');
      }

      // Emit final state with all updates
      emit(
        s.copyWith(
          fen: response.fen,
          board: newBoard,
          isWhiteTurn: true,
          isLoading: false,
          isBotThinking: false,
          clearSelectedIndex: true,
          legalTargets: const [],
          moveHistory: moveHistory,
          capturedBlackPieces: s.capturedBlackPieces, // Preserve black pieces
          capturedWhitePieces: capturedPieces, // Update with new captured piece
        ),
      );

      // Check if game is over
      if (response.gameStatus.gameOver) {
        _stopTimers();

        // Prepare the game over message
        String message;
        if (response.gameStatus.winner == 'white') {
          message = 'Chúc mừng! Bạn đã thắng';
        } else if (response.gameStatus.winner == 'black') {
          message = 'Bot đã thắng';
        } else {
          message = 'Hòa cờ';
        }

        emit(
          s.copyWith(
            isGameOver: true,
            gameResult: response.gameStatus.result,
            gameWinner: response.gameStatus.winner,
            gameReason: response.gameStatus.reason,
            errorMessage:
                '$message\nLý do: ${response.gameStatus.reason ?? ''}',
          ),
        );
        return;
      }

      // Start player timer for next move
      _startPlayerTimer();
    } catch (e) {
      print('Error: $e');
      add(ErrorOccurred(e.toString()));
    }
  }

  Future<void> _onBotMoveArrived(
    BotMoveArrived event,
    Emitter<PlayerVsBotState> emit,
  ) async {
    // This event handler is now obsolete since we handle bot moves directly in _onSubmitPlayerMove
    // Just log for debugging purposes
    print(
      '_onBotMoveArrived called but ignored - bot moves are handled in _onSubmitPlayerMove',
    );
  }

  void _onError(ErrorOccurred event, Emitter<PlayerVsBotState> emit) {
    _stopTimers();
    final s = state;

    // Nếu là lỗi từ server khi đi nước ăn quân
    if (event.message.contains('Could not apply move')) {
      // Cho phép người chơi tiếp tục đi
      emit(
        s.copyWith(
          isLoading: false,
          isBotThinking: false,
          isWhiteTurn: true,
          errorMessage: 'Nước đi không hợp lệ, vui lòng thử lại',
          clearSelectedIndex: true,
          legalTargets: const [],
        ),
      );
      _startPlayerTimer();
    } else {
      // Xử lý các lỗi khác
      emit(
        s.copyWith(
          isLoading: false,
          isBotThinking: false,
          errorMessage: event.message,
        ),
      );
    }
  }
}

List<int> _legalTargetsFromFen(String fen, int fromIndex) {
  final game = ch.Chess.fromFEN(fen);
  final fromSq = _toAlgebraic(fromIndex);
  final moves = game.generate_moves({'square': fromSq});
  return moves.map((m) => _fromAlgebraic(m.toAlgebraic)!).toList();
}

String _toAlgebraic(int index) {
  final file = 'abcdefgh'[index % 8];
  final rank = 8 - (index ~/ 8);
  return '$file$rank';
}

int? _fromAlgebraic(String sq) {
  if (sq.length != 2) return null;
  final file = sq[0];
  final rank = int.tryParse(sq[1]);
  if (rank == null) return null;
  final fileIdx = 'abcdefgh'.indexOf(file);
  if (fileIdx < 0) return null;
  final row = 8 - rank;
  final col = fileIdx;
  return row * 8 + col;
}
