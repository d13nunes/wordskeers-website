import { copyFileSync, existsSync, mkdirSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);


// Source and destination paths
const sourceFile = join(__dirname, '../../../../wordseerk-generator/data/game.sqlite');
console.log('sourceFile', sourceFile);
const destDir = join(__dirname, '../database');
const destFile = join(destDir, '/grids.sqlite');

// Create assets directory if it doesn't exist
if (!existsSync(destDir)) {
    mkdirSync(destDir, { recursive: true });
}

// Copy the file
try {
    copyFileSync(sourceFile, destFile);
    console.log(`Successfully copied ${sourceFile} to ${destFile}`);
} catch (err) {
    console.error('Error copying database:', err);
    process.exit(1);
} 