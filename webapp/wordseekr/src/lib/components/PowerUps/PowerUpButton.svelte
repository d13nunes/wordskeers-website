<script lang="ts">
	import CoinsPileIcon from '$lib/components/Icons/CoinsPileIcon.svelte';
	import { animate } from 'animejs';
	import { onMount, type Snippet } from 'svelte';

	interface Props {
		price: string;
		priceColor: string;
		color: string;
		title: string;
		titleColor: string;
		onclick: () => void;
		icon: Snippet;
		disabled?: boolean;
	}

	let {
		price = '100',
		priceColor = 'text-orange-500',
		color = 'bg-orange-500',
		title = 'Rotate',
		titleColor = 'text-orange-500',
		onclick,
		icon,
		disabled = false
	}: Props = $props();

	let button: HTMLDivElement;
	onMount(() => {
		const scaleDown = () => {
			if (disabled) return;
			animate(button, {
				scale: [1, 0.95],
				duration: 100,
				ease: 'easeOutQuad'
			});
		};

		const scaleUp = () => {
			if (disabled) return;
			animate(button, {
				scale: [0.95, 1],
				duration: 100,
				ease: 'easeOutQuad'
			});
		};

		button.addEventListener('mousedown', scaleDown);
		button.addEventListener('mouseup', scaleUp);
		button.addEventListener('mouseleave', scaleUp);

		button.addEventListener('touchstart', scaleDown, { passive: true });
		button.addEventListener('touchend', scaleUp);
		button.addEventListener('touchcancel', scaleUp);
	});
</script>

<button class="select-none" {onclick} {disabled}>
	<div
		bind:this={button}
		class="relative flex h-20 w-20 flex-col items-center justify-start rounded-lg border-gray-200 py-3 shadow-sm {color} {disabled
			? 'opacity-70'
			: ''}"
	>
		<div class="h-6 w-6">
			{@render icon()}
		</div>
		<div class="absolute bottom-2 flex flex-col items-center justify-center">
			<div class="flex flex-row items-center justify-center gap-0.5">
				<div class="h-2 w-2">
					<CoinsPileIcon />
				</div>
				<span class="font-regular text-xs {priceColor}">{price}</span>
			</div>
			<span class="font-regular text-xs {titleColor}">{title}1</span>
		</div>
	</div>
</button>
