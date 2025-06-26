<script lang="ts">
	import { cubicOut, cubicIn, cubicInOut } from 'svelte/easing';
	import { fade, scale } from 'svelte/transition';
	import { onMount, type Snippet } from 'svelte';
	import CloseX from './CloseX.svelte';

	interface Props {
		children: Snippet;
		backgroundOpacity?: number;
		canDismissOnBackground?: boolean;
		onDismiss?: () => void;
		onClose?: () => void;
	}

	let { children, backgroundOpacity, onDismiss, onClose }: Props = $props();
	let canDismissOnBackground = false;

	onMount(() => {
		const timeout = setTimeout(() => {
			canDismissOnBackground = true;
		}, 500);
		return () => {
			clearTimeout(timeout);
		};
	});

	const handleBackgroundClick = () => {
		if (!canDismissOnBackground) {
			return;
		}
		if (onDismiss) {
			onDismiss();
		}
	};
</script>

<div
	in:fade={{ duration: 300, easing: cubicOut }}
	out:fade={{ delay: 100, duration: 300, easing: cubicIn }}
	onclick={handleBackgroundClick}
	onkeydown={handleBackgroundClick}
	role="button"
	tabindex="-1"
	class="fixed inset-0 z-100 flex items-center justify-center {backgroundOpacity
		? `bg-black/${backgroundOpacity}`
		: 'bg-black'}"
>
	<div
		in:scale={{ delay: 100, duration: 300, easing: cubicInOut }}
		out:scale={{ duration: 300, easing: cubicInOut }}
		class="relative mx-4 flex flex-col items-center gap-4 rounded-lg bg-white p-8 shadow-lg"
		style="margin-top: var(--safe-area-inset-top)"
		onclick={(e) => e.stopPropagation()}
		ontouchstart={(e) => e.stopPropagation()}
		ontouchmove={(e) => e.stopPropagation()}
		ontouchend={(e) => e.stopPropagation()}
		onpointerdown={(e) => e.stopPropagation()}
		onpointerup={(e) => e.stopPropagation()}
		onpointermove={(e) => e.stopPropagation()}
		role="none"
		tabindex="-1"
	>
		{#if onClose}
			<button class="absolute top-4 right-4 h-6 w-6" onclick={() => onClose()}>
				<CloseX />
			</button>
		{/if}
		{@render children()}
	</div>
</div>
