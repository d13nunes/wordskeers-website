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
			discoveredWord.isDiscovered = true;
			setDiscovered(path);
			hintPositions.length = 0;
		}
	};

	function onPauseClick() {
		/// show new game route
		goto('/');
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

	function onPowerUpFindLetterClick() {
		if (isFindLetterDisabled) return;
		hintPositions.length = 0;
		const suggestedWord = getRandonUndiscoveredWord();
		const suggestedPositions = getWordPositions(suggestedWord);
		const suggestedLetter = suggestedPositions[randomInt(suggestedPositions.length)];
		hintPositions.push(suggestedLetter);
		console.log('hint letter', suggestedLetter);
		isFindLetterDisabled = true;
		walletStore.tryAndBuy(powerUpPrices.findLetter);
		setTimeout(() => {
			isFindLetterDisabled = false;
		}, powerUpCooldownButton);
	}

	function getRandonUndiscoveredWord(): Word {
		const undiscoveredWord = words.filter((word) => !word.isDiscovered);
		const randomIndex = randomInt(undiscoveredWord.length);
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
		console.log('💰 balance', balance);
		isRotateDisabled = balance < powerUpPrices.rotate;
		isFindLetterDisabled = balance < powerUpPrices.findLetter;
		isFindWordDisabled = balance < powerUpPrices.findWord;
	});
	walletStore.addCoins(1000);
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
						tag={word.word.toUpperCase()}
						isDiscovered={word.isDiscovered}
						customBg={word.color}
						customText={word.color}
					/>
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
