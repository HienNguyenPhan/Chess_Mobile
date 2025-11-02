import bulletchess
from bulletchess import *
import bulletchess.utils as utils

# Constants
MATERIAL = {
    PAWN: 84,
    KNIGHT: 285,
    BISHOP: 309,
    ROOK: 508,
    QUEEN: 898,
    KING: 0
}

piece_square_tables = {
    PAWN: {
        'opening': [
             0,  0,  0,  0,  0,  0,  0,  0,
            50, 50, 50, 50, 50, 50, 50, 50,
            10, 10, 20, 30, 30, 20, 10, 10,
             5,  5, 10, 25, 25, 10,  5,  5,
             0,  0,  0, 20, 20,  0,  0,  0,
             5, -5,-10,  0,  0,-10, -5,  5,
             5, 10, 10,-20,-20, 10, 10,  5,
             0,  0,  0,  0,  0,  0,  0,  0
        ],
        'endgame': [
             0,  0,  0,  0,  0,  0,  0,  0,
            80, 80, 80, 80, 80, 80, 80, 80,
            50, 50, 50, 50, 50, 50, 50, 50,
            30, 30, 30, 30, 30, 30, 30, 30,
            20, 20, 20, 20, 20, 20, 20, 20,
            10, 10, 10, 10, 10, 10, 10, 10,
             0,  0,  0,  0,  0,  0,  0,  0,
             0,  0,  0,  0,  0,  0,  0,  0
        ]
    },
    KNIGHT: {
        'opening': [
            -50,-40,-30,-30,-30,-30,-40,-50,
            -40,-20,  0,  0,  0,  0,-20,-40,
            -30,  0, 10, 15, 15, 10,  0,-30,
            -30,  5, 15, 20, 20, 15,  5,-30,
            -30,  0, 15, 20, 20, 15,  0,-30,
            -30,  5, 10, 15, 15, 10,  5,-30,
            -40,-20,  0,  5,  5,  0,-20,-40,
            -50,-40,-30,-30,-30,-30,-40,-50
        ],
        'endgame': [
            -50,-40,-30,-30,-30,-30,-40,-50,
            -40,-20,  0,  0,  0,  0,-20,-40,
            -30,  0, 10, 15, 15, 10,  0,-30,
            -30,  5, 15, 20, 20, 15,  5,-30,
            -30,  0, 15, 20, 20, 15,  0,-30,
            -30,  5, 10, 15, 15, 10,  5,-30,
            -40,-20,  0,  5,  5,  0,-20,-40,
            -50,-40,-30,-30,-30,-30,-40,-50
        ]
    },
    BISHOP: {
        'opening': [
            -20,-10,-10,-10,-10,-10,-10,-20,
            -10,  0,  0,  0,  0,  0,  0,-10,
            -10,  0,  5, 10, 10,  5,  0,-10,
            -10,  5,  5, 10, 10,  5,  5,-10,
            -10,  0, 10, 10, 10, 10,  0,-10,
            -10, 10, 10,  5,  5, 10, 10,-10,
            -10,  5,  0,  0,  0,  0,  5,-10,
            -20,-10,-10,-10,-10,-10,-10,-20
        ],
        'endgame': [
            -20,-10,-10,-10,-10,-10,-10,-20,
            -10,  0,  0,  0,  0,  0,  0,-10,
            -10,  0,  5, 10, 10,  5,  0,-10,
            -10,  5,  5, 10, 10,  5,  5,-10,
            -10,  0, 10, 10, 10, 10,  0,-10,
            -10, 10, 10,  5,  5, 10, 10,-10,
            -10,  5,  0,  0,  0,  0,  5,-10,
            -20,-10,-10,-10,-10,-10,-10,-20
        ]
    },
    ROOK: {
        'opening': [
             0,  0,  0,  0,  0,  0,  0,  0,
             5, 10, 10, 10, 10, 10, 10,  5,
            -5,  0,  0,  0,  0,  0,  0, -5,
            -5,  0,  0,  0,  0,  0,  0, -5,
            -5,  0,  0,  0,  0,  0,  0, -5,
            -5,  0,  0,  0,  0,  0,  0, -5,
            -5,  0,  0,  0,  0,  0,  0, -5,
             0, 10, 10, 10, 10, 10, 10,  0
        ],
        'endgame': [
             0,  0,  0,  0,  0,  0,  0,  0,
             5, 10, 10, 10, 10, 10, 10,  5,
             0,  0,  0,  0,  0,  0,  0,  0,
             0,  0,  0,  0,  0,  0,  0,  0,
             0,  0,  0,  0,  0,  0,  0,  0,
             0,  0,  0,  0,  0,  0,  0,  0,
             0,  0,  0,  0,  0,  0,  0,  0,
             0,  0,  0,  0,  0,  0,  0,  0
        ]
    },
    QUEEN: {
        'opening': [
            -20,-10,-10, -5, -5,-10,-10,-20,
            -10,  0,  0,  0,  0,  0,  0,-10,
            -10,  0,  5,  5,  5,  5,  0,-10,
             -5,  0,  5,  5,  5,  5,  0, -5,
              0,  0,  5,  5,  5,  5,  0, -5,
            -10,  5,  5,  5,  5,  5,  0,-10,
            -10,  0,  5,  0,  0,  0,  0,-10,
            -20,-10,-10, -5, -5,-10,-10,-20
        ],
        'endgame': [
            -20,-10,-10, -5, -5,-10,-10,-20,
            -10,  0,  0,  0,  0,  0,  0,-10,
            -10,  0,  5,  5,  5,  5,  0,-10,
             -5,  0,  5,  5,  5,  5,  0, -5,
             -5,  0,  5,  5,  5,  5,  0, -5,
            -10,  0,  5,  5,  5,  5,  0,-10,
            -10,  0,  0,  0,  0,  0,  0,-10,
            -20,-10,-10, -5, -5,-10,-10,-20
        ]
    },
    KING: {
        'opening': [
            -30,-40,-40,-50,-50,-40,-40,-30, 
            -40,-50,-50,-60,-60,-50,-50,-40, 
            -50,-60,-60,-70,-70,-60,-60,-50, 
            -60,-70,-70,-80,-80,-70,-70,-60,  
            -60,-70,-70,-80,-80,-70,-70,-60,
            -50,-60,-60,-70,-70,-60,-60,-50, 
            -10,-20,-20,-20,-20,-20,-20,-10, 
             10, 10,  0,  0,  0,  0, 10, 10 
        ],
        'endgame': [
            -50,-40,-30,-20,-20,-30,-40,-50,
            -30,-20,-10,  0,  0,-10,-20,-30,
            -30,-10, 20, 30, 30, 20,-10,-30,
            -30,-10, 30, 40, 40, 30,-10,-30,
            -30,-10, 30, 40, 40, 30,-10,-30,
            -30,-10, 20, 30, 30, 20,-10,-30,
            -30,-30,  0,  0,  0,  0,-30,-30,
            -50,-30,-30,-30,-30,-30,-30,-50
        ]
    }
}

