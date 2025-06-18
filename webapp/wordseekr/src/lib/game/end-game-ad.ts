import { adStore } from '$lib/ads/ads';
import { AdType } from '$lib/ads/ads-types';

export interface EndGameAd {
	show(options: EndGameAdShowOptions): Promise<void>;
}

export interface EndGameAdShowOptions {
	didWatchRewardAd: boolean;
	isDailyChallenge: boolean;
}

const maxFrequencyMillis = 1000 * 60 * 2; // 2 minutes
class AdmobEndGameAd implements EndGameAd {
	gameCount: number = 0;

	async show(options: EndGameAdShowOptions): Promise<void> {
		this.gameCount++;
		if (options.didWatchRewardAd) {
			console.log('📺📺📺 didWatchRewardAd', this.gameCount);
			return;
		}
		if (options.isDailyChallenge) {
			console.log('📺📺📺 isDailyChallenge - show ad', this.gameCount, options);
			await adStore.showAd(AdType.Interstitial, null);
			return;
		}
		if (this.gameCount < 2) {
			console.log('📺📺📺 gameCount < 2', this.gameCount);
			return;
		}
		console.log('📺📺📺 show', this.gameCount);
		const didSawAd = await adStore.showAd(AdType.Interstitial, maxFrequencyMillis);
		console.log('📺📺📺 didSawAd', didSawAd);
		if (didSawAd) {
			this.gameCount = 0;
		}
	}
}

export const endGameAdStore = new AdmobEndGameAd();
