-- WordSeekr Database Schema v2
-- This file contains the complete database structure for the WordSeekr word search game v2

-- ============================================================================
-- MAIN TABLES
-- ============================================================================

-- Word Search Grids - Main word search puzzles
CREATE TABLE word_search_grids (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    rows INTEGER NOT NULL,
    columns INTEGER NOT NULL,
    words_count INTEGER NOT NULL,
    directions TEXT NOT NULL,
    grid_hash TEXT UNIQUE,  -- Ensures uniqueness of the grid structure
    is_challenge BOOLEAN NOT NULL DEFAULT FALSE,
    played_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Quotes - Quote-based puzzles
CREATE TABLE quotes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    grid_id INTEGER REFERENCES word_search_grids(id),
    author TEXT NOT NULL,
    quote TEXT NOT NULL,
    playable_at TIMESTAMP NOT NULL,
    played_at TIMESTAMP,
    CHECK (grid_id IS NOT NULL)
);

-- Word placements within puzzles
CREATE TABLE word_placements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    grid_id INTEGER REFERENCES word_search_grids(id),
    word TEXT NOT NULL,
    row INTEGER NOT NULL,
    col INTEGER NOT NULL,
    direction TEXT NOT NULL,
    CHECK (grid_id IS NOT NULL)
);


-- Scores for tracking player performance
CREATE TABLE scores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    grid_id INTEGER REFERENCES word_search_grids(id),
    played_at TIMESTAMP NOT NULL,
    time_taken INTEGER NOT NULL
    CHECK (grid_id IS NOT NULL)
);

-- ============================================================================
-- FOREIGN KEY RELATIONSHIPS
-- ============================================================================

-- Foreign keys from word_placements
-- grid_id -> word_search_grids.id (NO ACTION)

-- ============================================================================
-- FIELD DESCRIPTIONS
-- ============================================================================

/*
word_search_grids:
- id: Primary key, auto-incrementing
- name: Name/title of the word search puzzle
- rows: Number of rows in the grid
- columns: Number of columns in the grid
- words_count: Number of words in the puzzle
- directions: Allowed directions for word placement (e.g., "horizontal,vertical,diagonal")
- grid_hash: Unique hash to ensure grid structure uniqueness

quotes:
- id: Primary key, auto-incrementing
- grid_id: Foreign key to word_search_grids.id (nullable)
- quote: Quote text JSON array of objects with text and isHidden properties
- playable_at: Timestamp when the quote becomes playable

word_placements:
- id: Primary key, auto-incrementing
- grid_id: Foreign key to word_search_grids.id (nullable)
- word: The actual word text
- row: Starting row position (0-based)
- col: Starting column position (0-based)
- direction: Direction of the word (e.g., "horizontal", "vertical", "diagonal")

scores:
- id: Primary key, auto-incrementing
- grid_id: Foreign key to word_search_grids.id (nullable)
- played_at: Timestamp when the puzzle was completed
- time_taken: Time taken to complete the puzzle in seconds
*/

-- ============================================================================
-- CONSTRAINTS
-- ============================================================================

-- The word_placements table has a CHECK constraint ensuring that grid_id is set

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Index on grid_hash for fast lookups
CREATE INDEX idx_word_search_grids_hash ON word_search_grids(grid_hash);

-- Index on playable_at for quote scheduling
CREATE INDEX idx_quotes_playable_at ON quotes(playable_at);

-- Indexes on foreign keys for better join performance
CREATE INDEX idx_word_placements_grid_id ON word_placements(grid_id);

-- Index on played_at for score queries
CREATE INDEX idx_scores_played_at ON scores(played_at);

-- ============================================================================
-- RELATIONSHIP SUMMARY
-- ============================================================================

/*
Relationships:
- word_search_grids ||--o{ word_placements : "has"
- quotes ||--o{ word_search_grids : "has"
- scores ||--o{ word_search_grids : "has" (implied through gameplay)

Note: The scores table doesn't have a direct foreign key to word_search_grids
as it appears to be designed to track general gameplay scores. If you need
to track which specific grid was played, consider adding a grid_id column
to the scores table.
*/