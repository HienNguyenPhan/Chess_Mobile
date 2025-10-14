# search_bitboard.py
import math
import time
import random
from typing import Tuple, Optional, Dict, List

from bit_board import BitboardState, WHITE, BLACK, BB_SQUARES, PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING, MATERIAL, ZOBRIST_BLACK_TO_MOVE

# -------------------------
# Config / globals
# -------------------------
RNG = random.Random(1234567)
INF = 1e9
MATE_SCORE = 32000

# diagnostics
nodes_searched = 0
tt_hits = 0

# -------------------------
# Transposition table
# -------------------------
class TTEntry:
    __slots__ = ("value", "depth", "flag", "best_move")
    def __init__(self, value: float, depth: int, flag: str, best_move):
        self.value = value
        self.depth = depth
        self.flag = flag  # "EXACT", "LOWER", "UPPER"
        self.best_move = best_move  # move tuple

transposition_table: Dict[int, TTEntry] = {}

def clear_transposition_table():
    global transposition_table, nodes_searched, tt_hits
    transposition_table.clear()
    nodes_searched = 0
    tt_hits = 0

# -------------------------
# Helpers (move <-> uci)
# -------------------------
def sq_to_coord(sq: int) -> str:
    file = sq % 8
    rank = sq // 8
    return chr(ord('a') + file) + str(rank + 1)

def move_to_uci(move) -> str:
    from_sq, to_sq, ptype, promo = move
    u = sq_to_coord(from_sq) + sq_to_coord(to_sq)
    if promo is not None:
        # promotion piece letter
        promo_map = {QUEEN: 'q', ROOK: 'r', BISHOP: 'b', KNIGHT: 'n'}
        u += promo_map.get(promo, 'q')
    return u

# -------------------------
# Move classification helpers (pseudo-legal API)
# -------------------------
def is_capture(state: BitboardState, move) -> bool:
    _, to_sq, _, _ = move
    us = state.side_to_move
    them = 1 - us
    occ_them = state.occupied_color(them)
    return bool(occ_them & BB_SQUARES[to_sq])

def is_promotion(move) -> bool:
    return move[3] is not None

# -------------------------
# MVV-LVA scoring (adapted)
# -------------------------
piece_value_order = {
    PAWN: 0,
    KNIGHT: 1,
    BISHOP: 2,
    ROOK: 3,
    QUEEN: 4,
    KING: 5
}

def mvv_lva_score(state: BitboardState, move) -> int:
    """Higher is better for captures."""
    if not is_capture(state, move):
        return 0
    _, to_sq, _, _ = move
    them = 1 - state.side_to_move
    # find captured piece type at to_sq (in opponent bitboards)
    for p in range(6):
        if state.bitboards[them][p] & BB_SQUARES[to_sq]:
            captured = p
            break
    else:
        captured = PAWN
    # attacker type:
    from_sq, _, ptype, _ = move
    attacker = ptype
    # prefer capturing high value pieces by low value attacker
    return (piece_value_order.get(captured, 0) * 10) - piece_value_order.get(attacker, 0)

# -------------------------
# History & killers
# -------------------------
HISTORY: Dict[Tuple[int,int,int,int], int] = {}  # keyed by move tuple
KILLER: Dict[int, List[Tuple]] = {}  # ply -> list of moves

def history_score(move) -> int:
    return HISTORY.get(tuple(move), 0)

def add_history(move, depth: int):
    HISTORY[tuple(move)] = HISTORY.get(tuple(move), 0) + (1 << depth)

def add_killer(move, ply: int):
    if ply not in KILLER:
        KILLER[ply] = []
    if move not in KILLER[ply]:
        KILLER[ply].insert(0, move)
        if len(KILLER[ply]) > 2:
            KILLER[ply].pop()

def is_killer(move, ply: int) -> bool:
    return move in KILLER.get(ply, [])

