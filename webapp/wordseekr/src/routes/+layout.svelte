<script lang="ts">
	import { onMount, type Snippet } from 'svelte';
	import '../app.css';
	import DailyRewardTag from '$lib/components/DailyRewards/DailyRewardTag.svelte';
	import BalanceTag from '$lib/components/Store/BalanceTag.svelte';
	import BottomSheet from '$lib/components/shared/BottomSheet.svelte';
	import DailyRewards from './dailyrewards/+page.svelte';
	import Store from './store/+page.svelte';
	import ModalHost from '$lib/components/shared/ModalHost.svelte';
	import { adStore } from '$lib/ads/ads';
	import { AdType } from '$lib/ads/ads-types';
	import { initialize } from '@capacitor-community/safe-area';
	import { getIsSmallScreen } from '$lib/utils/utils';
	import { animate } from 'animejs';
	import { analytics } from '$lib/analytics/analytics';
	interface Props {
		children: Snippet;
	}

	const { children }: Props = $props();

	let isDailyRewardsOpen = $state(false);
	let isStoreOpen = $state(false);

	function onStoreClick() {
		if (!isStoreOpen) {
			analytics.storedOpen();
		}
		isStoreOpen = true;
		isDailyRewardsOpen = false;
	}

	function onDailyRewardClick() {
		if (!isDailyRewardsOpen) {
			analytics.rewardsOpen();
		}
		isDailyRewardsOpen = true;
		isStoreOpen = false;
	}

	initialize();

	let isSmallScreen = $state(false);

	onMount(async () => {
		isSmallScreen = getIsSmallScreen();
		await adStore.initialize();
		const success = await adStore.showAd(AdType.Banner, null);
		console.log('📺 BannerAd shown', success);
		showBadge = true;
		const badges = document.getElementById('badges');
		if (badges) {
			animate(badges, {
				opacity: [0, 1],
				duration: 300,
				delay: 300
			});
		}
	});
	let showBadge = $state(false);
</script>

<main class="flex flex-col bg-slate-50 select-none">
	<!-- {#if showBadge} -->
	<div
		id="badges"
		class="z-[100] mx-4 mt-2 flex flex-row items-center justify-end gap-2 opacity-0 md:mx-4 {isSmallScreen
			? 'landscape:justify-start'
			: ''} "
	>
		<DailyRewardTag tag="Rewards" onclick={onDailyRewardClick} />
		<BalanceTag onclick={onStoreClick} />
	</div>
	<!-- {/if} -->
	{@render children()}

	<BottomSheet visible={isDailyRewardsOpen} close={() => (isDailyRewardsOpen = false)}>
		<DailyRewards />
	</BottomSheet>
	<BottomSheet visible={isStoreOpen} close={() => (isStoreOpen = false)}>
		<Store />
	</BottomSheet>
	<ModalHost />
</main>

<style>
	main {
		padding-top: var(--safe-area-inset-top);
		padding-right: var(--safe-area-inset-right);
		padding-bottom: var(--safe-area-inset-bottom);
		padding-left: var(--safe-area-inset-left);
		min-height: 100vh;
		box-sizing: border-box;
		overflow-y: auto; /* Make main scrollable */
		-webkit-overflow-scrolling: touch; /* Improve iOS scrolling */
	}
</style>
