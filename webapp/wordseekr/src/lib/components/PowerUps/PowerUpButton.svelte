<script lang="ts">
	import CoinsPileIcon from '$lib/components/Icons/CoinsPileIcon.svelte';

	export let price: string = '100';
	export let priceColor: string = 'text-orange-500';
	export let color: string = 'bg-orange-500';
	export let title: string = 'Rotate';
	export let titleColor: string = 'text-orange-500';

	export let onClick: () => void;
</script>

<button class=" select-none" on:click={onClick}>
	<div
		class="flex h-28 w-28 flex-col items-center justify-center rounded-lg border-gray-200 py-4 shadow-sm {color}"
	>
		<div class="h-8 w-8">
			<slot />
		</div>
		<div class="flex flex-col items-center justify-center pt-3">
			<div class="flex flex-row items-center justify-center gap-0.5">
				<div class="h-3 w-3">
					<CoinsPileIcon />
				</div>
				<span class="text-xs font-normal {priceColor}">{price}</span>
			</div>
			<span class="text-sm font-medium {titleColor}">{title}</span>
		</div>
	</div>
</button>
