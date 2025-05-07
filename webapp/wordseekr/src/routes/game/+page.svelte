<script lang="ts">
	import Tag from '$lib/components/Tag.svelte';
	import RotatePowerUp from '$lib/components/PowerUps/RotatePowerUp.svelte';
	import FindLetterPowerUp from '$lib/components/PowerUps/FindLetterPowerUp.svelte';
	import FindWordPowerUp from '$lib/components/PowerUps/FindWordPowerUp.svelte';
	import PauseButton from '$lib/components/Pause/PauseButton.svelte';
	import {
		createGameForConfiguration,
		getWordPositions,
		mockGameConfiguration,
		type Word,
		type WordLocation
	} from '$lib/components/Game/game';
	import { goto } from '$app/navigation';
	import Board from '$lib/components/Game/Board.svelte';
	import { type Position } from '$lib/components/Game/Position';
	import { ColorGenerator } from '$lib/components/Game/color-generator';
	import { randomInt } from '$lib/utils/random-utils';
	import { walletStore } from '$lib/economy/walletStore';
	import { flip } from 'svelte/animate';
	import { cubicIn, cubicInOut, cubicOut, quintOut } from 'svelte/easing';
	import { crossfade } from 'svelte/transition';

	let isRotated = $state(false);
	let isRotateDisabled = $state(false);
	let isFindLetterDisabled = $state(false);
	let isFindWordDisabled = $state(false);
	const powerUpCooldownButton = 600;

	const configuration = mockGameConfiguration();
	let game = createGameForConfiguration(configuration);
	let words = $state(game.words);

	let colorGenerator = new ColorGenerator();
	let hintPositions: Position[] = $state([]);

	function getWord(word: string): number | undefined {
		const wordDirection = words.findIndex((w) => w.word === word);
		if (wordDirection !== -1) {
			return wordDirection;
		}
		const reverseWord = word.split('').reverse().join('');
		const reverseWordDirection = words.findIndex((w) => w.word === reverseWord);
		if (reverseWordDirection !== -1) {
			return reverseWordDirection;
		}
		return undefined;
	}

	let onWordSelect = (
		word: string,
		path: Position[],
		setDiscovered: (position: Position[]) => void
	) => {
		const wordIndex = getWord(word);
		if (wordIndex !== undefined && !words[wordIndex].isDiscovered) {
			words[wordIndex].color = getColor().bg;
			words[wordIndex].textColor = 'text-white';
			words[wordIndex].isDiscovered = true;
			setDiscovered(path);
			hintPositions.length = 0;
		}
	};

	let showPauseModal = $state(false);
	function onPauseClick() {
		showPauseModal = true;
	}

	function onPowerUpRotateClick() {
		if (isRotateDisabled) return;
		isRotated = !isRotated;
		isRotateDisabled = true;
		walletStore.tryAndBuy(powerUpPrices.rotate);
		setTimeout(() => {
			isRotateDisabled = false;
		}, powerUpCooldownButton);
	}

	async function onPowerUpFindLetterClick() {
		if (isFindLetterDisabled) return;
		hintPositions.length = 0;
		const suggestedWord = getRandonUndiscoveredWord();
		const suggestedPositions = getWordPositions(suggestedWord);
		const suggestedLetterIndex = randomInt(suggestedPositions.length - 1);
		const suggestedLetter = suggestedPositions[suggestedLetterIndex];
		isFindLetterDisabled = true;
		const didBuy = await walletStore.tryAndBuy(powerUpPrices.findLetter);
		if (didBuy) {
			hintPositions.push(suggestedLetter);
		}
		setTimeout(() => {
			isFindLetterDisabled = false;
		}, powerUpCooldownButton);
	}

	function getRandonUndiscoveredWord(): Word {
		const undiscoveredWord = words.filter((word) => !word.isDiscovered);
		const randomIndex = randomInt(undiscoveredWord.length - 1);
		return undiscoveredWord[randomIndex];
	}

	function onPowerUpFindWordClick() {
		if (isFindWordDisabled) return;
		const suggestedWord = getRandonUndiscoveredWord();
		hintPositions.length = 0;
		hintPositions.push(...getWordPositions(suggestedWord));
		walletStore.tryAndBuy(powerUpPrices.findWord);
		isFindWordDisabled = true;
		setTimeout(() => {
			isFindWordDisabled = false;
		}, powerUpCooldownButton);
	}

	function getColor() {
		return colorGenerator.getColor(words.filter((w) => w.isDiscovered).length);
	}
	let title = $derived(game.title);
	let isRemoveAdsActive = $state(false);
	const powerUpPrices = {
		rotate: 10,
		findLetter: 100,
		findWord: 200
	};
	walletStore.coins((balance) => {
		isRotateDisabled = balance < powerUpPrices.rotate;
		isFindLetterDisabled = balance < powerUpPrices.findLetter;
		isFindWordDisabled = balance < powerUpPrices.findWord;
	});

	walletStore.addCoins(1000); // TODO: remove

	let sortedWords = $derived(
		[...words].sort((a, b) => {
			if (a.isDiscovered !== b.isDiscovered) {
				return (a.isDiscovered ? 1 : 0) - (b.isDiscovered ? 1 : 0);
			}
			return a.word.length - b.word.length;
		})
	);
