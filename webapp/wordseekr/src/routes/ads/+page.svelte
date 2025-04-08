<script lang="ts">
	import { adStore } from '$lib/ads/ads';
	import { AdType } from '$lib/ads/ads-types';
	import { walletStore } from '$lib/economy/walletStore';

	async function handleAdClick(adType: AdType) {
		console.log(`Showing ${adType} ad...`);
		const success = await adStore.showAd(adType);
		console.log(`${adType} ad ${success ? 'shown successfully' : 'failed to show'}`);
		showAdResult = `${adType} ad ${success ? 'shown successfully' : 'failed to show'}`;
	}

	let isRewardedAvailable: boolean = $state(false);
	let isInterstitialAvailable: boolean = $state(false);
	let isRewardedInterstitialAvailable: boolean = $state(false);
	let isBannerAvailable: boolean = $state(false);
	let isRemoveAdsActive: boolean = $state(false);

	walletStore.removeAds((removeAds) => {
		isRemoveAdsActive = removeAds;
	});
	let isInitialized: boolean = $state(false);

	adStore.isInitialized.subscribe((value) => {
		isInitialized = value;
	});

	adStore.getAdLoadingState(AdType.Interstitial).subscribe((value) => {
		isInterstitialAvailable = value;
	});
	adStore.getAdLoadingState(AdType.Rewarded).subscribe((value) => {
		isRewardedAvailable = value;
	});
	adStore.getAdLoadingState(AdType.RewardedInterstitial).subscribe((value) => {
		isRewardedInterstitialAvailable = value;
	});
	adStore.getAdLoadingState(AdType.Banner).subscribe((value) => {
		isBannerAvailable = value;
	});

	function setRemoveAds(isActive: boolean) {
		walletStore.setRemoveAds(isActive);
	}
	let showAdResult = $state('');
</script>

<div class="h-svh bg-white p-4 pt-32 select-none">
	<div class="flex flex-col items-start gap-4">
		<h1 class=" text-2xl font-bold">Ad Testing</h1>
		<div class="h-8 w-full bg-gray-100">{showAdResult}</div>
		<div class="flex flex-row items-start gap-4">
			<button
				class="rounded-lg bg-gray-100 px-4 py-2 text-black transition-colors"
				onclick={() => setRemoveAds(true)}>Set Remove Ads</button
			><button
				class="rounded-lg bg-gray-100 px-4 py-2 text-black transition-colors"
				onclick={() => setRemoveAds(false)}>Unset Remove Ads</button
			>
		</div>
		<div class="flex flex-row flex-wrap items-start gap-4">
			<button
				class="rounded-lg bg-gray-100 px-4 py-2 text-black transition-colors"
				onclick={() => handleAdClick(AdType.Interstitial)}>Show Interstitial</button
			>
			<button
				class="rounded-lg bg-gray-100 px-4 py-2 text-black transition-colors"
				onclick={() => handleAdClick(AdType.Rewarded)}>Show Rewarded</button
			>
			<button
				class="rounded-lg bg-gray-100 px-4 py-2 text-black transition-colors"
				onclick={() => handleAdClick(AdType.RewardedInterstitial)}
				>Show Rewarded Interstitial</button
			>
			<button
				class="rounded-lg bg-gray-100 px-4 py-2 text-black transition-colors"
				onclick={() => handleAdClick(AdType.Banner)}>Refresh Banner</button
			>
			<button
				class="rounded-lg bg-gray-100 px-4 py-2 text-black transition-colors"
				onclick={() => adStore.hideAd(AdType.Banner)}>Hide Banner</button
			>
			<button
				class="rounded-lg bg-gray-100 px-4 py-2 text-black transition-colors"
				onclick={() => adStore.loadAd(AdType.RewardedInterstitial)}
				>Load Rewarded Interstitial</button
			>
		</div>
		<div class="h-8 w-full bg-gray-100">
			isInitialized: {isInitialized ? 'Yes' : 'No'}
		</div>
		<div class="h-8 w-full bg-gray-100">Interstitial: {isInterstitialAvailable}</div>
		<div class="h-8 w-full bg-gray-100">Rewarded: {isRewardedAvailable}</div>
		<div class="h-8 w-full bg-gray-100">
			Rewarded Interstitial: {isRewardedInterstitialAvailable}
		</div>
		<div class="h-8 w-full bg-gray-100">
			Remove Ads Active: {isRemoveAdsActive ? 'Yes' : 'No'}
		</div>
		<div class="h-8 w-full bg-gray-100">Banner: {isBannerAvailable}</div>

		<div class="mt-4 rounded-lg bg-gray-100 p-4">
			<h2 class="mb-2 text-lg font-semibold">Debug Info</h2>
			<div class="space-y-1 text-sm">
				<p>Initialized: {isInitialized ? 'Yes' : 'No'}</p>
				<!-- <p>Banner Showing: {$isBannerShowing ? 'Yes' : 'No'}</p> -->
			</div>
		</div>
	</div>
</div>
