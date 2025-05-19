<script lang="ts">
	import { goto } from '$app/navigation';
	import SegmentedSelector from '$lib/components/SegmentedSelector.svelte';
	import { Difficulty } from '$lib/game/difficulty';
	import { DifficultyConfigMap } from '$lib/game/difficulty-config-map';
	import { DirectionName } from '$lib/components/Game/Direction';
	import { getRandomGridForDifficulty, getRandonGridID } from '$lib/game/grid-fetcher';

	let selectedDifficulty: Difficulty = Difficulty.Medium;
	const difficulties = [
		{ value: Difficulty.VeryEasy, label: 'Very Easy' },
		{ value: Difficulty.Easy, label: 'Easy' },
		{ value: Difficulty.Medium, label: 'Medium' },
		{ value: Difficulty.Hard, label: 'Hard' },
		{ value: Difficulty.VeryHard, label: 'Very Hard' }
	];

	$: currentConfig = DifficultyConfigMap.config(selectedDifficulty);
	$: directions = currentConfig.validDirections.map((d) => DirectionName[d.name].toLowerCase());

	function onDifficultyChange(event: CustomEvent) {
		selectedDifficulty = event.detail as Difficulty;
	}

	async function onPlayClick() {
		const id = await getRandonGridID(selectedDifficulty);
		console.log('id', id);
		goto(`/game?id=${id}`);
	}
</script>

<div class="bg-slate-50 p-6">
	<div class="relative flex h-screen items-end justify-center pb-[150px] lg:items-center lg:pb-0">
		<div class="flex max-w-2xl flex-col items-center justify-center">
			<div class="flex flex-col items-center justify-center gap-0">
				<span class="text-4xl font-bold lg:text-6xl">Classic</span>
				<span class="text-sm text-gray-500 lg:text-base">Game Mode</span>
			</div>
			<!-- Game Configuration Display -->
			<div class="mt-8 flex flex-col items-center gap-0">
				<div class="flex flex-row items-center justify-center gap-1">
					<span class="text-black-500 text-sm font-normal">Search for words in</span>
					<span class="text-black-500 text-sm font-bold"
						>{currentConfig.gridSize}x{currentConfig.gridSize}</span
					>
					<span class="text-black-500 text-sm font-normal">grid</span>
				</div>
				<div class="flex flex-row flex-wrap items-center justify-center gap-1">
					<span class="text-black-500 text-sm font-normal">Words can be found in</span>
					{#each directions as direction, i}
						<span class="text-black-500 text-sm font-bold">{direction}</span>
						{#if i < directions.length - 1}
							<span class="text-black-500 text-sm font-normal">,</span>
						{/if}
					{/each}
				</div>
			</div>

			<!-- Difficulty Selector -->
			<div class="mt-8 w-full">
				<SegmentedSelector
					segments={difficulties.map((d) => d.label)}
					selected={difficulties.find((d) => d.value === selectedDifficulty)?.label ?? null}
					on:change={onDifficultyChange}
				/>
			</div>

			<button
				class="button-active mt-12 w-full rounded-md bg-red-800 py-2 text-xl font-bold text-white"
				on:click={onPlayClick}
			>
				Play
			</button>
		</div>
	</div>
</div>