</script>

<div class="">
	{#if showPauseModal}
		<div class="bg-opacity-50 fixed inset-0 z-50 flex items-center justify-center bg-black">
			<div class="flex flex-col items-center gap-4 rounded-lg bg-white p-8 shadow-lg">
				<h2 class="mb-4 text-2xl font-bold">Game Paused</h2>
				<div class="flex flex-row gap-4">
					<button
						class="rounded bg-red-500 px-4 py-2 text-white hover:bg-blue-600"
						on:click={() => (showPauseModal = false)}
					>
						New Game
					</button>
					<button
						class="rounded bg-blue-500 px-4 py-2 text-white hover:bg-blue-600"
						on:click={() => (showPauseModal = false)}
					>
						Resume Game
					</button>
				</div>
			</div>
		</div>
	{/if}
	<div
		class="flex h-screen flex-col items-center justify-end {isRemoveAdsActive
			? 'pb-12'
			: 'pb-28'} lg:items-center lg:pb-24"
	>
		<div class="p-4 lg:px-64">
			<span class="pl-1 text-2xl font-bold text-gray-700">{title}</span>
			<div class=" flex flex-row flex-wrap gap-2 py-2">
				{#each sortedWords as word (word.word)}
					<div animate:flip={{ duration: 450, easing: cubicInOut }}>
						<Tag
							tag={word.word.toUpperCase()}
							isDiscovered={word.isDiscovered}
							bgColor={word.color}
							textColor={word.textColor}
						/>
					</div>
				{/each}
			</div>
			<div class="flex items-center justify-center pt-4">
				<Board grid={game.grid} {onWordSelect} {getColor} {isRotated} {hintPositions} />
			</div>
		</div>
		<div class="flex flex-row items-center justify-center gap-6">
			<PauseButton onclick={onPauseClick} />
			<div class="flex w-full flex-row items-center justify-center gap-2">
				<FindWordPowerUp
					onclick={onPowerUpFindWordClick}
					price={powerUpPrices.findWord.toString()}
					disabled={isFindWordDisabled}
				/>
				<FindLetterPowerUp
					onclick={onPowerUpFindLetterClick}
					price={powerUpPrices.findLetter.toString()}
					disabled={isFindLetterDisabled}
				/>
				<RotatePowerUp
					onclick={onPowerUpRotateClick}
					price={powerUpPrices.rotate.toString()}
					disabled={isRotateDisabled}
				/>
			</div>
		</div>
	</div>
</div>
