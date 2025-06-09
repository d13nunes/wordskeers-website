<script lang="ts">
	import { cubicOut, cubicIn, cubicInOut } from 'svelte/easing';
	import { fade, scale } from 'svelte/transition';
	import type { Snippet } from 'svelte';
	import CloseX from './CloseX.svelte';

	interface Props {
		children: Snippet;
		backgroundOpacity?: number;
		onClose?: () => void;
	}
	let { children, onClose, backgroundOpacity }: Props = $props();
</script>

<div
	in:fade={{ duration: 300, easing: cubicOut }}
	out:fade={{ delay: 100, duration: 300, easing: cubicIn }}
	class="fixed inset-0 z-100 flex items-center justify-center {backgroundOpacity
		? `bg-black/${backgroundOpacity}`
		: 'bg-black'}"
>
	<div
		in:scale={{ delay: 100, duration: 300, easing: cubicInOut }}
		out:scale={{ duration: 300, easing: cubicInOut }}
		class="relative mx-4 flex flex-col items-center gap-4 rounded-lg bg-white p-8 shadow-lg"
	>
		{#if onClose}
			<button class="absolute top-4 right-4 h-6 w-6" onclick={() => onClose()}>
				<CloseX />
			</button>
		{/if}
		{@render children()}
	</div>
</div>
