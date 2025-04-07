<script lang="ts">
	import BalanceCard from '$lib/components/Store/BalanceCard.svelte';
	import LockDailyRewardCard from '$lib/components/DailyRewards/LockDailyRewardCard.svelte';
	import ClaimableDailyRewardCard from '$lib/components/DailyRewards/ClaimableDailyRewardCard.svelte';
	import DailyRewardTimerCard from '../../lib/components/DailyRewards/DailyRewardTimerCard.svelte';
	import DailyRewardsEnableNotificationCard from '$lib/components/DailyRewards/DailyRewardsEnableNotificationCard.svelte';

	function handleClaimDailyReward() {
		console.log('claim daily reward');
	}

	function handleWatchAd() {
		console.log('watch ad');
	}

	const endDate = new Date(Date.now() + 1000 * 60 * 60 * 24);

	const handleEnableNotification = () => {
		console.log('enable notification');
	};
</script>

<div class="h-svh bg-white select-none">
	<div class="flex flex-col items-stretch gap-2 p-4">
		<span class="self-center text-2xl font-bold">Daily Rewards</span>
		<BalanceCard />
		<!--!! daily reward locked -->
		<LockDailyRewardCard title="Daily Reward" detail="Watch ad to unlock" />
		<!--!! daily reward claimable -->
		<ClaimableDailyRewardCard
			title="Claim 100 coins"
			detail="Free Reward"
			isAd={false}
			onClick={handleClaimDailyReward}
		/>
		<ClaimableDailyRewardCard
			title="Claim 100 coins"
			detail="Free Reward"
			isAd={true}
			onClick={handleClaimDailyReward}
		/>
		<DailyRewardTimerCard {endDate} />
		<DailyRewardsEnableNotificationCard onClick={handleEnableNotification} />
	</div>
</div>
