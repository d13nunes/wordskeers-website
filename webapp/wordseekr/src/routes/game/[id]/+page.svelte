<script lang="ts">
	import ClassicGameEndedModal from '../ClassicGameEndedModal.svelte';

	import { Haptics, ImpactStyle } from '@capacitor/haptics';
	import GameButtons from '../GameButtons.svelte';
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
	import colorGenerator, { type ColorTheme } from '$lib/components/Game/color-generator';
	import { randomInt } from '$lib/utils/random-utils';
	import { walletStore } from '$lib/economy/walletStore';
	import { animate, utils } from 'animejs';
	import { goto } from '$app/navigation';
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
	import DailyChallengeBoardWords from '$lib/daily-challenge/DailyChallengeBoardWords.svelte';
	import ClassicBoardWords from '../ClassicBoardWords.svelte';
	import Confetti from 'svelte-confetti';
	import PauseMenu from '../PauseMenu.svelte';
	import { markQuoteAsPlayed } from '$lib/daily-challenge/quote-fetcher';
	import { levelsManager } from '$lib/levels/levels';
	import LevelsEndGameModal from '$lib/components/Levels/LevelsEndGameModal.svelte';
	import type { Level } from '$lib/database/types';
	import type { DailyChallenge } from '$lib/daily-challenge/models';
	import LevelAllCleared from '$lib/components/Levels/LevelAllCleared.svelte';
	import { gotoLevel, gotoMainMenu } from '../../utils/naviation';
	import QuotesGameEndedModal from '../QuotesGameEndedModal.svelte';
	import { syncLevels } from '$lib/firestore/firestore';
	import { fade } from 'svelte/transition';
	import { openStoreModal } from '$lib/tag-store';

	const powerUpCooldownButton = 1500;
	let showBoard = $state(false);
	let isSmallScreen = $state(true);
	let isLandscape = $state(false);
	let progressCircle = $state<SVGCircleElement | null>(null);
	let isRotated = $state(false);
	let isRotateDisabled = $state(false);
	let isFindLetterDisabled = $state(false);
	let isFindWordDisabled = $state(false);
	let isClockVisible = $state(false);
	let game = $state<Game | undefined>(undefined);
	let words = $derived<Word[]>(game?.words ?? []);
	let error: string | null = $state(null);
	let hintPositions: Position[] = $state([]);
	let showPauseModal = $state(false);
	let isPowerUpAnimationActive = $state(false);
	let isGameEnded = $state(false);
	let isRemoveAdsActive = $state(false);
	let showAllLevelCleared = $state(false);
	let isCheckingMoreLevels = $state(false);
	let title = $derived(game?.title ?? '');
	let level = $state<Level | null>(null);
	let levelName = $derived(level?.name ?? '');
	let levelNumber = $derived(level?.orderIndex ?? 0);
	let stageName = $derived(title ?? '');
	let previousProgressValue: number | null = $state(null);
	let currentProgressValue: number | null = $state(null);
	let levelStage: number | null = $state(null);
	let didWatchAd = false;
	let showGameEnded = $state(false);
	let difficulty: string = $state(page.url.searchParams.get('difficulty') as Difficulty);
	let dailyChallengeID = $state(parseInt(page.url.searchParams.get('dailyChallengeId') ?? '-1'));
	let isDailyChallenge = $derived(dailyChallengeID !== -1);
	let dailyChallenge = $state<DailyChallenge | null>(null);

	let setGameEndedTimeOut: NodeJS.Timeout | null = $state(null);

	let isLevel = $state(parseInt(page.url.searchParams.get('level') ?? '-1') !== -1);
	let gridID: number = $state(parseInt(page.params.id ?? '-1'));

	let showOnBoarding = $derived(isLevel && levelNumber === 1);
	// get first word that is !discovered and get its first position
	let onboardingPositions: Position[] = $derived(
		showOnBoarding
			? words
					.filter((w) => !w.isDiscovered)
					.slice(0, 1)
					.flatMap((w) => getWordPositions(w))
			: []
	);

	async function loadGridFromDatabase(gridID: number) {
		try {
			// Get a random grid for the selected difficulty
			const configuration = await getGridWithID(gridID);
			game = createGameForConfiguration(configuration);
			showBoard = true;
			console.log('grid', JSON.stringify(game.grid));
			console.log('words', JSON.stringify(game.words));
		} catch (e) {
			error = e instanceof Error ? e.message : 'Failed to load game';
			console.error('Error loading game:', e);
		}
	}

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
	async function createBoard() {
		if (setGameEndedTimeOut) {
			clearTimeout(setGameEndedTimeOut);
			setGameEndedTimeOut = null;
		}
		isGameEnded = false;
		showGameEnded = false;

		if (isLevel) {
			level = await levelsManager.getCurrentLevel();

			const currentProgress = await levelsManager.getCurrentProgress();
			previousProgressValue = currentProgress;
			levelStage = await levelsManager.getCurrentStageNumber();
			analytics.startLevelStage(levelNumber, levelStage, gridID);
		}
		if (isDailyChallenge) {
			dailyChallenge = await getDailyChallenge(dailyChallengeID);
			analytics.startedPlayingQuote(dailyChallengeID);
		}
		if (!gridID) {
			isCheckingMoreLevels = true;
			await syncLevels();
			const itHasMoreLevels = await levelsManager.onMoreLevelsLoadedCheckItHasMoreLevels();
			if (itHasMoreLevels) {
				await navigateToNextLevel(true);
			}
			showAllLevelCleared = !itHasMoreLevels;
			isCheckingMoreLevels = false;
		} else {
			game = undefined;
			loadGridFromDatabase(gridID);
		}
	}

	onMount(() => {
		isSmallScreen = getIsSmallScreen();
		handleResize();
		window.addEventListener('resize', handleResize);
		createBoard();
		loadClockVisibility();
		walletStore.removeAds((removeAds) => {
			isRemoveAdsActive = removeAds;
		});
		openStoreModal.subscribe((value) => {
			showPauseModal = value;
		});
		return () => {
			window.removeEventListener('resize', handleResize);
		};
	});

	let currentColor: ColorTheme = $state(colorGenerator.getNextColor());
	function loadNextColor() {
		currentColor = colorGenerator.getNextColor();
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
		if (wordIndex !== undefined && wordIndex !== -1 && !words[wordIndex].isDiscovered) {
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

			setTimeout(() => {
				loadNextColor();
			}, 1);
			return path;
		}
		setTimeout(() => {
			loadNextColor();
		}, 1);
		return [];
	};

	async function checkIfGameEnded() {
		const foundAllWords = words.every((w) => w.isDiscovered);
		if (foundAllWords) {
			isGameEnded = true;

			Haptics.impact({ style: ImpactStyle.Heavy });

			analytics.completeGame(difficulty ?? 'undefined', gridID.toString());
			// Mark grid as played when game ends

			if (!isNaN(gridID)) {
				databaseService.markGridAsPlayed(gridID, new Date(), elapsedTime);
			}
			if (isDailyChallenge && dailyChallengeID) {
				analytics.markQuoteAsPlayed(dailyChallengeID);
				await markQuoteAsPlayed(dailyChallengeID);
			}
			if (isLevel) {
				const currentProgress = await levelsManager.markGridAsCompleted(gridID);
				currentProgressValue = currentProgress;
				analytics.completeLevelStage(levelNumber, levelStage ?? 0, gridID, elapsedTime);
			}

			gameCounter.increment();
			Haptics.impact({ style: ImpactStyle.Heavy });
			setGameEndedTimeOut = setTimeout(() => {
				showGameEnded = true;
			}, 1000);
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
		if (isPowerUpAnimationActive) {
			return;
		}
		if (isRotateDisabled) {
			openStoreModal.set(true);
			return;
		}
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
		if (isPowerUpAnimationActive) {
			return;
		}
		if (isFindLetterDisabled) {
			openStoreModal.set(true);
			return;
		}
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
		loadNextColor();
		setBGColorTag(suggestedWord.word, currentColor.bg);

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
		if (isPowerUpAnimationActive) {
			return;
		}
		if (isFindWordDisabled) {
			openStoreModal.set(true);
			return;
		}
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
			loadNextColor();
			setBGColorTag(suggestedWord.word, currentColor.bg);
		}
		setTimeout(() => {
			isPowerUpAnimationActive = false;
		}, powerUpCooldownButton);
	}

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
				showPauseModal = !isLevel && !isGameEnded;
			} else {
				openStoreModal.set(false);
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

	async function collectReward(showAd: boolean): Promise<void> {
		if (showAd) {
			didWatchAd = await adStore.showAd(AdType.Rewarded, null);
		} else {
			didWatchAd = false;
		}
	}

	function onRewardGiven() {
		if (isDailyChallenge) {
			const quoteDailyChallengeReward = 100;
			walletStore.addCoins(quoteDailyChallengeReward);
		} else {
			const gameEndedPrize = didWatchAd ? accumulatedCoins * 2 : accumulatedCoins;
			walletStore.addCoins(gameEndedPrize);
		}
	}

	function onRewardAnimationCompleted() {
		console.log('📺📺📺 show end game ad');

		endGameAdStore.show({ didWatchRewardAd: didWatchAd, isDailyChallenge: isDailyChallenge });
		gotoMainMenu();
	}

	// Add coin calculation function and state
	function calculateWordCoins(word: string): number {
		return 2; // Default reward per word
	}

	let accumulatedCoins = $state(0);

	async function onClockClick(isClockVisible_: boolean) {
		isClockVisible = isClockVisible_;
		await myLocalStorage.set(myLocalStorage.ClockVisible, isClockVisible.toString());
	}

	function pauseMenuNewGameClick() {
		analytics.quitGame(difficulty ?? 'undefined', game?.config.id.toString() ?? 'undefined');
		gotoMainMenu();
	}

	async function navigateToNextLevel(skipAd: boolean = false) {
		clearInterval(timerInterval);
		showGameEnded = false;
		showBoard = false;

		const canShowAdLevel = level && level.orderIndex >= 3;
		const didCompleteLevel = currentProgressValue && currentProgressValue >= 1;
		const isLevelWithMoreThan3Stages = level && level.gridIds.length > 3;
		const isFirstStage = level && level.orderIndex === 0;
		const isEvenStage = level && level.orderIndex % 2 === 0;
		const showAd =
			(canShowAdLevel && didCompleteLevel) ||
			(canShowAdLevel && isLevelWithMoreThan3Stages && !isFirstStage && isEvenStage);
		if (showAd && !skipAd) {
			const maxFrequencyMillis = 1000 * 60; // 1 minute
			adStore.showAd(AdType.Interstitial, maxFrequencyMillis);
		}
		const nextLevel = (await levelsManager.getCurrentLevel()).orderIndex;
		const nextGridId = await levelsManager.getNextGridId();

		difficulty = 'levels';

		setTimeout(() => {
			gotoLevel(nextGridId, nextLevel, true);

			gridID = nextGridId;
			levelNumber = nextLevel;

			setTimeout(async () => {
				await adStore.initialize();
				console.log('📺 initAds game - completed');
				const success = await adStore.showAd(AdType.Banner, null);
				console.log('📺 BannerAd shown', success);
			}, 1500);

			showOnBoarding = false;

			createBoard();
		}, 500);

		try {
			syncLevels();
		} catch (e) {
			console.error('navigateToNextLevel error', e);
		}
	}
</script>

{#if error}
	<div class="bg-opacity-75 fixed inset-0 z-50 flex items-center justify-center bg-white">
		<div class="mx-4 max-w-md rounded-lg border border-red-900 bg-red-50 p-4">
			<h3 class="text-lg font-medium text-red-800">Error</h3>
			<p class="mt-2 text-sm text-red-700">{error}</p>
			<button
				class="mt-4 rounded-md bg-red-100 px-4 py-2 text-red-700 transition-colors hover:bg-red-200"
				onclick={() => gotoMainMenu()}
			>
				Return to Home
			</button>
		</div>
	</div>
{:else if !game}
	{#if isCheckingMoreLevels}
		// spinner
		<div class="fixed inset-0 z-50 flex items-center justify-center bg-white">
			<div class="h-10 w-10 animate-spin rounded-full border-t-2 border-b-2 border-gray-900"></div>
		</div>
	{:else if showAllLevelCleared}
		<div
			class="fixed inset-0 z-50 flex max-h-full items-center justify-center bg-white"
			style="	padding-top: var(--safe-area-inset-top);
		padding-right: var(--safe-area-inset-right);
		padding-bottom: var(--safe-area-inset-bottom);
		padding-left: var(--safe-area-inset-left);"
		>
			<LevelAllCleared />
		</div>
	{:else}
		<button
			in:fade={{ duration: 1000, delay: 2000 }}
			class="fixed inset-0 z-50 flex items-center justify-center bg-white text-white"
			onclick={() => gotoMainMenu()}
		>
			Main Menu
		</button>
	{/if}
{:else}
	<div
		class=" flex h-full flex-row items-end justify-center md:items-center landscape:items-center"
		style="overflow: hidden;"
	>
		{#if showPauseModal}
			<PauseMenu
				onClickResume={() => (showPauseModal = false)}
				onClickNewGame={pauseMenuNewGameClick}
			/>
		{/if}
		{#if showGameEnded && !isLevel && isDailyChallenge && dailyChallenge}
			<QuotesGameEndedModal
				quoteChallenge={dailyChallenge}
				{accumulatedCoins}
				{onRewardAnimationCompleted}
				{onRewardGiven}
				collectReward={() => collectReward(false)}
				doubleReward={() => collectReward(true)}
				{isRewardAdReady}
			/>
		{:else if showGameEnded && isLevel && previousProgressValue !== null && currentProgressValue !== null}
			<LevelsEndGameModal
				{levelName}
				{stageName}
				{levelNumber}
				previousProgressValue={Math.round(previousProgressValue * 100)}
				currentProgressValue={Math.round(currentProgressValue * 100)}
				{navigateToNextLevel}
				onClose={() => gotoMainMenu()}
			/>
		{:else if showGameEnded && !isLevel && !isDailyChallenge}
			<ClassicGameEndedModal
				elapsedTime={getFormatedTime(elapsedTime)}
				{accumulatedCoins}
				{onRewardAnimationCompleted}
				{onRewardGiven}
				collectReward={() => collectReward(false)}
				doubleReward={() => collectReward(true)}
				{isRewardAdReady}
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
					{#if showBoard}
						<div in:fade={{ duration: 1000 }} out:fade={{ duration: 200, delay: 500 }} class="mb-4">
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
									showClockTime={isClockVisible}
									hideClock={isLevel}
									{elapsedTime}
									{title}
									{onClockClick}
								/>
							{/if}
						</div>
					{/if}
					{#if !showOnBoarding}
						<GameButtons
							findWordIconId="fwi-l"
							findLetterIconId="fli-l"
							rotateIconId="ri-l"
							{onPauseClick}
							{onPowerUpFindWordClick}
							{onPowerUpFindLetterClick}
							{onPowerUpRotateClick}
							isFindWordDisabled={false}
							isFindLetterDisabled={false}
							isRotateDisabled={false}
							findWordPrice={powerUpPrices.findWord.toString()}
							findLetterPrice={powerUpPrices.findLetter.toString()}
							rotatePrice={powerUpPrices.rotate.toString()}
						/>
					{/if}
				</div>
			{/if}
			<div
				class="flex h-full w-full flex-col items-center gap-6 max-[24rem]:gap-2 sm:max-w-3/4 sm:gap-2 sm:px-0 md:max-w-2/4 md:gap-2 lg:items-center lg:justify-center
				{isSmallScreen ? 'landscape:w-1/2 ' : ''} {isRemoveAdsActive && isSmallScreen
					? 'portrait:pb-2'
					: 'portrait:pb-[54px]'} 
				"
			>
				<!-- Board & Words -->
				<div
					class="flex h-full w-full flex-col items-center justify-start gap-4 px-4 max-[24rem]:gap-0 sm:gap-6 md:gap-1
					{isSmallScreen ? 'landscape:items-start ' : ''}"
				>
					{#if showBoard}
						<div
							in:fade={{ duration: 1000 }}
							out:fade={{ duration: 200, delay: 500 }}
							class="{isSmallScreen
								? 'portrait:block portrait:w-full landscape:hidden'
								: 'min-w-xs'} px-1"
						>
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
									showClockTime={isClockVisible}
									hideClock={isLevel}
									{elapsedTime}
									{title}
									{onClockClick}
								/>
							{/if}
						</div>
					{/if}

					{#if isGameEnded}
						<div class="fixed inset-0 z-10 flex items-center justify-center">
							<Confetti
								x={[-1.5, 1.5]}
								y={[-1.5, 1.5]}
								iterationCount={1}
								amount={400}
								duration={2000}
								noGravity={true}
							/>
						</div>
					{/if}
					{#if showBoard}
						<Board
							grid={game.grid}
							{onWordSelect}
							{currentColor}
							{isRotated}
							{hintPositions}
							class="board-container"
							{onboardingPositions}
						/>
					{/if}
				</div>
				<!-- Game Buttons -->
				<div
					class="{isSmallScreen
						? 'w-full portrait:block landscape:hidden'
						: 'mt-4 w-xs'} px-4 max-[24rem]:mt-0"
					style="padding-bottom: {isSmallScreen
						? 'calc(var(--safe-area-inset-bottom) + 8px)'
						: '0px'}"
				>
					{#if !showOnBoarding}
						<GameButtons
							findWordIconId="fwi-p"
							findLetterIconId="fli-p"
							rotateIconId="ri-p"
							{onPauseClick}
							{onPowerUpFindWordClick}
							{onPowerUpFindLetterClick}
							{onPowerUpRotateClick}
							isFindWordDisabled={false}
							isFindLetterDisabled={false}
							isRotateDisabled={false}
							findWordPrice={powerUpPrices.findWord.toString()}
							findLetterPrice={powerUpPrices.findLetter.toString()}
							rotatePrice={powerUpPrices.rotate.toString()}
						/>
					{/if}
				</div>
			</div>
		</div>
	</div>
{/if}
