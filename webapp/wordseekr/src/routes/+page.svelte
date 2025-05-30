<script lang="ts">
	import { goto } from '$app/navigation';
	import SegmentedSelector from '$lib/components/SegmentedSelector.svelte';
	import { Difficulty } from '$lib/game/difficulty';
	import { DifficultyConfigMap } from '$lib/game/difficulty-config-map';
	import { getRandomUnplayedGridID } from '$lib/game/grid-fetcher';
	import { DirectionPresets } from '$lib/game/direction-presets';
	import { onMount } from 'svelte';
	import { Preferences } from '@capacitor/preferences';
	import { getIsSmallScreen } from '$lib/utils/utils';

	const currentDifficultyKey = 'currentDifficulty';

	const difficulties = [
		{ value: Difficulty.VeryEasy, label: 'Very Easy' },
		{ value: Difficulty.Easy, label: 'Easy' },
		{ value: Difficulty.Medium, label: 'Medium' },
		{ value: Difficulty.Hard, label: 'Hard' }
	];

	let selectedDifficultyIndex = $state(0);
	let directionsSymbols = $state('');
	let gridSize = $state(0);
	let isSmallScreen = $state(false);

	onMount(() => {
		isSmallScreen = getIsSmallScreen();
	});

	function updateDifficulty(index: number) {
		selectedDifficultyIndex = index;
		const selectedDifficulty = difficulties[selectedDifficultyIndex].value;
		directionsSymbols = DirectionPresets[selectedDifficulty].join(', ');
		const config = DifficultyConfigMap.config(selectedDifficulty);
		gridSize = config.gridSize;
	}

	function onDifficultyChange(index: number) {
		updateDifficulty(index);
		Preferences.set({ key: currentDifficultyKey, value: index.toString() });
	}

	async function onPlayClick() {
		const selectedDifficulty = difficulties[selectedDifficultyIndex].value;
		// const { unplayed, total } = await getUnplayedAndTotalForDifficulty(selectedDifficulty);
		const id = await getRandomUnplayedGridID(selectedDifficulty);
		goto(`/game?id=${id}`);
	}

	onMount(async () => {
		const currentDifficulty = await Preferences.get({ key: currentDifficultyKey });
		if (currentDifficulty) {
			updateDifficulty(parseInt(currentDifficulty.value ?? '0'));
		}
	});

	$effect(() => {
		const selectedDifficulty = difficulties[selectedDifficultyIndex].value;
		directionsSymbols = DirectionPresets[selectedDifficulty].join(' ');
		const config = DifficultyConfigMap.config(selectedDifficulty);
		gridSize = config.gridSize;
	});
</script>

<div class="fixed inset-0 z-50 bg-slate-50">
	<div
		class="} relative flex h-full items-end justify-center sm:items-center lg:items-center lg:pb-0"
		style="padding-bottom: calc(var(--safe-area-inset-bottom))"
	>
		<div class="flex max-w-2xl flex-col items-center justify-center">
			<div class="flex flex-col items-center justify-center gap-0">
				<span class="text-4xl font-bold lg:text-6xl">Classic</span>
				<span class="text-sm text-gray-500 lg:text-base">Game Mode</span>
			</div>
			<!-- Game Configuration Display -->
			<div
				class="{isSmallScreen
					? 'portrait:mt-8 landscape:mt-4'
					: 'mt-8'} flex flex-col items-center gap-0"
			>
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
					selectedIndex={selectedDifficultyIndex}
					onChange={onDifficultyChange}
				/>
			</div>
			<button
				class="button-active mt-8 w-full rounded-md bg-red-800 py-2 text-xl font-bold text-white {isSmallScreen
					? 'portrait:mb-[104px]'
					: 'mt-8'} "
				onclick={onPlayClick}
			>
				Play
			</button>
		</div>
	</div>
</div>
