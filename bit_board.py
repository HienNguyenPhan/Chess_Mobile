import random
from typing import Optional

# -----------------------------
# Constants and Setup
# -----------------------------
WHITE, BLACK = 0, 1
PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING = range(6)

RANK_1, RANK_2, RANK_7, RANK_8 = 0xFF, 0xFF00, 0xFF000000000000, 0xFF00000000000000
A_FILE, H_FILE = 0x0101010101010101, 0x8080808080808080

# Precompute bit masks
BB_SQUARES = [1 << i for i in range(64)]

# Directions for knights, kings
KNIGHT_DELTAS = [17, 15, 10, 6, -17, -15, -10, -6]
KING_DELTAS = [1, -1, 8, -8, 9, 7, -9, -7]

# Random Zobrist keys
_rng = random.Random(987654321)
ZOBRIST_PIECE = [[[ _rng.getrandbits(64) for _ in range(64)] for _ in range(6)] for _ in range(2)]
ZOBRIST_BLACK_TO_MOVE = _rng.getrandbits(64)
ZOBRIST_CASTLING = [_rng.getrandbits(64) for _ in range(16)]
ZOBRIST_EP_FILE = [_rng.getrandbits(64) for _ in range(8)]

MATERIAL = [100, 320, 330, 500, 900, 0]

# -----------------------------
# Utility functions
# -----------------------------
def bit_scan_forward(bb):
    return (bb & -bb).bit_length() - 1

def pop_lsb(bb):
    idx = bit_scan_forward(bb)
    bb &= bb - 1
    return bb, idx

def bit_scan(bb):
    while bb:
        bb, sq = pop_lsb(bb)
        yield sq

def shift(bb, direction):
    if direction == 8:   # up
        return (bb << 8) & 0xFFFFFFFFFFFFFFFF
    if direction == -8:  # down
        return (bb >> 8) & 0xFFFFFFFFFFFFFFFF
    if direction == 7:   # down-left
        return (bb >> 7) & ~A_FILE
    if direction == 9:   # down-right
        return (bb >> 9) & ~H_FILE
    if direction == -7:  # up-right
        return (bb << 7) & ~H_FILE
    if direction == -9:  # up-left
        return (bb << 9) & ~A_FILE
    return 0


