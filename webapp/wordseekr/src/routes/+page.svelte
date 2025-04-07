<script lang="ts">
	import { goto } from '$app/navigation';
	import DailyRewardTag from '$lib/components/DailyRewards/DailyRewardTag.svelte';
	import DailyRewards from './dailyrewards/+page.svelte';
	import Store from './store/+page.svelte';

	import SegmentedSelector from '$lib/components/SegmentedSelector.svelte';
	import BottomSheet from '$lib/components/shared/BottomSheet.svelte';
	import BalanceTag from '$lib/components/Store/BalanceTag.svelte';
	let size = 6;
	let directions: string[] = ['up', 'down', 'left', 'right'];
	let selectedDirection: string | null = null;

	let isDailyRewardsOpen = false;
	let isStoreOpen = false;

	function onDirectionChange(event: CustomEvent) {
		console.log(event);
	}
	function onStoreClick() {
		//goto('/store');
		isStoreOpen = true;
	}
	function onPlayClick() {
		goto('/game');
	}
	function onDailyRewardClick() {
		isDailyRewardsOpen = true;
	}
</script>

<div class="bg-slate-50 p-6">
	<div class="relative flex h-screen items-end justify-center pb-[150px] lg:items-center lg:pb-0">
		<div class="flex max-w-2xl flex-col items-center justify-center">
			<div class="flex flex-col items-center justify-center gap-0">
				<span class="text-4xl font-bold lg:text-6xl">Classic</span>
				<span class="text-sm text-gray-500 lg:text-base">Game Mode</span>
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
				class="button-active mt-12 w-full rounded-md bg-red-800 py-2 text-xl font-bold text-white"
				onclick={onPlayClick}
			>
				Play
			</button>
		</div>
	</div>

	<BottomSheet visible={isDailyRewardsOpen} close={() => (isDailyRewardsOpen = false)}>
		<DailyRewards />
	</BottomSheet>

	<BottomSheet visible={isStoreOpen} close={() => (isStoreOpen = false)}>
		<Store />
	</BottomSheet>
</div>
