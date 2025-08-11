<script lang="ts">
	import { rotateIconAnimation } from '$lib/utils/animation-utils';
	import { onMount, type Snippet } from 'svelte';
	import { slide } from 'svelte/transition';
	import { expoOut } from 'svelte/easing';

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
	class="card-button z-50 flex h-8 flex-row items-center justify-center bg-red-500 lg:h-9"
	{onclick}
	{disabled}
	{id}
>
	<div bind:this={icon} class="pointer-events-none h-4 w-4 overflow-visible lg:h-5 lg:w-5">
		{@render children()}
	</div>

	{#if isExpanded}
		<div
			in:slide={{ duration: 300, axis: 'x', easing: expoOut }}
			out:slide={{ duration: 300, axis: 'x', easing: expoOut }}
			class="text-black-500 text-sm font-medium whitespace-nowrap lg:text-base dark:text-gray-100"
		>
			{title}
		</div>
	{/if}
</button>