# -------------------------
# Simple SEE (approx)
# -------------------------
def simple_see_gain(state: BitboardState, move) -> int:
    if not is_capture(state, move):
        return 0
    _, to_sq, _, _ = move
    them = 1 - state.side_to_move
    # find captured piece type
    for p in range(6):
        if state.bitboards[them][p] & BB_SQUARES[to_sq]:
            captured = p
            break
    else:
        captured = PAWN
    attacker = move[2]
    return MATERIAL[captured] - MATERIAL[attacker]

# -------------------------
# Evaluation wrapper
# -------------------------
def evaluate_state(state: BitboardState) -> float:
    # currently use state.evaluate() which is material-only in the skeleton.
    # replace this with your richer evaluator ported to bitboards for stronger play.
    return state.evaluate()

# -------------------------
# Quiescence
# -------------------------
def quiescence(state: BitboardState, alpha: float, beta: float) -> float:
    global nodes_searched
    nodes_searched += 1

    stand_pat = evaluate_state(state)
    if stand_pat >= beta:
        return beta
    if alpha < stand_pat:
        alpha = stand_pat

    # get captures/promotions
    captures = []
    for mv in state.generate_legal_moves():
        if is_capture(state, mv) or is_promotion(mv):
            captures.append(mv)

    # order
    captures.sort(key=lambda m: (mvv_lva_score(state, m), simple_see_gain(state, m)), reverse=True)

    for m in captures:
        # quick SEE prune
        if simple_see_gain(state, m) < -200:
            continue
        state.make_move(m)
        score = -quiescence(state, -beta, -alpha)
        state.unmake_move()
        if score >= beta:
            return beta
        if score > alpha:
            alpha = score
    return alpha

# -------------------------
# Negamax (PVS + LMR + TT + Null-move)
# -------------------------
def negamax(state: BitboardState, depth: int, alpha: float, beta: float, allow_null: bool,
            start_time: float, time_limit: float, ply: int = 0) -> Tuple[float, bool]:
    """
    Returns (score, time_exceeded_flag). Score = side-to-move perspective.
    """
    global nodes_searched, tt_hits

    if time.time() - start_time >= time_limit:
        return 0.0, True

    nodes_searched += 1
    zob = state.zobrist_key
    tt_entry = transposition_table.get(zob)
    alpha_orig = alpha

    # TT probe
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

    # leaf
    if depth <= 0:
        val = quiescence(state, alpha, beta)
        return val, False

    # futility pruning (shallow)
    if depth <= 2:
        static_eval = evaluate_state(state)
        margin = 100 * depth
        if static_eval + margin <= alpha:
            return static_eval, False

    # null-move pruning
    if allow_null and depth >= 3 and not state.is_in_check():
        state.side_to_move ^= 1
        state.zobrist_key ^= ZOBRIST_BLACK_TO_MOVE

        score_null, time_ex = negamax(state, depth - 1 - 2, -beta, -beta + 1, False, start_time, time_limit, ply + 1)

        state.side_to_move ^= 1
        state.zobrist_key ^= ZOBRIST_BLACK_TO_MOVE

        if time_ex:
            return 0.0, True
        
        if -score_null >= beta:
            return beta, False
        
    # generate and order moves
    if state.draw_detection():
        return 0.0, False  # draw detected

    moves = list(state.generate_legal_moves())
    
    if not moves:
        if state.is_in_check():
            return -MATE_SCORE + ply, False  # checkmate
        else:
            return 0.0, False  # stalemate

    # ordering scores
    tt_move = tt_entry.best_move if tt_entry else None
    scored = []
    for m in moves:
        sc = 0
        if tt_move and m == tt_move:
            sc += 1_000_000
        if is_capture(state, m):
            sc += 100_000 + mvv_lva_score(state, m)
        if is_promotion(m):
            sc += 80_000
        if is_killer(m, ply):
            sc += 5_000
        sc += history_score(m)
        scored.append((sc, m))
    scored.sort(key=lambda x: x[0], reverse=True)
    ordered_moves = [m for _, m in scored]

    best_value = -INF
    best_move_local = None

    for idx, move in enumerate(ordered_moves):
        if time.time() - start_time >= time_limit:
            return 0.0, True

        state.make_move(move)
        extension = 1 if state.is_in_check() else 0

        child_score = None

        # LMR: conservative
        if depth >= 3 and not is_capture(state, move) and idx >= 3:
            r = 1  # conservative: use reduction 1 for safety
            reduced_depth = depth - 1 - r + extension
            score_red, time_ex = negamax(state, reduced_depth, -alpha - 1, -alpha, True, start_time, time_limit, ply + 1)
            if time_ex:
                state.unmake_move()
                return 0.0, True
            score_red = -score_red
            if score_red > alpha:
                score_full, time_ex2 = negamax(state, depth - 1 + extension, -beta, -alpha, True, start_time, time_limit, ply + 1)
                if time_ex2:
                    state.unmake_move()
                    return 0.0, True
                child_score = -score_full
            else:
                child_score = score_red
        else:
            if idx == 0:
                score_c, time_ex = negamax(state, depth - 1 + extension, -beta, -alpha, True, start_time, time_limit, ply + 1)
                if time_ex:
                    state.unmake_move()
                    return 0.0, True
                child_score = -score_c
            else:
                score_z, time_ex = negamax(state, depth - 1 + extension, -alpha - 1, -alpha, True, start_time, time_limit, ply + 1)
                if time_ex:
                    state.unmake_move()
                    return 0.0, True
                child_score = -score_z
                if child_score > alpha:
                    score_full, time_ex2 = negamax(state, depth - 1 + extension, -beta, -alpha, True, start_time, time_limit, ply + 1)
                    if time_ex2:
                        state.unmake_move()
                        return 0.0, True
                    child_score = -score_full

        state.unmake_move()

        score = child_score
        if score is None:
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

    # TT flag
    if best_value <= alpha_orig:
        flag = "UPPER"
    elif best_value >= beta:
        flag = "LOWER"
    else:
        flag = "EXACT"

    transposition_table[zob] = TTEntry(best_value, depth, flag, best_move_local)
    return best_value, False

