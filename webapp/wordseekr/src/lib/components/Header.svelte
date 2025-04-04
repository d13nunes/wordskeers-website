<script lang="ts">
	import DailyRewardTag from '$lib/components/DailyRewards/DailyRewardTag.svelte';
	import BalanceTag from '$lib/components/Store/BalanceTag.svelte';

	function onDailyRewardClick() {
		console.log('daily reward clicked');
	}

	function onStoreClick() {
		console.log('store clicked');
	}
</script>

<div class="absolute top-12 right-12 flex flex-row gap-2">
	<DailyRewardTag tag="Daily Reward" onclick={onDailyRewardClick} />
	<BalanceTag onclick={onStoreClick} />
</div>
