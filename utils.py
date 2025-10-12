import chess

# Material values (centipawns)
MATERIAL = {
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

PST = {pt: {'opening': ps['opening'], 'endgame': ps['endgame']} for pt, ps in piece_square_tables.items()}

def get_game_phase(board: chess.Board) -> float:
    """Compute normalized phase 1=opening, 0=endgame."""
    total = (
        len(board.pieces(chess.KNIGHT, True)) + len(board.pieces(chess.KNIGHT, False))
    ) * MATERIAL[chess.KNIGHT]
    total += (
        len(board.pieces(chess.BISHOP, True)) + len(board.pieces(chess.BISHOP, False))
    ) * MATERIAL[chess.BISHOP]
    total += (
        len(board.pieces(chess.ROOK, True)) + len(board.pieces(chess.ROOK, False))
    ) * MATERIAL[chess.ROOK]
    total += (
        len(board.pieces(chess.QUEEN, True)) + len(board.pieces(chess.QUEEN, False))
    ) * MATERIAL[chess.QUEEN]
    return min(total / 3920, 1.0)

def evaluate_position(board: chess.Board) -> float:
    """Static evaluation with phase interpolation and basic king safety."""
    if board.is_checkmate():
        return -32000.0 if board.turn == chess.WHITE else 32000.0
    if board.is_stalemate() or board.is_insufficient_material():
        return 0.0

    score = 0.0
    phase = get_game_phase(board)

    # Material + PST
    for color in [chess.WHITE, chess.BLACK]:
        sign = 1 if color == chess.WHITE else -1
        for piece_type in chess.PIECE_TYPES:
            bitboard = board.pieces(piece_type, color)
            for sq in bitboard:
                idx = sq if color == chess.WHITE else 63 - sq
                op = PST[piece_type]['opening'][idx]
                eg = PST[piece_type]['endgame'][idx]
                score += sign * (MATERIAL[piece_type] + phase * op + (1 - phase) * eg)

    # Mobility (non-king)
    original_turn = board.turn
    mobility_score = 0
    for color in [chess.WHITE, chess.BLACK]:
        board.turn = color
        sign = 1 if color == chess.WHITE else -1
        moves = list(board.legal_moves)
        mobility = sum(1 for mv in moves if board.piece_type_at(mv.from_square) != chess.KING)
        mobility_score += sign * mobility * 2
    board.turn = original_turn
    score += mobility_score

    # King safety
    for color in [chess.WHITE, chess.BLACK]:
        king_sq = board.king(color)
        if king_sq is None:
            continue
        if color == chess.WHITE:
            shield = [king_sq + 7, king_sq + 8, king_sq + 9]
        else:
            shield = [king_sq - 7, king_sq - 8, king_sq - 9]
        pawn_shield = sum(
            10 for sq in shield if 0 <= sq < 64 and board.piece_at(sq) == chess.Piece(chess.PAWN, color)
        )
        score += (1 if color == chess.WHITE else -1) * pawn_shield

    if board.is_check():
        score -= 50

    return score if board.turn == chess.WHITE else -score