PST = {pt: {'opening': ps['opening'], 'endgame': ps['endgame']} for pt, ps in piece_square_tables.items()}

PHASE_STEPS = 10
interpolated_pst = {}
for ptype in [PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING]:
    interpolated_pst[ptype] = []
    for phase_step in range(PHASE_STEPS + 1):
        weight = phase_step / PHASE_STEPS
        # weight=0 (phase_step=0) => opening, weight=1 (phase_step=10) => endgame
        interpolated_pst[ptype].append([
            PST[ptype]['opening'][i] * (1 - weight) + PST[ptype]['endgame'][i] * weight
            for i in range(64)
        ])

def count_bits(bb: bulletchess.Bitboard) -> int:
    return sum(1 for _ in bb)

def manhattan_distance(sq1: bulletchess.Square, sq2: bulletchess.Square) -> int:
    file1, rank1 = sq1.index() % 8, sq1.index() // 8
    file2, rank2 = sq2.index() % 8, sq2.index() // 8
    return abs(file1 - file2) + abs(rank1 - rank2)

def get_game_phase(state: bulletchess.Board) -> float:
    phase_total = 24
    phase = phase_total
    phase -= count_bits(state[WHITE, KNIGHT] | state[BLACK, KNIGHT]) * 1
    phase -= count_bits(state[WHITE, BISHOP] | state[BLACK, BISHOP]) * 1
    phase -= count_bits(state[WHITE, ROOK]   | state[BLACK, ROOK])   * 2
    phase -= count_bits(state[WHITE, QUEEN]  | state[BLACK, QUEEN])  * 4
    phase = max(0, min(phase, phase_total))
    return phase / phase_total

