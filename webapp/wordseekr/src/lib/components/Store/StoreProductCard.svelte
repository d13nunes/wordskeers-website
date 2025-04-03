<script lang="ts">
	import StoreSmallCard from '$lib/components/StoreSmallCard.svelte';
	import CoinsPileIcon from '$lib/components/Icons/CoinsPileIcon.svelte';
	import ArrowIcon from './Icons/ArrowIcon.svelte';
	export let title: string;
	export let detail: string;
	export let price: string | undefined = undefined;
	export let callout: string | undefined = undefined;
	export let isCalloutRed: boolean = false;
	export let isIndicatorActive: boolean = false;
	export let isCalloutAnimating: boolean = false;

	const animation = isCalloutAnimating ? 'pulse-indicator' : '';
	export let onClick: () => void = () => {};
</script>

{#if callout}
	<div class="relative">
		<div
			class="absolute top-1 right-4 flex h-5 items-center rounded-sm {animation} {isCalloutRed
				? 'bg-red-700'
				: 'bg-emerald-700'} px-2"
		>
			<span class="text-xs text-white">{callout}</span>
		</div>
	</div>
{/if}
<StoreSmallCard {title} {detail} {onClick}>
	<div slot="icon">
		<div class="h-8 w-8">
			<CoinsPileIcon />
		</div>
	</div>
	<div slot="action">
		{#if isIndicatorActive}
			<div class="h-4 w-4">
				<ArrowIcon color="#2563eb" />
			</div>
		{:else if price}
			<div class="min-w-[80px] rounded-md bg-blue-700 px-2 py-1 text-white">{price}</div>
		{:else}
			<div class="min-w-[80px] rounded-md bg-emerald-700 px-3 py-1 text-white">Watch Ad</div>
		{/if}
	</div>
</StoreSmallCard>
