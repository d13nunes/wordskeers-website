<script lang="ts">
	import { onDestroy, onMount, type Snippet } from 'svelte';
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
	import { analytics } from '$lib/analytics/analytics';
	import DailyQuoteTag from '$lib/daily-challenge/DailyQuoteTag.svelte';
	import { fade, fly, slide } from 'svelte/transition';
	import QuotePage from '$lib/daily-challenge/QuoteModal.svelte';
	import { page } from '$app/state';
	import {
		getIsTodaysQuoteAvailableStore,
		getTodaysQuote
	} from '$lib/daily-challenge/quote-fetcher';
	import { beforeNavigate, goto } from '$app/navigation';
	import type { Unsubscriber } from 'svelte/store';
	import { appStateManager } from '$lib/utils/app-state';
	import { onGameSelectionAppear, OnAppearAction } from '$lib/logic/on-game-selection-actions';
	import LevelsTag from '$lib/components/Levels/LevelsTag.svelte';
	import ClassicTag from '$lib/components/Classic/ClassicTag.svelte';
	import { isGameModeSelectionClassic, toggleGameMode, updateTagState } from '$lib/tag-store';
	import { DailyRewardsNotifications } from '$lib/rewards/daily-rewards.notifications';

	interface Props {
		children: Snippet;
	}

	const { children }: Props = $props();
	let isDailyRewardsOpen = $state(false);
	let isStoreOpen = $state(false);
	let isSmallScreen = $state(false);
	let isQuoteAvailable = $state(false);
	let showQuoteModal = $state(false);
	let showBadge = $state(false);
	let isRootPage = $state(false);
	let isDailyQuoteVisible = $derived(isRootPage && isQuoteAvailable);

	initialize();
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

	export async function onDailyQuoteClick() {
		const todaysQuote = await getTodaysQuote();
		if (!todaysQuote) {
			return;
		}
		goto(`/game?dailyChallengeId=${todaysQuote.id}&difficulty=challenge`);
	}

	let unsubscribeQuoteAvailable: Unsubscriber | undefined;
	let unsubscribeAppState: (() => void) | undefined;

	let onAppearTimeout: NodeJS.Timeout | null = null;
	let showClassicTag = $state(false);

	onDestroy(() => {
		unsubscribeQuoteAvailable?.();
		if (onAppearTimeout) {
			clearTimeout(onAppearTimeout);
		}
	});

	onMount(async () => {
		isSmallScreen = getIsSmallScreen();
		await adStore.initialize();
		const success = await adStore.showAd(AdType.Banner, null);
		console.log('📺 BannerAd shown', success);
		showBadge = true;
		isRootPage = page.route?.id === '/';
		unsubscribeQuoteAvailable = (await getIsTodaysQuoteAvailableStore()).subscribe(
			(isAvailable: boolean) => {
				isQuoteAvailable = isAvailable;
			}
		);
		isGameModeSelectionClassic.subscribe((value) => {
			showClassicTag = value;
		});

		// Check if notifications are enabled
		const permissionStatus = await DailyRewardsNotifications.initializeNotifications();
		if (permissionStatus?.display === 'prompt') {
			DailyRewardsNotifications.requestPermissions();
		}
	});
	let lastTimePermissionPrompted: Date | null = null;
	const popupCooldown = 1000 * 60 * 10; // 2 minutes

	function showOnAppearPopup(delay: number = 300) {
		if (
			lastTimePermissionPrompted &&
			lastTimePermissionPrompted.getTime() + popupCooldown > Date.now()
		) {
			return;
		}
		lastTimePermissionPrompted = new Date();
		onAppearTimeout = setTimeout(async () => {
			const onAppearAction = await onGameSelectionAppear();
			switch (onAppearAction) {
				case OnAppearAction.ShowQuoteModal:
					showQuoteModal = true;
					break;
				case OnAppearAction.ShowRewardModal:
					isDailyRewardsOpen = true;
					break;
				default:
			}
		}, delay);
	}

	$effect(() => {
		// Subscribe to app state changes
		unsubscribeAppState = appStateManager.subscribe((isActive: boolean) => {
			if (isActive && isRootPage) {
				updateTagState();
				showOnAppearPopup();
			}
		});

		// Cleanup subscription when component unmounts
		return () => {
			if (unsubscribeAppState) {
				unsubscribeAppState();
			}
		};
	});
	beforeNavigate((navigation) => {
		isRootPage = navigation.to?.route?.id === '/';
		showBadge = true;

		if (isRootPage) {
			showOnAppearPopup(500);
		}
	});
</script>

<main class="flex flex-col bg-slate-50 select-none">
	{#if showQuoteModal}
		<QuotePage
			onClickPlay={() => (showQuoteModal = false)}
			onClickClose={() => (showQuoteModal = false)}
		/>
	{/if}
	<div
		class="z-[100] mx-4 mt-2 flex flex-row items-center justify-end gap-2 md:mx-4 {isSmallScreen
			? 'landscape:justify-start'
			: ''} "
	>
		{#if isDailyQuoteVisible}
			<div in:fade={{ duration: 200 }} out:fade={{ duration: 200 }}>
				<DailyQuoteTag onclick={onDailyQuoteClick} />
			</div>
		{/if}
		{#if isRootPage}
			<div in:fade={{ duration: 200 }} out:fade={{ duration: 200 }}>
				<DailyRewardTag onclick={onDailyRewardClick} />
			</div>
			<div
				class="flex h-8 flex-row lg:h-10"
				in:slide={{ duration: 200, axis: 'x' }}
				out:fade={{ duration: 200 }}
			>
				{#if !showClassicTag}
					<div
						in:slide={{ duration: 200, delay: 250, axis: 'x' }}
						out:slide={{ duration: 200, axis: 'x' }}
					>
						<ClassicTag onclick={toggleGameMode} />
					</div>
				{:else}
					<div
						in:slide={{ duration: 200, delay: 250, axis: 'x' }}
						out:slide={{ duration: 200, axis: 'x' }}
					>
						<LevelsTag onclick={toggleGameMode} />
					</div>
				{/if}
			</div>
		{/if}
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
