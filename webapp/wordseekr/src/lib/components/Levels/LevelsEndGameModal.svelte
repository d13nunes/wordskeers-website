<script lang="ts">
	import Modal from '$lib/components/Modal.svelte';
	import GameModeIconTitle from '../GameModeIconTitle.svelte';
	import levelsIcons from '$lib/assets/levels.png';
	import { goto } from '$app/navigation';
	import { levelsManager } from '$lib/levels/levels';
	import { onMount } from 'svelte';
	import { animate, eases, JSAnimation, utils } from 'animejs';
	import LevelsRewardIcon from '$lib/components/Levels/LevelsRewardIcon.svelte';
	import Confetti from 'svelte-confetti';
	import CoinsPileIcon from '../Icons/CoinsPileIcon.svelte';
	import { getFormatedTime } from '$lib/utils/string-utils';
	import LevelGiftBottom from './LevelGiftBottom.svelte';
	import LevelGiftTop from './LevelGiftTop.svelte';
	import { adStore } from '$lib/ads/ads';
	import { AdType } from '$lib/ads/ads-types';

	interface Props {
		previousProgressValue: number;
		currentProgressValue: number;
		levelName: string;
		stageName: string;
		onClose: () => void;
	}

	const { previousProgressValue, currentProgressValue, levelName, stageName, onClose }: Props =
		$props();
	let rewardIcon: HTMLDivElement | null = null;
	let showConfetti = $state(true);

	let icon = $state(levelsIcons);
	let iconId = $state('magnifierglassId');
	let levelNumber = $state(1);
	let title = $state('Levels');
	let progress = $state(previousProgressValue);
	let subtitle = $derived('Level ' + levelNumber + ' - ' + levelName);
	let isLevelCompleted = $derived(currentProgressValue >= 100);
	let didFinishAnimating = false;

	function playNextLevel() {
		didFinishAnimating = true;
		if (isLevelCompleted) {
			const balanceTag = document.getElementById('balance-tag-icon');
			const coinsPileIcon = document.getElementById('coins-pile-icon');
			const levelGiftTop = document.getElementById('level-gift-top');
			console.log('!!! coinsPileIcon', coinsPileIcon);
			if (coinsPileIcon && balanceTag && levelGiftTop) {
				console.log('!!! levelGiftTop', levelGiftTop);
				const balanceTagRect = balanceTag.getBoundingClientRect();
				const coinPileIconRect = coinsPileIcon.getBoundingClientRect();
				const translateX = balanceTagRect.x - coinPileIconRect.x - coinPileIconRect.width / 4;
				const translateY = balanceTagRect.y - coinPileIconRect.y - coinPileIconRect.height / 4;
				const animationDuration = 750;
				shakeAnimation?.revert();
				const delay = 200;
				showConfetti = false;
				animate(levelGiftTop, {
					rotate: [0, -90],
					duration: 750,
					delay: delay
				}).then(() => {
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
						console.log('!!! goto levels 3');
						setTimeout(async () => {
							// const didSawAd = await adStore.showAd(AdType.Interstitial, null);
							// TODO analytics
							goto(`/levels`, { replaceState: true });
						}, 0);
					});
				});
			} else {
				console.log('!!! goto levels 1');
				goto(`/levels`, { replaceState: true });
			}
		} else {
			console.log('!!! goto levels 2');
			goto(`/levels`, { replaceState: true });
		}
	}

	function onRewardClick() {
		playNextLevel();
	}
	async function onPlayClick() {
		playNextLevel();
	}

	let rewardIconScaleInitial = 3 + previousProgressValue / 100;
	let rewardIconScaleFinal = 3 + currentProgressValue / 100;
	let shakeAnimation: JSAnimation | null = null;
	onMount(() => {
		let counter = { value: previousProgressValue };
		animate(counter, {
			value: currentProgressValue,
			delay: 500,
			duration: 1000,
			ease: 'inQuad',
			modifier: utils.round(0),
			onUpdate: function () {
				progress = counter.value;
			}
		});
		if (rewardIcon) {
			animate(rewardIcon, {
				scale: rewardIconScaleFinal,
				delay: 0,
				duration: 1500,
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
	let message = $state(
		"You found all the words in 00:00\nYou've earned 0 coins!"
		// `You found all the words in ${getFormatedTime(elapsedTime)}\nYou've earned ${accumulatedCoins} coins!`
	);
</script>

<Modal {onClose} backgroundOpacity={50}>
	<div class="mt-2 flex w-3xs flex-col items-center justify-center">
		<!-- <div class="mb-4 text-3xl font-bold text-gray-900">Stage Completed</div> -->
		<!-- <GameModeIconTitle {icon} {iconId} {title} {subtitle} /> -->
		<!-- <div class=" text-5xl font-bold text-gray-900">{title}</div> -->
		<div class="mt-0 text-center text-4xl font-bold text-gray-900">{title}</div>
		<div class="mt-1 text-center text-2xl font-bold text-gray-600">
			{levelName} - {stageName}
		</div>
		<div class="mt-4 flex w-full flex-col items-center gap-1 px-4">
			<div class="relative my-4 flex min-h-14 items-center justify-center">
				<button onclick={onRewardClick}>
					{#if isLevelCompleted}
						<div
							id="coins-pile-icon"
							class="absolute -top-7 -left-[10px] z-100 h-12 w-12 opacity-0"
						>
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
						class="z-60 h-5 w-5"
						style="transform: scale({rewardIconScaleInitial});"
					>
						<div id="level-gift-top" class="z-100" style="transform-origin: 0% 100%;">
							<LevelGiftTop />
						</div>
						<div id="level-gift-bottom" class="z-100">
							<LevelGiftBottom />
						</div>
					</div></button
				>
			</div>
			<div class="self-start ps-2 text-sm text-gray-500">Level progress {progress}%</div>
			<div class="relative w-full">
				<div class=" min-h-4 w-full overflow-hidden rounded-md bg-gray-300">
					<div
						class="progress-bar-fill h-4 rounded-e-md bg-green-800"
						style="width: {progress}%;"
					></div>
				</div>
			</div>
		</div>
		<button
			class="button-active mt-8 w-full rounded-md bg-red-800 px-4 py-2 text-xl font-bold text-white lg:mt-8"
			onclick={onPlayClick}
		>
			Next Level
		</button>
	</div>
</Modal>
