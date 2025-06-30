<script lang="ts">
	import { onDestroy, onMount, type Snippet } from 'svelte';
	import '../app.css';
	import DailyRewardTag from '$lib/components/DailyRewards/DailyRewardTag.svelte';
	import BalanceTag from '$lib/components/Store/BalanceTag.svelte';
	import DailyRewards from './dailyrewards/+page.svelte';
	import Store from './store/+page.svelte';
	import ModalHost from '$lib/components/shared/ModalHost.svelte';
	import { adStore } from '$lib/ads/ads';
	import { AdType } from '$lib/ads/ads-types';
	import { initialize } from '@capacitor-community/safe-area';
	import { getIsSmallScreen } from '$lib/utils/utils';
	import { analytics } from '$lib/analytics/analytics';
	import DailyQuoteTag from '$lib/daily-challenge/DailyQuoteTag.svelte';
	import { fade, slide } from 'svelte/transition';
	import { page } from '$app/state';
	import { ensureScheduledNotificationForTheNNextDay } from '$lib/daily-challenge/quote-fetcher';
	import { appStateManager } from '$lib/utils/app-state';
	import { onGameSelectionAppear, OnAppearAction } from '$lib/logic/on-game-selection-actions';
	import LevelsTag from '$lib/components/Levels/LevelsTag.svelte';
	import ClassicTag from '$lib/components/Classic/ClassicTag.svelte';
	import {
		isGameModeSelectionClassic,
		openStoreModal,
		showQuoteModalStore,
		toggleGameMode,
		updateTagState
	} from '$lib/tag-store';
	import { myLocalStorage } from '$lib/storage/local-storage';
	import { LocalNotifications } from '@capacitor/local-notifications';
	import QuotePage from '$lib/daily-challenge/QuoteModal.svelte';
	import {
		QUOTE_TODAY_NOTIFICATION_ID_END,
		QUOTE_TODAY_NOTIFICATION_ID_START
	} from '$lib/rewards/daily-rewards.config';
	import QuotesModal from './quotes/+page.svelte';
	import NotificationRequest from './notification-request/+page.svelte';
	import { onNavigate } from '$app/navigation';
	import { Capacitor } from '@capacitor/core';

	interface Props {
		children: Snippet;
	}

	const { children }: Props = $props();
	let isDailyRewardsOpen = $state(false);
	let isNotificationRequestOpen = $state(false);
	let isQuotesModalOpen = $state(false);
	let isStoreOpen = $derived($openStoreModal);
	let isSmallScreen = $state(false);

	let showQuoteModal = $state(false);
	let isMainMenu = $state(false);
	let isWelcomeModalVisible = $state(false);
	let showBalanceTag = $state(false);
	let unsubscribeAppState: (() => void) | undefined;

	let onAppearTimeout: NodeJS.Timeout | null = null;
	let showClassicTag = $state(false);

	let lastTimePermissionPrompted: Date | null = null;
	const popupCooldown = 1000 * 60 * 10; // 2 minutes
	initialize();

	function onStoreClick() {
		showQuoteModal = false;
		isDailyRewardsOpen = false;
		isQuotesModalOpen = false;
		if (isWelcomeModalVisible) {
			return;
		}
		if (!isStoreOpen) {
			analytics.storedOpen();
		}
		openStoreModal.set(true);
		isDailyRewardsOpen = false;
	}
	let canShowNotificationRequest = $state(false);
	async function onDailyRewardClick() {
		showQuoteModal = false;
		isDailyRewardsOpen = false;
		isQuotesModalOpen = false;
		hasNotificationPermission = (await LocalNotifications.checkPermissions()).display === 'granted';
		const dontShowAgain = await myLocalStorage.get(myLocalStorage.NotificationRequestDontShowAgain);
		canShowNotificationRequest = !hasNotificationPermission && dontShowAgain !== 'true';
		if (!isDailyRewardsOpen) {
			analytics.rewardsOpen();
		}
		isDailyRewardsOpen = true;
		openStoreModal.set(false);
	}

	export async function onDailyQuoteClick() {
		showQuoteModal = false;
		isDailyRewardsOpen = false;
		isQuotesModalOpen = true;
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

	function onNotEnoughCoinsToUnlockQuote() {
		showQuoteModal = false;
		isDailyRewardsOpen = false;
		isQuotesModalOpen = false;
		openStoreModal.set(true);
	}

	async function initAds() {
		console.log('📺 initAds');
		await adStore.initialize();
		console.log('📺 initAds layout - completed');
		const success = await adStore.showAd(AdType.Banner, null);
		console.log('📺 BannerAd shown', success);
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
			}
		};
	});

	onDestroy(() => {
		if (onAppearTimeout) {
			clearTimeout(onAppearTimeout);
		}
	});
	let hasNotificationPermission = false;

	onNavigate(async () => {
		isWelcomeModalVisible = false;
		if (!hasNotificationPermission && Capacitor.isPluginAvailable('LocalNotifications')) {
			hasNotificationPermission =
				(await LocalNotifications.checkPermissions()).display === 'granted';
		}
	});

	onMount(async () => {
		const welcomeModalClaimed = await myLocalStorage.get(myLocalStorage.WelcomeModalGiftClaimed);
		if (!welcomeModalClaimed) {
			isWelcomeModalVisible = true;
		} else {
			initAds();
			ensureScheduledNotificationForTheNNextDay(5);
		}
		showQuoteModalStore.subscribe((value) => {
			if (value) {
				showQuoteModal = true;
				showQuoteModalStore.set(false);
			}
		});
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

<main class="fixed inset-0 flex flex-col bg-slate-50 select-none">
	{#if showQuoteModal}
		<QuotePage
			onClickPlay={() => (showQuoteModal = false)}
			onClickClose={() => (showQuoteModal = false)}
		/>
	{/if}
	<div
		class="absolute mx-4 mt-2 flex flex-row items-center justify-end gap-2 md:mx-4 {isSmallScreen
			? 'landscape:justify-start'
			: ''} "
		style="right: calc(var(--safe-area-inset-right));
		left: calc(var(--safe-area-inset-left));"
	>
		{#if isMainMenu && !isWelcomeModalVisible}
			<div in:fade={{ duration: 200 }} out:fade={{ duration: 200 }}>
				<DailyQuoteTag onclick={onDailyQuoteClick} />
			</div>
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
			<BalanceTag
				onclick={onStoreClick}
				class=" {isQuotesModalOpen || showQuoteModal ? ' z-0 ' : 'z-[900] delay-500'}"
			/>
		{/if}
	</div>
	<div class="h-full w-full overflow-y-visible">
		{@render children()}
	</div>

	{#if isDailyRewardsOpen}
		<DailyRewards
			onClose={() => {
				isDailyRewardsOpen = false;
				isNotificationRequestOpen = canShowNotificationRequest;
			}}
		/>
	{/if}
	{#if isNotificationRequestOpen}
		<NotificationRequest
			onClose={() => {
				isNotificationRequestOpen = false;
			}}
		/>
	{/if}
	{#if isQuotesModalOpen}
		<QuotesModal
			onClose={() => (isQuotesModalOpen = false)}
			onNotEnoughCoinsToUnlock={onNotEnoughCoinsToUnlockQuote}
		/>
	{/if}
	{#if isStoreOpen}
		<Store onClose={() => openStoreModal.set(false)} />
	{/if}
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
		overflow: hidden; /* No scrollable */
	}
</style>
