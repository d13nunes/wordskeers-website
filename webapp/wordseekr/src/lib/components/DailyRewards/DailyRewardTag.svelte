<script lang="ts">
	import { dailyRewardsStore } from '$lib/rewards/daily-rewards.store';
	import { animate, JSAnimation, utils } from 'animejs';
	import DailyRewardIcon from './DailyRewardIcon.svelte';
	import { onMount } from 'svelte';
	interface Props {
		tag: string;
		onclick: () => void;
	}
	let { tag, onclick }: Props = $props();

	let badge: HTMLDivElement | null = null;
	let icon: HTMLDivElement | null = null;
	let iconAnimation: JSAnimation | null = null;
	let first = true;

	onMount(() => {
		if (icon) {
			iconAnimation = animate(icon, {
				rotate: [0, -15, +15, -15, +15, -15, 0],
				duration: 1000,
				easing: 'inOutQuad',
				loop: true,
				loopDelay: 5000,
				delay: 2000
			});
		}
		dailyRewardsStore.subscribe((state) => {
			if (!state) {
				return;
			}
			const showBadge = state.rewardsCollectedToday === 0;
			const opacity = showBadge ? 1 : 0;
			const scale = showBadge ? [0, 1] : [1, 0];
			const delay = first ? 1000 : 0;
			first = false;
			if (badge && badge.style.opacity !== opacity.toString()) {
				animate(badge, {
					opacity: opacity,
					scale: scale,
					duration: 300,
					easing: 'inOutQuad',
					delay: delay
				});
			}
			if (iconAnimation) {
				if (showBadge) {
					if (!iconAnimation.began) {
						iconAnimation.play();
					}
				} else {
					iconAnimation.revert().cancel();
				}
			}
		});
	});
</script>

<button class="card-button relative flex flex-row items-center justify-center" {onclick}>
	<div
		bind:this={badge}
		class="absolute -top-1 -right-1.5 min-h-4 min-w-4 rounded-full bg-red-500 text-white opacity-0 lg:min-h-6 lg:min-w-6"
	></div>
	<div bind:this={icon} class="h-4 w-4 lg:h-6 lg:w-6">
		<DailyRewardIcon fill="#c10007" />
	</div>
	<span class="text-black-500 text-sm font-medium lg:text-lg">{tag}</span>
</button>
