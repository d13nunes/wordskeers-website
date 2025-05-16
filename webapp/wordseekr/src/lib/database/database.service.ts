import { CapacitorSQLite, SQLiteConnection, SQLiteDBConnection } from '@capacitor-community/sqlite';
import { Capacitor } from '@capacitor/core';
import initSqlJs from 'sql.js';
import type { Database as SqlJsDatabase, SqlValue } from 'sql.js';
import { writable, type Writable } from 'svelte/store';
import type {
	WordSearchGrid,
	WordPlacement,
	Category,
	Theme,
	Grid,
	Listing,
	ListingWord
} from './types';

// Database configuration
const DB_NAME = 'wordseekr.db';
const DB_VERSION = 1;

// Platform types
type Platform = 'ios' | 'android' | 'web';

// Database connection types
type DatabaseConnection = SQLiteDBConnection | SqlJsDatabase;

// Database state interface
interface DatabaseState {
	isInitialized: boolean;
	isConnected: boolean;
	error: string | null;
	platform: Platform | null;
}

// Create a writable store for database state
export const databaseState: Writable<DatabaseState> = writable({
	isInitialized: false,
	isConnected: false,
	error: null,
	platform: null
});

class DatabaseService {
	private static instance: DatabaseService;
	private connection: DatabaseConnection | null = null;
	private sqliteConnection: SQLiteConnection | null = null;
	private platform: Platform;

	private constructor() {
		this.platform = this.detectPlatform();
		databaseState.update((state) => ({ ...state, platform: this.platform }));
	}

	public static getInstance(): DatabaseService {
		if (!DatabaseService.instance) {
			DatabaseService.instance = new DatabaseService();
		}
		return DatabaseService.instance;
	}

	private detectPlatform(): Platform {
		if (Capacitor.isNativePlatform()) {
			return Capacitor.getPlatform() as Platform;
		}
		return 'web';
	}

	public async initialize(): Promise<void> {
		try {
			if (this.platform === 'web') {
				await this.initializeWebDatabase();
			} else {
				await this.initializeNativeDatabase();
			}

			databaseState.update((state) => ({
				...state,
				isInitialized: true,
				isConnected: true,
				error: null
			}));
		} catch (error) {
			const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
			databaseState.update((state) => ({
				...state,
				isInitialized: false,
				isConnected: false,
				error: errorMessage
			}));
			throw error;
		}
	}

	private async initializeWebDatabase(): Promise<void> {
		try {
			// Initialize SQL.js
			const SQL = await initSqlJs({
				locateFile: (file: string) => `/assets/${file}` // Add type annotation for file parameter
			});

			// Create a new database
			this.connection = new SQL.Database();

			// Initialize schema
			await this.initializeSchema();
		} catch (error) {
			throw new Error(
				`Failed to initialize web database: ${error instanceof Error ? error.message : 'Unknown error'}`
			);
		}
	}

	private async initializeNativeDatabase(): Promise<void> {
		try {
			this.sqliteConnection = new SQLiteConnection(CapacitorSQLite);

			// Copy the database from assets if it doesn't exist
			await CapacitorSQLite.copyFromAssets({});

			// Now create the connection as usual
			const db = await this.sqliteConnection.createConnection(
				DB_NAME,
				false,
				'no-encryption',
				DB_VERSION,
				false
			);

			await db.open();
			this.connection = db;
			await this.initializeSchema();
		} catch (error) {
			throw new Error(
				`Failed to initialize native database: ${error instanceof Error ? error.message : 'Unknown error'}`
			);
		}
	}

	private async initializeSchema(): Promise<void> {
		// TODO: Implement schema initialization
		// This will be implemented based on your specific database schema requirements
		const schema = `
            -- Add your table creation SQL here
            -- Example:
            -- CREATE TABLE IF NOT EXISTS games (
            --     id INTEGER PRIMARY KEY AUTOINCREMENT,
            --     title TEXT NOT NULL,
            --     created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            -- );
        `;

		if (this.platform === 'web') {
			(this.connection as SqlJsDatabase).exec(schema);
		} else {
			await (this.connection as SQLiteDBConnection).execute(schema);
		}
	}

