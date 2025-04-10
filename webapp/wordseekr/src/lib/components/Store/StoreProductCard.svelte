<script lang="ts">
	import StoreSmallCard from '$lib/components/StoreSmallCard.svelte';
	import CoinsPileIcon from '$lib/components/Icons/CoinsPileIcon.svelte';
	import ArrowIcon from './Icons/ArrowIcon.svelte';
	import RemoveAdsIcon from './Icons/RemoveAdsIcon.svelte';
	interface Props {
		title: string;
		detail: string;
		price?: string;
		callout?: string;
		isCalloutRed?: boolean;
		isIndicatorActive?: boolean;
		isCalloutAnimating?: boolean;
		isRemoveAds?: boolean;
		onclick: () => void;
	}

	let {
		title,
		detail,
		price = undefined,
		callout = undefined,
		isCalloutRed = false,
		isIndicatorActive = false,
		isCalloutAnimating = false,
		isRemoveAds = false,
		onclick
	}: Props = $props();

	const animation = isCalloutAnimating ? 'pulse-indicator' : '';
</script>

{#if callout}
	<div class="relative -mt-2">
		<div
			class="absolute top-1 right-4 flex h-5 items-center rounded-sm {animation} {isCalloutRed
				? 'bg-red-700'
				: 'bg-emerald-700'} px-2"
		>
			<span class="text-xs text-white">{callout}</span>
		</div>
	</div>
{/if}
<StoreSmallCard {title} {detail} {onclick}>
	{#snippet icon()}
		<div class="h-8 w-8">
			{#if isRemoveAds}
				<RemoveAdsIcon />
			{:else}
				<CoinsPileIcon />
			{/if}
		</div>
	{/snippet}
	{#snippet action()}
		{#if isIndicatorActive}
			<div class="h-4 w-4">
				<ArrowIcon color="#2563eb" />
			</div>
		{:else if price}
			<div class="min-w-[80px] rounded-md bg-blue-700 px-2 py-1 text-white">{price}</div>
		{:else}
			<div class="min-w-[80px] rounded-md bg-emerald-700 px-3 py-1 text-white">Watch Ad</div>
		{/if}
	{/snippet}
</StoreSmallCard>
