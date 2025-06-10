-- WordSeekr Database Schema
-- This file contains the complete database structure for the WordSeekr word search game

-- ============================================================================
-- MAIN TABLES
-- ============================================================================

-- Word Search Grids - Main word search puzzles
CREATE TABLE word_search_grids (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    size INTEGER NOT NULL,
    words_count INTEGER NOT NULL,
    directions TEXT NOT NULL,
    grid_hash TEXT UNIQUE,  -- Ensures uniqueness of the grid structure
);


-- Word placements within puzzles
CREATE TABLE word_placements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    grid_id INTEGER REFERENCES word_search_grids(id),
    word TEXT NOT NULL,
    row INTEGER NOT NULL,
    col INTEGER NOT NULL,
    direction TEXT NOT NULL,
    CHECK ((grid_id IS NOT NULL AND quote_id IS NULL) OR (grid_id IS NULL AND quote_id IS NOT NULL))
);

-- ============================================================================
-- FOREIGN KEY RELATIONSHIPS
-- ============================================================================

-- Foreign key from category to word_search_grids
-- grid_id -> word_search_grids.id (CASCADE delete)

-- Foreign keys from word_placements
-- grid_id -> word_search_grids.id (NO ACTION)
-- quote_id -> quotes.id (NO ACTION)

-- ============================================================================
-- FIELD DESCRIPTIONS
-- ============================================================================

/*
word_search_grids:
- id: Primary key, auto-incrementing
- name: Name/title of the word search puzzle
- size: Size of the grid (appears to be a single dimension)
- words_count: Number of words in the puzzle
- directions: Allowed directions for word placement (e.g., "horizontal,vertical,diagonal")
- grid_hash: Unique hash to ensure grid structure uniqueness
- played_at: Timestamp when the puzzle was completed (nullable)
- time_taken: Time taken to complete the puzzle in seconds (nullable)

category:
- id: Primary key, auto-incrementing
- name: Category name
- grid_id: Foreign key to word_search_grids.id (CASCADE delete)

quotes:
- id: Primary key, auto-incrementing
- name: Name/title of the quote puzzle
- rows: Number of rows in the grid
- columns: Number of columns in the grid
- directions: Allowed directions for word placement
- filler_letters: Filler letters used in the grid (nullable)
- placed_words: JSON or serialized data of placed words
- grid_data: The actual grid data
- created_at: Timestamp when the quote was created

word_placements:
- id: Primary key, auto-incrementing
- grid_id: Foreign key to word_search_grids.id (nullable)
- quote_id: Foreign key to quotes.id (nullable)
- word: The actual word text
- row: Starting row position (0-based)
- col: Starting column position (0-based)
- direction: Direction of the word (e.g., "horizontal", "vertical", "diagonal")
*/

-- ============================================================================
-- CONSTRAINTS
-- ============================================================================

-- The word_placements table has a CHECK constraint ensuring that either
-- grid_id OR quote_id is set, but not both. This allows the table to
-- reference either word_search_grids or quotes, but not both simultaneously.

-- ============================================================================
-- FUTURE EXTENSIONS (Referenced in TypeScript types)
-- ============================================================================

/*
The following tables are referenced in the TypeScript types but not yet implemented
in the database schema. They may be added in future versions:

- themes: For organizing puzzles by themes
- theme_categories: Junction table linking themes and categories
- listings: For word lists
- listing_words: Words within a listing
- insertion_rules: For puzzle generation rules
- grid_insertion_rules: Junction table linking grids and rules
- levels: For difficulty levels
*/ 