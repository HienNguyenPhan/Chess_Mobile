# search.py
import math
import chess
import time
import random
from typing import Tuple, Optional, Dict, List
from utils import evaluate_position, MATERIAL  # your eval module

# -------------------------
# Config / globals
# -------------------------
RNG = random.Random(1234567)
zobrist_keys = [[RNG.getrandbits(64) for _ in range(12)] for _ in range(64)]
ZOBRIST_BLACK_TO_MOVE = RNG.getrandbits(64)

INF = 1e9
MATE_SCORE = 32000

# diagnostics
nodes_searched = 0
tt_hits = 0

# -------------------------
# Zobrist (simple per-node hashing)
# -------------------------
def zobrist_hash(board: chess.Board) -> int:
    h = 0
    for sq in chess.SQUARES:
        piece = board.piece_at(sq)
        if piece is not None:
            piece_idx = (piece.piece_type - 1) + (6 if piece.color == chess.BLACK else 0)
            h ^= zobrist_keys[sq][piece_idx]
    if board.turn == chess.BLACK:
        h ^= ZOBRIST_BLACK_TO_MOVE
    return h

# -------------------------
# Transposition table
# -------------------------
class TTEntry:
    __slots__ = ("value", "depth", "flag", "best_move")
    def __init__(self, value: float, depth: int, flag: str, best_move: Optional[chess.Move]):
        self.value = value
        self.depth = depth
        self.flag = flag  # "EXACT", "LOWER", "UPPER"
        self.best_move = best_move

transposition_table: Dict[int, TTEntry] = {}

def clear_transposition_table():
    global transposition_table, nodes_searched, tt_hits
    transposition_table.clear()
    nodes_searched = 0
    tt_hits = 0

# -------------------------
# Move ordering helpers
# -------------------------
piece_value_order = {
    chess.PAWN: 0,
    chess.KNIGHT: 1,
    chess.BISHOP: 2,
    chess.ROOK: 3,
    chess.QUEEN: 4,
    chess.KING: 5
}

def mvv_lva_score(board: chess.Board, move: chess.Move) -> int:
    if board.is_capture(move):
        captured = board.piece_at(move.to_square)
        attacker = board.piece_at(move.from_square)
        if captured is None or attacker is None:
            return 0
        return (piece_value_order.get(captured.piece_type, 0) * 10) - piece_value_order.get(attacker.piece_type, 0)
    return 0

HISTORY: Dict[Tuple[int,int], int] = {}
KILLER: Dict[int, List[chess.Move]] = {}

def history_score(move: chess.Move) -> int:
    return HISTORY.get((move.from_square, move.to_square), 0)

def add_history(move: chess.Move, depth: int):
    HISTORY[(move.from_square, move.to_square)] = HISTORY.get((move.from_square, move.to_square), 0) + (1 << depth)

def add_killer(move: chess.Move, ply: int):
    if ply not in KILLER:
        KILLER[ply] = []
    if move not in KILLER[ply]:
        KILLER[ply].insert(0, move)
        if len(KILLER[ply]) > 2:
            KILLER[ply].pop()

def is_killer(move: chess.Move, ply: int) -> bool:
    return move in KILLER.get(ply, [])

# -------------------------
# Lightweight SEE (approx)
# -------------------------
def simple_see_gain(board: chess.Board, move: chess.Move) -> int:
    """Approximate SEE via material difference: attacker value - captured value (positive = good)."""
    if not board.is_capture(move):
        return 0
    captured = board.piece_at(move.to_square)
    attacker = board.piece_at(move.from_square)
    if captured is None or attacker is None:
        return 0
    return MATERIAL.get(captured.piece_type, 0) - MATERIAL.get(attacker.piece_type, 0)

