from typing import Union
from fastapi import FastAPI
from pydantic import BaseModel

from chess_engine import get_bet_move_and_eval
import chess
import chess.engine

app = FastAPI()

class FENInput(BaseModel):
    fen: str
    depth: int = 8
    session_id: str | None = None

@app.post("/best_move/")
async def best_move(input_data: FENInput):
    try:
        board = chess.Board(input_data.fen)
        best_move, eval = get_bet_move_and_eval(board, input_data.depth)
        return {
            "best_move": str(best_move), "evaluation": eval, "fen": board.fen()
        }
    except Exception as e:
        return {"error": str(e)}
