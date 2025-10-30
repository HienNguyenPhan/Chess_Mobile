import pandas as pd
import random
import xml.etree.ElementTree as ET
from typing import Dict, List, Optional, Tuple
import bulletchess

# Load puzzles at startup
puzzles_df = None
theme_descriptions = {}

def load_theme_descriptions():
    """Load theme descriptions from XML file."""
    global theme_descriptions
    try:
        tree = ET.parse('data/puzzleTheme.xml')
        root = tree.getroot()
        
        # Parse XML to extract theme names and descriptions
        themes = {}
        for string_elem in root.findall('string'):
            name = string_elem.get('name')
            text = string_elem.text
            
            if name and text:
                # Store both the name and description
                if name.endswith('Description'):
                    # This is a description
                    theme_key = name.replace('Description', '')
                    if theme_key not in themes:
                        themes[theme_key] = {}
                    themes[theme_key]['description'] = text
                else:
                    # This is a name
                    if name not in themes:
                        themes[name] = {}
                    themes[name]['name'] = text
        
        theme_descriptions = themes
        print(f"Loaded {len(theme_descriptions)} theme descriptions")
    except Exception as e:
        print(f"Error loading theme descriptions: {e}")
        theme_descriptions = {}

def get_theme_description(theme_tags: str) -> str:
    """
    Convert space-separated theme tags into a readable paragraph.
    
    Args:
        theme_tags: Space-separated theme tags (e.g., "advantage hangingPiece middlegame short")
    
    Returns:
        A formatted paragraph describing the puzzle themes
    """
    if not theme_tags or pd.isna(theme_tags):
        return "A challenging chess puzzle."
    
    if not theme_descriptions:
        load_theme_descriptions()
    
    tags = theme_tags.strip().split()
    descriptions = []
    
    for tag in tags:
        if tag in theme_descriptions:
            theme_info = theme_descriptions[tag]
            name = theme_info.get('name', tag)
            desc = theme_info.get('description', '')
            
            if desc:
                descriptions.append(desc)
    
    if descriptions:
        # Join descriptions into a paragraph
        return ' '.join(descriptions)
    else:
        return f"A puzzle featuring: {', '.join(tags)}."

def load_puzzles():
    """Load puzzles from CSV file."""
    global puzzles_df
    try:
        puzzles_df = pd.read_csv('data/chess_puzzle.csv')
        print(f"Loaded {len(puzzles_df)} puzzles")
        load_theme_descriptions()
    except Exception as e:
        print(f"Error loading puzzles: {e}")
        puzzles_df = None

def get_random_puzzle(min_rating: Optional[int] = None, max_rating: Optional[int] = None) -> Optional[Dict]:
    """
    Get a random puzzle
    Returns:
        Dict with puzzle data
    """
    if puzzles_df is None:
        load_puzzles()
    
    if puzzles_df is None or len(puzzles_df) == 0:
        return None

    # Select random puzzle
    puzzle = puzzles_df.sample(n=1).iloc[0]

    # Parse moves
    moves = puzzle['Moves'].strip().split()
    themes = puzzle['Themes'] if pd.notna(puzzle['Themes']) else ''
    
    return {
        'puzzle_id': puzzle['PuzzleId'],
        'fen': puzzle['FEN'],
        'moves': moves,
        'rating': int(puzzle['Rating']),
        'theme_description': get_theme_description(themes),
        'total_moves': len(moves)
    }

def get_puzzle_by_id(puzzle_id: str) -> Optional[Dict]:
    """Get a specific puzzle by ID."""
    if puzzles_df is None:
        load_puzzles()
    
    if puzzles_df is None:
        return None
    
    puzzle_row = puzzles_df[puzzles_df['PuzzleId'] == puzzle_id]
    
    if len(puzzle_row) == 0:
        return None
    
    puzzle = puzzle_row.iloc[0]
    moves = puzzle['Moves'].strip().split()
    themes = puzzle['Themes'] if pd.notna(puzzle['Themes']) else ''
    
    return {
        'puzzle_id': puzzle['PuzzleId'],
        'fen': puzzle['FEN'],
        'moves': moves,
        'rating': int(puzzle['Rating']),
        'themes': themes,
        'theme_description': get_theme_description(themes),
        'total_moves': len(moves)
    }

