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
		ensureScheduledNotificationForTheNNextDay,
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
	import { myLocalStorage } from '$lib/storage/local-storage';
	import WecolmeModal from '$lib/components/Levels/WecolmeModal.svelte';
	import { walletStore } from '$lib/economy/walletStore';
	import { LocalNotifications } from '@capacitor/local-notifications';
	import {
		QUOTE_TODAY_NOTIFICATION_ID_END,
		QUOTE_TODAY_NOTIFICATION_ID_START
	} from '$lib/rewards/daily-rewards.config';

	interface Props {
		children: Snippet;
	}

	const { children }: Props = $props();
	let isDailyRewardsOpen = $state(false);
	let isStoreOpen = $state(false);
	let isSmallScreen = $state(false);
	let isQuoteAvailable = $state(false);
	let showQuoteModal = $state(false);
	let isMainMenu = $state(false);
	let isWelcomeModalVisible = $state(false);
	let isDailyQuoteVisible = $derived(isMainMenu && isQuoteAvailable && !isWelcomeModalVisible);
	let showBalanceTag = $state(false);
	let unsubscribeQuoteAvailable: Unsubscriber | undefined;
	let unsubscribeAppState: (() => void) | undefined;

	let onAppearTimeout: NodeJS.Timeout | null = null;
	let showClassicTag = $state(false);

	let lastTimePermissionPrompted: Date | null = null;
	const popupCooldown = 1000 * 60 * 10; // 2 minutes
	initialize();

	function onStoreClick() {
		showQuoteModal = false;
		isDailyRewardsOpen = false;
		if (isWelcomeModalVisible) {
			return;
		}
		if (!isStoreOpen) {
			analytics.storedOpen();
		}
		isStoreOpen = true;
		isDailyRewardsOpen = false;
	}

	function onDailyRewardClick() {
		showQuoteModal = false;
		isDailyRewardsOpen = false;
		if (!isDailyRewardsOpen) {
			analytics.rewardsOpen();
		}
		isDailyRewardsOpen = true;
		isStoreOpen = false;
	}

	export async function onDailyQuoteClick() {
		showQuoteModal = false;
		isDailyRewardsOpen = false;
		const todaysQuote = await getTodaysQuote();

		if (!todaysQuote) {
			return;
		}
		goto(`/game?dailyChallengeId=${todaysQuote.id}&difficulty=challenge`);
	}

	function onGiveWelcomeReward() {
		walletStore.addCoins(350);
		myLocalStorage.set(myLocalStorage.WelcomeModalGiftClaimed, 'true');
	}
	async function onWelcomeCoinAnimationCompleted() {
		isWelcomeModalVisible = false;
		try {
			const permissionStatus = await DailyRewardsNotifications.initializeNotifications();
			if (permissionStatus?.display === 'prompt') {
				await DailyRewardsNotifications.requestPermissions();
			}
			subscribeToQuoteAvailable();
			ensureScheduledNotificationForTheNNextDay(5, true);
		} catch (error) {
			analytics.error(
				'error_welcome_notification_permission',
				error instanceof Error ? error.message : 'Unknown error'
			);
		}
		// Check if notifications are enabled
		await initAds();
	}

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
					showQuoteModal = !isWelcomeModalVisible;
					break;
				case OnAppearAction.ShowRewardModal:
					isDailyRewardsOpen = !isWelcomeModalVisible;
					break;
				default:
			}
		}, delay);
	}

	function onGameTagModeClick() {
		showQuoteModal = false;
		isDailyRewardsOpen = false;
		toggleGameMode();
	}

	async function initAds() {
		console.log('📺 initAds');
		await adStore.initialize();
		console.log('📺 initAds layout - completed');
		const success = await adStore.showAd(AdType.Banner, null);
		console.log('📺 BannerAd shown', success);
	}

	async function subscribeToQuoteAvailable() {
		if (unsubscribeQuoteAvailable) {
			unsubscribeQuoteAvailable();
		}
		unsubscribeQuoteAvailable = (await getIsTodaysQuoteAvailableStore()).subscribe(
			(isAvailable: boolean) => {
				isQuoteAvailable = isAvailable;
			}
		);
	}
	let count = 0;

	$effect(() => {
		// Subscribe to app state changes
		unsubscribeAppState = appStateManager.subscribe((isActive: boolean) => {
			if (isActive) {
				isMainMenu = page.url.pathname === '/main-menu';
				if (isMainMenu) {
					updateTagState();
					const delay = count > 0 ? 0 : 500;
					showOnAppearPopup(delay);
				}
			}
			count++;
		});

		// Cleanup subscription when component unmounts
		return () => {
			if (unsubscribeAppState) {
				unsubscribeAppState();
			}
		};
	});

	onDestroy(() => {
		unsubscribeQuoteAvailable?.();
		if (onAppearTimeout) {
			clearTimeout(onAppearTimeout);
		}
	});

	onMount(async () => {
		const welcomeModalClaimed = await myLocalStorage.get(myLocalStorage.WelcomeModalGiftClaimed);
		if (!welcomeModalClaimed) {
			isWelcomeModalVisible = true;
		} else {
			initAds();
			subscribeToQuoteAvailable();
			ensureScheduledNotificationForTheNNextDay(5);
		}
		showBalanceTag = true;
		isSmallScreen = getIsSmallScreen();
		isGameModeSelectionClassic.subscribe((value) => {
			showClassicTag = value;
		});

		LocalNotifications.addListener('localNotificationActionPerformed', (action) => {
			if (
				action.notification.id >= QUOTE_TODAY_NOTIFICATION_ID_START &&
				action.notification.id <= QUOTE_TODAY_NOTIFICATION_ID_END
			) {
				showQuoteModal = true;
			}
		});
	});
</script>

<main class="flex flex-col bg-slate-50 select-none">
	{#if isWelcomeModalVisible}
		<WecolmeModal
			onGiveReward={onGiveWelcomeReward}
			onCoinAnimationCompleted={onWelcomeCoinAnimationCompleted}
		/>
	{/if}
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
		{#if isDailyQuoteVisible && !isWelcomeModalVisible}
			<div in:fade={{ duration: 200 }} out:fade={{ duration: 200 }}>
				<DailyQuoteTag onclick={onDailyQuoteClick} />
			</div>
		{/if}
		{#if isMainMenu && !isWelcomeModalVisible}
			<div in:fade={{ duration: 200 }} out:fade={{ duration: 200 }}>
				<DailyRewardTag onclick={onDailyRewardClick} />
			</div>
			<div
				class="flex h-8 flex-row lg:h-9"
				in:slide={{ duration: 200, axis: 'x' }}
				out:fade={{ duration: 200 }}
			>
				{#if !showClassicTag}
					<div
						in:slide={{ duration: 200, delay: 250, axis: 'x' }}
						out:slide={{ duration: 200, axis: 'x' }}
					>
						<ClassicTag onclick={onGameTagModeClick} />
					</div>
				{:else}
					<div
						in:slide={{ duration: 200, delay: 250, axis: 'x' }}
						out:slide={{ duration: 200, axis: 'x' }}
					>
						<LevelsTag onclick={onGameTagModeClick} />
					</div>
				{/if}
			</div>
		{/if}
		{#if showBalanceTag}
			<BalanceTag onclick={onStoreClick} />
		{/if}
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
