<script lang="ts">
	import CoinsPileIcon from '$lib/components/Icons/CoinsPileIcon.svelte';
	import type { Quote } from '$lib/database/types';
	import { normalizeQuoteText } from '$lib/utils/utils';
	interface Props {
		quote: Quote;
		showUnlockButton: boolean;
		showPlayButton: boolean;
		showBlured: boolean;
		unlockPrice: string;
		onPlayClick: () => void;
		onUnlockClick: () => void;
	}

	const {
		quote,
		showUnlockButton,
		showPlayButton,
		showBlured,
		onPlayClick,
		onUnlockClick,
		unlockPrice
	}: Props = $props();

	let height = $state(0);
	let normalizedQuote = $derived(normalizeQuoteText(quote.quote));
</script>

<div
	bind:clientHeight={height}
	class=" flex flex-col items-start rounded-md bg-background-secondary pt-1 dark:bg-gray-800 dark:text-gray-100"
>
	<div class="flex flex-col items-start gap-0">
		<span class="text-sm font-light text-gray-700 italic dark:text-gray-300">{quote.playable_at}</span>
		<span class="text-center text-lg font-medium text-gray-700 dark:text-gray-300">
			<b>{quote.author}</b>
		</span>
	</div>

	<div class="relative h-full w-full">
		<div class="pb-1 text-sm text-gray-700 dark:text-gray-300 {showBlured ? 'blur-xs' : ''}">
			{#if normalizedQuote}
				{#each normalizedQuote as quoteSegment}
					{#if quoteSegment.isHidden}
						<span class="font-semibold">{quoteSegment.text}</span>
					{:else}
						<span class="font-light">{quoteSegment.text}</span>
					{/if}
					<span class=""> </span>
				{/each}
			{/if}
		</div>
		<div class="left absolute bottom-0 flex w-full flex-row items-start justify-center">
			{#if showUnlockButton}
				<button
					class=" button-active h-12 w-46 rounded-md bg-blue-800 px-4 text-xl font-bold text-white dark:bg-blue-600 dark:hover:bg-blue-700 dark:text-gray-100"
					onclick={onUnlockClick}
				>
					<div class="flex flex-row items-center justify-center gap-1">
						<span class="font-regular text-lg">Play {unlockPrice}</span>
						<div class="h-5 w-5">
							<CoinsPileIcon />
						</div>
					</div>
				</button>
			{:else if showPlayButton}
				<button
					class="button-active h-12 w-46 rounded-md bg-red-800 px-4 py-2 text-xl font-bold text-white dark:bg-red-600 dark:hover:bg-red-700 dark:text-gray-100"
					onclick={onPlayClick}
				>
					Play
				</button>
			{:else}{/if}
		</div>
	</div>
</div>
