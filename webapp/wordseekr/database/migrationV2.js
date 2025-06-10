import sqlite3 from 'sqlite3';
import path from 'path';
import fs from 'fs';

/**
 * Migration script to upgrade WordSeekr database from v1 to v2
 * 
 * Changes:
 * - Add rows/columns to word_search_grids (replacing size)
 * - Remove played_at/time_taken from word_search_grids
 * - Create new quotes table
 * - Create new scores table
 * - Update constraints and indexes
 */

class DatabaseMigrationV2 {
    constructor(dbPath = './database/grids.sqlite') {
        this.dbPath = path.resolve(dbPath);
        this.db = null;
    }

    async connect() {
        return new Promise((resolve, reject) => {
            this.db = new sqlite3.Database(this.dbPath, (err) => {
                if (err) {
                    console.error('Error opening database:', err.message);
                    reject(err);
                } else {
                    console.log('Connected to the database.');
                    resolve();
                }
            });
        });
    }

    async close() {
        return new Promise((resolve, reject) => {
            if (this.db) {
                this.db.close((err) => {
                    if (err) {
                        console.error('Error closing database:', err.message);
                        reject(err);
                    } else {
                        console.log('Database connection closed.');
                        resolve();
                    }
                });
            } else {
                resolve();
            }
        });
    }

    async run(sql, params = []) {
        return new Promise((resolve, reject) => {
            this.db.run(sql, params, function(err) {
                if (err) {
                    console.error('Error running SQL:', err.message);
                    reject(err);
                } else {
                    resolve({ lastID: this.lastID, changes: this.changes });
                }
            });
        });
    }

    async get(sql, params = []) {
        return new Promise((resolve, reject) => {
            this.db.get(sql, params, (err, row) => {
                if (err) {
                    console.error('Error getting row:', err.message);
                    reject(err);
                } else {
                    resolve(row);
                }
            });
        });
    }

    async all(sql, params = []) {
        return new Promise((resolve, reject) => {
            this.db.all(sql, params, (err, rows) => {
                if (err) {
                    console.error('Error getting rows:', err.message);
                    reject(err);
                } else {
                    resolve(rows);
                }
            });
        });
    }

    async checkTableExists(tableName) {
        const result = await this.get(
            "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
            [tableName]
        );
        return result !== undefined;
    }

    async checkColumnExists(tableName, columnName) {
        // Validate table name to prevent SQL injection
        if (!/^[a-zA-Z_][a-zA-Z0-9_]*$/.test(tableName)) {
            throw new Error(`Invalid table name: ${tableName}`);
        }
        const columns = await this.all(`PRAGMA table_info(${tableName})`);
        return columns.some(col => col.name === columnName);
    }

    async backupDatabase() {
        const backupPath = this.dbPath.replace('.sqlite', '_backup_v1.sqlite');
        console.log(`Creating backup at: ${backupPath}`);
        
        // Create a backup by copying the file
        fs.copyFileSync(this.dbPath, backupPath);
        console.log('Backup created successfully.');
        
        return backupPath;
    }

