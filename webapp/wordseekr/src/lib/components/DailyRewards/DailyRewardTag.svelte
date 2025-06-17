<script lang="ts">
	import { dailyRewardsStore } from '$lib/rewards/daily-rewards.store';
	import { animate, JSAnimation, utils } from 'animejs';
	import DailyRewardIcon from './DailyRewardIcon.svelte';
	import { onMount } from 'svelte';
	import BaseTag from '../BaseTag.svelte';
	import { animateRewardsTag, expandRewardsTag } from '$lib/tag-store';
	interface Props {
		onclick: () => void;
	}
	let { onclick }: Props = $props();

	let isAnimating = $state(false);
	let isExpanded = $state(false);

	onMount(() => {
		expandRewardsTag.subscribe((value) => {
			if (value !== isExpanded) {
				isExpanded = value;
			}
		});
		animateRewardsTag.subscribe((value) => {
			isAnimating = value;
		});
	});
</script>

<BaseTag {onclick} title="Rewards" {isExpanded} {isAnimating}>
	<DailyRewardIcon fill="#c10007" />
</BaseTag>
