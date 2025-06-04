<script lang="ts">
	import { Haptics, ImpactStyle } from '@capacitor/haptics';
	import GameButtons from './GameButtons.svelte';
	import { page } from '$app/state';
	import {
		createGameForConfiguration,
		createGameFromDailyChallenge,
		getWordPositions,
		type Game,
		type Word
	} from '$lib/components/Game/game';
	import Board from '$lib/components/Game/Board.svelte';
	import { type Position } from '$lib/components/Game/Position';
	import { ColorGenerator } from '$lib/components/Game/color-generator';
	import { randomInt } from '$lib/utils/random-utils';
	import { walletStore } from '$lib/economy/walletStore';
	import { animate, utils } from 'animejs';
	import { goto } from '$app/navigation';
	import GameEndedModal from './GameEndedModal.svelte';
	import { adStore } from '$lib/ads/ads';
	import { AdType } from '$lib/ads/ads-types';
	import { getFormatedTime, getPositionId } from '$lib/utils/string-utils';
	import { appStateManager } from '$lib/utils/app-state';
	import { getGridWithID } from '$lib/game/grid-fetcher';
	import { onMount } from 'svelte';
	import { databaseService } from '$lib/database/database.service';
	import BoardWords from './BoardWords.svelte';
	import PauseMenu from './PauseMenu.svelte';
	import { getIsSmallScreen } from '$lib/utils/utils';
	import { endGameAdStore } from '$lib/game/end-game-ad';
	import { analytics } from '$lib/analytics/analytics';
	import type { Difficulty } from '$lib/game/difficulty';
	import { myLocalStorage } from '$lib/storage/local-storage';
	import { mockDailyChallenge, type DailyChallenge } from '$lib/daily-challenge/models';
	import DailyChallengeBoardWords from '$lib/daily-challenge/DailyChallengeBoardWords.svelte';
	import ClassicBoardWords from './ClassicBoardWords.svelte';

	const powerUpCooldownButton = 1500;

	let colorGenerator = new ColorGenerator();

	let isSmallScreen = $state(true);
	let progressCircle = $state<SVGCircleElement | null>(null);
	let isRotated = $state(false);
	let isGameEnded = $state(false);
	let isRotateDisabled = $state(false);
	let isFindLetterDisabled = $state(false);
	let isFindWordDisabled = $state(false);
	let isClockVisible = $state(false);
	let game = $state<Game | null>(null);
	let words = $derived<Word[]>(game?.words ?? []);
	let error: string | null = $state(null);
	let hintPositions: Position[] = $state([]);
	let showPauseModal = $state(false);
	let isPowerUpAnimationActive = $state(false);

	let dailyChallenge = $state<DailyChallenge | null>(null);

	let difficulty: Difficulty | undefined = undefined;

	async function loadGridFromDatabase(gridID: number) {
		try {
			// Get a random grid for the selected difficulty
			const configuration = await getGridWithID(gridID);
			game = createGameForConfiguration(configuration);

			difficulty = page.url.searchParams.get('difficulty') as Difficulty;
		} catch (e) {
			error = e instanceof Error ? e.message : 'Failed to load game';
			console.error('Error loading game:', e);
		}
	}

	function loadGridFromDailyChallenge(dailyChallengeID: number) {
		dailyChallenge = mockDailyChallenge;
		game = createGameFromDailyChallenge(dailyChallenge);
	}

	let dailyChallengeID = parseInt(page.url.searchParams.get('dailyChallengeId') ?? '-1');
	let isDailyChallenge = dailyChallengeID !== -1;
	let gridID: number;
	onMount(async () => {
		isSmallScreen = getIsSmallScreen();
		if (isDailyChallenge) {
			gridID = dailyChallengeID;
			loadGridFromDailyChallenge(dailyChallengeID);
		} else {
			const gridID: number = parseInt(page.url.searchParams.get('id') ?? '-1');
			if (!gridID) {
				throw new Error('Invalid id');
			}
			loadGridFromDatabase(gridID);
		}
		try {
			const isClockVisibleResult = await myLocalStorage.get(myLocalStorage.ClockVisible);
			isClockVisible = isClockVisibleResult === 'true';
		} catch (e) {
			console.error('Error loading clock visibility:', e);
		}
	});

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
		console.debug(
			'wordIndex',
			wordIndex,
			word,
			words.map((w) => w.word)
		);
		if (wordIndex !== undefined && !words[wordIndex].isDiscovered) {
			console.debug('wordIndex', words[wordIndex], word);
			words[wordIndex].color = 'bg-slate-200';
			words[wordIndex].textColor = 'text-gray-700';
			words[wordIndex].isDiscovered = true;
			addCoinsToPiggyBank(word);
			hintPositions.length = 0;
			const totalWords = words.length;
			const discoveredWords = words.filter((w) => w.isDiscovered).length;
			if (discoveredWords === totalWords) {
				isGameEnded = true;
				const gridID = game?.config.id.toString() ?? 'undefined';
				analytics.completeGame(difficulty ?? 'undefined', gridID);
				// Mark grid as played when game ends
				const gridId = parseInt(game?.config.id ?? '-1');
				if (!isNaN(gridId)) {
					databaseService.markGridAsPlayed(gridId, elapsedTime);
				}
				Haptics.impact({ style: ImpactStyle.Heavy });
			} else {
				Haptics.impact({ style: ImpactStyle.Light });
			}
			return path;
		}
		return [];
	};

	function addCoinsToPiggyBank(word: string) {
		const totalToAdd = calculateWordCoins(word);
		const finalValue = accumulatedCoins + totalToAdd;
		let counter = { value: accumulatedCoins };

		// Animate the progress circle
		if (progressCircle) {
			const currentProgress = (words.filter((w) => w.isDiscovered).length / words.length) * 100;
			const nextProgress = ((words.filter((w) => w.isDiscovered).length + 1) / words.length) * 100;
			const circumference = 2 * Math.PI * 44; // 2πr where r=44

			animate(progressCircle, {
				strokeDashoffset: [
					circumference * (1 - currentProgress / 100),
					circumference * (1 - nextProgress / 100)
				],
				duration: 1000,
				easing: 'easeOutExpo'
			});
		}

		// Animate the coin counter
		animate(counter, {
			value: finalValue,
			duration: 1000,
			easing: 'outExpo',
			modifier: utils.round(0),
			onUpdate: function () {
				accumulatedCoins = counter.value;
			}
		});

		// Add a bounce effect to the coin icon
		const coinIcon = document.querySelector('.coin-icon');
		if (coinIcon) {
			animate(coinIcon, {
				scale: [1, 1.2, 1],
				rotate: [0, 10, -10, 0],
				duration: 800,
				easing: 'easeOutElastic(1, .5)'
			});
		}
	}

	function onPauseClick() {
		showPauseModal = true;
	}

	async function onPowerUpRotateClick(iconId: string) {
		if (isRotateDisabled || isPowerUpAnimationActive) return;
		isPowerUpAnimationActive = true;
		isRotated = !isRotated;
		const powerUpId = 'rotate';
		analytics.tryUsePowerUp(powerUpId);
		const didBuy = await walletStore.tryAndBuy(powerUpPrices.rotate);
		if (!didBuy) {
			analytics.failedToUsePowerUp(powerUpId);
			return;
		}

		analytics.usePowerUp(powerUpId);
		const rotateIcon = document.getElementById(iconId);
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

	async function onPowerUpFindLetterClick(iconId: string) {
		if (isFindLetterDisabled || isPowerUpAnimationActive) return;
		isPowerUpAnimationActive = true;
		hintPositions.length = 0;
		const suggestedWord = getRandonUndiscoveredWord();
		const suggestedPositions = getWordPositions(suggestedWord);
		const suggestedLetterIndex = randomInt(suggestedPositions.length - 1);
		const suggestedLetter = suggestedPositions[suggestedLetterIndex];
		const powerUpId = 'find_letter';
		analytics.tryUsePowerUp(powerUpId);
		const didBuy = await walletStore.tryAndBuy(powerUpPrices.findLetter);
		if (!didBuy) {
			analytics.failedToUsePowerUp(powerUpId);
			return;
		}
		analytics.usePowerUp(powerUpId);
		hintPositions.push(suggestedLetter);
		const icon = document.getElementById(iconId);
		if (icon) {
			animatePowerUp(suggestedLetter, icon);
		}
		setBGColorTag(suggestedWord.word, getColor().bg);

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
		const board = document.getElementById(getPositionId(position.row, position.col));
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

	async function onPowerUpFindWordClick(iconId: string) {
		if (isFindWordDisabled || isPowerUpAnimationActive) return;
		isPowerUpAnimationActive = true;
		const suggestedWord = getRandonUndiscoveredWord();
		hintPositions.length = 0;
		hintPositions.push(...getWordPositions(suggestedWord));
		const powerUpId = 'find_word';
		analytics.tryUsePowerUp(powerUpId);
		const didBuy = await walletStore.tryAndBuy(powerUpPrices.findWord);
		if (!didBuy) {
			analytics.failedToUsePowerUp(powerUpId);
			return;
		}
		const findWordIcon = document.getElementById(iconId);
		if (findWordIcon) {
			const suggestedLetter = hintPositions[Math.floor(hintPositions.length / 2)];
			animatePowerUp(suggestedLetter, findWordIcon);
			setBGColorTag(suggestedWord.word, getColor().bg);
		}
		setTimeout(() => {
			isPowerUpAnimationActive = false;
		}, powerUpCooldownButton);
	}

	let title = $derived(game?.title ?? '');
	let isRemoveAdsActive = $state(false);
	walletStore.removeAds((removeAds) => {
		isRemoveAdsActive = removeAds;
	});
	const powerUpPrices = {
		rotate: 5,
		findLetter: 100,
		findWord: 200
	};

	// Add progress calculation
	let progressPercentage = $derived(
		words.length > 0 ? (words.filter((w) => w.isDiscovered).length / words.length) * 100 : 0
	);

	walletStore.coins((balance) => {
		isRotateDisabled = balance < powerUpPrices.rotate;
		isFindLetterDisabled = balance < powerUpPrices.findLetter;
		isFindWordDisabled = balance < powerUpPrices.findWord;
	});

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

	let isRewardAdReady = $state(false);
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
				showPauseModal = false;
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

	async function collectReward(showAd: boolean) {
		let didWatchAd;
		if (showAd) {
			didWatchAd = await adStore.showAd(AdType.Rewarded, null);
		} else {
			didWatchAd = false;
		}
		const gameEndedPrize = didWatchAd ? accumulatedCoins * 2 : accumulatedCoins;
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
					console.log('📺📺📺 show end game ad');
					endGameAdStore.show({ didWatchRewardAd: didWatchAd });
					goto('/');
				}, 500);
			});
			setTimeout(() => {
				walletStore.addCoins(gameEndedPrize);
			}, animationDuration * 0.75);
		}
	}

	// Add coin calculation function and state
	function calculateWordCoins(word: string): number {
		return 10; // Default reward per word
	}

	let accumulatedCoins = $state(0);

	async function onClockClick(isClockVisible_: boolean) {
		isClockVisible = isClockVisible_;
		await myLocalStorage.set(myLocalStorage.ClockVisible, isClockVisible.toString());
	}

	function pauseMenuNewGameClick() {
		analytics.quitGame(difficulty ?? 'undefined', game?.config.id.toString() ?? 'undefined');
		goto('/');
	}
