import { analytics } from '$lib/analytics/analytics';
import { Difficulty } from '$lib/game/difficulty';
import { getUnplayedAndTotalForDifficulty } from '$lib/game/grid-fetcher';
import { Preferences } from '@capacitor/preferences';

class MyLocalStorage {
	CurrentDifficulty = 'currentDifficultyKey';
	CoinBalance = 'coinBalance';
	RemoveAds = 'removeAds';
	ClockVisible = 'isClockVisible';
	TotalPlayedGamesCount = 'totalPlayedGamesCount';

	constructor() {}

	async set(key: string, value: string): Promise<void> {
		return await Preferences.set({ key, value });
	}

	async get(key: string): Promise<string | null> {
		const { value } = await Preferences.get({ key });
		return value;
	}

	async remove(key: string): Promise<void> {
		return await Preferences.remove({ key });
	}
}

class GameCounter {
	private localStorage: MyLocalStorage;
	constructor(localStorage: MyLocalStorage) {
		this.localStorage = localStorage;
	}

	async getCount(): Promise<number> {
		const count = await this.localStorage.get(this.localStorage.TotalPlayedGamesCount);
		return count ? parseInt(count) : 0;
	}

	async increment(): Promise<void> {
		const count = await this.getCount();
		await this.localStorage.set(this.localStorage.TotalPlayedGamesCount, (count + 1).toString());
	}
}

class CompletionTracker {
	private localStorage: MyLocalStorage;
	private completed25 = 'completed25';
	private completed50 = 'completed50';
	private completed75 = 'completed75';
	private completed100 = 'completed100';

	constructor(localStorage: MyLocalStorage) {
		this.localStorage = localStorage;
	}

	trackCompletionPercentageOfAllDifficulties() {
		console.log('🔍ℹ tracking completion percentage of all difficulties');
		const difficulties = Object.values(Difficulty);
		console.log(`🔍ℹ difficulties: ${difficulties}`);
		for (const difficulty of difficulties) {
			this.trackCompletion(difficulty);
		}
	}

	private async trackCompletion(difficulty: Difficulty): Promise<void> {
		const { unplayed, total } = await getUnplayedAndTotalForDifficulty(difficulty);
		const unplayedPercentage = (unplayed / total) * 100;
		console.log(
			`🔍ℹ checking completion for ${difficulty} ${unplayedPercentage} ${unplayed}/${total}`
		);

		if (unplayedPercentage > 75) {
			return;
		}

		let percentilKey = '';
		if (unplayedPercentage > 50) {
			percentilKey = this.completed25;
		} else if (unplayedPercentage > 25) {
			percentilKey = this.completed50;
		} else if (unplayedPercentage > 0) {
			percentilKey = this.completed75;
		} else {
			percentilKey = this.completed100;
		}

		const key = `${percentilKey}_${difficulty.toLowerCase()}`;

		const doesKeyExist = await this.localStorage.get(key);
		if (!doesKeyExist) {
			await this.localStorage.set(key, Date.now().toString());
			analytics.track(key, { date: Date.now().toString() });
		} else {
			console.log(
				`🔍ℹ already tracked completion for ${difficulty} ${unplayedPercentage} ${unplayed}/${total}`
			);
		}
	}
}

export class LevelsStorage {
	private localStorage: MyLocalStorage;

	CurrentLevelId = 'currentLevelId';
	GridIdsCompleted = 'gridIdsCompleted';

	constructor(localStorage: MyLocalStorage) {
		this.localStorage = localStorage;
	}
	async setCurrentLevelNumber(levelId: number): Promise<void> {
		return await this.localStorage.set(this.CurrentLevelId, levelId.toString());
	}

	async getCurrentLevelNumber(): Promise<number> {
		const levelId = await this.localStorage.get(this.CurrentLevelId);
		return levelId ? parseInt(levelId) : 0;
	}

	async setGridIdsCompletedForLevel(levelNumber: number, gridIds: number[]): Promise<void> {
		const key = `${this.GridIdsCompleted}_${levelNumber}`;
		await this.localStorage.set(key, gridIds.join(','));
	}

	async getGridIdsCompletedForLevel(levelNumber: number): Promise<number[]> {
		const key = `${this.GridIdsCompleted}_${levelNumber}`;
		const gridIds = await this.localStorage.get(key);
		console.log('🔍🔍🔍ℹ getGridIdsCompletedForLevel', key, gridIds);
		if (!gridIds) {
			console.log('🔍🔍🔍ℹ getGridIdsCompletedForLevel no gridIds');
			return [];
		}
		const re = gridIds.split(',').map((id) => parseInt(id));
		console.log('🔍🔍🔍ℹ getGridIdsCompletedForLevel result', re);
		return re;
	}

	async clearStorage() {
		let currentLevelId = await this.getCurrentLevelNumber();
		while (currentLevelId > 0) {
			this.localStorage.remove(`${this.GridIdsCompleted}_${currentLevelId}`);
			this.localStorage.remove(this.CurrentLevelId);
			currentLevelId--;
		}
	}
}

export const myLocalStorage = new MyLocalStorage();
export const completionTracker = new CompletionTracker(myLocalStorage);
export const gameCounter = new GameCounter(myLocalStorage);
export const levelsStorage = new LevelsStorage(myLocalStorage);
