<script lang="ts">
	import { dailyRewardsStore } from '$lib/rewards/daily-rewards.store';
	import { rotateIconAnimation } from '$lib/utils/animation-utils';
	import { animate } from 'animejs';
	import { onMount, type Snippet } from 'svelte';
	import { fade, fly, slide } from 'svelte/transition';
	import {
		elasticOut,
		elasticIn,
		linear,
		expoOut,
		expoIn,
		bounceOut,
		bounceIn
	} from 'svelte/easing';

	interface Props {
		onclick: () => void;
		title?: string;
		children: Snippet;
		isExpanded?: boolean;
		isAnimating?: boolean;
		disabled?: boolean;
		id?: string;
	}
	let { onclick, children, disabled, id, title, isExpanded, isAnimating }: Props = $props();

	let icon: HTMLDivElement | undefined = undefined;
	let iconAnimation: any = undefined;

	onMount(() => {
		if (icon) {
			iconAnimation = rotateIconAnimation(icon, true, 1000, 1000);
		}
	});

	$effect(() => {
		if (isAnimating) {
			iconAnimation?.play();
		} else {
			iconAnimation?.revert().cancel();
		}
	});
</script>

<button
	class="card-button flex h-8 flex-row items-center justify-center lg:h-10"
	{onclick}
	{disabled}
	{id}
>
	<div bind:this={icon} class="h-4 w-4">
		{@render children()}
	</div>

	{#if isExpanded}
		<div
			in:slide={{ duration: 300, axis: 'x', easing: expoOut }}
			out:slide={{ duration: 300, axis: 'x', easing: expoOut }}
			class="text-black-500 text-sm font-medium whitespace-nowrap lg:text-base"
		>
			{title}
		</div>
	{/if}
</button>
