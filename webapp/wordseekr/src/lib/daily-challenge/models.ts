import { directionMap } from '$lib/components/Game/Direction';
import type { WordLocation } from '$lib/components/Game/game';

export interface QuoteSegment {
	text: string;
	isHidden: boolean;
	isDiscovered?: boolean;
}

export interface DailyChallenge {
	id: string;
	title: string;
	size: number;
	date: Date;
	quotes: QuoteSegment[];
	words: WordLocation[];
}

const mockDailyChallenge: DailyChallenge = {
	id: '1',
	title: 'Daily Challenge',
	date: new Date(),
	size: 8,
	words: [
		{
			word: 'CANNOT',
			initialPosition: { row: 0, col: 0 },
			direction: directionMap.RIGHT
		},
		{
			word: 'MUST',
			initialPosition: { row: 4, col: 0 },
			direction: directionMap.DOWN
		},
		{
			word: 'ERASE',
			initialPosition: { row: 1, col: 0 },
			direction: directionMap.DOWN_RIGHT
		},
		{
			word: 'PAST',
			initialPosition: { row: 6, col: 4 },
			direction: directionMap.UP_RIGHT
		},
		{
			word: 'PRESENT',
			initialPosition: { row: 2, col: 0 },
			direction: directionMap.RIGHT
		}
	],
	quotes: [
		{ text: 'One', isHidden: false },
		{
			text: 'cannot',
			isHidden: true
		},
		{ text: 'and', isHidden: false },
		{
			text: 'must',
			isHidden: true
		},
		{ text: 'not try to', isHidden: false },
		{
			text: 'erase',
			isHidden: true
		},
		{ text: 'the', isHidden: false },
		{
			text: 'past',
			isHidden: true
		},
		{ text: 'merely because it does not fit the', isHidden: false },
		{
			text: 'present',
			isHidden: true
		}
	]
};

export { mockDailyChallenge };
