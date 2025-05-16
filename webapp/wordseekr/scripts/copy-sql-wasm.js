import { copyFileSync, existsSync, mkdirSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Source and destination paths
const sourceFile = join(__dirname, '../node_modules/sql.js/dist/sql-wasm.wasm');
const destDir = join(__dirname, '../static/assets');
const destFile = join(destDir, 'sql-wasm.wasm');

// Create assets directory if it doesn't exist
if (!existsSync(destDir)) {
    mkdirSync(destDir, { recursive: true });
}

// Copy the file
try {
    copyFileSync(sourceFile, destFile);
    console.log('Successfully copied sql-wasm.wasm to static/assets/');
} catch (err) {
    console.error('Error copying sql-wasm.wasm:', err);
    process.exit(1);
} 