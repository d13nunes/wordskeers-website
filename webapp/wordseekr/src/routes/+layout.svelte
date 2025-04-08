<script lang="ts">
	import type { Snippet } from 'svelte';
	import '../app.css';
	import DailyRewardTag from '$lib/components/DailyRewards/DailyRewardTag.svelte';
	import BalanceTag from '$lib/components/Store/BalanceTag.svelte';
	import BottomSheet from '$lib/components/shared/BottomSheet.svelte';
	import DailyRewards from './dailyrewards/+page.svelte';
	import Store from './store/+page.svelte';

	interface Props {
		children: Snippet;
	}

	const { children }: Props = $props();

	let isDailyRewardsOpen = $state(false);
	let isStoreOpen = $state(false);

	function onStoreClick() {
		console.log('store clicked');
		isStoreOpen = true;
		isDailyRewardsOpen = false;
	}

	function onDailyRewardClick() {
		console.log('daily rewards clicked');
		isDailyRewardsOpen = true;
		isStoreOpen = false;
	}

	function cenas() {
		console.log('cenas clicked');
	}
</script>

<div class="pt-safe-top pb-safe-bottom px-safe-left pr-safe-right min-h-screen bg-slate-50">
	<div class="absolute top-16 right-4 z-[100] flex flex-row gap-2 lg:top-8">
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
</div>