def compute_pst_and_material(state: bulletchess.Board, phase: float) -> float:
    phase_idx = int(phase * PHASE_STEPS)
    score = 0.0
    for color in [WHITE, BLACK]:
        sign = 1 if color == WHITE else -1
        for ptype in [PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING]:
            bb = state[color, ptype]
            value = MATERIAL[ptype]
            table = interpolated_pst[ptype][phase_idx]
            for sq in bb:
                sq_idx = sq.index()
                rank = sq_idx // 8
                file = sq_idx % 8
                # PST is from black's perspective (rank 8 at top)
                # For white: flip rank only (e1 -> e8)
                # For black: use direct index
                if color == WHITE:
                    idx = (7 - rank) * 8 + file
                else:
                    idx = sq_idx
                score += sign * (value + table[idx])
    return score

def king_safety(state: bulletchess.Board, color: bulletchess.Color, phase_weight: float) -> int:
    """
    Evaluate king safety - only matters in opening/middlegame.
    In endgame, king should be active and centralized.
    """
    sign = 1 if color == WHITE else -1
    king_sq = utils.king_square(state, color)
    safety = 0

    if phase_weight < 0.3:
        # Pawn shield - more important in opening
        if color == WHITE:
            shield_sqs = [king_sq.north(), king_sq.nw(), king_sq.ne()]
        else:
            shield_sqs = [king_sq.south(), king_sq.sw(), king_sq.se()]
        
        shield = sum(19 for sq in shield_sqs if sq and state[color, PAWN] & sq.bb())
        safety += int(shield * phase_weight)  # Scale with game phase
        
        # Penalty for king in center during opening/middlegame
        king_file = king_sq.index() % 8
        if king_file in [3, 4]:
            safety -= int(41 * phase_weight)  # Only penalize in opening
        
        # Bonus for castled king - only in opening/middlegame
        king_rank = king_sq.index() // 8
        back_rank = 0 if color == WHITE else 7
        if king_rank == back_rank and king_file in [0, 1, 6, 7]:
            safety += int(20 * phase_weight)
    
    return sign * safety

def passed_pawn_bonus(board, phase_weight):
    """Award bonus for passed pawns, scaled by advancement and phase"""
    bonus = 0
    
    # Endgame: passed pawns more valuable
    base_value = 20 if phase_weight < 0.5 else 37
    
    white_pawns = board[WHITE, PAWN]
    black_pawns = board[BLACK, PAWN]
    
    # Check white pawns
    for sq in white_pawns:
        square_index = sq.index()
        rank = square_index // 8
        
        if _is_passed_pawn(board, square_index, True):
            # Scale by rank: more advanced = more valuable
            # Ranks 1-7 (index 1-6 for white pawns)
            advancement_multiplier = max(0, rank - 1)  # 0 to 6
            
            # In endgame, advanced pawns are MUCH more valuable
            if phase_weight > 0.5:  # Endgame
                # Exponential scaling: 40, 80, 138, 208, 290, 382
                bonus += base_value * (1 + advancement_multiplier ** 1.15)
            else:  # Opening/Middlegame
                bonus += base_value * (1 + advancement_multiplier * 0.3)
    
    # Check black pawns
    for sq in black_pawns:
        square_index = sq.index()
        rank = square_index // 8
        
        if _is_passed_pawn(board, square_index, False):
            advancement_multiplier = max(0, 6 - rank)  # Inverted for black (0 to 6)
            if phase_weight > 0.5:  # Endgame
                bonus -= base_value * (1 + advancement_multiplier ** 1.15)
            else:  # Opening/Middlegame
                bonus -= base_value * (1 + advancement_multiplier * 0.3)
    
    return bonus

