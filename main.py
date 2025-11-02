from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional, Dict, Any
import bulletchess
from bulletchess import CHECKMATE, DRAW, CHECK
from chess_engine import get_best_move_and_eval
from engine_state import (
    apply_move, get_or_create_board, reset_board, sessions,
    mark_game_resigned, is_game_resigned
)
from opening_book import get_opening_move, load_book
from puzzle_manager import (
    load_puzzles, create_puzzle_session, get_session as get_puzzle_session,
    delete_session as delete_puzzle_session
)
import uuid

# Load opening book and puzzles at startup
load_book()
load_puzzles()

app = FastAPI()

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def check_game_status(board: bulletchess.Board, session_id: str) -> Dict[str, Any]:
    """
    Check if the game has ended and return status information.
    
    Args:
        board: The chess board to check
        session_id: The session ID to check for resignation
    
    Returns:
        dict with keys:
        - game_over: bool
        - result: str ('win', 'lose', 'draw', None)
        - reason: str (checkmate, stalemate, insufficient_material, etc.)
        - winner: str ('white', 'black', None)
    """
    # First check if the game was resigned
    winner = is_game_resigned(session_id)
    if winner:
        return {
            "game_over": True,
            "result": "win",  # Consistent: win/draw not descriptive strings
            "reason": "resignation",
            "winner": winner,
            "in_check": board in CHECK
        }
    
    status = {
        "game_over": False,
        "result": None,
        "reason": None,
        "winner": None,
        "in_check": board in CHECK
    }
    
    # Check for checkmate
    if board in CHECKMATE:
        status["game_over"] = True
        status["reason"] = "checkmate"
        status["result"] = "win"  # Consistent with other game endings
        # The side to move is checkmated (they lost)
        status["winner"] = "black" if board.turn == bulletchess.WHITE else "white"
        return status
    
    # Check for draw conditions
    if board in DRAW:
        status["game_over"] = True
        status["result"] = "draw"
        status["winner"] = None
        
        # Determine specific draw reason
        if not list(board.legal_moves()):
            status["reason"] = "stalemate"
        elif board.is_insufficient_material():
            status["reason"] = "insufficient_material"
        elif board.can_claim_fifty_move_rule():
            status["reason"] = "fifty_move_rule"
        elif board.can_claim_threefold_repetition():
            status["reason"] = "threefold_repetition"
        else:
            status["reason"] = "draw"
        
        return status
    
    # Game is still ongoing
    return status

class MoveRequest(BaseModel):
    session_id: str
    move_uci: str
    # If true, server will immediately compute and apply the bot's reply after the player's move
    auto_bot_response: bool = False
    # Time limit (seconds) to use for the bot move when auto_bot_response is true
    bot_time_limit: float = 5.0

class NewGameRequest(BaseModel):
    session_id: str
    bot_first: bool = False

class BotMoveRequest(BaseModel):
    session_id: str
    time_limit: float = 5.0

class HistoryRequest(BaseModel):
    session_id: str

