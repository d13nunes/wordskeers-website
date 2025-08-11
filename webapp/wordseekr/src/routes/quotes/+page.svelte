<script lang="ts">
	import QuoteListItem from './QuoteListItem.svelte';
	import { VList } from 'virtua/svelte';

	import { onMount } from 'svelte';
	import { databaseService } from '$lib/database/database.service';
	import { syncQuotes } from '$lib/firestore/firestore';
	import type { Quote } from '$lib/database/types';
	import DailyQuoteIcon from '$lib/daily-challenge/DailyQuoteIcon.svelte';
	import Modal from '$lib/components/Modal.svelte';
	import { isToday } from 'date-fns';
	import { gotoDailyChallenge } from '../utils/naviation';
	import { unlockQuote } from '$lib/daily-challenge/quote-fetcher';
	import { walletStore } from '$lib/economy/walletStore';
	import SegmentedSelector from '$lib/components/SegmentedSelector.svelte';
	import { analytics } from '$lib/analytics/analytics';
	import { isDarkMode } from '$lib/utils/darkmode';
	const { onClose, onNotEnoughCoinsToUnlock } = $props();
	const unlockQuotePrice = 1000;

	let quotes = $state<Quote[]>([]);
	let quoteList = $state<VList<Quote>>();
	let selectedIndex = $state(0);
	let onlyLocked = $derived(selectedIndex === 1);
	let onlyPlayable = $derived(selectedIndex === 2);
	let filteredQuotes = $derived(
		quotes
			.filter(
				(quote) =>
					(onlyLocked &&
						quote.played_at === null &&
						!quote.unlocked &&
						!isToday(new Date(quote.playable_at))) ||
					(onlyPlayable &&
						quote.played_at === null &&
						(quote.unlocked || isToday(new Date(quote.playable_at)))) ||
					(!onlyLocked && !onlyPlayable)
			)
			.sort((a, b) => {
				return new Date(b.playable_at).getTime() - new Date(a.playable_at).getTime();
			})
	);

	let isLoading = $state(true);
	let hasEnoughCoins = $state(false);

	function playQuote(quote: Quote) {
		onClose();
		gotoDailyChallenge(quote.grid_id, quote.id);
	}

	onMount(async () => {
		isLoading = true;
		walletStore.coins((balance) => {
			hasEnoughCoins = balance >= unlockQuotePrice;
		});
		await syncQuotes();
		quotes = await databaseService.getAllQuotesTillToday();
		isLoading = false;
		console.log('!!! quotes');
		quotes.forEach((quote) => {
			console.log(quote.author);
			console.log(quote.played_at);
		});
	});

	async function unlock(quote: Quote) {
		if (hasEnoughCoins) {
			if (await walletStore.tryAndBuy(unlockQuotePrice)) {
				analytics.unlockedQuote(quote.id);
				await unlockQuote(quote.id);
				playQuote(quote);
			}
		} else {
			onNotEnoughCoinsToUnlock();
		}
	}

	function onChange(index: number) {
		selectedIndex = index;
		quoteList?.scrollToIndex(0);
	}
</script>

<Modal {onClose} backgroundOpacity={50} onDismiss={onClose}>
	<div class="flex h-[65svh] w-2xs flex-col items-center justify-start gap-4">
		<div class="flex flex-row items-center justify-center gap-2">
			<div class="flex flex-row items-center justify-center gap-2">
				<div class="w-12">
					<DailyQuoteIcon color={$isDarkMode ? '#f3f4f6' : '#000000'} />
				</div>
				<span class="text-4xl font-medium text-black dark:text-gray-100">Quotes</span>
			</div>
		</div>

		<div class="flex flex-row items-center justify-center px-3 text-center">
			Past quotes are waiting for you! Unlock any you missed
		</div>

		{#if isLoading}
			<p>Loading...</p>
		{:else}
			<div class="flex flex-row items-center justify-center gap-2">
				<div class="w-full">
					<SegmentedSelector segments={['All', 'Locked', 'Playable']} {selectedIndex} {onChange} />
				</div>
			</div>
			<div class="mb-4 flex max-h-[48svh] min-w-full flex-col items-center justify-center">
				{#if filteredQuotes.length > 0}
					<VList
						bind:this={quoteList}
						data={filteredQuotes}
						style="height: 48svh; max-height: 48svh; min-height: 200px;"
					>
						{#snippet children(quote)}
							<div class="mb-4">
								<QuoteListItem
									{quote}
									unlockPrice={unlockQuotePrice.toString()}
									onPlayClick={() => playQuote(quote)}
									onUnlockClick={() => unlock(quote)}
									showUnlockButton={!quote.unlocked &&
										quote.played_at === null &&
										!isToday(new Date(quote.playable_at))}
									showPlayButton={(quote.unlocked && quote.played_at === null) ||
										(isToday(new Date(quote.playable_at)) && quote.played_at === null)}
									showBlured={quote.played_at === null}
								/>
							</div>
						{/snippet}
					</VList>
				{:else if onlyLocked}
					<p>No locked quotes found</p>
				{:else if onlyPlayable}
					<p>No playable quotes found</p>
				{:else}
					<p>No quotes found</p>
				{/if}
			</div>
		{/if}
	</div>
</Modal>
