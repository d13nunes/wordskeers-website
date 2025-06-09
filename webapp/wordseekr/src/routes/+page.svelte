<script lang="ts">
	import GameModeIconTitle from '$lib/components/GameModeIconTitle.svelte';
	import { goto } from '$app/navigation';
	import SegmentedSelector from '$lib/components/SegmentedSelector.svelte';
	import { Difficulty } from '$lib/game/difficulty';
	import { DifficultyConfigMap } from '$lib/game/difficulty-config-map';
	import { getRandomUnplayedGridID } from '$lib/game/grid-fetcher';
	import { DirectionPresets } from '$lib/game/direction-presets';
	import { onMount } from 'svelte';
	import { getIsSmallScreen } from '$lib/utils/utils';
	import magnifierglass from '$lib/assets/magnifierglass.webp';
	import { animate } from 'animejs';
	import { analytics } from '$lib/analytics/analytics';
	import { myLocalStorage, completionTracker } from '$lib/storage/local-storage';
	import { OnAppearAction, onGameSelectionAppear } from '$lib/logic/on-game-selection-actions';
	import { modalPresenter } from './modal-presenter';

	let gridSize = $state(0);
	let directionsSymbols = $state('');
	let selectedDifficultyIndex = $state(0);
	let difficulties = [
		{ label: 'Very Easy', value: Difficulty.VeryEasy },
		{ label: 'Easy', value: Difficulty.Easy },
		{ label: 'Medium', value: Difficulty.Medium },
		{ label: 'Hard', value: Difficulty.Hard },
		{ label: 'Very Hard', value: Difficulty.VeryHard }
	];

	let isSmallScreen = $state(getIsSmallScreen());

	const magnifierglassId = 'magnifierglass';

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

	onMount(async () => {
		const currentDifficulty = await myLocalStorage.get(myLocalStorage.CurrentDifficulty);
		if (currentDifficulty) {
			updateDifficulty(parseInt(currentDifficulty ?? '0'));
		}
		const magnifierglass = document.getElementById(magnifierglassId);
		if (magnifierglass) {
			animate(magnifierglass, {
				rotate: [0, -5, 5, -5, 0],
				duration: 1000
			});
		}
		await completionTracker.trackCompletionPercentageOfAllDifficulties();

		const onAppearAction = await onGameSelectionAppear();
		console.log('🔍ℹ onAppearAction', onAppearAction);
		switch (onAppearAction) {
			case OnAppearAction.ShowQuoteModal:
				console.log('🔍ℹ showQuoteModal');
				modalPresenter.showQuoteModal();
				break;
			case OnAppearAction.ShowRewardModal:
				console.log('🔍ℹ showRewardsModal');
				modalPresenter.showRewardsModal();
				break;
			default:
		}
	});

	$effect(() => {
		const config = DifficultyConfigMap.config(difficulties[selectedDifficultyIndex].value);
		gridSize = config.rows;
		directionsSymbols = config.validDirections.join(', ');
	});
</script>

<div class="fixed inset-0 z-50 bg-slate-50">
	<div class="flex h-full items-center justify-center sm:items-center lg:items-center lg:pb-0">
		<div class="flex max-w-2xl flex-col items-center justify-center">
			<GameModeIconTitle
				icon={magnifierglass}
				iconId={magnifierglassId}
				title="Classic"
				subtitle="Game Mode"
			/>
			<!-- Game Configuration Display -->
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
			<button
				class="button-active mt-6 w-full rounded-md bg-red-800 py-2 text-xl font-bold text-white lg:mt-8"
				onclick={onPlayClick}
			>
				Play
			</button>
		</div>
	</div>
</div>
