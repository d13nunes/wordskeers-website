<script lang="ts">
	import LevelGiftBottom from './LevelGiftBottom.svelte';
	import LevelGiftTop from './LevelGiftTop.svelte';
	import { JSAnimation, Timeline, animate, eases } from 'animejs';

	// Animation state

	let topElement: any;
	let bottomElement: any;

	let { isAnimating = false } = $props();
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
			// ease: eases.inOutElastic(1, 0.1)
		});
	}
</script>

<div class="relative h-36 w-40">
	<LevelGiftTop class="absolute top-0 right-[0px] z-10 w-40" style="" id="level-gift-icon-top" />
	<LevelGiftBottom
		class="absolute bottom-[10px] left-[0px] z-0 w-40"
		style=""
		id="level-gift-icon-bottom"
	/>
</div>
