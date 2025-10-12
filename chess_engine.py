import chess
import random
from typing import Tuple, List
from eval import evaluate_position, material_values

# Zobrist hashing for transposition table
zobrist_keys = [[random.getrandbits(64) for _ in range(12)] for _ in range(64)]
transposition_table = {}  # {hash: {'eval': float, 'depth': int}}

def clear_transposition_table():
    """Clear the transposition table."""
    transposition_table.clear()

def zobrist_hash(board: chess.Board) -> int:
    h = 0
    for sq in chess.SQUARES:
        piece = board.piece_at(sq)
        if piece:
            piece_idx = piece.piece_type - 1 + (6 if piece.color == chess.BLACK else 0)
            h ^= zobrist_keys[sq][piece_idx]
    return h ^ (1 if board.turn == chess.BLACK else 0)

def generate_moves(board: chess.Board) -> List[chess.Move]:
    """Generate and sort moves for better pruning."""
    moves = list(board.legal_moves)
    print(f"Generated moves: {[str(m) for m in moves]}")  # Debug
    if not moves:
        print("No legal moves found")
        return []
    def move_priority(move):
        if board.is_capture(move):
            piece = board.piece_at(move.to_square)
            return material_values.get(piece.piece_type, 0) if piece else 0
        return -1
    moves.sort(key=move_priority, reverse=True)
    return moves

def quiescence(board: chess.Board, alpha: float, beta: float, max_depth: int = 3) -> float:
    """Quiescence search for captures."""
    if max_depth == 0:
        return evaluate_position(board)
    stand_pat = evaluate_position(board)
    if stand_pat >= beta:
        return beta
    alpha = max(alpha, stand_pat)
    for move in generate_moves(board):
        if not board.is_capture(move):
            continue
        board.push(move)
        eval_score = -quiescence(board, -beta, -alpha, max_depth - 1)
        board.pop()
        if eval_score >= beta:
            return beta
        alpha = max(alpha, eval_score)
    return alpha

def minimax(board: chess.Board, depth: int, alpha: float, beta: float, maximizing: bool) -> float:
    """Alpha-beta pruning search."""
    hash_key = zobrist_hash(board)
    if hash_key in transposition_table and transposition_table[hash_key]['depth'] >= depth:
        return transposition_table[hash_key]['eval']
    
    if depth == 0 or board.is_game_over():
        eval_score = quiescence(board, alpha, beta)
        transposition_table[hash_key] = {'eval': eval_score, 'depth': depth}
        return eval_score
    
    moves = generate_moves(board)
    if not moves:
        return evaluate_position(board)
    
    if maximizing:
        max_eval = -float('inf')
        for move in moves:
            board.push(move)
            eval_score = minimax(board, depth - 1, alpha, beta, False)
            board.pop()
            max_eval = max(max_eval, eval_score)
            alpha = max(alpha, eval_score)
            if beta <= alpha:
                break
        transposition_table[hash_key] = {'eval': max_eval, 'depth': depth}
        return max_eval
    else:
        min_eval = float('inf')
        for move in moves:
            board.push(move)
            eval_score = minimax(board, depth - 1, alpha, beta, True)
            board.pop()
            min_eval = min(min_eval, eval_score)
            beta = min(beta, eval_score)
            if beta <= alpha:
                break
        transposition_table[hash_key] = {'eval': min_eval, 'depth': depth}
        return min_eval

def get_best_move_and_eval(board: chess.Board, depth: int) -> Tuple[chess.Move, float]:
    """Find best move and evaluation."""
    print(f"Board FEN: {board.fen()}")  # Debug
    moves = generate_moves(board)
    if not moves:
        raise ValueError("No legal moves available")
    
    best_move = None
    best_eval = -float('inf') if board.turn == chess.WHITE else float('inf')
    for move in moves:
        board.push(move)
        eval_score = minimax(board, depth - 1, -float('inf'), float('inf'), board.turn != chess.WHITE)
        board.pop()
        print(f"Move: {move}, Eval: {eval_score}")  # Debug
        if board.turn == chess.WHITE:
            if eval_score > best_eval:
                best_eval = eval_score
                best_move = move
        else:
            if eval_score < best_eval:
                best_eval = eval_score
                best_move = move
    if best_move is None:
        raise ValueError("No legal moves available after evaluation")
    print(f"Selected move: {best_move}, Eval: {best_eval}")  # Debug
    return best_move, best_eval
