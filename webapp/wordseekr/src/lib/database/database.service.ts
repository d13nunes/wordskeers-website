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
	ListingWord,
	DailyChallengeDB
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
	isInitializing = false;

	public async initialize(): Promise<void> {
		this.isInitializing = true;
		try {
			if (this.platform === 'web') {
				this.connection = await this.initializeWebDatabase();
			} else {
				this.connection = await this.initializeNativeDatabase();
			}

			if (!this.connection) {
				this.isInitializing = false;
				console.error(
					'!!! -> DatabaseService 33 initialize error',
					'Init mehtod returned no connection'
				);
				return;
			}

			databaseState.update((state) => ({
				...state,
				isInitialized: true,
				isConnected: true,
				error: null
			}));
		} catch (error) {
			console.error('CapacitorSQLite initialize error', error);
			const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
			databaseState.update((state) => ({
				...state,
				isInitialized: false,
				isConnected: false,
				error: errorMessage
			}));
			throw error;
		}
		this.isInitializing = false;
	}

	private async initializeWebDatabase(): Promise<DatabaseConnection | null> {
		try {
			// Initialize SQL.js
			const SQL = await initSqlJs({
				locateFile: (file: string) => `/assets/${file}`
			});

			// Fetch the pre-populated database from assets
			const response = await fetch('/assets/databases/wordseekr.db');
			if (!response.ok) {
				throw new Error(
					'Failed to fetch pre-populated database from /assets/databases/wordseekr.db'
				);
			}
			const buffer = await response.arrayBuffer();
			const db = new SQL.Database(new Uint8Array(buffer));
			return db;
			// No need to initialize schema for pre-populated DB
		} catch (error) {
			throw new Error(
				`Failed to initialize web database: ${error instanceof Error ? error.message : 'Unknown error'}`
			);
		}
	}

	private async initializeNativeDatabase(): Promise<DatabaseConnection | null> {
		try {
			console.log('CapacitorSQLite initializeNativeDatabase start');
			if (!this.sqliteConnection) {
				this.sqliteConnection = new SQLiteConnection(CapacitorSQLite);
			}
			// Check if database exists before copying
			const isDbExists = await CapacitorSQLite.isDatabase({ database: DB_NAME });
			if (!isDbExists.result) {
				console.log('CapacitorSQLite Database does not exist, copying from assets...');
				await CapacitorSQLite.copyFromAssets({});
			} else {
				console.log('CapacitorSQLite Database already exists, skipping copy from assets');
			}
			const db: SQLiteDBConnection = await getConnection(this.sqliteConnection, DB_NAME);
			console.log('CapacitorSQLite created, opening connection....');
			await db.open();
			console.log('CapacitorSQLite opened, returning connection...');
			return db;
		} catch (error) {
			throw new Error(`CapacitorSQLite Failed to initialize native database📺: ${error}`);
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
			try {
				await this.initialize();
			} catch (error) {
				throw new Error(
					`CapacitorSQLite Failed 1 to initialize database: ${error instanceof Error ? error.message : 'Unknown error'}`
				);
			}
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
				`CapacitorSQLite Query execution failed: ${error instanceof Error ? error.message : 'Unknown error'}`
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

	public async markGridAsPlayed(gridId: number, timeTaken: number): Promise<void> {
		await this.executeQuery(
			'UPDATE word_search_grids SET played_at = CURRENT_TIMESTAMP, time_taken = ? WHERE id = ?',
			[timeTaken, gridId]
		);
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

	// Add missing getGridById method
	public async getGridById(id: number): Promise<Grid | null> {
		const results = await this.executeQuery<Grid>('SELECT * FROM grids WHERE id = ?', [id]);
		return results[0] || null;
	}

	public async getDailyChallengeById(id: number): Promise<DailyChallengeDB | null> {
		// TODO: Implement this
		return {
			id: '' + id,
			title: 'Albert Einstein',
			size: 7,
			date: new Date('2025-06-05T15:58:13.383Z'),
			quotes: [
				{ text: 'LIFE', isHidden: true },
				{ text: 'IS', isHidden: false },
				{ text: 'LIKE', isHidden: false },
				{ text: 'RIDING', isHidden: false },
				{ text: 'A', isHidden: false },
				{ text: 'BICYCLE', isHidden: true },
				{ text: '.', isHidden: false },
				{ text: 'TO', isHidden: false },
				{ text: 'KEEP', isHidden: true },
				{ text: 'YOUR', isHidden: false },
				{ text: 'BALANCE', isHidden: true },
				{ text: ',', isHidden: false },
				{ text: 'YOU', isHidden: false },
				{ text: 'MUST', isHidden: true },
				{ text: 'KEEP', isHidden: false },
				{ text: 'MOVING', isHidden: true },
				{ text: '.', isHidden: false }
			],
			words: [
				{ word: 'KEEP', row: 0, col: 5, direction: 'vertical', id: 1, grid_id: 1 },
				{ word: 'MUST', row: 2, col: 3, direction: 'diagonal-dl', id: 2, grid_id: 1 },
				{ word: 'LIFE', row: 1, col: 0, direction: 'horizontal', id: 3, grid_id: 1 },
				{ word: 'MOVING', row: 6, col: 0, direction: 'horizontal', id: 4, grid_id: 1 },
				{ word: 'BALANCE', row: 0, col: 6, direction: 'vertical', id: 5, grid_id: 1 },
				{ word: 'BICYCLE', row: 0, col: 0, direction: 'diagonal-dr', id: 6, grid_id: 1 }
			]
		};
	}
}

// Export a singleton instance
export const databaseService = DatabaseService.getInstance();

async function getConnection(
	sqliteConnection: SQLiteConnection,
	dbName: string
): Promise<SQLiteDBConnection> {
	try {
		const isGood = await sqliteConnection.checkConnectionsConsistency();
		console.debug('CapacitorSQLite checkConnectionsConsistency', isGood);
		if (isGood.result) {
			console.debug('CapacitorSQLite retrieveConnection');
			return await sqliteConnection.retrieveConnection(dbName, false);
		} else {
			console.debug('CapacitorSQLite createConnection');
			return await sqliteConnection.createConnection(
				dbName,
				false,
				'no-encryption',
				DB_VERSION,
				false
			);
		}
	} catch (error) {
		console.error('CapacitorSQLite bd connection is not good, creating a new one', error);
		return await sqliteConnection.createConnection(
			dbName,
			false,
			'no-encryption',
			DB_VERSION,
			false
		);
	}
}
