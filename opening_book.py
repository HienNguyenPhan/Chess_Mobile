"""
Polyglot opening book reader for chess engine.
Reads .bin files in polyglot format and provides opening moves.

Note: This implementation uses python-chess for proper Polyglot hash compatibility,
then converts moves to bulletchess format.
"""
import struct
import random
from typing import List, Optional, Tuple
import bulletchess
from pathlib import Path

try:
    import chess
    import chess.polyglot
    HAS_PYTHON_CHESS = True
except ImportError:
    HAS_PYTHON_CHESS = False
    print("Warning: python-chess not installed. Opening book will not work.")
    print("Install with: pip install python-chess")


class PolyglotBook:
    """Reader for polyglot opening book format using python-chess."""
    
    def __init__(self, book_path: str):
        if not HAS_PYTHON_CHESS:
            raise ImportError("python-chess is required for opening book support")
        
        self.book_path = Path(book_path)
        if not self.book_path.exists():
            raise FileNotFoundError(f"Opening book not found: {book_path}")
        
        # Open the polyglot reader
        self.reader = chess.polyglot.open_reader(str(self.book_path))
    
    def _bulletchess_to_python_chess(self, board: bulletchess.Board) -> chess.Board:
        """Convert bulletchess Board to python-chess Board."""
        fen = board.fen()
        return chess.Board(fen)
    
    def _python_chess_move_to_uci(self, move: chess.Move) -> str:
        """Convert python-chess Move to UCI string."""
        return move.uci()
    
    def get_book_move(self, board: bulletchess.Board, random_choice: bool = True) -> Optional[str]:
        """
        Get a move from the opening book.
        
        Args:
            board: Current board position (bulletchess)
            random_choice: If True, randomly select weighted by frequency.
                          If False, always pick the most common move.
        
        Returns:
            UCI string of the book move, or None if position not in book
        """
        try:
            # Convert to python-chess board
            pc_board = self._bulletchess_to_python_chess(board)
            
            # Get all entries for this position
            entries = list(self.reader.find_all(pc_board))
            
            if not entries:
                return None
            
            if random_choice:
                # Weighted random selection based on weight
                choice = self.reader.weighted_choice(pc_board)
                return choice.move.uci() if choice else None
            else:
                # Return highest weighted move
                best_entry = max(entries, key=lambda e: e.weight)
                return best_entry.move.uci()
        
        except Exception as e:
            # Position not in book or error
            return None
    
    def is_in_book(self, board: bulletchess.Board) -> bool:
        """Check if the current position is in the opening book."""
        try:
            pc_board = self._bulletchess_to_python_chess(board)
            entries = list(self.reader.find_all(pc_board))
            return len(entries) > 0
        except:
            return False
    
    def get_all_book_moves(self, board: bulletchess.Board) -> List[Tuple[str, int]]:
        """Get all book moves with their weights for the current position."""
        try:
            pc_board = self._bulletchess_to_python_chess(board)
            entries = list(self.reader.find_all(pc_board))
            return [(entry.move.uci(), entry.weight) for entry in entries]
        except:
            return []
    
    def close(self):
        """Close the book reader."""
        if hasattr(self, 'reader'):
            self.reader.close()
    
    def __del__(self):
        """Cleanup on deletion."""
        self.close()


# Global book instance
_book_instance = None

def load_book(book_path: str = "data/Perfect2023.bin") -> PolyglotBook:
    """Load the opening book (singleton)."""
    global _book_instance
    if _book_instance is None:
        try:
            _book_instance = PolyglotBook(book_path)
            print(f"Opening book loaded: {book_path}")
        except Exception as e:
            print(f"Failed to load opening book: {e}")
            _book_instance = None
    return _book_instance

def get_opening_move(board: bulletchess.Board, random_choice: bool = True) -> Optional[str]:
    """
    Convenience function to get an opening move from the book.
    
    Args:
        board: Current position
        random_choice: If True, randomly choose weighted by popularity
    
    Returns:
        UCI move string or None if not in book
    """
    book = load_book()
    if book:
        return book.get_book_move(board, random_choice)
    return None
