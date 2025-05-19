<script lang="ts">
	import { page } from '$app/state';
	import PauseMenu from './PauseMenu.svelte';
	import Tag from '$lib/components/Tag.svelte';
	import RotatePowerUp from '$lib/components/PowerUps/RotatePowerUp.svelte';
	import FindLetterPowerUp from '$lib/components/PowerUps/FindLetterPowerUp.svelte';
	import FindWordPowerUp from '$lib/components/PowerUps/FindWordPowerUp.svelte';
	import PauseButton from '$lib/components/Pause/PauseButton.svelte';
	import {
		createGameForConfiguration,
		getWordPositions,
		type Word
	} from '$lib/components/Game/game';
	import Board from '$lib/components/Game/Board.svelte';
	import { type Position } from '$lib/components/Game/Position';
	import { ColorGenerator } from '$lib/components/Game/color-generator';
	import { randomInt } from '$lib/utils/random-utils';
	import { walletStore } from '$lib/economy/walletStore';
	import { animate } from 'animejs';
	import { goto } from '$app/navigation';
	import GameEndedModal from './GameEndedModal.svelte';
	import { adStore } from '$lib/ads/ads';
	import { AdType } from '$lib/ads/ads-types';
	import { getFormatedTime, toTitleCase } from '$lib/utils/string-utils';
	import ClockIcon from '$lib/components/Icons/ClockIcon.svelte';
	import { flip } from 'svelte/animate';
	import { appStateManager } from '$lib/utils/app-state';
	import { getGridWithID } from '$lib/game/grid-fetcher';
	import { onMount } from 'svelte';
	import { databaseService } from '$lib/database/database.service';
	import { parse } from 'date-fns';

	let isRotated = $state(false);
	let isGameEnded = $state(false);
	let isRotateDisabled = $state(false);
	let isFindLetterDisabled = $state(false);
	let isFindWordDisabled = $state(false);
	const powerUpCooldownButton = 2000;

	let isClockVisible = $state(false);

	let game = $state<any>(null);
	let words = $state<Word[]>([]);
	let error: string | null = $state(null);

	onMount(async () => {
		try {
			// Get difficulty from URL params
			const id: number = parseInt(page.url.searchParams.get('id') ?? '-1');
			if (!id) {
				throw new Error('Invalid id');
			}
			// Get a random grid for the selected difficulty
			const configuration = await getGridWithID(id);
			game = createGameForConfiguration(configuration);
			words = game.words;
		} catch (e) {
			error = e instanceof Error ? e.message : 'Failed to load game';
			console.error('Error loading game:', e);
		}
	});

	let colorGenerator = new ColorGenerator();
	let hintPositions: Position[] = $state([]);
	function getColor() {
		return colorGenerator.getColor(words.filter((w) => w.isDiscovered).length);
	}

	function getWordIndex(word: string): number | undefined {
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
		const wordIndex = getWordIndex(word);
		console.log(
			'wordIndex',
			wordIndex,
			word,
			words.map((w) => w.word)
		);
		if (wordIndex !== undefined && !words[wordIndex].isDiscovered) {
			console.log('wordIndex', words[wordIndex], word);
			words[wordIndex].color = 'bg-slate-200';
			words[wordIndex].textColor = 'text-gray-700';
			words[wordIndex].isDiscovered = true;
			hintPositions.length = 0;
			const totalWords = words.length;
			const discoveredWords = words.filter((w) => w.isDiscovered).length;
			if (discoveredWords === totalWords) {
				isGameEnded = true;
				// Mark grid as played when game ends
				const gridId = parseInt(game.config.id);
				if (!isNaN(gridId)) {
					databaseService.markGridAsPlayed(gridId, elapsedTime);
				}
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
				ease: 'inOutQuad'
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
			setBGColorTag(suggestedWord.word, getColor().bg);
		}
		setTimeout(() => {
			isPowerUpAnimationActive = false;
		}, powerUpCooldownButton);
	}

	function setBGColorTag(word: string, color: string) {
		const wordIndex = getWordIndex(word);
		if (wordIndex !== undefined) {
			words[wordIndex].color = color;
		}
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
			setBGColorTag(suggestedWord.word, getColor().bg);
		}
		setTimeout(() => {
			isPowerUpAnimationActive = false;
		}, powerUpCooldownButton);
	}

	let title = $derived(game.title);
	let isRemoveAdsActive = $state(false);
	const powerUpPrices = {
		rotate: 5,
		findLetter: 100,
		findWord: 200
	};
	walletStore.coins((balance) => {
		isRotateDisabled = balance < powerUpPrices.rotate;
		isFindLetterDisabled = balance < powerUpPrices.findLetter;
		isFindWordDisabled = balance < powerUpPrices.findWord;
	});

	walletStore.addCoins(70); // TODO: remove

	let sortDiscoveredWords = false;

	let sortedWords = $derived(
		[...words].sort((a, b) => {
			if (sortDiscoveredWords) {
				if (a.isDiscovered !== b.isDiscovered) {
					return (a.isDiscovered ? 1 : 0) - (b.isDiscovered ? 1 : 0);
				}
			}
			return a.word.length - b.word.length;
		})
	);
	let isRewardAdReady = false;
	adStore.isAdLoaded(AdType.Rewarded).subscribe((isLoaded) => {
		isRewardAdReady = isLoaded;
	});

	let elapsedTime = $state(0);
	let timerInterval: NodeJS.Timeout;

	let unsubscribeAppState: (() => void) | undefined;

	$effect(() => {
		// Subscribe to app state changes
		unsubscribeAppState = appStateManager.subscribe((isActive) => {
			if (!isActive && !showPauseModal && !isGameEnded) {
				showPauseModal = true;
			}
		});

		// Cleanup subscription when component unmounts
		return () => {
			if (unsubscribeAppState) {
				unsubscribeAppState();
			}
		};
	});

	// Start timer when component mounts
	$effect(() => {
		timerInterval = setInterval(() => {
			if (!showPauseModal) {
				elapsedTime++;
			}
		}, 1000);

		// Cleanup timer when component unmounts or game ends
		return () => {
			clearInterval(timerInterval);
		};
	});

	// Stop timer when game ends
	$effect(() => {
		if (isGameEnded) {
			clearInterval(timerInterval);
		}
	});

	const rewardCoins = 110;

	async function collectReward(showAd: boolean) {
		let didWatchAd;
		if (showAd) {
			didWatchAd = await adStore.showAd(AdType.Rewarded);
		} else {
			didWatchAd = false;
		}
		const gameEndedPrize = didWatchAd ? 100 : 50;
		const coinPileIconName = 'coin-pile-icon';

		const balanceTag = document.getElementById('balance-tag-icon');
		const coinPileIcon = document.getElementById(coinPileIconName);

		if (balanceTag && coinPileIcon) {
			const balanceTagRect = balanceTag.getBoundingClientRect();
			const coinPileIconRect = coinPileIcon.getBoundingClientRect();
			const translateX = balanceTagRect.x - coinPileIconRect.x - coinPileIconRect.width / 2;
			const translateY = balanceTagRect.y - coinPileIconRect.y - coinPileIconRect.height / 2;
			const animationDuration = 1000;
			animate(coinPileIcon, {
				translateX,
				translateY,
				scale: [1, 1, 1, 0.5, 0],
				ease: 'inOut',
				duration: animationDuration
			}).then(() => {
				setTimeout(() => {
					goto('/');
				}, 500);
			});
			setTimeout(() => {
				walletStore.addCoins(gameEndedPrize);
			}, animationDuration * 0.75);
		}
	}
