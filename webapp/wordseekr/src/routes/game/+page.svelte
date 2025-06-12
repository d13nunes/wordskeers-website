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
	import { animate, JSAnimation, utils } from 'animejs';
	import { goto } from '$app/navigation';
	import GameEndedModal from './GameEndedModal.svelte';
	import { adStore } from '$lib/ads/ads';
	import { AdType } from '$lib/ads/ads-types';
	import { getFormatedTime, getPositionId } from '$lib/utils/string-utils';
	import { appStateManager } from '$lib/utils/app-state';
	import { getDailyChallenge, getGridWithID } from '$lib/game/grid-fetcher';
	import { onMount } from 'svelte';
	import { databaseService } from '$lib/database/database.service';
	import { getIsSmallScreen } from '$lib/utils/utils';
	import { endGameAdStore } from '$lib/game/end-game-ad';
	import { analytics } from '$lib/analytics/analytics';
	import type { Difficulty } from '$lib/game/difficulty';
	import { gameCounter, myLocalStorage } from '$lib/storage/local-storage';
	import { type DailyChallenge } from '$lib/daily-challenge/models';
	import DailyChallengeBoardWords from '$lib/daily-challenge/DailyChallengeBoardWords.svelte';
	import ClassicBoardWords from './ClassicBoardWords.svelte';
	import Confetti from 'svelte-confetti';
	import PauseMenu from './PauseMenu.svelte';
	import { markQuoteAsPlayed } from '$lib/daily-challenge/quote-fetcher';

	const powerUpCooldownButton = 1500;

	let colorGenerator = new ColorGenerator();
	let isSmallScreen = $state(true);
	let isLandscape = $state(false);
	let progressCircle = $state<SVGCircleElement | null>(null);
	let isRotated = $state(false);
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
	let isGameEnded = $state(false);

	let dailyChallenge = $state<DailyChallenge | null>(null);
	let showGameEnded = $state(false);

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

	async function loadGridFromDailyChallenge(dailyChallengeID: number) {
		dailyChallenge = await getDailyChallenge(dailyChallengeID);
		game = createGameFromDailyChallenge(dailyChallenge);
		analytics.startedPlayingQuote(dailyChallengeID);
	}
	let dailyChallengeID = parseInt(page.url.searchParams.get('dailyChallengeId') ?? '-1');
	let isDailyChallenge = dailyChallengeID !== -1;
	let gridID: number = -1;
	const handleResize = () => {
		isLandscape = window.innerWidth > window.innerHeight;
	};
	async function loadClockVisibility() {
		try {
			const isClockVisibleResult = await myLocalStorage.get(myLocalStorage.ClockVisible);
			isClockVisible = isClockVisibleResult === 'true';
		} catch (e) {
			console.error('Error loading clock visibility:', e);
		}
	}
	onMount(() => {
		isSmallScreen = getIsSmallScreen();
		window.addEventListener('resize', handleResize);

		if (isDailyChallenge) {
			gridID = dailyChallengeID;
			loadGridFromDailyChallenge(dailyChallengeID);
		} else {
			gridID = parseInt(page.url.searchParams.get('id') ?? '-1');
			if (!gridID) {
				throw new Error('Invalid id');
			}
			loadGridFromDatabase(gridID);
		}
		loadClockVisibility();
		return () => {
			window.removeEventListener('resize', handleResize);
		};
	});

	function getColor() {
		return colorGenerator.getColor(words.filter((w) => w.isDiscovered).length);
	}

	function getWordIndex(word: string): { index: number; isReversed: boolean } | undefined {
		const wordDirection = words.findIndex((w) => w.word === word);
		if (wordDirection !== -1) {
			return { index: wordDirection, isReversed: false };
		}
		const reverseWord = word.split('').reverse().join('');
		const reverseWordDirection = words.findIndex((w) => w.word === reverseWord);
		if (reverseWordDirection !== -1) {
			return { index: reverseWordDirection, isReversed: true };
		}
		return undefined;
	}

	function setWordDiscovered(index: number, path: Position[]) {
		if (index !== -1) {
			words[index].color = 'bg-slate-200';
			words[index].textColor = 'text-gray-700';
			words[index].isDiscovered = true;
			words[index].discoveredPositions = path;
		}
		checkIfGameEnded();
	}

	let onWordSelect = (word: string, path: Position[], letterSize: number): Position[] => {
		const { index: wordIndex, isReversed } = getWordIndex(word) ?? {
			index: -1,
			isReversed: false
		};
		const wordToDiscover = isReversed ? word.split('').reverse().join('') : word;
		console.debug(
			'wordIndex',
			wordIndex,
			wordToDiscover,
			words.map((w) => w.word)
		);
		if (wordIndex !== undefined && !words[wordIndex].isDiscovered) {
			const normalizedPath = isReversed ? path.reverse() : path;
			addCoinsToPiggyBank(wordToDiscover);
			hintPositions.length = 0;
			const wordsDiscoveredCells = normalizedPath.map((p) =>
				document.getElementById(getPositionId(p.row, p.col))
			);
			const prefixForOrientation = isSmallScreen && isLandscape ? 'l-' : 'p-';
			const wordElementId = prefixForOrientation + wordToDiscover.toLowerCase();
			const wordElement = document.getElementById(wordElementId);

			const wordElementRect = wordElement?.getBoundingClientRect();
			if (wordElement && wordElementRect && wordsDiscoveredCells.length > 0) {
				const totalCells = wordsDiscoveredCells.length - 1;
				const duration = 750;
				wordsDiscoveredCells.forEach((cell, index) => {
					if (cell) {
						const rect = cell.getBoundingClientRect();
						const clone = cell.cloneNode(true) as HTMLElement;
						clone.removeAttribute('id');
						Object.assign(clone.style, {
							position: 'fixed',
							left: `${rect.left}px`,
							top: `${rect.top}px`,
							width: `${rect.width}px`,
							height: `${rect.height}px`,
							margin: 0,
							zIndex: 9999,

							pointerEvents: 'none' // prevent accidental clicks
						});
						utils.set(clone, {
							opacity: 0
						});
						document.body.appendChild(clone);

						const offsetX = Math.min(
							Math.max(10, (wordElementRect.width * index) / totalCells),
							wordElementRect.width - 10
						);
						const offsetY = wordElementRect.height / 2;
						const translateX =
							wordElementRect.x + wordElementRect.width / 2 - (rect.x + rect.width / 2);
						const translateY = wordElementRect.y + offsetY - (rect.y + rect.height / 2);
						animate(clone, {
							translateX: [0, translateX],
							translateY: [0, translateY],
							opacity: [1, 0.5, 0],
							fontSize: [letterSize + 'px', '6px'],
							duration: duration,
							easing: 'inOut',
							onBegin: () => {
								utils.set(clone, {
									opacity: 1,
									backgroundColor: 'rgba(255, 255, 255, 0)'
								});
							}
						}).then(() => {
							clone.remove();
						});
					}
				});

				setTimeout(() => {
					setWordDiscovered(wordIndex, normalizedPath);
				}, duration);

				animate(wordElement, {
					scale: [1, 1.2, 1],
					delay: duration - 100,
					duration: 300,
					easing: 'inOut'
				}).then(() => {});
			} else {
				setWordDiscovered(wordIndex, normalizedPath);
			}
			Haptics.impact({ style: ImpactStyle.Light });

			return path;
		}
		return [];
	};

	async function checkIfGameEnded() {
		const foundAllWords = words.every((w) => w.isDiscovered);
		if (foundAllWords) {
			isGameEnded = true;

			setTimeout(() => {
				showGameEnded = true;
			}, 1000);
			Haptics.impact({ style: ImpactStyle.Heavy });
			const gridID = game?.config.id.toString() ?? 'undefined';
			analytics.completeGame(difficulty ?? 'undefined', gridID);
			// Mark grid as played when game ends
			const gridId = parseInt(game?.config.id ?? '-1');
			if (!isNaN(gridId)) {
				databaseService.markGridAsPlayed(gridId, new Date(), elapsedTime);
			}
			if (isDailyChallenge && dailyChallengeID) {
				analytics.markQuoteAsPlayed(dailyChallengeID);
				await markQuoteAsPlayed(dailyChallengeID);
			}
			gameCounter.increment();
			Haptics.impact({ style: ImpactStyle.Heavy });
		}
	}

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

		const powerUpId = 'rotate';
		analytics.tryUsePowerUp(powerUpId);
		const didBuy = await walletStore.tryAndBuy(powerUpPrices.rotate);
		if (!didBuy) {
			analytics.failedToUsePowerUp(powerUpId);
			return;
		}

		analytics.usePowerUp(powerUpId);
		const rotateIcon = document.getElementById(iconId);
		const board = document.getElementById('board');
		if (board && rotateIcon) {
			animatePowerUp(
				board,
				rotateIcon,
				{
					rotationClockwise: isRotated
				},
				{
					onTranslationCompleted: () => {
						setTimeout(() => {
							isRotated = !isRotated;
						}, 100);
					}
				}
			);
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
		const suggestedCell = document.getElementById(
			getPositionId(suggestedLetter.row, suggestedLetter.col)
		);
		if (icon && suggestedCell) {
			animatePowerUp(suggestedCell, icon);
		}
		setBGColorTag(suggestedWord.word, getColor().bg);

		setTimeout(() => {
			isPowerUpAnimationActive = false;
		}, powerUpCooldownButton);
	}

	function setBGColorTag(word: string, color: string) {
		const { index } = getWordIndex(word) ?? { index: -1 };
		if (index !== undefined) {
			words[index].color = color;
		}
	}

	function getRandonUndiscoveredWord(): Word {
		const undiscoveredWord = words.filter((word) => !word.isDiscovered);
		const randomIndex = randomInt(undiscoveredWord.length - 1);
		return undiscoveredWord[randomIndex];
	}

	function animatePowerUp(
		board: HTMLElement,
		icon: HTMLElement,
		options?: {
			rotationClockwise?: boolean;
		},
		onAnimationCompletion?: {
			onTranslationCompleted?: () => void;
			onRotationCompleted?: () => void;
			onResetCompleted?: () => void;
		}
	) {
		const boardRect = board.getBoundingClientRect();
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
			animate(icon, {
				translateX,
				translateY,
				duration: 700,
				opacity: [1, 1, 0.8],
				scale: 1.5,
				easing: 'easeInOut',
				onComplete: () => {
					onAnimationCompletion?.onTranslationCompleted?.();
				}
			}).then(() => {
				// Second animation: fade out
				animate(icon, {
					delay: 100,
					opacity: [0.8, 0],
					rotate: [0, options?.rotationClockwise ? -360 : 360],
					scale: [1.5, 0.0],
					duration: 500,
					easing: 'easeOutQuad',
					onComplete: () => {
						onAnimationCompletion?.onRotationCompleted?.();
					}
				}).then(() => {
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
						easing: 'easeInOut',
						onComplete: () => {
							onAnimationCompletion?.onResetCompleted?.();
						}
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
			const suggestedCell = document.getElementById(
				getPositionId(suggestedLetter.row, suggestedLetter.col)
			);
			if (suggestedCell) {
				animatePowerUp(suggestedCell, findWordIcon);
			}
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
			if (!isActive) {
				showPauseModal = !isGameEnded;
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
		{#if showGameEnded}
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
								idPrefix="l-"
								{dailyChallenge}
								words={sortedWords}
								showClock={isClockVisible}
								{elapsedTime}
								{title}
								{onClockClick}
							/>
						{:else}
							<ClassicBoardWords
								idPrefix="l-"
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
								idPrefix="p-"
								{dailyChallenge}
								words={sortedWords}
								showClock={isClockVisible}
								{elapsedTime}
								{title}
								{onClockClick}
							/>
						{:else}
							<ClassicBoardWords
								idPrefix="p-"
								words={sortedWords}
								showClock={isClockVisible}
								{elapsedTime}
								{title}
								{onClockClick}
							/>
						{/if}
					</div>

					{#if isGameEnded}
						<div class="fixed inset-0 z-10 flex items-center justify-center">
							<Confetti
								x={[-1.5, 1.5]}
								y={[-1.5, 1.5]}
								iterationCount={5}
								amount={400}
								duration={2000}
								noGravity={true}
							/>
						</div>
					{/if}
					<Board
						grid={game.grid}
						{onWordSelect}
						{getColor}
						{isRotated}
						{hintPositions}
						{isGameEnded}
						class="board-container"
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
