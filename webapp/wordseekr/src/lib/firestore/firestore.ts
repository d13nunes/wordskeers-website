import { databaseService } from '$lib/database/database.service';
import type { WordPlacement, WordSearchGrid } from '$lib/database/types';
import { levelsManager } from '$lib/levels/levels';
import { FirebaseFirestore } from '@capacitor-firebase/firestore';

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

let lastSyncQuotesTime = 0;
const syncQuotesCooldown = 1000 * 60 * 10; // 10 minutes

export async function syncQuotes(): Promise<boolean> {
	try {
		const highestDateQuote = await databaseService.getHighestDateQuote();
		// if highestDateQuote bigger than today bypass cooldown
		const haveQuoteForToday = new Date(highestDateQuote) > new Date();
		const isCooldown = Date.now() - lastSyncQuotesTime < syncQuotesCooldown;
		console.log('syncQuotes cooldown', isCooldown, haveQuoteForToday);
		if (isCooldown && haveQuoteForToday) {
			return false;
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
				{ type: 'limit', limit: 30 },
				{ type: 'orderBy', fieldPath: 'playable_at', directionStr: 'asc' }
			]
		});
		console.log('syncQuotes snapshots', snapshots);
		lastSyncQuotesTime = Date.now();
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

let lastSyncLevelsTime = 0;
const syncLevelsCooldown = 1000 * 60 * 10; // 10 minutes

export async function syncLevels(): Promise<boolean> {
	try {
		const highestLevel = await databaseService.getHighestLevel();
		const currentLevel = (await levelsManager.getCurrentLevel())?.orderIndex ?? 0;
		// ensure there is at least 10 levels after the current level
		const levelsToSync = 10 - (highestLevel - currentLevel);
		const isCooldown = Date.now() - lastSyncLevelsTime < syncLevelsCooldown;
		// if cooldown is true and levelsToSync is greater than 3, return false
		console.log('syncLevels cooldown', isCooldown, levelsToSync);
		console.log('syncLevels lastSyncLevelsTime', lastSyncLevelsTime, syncLevelsCooldown);
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
				{ type: 'limit', limit: levelsToSync },
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
		lastSyncLevelsTime = Date.now();
	} catch (error) {
		console.error('error syncing levels: ', error);
		return false;
	}
	return true;
}
