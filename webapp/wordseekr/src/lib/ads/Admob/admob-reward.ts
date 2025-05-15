import { AdType, type AdProvider } from '$lib/ads/ads-types';
import { AdMob, RewardAdPluginEvents, type AdMobError } from '@capacitor-community/admob';

import { writable, type Readable } from 'svelte/store';

export class AdmobReward implements AdProvider {
	adType = AdType.Rewarded;

	private _isLoaded = writable(false);

	constructor(private adId: string) {}

	isLoaded: Readable<boolean> = this._isLoaded;
	private isLoading = false;
	async load(): Promise<boolean> {
		if (this.isLoading) {
			return Promise.resolve(false);
		}
		this.isLoading = true;
		AdMob.prepareRewardVideoAd({
			adId: this.adId
		});
		return new Promise((resolve, reject) => {
			AdMob.addListener(RewardAdPluginEvents.Loaded, () => {
				this._isLoaded.set(true);
				this.isLoading = false;
				resolve(true);
			});
			AdMob.addListener(RewardAdPluginEvents.FailedToLoad, () => {
				this._isLoaded.set(false);
				this.isLoading = false;
				reject(new Error('Failed to load rewarded ad'));
			});
		});
	}

	show(): Promise<boolean> {
		return new Promise((resolve, reject) => {
			AdMob.addListener(RewardAdPluginEvents.Dismissed, () => {
				resolve(false);
			});
			AdMob.addListener(RewardAdPluginEvents.FailedToShow, (error: AdMobError) => {
				reject(error);
			});
			AdMob.addListener(RewardAdPluginEvents.Showed, () => {});
			AdMob.addListener(RewardAdPluginEvents.Rewarded, () => {
				resolve(true);
			});
			AdMob.showRewardVideoAd();
		});
	}
}
