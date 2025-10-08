import chess
import chess.engine
from evaluate import Evaluate
import random

transposition_table = {}
zobrist_keys = [[random.getrandbits(64) for _ in range(12)] for _ in range(64)]

def zobrist_hash(board: chess.Board):
    h = 0
    for sq in range(64):
        piece = board.piece_at(sq)
        if piece:
            piece_idx = piece.piece_type - 1 + (6 if piece.color == chess.BLACK else 0)
            h ^= zobrist_keys[sq][piece_idx]
    return h ^ (1 if board.turn == chess.BLACK else 0)

def quiescence(board: chess.Board, alpha: float, beta: float, max_depth=3) -> float:
    stand_pat = Evaluate(board)
    if max_depth == 0:
        return stand_pat
    if stand_pat >= beta:
        return beta
    alpha = max(alpha, stand_pat)
    for move in generate_moves(board):
        if not board.is_capture(move):
            continue
        board.push(move)
        eval = -quiescence(board, -beta, -alpha, max_depth-1)
        board.pop()
        if eval >= beta:
            return beta
        alpha = max(alpha, eval)
    return alpha

def generate_moves(board: chess.Board):
    moves = list(board.legal_moves)
    moves.sort(key=lambda m: board.piece_at(m.to_square).piece_type if board.is_capture(m) else 0, reverse=True)
    return moves

def minimax(board: chess.Board, depth: int, alpha: float, beta: float, maximizing: bool):
    board_hash = zobrist_hash(board)
    if board_hash in transposition_table:
        return transposition_table[board_hash]['eval']
    if depth == 0 or board.is_game_over():
        return quiescence(board, alpha, beta)
    
    moves = generate_moves(board)

    if maximizing:
        max_eval = float("-inf")
        for move in moves:
            board.push(move)
            eval = minimax(board, depth-1, alpha, beta, False)
            board.pop()
            max_eval = max(max_eval, eval)
            alpha = max(alpha, eval)
            if beta <= alpha:
                break
        transposition_table[board_hash] = {'eval': max_eval, 'depth': depth}
        return max_eval
    else:
        min_eval = float("inf")
        for move in moves:
            board.push(move)
            eval = minimax(board, depth-1, alpha, beta, True)
            board.pop()
            min_eval = min(min_eval, eval)
            beta = min(beta, eval)
            if beta <= alpha:
                break
        transposition_table[board_hash] = {'eval': min_eval, 'depth': depth}
        return min_eval

def get_best_move_and_eval(board: chess.Board, depth: int):
    best_move = None
    best_eval = float("-inf") if board.turn == chess.WHITE else float("inf")

    for move in generate_moves(board):
        board.push(move)
        eval = minimax(board, depth-1, float("-inf"), float("inf"), not board.turn)
        board.pop()
        if (board.turn == chess.WHITE and eval > best_eval) or (board.turn == chess.BLACK and eval < best_eval):
            best_eval = eval
            best_move = move
    if best_move is None:
        raise ValueError("No legal moves available")

    return best_move, best_eval