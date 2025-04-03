<script lang="ts">
	import { goto } from '$app/navigation';
	import DailyRewardTag from '$lib/components/DailyRewards/DailyRewardTag.svelte';
	import DailyRewards from '../dailyrewards/+page.svelte';

	import SegmentedSelector from '$lib/components/SegmentedSelector.svelte';
	import BottomSheet from '$lib/components/shared/BottomSheet.svelte';
	import BalanceTag from '$lib/components/Store/BalanceTag.svelte';
	let size = 6;
	let directions: string[] = ['up', 'down', 'left', 'right'];
	let selectedDirection: string | null = null;

	let isDailyRewardsOpen = false;

	function onDirectionChange(event: CustomEvent) {
		console.log(event);
	}
	function onStoreClick() {
		goto('/store');
		console.log('store clicked');
	}
	function onPlayClick() {
		console.log('play clicked');
	}
	function onDailyRewardClick() {
		isDailyRewardsOpen = true;
		console.log('daily reward clicked');
	}
</script>

<div class="relative flex h-screen w-screen items-center justify-center bg-slate-50 p-6">
	<div class="absolute top-12 right-12 flex flex-row gap-2">
		<DailyRewardTag tag="Daily Reward" onClick={onDailyRewardClick} />
		<BalanceTag balance={100} onClick={onStoreClick} />
	</div>
	<div class="flex max-w-2xl flex-col items-center justify-center">
		<div class="flex flex-col items-center justify-center gap-0">
			<span class="text-4xl font-bold">Classic</span>
			<span class="text-sm text-gray-500">Game Mode</span>
		</div>
		<div class="mt-12 flex flex-row items-center justify-center gap-1">
			<span class="text-black-500 text-sm font-normal">Search for words in</span>
			<span class="text-black-500 text-sm font-bold">{size}x{size}</span>
			<span class="text-black-500 text-sm font-normal">grid</span>
		</div>
		<div class="mb-2 flex flex-row items-center justify-center gap-1">
			<span class="text-black-500 text-sm font-normal">Words can found in</span>
			{#each directions as direction}
				<span class="text-black-500 text-sm font-bold">{direction}</span>
			{/each}
		</div>
		<SegmentedSelector
			segments={directions}
			selected={selectedDirection}
			on:change={onDirectionChange}
		/>

		<button
			class="mt-12 w-full rounded-md bg-red-800 py-2 text-xl font-bold text-white"
			onclick={onPlayClick}
		>
			Play
		</button>
	</div>
</div>

<BottomSheet visible={isDailyRewardsOpen} close={() => (isDailyRewardsOpen = false)}>
	<DailyRewards />
</BottomSheet>
