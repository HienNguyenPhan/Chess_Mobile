from fastapi import FastAPI
from pydantic import BaseModel
from chess_engine import get_best_move_and_eval
from engine_state import apply_move, get_or_create_board, reset_board

app = FastAPI()

class MoveRequest(BaseModel):
    session_id: str
    move_uci: str

class NewGameRequest(BaseModel):
    session_id: str
    bot_first: bool = False

class BotMoveRequest(BaseModel):
    session_id: str
    time_limit: float = 3.0

@app.post("/bot_move")
def bot_move(req: BotMoveRequest):
    board = get_or_create_board(req.session_id)
    best_move, eval_score = get_best_move_and_eval(board, time_limit=req.time_limit)
    board.push(best_move)
    return {
        "best_move": best_move.uci() if best_move else None,
        "evaluation": eval_score,
        "fen": board.fen(),
        "session_id": req.session_id,
    }

@app.post("/new_game")
def new_game(req: NewGameRequest):
    reset_board(req.session_id)
    board = get_or_create_board(req.session_id)

    best_move, eval = None, None
    if req.bot_first:
        best_move, eval = get_best_move_and_eval(board, time_limit=3.0)
        if best_move:
            board.push(best_move)
    return {
        "message": "New game started",
        "fen": board.fen(),
        "best_move": best_move.uci() if best_move else None,
        "evaluation": eval,
        "session_id": req.session_id,
    }

@app.post("/move")
def player_move(req: MoveRequest):
    board = apply_move(req.session_id, req.move_uci)
    return {"fen": board.fen(), "session_id": req.session_id}
