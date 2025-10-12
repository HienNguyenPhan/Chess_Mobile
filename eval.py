import chess

# Material values (centipawns)
material_values = {
    chess.PAWN: 100,
    chess.KNIGHT: 320,
    chess.BISHOP: 330,
    chess.ROOK: 500,
    chess.QUEEN: 900,
    chess.KING: 0
}

# Piece-square tables (opening/endgame, mirrored for black)
piece_square_tables = {
    chess.PAWN: {
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
    chess.KNIGHT: {
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
    chess.BISHOP: {
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
    chess.ROOK: {
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
    chess.QUEEN: {
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
    chess.KING: {
        'opening': [
            -30,-40,-40,-50,-50,-40,-40,-30,
            -30,-40,-40,-50,-50,-40,-40,-30,
            -30,-40,-40,-50,-50,-40,-40,-30,
            -30,-40,-40,-50,-50,-40,-40,-30,
            -20,-30,-30,-40,-40,-30,-30,-20,
            -10,-20,-20,-20,-20,-20,-20,-10,
             10, 10,  0,  0,  0,  0, 10, 10,
             20, 30, 10,  0,  0, 10, 30, 20
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

def get_game_phase(board: chess.Board) -> float:
    """Return game phase (0=endgame, 1=opening) based on material."""
    total_material = 0
    for piece_type in [chess.KNIGHT, chess.BISHOP, chess.ROOK, chess.QUEEN]:
        total_material += len(board.pieces(piece_type, chess.WHITE)) * material_values[piece_type]
        total_material += len(board.pieces(piece_type, chess.BLACK)) * material_values[piece_type]
    # Max material (2 knights, 2 bishops, 2 rooks, 1 queen per side) = 2*(320*2 + 330*2 + 500*2 + 900) = 3920
    return min(total_material / 3920, 1.0)

def evaluate_position(board: chess.Board) -> float:
    """Evaluate position using HCE (positive for White, negative for Black)."""
    if board.is_checkmate():
        return -32000.0 if board.turn == chess.WHITE else 32000.0
    if board.is_stalemate() or board.is_insufficient_material():
        return 0.0

    score = 0.0
    phase = get_game_phase(board)
    
    # Material and PST
    for color in [chess.WHITE, chess.BLACK]:
        sign = 1 if color == chess.WHITE else -1
        for piece_type in chess.PIECE_TYPES:
            for sq in board.pieces(piece_type, color):
                # Material
                score += sign * material_values[piece_type]
                # PST (interpolate between opening and endgame)
                op_score = piece_square_tables[piece_type]['opening'][sq if color == chess.WHITE else 63 - sq]
                eg_score = piece_square_tables[piece_type]['endgame'][sq if color == chess.WHITE else 63 - sq]
                score += sign * (phase * op_score + (1 - phase) * eg_score)
    
    # Mobility (bonus for legal moves, except king)
    for color in [chess.WHITE, chess.BLACK]:
        sign = 1 if color == chess.WHITE else -1
        for piece_type in [chess.KNIGHT, chess.BISHOP, chess.ROOK, chess.QUEEN]:
            for sq in board.pieces(piece_type, color):
                board.push(chess.Move.null())  # Temporarily switch turn
                mobility = len(list(board.legal_moves))
                board.pop()
                score += sign * mobility * 2  # 2 centipawns per move
    
    # King safety (penalty for weak pawn shield)
    for color in [chess.WHITE, chess.BLACK]:
        sign = 1 if color == chess.WHITE else -1
        king_sq = board.king(color)
        if king_sq is None:
            continue
        # Check pawn shield (e.g., pawns in front of king)
        pawn_shield = 0
        if color == chess.WHITE:
            shield_squares = [king_sq + 8, king_sq + 7, king_sq + 9] if king_sq // 8 < 7 else []
        else:
            shield_squares = [king_sq - 8, king_sq - 7, king_sq - 9] if king_sq // 8 > 0 else []
        for sq in shield_squares:
            if board.piece_at(sq) == chess.Piece(chess.PAWN, color):
                pawn_shield += 10
        score += sign * pawn_shield
        # Penalty for checks
        board.push(chess.Move.null())
        if board.is_check():
            score -= sign * 50
        board.pop()
    
    return score if board.turn == chess.WHITE else -score