# -------------------------
# Iterative deepening / root
# -------------------------
def get_best_move_and_eval(state: BitboardState, time_limit: float = 3.0, max_depth: int = 20) -> Tuple[Optional[str], float]:
    """
    Returns (best_move_uci or None, score).
    Score is side-to-move perspective (same scale as evaluate_state()).
    """
    global nodes_searched, tt_hits
    nodes_searched = 0
    tt_hits = 0
    clear_transposition_table()

    # initial move list
    root_moves = list(state.generate_legal_moves())
    if not root_moves:
        return None, evaluate_state(state)

    start_time = time.time()
    best_move = None
    last_score = 0.0
    window = 50.0

    for depth in range(1, max_depth + 1):
        if time.time() - start_time >= time_limit:
            break

        alpha = last_score - window
        beta = last_score + window

        score, time_exceeded = negamax(state, depth, alpha, beta, True, start_time, time_limit)
        if time_exceeded:
            break

        # aspiration miss -> full-window re-search
        if score <= alpha or score >= beta:
            score, time_exceeded = negamax(state, depth, -INF, INF, True, start_time, time_limit)
            if time_exceeded:
                break

        # read root best move from TT
        zob = state.zobrist_key
        tt = transposition_table.get(zob)
        if tt and tt.best_move:
            best_move = tt.best_move
            best_score = score
        else:
            best_move = best_move or root_moves[0]
            best_score = score

        last_score = score
        window = max(20.0, window * 0.75)

        if time.time() - start_time >= time_limit:
            break

    # return uci and score
    uci = move_to_uci(best_move) if best_move else None
    print(f"Depth reached: {depth}, Nodes searched: {nodes_searched}, TT hits: {tt_hits}")
    return uci, last_score
