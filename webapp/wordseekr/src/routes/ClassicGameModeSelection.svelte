<script lang="ts">
	import GameModeSelection from './GameModeSelection.svelte';
	import { goto } from '$app/navigation';
	import SegmentedSelector from '$lib/components/SegmentedSelector.svelte';
	import { Difficulty } from '$lib/game/difficulty';
	import { DifficultyConfigMap } from '$lib/game/difficulty-config-map';
	import { getRandomUnplayedGridID } from '$lib/game/grid-fetcher';
	import { onMount } from 'svelte';
	import { getIsSmallScreen } from '$lib/utils/utils';
	import magnifierglass from '$lib/assets/magnifier-glass.webp';
	import { animate } from 'animejs';
	import { analytics } from '$lib/analytics/analytics';
	import { myLocalStorage, completionTracker } from '$lib/storage/local-storage';

	const magnifierglassId = 'magnifierglass';
	let gridSize = $state(0);
	let directionsSymbols = $state('');
	let selectedDifficultyIndex = $state(0);
	let difficulties = [
		{ label: 'Very Easy', value: Difficulty.VeryEasy },
		{ label: 'Easy', value: Difficulty.Easy },
		{ label: 'Medium', value: Difficulty.Medium },
		{ label: 'Hard', value: Difficulty.Hard }
		// { label: 'Very Hard', value: Difficulty.VeryHard }
	];
	let isSmallScreen = $state(getIsSmallScreen());

	function updateDifficulty(index: number) {
		selectedDifficultyIndex = index;
		const selectedDifficulty = difficulties[selectedDifficultyIndex].value;
		const config = DifficultyConfigMap.config(selectedDifficulty);
		gridSize = config.rows;
		directionsSymbols = config.validDirections.join(', ');
	}

	function onDifficultyChange(index: number) {
		updateDifficulty(index);
		myLocalStorage.set(myLocalStorage.CurrentDifficulty, index.toString());
	}

	async function onPlayClick() {
		const selectedDifficulty = difficulties[selectedDifficultyIndex].value;
		// const { unplayed, total } = await getUnplayedAndTotalForDifficulty(selectedDifficulty);
		const id = await getRandomUnplayedGridID(selectedDifficulty);
		analytics.startGame(selectedDifficulty, id.toString());
		goto(`/game?id=${id}&difficulty=${selectedDifficulty}`);
	}

	$effect(() => {
		const config = DifficultyConfigMap.config(difficulties[selectedDifficultyIndex].value);
		gridSize = config.rows;
		directionsSymbols = config.validDirections.join(', ');
	});

	onMount(async () => {
		const currentDifficulty = await myLocalStorage.get(myLocalStorage.CurrentDifficulty);
		if (currentDifficulty) {
			updateDifficulty(parseInt(currentDifficulty ?? '0'));
		}
		const magnifierglass = document.getElementById(magnifierglassId);
		if (magnifierglass) {
			animate(magnifierglass, {
				rotate: [0, -5, 5, -5, 0],
				duration: 1000,
				loop: true,
				loopDelay: 2000
			});
		}
		completionTracker.trackCompletionPercentageOfAllDifficulties();
	});
</script>

<GameModeSelection icon={magnifierglass} iconId={magnifierglassId} title="Classic" {onPlayClick}>
	<div
		class="{isSmallScreen
			? 'portrait:mt-8 landscape:mt-4'
			: 'mt-8'} flex flex-col items-center gap-0"
	>
		<div class="flex flex-row items-center justify-center gap-1">
			<span class="text-black-500 text-base font-normal">Search for words in</span>
			<span class="text-black-500 text-base font-bold">{gridSize}x{gridSize}</span>
			<span class="text-black-500 text-base font-normal">grid</span>
		</div>
		<div class="flex flex-col items-center justify-center gap-0.5">
			<span class="text-black-500 text-base font-normal">Words can be found in</span>
			<span class="text-black-500 min-h-5 text-sm font-bold">
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
</GameModeSelection>