# -------------------------
# Quiescence search (captures & promotions)
# -------------------------
def quiescence(board: chess.Board, alpha: float, beta: float) -> float:
    global nodes_searched
    nodes_searched += 1

    stand_pat = evaluate_position(board)
    if stand_pat >= beta:
        return beta
    if alpha < stand_pat:
        alpha = stand_pat

    # collect capture/promotion moves
    moves = [m for m in board.legal_moves if board.is_capture(m) or m.promotion]
    # order by MVV-LVA + SEE (descending)
    moves.sort(key=lambda m: (mvv_lva_score(board, m), simple_see_gain(board, m)), reverse=True)

    push = board.push
    pop = board.pop
    for m in moves:
        # quick SEE prune
        if simple_see_gain(board, m) < -200:
            continue
        push(m)
        score = -quiescence(board, -beta, -alpha)
        pop()
        if score >= beta:
            return beta
        if score > alpha:
            alpha = score
    return alpha

# -------------------------
# Negamax with alpha-beta, TT, null-move, check extensions
# -------------------------
def negamax(board: chess.Board, depth: int, alpha: float, beta: float, allow_null: bool,
            start_time: float, time_limit: float, ply: int = 0) -> Tuple[float, bool]:
    """
    Negamax with:
      - TT probing
      - Null-move pruning
      - Futility pruning (shallow)
      - PVS (principal variation search)
      - LMR (late move reductions) for quiet moves
      - Check extensions (+1 depth when giving check)
    Returns (score, time_exceeded_flag).
    """
    global nodes_searched, tt_hits

    # time check
    if time.time() - start_time >= time_limit:
        return 0.0, True

    nodes_searched += 1
    zob = zobrist_hash(board)
    tt_entry = transposition_table.get(zob)

    alpha_orig = alpha  # save original alpha for TT storing

    # ---------- Transposition table probe ----------
    if tt_entry is not None and tt_entry.depth >= depth:
        tt_hits += 1
        if tt_entry.flag == "EXACT":
            return tt_entry.value, False
        elif tt_entry.flag == "LOWER":
            alpha = max(alpha, tt_entry.value)
        elif tt_entry.flag == "UPPER":
            beta = min(beta, tt_entry.value)
        if alpha >= beta:
            return tt_entry.value, False

    # ---------- leaf node ----------
    if depth <= 0:
        val = quiescence(board, alpha, beta)
        return val, False

    # ---------- Futility pruning (shallow) ----------
    if depth <= 2 and not board.is_check():
        static_eval = evaluate_position(board)
        margin = 100 * depth
        if static_eval + margin <= alpha:
            return static_eval, False

    # ---------- Null-move pruning ----------
    if allow_null and depth >= 3 and not board.is_check():
        board.push(chess.Move.null())
        score_nm, time_ex = negamax(board, depth - 1 - 2, -beta, -beta + 1, False, start_time, time_limit, ply + 1)
        board.pop()
        if time_ex:
            return 0.0, True
        # negate NM child to parent perspective
        if -score_nm >= beta:
            return -score_nm, False

    # ---------- Generate & order moves ----------
    legal_moves_iter = board.legal_moves
    tt_move = tt_entry.best_move if tt_entry else None
    move_scores = []
    for m in legal_moves_iter:
        sc = 0
        if tt_move and m == tt_move:
            sc += 1_000_000
        if board.is_capture(m):
            sc += 100_000 + mvv_lva_score(board, m)
        if m.promotion:
            sc += 80_000
        if is_killer(m, ply):
            sc += 5_000
        sc += history_score(m)
        move_scores.append((sc, m))
    move_scores.sort(key=lambda x: x[0], reverse=True)
    ordered_moves = [m for _, m in move_scores]

    if not ordered_moves:
        if board.is_checkmate():
            return -MATE_SCORE + ply, False
        else:
            return 0.0, False

    best_value = -INF
    best_move_local = None

    push = board.push
    pop = board.pop

    # ---------- PVS + LMR loop ----------
    for idx, move in enumerate(ordered_moves):
        # time check
        if time.time() - start_time >= time_limit:
            return 0.0, True

        push(move)

        # extension: if move gives check, extend search by 1
        extension = 1 if board.is_check() else 0

        # Decide whether to try LMR (conservative)
        used_reduction = 0
        child_score = None

        if (depth >= 3 and not board.is_capture(move) and not board.is_check()
                and idx >= 3):
            # compute reduction conservatively
            r = 1 + int(math.log2(depth)) if depth > 1 else 1
            r = min(r, depth - 1)
            r = max(1, r)
            reduced_depth = depth - 1 - r + extension
            # reduced zero-window search first
            score_reduced, time_ex = negamax(board, reduced_depth, -alpha - 1, -alpha, True, start_time, time_limit, ply + 1)
            if time_ex:
                pop()
                return 0.0, True
            # convert to parent perspective
            score_reduced = -score_reduced

            if score_reduced > alpha:
                # re-search full window at normal depth
                score_full, time_ex2 = negamax(board, depth - 1 + extension, -beta, -alpha, True, start_time, time_limit, ply + 1)
                if time_ex2:
                    pop()
                    return 0.0, True
                child_score = -score_full
            else:
                child_score = score_reduced
        else:
            # Normal PVS behavior
            if idx == 0:
                # first move: full window
                score_child, time_ex = negamax(board, depth - 1 + extension, -beta, -alpha, True, start_time, time_limit, ply + 1)
                if time_ex:
                    pop()
                    return 0.0, True
                child_score = -score_child
            else:
                # zero-window PVS
                score_zw, time_ex = negamax(board, depth - 1 + extension, -alpha - 1, -alpha, True, start_time, time_limit, ply + 1)
                if time_ex:
                    pop()
                    return 0.0, True
                child_score = -score_zw
                if child_score > alpha:
                    # re-search full window
                    score_full, time_ex2 = negamax(board, depth - 1 + extension, -beta, -alpha, True, start_time, time_limit, ply + 1)
                    if time_ex2:
                        pop()
                        return 0.0, True
                    child_score = -score_full

        pop()

        score = child_score  # already in parent perspective
        if score is None:
            # fallback safety
            score = -INF

        if score > best_value:
            best_value = score
            best_move_local = move

        if score > alpha:
            alpha = score

        if alpha >= beta:
            add_killer(move, ply)
            add_history(move, depth)
            break

    # Decide TT flag using alpha_orig (canonical)
    if best_value <= alpha_orig:
        flag = "UPPER"
    elif best_value >= beta:
        flag = "LOWER"
    else:
        flag = "EXACT"

    transposition_table[zob] = TTEntry(best_value, depth, flag, best_move_local)
    return best_value, False