class PuzzleSession:
    """Manages an active puzzle session for a user."""
    
    def __init__(self, puzzle_data: Dict):
        self.puzzle_id = puzzle_data['puzzle_id']
        self.initial_fen = puzzle_data['fen']
        self.board = bulletchess.Board.from_fen(puzzle_data['fen'])
        self.solution_moves = puzzle_data['moves']
        self.rating = puzzle_data['rating']
        self.themes = puzzle_data.get('themes', '')
        self.theme_description = puzzle_data.get('theme_description', '')
        
        # Lichess puzzle format: first move is the opponent's move that creates the puzzle
        # Apply it to get to the position where the player needs to find the winning move
        self.current_move_index = 1  # Start at 1 (player's first move)
        if len(self.solution_moves) > 0:
            try:
                opponent_move = bulletchess.Move.from_uci(self.solution_moves[0])
                self.board.apply(opponent_move)
                print(f"[DEBUG] Applied opponent's move: {self.solution_moves[0]}")
            except Exception as e:
                print(f"[ERROR] Could not apply opponent's move {self.solution_moves[0]}: {e}")
                self.current_move_index = 0  # Fallback to original behavior
            
        self.completed = False
        self.failed = False
    
    def get_current_fen(self) -> str:
        """Get current board position."""
        return self.board.fen()
    
    def get_expected_move(self) -> Optional[str]:
        """Get the next expected move in the solution."""
        if self.current_move_index < len(self.solution_moves):
            return self.solution_moves[self.current_move_index]
        return None
    
    def make_move(self, move_uci: str) -> Dict:
        """
        Make a move and check if it's correct.
        
        Returns:
            Dict with result: 'correct', 'wrong', or 'complete'
        """
        if self.completed or self.failed:
            return {
                'status': 'already_finished',
                'message': 'Puzzle already completed or failed'
            }
        
        expected_move = self.get_expected_move()
        
        if expected_move is None:
            return {
                'status': 'error',
                'message': 'No more moves expected'
            }
        
        # Check if move is correct
        if move_uci != expected_move:
            self.failed = True
            return {
                'status': 'wrong',
                'message': 'Incorrect move!',
                'expected_move': expected_move,
                'fen': self.board.fen(),
                'move': expected_move,  # The correct move they should have made
                'progress': f"{self.current_move_index}/{len(self.solution_moves)}"
            }
        
        # Move is correct - apply it
        try:
            move = bulletchess.Move.from_uci(move_uci)
            self.board.apply(move)
            self.current_move_index += 1
        except Exception as e:
            return {
                'status': 'error',
                'message': f'Invalid move: {str(e)}'
            }
        
        # Check if puzzle is complete
        if self.current_move_index >= len(self.solution_moves):
            self.completed = True
            return {
                'status': 'complete',
                'message': 'Puzzle solved! 🎉',
                'fen': self.board.fen(),
                'move': None,
                'rating': self.rating,
                'themes': self.themes,
                'theme_description': self.theme_description
            }
        
        # Move correct but more moves needed - make opponent's move automatically
        opponent_move_uci = self.solution_moves[self.current_move_index]
        try:
            opponent_move = bulletchess.Move.from_uci(opponent_move_uci)
            self.board.apply(opponent_move)
            self.current_move_index += 1
        except Exception as e:
            return {
                'status': 'error',
                'message': f'Error making opponent move: {str(e)}'
            }
        
        # Check again if puzzle is complete after opponent move
        if self.current_move_index >= len(self.solution_moves):
            self.completed = True
            return {
                'status': 'complete',
                'message': 'Puzzle solved! 🎉',
                'fen': self.board.fen(),
                'move': None,
                'rating': self.rating,
                'themes': self.themes,
                'theme_description': self.theme_description
            }
        
        # Get next expected player move
        next_move = self.get_expected_move()
        # Calculate remaining player moves
        remaining_count = len([i for i in range(self.current_move_index, len(self.solution_moves), 2)])
        
        return {
            'status': 'correct',
            'message': 'Correct move! Continue...',
            'fen': self.board.fen(),
            'move': next_move,  # Only the next correct move
            'progress': f"{self.current_move_index}/{len(self.solution_moves)}",
            'moves_remaining': remaining_count
        }
    
    def get_hint(self) -> Optional[str]:
        """Get a hint for the next move."""
        expected_move = self.get_expected_move()
        if expected_move:
            # Return from-square as a hint
            return expected_move[:2]  # e.g., "e2" from "e2e4"
        return None
    
    def reset(self):
        """Reset puzzle to initial position."""
        self.board = bulletchess.Board.from_fen(self.initial_fen)
        # Re-apply opponent's blunder
        if len(self.solution_moves) > 0:
            try:
                opponent_blunder = bulletchess.Move.from_uci(self.solution_moves[0])
                self.board.apply(opponent_blunder)
                self.current_move_index = 1
            except:
                self.current_move_index = 0
        else:
            self.current_move_index = 0
        self.completed = False
        self.failed = False

# Store active puzzle sessions
active_sessions: Dict[str, PuzzleSession] = {}

def create_puzzle_session(session_id: str, min_rating: Optional[int] = None, 
                         max_rating: Optional[int] = None) -> Optional[Dict]:
    """Create a new puzzle session."""
    puzzle_data = get_random_puzzle(min_rating, max_rating)
    
    if puzzle_data is None:
        return None
    
    session = PuzzleSession(puzzle_data)
    active_sessions[session_id] = session
    
    # Calculate total player moves (odd indices: 1, 3, 5...)
    total_player_moves = len([i for i in range(1, len(session.solution_moves), 2)])
    
    return {
        'puzzle_id': puzzle_data['puzzle_id'],
        'fen': session.get_current_fen(),  # Position after opponent's blunder
        'rating': puzzle_data['rating'],
        'total_moves': total_player_moves,  # Number of moves player needs to make
        'move': session.get_expected_move(),  # Only the current correct move
        'theme_description': puzzle_data['theme_description']
    }

def get_session(session_id: str) -> Optional[PuzzleSession]:
    """Get an active puzzle session."""
    return active_sessions.get(session_id)

def delete_session(session_id: str):
    """Delete a puzzle session."""
    if session_id in active_sessions:
        del active_sessions[session_id]