	public async close(): Promise<void> {
		try {
			if (this.connection) {
				if (this.platform === 'web') {
					(this.connection as SqlJsDatabase).close();
				} else {
					await (this.connection as SQLiteDBConnection).close();
					if (this.sqliteConnection) {
						await this.sqliteConnection.closeConnection(DB_NAME, false);
					}
				}
				this.connection = null;
			}

			databaseState.update((state) => ({
				...state,
				isConnected: false
			}));
		} catch (error) {
			throw new Error(
				`Failed to close database: ${error instanceof Error ? error.message : 'Unknown error'}`
			);
		}
	}

	// Example CRUD methods (to be implemented based on your specific needs)
	public async executeQuery<T>(query: string, params: SqlValue[] = []): Promise<T[]> {
		if (!this.connection) {
			throw new Error('Database not initialized');
		}

		try {
			if (this.platform === 'web') {
				const db = this.connection as SqlJsDatabase;
				const stmt = db.prepare(query);
				stmt.bind(params);
				const results: T[] = [];
				while (stmt.step()) {
					results.push(stmt.getAsObject() as T);
				}
				stmt.free();
				return results;
			} else {
				const db = this.connection as SQLiteDBConnection;
				const result = await db.query(query, params);
				return result.values as T[];
			}
		} catch (error) {
			throw new Error(
				`Query execution failed: ${error instanceof Error ? error.message : 'Unknown error'}`
			);
		}
	}

	// Word Search Grid methods
	public async getWordSearchGrids(): Promise<WordSearchGrid[]> {
		return this.executeQuery<WordSearchGrid>('SELECT * FROM word_search_grids');
	}

	public async getWordSearchGridById(id: number): Promise<WordSearchGrid | null> {
		const results = await this.executeQuery<WordSearchGrid>(
			'SELECT * FROM word_search_grids WHERE id = ?',
			[id]
		);
		return results[0] || null;
	}

	public async getWordPlacements(gridId: number): Promise<WordPlacement[]> {
		return this.executeQuery<WordPlacement>('SELECT * FROM word_placements WHERE grid_id = ?', [
			gridId
		]);
	}

	// Theme methods
	public async getThemes(): Promise<Theme[]> {
		return this.executeQuery<Theme>('SELECT * FROM themes ORDER BY name');
	}

	public async getThemeById(id: number): Promise<Theme | null> {
		const results = await this.executeQuery<Theme>('SELECT * FROM themes WHERE id = ?', [id]);
		return results[0] || null;
	}

	// Category methods
	public async getCategories(): Promise<Category[]> {
		return this.executeQuery<Category>('SELECT * FROM categories ORDER BY name');
	}

	public async getCategoriesByTheme(themeId: number): Promise<Category[]> {
		return this.executeQuery<Category>(
			'SELECT * FROM categories WHERE theme_id = ? ORDER BY name',
			[themeId]
		);
	}

	// Listing methods
	public async getListings(): Promise<Listing[]> {
		return this.executeQuery<Listing>('SELECT * FROM listings ORDER BY name');
	}

	public async getListingWords(listingId: number): Promise<ListingWord[]> {
		return this.executeQuery<ListingWord>(
			'SELECT * FROM listing_words WHERE listing_id = ? ORDER BY word',
			[listingId]
		);
	}

	// Complex queries
	public async getGridWithWords(gridId: number): Promise<{
		grid: Grid | null;
		placements: WordPlacement[];
	}> {
		const grid = await this.getGridById(gridId);
		const placements = await this.getWordPlacements(gridId);
		return { grid, placements };
	}

	public async getThemeWithCategories(themeId: number): Promise<{
		theme: Theme | null;
		categories: Category[];
	}> {
		const theme = await this.getThemeById(themeId);
		const categories = await this.getCategoriesByTheme(themeId);
		return { theme, categories };
	}

	public async getListingWithWords(listingId: number): Promise<{
		listing: Listing | null;
		words: ListingWord[];
	}> {
		const results = await this.executeQuery<Listing>('SELECT * FROM listings WHERE id = ?', [
			listingId
		]);
		const listing = results[0] || null;
		const words = await this.getListingWords(listingId);
		return { listing, words };
	}
}

// Export a singleton instance
export const databaseService = DatabaseService.getInstance();