# -----------------------------
# Main Bitboard Class
# -----------------------------
class BitboardState:
    __slots__ = ("bitboards", "side_to_move", "castling_rights", "en_passant",
                 "zobrist_key", "history")

    def __init__(self):
        self.bitboards = [[0] * 6 for _ in range(2)]
        self.side_to_move = WHITE
        self.castling_rights = 0b1111  # KQkq
        self.en_passant = None
        self.zobrist_key = 0
        self.halfmove_clock = 0
        self.position_history = {}
        self.history = []

    # -------------------------
    # Setup
    # -------------------------
    def set_startpos(self):
        """Set standard chess start position."""
        self.bitboards[WHITE][PAWN] = 0x000000000000FF00
        self.bitboards[BLACK][PAWN] = 0x00FF000000000000
        self.bitboards[WHITE][KNIGHT] = 0x0000000000000042
        self.bitboards[BLACK][KNIGHT] = 0x4200000000000000
        self.bitboards[WHITE][BISHOP] = 0x0000000000000024
        self.bitboards[BLACK][BISHOP] = 0x2400000000000000
        self.bitboards[WHITE][ROOK] = 0x0000000000000081
        self.bitboards[BLACK][ROOK] = 0x8100000000000000
        self.bitboards[WHITE][QUEEN] = 0x0000000000000008
        self.bitboards[BLACK][QUEEN] = 0x0800000000000000
        self.bitboards[WHITE][KING] = 0x0000000000000010
        self.bitboards[BLACK][KING] = 0x1000000000000000

        self.side_to_move = WHITE
        self.castling_rights = 0b1111
        self.en_passant = None
        self.zobrist_key = self.compute_zobrist()
        self.history.clear()

    # -------------------------
    # Occupancy
    # -------------------------
    def occupied(self):
        return self.occupied_color(WHITE) | self.occupied_color(BLACK)

    def occupied_color(self, color):
        bb = 0
        for p in range(6):
            bb |= self.bitboards[color][p]
        return bb

    def empty(self):
        return ~self.occupied() & 0xFFFFFFFFFFFFFFFF

    # -------------------------
    # Zobrist Hashing
    # -------------------------
    def compute_zobrist(self):
        h = 0
        for color in (WHITE, BLACK):
            for p in range(6):
                bb = self.bitboards[color][p]
                while bb:
                    bb, sq = pop_lsb(bb)
                    h ^= ZOBRIST_PIECE[color][p][sq]
        if self.side_to_move == BLACK:
            h ^= ZOBRIST_BLACK_TO_MOVE
        h ^= ZOBRIST_CASTLING[self.castling_rights]
        if self.en_passant is not None:
            h ^= ZOBRIST_EP_FILE[self.en_passant % 8]
        return h
    
    # -------------------------
    # Make/Unmake Move
    # -------------------------
    def make_move(self, move):
        from_sq, to_sq, ptype, promo = move
        us, them = self.side_to_move, 1 - self.side_to_move
        captured_piece = None
        prev_ep = self.en_passant
        prev_castling = self.castling_rights
        
        # Reset halfmove clock
        if ptype == PAWN or any(self.bitboards[them][pt] & BB_SQUARES[to_sq] for pt in range(6)):
            self.halfmove_clock = 0
        else:
            self.halfmove_clock += 1

        if self.en_passant is not None:
            self.zobrist_key ^= ZOBRIST_EP_FILE[self.en_passant % 8]
        self.en_passant = None

        self.zobrist_key ^= ZOBRIST_PIECE[us][ptype][from_sq]

        for cap_type in range(6):
            if self.bitboards[them][cap_type] & BB_SQUARES[to_sq]:
                captured_piece = cap_type
                self.bitboards[them][cap_type] &= ~BB_SQUARES[to_sq]
                self.zobrist_key ^= ZOBRIST_PIECE[them][cap_type][to_sq]
                break
        
        if ptype == PAWN and to_sq == prev_ep:
            if us == WHITE:
                cap_sq = to_sq + 8
            else:
                cap_sq = to_sq - 8
            for cap_type in range(6):
                if self.bitboards[them][cap_type] & BB_SQUARES[cap_sq]:
                    captured_piece = cap_type
                    self.bitboards[them][cap_type] &= ~BB_SQUARES[cap_sq]
                    self.zobrist_key ^= ZOBRIST_PIECE[them][cap_type][cap_sq]
                    break

        self.bitboards[us][ptype] &= ~BB_SQUARES[from_sq]
        if promo is not None:
            self.bitboards[us][promo] |= BB_SQUARES[to_sq]
            self.zobrist_key ^= ZOBRIST_PIECE[us][promo][to_sq]
        else:
            self.bitboards[us][ptype] |= BB_SQUARES[to_sq]
            self.zobrist_key ^= ZOBRIST_PIECE[us][ptype][to_sq]

        # Handle castling rights
        if ptype == KING:
            if us == WHITE:
                self.castling_rights &= 0b0011
                # Castling move rook
                if from_sq == 4 and to_sq == 6:  # O-O
                    self.bitboards[WHITE][ROOK] &= ~BB_SQUARES[7]
                    self.bitboards[WHITE][ROOK] |= BB_SQUARES[5]
                elif from_sq == 4 and to_sq == 2:  # O-O-O
                    self.bitboards[WHITE][ROOK] &= ~BB_SQUARES[0]
                    self.bitboards[WHITE][ROOK] |= BB_SQUARES[3]
            else:
                self.castling_rights &= 0b1100
                if from_sq == 60 and to_sq == 62:
                    self.bitboards[BLACK][ROOK] &= ~BB_SQUARES[63]
                    self.bitboards[BLACK][ROOK] |= BB_SQUARES[61]
                elif from_sq == 60 and to_sq == 58:
                    self.bitboards[BLACK][ROOK] &= ~BB_SQUARES[56]
                    self.bitboards[BLACK][ROOK] |= BB_SQUARES[59]

        # Handle pawn double push → set en passant
        if ptype == PAWN:
            if abs(from_sq - to_sq) == 16:
                self.en_passant = (from_sq + to_sq) // 2
                self.zobrist_key ^= ZOBRIST_EP_FILE[self.en_passant % 8]

        # Update castling Zobrist if changed
        if self.castling_rights != prev_castling:
            self.zobrist_key ^= ZOBRIST_CASTLING[prev_castling]
            self.zobrist_key ^= ZOBRIST_CASTLING[self.castling_rights]

        # Flip side to move
        self.side_to_move ^= 1
        self.zobrist_key ^= ZOBRIST_BLACK_TO_MOVE

        # Save undo info
        self.position_history.append(self.zobrist_key)
        self.history.append((move, captured_piece, prev_ep, prev_castling, self.zobrist_key))

    def unmake_move(self):
        """Undo last move."""
        move, captured_piece, prev_ep, prev_castling, prev_zob = self.history.pop()
        from_sq, to_sq, ptype, promo = move
        us = 1 - self.side_to_move
        them = 1 - us

        # Restore hash
        self.zobrist_key = prev_zob

        # Restore castling/en passant
        self.castling_rights = prev_castling
        self.en_passant = prev_ep

        self.position_history.pop()

        # Undo piece movement
        if promo is not None:
            self.bitboards[us][promo] &= ~BB_SQUARES[to_sq]
            self.bitboards[us][PAWN] |= BB_SQUARES[from_sq]
        else:
            self.bitboards[us][ptype] &= ~BB_SQUARES[to_sq]
            self.bitboards[us][ptype] |= BB_SQUARES[from_sq]

        # Restore captured piece
        if captured_piece is not None:
            self.bitboards[them][captured_piece] |= BB_SQUARES[to_sq]

        # Undo castling rook movement
        if ptype == KING:
            if us == WHITE:
                if from_sq == 4 and to_sq == 6:  # O-O
                    self.bitboards[WHITE][ROOK] &= ~BB_SQUARES[5]
                    self.bitboards[WHITE][ROOK] |= BB_SQUARES[7]
                elif from_sq == 4 and to_sq == 2:  # O-O-O
                    self.bitboards[WHITE][ROOK] &= ~BB_SQUARES[3]
                    self.bitboards[WHITE][ROOK] |= BB_SQUARES[0]
            else:
                if from_sq == 60 and to_sq == 62:
                    self.bitboards[BLACK][ROOK] &= ~BB_SQUARES[61]
                    self.bitboards[BLACK][ROOK] |= BB_SQUARES[63]
                elif from_sq == 60 and to_sq == 58:
                    self.bitboards[BLACK][ROOK] &= ~BB_SQUARES[59]
                    self.bitboards[BLACK][ROOK] |= BB_SQUARES[56]

        # Flip side back
        self.side_to_move = us

    # -------------------------
    # Move Generation
    # -------------------------
    def generate_pseudo_legal_moves(self):
        """Generate all simple moves (pawns, sliders, knights, king, promotions, captures, castling)."""
        moves = []
        us, them = self.side_to_move, 1 - self.side_to_move
        occ = self.occupied()
        empty = self.empty()

        # -----------------
        # Pawn pushes/captures
        # -----------------
        pawn_bb = self.bitboards[us][PAWN]
        if us == WHITE:
            # single push
            single_push = shift(pawn_bb, -8) & empty
            for to_sq in bitscan(single_push):
                from_sq = to_sq + 8
                if BB_SQUARES[to_sq] & RANK_8:
                    # promotions
                    for promo in [QUEEN, ROOK, BISHOP, KNIGHT]:
                        moves.append((from_sq, to_sq, PAWN, promo))
                else:
                    moves.append((from_sq, to_sq, PAWN, None))

            # captures
            left = shift(pawn_bb, -9) & self.occupied_color(them) & ~H_FILE
            right = shift(pawn_bb, -7) & self.occupied_color(them) & ~A_FILE
            for to_sq in bitscan(left | right):
                from_sq = to_sq + (9 if (BB_SQUARES[to_sq] & left) else 7)
                if BB_SQUARES[to_sq] & RANK_8:
                    for promo in [QUEEN, ROOK, BISHOP, KNIGHT]:
                        moves.append((from_sq, to_sq, PAWN, promo))
                else:
                    moves.append((from_sq, to_sq, PAWN, None))
        else:
            # black pawns
            single_push = shift(pawn_bb, 8) & empty
            for to_sq in bitscan(single_push):
                from_sq = to_sq - 8
                if BB_SQUARES[to_sq] & RANK_1:
                    for promo in [QUEEN, ROOK, BISHOP, KNIGHT]:
                        moves.append((from_sq, to_sq, PAWN, promo))
                else:
                    moves.append((from_sq, to_sq, PAWN, None))

            left = shift(pawn_bb, 9) & self.occupied_color(them) & ~H_FILE
            right = shift(pawn_bb, 7) & self.occupied_color(them) & ~A_FILE
            for to_sq in bitscan(left | right):
                from_sq = to_sq - (9 if (BB_SQUARES[to_sq] & left) else 7)
                if BB_SQUARES[to_sq] & RANK_1:
                    for promo in [QUEEN, ROOK, BISHOP, KNIGHT]:
                        moves.append((from_sq, to_sq, PAWN, promo))
                else:
                    moves.append((from_sq, to_sq, PAWN, None))

        # En passant (simplified)
        if self.en_passant is not None:
            ep_sq = self.en_passant
            if us == WHITE:
                attack_mask = shift(pawn_bb, -7) | shift(pawn_bb, -9)
            else:
                attack_mask = shift(pawn_bb, 7) | shift(pawn_bb, 9)
            if attack_mask & BB_SQUARES[ep_sq]:
                from_sq = ep_sq + (8 if us == WHITE else -8)
                moves.append((from_sq, ep_sq, PAWN, None))

        # -----------------
        # Knights & Kings
        # -----------------
        moves.extend(generate_leaper_moves(self, KNIGHT))
        moves.extend(generate_leaper_moves(self, KING))

        # -----------------
        # Sliding Pieces (Rook, Bishop, Queen)
        # -----------------
        moves.extend(generate_slider_moves(self, BISHOP))
        moves.extend(generate_slider_moves(self, ROOK))
        moves.extend(generate_slider_moves(self, QUEEN))

        # -----------------
        # Castling
        # -----------------
        if us == WHITE:
            if self.castling_rights & 0b1000 and not (occ & 0x0000000000000060):
                moves.append((4, 6, KING, None))
            if self.castling_rights & 0b0100 and not (occ & 0x000000000000000E):
                moves.append((4, 2, KING, None))
        else:
            if self.castling_rights & 0b0010 and not (occ & 0x6000000000000000):
                moves.append((60, 62, KING, None))
            if self.castling_rights & 0b0001 and not (occ & 0x0E00000000000000):
                moves.append((60, 58, KING, None))

        return moves

    # ===============================
    # King safety / legality handling
    # ===============================
    def attacks_to_square(self, sq: int, attacker_color: int) -> int:
        """Return bitboard of pieces of attacker_color that attack the given square."""
        attacks = 0
        occ = self.occupied()
        # Pawn attacks
        if attacker_color == WHITE:
            if sq % 8 != 0:  # not file a
                attacks |= (self.bitboards[WHITE][PAWN] >> 7) & BB_SQUARES[sq]
            if sq % 8 != 7:  # not file h
                attacks |= (self.bitboards[WHITE][PAWN] >> 9) & BB_SQUARES[sq]
        else:
            if sq % 8 != 7:
                attacks |= (self.bitboards[BLACK][PAWN] << 7) & BB_SQUARES[sq]
            if sq % 8 != 0:
                attacks |= (self.bitboards[BLACK][PAWN] << 9) & BB_SQUARES[sq]

        # Knight attacks
        attacks |= self.knight_attacks(attacker_color) & BB_SQUARES[sq]

        # King attacks
        attacks |= self.king_attacks(attacker_color) & BB_SQUARES[sq]

        # Sliding attacks (rough but functional)
        attacks |= self.sliding_attacks(attacker_color, sq, occ)

        return attacks

    def sliding_attacks(self, color: int, sq: int, occ: int) -> int:
        """Return bitboard of sliding pieces of `color` that attack `sq`."""
        attacks = 0
        dirs = [8, -8, 1, -1, 9, 7, -9, -7]
        for d in dirs:
            s = sq
            while True:
                s += d
                if s < 0 or s > 63:
                    break
                # stop if wrapped around files
                if abs((s % 8) - (sq % 8)) > 2 and d in (1, -1, 9, -9, 7, -7):
                    break
                bb = BB_SQUARES[s]
                if occ & bb:
                    # piece here
                    for ptype in [ROOK, BISHOP, QUEEN]:
                        if self.bitboards[color][ptype] & bb:
                            # rook or bishop can only attack in their directions
                            if ptype == ROOK and d in (8, -8, 1, -1):
                                attacks |= bb
                            elif ptype == BISHOP and d in (9, 7, -9, -7):
                                attacks |= bb
                            elif ptype == QUEEN:
                                attacks |= bb
                    break
        return attacks

    def is_in_check(self, color: Optional[int] = None) -> bool:
        """True if `color` (or side-to-move if None) is currently in check."""
        if color is None:
            color = self.side_to_move
        king_bb = self.bitboards[color][KING]
        if not king_bb:
            return False
        king_sq = (king_bb.bit_length() - 1)
        opp = 1 - color
        occ = self.occupied()
        # brute-force check
        # check pawn, knight, bishop/rook/queen, king attacks
        # quick pawn check
        if color == WHITE:
            pawn_attacks = ((self.bitboards[BLACK][PAWN] << 7) & ~0x0101010101010101) | \
                           ((self.bitboards[BLACK][PAWN] << 9) & ~0x8080808080808080)
            if pawn_attacks & king_bb:
                return True
        else:
            pawn_attacks = ((self.bitboards[WHITE][PAWN] >> 7) & ~0x8080808080808080) | \
                           ((self.bitboards[WHITE][PAWN] >> 9) & ~0x0101010101010101)
            if pawn_attacks & king_bb:
                return True

        # Knights
        k_sq = king_sq
        for delta in [6, 10, 15, 17, -6, -10, -15, -17]:
            s = k_sq + delta
            if 0 <= s < 64 and abs((s % 8) - (k_sq % 8)) <= 2:
                if self.bitboards[opp][KNIGHT] & BB_SQUARES[s]:
                    return True

        # King proximity
        for delta in [1, -1, 8, -8, 7, 9, -7, -9]:
            s = k_sq + delta
            if 0 <= s < 64 and abs((s % 8) - (k_sq % 8)) <= 1:
                if self.bitboards[opp][KING] & BB_SQUARES[s]:
                    return True

        # Sliding (rays)
        occ = self.occupied()
        dirs = [(8, ROOK), (-8, ROOK), (1, ROOK), (-1, ROOK),
                (9, BISHOP), (7, BISHOP), (-9, BISHOP), (-7, BISHOP)]
        for d, piece_type in dirs:
            s = k_sq
            while True:
                s += d
                if s < 0 or s > 63:
                    break
                if abs((s % 8) - (k_sq % 8)) > 2 and d in (1, -1, 9, -9, 7, -7):
                    break
                bb = BB_SQUARES[s]
                if occ & bb:
                    # found piece
                    if self.bitboards[opp][QUEEN] & bb:
                        return True
                    if piece_type == ROOK and self.bitboards[opp][ROOK] & bb:
                        return True
                    if piece_type == BISHOP and self.bitboards[opp][BISHOP] & bb:
                        return True
                    break
        return False

    def generate_legal_moves(self):
        """Generate only legal moves (those that do not leave own king in check)."""
        legal_moves = []
        for mv in self.generate_pseudo_legal_moves():
            self.make_move(mv)
            if not self.is_in_check(1 - self.side_to_move):
                legal_moves.append(mv)
            self.unmake_move()
        return legal_moves
    
    def draw_detection(self):
        """Simple draw detection: 50-move rule and threefold repetition."""
        if self.halfmove_clock >= 100:
            return True
        if self.position_history.get(self.zobrist_key, 0) >= 3:
            return True
        return False



