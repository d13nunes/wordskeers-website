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
		goto('/');
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
	let title = 'Cenas'; //$derived(game.title);
	let isRemoveAdsActive = $state(false);
</script>

<div class="">
	<div
		class="flex h-screen flex-col items-center justify-end {isRemoveAdsActive
			? 'pb-12'
			: 'pb-28'} lg:items-center lg:pb-0"
	>
		<div class="p-4">
			<span class="pl-1 text-2xl font-bold text-gray-700">{title}</span>
			<div class=" flex flex-row flex-wrap gap-2 py-2">
				{#each words as word}
					<Tag
						tag={word.word}
						isDiscovered={word.isDiscovered}
						customBg={word.color}
						customText={word.color}
					/>
				{/each}
			</div>
			<div class="flex items-center justify-center pt-4">
				<Board grid={game.grid} {onWordSelect} {getColor} {isRotated} />
			</div>
		</div>
		<div class="flex flex-row items-center justify-center gap-6">
			<PauseButton onclick={onPauseClick} />
			<div class="flex w-full flex-row items-center justify-center gap-2">
				<FindWordPowerUp onclick={onPowerUpFindWordClick} price="200" />
				<FindLetterPowerUp onclick={onPowerUpFindLetterClick} price="100" />
				<RotatePowerUp onclick={onPowerUpRotateClick} price="10" />
			</div>
		</div>
	</div>
</div>