# -------------------------
# Iterative deepening with aspiration windows
# -------------------------
def get_best_move_and_eval(board: chess.Board, time_limit: float = 2.5, max_depth: int = 20) -> Tuple[Optional[chess.Move], float]:
    """
    Returns (best_move, score). Score is in same scale as evaluate_position (side-to-move).
    """
    global nodes_searched, tt_hits
    nodes_searched = 0
    tt_hits = 0

    legal = list(board.legal_moves)
    if not legal:
        return None, evaluate_position(board)

    start_time = time.time()
    best_move = None
    last_score = 0.0
    window = 50.0

    for depth in range(1, max_depth + 1):
        if time.time() - start_time >= time_limit:
            break

        alpha = last_score - window
        beta = last_score + window

        score, time_exceeded = negamax(board, depth, alpha, beta, True, start_time, time_limit)
        if time_exceeded:
            break

        # if outside aspiration window, re-search full window once
        if score <= alpha or score >= beta:
            score, time_exceeded = negamax(board, depth, -INF, INF, True, start_time, time_limit)
            if time_exceeded:
                break

        # root best move from TT if available
        zob = zobrist_hash(board)
        tt = transposition_table.get(zob)
        if tt and tt.best_move:
            best_move = tt.best_move
            best_score = score
        else:
            best_move = best_move or legal[0]
            best_score = score

        last_score = score
        window = max(20.0, window * 0.75)

        if time.time() - start_time >= time_limit:
            break    
    print(f"Depth reached: {depth}, Nodes searched: {nodes_searched}, TT hits: {tt_hits}")
    return best_move, last_score

