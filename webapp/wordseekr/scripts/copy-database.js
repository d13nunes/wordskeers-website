import { copyFileSync, existsSync, mkdirSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Source and destination paths
const sourceFile = join(__dirname, '../database/grids.sqlite');
console.log('sourceFile', sourceFile);
const destDir = join(__dirname, '../static/assets/databases');
const destFile = join(destDir, 'wordseekr.db');

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