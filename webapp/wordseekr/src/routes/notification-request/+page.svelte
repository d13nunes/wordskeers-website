<script lang="ts">
	import GameModeIconTitle from '$lib/components/GameModeIconTitle.svelte';
	import Modal from '$lib/components/Modal.svelte';
	import { onDestroy, onMount } from 'svelte';
	import { Capacitor } from '@capacitor/core';
	import { analytics } from '$lib/analytics/analytics';
	import { LocalNotifications } from '@capacitor/local-notifications';
	import { DailyRewardsNotifications } from '$lib/rewards/daily-rewards.notifications';
	import { dailyRewardsStore } from '$lib/rewards/daily-rewards.store';
	import { ensureScheduledNotificationForTheNNextDay } from '$lib/daily-challenge/quote-fetcher';
	import { myLocalStorage } from '$lib/storage/local-storage';

	interface Props {
		onClose?: () => void;
	}
	const { onClose }: Props = $props();

	let hasRequestedPermission = $state(false);

	function onDontShowAgain() {
		myLocalStorage.set(myLocalStorage.NotificationRequestDontShowAgain, 'true');
		closeModal();
	}

	async function onEnable() {
		console.log('onEnable');
		if (!Capacitor.isPluginAvailable('LocalNotifications')) {
			console.warn('📨LocalNotifications plugin not available');
			closeModal();
			return false;
		}
		if (hasRequestedPermission) {
			const result = await LocalNotifications.changeExactNotificationSetting();
			closeModal();
			return;
		}

		const result = await LocalNotifications.requestPermissions();
		switch (result.display) {
			case 'granted':
				analytics.track('notification_request_enabled', {});
				try {
					await DailyRewardsNotifications.initializeNotifications();
					await dailyRewardsStore.setEnableNotifications(true);
					await ensureScheduledNotificationForTheNNextDay(3, true);
				} catch (error) {}
				break;
			case 'denied':
				analytics.track('notification_request_denied', {});
				break;
			default:
				analytics.track('notification_request_denied', {});
				break;
		}
		closeModal();
	}

	let showDontShowAgain = $state(false);

	onMount(async () => {
		// Refresh the state when the component mounts
		const status = await LocalNotifications.checkPermissions();
		hasRequestedPermission = status.display === 'granted' || status.display === 'denied';
		const dontShowAgain = await myLocalStorage.get(
			myLocalStorage.NotificationRequestBeenShownAtLeastOnce
		);
		showDontShowAgain = dontShowAgain === 'true';
	});

	function closeModal() {
		myLocalStorage.set(myLocalStorage.NotificationRequestBeenShownAtLeastOnce, 'true');
		onClose?.();
	}
</script>

<Modal
	backgroundOpacity={50}
	onClose={closeModal}
	onDismiss={closeModal}
	canDismissOnBackground={true}
>
	<div class="mt-4 flex w-2xs max-w-sm flex-col items-center gap-4">
		<GameModeIconTitle icon={undefined} title="Notifications" subtitle="Don't Miss Out!" />
		<div class="text-md flex flex-col gap-2 text-xl">
			Enable notifications to get alerts when your rewards are ready to collect and new daily
			challenges are available. Stay on top of your game!
		</div>
		<div class="mt-2 flex w-full flex-col gap-4">
			<div class="mt-2 flex w-full flex-col gap-4">
				{#if showDontShowAgain}
					<button
						class="button-active mt-0 flex w-full flex-row items-center justify-center gap-2 rounded-md bg-red-800 px-4 py-2 text-xl font-bold text-white"
						onclick={onDontShowAgain}
					>
						Don't show again
					</button>
				{/if}
				<button
					class="button-active mt-0 flex w-full flex-row items-center justify-center gap-2 rounded-md bg-green-800 px-4 py-2 text-xl font-bold text-white"
					onclick={onEnable}
				>
					Enable
				</button>
			</div>
		</div>
	</div>
</Modal>
