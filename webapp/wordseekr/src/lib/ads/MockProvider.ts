// mock-ad-provider.ts
import { type AdProvider, AdType } from './AdManager';

export class MockAdProvider implements AdProvider {
	private isRewardedLoaded = false;
	private isInterstitialLoaded = false;
	private isBannerLoaded = false;

	private rewardedAdCompletedCallback: (() => void) | null = null;
	private adFailedToLoadCallback: ((adType: AdType, error: Error) => void) | null = null;
	private adLoadedCallback: ((adType: AdType) => void) | null = null;
	private adShownCallback: ((adType: AdType) => void) | null = null;
	private adClickedCallback: ((adType: AdType) => void) | null = null;
	private adClosedCallback: ((adType: AdType) => void) | null = null;

	async initialize(): Promise<boolean> {
		console.log('MockAdProvider initialized.');
		return true;
	}

	async loadAd(adType: AdType, adUnitId: string): Promise<boolean> {
		console.log(`MockAdProvider: Loading ${adType} ad with ID ${adUnitId}`);
		return new Promise((resolve) => {
			setTimeout(() => {
				if (Math.random() < 0.8) {
					// Simulate successful load 80% of the time
					console.log(`MockAdProvider: ${adType} ad loaded successfully.`);
					if (adType === AdType.Rewarded) {
						this.isRewardedLoaded = true;
					} else if (adType === AdType.Interstitial) {
						this.isInterstitialLoaded = true;
					} else if (adType === AdType.Banner) {
						this.isBannerLoaded = true;
					}
					this.adLoadedCallback?.(adType);
					resolve(true);
				} else {
					const error = 'Mock ad load failed.';
					console.error(`MockAdProvider: ${adType} ad failed to load: ${error}`);
					this.adFailedToLoadCallback?.(adType, error);
					resolve(false);
				}
			}, 1000);
		});
	}

	async showAd(adType: AdType): Promise<boolean> {
		console.log(`MockAdProvider: Showing ${adType} ad.`);
		return new Promise((resolve) => {
			if (
				(adType === AdType.Rewarded && this.isRewardedLoaded) ||
				(adType === AdType.Interstitial && this.isInterstitialLoaded) ||
				(adType === AdType.Banner && this.isBannerLoaded)
			) {
				setTimeout(() => {
					console.log(`MockAdProvider: ${adType} ad shown.`);
					this.adShownCallback?.(adType);
					if (adType === AdType.Rewarded && this.rewardedAdCompletedCallback) {
						console.log('MockAdProvider: Rewarded ad completed.');
						this.rewardedAdCompletedCallback();
						this.isRewardedLoaded = false; // Reset after completion
					} else if (adType === AdType.Interstitial) {
						this.isInterstitialLoaded = false; // Reset after showing
						this.adClosedCallback?.(adType);
					} else if (adType === AdType.Banner) {
						// Banner ads might persist
					}
					this.adClosedCallback?.(adType);
					resolve(true);
				}, 500);
			} else {
				console.warn(`MockAdProvider: Cannot show ${adType} ad. It's not loaded.`);
				resolve(false);
			}
		});
	}

	isAdLoaded(adType: AdType): boolean {
		if (adType === AdType.Rewarded) {
			return this.isRewardedLoaded;
		}
		if (adType === AdType.Interstitial) {
			return this.isInterstitialLoaded;
		}
		if (adType === AdType.Banner) {
			return this.isBannerLoaded;
		}
		return false;
	}

	setBannerAdContainer?(containerId: string): void {
		console.log(`MockAdProvider: Setting banner ad container to #${containerId}`);
	}

	onRewardedAdCompleted?(callback: () => void): void {
		this.rewardedAdCompletedCallback = callback;
	}

	onAdFailedToLoad?(callback: (adType: AdType, error: Error) => void): void {
		this.adFailedToLoadCallback = callback;
	}

	onAdLoaded?(callback: (adType: AdType) => void): void {
		this.adLoadedCallback = callback;
	}

	onAdShown?(callback: (adType: AdType) => void): void {
		this.adShownCallback = callback;
	}

	onAdClicked?(callback: (adType: AdType) => void): void {
		this.adClickedCallback = callback;
	}

	onAdClosed?(callback: (adType: AdType) => void): void {
		this.adClosedCallback = callback;
	}
}
