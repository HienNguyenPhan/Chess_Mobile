from typing import Dict, Tuple, Optional
from datetime import datetime, timedelta
import bulletchess
from chess_engine import clear_transposition_table

# store all ongoing sessions with last access time
sessions: Dict[str, Tuple[bulletchess.Board, datetime]] = {}
# Track resigned/manually ended games
resigned_games: Dict[str, str] = {}  # session_id -> winner ('white' or 'black')
SESSION_TTL = timedelta(hours=2)  # Sessions expire after 2 hours of inactivity

def cleanup_old_sessions():
    """Remove sessions that haven't been accessed recently."""
    now = datetime.now()
    expired = [sid for sid, (_, last_access) in sessions.items() 
               if now - last_access > SESSION_TTL]
    for sid in expired:
        del sessions[sid]

def get_or_create_board(session_id: str) -> bulletchess.Board:
    # Periodically cleanup old sessions (every 100th call)
    import random
    if random.randint(1, 100) == 1:
        cleanup_old_sessions()
    
    if session_id not in sessions:
        board = bulletchess.Board()
        sessions[session_id] = (board, datetime.now())
    else:
        board, _ = sessions[session_id]
        # Update last access time
        sessions[session_id] = (board, datetime.now())
    
    return board

def apply_move(session_id: str, move_uci: str) -> bulletchess.Board:
    board = get_or_create_board(session_id)
    move = bulletchess.Move.from_uci(move_uci)
    board.apply(move)
    # Update last access time
    if session_id in sessions:
        old_board, _ = sessions[session_id]
        sessions[session_id] = (old_board, datetime.now())
    return board

def reset_board(session_id: str):
    board = bulletchess.Board()
    sessions[session_id] = (board, datetime.now())
    # Clear resignation status when starting new game
    if session_id in resigned_games:
        del resigned_games[session_id]
    # Clear transposition table to avoid hash collisions from previous games
    clear_transposition_table()

def get_fen(session_id: str) -> str:
    return get_or_create_board(session_id).fen()

def mark_game_resigned(session_id: str, winner: str):
    """Mark a game as resigned with the specified winner."""
    resigned_games[session_id] = winner

def is_game_resigned(session_id: str) -> Optional[str]:
    """Check if game is resigned. Returns winner ('white'/'black') or None."""
    return resigned_games.get(session_id)