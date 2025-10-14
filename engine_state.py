import chess
from typing import Dict

# store all ongoing sessions
sessions: Dict[str, chess.Board] = {}

def get_or_create_board(session_id: str) -> chess.Board:
    if session_id not in sessions:
        sessions[session_id] = chess.Board()
    return sessions[session_id]

def apply_move(session_id: str, move_uci: str) -> chess.Board:
    board = get_or_create_board(session_id)
    move = chess.Move.from_uci(move_uci)
    if move in board.legal_moves:
        board.push(move)
    else:
        raise ValueError(f"Illegal move: {move_uci}")
    return board

def reset_board(session_id: str):
    sessions[session_id] = chess.Board()

def get_fen(session_id: str) -> str:
    return get_or_create_board(session_id).fen()