# -----------------------------
# Move Generation Helpers
# -----------------------------
def bitscan(bb):
    while bb:
        bb, sq = pop_lsb(bb)
        yield sq


def generate_leaper_moves(board: BitboardState, piece_type: int):
    moves = []
    us, them = board.side_to_move, 1 - board.side_to_move
    deltas = KNIGHT_DELTAS if piece_type == KNIGHT else KING_DELTAS
    bb = board.bitboards[us][piece_type]
    occ_us = board.occupied_color(us)
    for from_sq in bitscan(bb):
        for d in deltas:
            to_sq = from_sq + d
            if 0 <= to_sq < 64 and abs((to_sq % 8) - (from_sq % 8)) <= (2 if piece_type == KNIGHT else 1):
                if not (occ_us & BB_SQUARES[to_sq]):
                    moves.append((from_sq, to_sq, piece_type, None))
    return moves


def generate_slider_moves(board: BitboardState, piece_type: int):
    """Basic sliding move generation (rook/bishop/queen)."""
    moves = []
    us = board.side_to_move
    occ = board.occupied()
    occ_us = board.occupied_color(us)
    directions = []
    if piece_type == ROOK:
        directions = [8, -8, 1, -1]
    elif piece_type == BISHOP:
        directions = [9, 7, -7, -9]
    else:  # queen
        directions = [8, -8, 1, -1, 9, 7, -7, -9]

    bb = board.bitboards[us][piece_type]
    for from_sq in bitscan(bb):
        for d in directions:
            to_sq = from_sq
            while True:
                to_sq += d
                if to_sq < 0 or to_sq >= 64 or abs((to_sq % 8) - (from_sq % 8)) > 7:
                    break
                moves.append((from_sq, to_sq, piece_type, None))
                if BB_SQUARES[to_sq] & occ:
                    break
    return moves
