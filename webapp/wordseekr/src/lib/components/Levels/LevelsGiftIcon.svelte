<script lang="ts">
	import CoinsPileIcon from '../Icons/CoinsPileIcon.svelte';
	import LevelGiftBottom from './LevelGiftBottom.svelte';
	import LevelGiftTop from './LevelGiftTop.svelte';
	import { JSAnimation, Timeline, animate, eases } from 'animejs';

	// Animation state

	let topElement: any;
	let bottomElement: any;

	interface Props {
		isAnimating?: boolean;
		animateCoin?: boolean;
		onGiveReward?: () => void;
		onCoinAnimationCompleted?: () => void;
	}

	let {
		isAnimating = false,
		animateCoin = false,
		onGiveReward,
		onCoinAnimationCompleted
	}: Props = $props();
	let shakingAnimation: JSAnimation | null = null;

	$effect(() => {
		if (isAnimating) {
			triggerShake();
		} else {
			shakingAnimation?.complete();
			shakingAnimation = null;
		}
	});

	// Function to trigger shake animation with anime.js v4
	function triggerShake() {
		// Prevent multiple animations
		if (shakingAnimation) {
			console.log('🙏 already animating');
			return;
		}
		// Shake animation for top part
		const top = document.getElementById('level-gift-icon-top');
		const bottom = document.getElementById('level-gift-icon-bottom');
		if (!top || !bottom) return;

		shakingAnimation = animate(top, {
			rotate: [1.5, -1.5, 1.5, -0.8, 0.8, -0.4, 0.4, -0.2, 0.2, 0],
			translateY: [-2, 0],
			loop: true,
			loopDelay: 1000,
			duration: 1000
		});
	}

	$effect(() => {
		if (animateCoin) {
			animateCoinAnimation();
		}
	});

	function animateCoinAnimation() {
		const balanceTag = document.getElementById('balance-tag-icon');
		const coinsPileIcon = document.getElementById('coins-pile-icon');
		const levelGiftTop = document.getElementById('level-gift-icon-top');
		const levelGiftBottom = document.getElementById('level-gift-icon-bottom');

		if (coinsPileIcon && balanceTag && levelGiftTop && levelGiftBottom) {
			const balanceTagRect = balanceTag.getBoundingClientRect();
			const coinPileIconRect = coinsPileIcon.getBoundingClientRect();
			const translateX = balanceTagRect.x - coinPileIconRect.x;
			const translateY = balanceTagRect.y - coinPileIconRect.y - balanceTagRect.height * 2;

			const levelGiftBottomRect = levelGiftBottom.getBoundingClientRect();
			const levelGiftTopRect = levelGiftTop.getBoundingClientRect();
			const levelGiftBottomTranslateX = levelGiftBottomRect.width - levelGiftBottomRect.width / 3;
			const levelGiftBottomTranslateY = levelGiftBottomRect.height;
			const animationDuration = 750;
			shakingAnimation?.revert();
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
				onGiveReward?.();
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
					opacity: [1, 1, 0],
					scale: [1, 0.5, 0],
					ease: 'inOut',
					duration: animationDuration
				}).then(() => {
					onCoinAnimationCompleted?.();
				});
			});
		} else {
			onCoinAnimationCompleted?.();
		}
	}
</script>

<div class="relative h-36 w-40">
	<div id="coins-pile-icon" class="absolute top-[48px] left-[48px] z-50 h-16 w-16 opacity-100">
		<CoinsPileIcon />
	</div>
	<LevelGiftTop class="absolute top-0 right-[0px] z-70 w-40" style="" id="level-gift-icon-top" />
	<LevelGiftBottom
		class="absolute bottom-[10px] left-[0px] z-60 w-40"
		style=""
		id="level-gift-icon-bottom"
	/>
</div>
