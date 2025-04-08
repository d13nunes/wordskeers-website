import type { Readable } from 'svelte/store';

export enum AdType {
	Interstitial = 'interstitial',
	Rewarded = 'rewarded',
	RewardedInterstitial = 'rewardedInterstitial',
	Banner = 'banner'
}
export interface AdProvider {
	adType: AdType;
	load: () => Promise<boolean>;
	isLoaded: Readable<boolean>;
	show: () => Promise<boolean>;
	hide?: () => Promise<void>;
}