def _is_passed_pawn(board, square_index, is_white):
    """Check if pawn is passed (no enemy pawns ahead) - optimized version"""
    rank = square_index // 8
    file_idx = square_index % 8
    
    enemy_pawns = board[BLACK, PAWN] if is_white else board[WHITE, PAWN]
    
    # Create set of enemy pawn indices for O(1) lookup
    enemy_indices = set(sq.index() for sq in enemy_pawns)
    
    # Check file and adjacent files
    for check_file in [file_idx - 1, file_idx, file_idx + 1]:
        if check_file < 0 or check_file >= 8:
            continue
        
        # Check ranks ahead
        if is_white:
            check_ranks = range(rank + 1, 8)
        else:
            check_ranks = range(0, rank)
        
        for check_rank in check_ranks:
            # O(1) check if enemy pawn exists at this square
            if check_rank * 8 + check_file in enemy_indices:
                return False
    
    return True

def isolated_pawn_penalty(state: bulletchess.Board, phase_weight: float) -> float:
    penalty = 8 if phase_weight > 0.5 else 11
    return (count_bits(utils.isolated_pawns(state, WHITE)) - count_bits(utils.isolated_pawns(state, BLACK))) * -penalty

def mop_up_eval(state: bulletchess.Board, phase_weight: float) -> float:
    # Only apply in endgame (phase > 0.5) when material advantage is LARGE (500+)
    if phase_weight <= 0.5:
        return 0
    
    white_king = utils.king_square(state, WHITE)
    black_king = utils.king_square(state, BLACK)
    
    # Calculate who's winning by material
    white_material = sum(count_bits(state[WHITE, pt]) * MATERIAL[pt] for pt in [PAWN, KNIGHT, BISHOP, ROOK, QUEEN])
    black_material = sum(count_bits(state[BLACK, pt]) * MATERIAL[pt] for pt in [PAWN, KNIGHT, BISHOP, ROOK, QUEEN])
    
    material_diff = white_material - black_material
    
    # Only apply mop-up when winning by a FULL PIECE or more (500+ material)
    # 223 material difference is not enough to apply mop-up
    if material_diff > 500:  # White winning by a lot
        distance = manhattan_distance(white_king, black_king)
        score = (14 - distance) * 5  # Reward closer kings (reduced from 8)
        
        # Drive black king to edge
        black_file, black_rank = black_king.index() % 8, black_king.index() // 8
        black_edge_dist = min(black_file, 7 - black_file, black_rank, 7 - black_rank)
        score += (3 - black_edge_dist) * 7  # Reduced from 11
        return score  # Removed * 3 multiplier - was way too strong!
        
    elif material_diff < -500:  # Black winning by a lot
        distance = manhattan_distance(white_king, black_king)
        score = -(14 - distance) * 5  # Reduced from 10
        
        # Drive white king to edge
        white_file, white_rank = white_king.index() % 8, white_king.index() // 8
        white_edge_dist = min(white_file, 7 - white_file, white_rank, 7 - white_rank)
        score -= (3 - white_edge_dist) * 7  # Reduced from 20
        return score  # Removed * 3 multiplier
    
    return 0

def tempo(state: bulletchess.Board, phase_weight: float) -> int:
    bonus = int(20 * (1 - phase_weight))
    return bonus if state.turn == WHITE else -bonus

def piece_mobility(state: bulletchess.Board, color: bulletchess.Color) -> int:
    """
    Evaluate piece mobility - simplified version.
    Counts legal moves for each piece type.
    """
    # This is expensive, so we'll use a simplified heuristic
    # Just count pieces that are well-placed (not on back rank for minors)
    sign = 1 if color == WHITE else -1
    mobility = 0
    
    # Knights off back rank
    knights = state[color, KNIGHT]
    for sq in knights:
        rank = sq.index() // 8
        back_rank = 0 if color == WHITE else 7
        if rank != back_rank:
            mobility += 2  # Knight developed
    
    # Bishops off back rank
    bishops = state[color, BISHOP]
    for sq in bishops:
        rank = sq.index() // 8
        back_rank = 0 if color == WHITE else 7
        if rank != back_rank:
            mobility += 2  # Bishop developed
    
    return sign * mobility

