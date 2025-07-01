import { databaseService } from '$lib/database/database.service';
import type { WordPlacement, WordSearchGrid } from '$lib/database/types';
import { levelsManager } from '$lib/levels/levels';
import { FirebaseFirestore } from '@capacitor-firebase/firestore';
import { myLocalStorage } from '$lib/storage/local-storage';
import { Capacitor } from '@capacitor/core';
import { isToday } from 'date-fns';

export async function syncGrid(id: number): Promise<void> {
	const { snapshots } = await FirebaseFirestore.getCollection({
		reference: 'word_search_grids',
		compositeFilter: {
			type: 'and',
			queryConstraints: [
				{
					type: 'where',
					fieldPath: 'id',
					opStr: '==',
					value: id
				}
			]
		}
	});
	const gridData = {
		id: id,
		name: snapshots[0].data?.name ?? '',
		rows: snapshots[0].data?.rows ?? 0,
		columns: snapshots[0].data?.columns ?? 0,
		words_count: snapshots[0].data?.words_count ?? 0,
		directions: snapshots[0].data?.directions ?? [],
		grid_hash: snapshots[0].data?.grid_hash ?? '',
		is_challenge: snapshots[0].data?.is_challenge ?? false
	} as WordSearchGrid;

	await databaseService.insertGrid(gridData);
	const words = await FirebaseFirestore.getCollection({
		reference: `word_placements`,
		compositeFilter: {
			type: 'and',
			queryConstraints: [
				{
					type: 'where',
					fieldPath: 'grid_id',
					opStr: '==',
					value: id
				}
			]
		}
	});

	const wordPlacements: WordPlacement[] = words.snapshots.map((word) => ({
		id: parseInt(word.id),
		grid_id: id,
		word: word.data?.word ?? '',
		row: word.data?.row ?? 0,
		col: word.data?.col ?? 0,
		direction: word.data?.direction ?? ''
	}));
	await databaseService.insertWordPlacements(wordPlacements);
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
		console.log('syncQuotes snapshots', snapshots);
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
					const { id, grid_id, author, quote, playable_at } = data;
					if (!id || !grid_id || !author || !quote || !playable_at) {
						return;
					}
					await syncGrid(grid_id);
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
		console.log('syncLevels cooldown', isCooldown, levelsToSync);
		console.log('syncLevels lastSyncLevelsTime', lastSyncLevelsTime, lastSyncLevelsTime);
		if (isCooldown && levelsToSync > 3) {
			return false;
		}
		console.log('syncLevels highestLevel', highestLevel);
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
		console.log('syncLevels snapshots', snapshots);
		if (snapshots.length === 0) {
			return false;
		}
		try {
			await Promise.all(
				snapshots.map(async (doc) => {
					const data = doc.data;
					if (!data) {
						console.log('syncLevels no data');
						return;
					}
					const { id, name, grid_ids, order_index } = data;
					if (!id || !name || !grid_ids || !order_index) {
						console.log('syncLevels no data', id, name, grid_ids, order_index);
						return;
					}
					const gridIds: number[] = grid_ids.split(',').map(Number);
					await Promise.all(
						gridIds.map(async (gridId: number) => {
							try {
								await syncGrid(gridId);
							} catch (error) {
								console.error('error syncing grid: ', error);
							}
						})
					);
					try {
						console.log('syncLevels inserting level: ', id, name, grid_ids, order_index);
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
