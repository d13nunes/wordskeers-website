import { AdType, type AdProvider } from '$lib/ads/ads-types';
import { getIsSmallScreen } from '$lib/utils/utils';
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
	private orientationChangeHandler: (() => void) | null = null;
	private isShowing = false;

	constructor(private adId: string) {}

	isLoaded: Readable<boolean> = this._isLoaded;

	private getCssVariableValue(variableName: string): number {
		const value = getComputedStyle(document.documentElement).getPropertyValue(variableName).trim();
		console.log('value', value);
		// Handle CSS max() function
		if (value.startsWith('max(')) {
			// Extract values from max() function
			const values = value
				.replace('max(', '')
				.replace(')', '')
				.split(',')
				.map((v) => parseInt(v.trim().replace('px', ''), 10) || 0);
			// Return the maximum value
			const maxValue = Math.max(...values);
			console.log('max', maxValue);
			return maxValue;
		}
		// Handle regular pixel value
		const parsedValue = parseInt(value.replace('px', ''), 10) || 0;
		console.log('parsed', parsedValue);
		return parsedValue;
	}

	private getSafeAreaInsets() {
		return {
			top: this.getCssVariableValue('--safe-area-inset-top'),
			bottom: this.getCssVariableValue('--safe-area-inset-bottom'),
			left: this.getCssVariableValue('--safe-area-inset-left'),
			right: this.getCssVariableValue('--safe-area-inset-right')
		};
	}

	private getBannerParams(): BannerAdOptions {
		const orientation = window.orientation;
		const isLandscape = Math.abs(orientation) === 90;

		const bannerOptions: BannerAdOptions = {
			adId: this.adId,
			adSize: BannerAdSize.BANNER,
			margin: 0
		};

		if (isLandscape && getIsSmallScreen()) {
			bannerOptions.position = BannerAdPosition.TOP_CENTER;
		} else {
			bannerOptions.position = BannerAdPosition.BOTTOM_CENTER;
		}
		return bannerOptions;
	}

	private async updateBannerPosition(params: BannerAdOptions) {
		console.log('📺 updateBannerPosition', this.isShowing);
		if (!this.isShowing) {
			return;
		}

		try {
			await AdMob.removeBanner();
		} catch (err) {
			console.warn(
				'📺 Failed to hide banner:',
				err instanceof Error ? err.message : 'Unknown error'
			);
		}
		try {
			await AdMob.showBanner(params);
		} catch (err) {
			console.warn(
				'📺 Failed to reposition banner:',
				err instanceof Error ? err.message : 'Unknown error'
			);
		}
	}

	load(): Promise<boolean> {
		console.log('📺 Loading BannerAd');
		return Promise.resolve(true);
	}

	async show(): Promise<boolean> {
		console.log('📺 Showing BannerAd');
		if (this.isShowing) {
			return true;
		}
		this.isShowing = true;
		this.orientationChangeHandler = () => {
			this.updateBannerPosition(this.getBannerParams());
		};

		await AdMob.showBanner(this.getBannerParams());
		// Set up orientation change listener
		window.addEventListener('orientationchange', this.orientationChangeHandler);

		return true;
	}

	async hide(): Promise<void> {
		console.log('📺 Hiding BannerAd 1', this.isShowing);
		if (!this.isShowing) {
			return;
		}
		console.log('📺 Hiding BannerAd');
		this.isShowing = false;
		if (this.orientationChangeHandler) {
			window.removeEventListener('orientationchange', this.orientationChangeHandler);
			this.orientationChangeHandler = null;
		}
		return AdMob.hideBanner();
	}
}
