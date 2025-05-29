import { AdMob } from '@capacitor-community/admob';
import { writable, type Readable, derived } from 'svelte/store';
import { AdType } from './ads-types';
import { AdmobReward } from './Admob/admob-reward';
import { AdmobInterstitial } from './Admob/admob-interstitial';
import { AdmobRewardInterstitial } from './Admob/admob-rewardinterstitial';
import { AdmobBanner } from './Admob/admob-banner';
import type { AdProvider } from './ads-types';
import { walletStore } from '$lib/economy/walletStore';
import { Capacitor } from '@capacitor/core';

interface AdmobAdIds {
	interstitial: string;
	rewardInterstitial: string;
	reward: string;
	banner: string;
}

const admobAdIdsDebug: AdmobAdIds = {
	interstitial: 'ca-app-pub-3940256099942544/4411468910',
	rewardInterstitial: 'ca-app-pub-3940256099942544/6978759866',
	reward: 'ca-app-pub-3940256099942544/1712485313',
	banner: 'ca-app-pub-3940256099942544/2934735716'
};

const admobAdIdsProductionIOS: AdmobAdIds = {
	banner: 'ca-app-pub-9539843520256562/1015855733',
	interstitial: 'ca-app-pub-9539843520256562/2545593663',
	rewardInterstitial: 'ca-app-pub-9539843520256562/5270995200',
	reward: 'ca-app-pub-9539843520256562/3226451648'
};
const admobAdIdsProductionAndroid: AdmobAdIds = {
	banner: 'ca-app-pub-9539843520256562/2262611927',
	interstitial: 'ca-app-pub-9539843520256562/8306519367',
	rewardInterstitial: 'ca-app-pub-9539843520256562/1328804202',
	reward: 'ca-app-pub-9539843520256562/9667229737'
};
// Initialize with debug ads by default
let admobAdIds: AdmobAdIds = admobAdIdsDebug;

// Access query parameters
const isDev = import.meta.env.VITE_CAPACITOR_IS_DEV;

if (!isDev) {
	if (Capacitor.getPlatform() === 'ios') {
		console.log('Loaded Ads Production iOS config');
		admobAdIds = admobAdIdsProductionIOS;
	} else if (Capacitor.getPlatform() === 'android') {
		console.log('Loaded Ads Production Android config');
		admobAdIds = admobAdIdsProductionAndroid;
	}
} else {
	console.log('Loaded Ads Debug config');
}
console.log('AdmobAdIds', admobAdIds);

const lastTimeAdShown: Record<AdType, Date> = {
	[AdType.Interstitial]: new Date(),
	[AdType.Rewarded]: new Date(),
	[AdType.RewardedInterstitial]: new Date(),
	[AdType.Banner]: new Date()
};

