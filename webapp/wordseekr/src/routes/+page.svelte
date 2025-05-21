<script lang="ts">
	import { goto } from '$app/navigation';
	import SegmentedSelector from '$lib/components/SegmentedSelector.svelte';
	import { Difficulty } from '$lib/game/difficulty';
	import { DifficultyConfigMap } from '$lib/game/difficulty-config-map';
	import { getRandonGridID, getUnplayedAndTotalForDifficulty } from '$lib/game/grid-fetcher';
	import { DirectionPresets } from '$lib/game/direction-presets';

	const difficulties = [
		{ value: Difficulty.VeryEasy, label: 'Very Easy' },
		{ value: Difficulty.Easy, label: 'Easy' },
		{ value: Difficulty.Medium, label: 'Medium' },
		{ value: Difficulty.Hard, label: 'Hard' }
	];

	let selectedDifficultyIndex = $state(0);
	let currentDifficultyIndex = 0;
	let directionsSymbols = $state('');
	let gridSize = $state(0);

	function onDifficultyChange(index: number) {
		selectedDifficultyIndex = index;
		const selectedDifficulty = difficulties[selectedDifficultyIndex].value;
		directionsSymbols = DirectionPresets[selectedDifficulty].join(', ');
		const config = DifficultyConfigMap.config(selectedDifficulty);
		gridSize = config.gridSize;
	}

	async function onPlayClick() {
		const selectedDifficulty = difficulties[selectedDifficultyIndex].value;
		// const { unplayed, total } = await getUnplayedAndTotalForDifficulty(selectedDifficulty);
		const id = await getRandonGridID(selectedDifficulty);
		goto(`/game?id=${id}`);
	}

	$effect(() => {
		const selectedDifficulty = difficulties[selectedDifficultyIndex].value;
		directionsSymbols = DirectionPresets[selectedDifficulty].join(' ');
		const config = DifficultyConfigMap.config(selectedDifficulty);
		gridSize = config.gridSize;
	});
</script>

<div class="fixed inset-0 z-50 bg-slate-50">
	<div class="relative flex h-screen items-end justify-center pb-[150px] lg:items-center lg:pb-0">
		<div class="flex max-w-2xl flex-col items-center justify-center">
			<div class="flex flex-col items-center justify-center gap-0">
				<span class="text-4xl font-bold lg:text-6xl">Classic</span>
				<span class="text-sm text-gray-500 lg:text-base">Game Mode</span>
			</div>
			<!-- Game Configuration Display -->
			<div class="mt-12 flex flex-col items-center gap-0">
				<div class="flex flex-row items-center justify-center gap-1">
					<span class="text-black-500 text-sm font-normal">Search for words in</span>
					<span class="text-black-500 text-sm font-bold">{gridSize}x{gridSize}</span>
					<span class="text-black-500 text-sm font-normal">grid</span>
				</div>
				<div class="flex flex-col items-center justify-center gap-0.5">
					<span class="text-black-500 text-sm font-normal">Words can be found in</span>
					<span class="text-black-500 text-sm font-bold">
						{directionsSymbols}
					</span>
				</div>
			</div>

			<!-- Difficulty Selector -->
			<div class="mt-4 w-full">
				<SegmentedSelector
					segments={difficulties.map((d) => d.label)}
					firstSelectedIndex={currentDifficultyIndex}
					onChange={onDifficultyChange}
				/>
			</div>

			<button
				class="button-active mt-8 w-full rounded-md bg-red-800 py-2 text-xl font-bold text-white"
				onclick={onPlayClick}
			>
				Play
			</button>
		</div>
	</div>
</div>