</script>

{#if error}
	<div class="bg-opacity-75 fixed inset-0 z-50 flex items-center justify-center bg-white">
		<div class="mx-4 max-w-md rounded-lg border border-red-200 bg-red-50 p-4">
			<h3 class="text-lg font-medium text-red-800">Error</h3>
			<p class="mt-2 text-sm text-red-700">{error}</p>
			<button
				class="mt-4 rounded-md bg-red-100 px-4 py-2 text-red-700 transition-colors hover:bg-red-200"
				onclick={() => goto('/')}
			>
				Return to Home
			</button>
		</div>
	</div>
{:else if !game}
	<div class="bg-opacity-75 fixed inset-0 z-50 flex items-center justify-center bg-white">
		<div class="text-center">
			<div class="mx-auto h-12 w-12 animate-spin rounded-full border-b-2 border-gray-900"></div>
			<p class="mt-4 text-gray-700">Loading game...</p>
		</div>
	</div>
{:else}
	<div class="">
		{#if showPauseModal}
			<PauseMenu onClickResume={() => (showPauseModal = false)} onClickNewGame={() => goto('/')} />
		{/if}
		{#if isGameEnded}
			<GameEndedModal
				message={`You found all the words in ${getFormatedTime(elapsedTime)}\nYou've earned ${rewardCoins} coins!`}
				onClickContinue={() => collectReward(false)}
				onClickDouble={() => collectReward(true)}
				showDoubleButton={false}
			/>
		{/if}

		<div
			class="relative flex h-screen flex-col items-center justify-end {isRemoveAdsActive
				? 'pb-12'
				: 'pb-28'} lg:items-center lg:pb-24"
		>
			<div class="p-4 lg:px-64">
				<button
					type="button"
					class="flex w-full items-end justify-between"
					onclick={() => (isClockVisible = !isClockVisible)}
				>
					<span class="pl-1 text-left text-2xl font-bold text-gray-700">{title}</span>
					<div class="flex h-7 items-center gap-1">
						{#if isClockVisible}
							<span class="  text-gray-700">{elapsedTime}</span>
						{/if}
						<div class="h-4 w-4">
							<ClockIcon color="#37385F" />
						</div>
					</div>
				</button>
				<div class="flex flex-row flex-wrap gap-2 p-2 py-2">
					{#each sortedWords as word (word.word)}
						<div animate:flip={{ duration: 450 }}>
							<Tag
								tag={toTitleCase(word.word)}
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
{/if}
