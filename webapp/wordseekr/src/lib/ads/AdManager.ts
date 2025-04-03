// ad-manager.ts

/**
 * Defines the different types of ads supported.
 */
export enum AdType {
	Rewarded = 'rewarded',
	Interstitial = 'interstitial',
	RewardedInterstitial = 'rewardedInterstitial',
	Banner = 'banner'
}

/**
 * Defines the interface for an ad provider.
 * Concrete providers (e.g., Google AdMob, Facebook Audience Network) will implement this.
 */
export interface AdProvider {
	initialize(): Promise<boolean>;
	loadAd(adType: AdType, adUnitId: string): Promise<boolean>;
	showAd(adType: AdType): Promise<boolean>;
	isAdLoaded(adType: AdType): boolean;
	setBannerAdContainer?(containerId: string): void; // Optional: For banner ads to specify the container
	onRewardedAdCompleted?(callback: () => void): void; // Optional: Callback for rewarded ads
	onAdFailedToLoad?(callback: (adType: AdType, error: Error) => void): void; // Optional: Generic failure callback
	onAdLoaded?(callback: (adType: AdType) => void): void; // Optional: Generic loaded callback
	onAdShown?(callback: (adType: AdType) => void): void; // Optional: Generic shown callback
	onAdClicked?(callback: (adType: AdType) => void): void; // Optional: Generic clicked callback
	onAdClosed?(callback: (adType: AdType) => void): void; // Optional: Generic closed callback
}

/**
 * Options that can be passed when creating the AdManager.
 */
export interface AdManagerOptions {
	defaultProvider?: AdProvider;
}

/**
 * Manages the display of ads using different ad providers.
 */
export class AdManager {
	private currentProvider: AdProvider | null = null;
	private providers: Record<string, AdProvider> = {};
	private rewardedAdCompletedCallback: (() => void) | null = null;
	private adFailedToLoadCallback: ((adType: AdType, error: any) => void) | null = null;
	private adLoadedCallback: ((adType: AdType) => void) | null = null;
	private adShownCallback: ((adType: AdType) => void) | null = null;
	private adClickedCallback: ((adType: AdType) => void) | null = null;
	private adClosedCallback: ((adType: AdType) => void) | null = null;

	constructor(options?: AdManagerOptions) {
		if (options?.defaultProvider) {
			this.currentProvider = options.defaultProvider;
		}
	}

	/**
	 * Registers a new ad provider with a specific name.
	 * @param name The name of the provider (e.g., 'admob', 'facebook').
	 * @param provider The AdProvider instance.
	 */
	registerProvider(name: string, provider: AdProvider): void {
		this.providers[name] = provider;
	}

	/**
	 * Sets the currently active ad provider by its registered name.
	 * @param providerName The name of the provider to use.
	 */
	setProvider(providerName: string): void {
		if (this.providers[providerName]) {
			this.currentProvider = this.providers[providerName];
			this.setupProviderCallbacks();
		} else {
			console.error(`Ad provider "${providerName}" not registered.`);
			this.currentProvider = null;
		}
	}

	/**
	 * Gets the currently active ad provider.
	 * @returns The current AdProvider instance or null if none is set.
	 */
	getCurrentProvider(): AdProvider | null {
		return this.currentProvider;
	}

	private setupProviderCallbacks(): void {
		if (this.currentProvider) {
			if (this.rewardedAdCompletedCallback && this.currentProvider.onRewardedAdCompleted) {
				this.currentProvider.onRewardedAdCompleted(this.rewardedAdCompletedCallback);
			}
			if (this.adFailedToLoadCallback && this.currentProvider.onAdFailedToLoad) {
				this.currentProvider.onAdFailedToLoad(this.adFailedToLoadCallback);
			}
			if (this.adLoadedCallback && this.currentProvider.onAdLoaded) {
				this.currentProvider.onAdLoaded(this.adLoadedCallback);
			}
			if (this.adShownCallback && this.currentProvider.onAdShown) {
				this.currentProvider.onAdShown(this.adShownCallback);
			}
			if (this.adClickedCallback && this.currentProvider.onAdClicked) {
				this.currentProvider.onAdClicked(this.adClickedCallback);
			}
			if (this.adClosedCallback && this.currentProvider.onAdClosed) {
				this.currentProvider.onAdClosed(this.adClosedCallback);
			}
		}
	}

