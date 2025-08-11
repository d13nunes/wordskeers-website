<script lang="ts">
	import Board from '$lib/components/Game/Board.svelte';
	import { isDarkMode } from '$lib/utils/darkmode';
	import type { Position } from '$lib/components/Game/Position';
	import colorGenerator, { type ColorTheme } from '$lib/components/Game/color-generator';
	import { getWordPositions, type Word } from '$lib/components/Game/game';
	let grid: string[][] = [
		['F', 'W', 'L', 'S'],
		['U', 'X', 'C', 'F'],
		['N', 'E', 'T', 'E'],
		['P', 'L', 'A', 'Y']
	];
	let words: Word[] = [
		{
			word: 'PLAY',
			position: { row: 3, col: 0 },
			direction: { name: 3, dx: 1, dy: 0, angle: 0 },
			isDiscovered: false
		},
		{
			word: 'FUN',
			position: { row: 0, col: 0 },
			direction: { name: 1, dx: 0, dy: 1, angle: 90 },
			isDiscovered: false
		}
	];
	let hintPositions: Position[] = [];
	let onboardingPositions: Position[] = $derived(
		words
			.filter((w) => !w.isDiscovered)
			.slice(0, 1)
			.flatMap((w) => getWordPositions(w))
	);

	$inspect('🐽🐽🐽 ', onboardingPositions);

	function onWordSelect(word: string, path: Position[], letterSize: number): Position[] {
		console.log('onWordSelect', word, path, letterSize);
		const index = words.findIndex((w) => w.word === word);
		if (index !== -1) {
			words[index].isDiscovered = true;
			words = words.map((w, i) => ({ ...w, isDiscovered: i === index }));
			onboardingPositions = words
				.filter((w) => !w.isDiscovered)
				.flatMap((w) => getWordPositions(w));
			return getWordPositions(words[index]);
		}
		return [];
	}

	let currentColor: ColorTheme = colorGenerator.getNextColor($isDarkMode);
	let isRotated = false;
</script>

<div>
	<h1>Board</h1>
	<Board
		{grid}
		{onWordSelect}
		{currentColor}
		{isRotated}
		{hintPositions}
		class="board-container"
		{onboardingPositions}
	/>
</div>
