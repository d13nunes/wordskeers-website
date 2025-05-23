import { adStore } from '$lib/ads/ads';
import { AdType } from '$lib/ads/ads-types';

export interface EndGameAd {
	show(): Promise<void>;
}

const maxFrequencyMillis = 1000 * 5; // 5 seconds
class AdmobEndGameAd implements EndGameAd {
	gameCount: number = 0;

	async show(): Promise<void> {
		this.gameCount++;
		console.log('📺📺📺 show', this.gameCount);
		const didSawAd = await adStore.showAd(AdType.Interstitial, maxFrequencyMillis);
		console.log('📺📺📺 didSawAd', didSawAd);
		if (didSawAd) {
			this.gameCount = 0;
		}
	}
}

export const endGameAdStore = new AdmobEndGameAd();
