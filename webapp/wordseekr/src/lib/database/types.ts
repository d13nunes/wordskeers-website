export interface WordSearchGrid {
	id: number;
	name: string;
	size: number;
	words_count: number;
	directions: string;
	grid_hash: string;
	played_at: string | null;
	time_taken: number | null;
}

export interface WordPlacement {
	id: number;
	grid_id: number;
	word: string;
	row: number;
	col: number;
	direction: string;
}

export interface Category {
	id: number;
	name: string;
	theme_id: number | null;
	created_at: string;
}

export interface Theme {
	id: number;
	name: string;
	description: string | null;
	created_at: string;
}

export interface Grid {
	id: number;
	name: string;
	rows: number;
	columns: number;
	directions: string;
	filler_letters: string | null;
	placed_words: string;
	grid_data: string;
	created_at: string;
}

export interface Listing {
	id: number;
	name: string;
	created_at: string;
}

export interface ListingWord {
	id: number;
	listing_id: number;
	word: string;
	created_at: string;
}

export interface InsertionRule {
	id: number;
	name: string;
	description: string | null;
	is_active: boolean;
}

export interface GridInsertionRule {
	grid_id: number;
	rule_id: number;
	rule_value: string | null;
}

export interface Level {
	id: number;
	grid_id: number;
}

export interface ThemeCategory {
	theme_id: number;
	category_id: number;
}