</script>

{#if error}
	<div class="bg-opacity-75 fixed inset-0 z-50 flex items-center justify-center bg-white">
		<div class="mx-4 max-w-md rounded-lg border border-red-900 bg-red-50 p-4">
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
	<div class="bg-opacity-75 fixed inset-0 flex items-center justify-center bg-white">
		<div class="text-center">
			<!-- <div class="mx-auto h-12 w-12 animate-spin rounded-full border-b-2 border-gray-900"></div>
			<p class="mt-4 text-gray-700">Loading game...</p> -->
		</div>
	</div>
{:else}
	<div
		class="fixed inset-0 z-50 flex max-h-full flex-row items-end justify-center sm:items-center"
		style="padding-left: calc(var(--safe-area-inset-left)"
	>
		{#if showPauseModal}
			<PauseMenu
				onClickResume={() => (showPauseModal = false)}
				onClickNewGame={pauseMenuNewGameClick}
			/>
		{/if}
		{#if isGameEnded}
			<GameEndedModal
				message={`You found all the words in ${getFormatedTime(elapsedTime)}\nYou've earned ${accumulatedCoins} coins!`}
				onClickContinue={() => collectReward(false)}
				onClickDouble={() => collectReward(true)}
				showDoubleButton={isRewardAdReady}
			/>
		{/if}

		<div
			class="flex min-w-full flex-row items-center gap-2 sm:justify-center {isSmallScreen
				? 'landscape:px-8'
				: ''}"
		>
			{#if isSmallScreen}
				<div
					class="z-10 flex w-1/2 flex-row p-4 portrait:hidden
				landscape:block
				"
				>
					<div class="mb-4">
						{#if dailyChallenge}
							<DailyChallengeBoardWords
								{dailyChallenge}
								words={sortedWords}
								showClock={isClockVisible}
								{elapsedTime}
								{title}
								{onClockClick}
							/>
						{:else}
							<ClassicBoardWords
								words={sortedWords}
								showClock={isClockVisible}
								{elapsedTime}
								{title}
								{onClockClick}
							/>
						{/if}
					</div>
					<GameButtons
						findWordIconId="fwi-l"
						findLetterIconId="fli-l"
						rotateIconId="ri-l"
						{onPauseClick}
						{onPowerUpFindWordClick}
						{onPowerUpFindLetterClick}
						{onPowerUpRotateClick}
						{isFindWordDisabled}
						{isFindLetterDisabled}
						{isRotateDisabled}
						findWordPrice={powerUpPrices.findWord.toString()}
						findLetterPrice={powerUpPrices.findLetter.toString()}
						rotatePrice={powerUpPrices.rotate.toString()}
					/>
				</div>
			{/if}
			<div
				class="flex h-full w-full flex-col items-center gap-2 sm:max-w-3/4 sm:gap-2 sm:px-0 md:max-w-2/4 md:gap-2 lg:items-center lg:justify-center
				{isSmallScreen ? 'landscape:w-1/2 ' : ''} {isRemoveAdsActive && isSmallScreen
					? 'portrait:pb-2'
					: 'portrait:pb-[54px]'} 
				"
			>
				<!-- Board & Words -->
				<div
					class="flex h-full w-full flex-col items-center justify-start gap-2 px-4 sm:gap-6 md:gap-1
					{isSmallScreen ? 'landscape:items-start ' : ''}"
				>
					<div class="{isSmallScreen ? 'portrait:block portrait:w-full landscape:hidden' : ''} ">
						{#if dailyChallenge}
							<DailyChallengeBoardWords
								{dailyChallenge}
								words={sortedWords}
								showClock={isClockVisible}
								{elapsedTime}
								{title}
								{onClockClick}
							/>
						{:else}
							<ClassicBoardWords
								words={sortedWords}
								showClock={isClockVisible}
								{elapsedTime}
								{title}
								{onClockClick}
							/>
						{/if}
					</div>

					<Board
						grid={game.grid}
						{onWordSelect}
						{getColor}
						{isRotated}
						{hintPositions}
						{isGameEnded}
					/>
				</div>
				<!-- Game Buttons -->
				<div
					class={isSmallScreen ? 'portrait:block landscape:hidden' : ''}
					style="padding-bottom: {isSmallScreen
						? 'calc(var(--safe-area-inset-bottom) + 8px)'
						: '0px'}"
				>
					<GameButtons
						findWordIconId="fwi-p"
						findLetterIconId="fli-p"
						rotateIconId="ri-p"
						{onPauseClick}
						{onPowerUpFindWordClick}
						{onPowerUpFindLetterClick}
						{onPowerUpRotateClick}
						{isFindWordDisabled}
						{isFindLetterDisabled}
						{isRotateDisabled}
						findWordPrice={powerUpPrices.findWord.toString()}
						findLetterPrice={powerUpPrices.findLetter.toString()}
						rotatePrice={powerUpPrices.rotate.toString()}
					/>
				</div>
			</div>
		</div>
	</div>
{/if}
