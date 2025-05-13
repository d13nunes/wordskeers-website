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
		type Word
	} from '$lib/components/Game/game';
	import Board from '$lib/components/Game/Board.svelte';
	import { type Position } from '$lib/components/Game/Position';
	import { ColorGenerator } from '$lib/components/Game/color-generator';
	import { randomInt } from '$lib/utils/random-utils';
	import { walletStore } from '$lib/economy/walletStore';
	import { flip } from 'svelte/animate';
	import { cubicIn, cubicInOut, cubicOut } from 'svelte/easing';
	import { fade, scale } from 'svelte/transition';
	import { animate } from 'animejs';

	let isRotated = $state(false);
	let isGameEnded = $state(false);
	let isRotateDisabled = $state(false);
	let isFindLetterDisabled = $state(false);
	let isFindWordDisabled = $state(false);
	const powerUpCooldownButton = 2000;

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

	let onWordSelect = (word: string, path: Position[]): Position[] => {
		const wordIndex = getWord(word);
		if (wordIndex !== undefined && !words[wordIndex].isDiscovered) {
			words[wordIndex].color = getColor().bg;
			words[wordIndex].textColor = 'text-white';
			words[wordIndex].isDiscovered = true;
			hintPositions.length = 0;
			const totalWords = words.length;
			const discoveredWords = words.filter((w) => w.isDiscovered).length;
			if (discoveredWords === totalWords) {
				isGameEnded = true;
			}
			return path;
		}
		return [];
	};

	let showPauseModal = $state(false);
	function onPauseClick() {
		showPauseModal = true;
	}

	let isPowerUpAnimationActive = $state(false);

	function onPowerUpRotateClick() {
		if (isRotateDisabled || isPowerUpAnimationActive) return;
		isPowerUpAnimationActive = true;
		isRotated = !isRotated;
		walletStore.tryAndBuy(powerUpPrices.rotate);
		const rotateIcon = document.getElementById('rotate-icon');
		const finalRotation = isRotated ? '360' : '-360';
		if (rotateIcon) {
			animate(rotateIcon, {
				rotate: ['0', finalRotation],
				duration: 1000,
				easing: 'easeInOutQuad'
			});
		}
		setTimeout(() => {
			isPowerUpAnimationActive = false;
		}, powerUpCooldownButton);
	}

	async function onPowerUpFindLetterClick() {
		if (isFindLetterDisabled || isPowerUpAnimationActive) return;
		isPowerUpAnimationActive = true;
		hintPositions.length = 0;
		const suggestedWord = getRandonUndiscoveredWord();
		const suggestedPositions = getWordPositions(suggestedWord);
		const suggestedLetterIndex = randomInt(suggestedPositions.length - 1);
		const suggestedLetter = suggestedPositions[suggestedLetterIndex];
		const didBuy = await walletStore.tryAndBuy(powerUpPrices.findLetter);
		if (didBuy) {
			hintPositions.push(suggestedLetter);
			const icon = document.getElementById('find-letter-icon');
			if (icon) {
				animatePowerUp(suggestedLetter, icon);
			}
		}
		setTimeout(() => {
			isPowerUpAnimationActive = false;
		}, powerUpCooldownButton);
	}

	function getRandonUndiscoveredWord(): Word {
		const undiscoveredWord = words.filter((word) => !word.isDiscovered);
		const randomIndex = randomInt(undiscoveredWord.length - 1);
		return undiscoveredWord[randomIndex];
	}

	function animatePowerUp(position: Position, icon: HTMLElement) {
		const board = document.getElementById(`${position.row}${position.col}`);
		const boardRect = board?.getBoundingClientRect();
		const findWordIconRect = icon.getBoundingClientRect();

		if (boardRect && findWordIconRect) {
			// Calculate the center position of the board
			const boardCenterX = boardRect.x + boardRect.width / 2;
			const boardCenterY = boardRect.y + boardRect.height / 2;

			// Calculate the position to center the icon
			// We subtract half of the icon's dimensions to center it
			const targetX = boardCenterX - findWordIconRect.width / 2;
			const targetY = boardCenterY - findWordIconRect.height / 2;

			// Calculate the translation needed from the icon's current position
			const translateX = targetX - findWordIconRect.x;
			const translateY = targetY - findWordIconRect.y;

			// Store original position for the return animation
			const originalX = findWordIconRect.x;
			const originalY = findWordIconRect.y;

			// First animation: move to center and scale up
			const moveToCenter = animate(icon, {
				translateX,
				translateY,
				duration: 700,
				opacity: [1, 1, 0.8],
				scale: 1.5,
				easing: 'easeInOut'
			});

			// Chain the animations
			moveToCenter.then(() => {
				// Second animation: fade out
				const fadeOut = animate(icon, {
					delay: 100,
					opacity: [0.8, 0],
					rotate: [0, 360],
					scale: [1.5, 0.0],
					duration: 500,
					easing: 'easeOutQuad'
				});

				fadeOut.then(() => {
					// Reset position and scale instantly
					animate(icon, {
						translateX: 0,
						translateY: 0,
						scale: 1,
						duration: 0
					});

					// Final animation: fade in at original position
					animate(icon, {
						opacity: 1,
						duration: 500,
						easing: 'easeInOut'
					});
				});
			});
		}
	}

	function onPowerUpFindWordClick() {
		if (isFindWordDisabled || isPowerUpAnimationActive) return;
		isPowerUpAnimationActive = true;
		const suggestedWord = getRandonUndiscoveredWord();
		hintPositions.length = 0;
		hintPositions.push(...getWordPositions(suggestedWord));
		walletStore.tryAndBuy(powerUpPrices.findWord);
		const findWordIcon = document.getElementById('find-word-icon');
		if (findWordIcon) {
			const suggestedLetter = hintPositions[Math.floor(hintPositions.length / 2)];
			animatePowerUp(suggestedLetter, findWordIcon);
		}
		setTimeout(() => {
			isPowerUpAnimationActive = false;
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

	walletStore.addCoins(300); // TODO: remove

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
		<div
			in:fade={{ duration: 300, easing: cubicOut }}
			out:fade={{ delay: 100, duration: 300, easing: cubicIn }}
			class="bg-opacity-50 fixed inset-0 z-50 flex items-center justify-center bg-black"
		>
			<div
				in:scale={{ delay: 100, duration: 300, easing: cubicInOut }}
				out:scale={{ duration: 300, easing: cubicInOut }}
				class="flex flex-col items-center gap-4 rounded-lg bg-white p-8 shadow-lg"
			>
				<h2 class="mb-4 text-2xl font-bold">Game Paused</h2>
				<div class="flex flex-row gap-4">
					<button
						class="rounded bg-red-500 px-4 py-2 text-white hover:bg-red-600"
						onclick={() => (showPauseModal = false)}
					>
						New Game
					</button>
					<button
						class="rounded bg-blue-500 px-4 py-2 text-white hover:bg-blue-600"
						onclick={() => (showPauseModal = false)}
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
			<div class="flex items-center justify-center pt-2">
				<Board
					grid={game.grid}
					{onWordSelect}
					{getColor}
					{isRotated}
					{hintPositions}
					{isGameEnded}
				/>
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
