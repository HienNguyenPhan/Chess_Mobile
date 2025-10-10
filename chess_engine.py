import chess
import torch
import random
from typing import Tuple, List
from nnue import NNUE, get_feature_indices

# Zobrist hashing for transposition table
zobrist_keys = [[random.getrandbits(64) for _ in range(12)] for _ in range(64)]
transposition_table = {}  # {hash: {'eval': float, 'depth': int}}

def zobrist_hash(board: chess.Board) -> int:
    h = 0
    for sq in chess.SQUARES:
        piece = board.piece_at(sq)
        if piece:
            piece_idx = piece.piece_type - 1 + (6 if piece.color == chess.BLACK else 0)
            h ^= zobrist_keys[sq][piece_idx]
    return h ^ (1 if board.turn == chess.BLACK else 0)

# Load quantized model
device = torch.device("cpu")  # CUDA for training, CPU for inference
model = NNUE(input_dim=22528, ft_dim=2048, hidden=32, buckets=8)
try:
    state_dict = torch.load("chess_nnue_quantized.pt", map_location=device)
    model.load_state_dict(state_dict)
except FileNotFoundError:
    raise Exception("Model file chess_nnue_quantized.pt not found.")
model.eval()

def evaluate_position(board: chess.Board) -> float:
    """Evaluate position using NNUE."""
    if board.is_checkmate():
        return -32000.0 if board.turn == chess.WHITE else 32000.0
    if board.is_stalemate() or board.is_insufficient_material():
        return 0.0
    
    white_indices = get_feature_indices(board, chess.WHITE)
    black_indices = get_feature_indices(board, chess.BLACK)
    features_white = torch.zeros(22528, device=device, dtype=torch.float32)
    features_black = torch.zeros(22528, device=device, dtype=torch.float32)
    for idx in white_indices:
        features_white[idx] = 1.0
    for idx in black_indices:
        features_black[idx] = 1.0
    
    stm = torch.tensor([1.0 if board.turn == chess.WHITE else 0.0], device=device)
    piece_count = sum(1 for _ in board.piece_map())
    piece_counts = torch.tensor([piece_count], device=device, dtype=torch.int64)
    
    with torch.no_grad():
        eval_normalized = model(
            features_white.unsqueeze(0),
            features_black.unsqueeze(0),
            stm,
            piece_counts
        ).item()
    return eval_normalized * 600  # Denormalize to centipawns

def generate_moves(board: chess.Board) -> List[chess.Move]:
    """Generate and sort moves for better pruning."""
    moves = list(board.legal_moves)
    moves.sort(key=lambda m: board.piece_at(m.to_square).piece_type if board.is_capture(m) else 0, reverse=True)
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
    best_move = None
    best_eval = -float('inf') if board.turn == chess.WHITE else float('inf')
    for move in generate_moves(board):
        board.push(move)
        eval_score = minimax(board, depth - 1, -float('inf'), float('inf'), board.turn != chess.WHITE)
        board.pop()
        if (board.turn == chess.WHITE and eval_score > best_eval) or (board.turn != chess.WHITE and eval_score < best_eval):
            best_eval = eval_score
            best_move = move
    if best_move is None:
        raise ValueError("No legal moves available")
    return best_move, best_eval
