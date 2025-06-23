import { CapacitorSQLite, SQLiteConnection, SQLiteDBConnection } from '@capacitor-community/sqlite';
import { Capacitor } from '@capacitor/core';
import initSqlJs from 'sql.js';
import type { Database as SqlJsDatabase, SqlValue } from 'sql.js';
import { writable, type Writable } from 'svelte/store';
import type {
	WordSearchGrid,
	WordPlacement,
	DailyChallenge,
	Score,
	Quote,
	QuoteSegment,
	Level,
	LevelDB
} from './types';
import { isToday } from 'date-fns/isToday';

// Database configuration
const DB_NAME = 'wordseekr_v4.db';
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
			const response = await fetch('/assets/databases/wordseekr_v4.db');
			if (!response.ok) {
				throw new Error(
					'Failed to fetch pre-populated database from /assets/databases/wordseekr_v4.db'
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

	public async insertQuote(
		id: number,
		grid_id: number,
		author: string,
		quote: string,
		playable_at: string
	): Promise<void> {
		await this.executeQuery(
			'INSERT INTO quotes (id, grid_id, author, quote, playable_at) VALUES (?, ?, ?, ?, ?)',
			[id, grid_id, author, quote, playable_at]
		);
	}

	public async markQuoteAsPlayed(quoteId: number, played_at: Date): Promise<void> {
		await this.executeQuery('UPDATE quotes SET played_at = ? WHERE id = ?', [
			played_at.toISOString(),
			quoteId
		]);
	}

	public async didPlayedQuote(quoteId: number): Promise<boolean> {
		const quote = await this.getQuoteById(quoteId);
		if (!quote) {
			return false;
		}
		const playedAt = quote.played_at ? new Date(quote.played_at) : null;
		if (!playedAt) {
			return false;
		}
		return isToday(playedAt);
	}

	public async getHighestDateQuote(): Promise<string> {
		const results = await this.executeQuery<{ 'MAX(playable_at)': string }>(
			'SELECT MAX(playable_at) FROM quotes'
		);
		return results[0]?.['MAX(playable_at)'] ?? '';
	}

	public async insertGrid(gridData: WordSearchGrid): Promise<void> {
		await this.executeQuery(
			`
				INSERT INTO word_search_grids (id, name, rows, columns, words_count, directions, grid_hash, is_challenge)
				VALUES (?, ?, ?, ?, ?, ?, ?, ?)
			`,
			[
				gridData.id,
				gridData.name,
				gridData.rows,
				gridData.columns,
				gridData.words_count,
				gridData.directions,
				gridData.grid_hash,
				JSON.stringify(gridData.is_challenge)
			]
		);
	}

	public async insertWordPlacements(placedWords: WordPlacement[]): Promise<void> {
		for (const placement of placedWords) {
			try {
				await this.insertWordPlacement(placement);
			} catch (error) {
				console.error('!!!! error inserting word placement: ', error);
			}
		}
	}

	public async insertWordPlacement(placement: WordPlacement): Promise<void> {
		await this.executeQuery(
			`
				INSERT INTO word_placements (id, grid_id, word, row, col, direction)
				VALUES (?, ?, ?, ?, ?, ?)
			`,
			[
				placement.id,
				placement.grid_id,
				placement.word,
				placement.row,
				placement.col,
				placement.direction
			]
		);
	}

	public async markGridAsPlayed(
		gridId: number,
		played_at: Date,
		time_taken: number
	): Promise<void> {
		await this.executeQuery('UPDATE word_search_grids SET played_at = ? WHERE id = ?', [
			played_at.toISOString(),
			gridId
		]);
		await this.executeQuery(
			'INSERT INTO scores (grid_id, played_at, time_taken) VALUES (?, ?, ?)',
			[gridId, played_at.toISOString(), time_taken]
		);
	}

	public async getAllScores(): Promise<Score[]> {
		return this.executeQuery<Score>('SELECT * FROM scores');
	}

	public async getAllQuotes(): Promise<Quote[]> {
		return this.executeQuery<Quote>('SELECT * FROM quotes');
	}

	public async getQuoteById(id: number): Promise<Quote | null> {
		const results = await this.executeQuery<Record<string, unknown>>(
			'SELECT * FROM quotes WHERE id = ?',
			[id]
		);
		const result = results[0];
		if (!result) {
			return null;
		}
		return {
			id: result.id,
			grid_id: result.grid_id,
			author: result.author,
			quote: JSON.parse(result.quote as string) as QuoteSegment[],
			playable_at: result.playable_at
		} as Quote;
	}

	public async getQuoteForDate(date: Date): Promise<Quote | null> {
		const results = await this.executeQuery<Quote>('SELECT * FROM quotes WHERE playable_at = ?', [
			date.toISOString().split('T')[0]
		]);
		return results[0] || null;
	}

	public async getDailyChallengeById(id: number): Promise<DailyChallenge | null> {
		const quote = await this.getQuoteById(id);
		if (!quote) {
			return null;
		}
		const grid = await this.getWordSearchGridById(quote.grid_id);
		if (!grid) {
			return null;
		}
		const words = await this.getWordPlacements(grid.id);
		if (!words) {
			return null;
		}
		return {
			id: '' + id,
			title: grid.name,
			rows: grid.rows,
			columns: grid.columns,
			date: new Date(quote.playable_at),
			quotes: quote.quote,
			words: words
		};
	}

	public async getAllLevels(): Promise<Level[]> {
		return this.executeQuery<Level>('SELECT * FROM levels ORDER BY order_index ASC');
	}

	public async getHighestLevel(): Promise<number> {
		console.log('highestLevel !!!');
		const results = await this.executeQuery<{ 'MAX(order_index)': number }>(
			'SELECT MAX(order_index) FROM levels'
		);
		return results[0]?.['MAX(order_index)'] ?? 0;
	}

	public async insertLevel(
		id: number,
		name: string,
		grid_ids: string,
		order_index: number
	): Promise<void> {
		try {
			console.log('🙏 insertLevel will insert level:', id, name, grid_ids, order_index);
			await this.executeQuery(
				'INSERT INTO levels (id, name, grid_ids, order_index) VALUES (?, ?, ?, ?)',
				[id, name, grid_ids, order_index]
			);
		} catch (error) {
			console.error('error inserting level: ', id, name, grid_ids, order_index, error);
			throw error;
		}
	}

	// Levels methods
	public async getLevel(levelNumber: number): Promise<Level | null> {
		const results = await this.executeQuery<LevelDB>('SELECT * FROM levels WHERE order_index = ?', [
			levelNumber
		]);
		const level = results[0] as LevelDB;
		if (level) {
			return {
				orderIndex: level.order_index,
				gridIds: level.grid_ids.split(',').map(Number),
				name: level.name
			} as Level;
		}
		return null;
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
