<script lang="ts">
	import StoreSmallCard from '$lib/components/StoreSmallCard.svelte';
	import CoinsPileIcon from '$lib/components/Icons/CoinsPileIcon.svelte';
	import ArrowIcon from './Icons/ArrowIcon.svelte';
	import RemoveAdsIcon from './Icons/RemoveAdsIcon.svelte';
	import { isDarkMode } from '$lib/utils/darkmode';
	interface Props {
		title: string;
		detail: string;
		price?: string;
		callout?: string;
		isCalloutRed?: boolean;
		isIndicatorActive?: boolean;
		isCalloutAnimating?: boolean;
		isRemoveAds?: boolean;
		iconId: string;
		onclick: () => void;
	}

	let {
		iconId,
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
		<div class="z-100 h-8 w-8">
			{#if isRemoveAds}
				<RemoveAdsIcon />
			{:else}
				<CoinsPileIcon id={iconId} />
			{/if}
		</div>
	{/snippet}
	{#snippet action()}
		{#if isIndicatorActive}
			<div class="h-4 w-4">
				<ArrowIcon color={$isDarkMode ? '#d1d5dc' : '#2563eb'} />
			</div>
		{:else if price}
			<div class="min-w-[80px] rounded-md bg-blue-700 px-2 py-1 text-white dark:bg-blue-600 dark:text-gray-100">{price}</div>
		{:else}
			<div class="min-w-[80px] rounded-md bg-emerald-700 px-3 py-1 text-white dark:bg-emerald-600 dark:text-gray-00">Watch Ad</div>
		{/if}
	{/snippet}
</StoreSmallCard>
