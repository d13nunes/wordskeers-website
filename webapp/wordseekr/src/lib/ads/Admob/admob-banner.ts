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

	private getCssVariableValue(variableName: string): number {
		const value = getComputedStyle(document.documentElement).getPropertyValue(variableName).trim();
		// Convert from 'px' to number
		return parseInt(value.replace('px', ''), 10) || 0;
	}

	load(): Promise<boolean> {
		console.log('📺 Loading BannerAd');
		return Promise.resolve(true);
	}

	async show(): Promise<boolean> {
		console.log('📺 Showing BannerAd');
		try {
			// Get the bottom safe area inset from CSS variable
			// const bottomInset = this.getCssVariableValue('--safe-area-inset-bottom');
			// Add a small padding to the bottom inset for better visual appearance
			const margin = 0; // Math.max(bottomInset + 16, 16); // Minimum 16px padding

			const bannerOptions: BannerAdOptions = {
				adId: this.adId,
				adSize: BannerAdSize.BANNER,
				position: BannerAdPosition.BOTTOM_CENTER,
				margin,
				isTesting: true
			};

			await AdMob.showBanner(bannerOptions);
			console.log('📺 BannerAd shown with margin:', margin);
			return true;
		} catch (err) {
			// Fallback to a default margin if something goes wrong
			console.warn(
				'📺 Failed to get safe area insets:',
				err instanceof Error ? err.message : 'Unknown error'
			);
			const bannerOptions: BannerAdOptions = {
				adId: this.adId,
				adSize: BannerAdSize.BANNER,
				position: BannerAdPosition.BOTTOM_CENTER,
				margin: 16, // Default padding
				isTesting: true
			};

			await AdMob.showBanner(bannerOptions);
			console.log('📺 BannerAd shown with default margin');
			return true;
		}
	}

	hide(): Promise<void> {
		return AdMob.hideBanner();
	}
}
