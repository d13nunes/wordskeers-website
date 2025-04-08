import { AdType, type AdProvider } from '$lib/ads/ads-types';
import {
	AdMob,
	RewardInterstitialAdPluginEvents,
	type AdMobError
} from '@capacitor-community/admob';

import { writable, type Readable } from 'svelte/store';

export class AdmobRewardInterstitial implements AdProvider {
	adType = AdType.RewardedInterstitial;

	private _isLoaded = writable(false);
	private isLoading = false;
	constructor(private adId: string) {}

	isLoaded: Readable<boolean> = this._isLoaded;

	load(): Promise<boolean> {
		if (this.isLoading) {
			return Promise.resolve(false);
		}
		this.isLoading = true;
		return new Promise((resolve, reject) => {
			AdMob.addListener(RewardInterstitialAdPluginEvents.Loaded, () => {
				this._isLoaded.set(true);
				this.isLoading = false;
				resolve(true);
			});
			AdMob.addListener(RewardInterstitialAdPluginEvents.FailedToLoad, () => {
				this._isLoaded.set(false);
				this.isLoading = false;
				reject(new Error('Failed to load reward interstitial ad'));
			});

			try {
				AdMob.prepareRewardInterstitialAd({
					adId: this.adId
				});
			} catch (error) {
				reject(error);
			}
		});
	}

	show(): Promise<boolean> {
		return new Promise((resolve, reject) => {
			AdMob.addListener(RewardInterstitialAdPluginEvents.Dismissed, () => {
				resolve(false);
			});
			AdMob.addListener(RewardInterstitialAdPluginEvents.FailedToShow, (error: AdMobError) => {
				reject(error);
			});
			AdMob.addListener(RewardInterstitialAdPluginEvents.Showed, () => {});
			AdMob.addListener(RewardInterstitialAdPluginEvents.Rewarded, () => {
				resolve(true);
			});
			this.showAd();
		});
	}

	private async showAd() {
		try {
			AdMob.showRewardInterstitialAd();
		} catch (error) {
			return false;
		}
	}
}
