import { AdType, type AdProvider } from '$lib/ads/ads-types';
import {
	AdMob,
	BannerAdPosition,
	BannerAdSize,
	type BannerAdOptions
} from '@capacitor-community/admob';

import { writable, type Readable } from 'svelte/store';

export class AdmobBanner implements AdProvider {
	adType = AdType.Banner;

	private _isLoaded = writable(false);

	constructor(private adId: string) {}

	isLoaded: Readable<boolean> = this._isLoaded;

	load(): Promise<boolean> {
		return Promise.resolve(true);
	}

	async show(): Promise<boolean> {
		const bannerOptions: BannerAdOptions = {
			adId: this.adId,
			adSize: BannerAdSize.BANNER,
			position: BannerAdPosition.BOTTOM_CENTER,
			margin: 0,
			isTesting: true
		};

		try {
			await AdMob.showBanner(bannerOptions);
			return true;
		} catch (error) {
			console.error('Failed to show banner ad', error);
			return false;
		}
	}

	hide(): Promise<void> {
		return AdMob.hideBanner();
	}
}