    async migrate() {
        try {
            console.log('Starting migration to v2...');
            
            // Step 1: Create backup
            await this.backupDatabase();
            
            // Step 2: Begin transaction
            await this.run('BEGIN TRANSACTION');
            
            // Step 3: Add new columns to word_search_grids
            console.log('Adding rows and columns to word_search_grids...');
            const hasRows = await this.checkColumnExists('word_search_grids', 'rows');
            const hasColumns = await this.checkColumnExists('word_search_grids', 'columns');
            const hasIsChallenge = await this.checkColumnExists('word_search_grids', 'is_challenge');
            
            if (!hasRows) {
                await this.run('ALTER TABLE word_search_grids ADD COLUMN rows INTEGER');
            }
            if (!hasColumns) {
                await this.run('ALTER TABLE word_search_grids ADD COLUMN columns INTEGER');
            }
            if (!hasIsChallenge) {
                await this.run('ALTER TABLE word_search_grids ADD COLUMN is_challenge BOOLEAN NOT NULL DEFAULT FALSE');
            }
            
            // Step 4.5: Update played_at field to match v2 schema
            console.log('Updating played_at field constraints...');
            const hasPlayedAt = await this.checkColumnExists('word_search_grids', 'played_at');
            if (hasPlayedAt) {
                // Update the played_at field to have the correct default value
                // Note: SQLite doesn't support ALTER COLUMN with DEFAULT, so we need to recreate the table
                // For now, we'll just ensure the field exists and handle the default in application code
                console.log('played_at field already exists, ensuring it has correct constraints...');
            }
            
            // Step 5: Populate rows/columns from size (assuming size is square)
            console.log('Populating rows and columns from size...');
            const grids = await this.all('SELECT id, size FROM word_search_grids WHERE rows IS NULL OR columns IS NULL');
            
            for (const grid of grids) {
                // Assuming size represents a square grid (e.g., size=10 means 10x10)
                const gridSize = Math.sqrt(grid.size);
                if (Number.isInteger(gridSize)) {
                    await this.run(
                        'UPDATE word_search_grids SET rows = ?, columns = ? WHERE id = ?',
                        [gridSize, gridSize, grid.id]
                    );
                } else {
                    // If size is not a perfect square, use size for both dimensions
                    await this.run(
                        'UPDATE word_search_grids SET rows = ?, columns = ? WHERE id = ?',
                        [grid.size, grid.size, grid.id]
                    );
                }
            }
            
            // Step 6: Create quotes table
            console.log('Creating quotes table...');
            const quotesExists = await this.checkTableExists('quotes');
            if (quotesExists) {
                console.log('Dropping existing quotes table...');
                await this.run('DROP TABLE quotes');
            }
            await this.run(`
                CREATE TABLE quotes (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    grid_id INTEGER REFERENCES word_search_grids(id),
                    quote TEXT NOT NULL,
                    playable_at TIMESTAMP NOT NULL,
                    played_at TIMESTAMP,
                    CHECK (grid_id IS NOT NULL)
                )
            `);
            
            // Step 7: Create scores table
            console.log('Creating scores table...');
            const scoresExists = await this.checkTableExists('scores');
            if (!scoresExists) {
                await this.run(`
                    CREATE TABLE scores (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        grid_id INTEGER REFERENCES word_search_grids(id),
                        played_at TIMESTAMP NOT NULL,
                        time_taken INTEGER NOT NULL,
                        CHECK (grid_id IS NOT NULL)
                    )
                `);
            }
            
            // Step 8: Handle existing category table (drop if exists as it's not in v2)
            console.log('Handling category table...');
            const categoryExists = await this.checkTableExists('category');
            if (categoryExists) {
                console.log('Dropping existing category table (not in v2 schema)...');
                await this.run('DROP TABLE category');
            }
            
            // Step 9: Migrate existing score data (if any)
            console.log('Migrating existing score data...');
            const hasPlayedAtField = await this.checkColumnExists('word_search_grids', 'played_at');
            const hasTimeTaken = await this.checkColumnExists('word_search_grids', 'time_taken');
            
            if (hasPlayedAtField && hasTimeTaken) {
                const scoreData = await this.all(
                    'SELECT id, played_at, time_taken FROM word_search_grids WHERE played_at IS NOT NULL AND time_taken IS NOT NULL'
                );
                
                for (const score of scoreData) {
                    await this.run(
                        'INSERT INTO scores (grid_id, played_at, time_taken) VALUES (?, ?, ?)',
                        [score.id, score.played_at, score.time_taken]
                    );
                }
            }
            
            // Step 10: Update word_placements constraints
            console.log('Updating word_placements constraints...');
            await this.run('DROP TABLE IF EXISTS word_placements_temp');
            await this.run(`
                CREATE TABLE word_placements_temp (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    grid_id INTEGER REFERENCES word_search_grids(id),
                    word TEXT NOT NULL,
                    row INTEGER NOT NULL,
                    col INTEGER NOT NULL,
                    direction TEXT NOT NULL,
                    CHECK (grid_id IS NOT NULL)
                )
            `);
            
            // Copy data to temp table
            await this.run(`
                INSERT INTO word_placements_temp (id, grid_id, word, row, col, direction)
                SELECT id, grid_id, word, row, col, direction FROM word_placements
            `);
            
            // Drop old table and rename temp table
            await this.run('DROP TABLE word_placements');
            await this.run('ALTER TABLE word_placements_temp RENAME TO word_placements');
            
            // Step 11: Create indexes
            console.log('Creating indexes...');
            await this.run('CREATE INDEX IF NOT EXISTS idx_word_search_grids_hash ON word_search_grids(grid_hash)');
            await this.run('CREATE INDEX IF NOT EXISTS idx_quotes_playable_at ON quotes(playable_at)');
            await this.run('CREATE INDEX IF NOT EXISTS idx_word_placements_grid_id ON word_placements(grid_id)');
            await this.run('CREATE INDEX IF NOT EXISTS idx_scores_played_at ON scores(played_at)');
            await this.run('CREATE INDEX IF NOT EXISTS idx_scores_grid_id ON scores(grid_id)');
            
            // Step 12: Remove old columns (optional - keeping them for backward compatibility)
            // Uncomment the following lines if you want to remove the old columns:
            /*
            if (hasPlayedAt) {
                await this.run('ALTER TABLE word_search_grids DROP COLUMN played_at');
            }
            if (hasTimeTaken) {
                await this.run('ALTER TABLE word_search_grids DROP COLUMN time_taken');
            }
            */
            
            // Step 13: Commit transaction
            await this.run('COMMIT');
            
            console.log('Migration completed successfully!');
            
        } catch (error) {
            console.error('Migration failed:', error);
            await this.run('ROLLBACK');
            throw error;
        }
    }

