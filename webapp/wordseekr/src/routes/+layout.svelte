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
	import DatabaseInitializer from '$lib/database/DatabaseInitializer.svelte';
	import { initialize } from '@capacitor-community/safe-area';
	import { getIsSmallScreen } from '$lib/utils/utils';
	interface Props {
		children: Snippet;
	}

	const { children }: Props = $props();

	let isDailyRewardsOpen = $state(false);
	let isStoreOpen = $state(false);

	function onStoreClick() {
		isStoreOpen = true;
		isDailyRewardsOpen = false;
	}

	function onDailyRewardClick() {
		isDailyRewardsOpen = true;
		isStoreOpen = false;
	}

	initialize();

	let isSmallScreen = $state(false);

	onMount(async () => {
		isSmallScreen = getIsSmallScreen();
		await adStore.initialize();
		const success = await adStore.showAd(AdType.Banner);
		console.log('📺 BannerAd shown', success);
	});
</script>

<main class="flex flex-col bg-slate-50 select-none">
	<div
		class="z-[100] mx-2 mt-2 flex flex-row items-center justify-end gap-2 md:mx-4 {isSmallScreen
			? 'landscape:justify-start'
			: ''} "
	>
		<DailyRewardTag tag="Rewards" onclick={onDailyRewardClick} />
		<BalanceTag onclick={onStoreClick} />
	</div>
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
