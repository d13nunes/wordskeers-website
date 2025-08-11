<script lang="ts">
	import LevelsProgressBar from './LevelsProgressBar.svelte';
	import Modal from '$lib/components/Modal.svelte';
	import { onDestroy, onMount } from 'svelte';
	import { animate, eases, JSAnimation, utils } from 'animejs';
	import CoinsPileIcon from '../Icons/CoinsPileIcon.svelte';
	import LevelGiftTop from './LevelGiftTop.svelte';
	import LevelGiftBottom from './LevelGiftBottom.svelte';
	import { walletStore } from '$lib/economy/walletStore';
	import { slide } from 'svelte/transition';

	interface Props {
		previousProgressValue: number;
		currentProgressValue: number;
		levelNumber: number;
		levelName: string;
		stageName: string;
		navigateToNextLevel: () => void;
		onClose: () => void;
	}

	const {
		previousProgressValue,
		currentProgressValue,
		levelNumber,
		levelName,
		stageName,
		navigateToNextLevel,
		onClose
	}: Props = $props();
	let rewardIcon: HTMLDivElement | null = null;
	let showConfetti = $state(true);

	let progress = $state(previousProgressValue);
	let isLevelCompleted = currentProgressValue >= 100;
	let isFinishingLastAnimation = $state(false);
	let navigateToNextLevelTimeout: NodeJS.Timeout | null = null;
	const initialCountdown = isLevelCompleted ? 5 : 5;

	let rewardIconScaleInitial = Math.max(Math.min(1 + (previousProgressValue / 100) * 4, 2), 1.5);
	let rewardIconScaleFinal = rewardIconScaleInitial + (currentProgressValue / 100) * 1.5;

	let title = $derived(`Level ${levelNumber}`);
	let shakeAnimation: JSAnimation | null = null;
	let scaleAnimation: JSAnimation | null = null;
	let nextLevelIn = $state(initialCountdown);
	let nextLevelTimeText = $state(`Next level in ${initialCountdown}`);
	let timerInterval = setInterval(() => {
		nextLevelIn--;
		nextLevelTimeText = `Next level in ${nextLevelIn}`;
		if (nextLevelIn <= 0) {
			nextLevelTimeText = ''; //`Have Fun!`;
			clearInterval(timerInterval);
			if (!isFinishingLastAnimation) {
				navigateToNextLevelTimeout = setTimeout(() => {
					playNextLevel();
				}, 1000);
			}
		}
	}, 500);
	function getRewardAmount() {
		return Math.min(20 * levelNumber, 200 + 1 * levelNumber);
	}

	function giveReward() {
		if (rewardGiven) {
			return;
		}
		walletStore.addCoins(getRewardAmount());
		rewardGiven = true;
	}

	function playNextLevel() {
		if (isFinishingLastAnimation) {
			return;
		}
		isFinishingLastAnimation = true;
		if (isLevelCompleted) {
			const balanceTag = document.getElementById('balance-tag-icon');
			const coinsPileIcon = document.getElementById('coins-pile-icon');
			const levelGiftTop = document.getElementById('level-gift-top');
			const levelGiftBottom = document.getElementById('level-gift-bottom');
			if (coinsPileIcon && balanceTag && levelGiftTop && levelGiftBottom && rewardIcon) {
				const balanceTagRect = balanceTag.getBoundingClientRect();
				const coinPileIconRect = coinsPileIcon.getBoundingClientRect();
				const translateX = balanceTagRect.x - coinPileIconRect.x - coinPileIconRect.width / 4;
				const translateY = balanceTagRect.y - coinPileIconRect.y - balanceTagRect.height * 4;
				const levelGiftBottomRect = levelGiftBottom.getBoundingClientRect();
				const rewardIconScale = parseFloat(utils.get(rewardIcon, 'scale'));
				const levelGiftBottomRectWidth = levelGiftBottomRect.width / rewardIconScale;
				const levelGiftBottomTranslateX = (levelGiftBottomRectWidth / 4) * 3;

				const levelGiftBottomTranslateY = levelGiftBottomRect.height / rewardIconScale;
				const animationDuration = 750;

				shakeAnimation?.revert();
				scaleAnimation?.complete();

				const delay = 200;

				showConfetti = false;
				animate(coinsPileIcon, {
					opacity: [0, 1],
					translateY: -55,
					duration: 750 * 2,
					ease: eases.outElastic(1.1, 1),
					delay: delay
				});
				animate(levelGiftTop, {
					translateX: levelGiftBottomTranslateX,
					duration: 750,
					ease: eases.outElastic(0.5, 1),
					delay: delay
				});
				animate(levelGiftTop, {
					translateY: levelGiftBottomTranslateY,
					duration: 750,
					ease: eases.inElastic(0.5, 2),
					delay: delay
				}).then(() => {
					giveReward();
					animate(coinsPileIcon, {
						translateX,
						ease: 'in',
						duration: animationDuration
					});
					animate(coinsPileIcon, {
						translateY,
						ease: 'out',
						duration: animationDuration
					});
					animate(coinsPileIcon, {
						opacity: [1, 1],
						scale: [1, 0.5, 0],
						ease: 'inOut',
						duration: animationDuration
					}).then(() => {
						navigateToNextLevelTimeout = setTimeout(async () => {
							navigateToNextLevel();
						}, 0);
					});
				});
			} else {
				navigateToNextLevel();
			}
		} else {
			navigateToNextLevel();
		}
	}

	let rewardGiven = false;

	function onRewardClick() {
		playNextLevel();
	}

	async function onPlayClick() {
		playNextLevel();
	}

	async function onDismiss() {
		await playNextLevel();
	}
	function onClose__() {
		if (!rewardGiven && isLevelCompleted) {
			giveReward();
		}
		onClose();
	}

	let onClose_ = $derived(!isFinishingLastAnimation ? onClose__ : undefined);

	onDestroy(() => {
		clearInterval(timerInterval);
		if (navigateToNextLevelTimeout) {
			clearTimeout(navigateToNextLevelTimeout);
		}
	});

	onMount(() => {
		let counter = { value: previousProgressValue };
		animate(counter, {
			value: currentProgressValue,
			delay: 500,
			duration: 2000,
			ease: 'outQuad',
			modifier: utils.round(0),
			onUpdate: function () {
				progress = counter.value;
			}
		});
		if (rewardIcon) {
			scaleAnimation = animate(rewardIcon, {
				scale: [rewardIconScaleInitial, rewardIconScaleFinal],
				delay: 0,
				duration: 2500,
				ease: 'linear'
			});
			scaleAnimation.then(() => {
				if (isLevelCompleted) {
					if (rewardIcon && !isFinishingLastAnimation) {
						shakeAnimation = animate(rewardIcon, {
							rotate: [0, -5, 10, -10, 10, -10, 5, 0],
							duration: 500,
							loop: true,
							loopDelay: 1000
						});
					}
				}
			});
		}
	});