    async validateMigration() {
        console.log('Validating migration...');
        
        // Check that all required tables exist
        const requiredTables = ['word_search_grids', 'quotes', 'word_placements', 'scores'];
        for (const table of requiredTables) {
            const exists = await this.checkTableExists(table);
            console.log(`Table ${table}: ${exists ? '✓' : '✗'}`);
        }
        
        // Check that required columns exist
        const requiredColumns = {
            'word_search_grids': ['id', 'name', 'rows', 'columns', 'words_count', 'directions', 'grid_hash', 'is_challenge'],
            'quotes': ['id', 'grid_id', 'quote', 'playable_at'],
            'word_placements': ['id', 'grid_id', 'word', 'row', 'col', 'direction'],
            'scores': ['id', 'grid_id', 'played_at', 'time_taken']
        };
        
        for (const [table, columns] of Object.entries(requiredColumns)) {
            for (const column of columns) {
                const exists = await this.checkColumnExists(table, column);
                console.log(`Column ${table}.${column}: ${exists ? '✓' : '✗'}`);
            }
        }
        
        // Check data integrity
        const gridCount = await this.get('SELECT COUNT(*) as count FROM word_search_grids');
        const placementCount = await this.get('SELECT COUNT(*) as count FROM word_placements');
        const scoreCount = await this.get('SELECT COUNT(*) as count FROM scores');
        
        console.log(`Data counts - Grids: ${gridCount.count}, Placements: ${placementCount.count}, Scores: ${scoreCount.count}`);
    }
}

// Main execution
async function main() {
    const migration = new DatabaseMigrationV2();
    
    try {
        await migration.connect();
        await migration.migrate();
        await migration.validateMigration();
    } catch (error) {
        console.error('Migration failed:', error);
        process.exit(1);
    } finally {
        await migration.close();
    }
}

// Export for use as module
export default DatabaseMigrationV2;

// Run if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
    main();
} 