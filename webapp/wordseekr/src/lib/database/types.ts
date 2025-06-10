export interface WordSearchGrid {
	id: number;
	name: string;
	rows: number;
	columns: number;
	words_count: number;
	directions: string;
	grid_hash: string;
	played_at: string | null;
	is_challenge: boolean;
	created_at: string;
}

export interface WordPlacement {
	id: number;
	grid_id: number;
	word: string;
	row: number;
	col: number;
	direction: string;
}

export interface Quote {
	id: number;
	grid_id: number;
	author: string;
	quote: QuoteSegment[];
	playable_at: string;
	played_at: string | null;
}

export interface QuoteSegment {
	text: string;
	isHidden: boolean;
}

export interface DailyChallenge {
	id: string;
	title: string;
	rows: number;
	columns: number;
	date: Date;
	quotes: QuoteSegment[];
	words: WordPlacement[];
}
export interface Score {
	id: number;
	grid_id: number;
	played_at: string;
	time_taken: number;
}