	/**
	 * Initializes the currently active ad provider.
	 * @returns A promise that resolves to true if initialization is successful, false otherwise.
	 */
	async initialize(): Promise<boolean> {
		if (!this.currentProvider) {
			console.warn('No ad provider is currently set. Cannot initialize.');
			return false;
		}
		return this.currentProvider.initialize();
	}

	/**
	 * Loads an ad of the specified type using the currently active provider.
	 * @param adType The type of ad to load (e.g., Rewarded, Interstitial, Banner).
	 * @param adUnitId The specific ad unit ID for this ad type.
	 * @returns A promise that resolves to true if loading is successful, false otherwise.
	 */
	async loadAd(adType: AdType, adUnitId: string): Promise<boolean> {
		if (!this.currentProvider) {
			console.warn('No ad provider is currently set. Cannot load ad.');
			return false;
		}
		return this.currentProvider.loadAd(adType, adUnitId);
	}

	/**
	 * Shows an ad of the specified type using the currently active provider.
	 * @param adType The type of ad to show (e.g., Rewarded, Interstitial).
	 * @returns A promise that resolves to true if showing is successful, false otherwise.
	 */
	async showAd(adType: AdType): Promise<boolean> {
		if (!this.currentProvider) {
			console.warn('No ad provider is currently set. Cannot show ad.');
			return false;
		}
		return this.currentProvider.showAd(adType);
	}

	/**
	 * Checks if an ad of the specified type is currently loaded.
	 * @param adType The type of ad to check.
	 * @returns True if the ad is loaded, false otherwise.
	 */
	isAdLoaded(adType: AdType): boolean {
		if (!this.currentProvider) {
			return false;
		}
		return this.currentProvider.isAdLoaded(adType);
	}

	/**
	 * Sets the container element ID for banner ads (if the current provider supports it).
	 * @param containerId The ID of the HTML element to use as the banner container.
	 */
	setBannerAdContainer(containerId: string): void {
		if (this.currentProvider?.setBannerAdContainer) {
			this.currentProvider.setBannerAdContainer(containerId);
		} else {
			console.warn('Current ad provider does not support setting a banner ad container.');
		}
	}

	/**
	 * Sets a callback function to be executed when a rewarded ad is completed.
	 * @param callback The function to call.
	 */
	onRewardedAdCompleted(callback: () => void): void {
		this.rewardedAdCompletedCallback = callback;
		this.setupProviderCallbacks(); // Update callback on the current provider if it's set
	}

	/**
	 * Sets a callback function to be executed when an ad fails to load.
	 * @param callback The function to call with the ad type and error.
	 */
	onAdFailedToLoad(callback: (adType: AdType, error: any) => void): void {
		this.adFailedToLoadCallback = callback;
		this.setupProviderCallbacks();
	}

	/**
	 * Sets a callback function to be executed when an ad is loaded.
	 * @param callback The function to call with the ad type.
	 */
	onAdLoaded(callback: (adType: AdType) => void): void {
		this.adLoadedCallback = callback;
		this.setupProviderCallbacks();
	}

	/**
	 * Sets a callback function to be executed when an ad is shown.
	 * @param callback The function to call with the ad type.
	 */
	onAdShown(callback: (adType: AdType) => void): void {
		this.adShownCallback = callback;
		this.setupProviderCallbacks();
	}

	/**
	 * Sets a callback function to be executed when an ad is clicked.
	 * @param callback The function to call with the ad type.
	 */
	onAdClicked(callback: (adType: AdType) => void): void {
		this.adClickedCallback = callback;
		this.setupProviderCallbacks();
	}

	/**
	 * Sets a callback function to be executed when an ad is closed.
	 * @param callback The function to call with the ad type.
	 */
	onAdClosed(callback: (adType: AdType) => void): void {
		this.adClosedCallback = callback;
		this.setupProviderCallbacks();
	}
}
