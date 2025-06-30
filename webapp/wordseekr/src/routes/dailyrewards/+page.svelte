<script lang="ts">
	import GameModeIconTitle from '$lib/components/GameModeIconTitle.svelte';
	import LevelsGiftIcon from '$lib/components/Levels/LevelsGiftIcon.svelte';
	import Modal from '$lib/components/Modal.svelte';
	import { adStore } from '$lib/ads/ads';
	import { AdType } from '$lib/ads/ads-types';
	import { adsIconBase64 } from '$lib/utils/utils';
	import { onMount } from 'svelte';
	import { dailyRewardsStore } from '$lib/rewards/daily-rewards.store';

	import RewardTimer from '$lib/components/DailyRewards/RewardTimer.svelte';
	import type { DailyRewardsState } from '$lib/rewards/daily-rewards.state';
	import { DailyRewardStatus } from '$lib/rewards/daily-reward.model';
	import { updateTagState } from '$lib/tag-store';
	import { walletStore } from '$lib/economy/walletStore';
	import { fade, fly } from 'svelte/transition';

	interface Props {
		onClose?: () => void;
	}
	const { onClose }: Props = $props();

	let canAnimateReward = $state(false);
	let buttonDisabled = $state(false);
	let showDoubleButton = $state(false);
	let rewardAvailable = $state(false);
	let rewards = $derived($dailyRewardsStore?.currentRewards ?? []);
	let claimableRewards = $derived(rewards.filter((r) => r.status === DailyRewardStatus.Claimable));
	let resetRewardTimestamp = $derived($dailyRewardsStore?.resetRewardDate);
	let canAnimateShake = $derived(resetRewardTimestamp ? false : true);

	let didWatchAd = false;

	let rewardsState = $state<DailyRewardsState | null>(null);

	onMount(() => {
		// Refresh the state when the component mounts
		dailyRewardsStore.refresh();
		dailyRewardsStore.subscribe((state) => {
			rewardsState = state;
			rewardAvailable = state?.rewardsCollectedToday === 0;
		});
		adStore.getAdLoadingState(AdType.Rewarded).subscribe((isReady: boolean) => {
			showDoubleButton = isReady;
		});
	});

	async function handleClaimDailyReward(requiresAd: boolean) {
		if (requiresAd) {
			didWatchAd = await adStore.showAd(AdType.Rewarded, null);
			if (!didWatchAd) {
				return false;
			}
		}
		canAnimateReward = true;
	}

	async function onClickContinue() {
		buttonDisabled = true;
		await handleClaimDailyReward(false);
		buttonDisabled = false;
	}

	async function onClickDouble() {
		buttonDisabled = true;
		await handleClaimDailyReward(true);
		buttonDisabled = false;
	}

	async function onGiftClick() {
		console.log('onGiftClick', buttonDisabled, resetRewardTimestamp);
		if (buttonDisabled) {
			console.log('onGiftClick not', buttonDisabled, resetRewardTimestamp);
			return;
		}
		if (resetRewardTimestamp) {
			canAnimateShake = true;
			setTimeout(() => {
				canAnimateShake = false;
			}, 1000);
			return;
		}
		buttonDisabled = true;
		await handleClaimDailyReward(showDoubleButton);
		buttonDisabled = false;
	}

	async function onRewardGiven() {
		const currentReward = claimableRewards[0];
		if (!currentReward) {
			console.log('onRewardGiven no current reward');
			return;
		}
		const prize = currentReward.coins * (didWatchAd ? 2 : 1);
		console.log('onRewardGiven', prize);
		const markRewardHasClaimed = await dailyRewardsStore.markRewardHasClaimed(currentReward.id);
		console.log('markRewardHasClaimed', markRewardHasClaimed);
		if (!markRewardHasClaimed) {
			return;
		}
		walletStore.addCoins(prize);
	}

	async function onRewardAnimationCompleted() {
		const result = await dailyRewardsStore.markRewardHasClaimed(
			rewardsState?.currentRewards[0].id ?? ''
		);
		console.log('onRewardAnimationCompleted', result);
		updateTagState();
		onClose?.();
	}

	const onDismiss = $derived(canAnimateReward ? undefined : onClose);
</script>

<Modal backgroundOpacity={50} {onClose} {onDismiss} canDismissOnBackground={!buttonDisabled}>
	<div class="mt-4 flex h-[330px] max-w-sm min-w-2xs flex-col items-center gap-4">
		<GameModeIconTitle icon={undefined} title="Reward" subtitle="Collect your free reward" />
		<button class="mt-2" onclick={onGiftClick}>
			<LevelsGiftIcon
				id="reward"
				animateCoin={canAnimateReward}
				isAnimating={canAnimateShake}
				onGiveReward={onRewardGiven}
				onCoinAnimationCompleted={onRewardAnimationCompleted}
			/>
		</button>

		<div class="mt-2 flex w-full flex-col gap-4">
			{#if rewardAvailable}
				<div in:fade={{ duration: 200, delay: 200 }} class="mt-2 flex w-full flex-row gap-4">
					<button
						class="button-active mt-0 flex w-full flex-row items-center justify-center gap-2 rounded-md bg-blue-800 px-4 py-2 text-xl font-bold text-white"
						disabled={buttonDisabled}
						onclick={onClickContinue}
					>
						Collect
					</button>
					{#if showDoubleButton}
						<button
							class="button-active mt-0 flex w-full flex-row items-center justify-center gap-1 rounded-md bg-green-800 px-4 py-2 text-xl font-bold text-white"
							disabled={buttonDisabled}
							onclick={onClickDouble}
						>
							<img class="h-5 w-5" src={adsIconBase64} alt="" />
							Double
						</button>
					{/if}
				</div>
			{/if}
			{#if resetRewardTimestamp}
				<div
					in:fly={{ duration: 400, y: 100, opacity: 0 }}
					out:fade={{ duration: 400 }}
					class="flex flex-col gap-2"
				>
					<div class="text-center text-sm text-gray-500">Next reward available in:</div>
					<RewardTimer endDate={new Date(resetRewardTimestamp)} />
				</div>
			{:else}{/if}
		</div>
	</div>
</Modal>