@app.post("/bot_move")
def bot_move(req: BotMoveRequest):
    try:
        # Validate time_limit
        if req.time_limit <= 0:
            raise HTTPException(status_code=400, detail="time_limit must be positive")
        if req.time_limit > 60:
            raise HTTPException(status_code=400, detail="time_limit cannot exceed 60 seconds")
        
        board = get_or_create_board(req.session_id)
        
        # Check if game is already over
        status = check_game_status(board, req.session_id)
        if status["game_over"]:
            return {
                "error": "Game is already over",
                "game_status": status,
                "fen": board.fen(),
                "session_id": req.session_id,
            }
        
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
            # No legal moves - game is over
            status = check_game_status(board, req.session_id)
            return {
                "error": "No legal moves available",
                "game_status": status,
                "fen": board.fen(),
                "session_id": req.session_id,
            }
        
        move = bulletchess.Move.from_uci(best_move_uci)
        board.apply(move)
        
        # Check game status after bot's move
        status = check_game_status(board, req.session_id)
        
        response = {
            "best_move": best_move_uci,
            "evaluation": eval_score,
            "from_book": from_book,
            "fen": board.fen(),
            "game_status": status,
            "session_id": req.session_id,
        }
        
        # Add user-friendly message if game ended
        if status["game_over"]:
            if status["reason"] == "checkmate":
                response["message"] = f"Checkmate! {status['winner'].capitalize()} wins!"
            elif status["reason"] == "stalemate":
                response["message"] = "Draw by stalemate"
            else:
                response["message"] = f"Draw by {status['reason'].replace('_', ' ')}"
        
        return response
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@app.post("/get_history")
def get_history(req: HistoryRequest):
    try:
        board = get_or_create_board(req.session_id)
        history = board.history    
        return {
            "history": history,
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
                best_move_uci, eval_score = get_best_move_and_eval(board, time_limit=5.0)
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
        board = get_or_create_board(req.session_id)
        
        # Check if game is already over
        status = check_game_status(board, req.session_id)
        if status["game_over"]:
            return {
                "error": "Game is already over",
                "game_status": status,
                "fen": board.fen(),
                "session_id": req.session_id,
            }
        
        # Apply the player's move
        board = apply_move(req.session_id, req.move_uci)

        # Check game status after player's move
        status = check_game_status(board, req.session_id)

        response = {
            "fen": board.fen(),
            "game_status": status,
            "session_id": req.session_id
        }

        # Add user-friendly message if game ended after player's move
        if status["game_over"]:
            if status["reason"] == "checkmate":
                response["message"] = f"Checkmate! {status['winner'].capitalize()} wins!"
            elif status["reason"] == "stalemate":
                response["message"] = "Draw by stalemate"
            else:
                response["message"] = f"Draw by {status['reason'].replace('_', ' ')}"

            return response

        # If requested, compute and apply the bot's reply immediately
        if req.auto_bot_response:
            # Validate time limit for bot move
            if req.bot_time_limit <= 0:
                raise HTTPException(status_code=400, detail="bot_time_limit must be positive")
            if req.bot_time_limit > 60:
                raise HTTPException(status_code=400, detail="bot_time_limit cannot exceed 60 seconds")

            # Try opening book first
            book_move = get_opening_move(board, random_choice=True)

            if book_move:
                bot_move_uci = book_move
                bot_eval = 0.0
                bot_from_book = True
            else:
                bot_move_uci, bot_eval = get_best_move_and_eval(board, time_limit=req.bot_time_limit)
                bot_from_book = False

            if not bot_move_uci:
                # No legal bot move available (game may be over)
                status = check_game_status(board, req.session_id)
                response.update({
                    "bot_error": "No legal bot moves available",
                    "game_status": status,
                    "fen": board.fen()
                })
                return response

            # Apply bot move
            bot_move = bulletchess.Move.from_uci(bot_move_uci)
            board.apply(bot_move)

            # Check game status after bot move
            status_after_bot = check_game_status(board, req.session_id)

            # Attach bot move details to response
            response.update({
                "bot_move": bot_move_uci,
                "bot_evaluation": bot_eval,
                "bot_from_book": bot_from_book,
                "fen": board.fen(),
                "game_status": status_after_bot,
            })

            # Friendly end-game message if bot ended the game
            if status_after_bot["game_over"]:
                if status_after_bot["reason"] == "checkmate":
                    response["message"] = f"Checkmate! {status_after_bot['winner'].capitalize()} wins!"
                elif status_after_bot["reason"] == "stalemate":
                    response["message"] = "Draw by stalemate"
                else:
                    response["message"] = f"Draw by {status_after_bot['reason'].replace('_', ' ')}"

        return response
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/session/{session_id}")
def delete_session(session_id: str):
    """Delete a session to free up memory."""
    from engine_state import resigned_games
    
    if session_id in sessions:
        del sessions[session_id]
        # Also clean up resignation status if exists
        if session_id in resigned_games:
            del resigned_games[session_id]
        return {"message": f"Session {session_id} deleted"}
    raise HTTPException(status_code=404, detail="Session not found")

@app.get("/sessions/count")
def get_session_count():
    """Get the current number of active sessions (for monitoring)."""
    return {"active_sessions": len(sessions)}

@app.post("/resign/{session_id}")
def resign_game(session_id: str):
    """
    Resign the current game. The player whose turn it is loses.
    """
    try:
        board = get_or_create_board(session_id)
        status = check_game_status(board, session_id)
        
        if status["game_over"]:
            return {
                "error": "Game is already over",
                "game_status": status,
                "fen": board.fen(),
                "session_id": session_id,
            }
        
        # Determine winner - player resigning loses
        winner = "black" if board.turn == bulletchess.WHITE else "white"
        
        # Mark game as resigned
        mark_game_resigned(session_id, winner)
        
        # Create resignation status
        resignation_status = {
            "game_over": True,
            "result": "resignation",
            "reason": "resignation",
            "winner": winner,
            "in_check": status["in_check"]  # Preserve check status
        }
        
        return {
            "message": f"{winner.capitalize()} wins by resignation",
            "fen": board.fen(),
            "game_status": resignation_status,
            "session_id": session_id,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/undo/{session_id}")
def undo_move(session_id: str):
    """
    Undo the last move(s). 
    - In player vs bot: undoes both bot's move and player's move (2 moves)
    - Returns to the position before player's last move
    """
    try:
        board = get_or_create_board(session_id)
        
        # Check if there are moves to undo
        if not board.history:
            return {
                "error": "No moves to undo",
                "fen": board.fen(),
                "session_id": session_id,
            }
        
        # Check if game is over
        status = check_game_status(board, session_id)
        if status["game_over"]:
            # Allow undo even if game is over (to review/continue)
            pass
        
        # Undo 2 moves (bot's move + player's move)
        moves_undone = 0
        max_undo = min(2, len(board.history))
        
        for _ in range(max_undo):
            try:
                board.undo()
                moves_undone += 1
            except:
                break
        
        # Clear resignation status when undoing (game is back in play)
        if is_game_resigned(session_id):
            from engine_state import resigned_games
            del resigned_games[session_id]
        
        # Get updated game status
        status = check_game_status(board, session_id)
        
        return {
            "message": f"Undone {moves_undone} move(s)",
            "moves_undone": moves_undone,
            "fen": board.fen(),
            "game_status": status,
            "session_id": session_id,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ============================================================================
# PUZZLE ENDPOINTS
# ============================================================================

class NewPuzzleRequest(BaseModel):
    session_id: str

class PuzzleMoveRequest(BaseModel):
    session_id: str
    move_uci: str

@app.post("/puzzle/new")
def new_puzzle(req: NewPuzzleRequest):
    """
    Get a new random puzzle.
    """
    try:
        puzzle_data = create_puzzle_session(
            req.session_id, 
        )
        
        
        return {
            "message": "New puzzle started",
            "puzzle_id": puzzle_data['puzzle_id'],
            "fen": puzzle_data['fen'],
            "rating": puzzle_data['rating'],
            "theme_description": puzzle_data.get('theme_description', ''),
            "total_moves": puzzle_data['total_moves'],
            "session_id": req.session_id,
            "moves": puzzle_data['moves']
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/puzzle/move")
def puzzle_move(req: PuzzleMoveRequest):
    """
    Make a move in the current puzzle.
    
    Returns:
    - status: 'correct', 'wrong', 'complete', or 'error'
    - If correct: new FEN and progress
    - If wrong: expected move and current FEN
    - If complete: success message and puzzle rating
    """
    try:
        session = get_puzzle_session(req.session_id)
        
        if session is None:
            raise HTTPException(status_code=404, detail="No active puzzle session. Start a new puzzle first.")
        
        result = session.make_move(req.move_uci)
        result['session_id'] = req.session_id
        
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/puzzle/hint/{session_id}")
def get_hint(session_id: str):
    """
    Get a hint for the current puzzle (shows from-square of next move).
    """
    try:
        session = get_puzzle_session(session_id)
        
        if session is None:
            raise HTTPException(status_code=404, detail="No active puzzle session")
        
        hint = session.get_hint()
        
        if hint is None:
            return {"message": "No hint available"}
        
        return {
            "hint": hint,
            "message": f"Move from square: {hint}",
            "session_id": session_id
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/puzzle/status/{session_id}")
def puzzle_status(session_id: str):
    """Get current puzzle status and progress."""
    try:
        session = get_puzzle_session(session_id)
        
        if session is None:
            raise HTTPException(status_code=404, detail="No active puzzle session")
        
        return {
            "puzzle_id": session.puzzle_id,
            "fen": session.get_current_fen(),
            "rating": session.rating,
            "progress": f"{session.current_move_index}/{len(session.solution_moves)}",
            "completed": session.completed,
            "failed": session.failed,
            "session_id": session_id
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/puzzle/{session_id}")
def delete_puzzle(session_id: str):
    """Delete a puzzle session."""
    try:
        delete_puzzle_session(session_id)
        return {"message": f"Puzzle session {session_id} deleted"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))