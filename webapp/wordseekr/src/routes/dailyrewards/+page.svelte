<script lang="ts">
	import BalanceCard from '$lib/components/Store/BalanceCard.svelte';
	import DailyRewardCardLock from '$lib/components/DailyRewards/DailyRewardCardLock.svelte';
	import ClaimableDailyCardReward from '$lib/components/DailyRewards/DailyRewardCardClaimable.svelte';
	import DailyRewardCardTimer from '../../lib/components/DailyRewards/DailyRewardCardTimer.svelte';
	import DailyRewardsEnableCardNotification from '$lib/components/DailyRewards/DailyRewardsCardEnableNotification.svelte';
	import { dailyRewardsStore } from '$lib/rewards/daily-rewards.store';

	import { onMount } from 'svelte';
	import DailyRewardCardClaimed from '$lib/components/DailyRewards/DailyRewardCardClaimed.svelte';
	import { DailyRewardStatus } from '$lib/rewards/daily-reward.model';

	// Store subscriptions
	let rewards = $derived($dailyRewardsStore?.currentRewards ?? []);
	let claimedRewards = $derived(rewards.filter((r) => r.status === DailyRewardStatus.Claimed));
	let lockedRewards = $derived(rewards.filter((r) => r.status === DailyRewardStatus.Locked));
	let claimableRewards = $derived(rewards.filter((r) => r.status === DailyRewardStatus.Claimable));
	let resetRewardTimestamp = $derived($dailyRewardsStore?.resetRewardTimestamp);
	let hasClaimedFirstReward = $derived(($dailyRewardsStore?.rewardsCollectedToday ?? 0) > 0);

	async function handleClaimDailyReward(rewardId: string, requiresAd: boolean) {
		const result = await dailyRewardsStore.claimReward(rewardId);
		// TODO Animation
	}

	const handleEnableNotification = async () => {
		await dailyRewardsStore.setEnableNotifications(true);
	};

	onMount(() => {
		// Refresh the state when the component mounts
		dailyRewardsStore.refresh();
	});
</script>

<div class="h-svh bg-white select-none">
	<div class="flex flex-col items-stretch gap-2 px-4 pt-5">
		<h1 class="mb-2 self-center text-2xl font-bold">Daily Rewards</h1>
		<BalanceCard />

		{#if resetRewardTimestamp}
			<DailyRewardCardTimer endDate={new Date(resetRewardTimestamp)} />
		{/if}
		{#each claimedRewards as reward (reward.id)}
			<DailyRewardCardClaimed title={`Earned ${reward.coins} coins`} detail="Claimed" />
		{/each}

		{#each lockedRewards as reward (reward.id)}
			<DailyRewardCardLock
				title="Daily Reward"
				detail={reward.requiresAd ? 'Watch ad to unlock' : 'Not available yet'}
			/>
		{/each}

		{#each claimableRewards as reward (reward.id)}
			<ClaimableDailyCardReward
				title={`Claim ${reward.coins} coins`}
				detail={'Free Coins'}
				isAd={reward.requiresAd}
				onClick={() => handleClaimDailyReward(reward.id, reward.requiresAd)}
			/>
		{/each}

		{#if hasClaimedFirstReward && !$dailyRewardsStore?.notificationsEnabled}
			<DailyRewardsEnableCardNotification onClick={handleEnableNotification} />
		{/if}
	</div>
</div>
