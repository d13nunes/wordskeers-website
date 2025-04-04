<script lang="ts">
	import Tag from '$lib/components/Tag.svelte';
	import RotatePowerUp from '$lib/components/PowerUps/RotatePowerUp.svelte';
	import DirectionPowerUp from '$lib/components/PowerUps/DirectionPowerUp.svelte';
	import FindLetterPowerUp from '$lib/components/PowerUps/FindLetterPowerUp.svelte';
	import FindWordPowerUp from '$lib/components/PowerUps/FindWordPowerUp.svelte';
	import PauseButton from '$lib/components/Pause/PauseButton.svelte';
	import { createMockGame } from '$lib/components/Game/game';
	import { goto } from '$app/navigation';
	import Board from '$lib/components/Game/Board.svelte';
	import { type Position } from '$lib/components/Game/Position';
	import { ColorGenerator } from '$lib/components/Game/color-generator';
	import type { Word } from '$lib/components/Game/Word';

	let isRotated = $state(false);

	let words: Word[] = $state([]);

	let game = createMockGame(); // TODO

	let colorGenerator = new ColorGenerator();

	words = game.words.map((word) => ({
		word,
		color: undefined,
		textColor: undefined,
		isDiscovered: false
	}));

	function getWord(word: string): Word | undefined {
		const wordDirection = words.find((w) => w.word === word);
		if (wordDirection) {
			return wordDirection;
		}
		const reverseWord = word.split('').reverse().join('');
		const reverseWordDirection = words.find((w) => w.word === reverseWord);
		return reverseWordDirection;
	}

	let onWordSelect = (
		word: string,
		path: Position[],
		setDiscovered: (position: Position[]) => void
	) => {
		const discoveredWord = getWord(word);
		if (discoveredWord && !discoveredWord.isDiscovered) {
			discoveredWord.color = getColor().bg;
			console.log('!!!! words[index].color', discoveredWord.color);
			discoveredWord.isDiscovered = true;
			setDiscovered(path);
		}
	};

	function onPauseClick() {
		/// show new game route
		goto('/newgame');
	}

	function onPowerUpRotateClick() {
		isRotated = !isRotated;
	}

	function onPowerUpDirectionClick() {}

	function onPowerUpFindLetterClick() {}

	function onPowerUpFindWordClick() {}
	function getColor() {
		return colorGenerator.getColor(words.filter((w) => w.isDiscovered).length);
	}
</script>

<div class="h-screen w-screen overflow-hidden bg-slate-50">
	<div class="p-8">
		<div class="card flex flex-row flex-wrap gap-2">
			{#each words as word}
				<Tag
					tag={word.word}
					isDiscovered={word.isDiscovered}
					customBg={word.color}
					customText={word.color}
				/>
			{/each}
		</div>
		<div class="flex flex-row pt-2">
			<Board grid={game.grid} {onWordSelect} {getColor} {isRotated} />
		</div>
	</div>
	<div class="flex flex-row gap-2 p-8">
		<PauseButton onClick={onPauseClick} />
		<div class="w-full"></div>
		<RotatePowerUp onClick={onPowerUpRotateClick} />
		<DirectionPowerUp onClick={onPowerUpDirectionClick} />
		<FindLetterPowerUp onClick={onPowerUpFindLetterClick} />
		<FindWordPowerUp onClick={onPowerUpFindWordClick} />
	</div>
</div>
