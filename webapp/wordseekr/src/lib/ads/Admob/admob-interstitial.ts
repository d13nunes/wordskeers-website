import { AdType, type AdProvider } from '$lib/ads/ads-types';
import { AdMob, InterstitialAdPluginEvents, type AdMobError } from '@capacitor-community/admob';

import { writable, type Readable } from 'svelte/store';

export class AdmobInterstitial implements AdProvider {
	adType = AdType.Interstitial;

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
			AdMob.addListener(InterstitialAdPluginEvents.Loaded, () => {
				this._isLoaded.set(true);
				this.isLoading = false;
				resolve(true);
			});
			AdMob.addListener(InterstitialAdPluginEvents.FailedToLoad, () => {
				this._isLoaded.set(false);
				this.isLoading = false;
				reject(new Error('Failed to load interstitial ad'));
			});
			AdMob.prepareInterstitial({
				adId: this.adId
			});
		});
	}

	show(): Promise<boolean> {
		return new Promise((resolve, reject) => {
			AdMob.addListener(InterstitialAdPluginEvents.Dismissed, () => {
				resolve(true);
			});
			AdMob.addListener(InterstitialAdPluginEvents.FailedToShow, (error: AdMobError) => {
				reject(error);
			});
			AdMob.addListener(InterstitialAdPluginEvents.Showed, () => {
				resolve(true);
			});

			AdMob.showInterstitial();
		});
	}
}
