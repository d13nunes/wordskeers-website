import { databaseService } from '$lib/database/database.service';
import type { WordPlacement, WordSearchGrid } from '$lib/database/types';
import { levelsManager } from '$lib/levels/levels';
import { FirebaseFirestore } from '@capacitor-firebase/firestore';
import { myLocalStorage } from '$lib/storage/local-storage';
import { Capacitor } from '@capacitor/core';
import { isToday } from 'date-fns';

export async function syncGrid(grid: WordSearchGrid, words: WordPlacement[]): Promise<void> {
	try {
		await databaseService.insertGrid(grid);
	} catch (error) {
		console.error('error syncing grid: ', JSON.stringify(grid), error);
	}
	await databaseService.insertWordPlacements(words);
}

const hasFirebaseEnabled = Capacitor.isNativePlatform();

export async function syncQuotes(): Promise<boolean> {
	if (!hasFirebaseEnabled) {
		return false;
	}
	try {
		const lastSyncQuotesTime = await myLocalStorage.get(myLocalStorage.LastSyncQuotesTime);
		if (lastSyncQuotesTime) {
			const lastSyncDate = new Date(parseInt(lastSyncQuotesTime));
			if (isToday(lastSyncDate)) {
				return false;
			}
		}

		const highestDateQuote = await databaseService.getHighestDateQuote();
		const distanceInDaysFromTodayToHighestDateQuote = Math.floor(
			(new Date(highestDateQuote).getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24)
		);
		let ajustForToday = 0;
		if (distanceInDaysFromTodayToHighestDateQuote <= 0) {
			ajustForToday = Math.abs(distanceInDaysFromTodayToHighestDateQuote);
		}

		const { snapshots } = await FirebaseFirestore.getCollection({
			reference: 'quotes',
			compositeFilter: {
				type: 'and',
				queryConstraints: [
					{
						type: 'where',
						fieldPath: 'playable_at',
						opStr: '>',
						value: highestDateQuote
					}
				]
			},
			queryConstraints: [
				{ type: 'limit', limit: 30 + ajustForToday },
				{ type: 'orderBy', fieldPath: 'playable_at', directionStr: 'asc' }
			]
		});
		myLocalStorage.set(myLocalStorage.LastSyncQuotesTime, Date.now().toString());
		if (snapshots.length === 0) {
			return false;
		}
		// save to database
		await Promise.all(
			snapshots.map(async (doc) => {
				const data = doc.data;
				if (!data) {
					return;
				}
				try {
					const { id, grid_id, author, quote, playable_at, grid } = data;
					if (!id || !grid_id || !author || !quote || !playable_at) {
						return;
					}
					const gridData: WordSearchGrid = {
						id: grid_id,
						name: grid.name,
						rows: grid.rows,
						columns: grid.columns,
						words_count: grid.placedWords.length,
						directions: grid.directions,
						grid_hash: grid.gridHash,
						played_at: null,
						is_challenge: grid.isChallenge,
						created_at: grid.createdAt
					};
					// eslint-disable-next-line @typescript-eslint/no-explicit-any
					const wordPlacements: WordPlacement[] = grid.placedWords.map((word: any) => ({
						id: word.id,
						grid_id: grid_id,
						word: word.word,
						row: word.row,
						col: word.col,
						direction: word.direction
					}));
					await syncGrid(gridData, wordPlacements);
					await databaseService.insertQuote(id, grid_id, author, quote, playable_at);
				} catch (error) {
					console.error('error inserting quote: ', error);
				}
			})
		);
	} catch (error) {
		console.error('error syncing quotes: ', error);
		return false;
	}
	return true;
}

export async function syncLevels(): Promise<boolean> {
	if (!hasFirebaseEnabled) {
		return false;
	}
	try {
		const highestLevel = await databaseService.getHighestLevel();
		const currentLevel = (await levelsManager.getCurrentLevel())?.orderIndex ?? 0;
		// ensure there is at least 10 levels after the current level
		const levelsToSync = 10 - (highestLevel - currentLevel);
		const lastSyncLevelsTime = await myLocalStorage.get(myLocalStorage.LastSyncLevelsTime);
		const isCooldown = lastSyncLevelsTime && isToday(lastSyncLevelsTime);
		// if cooldown is true and levelsToSync is greater than 3, return false
		if (isCooldown && levelsToSync > 3) {
			return false;
		}
		const { snapshots } = await FirebaseFirestore.getCollection({
			reference: 'levels',
			compositeFilter: {
				type: 'and',
				queryConstraints: [
					{
						type: 'where',
						fieldPath: 'order_index',
						opStr: '>',
						value: highestLevel
					}
				]
			},
			queryConstraints: [
				{ type: 'limit', limit: 10 },
				{ type: 'orderBy', fieldPath: 'order_index', directionStr: 'asc' }
			]
		});
		if (snapshots.length === 0) {
			return false;
		}
		try {
			await Promise.all(
				snapshots.map(async (doc) => {
					const data = doc.data;
					if (!data) {
						console.warn('syncLevels no data');
						return;
					}
					const { id, name, grid_ids, order_index, grids } = data;
					if (!id || !name || !grid_ids || !order_index || !grids) {
						console.warn('syncLevels no data', id, name, grid_ids, order_index);
						return;
					}
					await Promise.all(
						// eslint-disable-next-line @typescript-eslint/no-explicit-any
						grids.map(async (grid: any) => {
							try {
								await syncGrid(
									{
										id: grid.id,
										name: grid.name,
										rows: grid.rows,
										columns: grid.columns,
										words_count: grid.placedWords.length,
										directions: grid.directions,
										grid_hash: grid.gridHash,
										played_at: null,
										is_challenge: grid.isChallenge,
										created_at: grid.createdAt
									},
									grid.placedWords.map((word: WordPlacement) => ({
										id: word.id,
										grid_id: grid.id,
										word: word.word,
										row: word.row,
										col: word.col,
										direction: word.direction
									}))
								);
							} catch (error) {
								console.error('level error syncing grid: ', error);
							}
						})
					);
					try {
						await databaseService.insertLevel(id, name, grid_ids, order_index);
					} catch (error) {
						console.error('syncLevels error inserting level: ', error);
					}
				})
			);
		} catch (error) {
			console.error('error syncing levels: ', error);
		}
		myLocalStorage.set(myLocalStorage.LastSyncLevelsTime, Date.now().toString());
	} catch (error) {
		console.error('error syncing levels: ', error);
		return false;
	}
	return true;
}
