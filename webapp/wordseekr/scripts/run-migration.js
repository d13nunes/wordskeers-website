import { join } from 'path';
import { existsSync, readFileSync } from 'fs';
import sqlite3 from 'sqlite3';
import { fileURLToPath } from 'url';

const { Database } = sqlite3;
const __dirname = fileURLToPath(new URL('.', import.meta.url));
const sourceFile = join(__dirname, '../database/grids.sqlite');
const migrationFile = join(__dirname, 'migrations/add_played_at.sql');

if (!existsSync(sourceFile)) {
    console.error('Database file not found:', sourceFile);
    process.exit(1);
}

if (!existsSync(migrationFile)) {
    console.error('Migration file not found:', migrationFile);
    process.exit(1);
}

const db = new Database(sourceFile);
const migration = readFileSync(migrationFile, 'utf8');

console.log('Running migration...');
db.serialize(() => {
    db.run(migration, (err) => {
        if (err) {
            console.error('Error running migration:', err);
            process.exit(1);
        }
        console.log('Migration completed successfully');
        db.close();
    });
}); 