def piece_development(state: bulletchess.Board, phase_weight: float) -> int:
    """
    Reward piece development in opening - get pieces off back rank.
    Only matters in opening phase.
    """
    if phase_weight > 0.3:
        return 0
    
    score = 0
    
    # White development - penalize minor pieces on back rank (rank 0)
    for sq in state[WHITE, KNIGHT]:
        if sq.index() // 8 == 0:  # On rank 1 (index 0-7)
            score -= 9
    
    for sq in state[WHITE, BISHOP]:
        if sq.index() // 8 == 0:
            score -= 9
    
    # Black development - penalize minor pieces on back rank (rank 7)
    for sq in state[BLACK, KNIGHT]:
        if sq.index() // 8 == 7:  # On rank 8 (index 56-63)
            score += 9  # Penalty for black
    
    for sq in state[BLACK, BISHOP]:
        if sq.index() // 8 == 7:
            score += 9
    
    # Scale with phase
    return int(score * phase_weight)

def center_control(state: bulletchess.Board) -> int:
    """
    Reward control of central squares (d4, e4, d5, e5).
    This encourages better positional play.
    """
    # We'll check if pawns are in center by checking the bitboards
    score = 0
    
    # Just reward having more pawns advanced
    white_pawns = state[WHITE, PAWN]
    black_pawns = state[BLACK, PAWN]
    
    for sq in white_pawns:
        rank = sq.index() // 8
        file = sq.index() % 8
        # Pawns on files d,e (3,4) and ranks 4-5 (3-4)
        if file in [3, 4] and rank in [3, 4]:
            score += 10  # Central pawn
    
    for sq in black_pawns:
        rank = sq.index() // 8
        file = sq.index() % 8
        if file in [3, 4] and rank in [3, 4]:
            score -= 10  # Black central pawn
    
    return score

def rook_on_open_file(state: bulletchess.Board, color: bulletchess.Color) -> int:
    """
    Reward rooks on open or semi-open files.
    """
    sign = 1 if color == WHITE else -1
    bonus = 0
    
    rooks = state[color, ROOK]
    for rook_sq in rooks:
        file = rook_sq.index() % 8
        
        # Check if file is open (no pawns)
        has_own_pawn = False
        has_enemy_pawn = False
        
        # Check all pawns to see if any are on this file
        for pawn_sq in state[color, PAWN]:
            if pawn_sq.index() % 8 == file:
                has_own_pawn = True
                break
        
        for pawn_sq in state[color.opposite, PAWN]:
            if pawn_sq.index() % 8 == file:
                has_enemy_pawn = True
                break
        
        if not has_own_pawn and not has_enemy_pawn:
            bonus += 35  # Open file
        elif not has_own_pawn and has_enemy_pawn:
            bonus += 20  # Semi-open file
    
    return sign * bonus

def evaluate_position(state: bulletchess.Board) -> float:
    phase_weight = get_game_phase(state)
    # Core evaluation
    score = compute_pst_and_material(state, phase_weight)

    # Tempo bonus
    score += tempo(state, phase_weight)
    
    # King safety (only in opening/middlegame)
    score += king_safety(state, WHITE, phase_weight)
    score += king_safety(state, BLACK, phase_weight)
    
    # Pawn structure
    score += passed_pawn_bonus(state, phase_weight)
    score += isolated_pawn_penalty(state, phase_weight)
    
    # Endgame specific
    score += mop_up_eval(state, phase_weight)
    
    # Positional factors (more important in middlegame)
    if phase_weight <= 0.7:  # Opening/Middlegame
        score += piece_mobility(state, WHITE) - piece_mobility(state, BLACK)
        score += piece_development(state, phase_weight)
        score += center_control(state)
        score += rook_on_open_file(state, WHITE)
        score += rook_on_open_file(state, BLACK)
    
    return score if state.turn == WHITE else -score