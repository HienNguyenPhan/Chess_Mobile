from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import chess
from chess_engine import get_best_move_and_eval, clear_transposition_table
import uuid

app = FastAPI()

class FENInput(BaseModel):
    fen: str
    depth: int = 8
    session_id: str | None = None

@app.post("/best_move/")
async def best_move(input_data: FENInput):
    try:
        # Validate inputs
        if input_data.depth < 1 or input_data.depth > 20:
            raise HTTPException(status_code=400, detail="Depth must be 1-20")
        
        # Use provided FEN
        try:
            board = chess.Board(input_data.fen)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid FEN")
        
        # Clear transposition table to avoid stale cache
        clear_transposition_table()
        
        # Generate session ID for response
        session_id = input_data.session_id or str(uuid.uuid4())
        
        # Get best move and evaluation
        best_move, eval_score = get_best_move_and_eval(board, input_data.depth)
        
        # Update board for response
        board_copy = board.copy()
        board_copy.push(best_move)
        
        return {
            "best_move": str(best_move),
            "evaluation": eval_score,
            "fen": board_copy.fen(),
            "session_id": session_id
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
