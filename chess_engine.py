import bulletchess
from bulletchess import *
from bulletchess.utils import *
import time
import random
from typing import Tuple, Optional, Dict, List
from eval import evaluate_position

# -------------------------
# Config / globals
# -------------------------
RNG = random.Random(1234567)
INF = 1e9
MATE_SCORE = 32000
MATERIAL = {
    PAWN: 100,
    KNIGHT: 320,
    BISHOP: 330,
    ROOK: 500,
    QUEEN: 900,
    KING: 0
}

# Diagnostics
nodes_searched = 0
tt_hits = 0

# -------------------------
# Transposition table
# -------------------------
MAX_TT_SIZE = 500_000  # Limit TT size to prevent memory issues

class TTEntry:
    __slots__ = ("value", "depth", "flag", "best_move")
    def __init__(self, value: float, depth: int, flag: str, best_move: bulletchess.Move):
        self.value = value
        self.depth = depth
        self.flag = flag
        self.best_move = best_move

transposition_table: Dict[int, TTEntry] = {}  # Changed from str to int

def simple_hash(state: bulletchess.Board) -> int:
    """Fast hash for transposition table. Fallback to FEN hash if needed."""
    try:
        return hash(state)
    except:
        return hash(state.fen())

def store_tt_entry(zob: int, entry: TTEntry):
    """Store TT entry with depth-preferred replacement strategy."""
    global transposition_table
    
    existing = transposition_table.get(zob)
    
    # Always replace if:
    # 1. Slot is empty
    # 2. New entry has higher/equal depth
    # 3. New entry is exact score
    if existing is None or \
       entry.depth >= existing.depth or \
       entry.flag == "EXACT":
        transposition_table[zob] = entry
    
    # Only check size every N entries
    if len(transposition_table) >= MAX_TT_SIZE and nodes_searched % 1000 == 0:
        keys_to_remove = random.sample(list(transposition_table.keys()), MAX_TT_SIZE // 10)
        for k in keys_to_remove:
            del transposition_table[k]

def clear_transposition_table():
    global transposition_table, nodes_searched, tt_hits, HISTORY, KILLER
    transposition_table.clear()
    HISTORY.clear()
    KILLER.clear()
    nodes_searched = 0
    tt_hits = 0

# -------------------------
# MVV-LVA scoring
# -------------------------
def get_captured_piece(state: bulletchess.Board, move: bulletchess.Move) -> Optional[int]:
    """Get the piece type at the destination square."""
    if not move.is_capture(state):
        return None
    to_sq = move.destination
    them = state.turn.opposite
    for ptype in [PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING]:
        if state[them, ptype] & to_sq.bb():
            return ptype
    return None

def mvv_lva_score(state: bulletchess.Board, move: bulletchess.Move) -> int:
    captured = get_captured_piece(state, move)
    if captured is None:
        return 0
    piece = state[move.origin]
    attacker = piece.piece_type if piece else PAWN
    
    victim_value = MATERIAL.get(captured, 0)
    attacker_value = MATERIAL.get(attacker, 100)
    
    return victim_value * 10 + (1000 - attacker_value)

# -------------------------
# History & killers
# -------------------------
HISTORY: Dict[Tuple[int, int], int] = {}
KILLER: Dict[int, List[bulletchess.Move]] = {}

def history_score(move: bulletchess.Move) -> int:
    key = (move.origin.index(), move.destination.index())
    return HISTORY.get(key, 0)

def add_history(move: bulletchess.Move, depth: int):
    key = (move.origin.index(), move.destination.index())
    # Use depth squared for better scaling
    HISTORY[key] = HISTORY.get(key, 0) + (depth * depth)

def add_killer(move: bulletchess.Move, ply: int):
    if ply not in KILLER:
        KILLER[ply] = []
    if move not in KILLER[ply]:
        KILLER[ply].insert(0, move)
        if len(KILLER[ply]) > 2:
            KILLER[ply].pop()

def is_killer(move: bulletchess.Move, ply: int) -> bool:
    return move in KILLER.get(ply, [])

# -------------------------
# Simple SEE
# -------------------------
def simple_see_gain(state: bulletchess.Board, move: bulletchess.Move) -> int:
    captured = get_captured_piece(state, move)
    if captured is None:
        return 0
    piece = state[move.origin]
    attacker = piece.piece_type if piece else PAWN
    return MATERIAL[captured] - MATERIAL[attacker]

# -------------------------
# Quiescence
# -------------------------
def quiescence(state: bulletchess.Board, alpha: float, beta: float, ply: int = 0) -> float:
    global nodes_searched
    nodes_searched += 1

    # Check terminal positions first
    if state in CHECKMATE:
        return -MATE_SCORE + ply
    if state in DRAW:
        return 0.0

    stand_pat = evaluate_position(state)
    if stand_pat >= beta:
        return beta
    
    # Delta pruning: if we can't reach alpha even with a queen capture
    BIG_DELTA = 975  # Queen value + margin
    if stand_pat < alpha - BIG_DELTA:
        return alpha
    
    if alpha < stand_pat:
        alpha = stand_pat

    # Collect captures and promotions (avoid expensive board copies)
    captures = [m for m in state.legal_moves() if m.is_capture(state) or m.is_promotion()]

    captures.sort(key=lambda m: (mvv_lva_score(state, m), simple_see_gain(state, m)), reverse=True)

    for move in captures:
        # SEE pruning: only skip obviously bad captures (losing major piece for pawn)
        # Be conservative - simple_see_gain doesn't account for whether recapture exists
        if simple_see_gain(state, move) < -400:  # Only prune if losing 400+ material
            continue
        state.apply(move)
        score = -quiescence(state, -beta, -alpha, ply + 1)
        state.undo()
        if score >= beta:
            return beta
        if score > alpha:
            alpha = score
    return alpha

# -------------------------
# Negamax (PVS + LMR + TT + Null-move)
# -------------------------
def negamax(state: bulletchess.Board, depth: int, alpha: float, beta: float, allow_null: bool,
            start_time: float, time_limit: float, ply: int = 0) -> Tuple[float, bool]:
    global nodes_searched, tt_hits

    if time.time() - start_time >= time_limit:
        return 0.0, True

    nodes_searched += 1
    
    # Cache in_check to avoid multiple calls
    in_check = state in CHECK
    
    zob = simple_hash(state)
    tt_entry = transposition_table.get(zob)
    alpha_orig = alpha

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

    if depth <= 0 or state in CHECKMATE or state in DRAW:
        return quiescence(state, alpha, beta, ply), False

    # Futility pruning (reversed/razor)
    if depth <= 2 and not in_check:
        static_eval = evaluate_position(state)
        margin = 200 * depth
        if static_eval + margin <= alpha:
            return alpha, False

    if allow_null and depth >= 3 and not in_check:
        state.apply(None)
        score_null, time_ex = negamax(state, depth - 1 - 2, -beta, -beta + 1, False, start_time, time_limit, ply + 1)
        state.undo()
        if time_ex:
            return 0.0, True
        if -score_null >= beta:
            return beta, False

    moves = list(state.legal_moves())
    if not moves:
        if in_check:
            return -MATE_SCORE + ply, False
        return 0.0, False

    tt_move = tt_entry.best_move if tt_entry else None
    
    # Internal Iterative Deepening: if no TT move, do shallow search to find one
    if depth >= 4 and tt_move is None and not in_check:
        _, _ = negamax(state, depth - 2, alpha, beta, False, start_time, time_limit, ply)
        # Check TT again after shallow search
        tt_entry = transposition_table.get(zob)
        tt_move = tt_entry.best_move if tt_entry else None
    
    scored = []
    for move in moves:
        score = 0
        if tt_move and move == tt_move:
            score += 1_000_000
        if move.is_capture(state):
            score += 100_000 + mvv_lva_score(state, move)
        if move.is_promotion():
            score += 80_000
        # Enhanced killer scoring - differentiate primary and secondary killers
        if ply in KILLER:
            if len(KILLER[ply]) > 0 and move == KILLER[ply][0]:
                score += 9_000  # Primary killer
            elif len(KILLER[ply]) > 1 and move == KILLER[ply][1]:
                score += 8_000  # Secondary killer
        if is_pinned(state, move.origin) and not move.is_capture(state):
            score -= 1_000  # Lighter penalty for pinned quiet moves
        score += history_score(move)
        scored.append((score, move))
    scored.sort(key=lambda x: x[0], reverse=True)
    ordered_moves = [m for _, m in scored]

    best_value = -INF
    best_move_local = None

    for idx, move in enumerate(ordered_moves):
        if time.time() - start_time >= time_limit:
            return 0.0, True

        # Check move properties BEFORE applying
        is_capture = move.is_capture(state)
        is_promo = move.is_promotion()
        
        state.apply(move)
        extension = 1 if state in CHECK else 0

        child_score = None
        # Late Move Reduction (LMR) - more aggressive
        if depth >= 3 and not is_capture and not is_promo and idx >= 4:
            # Calculate reduction based on depth and move index
            r = 1
            if idx >= 6:
                r = 2
            if idx >= 12:
                r = 3
            if depth >= 6:
                r += 1  # Extra reduction at high depths
            
            # Don't reduce killers as much
            if ply in KILLER and move in KILLER[ply]:
                r = max(1, r - 1)
            
            reduced_depth = max(0, depth - 1 - r + extension)
            score_red, time_ex = negamax(state, reduced_depth, -alpha - 1, -alpha, True, start_time, time_limit, ply + 1)
            if time_ex:
                state.undo()
                return 0.0, True
            score_red = -score_red
            if score_red > alpha:
                score_full, time_ex2 = negamax(state, depth - 1 + extension, -beta, -alpha, True, start_time, time_limit, ply + 1)
                if time_ex2:
                    state.undo()
                    return 0.0, True
                child_score = -score_full
            else:
                child_score = score_red
        else:
            # Principal Variation Search (PVS)
            if idx == 0:
                score_c, time_ex = negamax(state, depth - 1 + extension, -beta, -alpha, True, start_time, time_limit, ply + 1)
                if time_ex:
                    state.undo()
                    return 0.0, True
                child_score = -score_c
            else:
                score_z, time_ex = negamax(state, depth - 1 + extension, -alpha - 1, -alpha, True, start_time, time_limit, ply + 1)
                if time_ex:
                    state.undo()
                    return 0.0, True
                child_score = -score_z
                if child_score > alpha:
                    score_full, time_ex2 = negamax(state, depth - 1 + extension, -beta, -alpha, True, start_time, time_limit, ply + 1)
                    if time_ex2:
                        state.undo()
                        return 0.0, True
                    child_score = -score_full

        state.undo()
        score = child_score if child_score is not None else -INF

        if score > best_value:
            best_value = score
            best_move_local = move

        if score > alpha:
            alpha = score

        if alpha >= beta:
            if not is_capture and not is_promo:
                add_killer(move, ply)
                add_history(move, depth)
            break

    if best_value <= alpha_orig:
        flag = "UPPER"
    elif best_value >= beta:
        flag = "LOWER"
    else:
        flag = "EXACT"
    store_tt_entry(zob, TTEntry(best_value, depth, flag, best_move_local))
    return best_value, False

# -------------------------
# Iterative deepening with root move ordering
# -------------------------
def get_best_move_and_eval(state: bulletchess.Board, time_limit: float = 3.0, max_depth: int = 20) -> Tuple[Optional[str], float]:
    global nodes_searched, tt_hits
    nodes_searched = 0
    tt_hits = 0
    # Don't clear TT - keep info from previous searches
    # clear_transposition_table()

    root_moves = list(state.legal_moves())
    if not root_moves:
        return None, evaluate_position(state)

    start_time = time.time()
    best_move = None
    last_score = 0.0
    window = 50.0

    for depth in range(1, max_depth + 1):
        if time.time() - start_time >= time_limit:
            break

        # Move best move from previous depth to front for better ordering
        if best_move and best_move in root_moves:
            # print(f"Depth {depth}: Best move so far: {best_move.uci()} with score {last_score}")
            root_moves.remove(best_move)
            root_moves.insert(0, best_move)

        alpha = last_score - window
        beta = last_score + window

        # Search at root level with PVS
        best_value = -INF
        best_move_at_depth = None

        for i, move in enumerate(root_moves):
            state.apply(move)
            
            if i == 0:
                # Full window for first move (expected PV)
                score, time_ex = negamax(state, depth - 1, -beta, -alpha, True, start_time, time_limit, 1)
            else:
                # Null window search
                score, time_ex = negamax(state, depth - 1, -alpha - 1, -alpha, True, start_time, time_limit, 1)
                if not time_ex and -score > alpha and -score < beta:
                    # Re-search with full window
                    score, time_ex = negamax(state, depth - 1, -beta, -alpha, True, start_time, time_limit, 1)
            
            state.undo()
            
            if time_ex:
                break
            
            score = -score
            
            if score > best_value:
                best_value = score
                best_move_at_depth = move
            
            if score > alpha:
                alpha = score
            
            # Check for fail-high (need full re-search)
            if score >= beta:
                failed_high = True
                break

        # Handle aspiration window failures
        if not time_ex:
            if best_value <= last_score - window or best_value >= last_score + window:
                # Failed low or high, re-search with full window
                alpha = -INF
                beta = INF
                best_value = -INF
                best_move_at_depth = None
                
                for i, move in enumerate(root_moves):
                    state.apply(move)
                    
                    if i == 0:
                        score, time_ex = negamax(state, depth - 1, -beta, -alpha, True, start_time, time_limit, 1)
                    else:
                        score, time_ex = negamax(state, depth - 1, -alpha - 1, -alpha, True, start_time, time_limit, 1)
                        if not time_ex and -score > alpha:
                            score, time_ex = negamax(state, depth - 1, -beta, -alpha, True, start_time, time_limit, 1)
                    
                    state.undo()
                    
                    if time_ex:
                        break
                    
                    score = -score
                    
                    if score > best_value:
                        best_value = score
                        best_move_at_depth = move
                    
                    if score > alpha:
                        alpha = score

        if not time_ex and best_move_at_depth:
            best_move = best_move_at_depth
            last_score = best_value
            if alpha < best_value < beta:
                window = max(20.0, window * 0.75)
            else:
                window = min(500.0, window * 1.5)
        else:
            break

    uci = best_move.uci() if best_move else None
    return uci, last_score