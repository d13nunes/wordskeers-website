import type { WordLocation } from '$lib/components/Game/game';

export interface QuoteSegment {
	text: string;
	isHidden: boolean;
	isDiscovered?: boolean;
}

export interface DailyChallenge {
	id: string;
	title: string;
	rows: number;
	columns: number;
	date: Date;
	quotes: QuoteSegment[];
	words: WordLocation[];
}
