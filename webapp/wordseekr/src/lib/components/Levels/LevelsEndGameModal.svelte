<script lang="ts">
	import Modal from '$lib/components/Modal.svelte';
	import { goto } from '$app/navigation';
	import { onDestroy, onMount } from 'svelte';
	import { animate, eases, JSAnimation, utils } from 'animejs';
	import Confetti from 'svelte-confetti';
	import CoinsPileIcon from '../Icons/CoinsPileIcon.svelte';
	import LevelGiftBottom from '$lib/assets/level-gift-bottom.png';
	import LevelGiftTop from '$lib/assets/level-gift-top.png';

	interface Props {
		previousProgressValue: number;
		currentProgressValue: number;
		levelName: string;
		stageName: string;
		navigateToNextLevel: () => void;
		onDismiss: () => void;
		onClose: () => void;
	}

	const {
		previousProgressValue,
		currentProgressValue,
		levelName,
		stageName,
		onDismiss,
		navigateToNextLevel,
		onClose
	}: Props = $props();
	let rewardIcon: HTMLDivElement | null = null;
	let showConfetti = $state(true);

	let levelNumber = $state(1);
	let title = $state('Levels');
	let progress = $state(previousProgressValue);
	let isLevelCompleted = currentProgressValue >= 100;
	let didFinishAnimating = false;
	let navigateToNextLevelTimeout: NodeJS.Timeout | null = null;

	function playNextLevel() {
		if (didFinishAnimating) {
			return;
		}
		didFinishAnimating = true;
		if (isLevelCompleted) {
			const balanceTag = document.getElementById('balance-tag-icon');
			const coinsPileIcon = document.getElementById('coins-pile-icon');
			const levelGiftTop = document.getElementById('level-gift-top');
			const levelGiftBottom = document.getElementById('level-gift-bottom');
			console.log('!!! coinsPileIcon', coinsPileIcon);
			if (coinsPileIcon && balanceTag && levelGiftTop && levelGiftBottom) {
				console.log('!!! levelGiftTop', levelGiftTop);
				console.log('!!! levelGiftBottom', levelGiftBottom);
				const balanceTagRect = balanceTag.getBoundingClientRect();
				const coinPileIconRect = coinsPileIcon.getBoundingClientRect();
				const translateX = balanceTagRect.x - coinPileIconRect.x - coinPileIconRect.width / 4;
				const translateY = balanceTagRect.y - coinPileIconRect.y - coinPileIconRect.height / 4;
				const levelGiftBottomRect = levelGiftBottom.getBoundingClientRect();
				const levelGiftBottomTranslateX = (coinPileIconRect.width / 5) * 2;
				const levelGiftBottomTranslateY = coinPileIconRect.height / 4 + 2;
				const animationDuration = 750;
				shakeAnimation?.revert();
				const delay = 200;

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
					showConfetti = false;
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
						scale: [1, 0.25],
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

	function onRewardClick() {
		playNextLevel();
	}
	async function onPlayClick() {
		playNextLevel();
	}
	let rewardIconScaleInitial = 1.5 + previousProgressValue / 100 / 2;
	let rewardIconScaleFinal = 1.5 + currentProgressValue / 100 / 2;
	let shakeAnimation: JSAnimation | null = null;
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
			animate(rewardIcon, {
				scale: rewardIconScaleFinal,
				delay: 0,
				duration: 2500,
				ease: 'linear'
			}).then(() => {
				if (isLevelCompleted) {
					if (rewardIcon && !didFinishAnimating) {
						shakeAnimation = animate(rewardIcon, {
							rotate: [0, -5, 10, -10, 5, 0],
							duration: 500,
							loop: true,
							loopDelay: 1000
						});
					}
				}
			});
		}
	});
	const initialCountdown = isLevelCompleted ? 5 : 3;
	let nextLevelIn = $state(initialCountdown);
	let nextLevelTimeText = $state(`Next level in ${initialCountdown}`);
	let timerInterval = setInterval(() => {
		nextLevelIn--;
		nextLevelTimeText = `Next level in ${nextLevelIn}`;
		if (nextLevelIn <= 0) {
			nextLevelTimeText = `Have Fun!`;
			clearInterval(timerInterval);
			if (!didFinishAnimating) {
				navigateToNextLevelTimeout = setTimeout(() => {
					playNextLevel();
				}, 1000);
			}
		}
	}, 500);

	onDestroy(() => {
		clearInterval(timerInterval);
		if (navigateToNextLevelTimeout) {
			clearTimeout(navigateToNextLevelTimeout);
		}
	});
</script>

<Modal {onClose} {onDismiss} backgroundOpacity={50}>
	<div class="mt-2 flex w-3xs flex-col items-center justify-center">
		<div class="mt-0 text-center text-4xl font-bold text-gray-900">{title}</div>
		<div class="mt-1 text-center text-2xl font-bold text-gray-600">
			{levelName} - {stageName}
		</div>
		<div class="mt-8 flex w-full flex-col items-center gap-1 px-4">
			<div class="relative my-4 flex min-h-14 items-center justify-center">
				<button onclick={onRewardClick}>
					{#if isLevelCompleted}
						<div id="coins-pile-icon" class="absolute -left-[10px] z-50 h-12 w-12 opacity-0">
							<CoinsPileIcon />
						</div>
						<div class="absolute top-2 right-2.5">
							{#if showConfetti}
								<Confetti
									x={[-0.5, 0.5]}
									y={[-0.3, 0.25]}
									iterationCount={13}
									amount={100}
									delay={[1500, 1500]}
									duration={1000}
									noGravity={true}
								/>
							{/if}
						</div>
					{/if}
					<div
						bind:this={rewardIcon}
						class="relative z-60 h-[25px] w-[25px]"
						style="scale: {rewardIconScaleInitial}"
					>
						<img
							src={LevelGiftTop}
							alt="Logo"
							id="level-gift-top"
							class="pointer-events-none absolute top-0 z-100 w-[25px] shadow-lg select-none"
							style="transform-origin: 0% 100%;"
						/>
						<img
							src={LevelGiftBottom}
							alt="Logo"
							id="level-gift-bottom"
							class="pointer-events-none z-100 w-[25px] pt-[8px] select-none"
						/>
					</div></button
				>
			</div>
			<div class="mt-2 self-start ps-2 text-sm text-gray-500">Level progress {progress}%</div>
			<div class="relative w-full">
				<div class=" min-h-4 w-full overflow-hidden rounded-md bg-gray-300">
					<div
						class="progress-bar-fill h-4 rounded-e-md bg-green-800"
						style="width: {progress}%;"
					></div>
				</div>
			</div>
		</div>
		<div class="mt-8 flex w-full flex-col gap-2">
			<div class=" ps-2 text-left font-mono text-xs/2 font-bold text-gray-600">
				{nextLevelTimeText}
			</div>
			<button
				class="button-active mt-0 flex w-full flex-row items-center justify-center gap-2 rounded-md bg-red-800 px-4 py-2 text-xl font-bold text-white"
				onclick={onPlayClick}
			>
				<div class="w-full text-xl font-bold text-white">Play Now</div>
			</button>
		</div>
	</div>
</Modal>
