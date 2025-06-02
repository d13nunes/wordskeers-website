import { analytics } from '$lib/analytics/analytics';
import { Difficulty } from '$lib/game/difficulty';
import { getUnplayedAndTotalForDifficulty } from '$lib/game/grid-fetcher';
import { Preferences } from '@capacitor/preferences';

class LocalStorage {
	CurrentDifficulty = 'currentDifficultyKey';
	CoinBalance = 'coinBalance';
	RemoveAds = 'removeAds';
	ClockVisible = 'isClockVisible';

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

class CompletionTracker {
	private localStorage: LocalStorage;
	private completed25 = 'completed25';
	private completed50 = 'completed50';
	private completed75 = 'completed75';
	private completed100 = 'completed100';

	constructor(localStorage: LocalStorage) {
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

export const myLocalStorage = new LocalStorage();
export const completionTracker = new CompletionTracker(myLocalStorage);