function createAdStore(adProviders: AdProvider[]) {
	let canShowInterstitial = false;
	walletStore.removeAds((removeAds) => {
		canShowInterstitial = !removeAds;
		if (removeAds) {
			// Hide banner ads when removeAds is true
			const bannerProvider = adProviders.find((ad) => ad.adType === AdType.Banner);
			if (bannerProvider && bannerProvider.hide) {
				bannerProvider.hide().catch((error) => {
					console.error('📺 Failed to hide banner ad:', error);
				});
			}
		}
	});
	const isInitialized = writable(false);

	// Create a derived store that allows subscribing to specific ad types
	const createAdTypeLoadingStore = (adType: AdType) => {
		const adProvider = adProviders.find((ad) => ad.adType === adType);
		if (!adProvider) {
			throw new Error(`📺 Ad provider for ${adType} not found`);
		}
		return derived(adProvider.isLoaded, ($state) => $state);
	};

	async function initialize(): Promise<void> {
		try {
			await AdMob.initialize();
			console.log('📺 AdMob initialized');
			isInitialized.set(true);

			const trackingInfo = await AdMob.trackingAuthorizationStatus();
			if (trackingInfo.status === 'notDetermined') {
				await AdMob.requestTrackingAuthorization();
			}

			const consentInfo = await AdMob.requestConsentInfo();

			console.log('📺 showing consent form');
			await AdMob.showConsentForm();
			// }
			console.log('📺 consent form shown', consentInfo);
		} catch (error) {
			console.error('📺 AdMob initialization error:', error);
		}
		await loadAllAds();
	}

	async function loadAllAds(): Promise<void> {
		adProviders.forEach(async (adProvider) => {
			loadAd(adProvider.adType);
		});
	}

	const removeAdAdType: AdType[] = [AdType.Interstitial, AdType.Banner];

	async function loadAd(adType: AdType): Promise<boolean> {
		const adProvider = adProviders.find((ad) => ad.adType === adType);
		if (!adProvider) {
			throw new Error(`📺 Ad provider for ${adType} not found`);
		}
		if (!canShowInterstitial && removeAdAdType.includes(adType)) {
			console.log('📺 not loading ad', adType, 'user has removed ads active');
			return false;
		}
		try {
			const result = await adProvider.load();
			console.log('📺 loaded ad', adType, result);
			return result;
		} catch (error) {
			console.log('📺 failed to load ad', adType, error);
			return false;
		}
	}

	function canShowBasedOnTime(adType: AdType, maxFrequencyMillis: number): boolean {
		const lastTime = lastTimeAdShown[adType];
		if (!lastTime) {
			return true;
		}
		const now = new Date();
		const diff = now.getTime() - lastTime.getTime();
		const canShow = diff > maxFrequencyMillis;
		return canShow;
	}

	async function showAd(adType: AdType, maxFrequencyMillis: number | null): Promise<boolean> {
		const adProvider = adProviders.find((ad) => ad.adType === adType);
		if (!adProvider) {
			throw new Error(`📺 Ad provider for ${adType} not found`);
		}
		if (!canShowInterstitial && removeAdAdType.includes(adType)) {
			console.log('📺 not showing ad', adType, 'user has removed ads active');
			return false;
		}

		if (maxFrequencyMillis && !canShowBasedOnTime(adType, maxFrequencyMillis)) {
			return false;
		}
		try {
			lastTimeAdShown[adType] = new Date();
			const success = await adProvider.show();
			adProvider.load();
			return success;
		} catch (error) {
			console.error(`📺 Error showing ${adType} ad:`, error);
			adProvider.load();
			return false;
		}
	}

	async function hideAd(adType: AdType): Promise<void> {
		const adProvider = adProviders.find((ad) => ad.adType === adType);
		if (!adProvider) {
			throw new Error(`📺 Ad provider for ${adType} not found`);
		}
		if (adProvider.hide === undefined) {
			throw new Error(`📺 Ad provider for ${adType} does not support hiding`);
		}
		return adProvider.hide();
	}

	return {
		isInitialized,
		initialize,
		loadAd,
		showAd,
		hideAd,
		getAdLoadingState: createAdTypeLoadingStore,
		isAdLoaded: (adType: AdType) => {
			const adProvider = adProviders.find((ad) => ad.adType === adType);
			if (!adProvider) {
				throw new Error(`📺 Ad provider for ${adType} not found`);
			}
			// Use the same derived store logic as getAdLoadingState
			return derived(adProvider.isLoaded, ($state) => $state);
		}
	};
}

interface AdStore {
	isInitialized: Readable<boolean>;
	initialize: () => Promise<void>;
	loadAd: (adType: AdType) => Promise<boolean>;
	showAd: (adType: AdType, maxFrequencyMillis: number | null) => Promise<boolean>;
	hideAd: (adType: AdType) => Promise<void>;
	isAdLoaded: (adType: AdType) => Readable<boolean>;
	getAdLoadingState: (adType: AdType) => Readable<boolean>;
}

const adProviders: AdProvider[] = [
	new AdmobInterstitial(admobAdIds.interstitial),
	new AdmobReward(admobAdIds.reward),
	new AdmobRewardInterstitial(admobAdIds.rewardInterstitial),
	new AdmobBanner(admobAdIds.banner)
];
export const adStore: AdStore = createAdStore(adProviders);