</script>

<Modal onClose={onClose_} {onDismiss} backgroundOpacity={50}>
	<div class="mt-2 flex w-3xs flex-col items-center justify-center">
		<div class="mt-0 text-center text-4xl font-bold text-gray-900 dark:text-gray-100">{title}</div>
		<div class="mt-1 text-center text-2xl font-bold text-gray-600 dark:text-gray-300">
			{levelName} - {stageName}
		</div>
		<div class="mt-8 flex w-full flex-col items-center gap-1 px-4">
			<div class="relative my-4 flex min-h-14 items-center justify-center">
				<button onclick={onRewardClick}>
					{#if isLevelCompleted}
						<div id="coins-pile-icon" class="absolute -left-[10px] z-50 h-12 w-12 opacity-0">
							<CoinsPileIcon />
						</div>
					{/if}
					<div bind:this={rewardIcon} class="relative z-60 h-[25px] w-[26px]">
						<LevelGiftTop
							id="level-gift-top"
							class="pointer-events-none absolute  z-100  w-[30px] shadow-lg select-none"
							style="
							transform-origin: 0% 100%;
							margin-top: -8%;
							"
						/>
						<LevelGiftBottom
							id="level-gift-bottom"
							class="pointer-events-none z-100 w-[30px] pt-[8px] select-none"
							style=""
						/>
					</div>
				</button>
			</div>
			<LevelsProgressBar
				class="mt-2"
				{currentProgressValue}
				startAnimation={true}
				{previousProgressValue}
			/>
		</div>
		{#if !isFinishingLastAnimation}
			<div out:slide={{ duration: 200, axis: 'y' }} class="mt-8 flex w-full flex-col gap-2">
				<div class=" min-h-2 ps-2 text-left font-mono text-xs/2 font-bold text-gray-600 dark:text-gray-300">
					{nextLevelTimeText}
				</div>
				<button
					class="button-active mt-0 flex w-full flex-row items-center justify-center gap-2 rounded-md bg-red-800 px-4 py-2 text-xl font-bold text-white"
					onclick={onPlayClick}
				>
					<div class="w-full text-xl font-bold text-white dark:text-gray-100">Play Now</div>
				</button>
			</div>
		{/if}
	</div>
</Modal>
