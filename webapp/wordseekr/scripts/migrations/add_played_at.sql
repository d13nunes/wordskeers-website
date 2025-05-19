-- Add played_at column to word_search_grids table
ALTER TABLE word_search_grids ADD COLUMN time_taken INTEGER DEFAULT NULL; 
ALTER TABLE word_search_grids ADD COLUMN played_at TIMESTAMP DEFAULT NULL; 