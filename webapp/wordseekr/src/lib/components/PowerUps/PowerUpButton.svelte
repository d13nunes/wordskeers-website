<script lang="ts">
	import CoinsPileIcon from '$lib/components/Icons/CoinsPileIcon.svelte';
	import type { Snippet } from 'svelte';

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
</script>

<button class="select-none" {onclick} {disabled}>
	<div
		class="relative flex h-20 w-20 flex-col items-center justify-start rounded-lg border-gray-200 py-3 shadow-sm {color} button-active {disabled
			? 'cursor-not-allowed opacity-50'
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
			<span class="font-regular text-xs {titleColor}">{title}</span>
		</div>
	</div>
</button>
