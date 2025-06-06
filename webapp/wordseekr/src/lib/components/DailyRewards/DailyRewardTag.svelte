<script lang="ts">
	import { dailyRewardsStore } from '$lib/rewards/daily-rewards.store';
	import { animate, JSAnimation, utils } from 'animejs';
	import DailyRewardIcon from './DailyRewardIcon.svelte';
	import { onMount } from 'svelte';
	import BaseTag from '../BaseTag.svelte';
	import { rotateIconAnimation } from '$lib/utils/animation-utils';
	interface Props {
		tag: string;
		onclick: () => void;
	}
	let { tag, onclick }: Props = $props();

	let icon: HTMLDivElement | null = null;
	let iconAnimation: JSAnimation | null = null;

	onMount(() => {
		if (icon) {
			iconAnimation = rotateIconAnimation(icon, true, 1000, 1000);
		}
		dailyRewardsStore.subscribe((state) => {
			if (!state) {
				return;
			}
			const showBadge = state.rewardsCollectedToday === 0;

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

<BaseTag {onclick}>
	<div bind:this={icon} class="h-4 w-4 lg:h-6 lg:w-6">
		<DailyRewardIcon fill="#c10007" />
	</div>
	<span class="text-black-500 text-sm font-medium lg:text-lg">{tag}</span>
</BaseTag>
