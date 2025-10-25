from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import bulletchess
from chess_engine import get_best_move_and_eval
from engine_state import apply_move, get_or_create_board, reset_board, sessions
from opening_book import get_opening_move, load_book

# Load opening book at startup
load_book()

app = FastAPI()

class MoveRequest(BaseModel):
    session_id: str
    move_uci: str

class NewGameRequest(BaseModel):
    session_id: str
    bot_first: bool = False

class BotMoveRequest(BaseModel):
    session_id: str
    time_limit: float = 5.0

@app.post("/bot_move")
def bot_move(req: BotMoveRequest):
    try:
        board = get_or_create_board(req.session_id)
        
        # Try to get move from opening book first
        book_move = get_opening_move(board, random_choice=True)
        
        if book_move:
            # Use book move
            best_move_uci = book_move
            eval_score = 0.0  # Book moves don't have evaluation
            from_book = True
        else:
            # No book move, use engine
            best_move_uci, eval_score = get_best_move_and_eval(board, time_limit=req.time_limit)
            from_book = False
        
        if not best_move_uci:
            return {
                "error": "No legal moves available",
                "fen": board.fen(),
                "session_id": req.session_id,
            }
        
        move = bulletchess.Move.from_uci(best_move_uci)
        board.apply(move)
        
        return {
            "best_move": best_move_uci,
            "evaluation": eval_score,
            "from_book": from_book,
            "fen": board.fen(),
            "session_id": req.session_id,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/new_game")
def new_game(req: NewGameRequest):
    try:
        reset_board(req.session_id)
        board = get_or_create_board(req.session_id)

        best_move_uci, eval_score, from_book = None, None, False
        if req.bot_first:
            # Bot goes first - try opening book with random choice
            book_move = get_opening_move(board, random_choice=True)
            
            if book_move:
                best_move_uci = book_move
                eval_score = 0.0
                from_book = True
            else:
                # Fallback to engine if no book move
                best_move_uci, eval_score = get_best_move_and_eval(board, time_limit=3.0)
                from_book = False
            
            if best_move_uci:
                move = bulletchess.Move.from_uci(best_move_uci)
                board.apply(move)
        
        return {
            "message": "New game started",
            "fen": board.fen(),
            "best_move": best_move_uci,
            "evaluation": eval_score,
            "from_book": from_book,
            "session_id": req.session_id,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/move")
def player_move(req: MoveRequest):
    try:
        board = apply_move(req.session_id, req.move_uci)
        return {"fen": board.fen(), "session_id": req.session_id}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/session/{session_id}")
def delete_session(session_id: str):
    """Delete a session to free up memory."""
    if session_id in sessions:
        del sessions[session_id]
        return {"message": f"Session {session_id} deleted"}
    raise HTTPException(status_code=404, detail="Session not found")

@app.get("/sessions/count")
def get_session_count():
    """Get the current number of active sessions (for monitoring)."""
    return {"active_sessions": len(sessions)}