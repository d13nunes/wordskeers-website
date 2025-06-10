import { databaseService } from '$lib/database/database.service';
import type { Quote } from '$lib/database/types';
import { writable, type Readable } from 'svelte/store';

const isTodaysQuoteAvailable_ = writable(false);

export async function getAllQuotes(): Promise<Quote[]> {
	const quotes = await databaseService.getAllQuotes();
	return quotes;
}

export async function getTodaysQuote(): Promise<Quote | null> {
	const quote = await databaseService.getQuoteForDate(new Date());
	return quote;
}

export async function isTodaysQuoteAvailable(): Promise<boolean> {
	const quote = await getTodaysQuote();
	const isAvailable = !!(quote && quote.played_at === null);
	isTodaysQuoteAvailable_.set(isAvailable);
	return isAvailable;
}

export async function markQuoteAsPlayed(quoteId: number): Promise<void> {
	await databaseService.markQuoteAsPlayed(quoteId, new Date());
	isTodaysQuoteAvailable_.set(false);
}

export async function getIsTodaysQuoteAvailableStore(): Promise<Readable<boolean>> {
	const isAvailable = await isTodaysQuoteAvailable();
	isTodaysQuoteAvailable_.set(isAvailable);
	return isTodaysQuoteAvailable_;
}
