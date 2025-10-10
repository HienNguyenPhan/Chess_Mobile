from typing import Union
from fastapi import FastAPI, HTTPException
from contextlib import asynccontextmanager
from pydantic import BaseModel
import chess
from chess_engine import get_best_move_and_eval
import uuid

# In-memory session storage (use Redis for production)
sessions = {}

class FENInput(BaseModel):
    fen: str
    depth: int = 8
    session_id: str | None = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    yield
    # Clean up the ML models and release the resources
    sessions.clear()

app = FastAPI(lifespan=lifespan)

@app.post("/best_move/")
async def best_move(input_data: FENInput):
    try:
        # Validate inputs
        if input_data.depth < 1 or input_data.depth > 20:
            raise HTTPException(status_code=400, detail="Depth must be 1-20")
        
        # Get or create session
        session_id = input_data.session_id or str(uuid.uuid4())
        board = sessions.get(session_id, chess.Board(input_data.fen))
        
        # Validate FEN
        try:
            chess.Board(input_data.fen)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid FEN")
        
        # Get best move and evaluation
        best_move, eval_score = get_best_move_and_eval(board, input_data.depth)
        
        # Update session
        board_copy = board.copy()
        board_copy.push(best_move)
        sessions[session_id] = board_copy
        
        return {
            "best_move": str(best_move),
            "evaluation": eval_score,
            "fen": board.fen(),
            "session_id": session_id
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
