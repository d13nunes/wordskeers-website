export interface Game {
	grid: string[][];
	words: string[];
}

export function createMockGame(): Game {
	return {
		grid: [
			['A', 'B', 'C', 'D', 'E', 'F'],
			['G', 'H', 'I', 'J', 'K', 'L'],
			['M', 'N', 'O', 'P', 'Q', 'R'],
			['S', 'T', 'U', 'V', 'W', 'X'],
			['Y', 'Z', 'A', 'B', 'C', 'D'],
			['E', 'F', 'G', 'H', 'I', 'J']
		],
		words: ['ABC', 'DEF', 'GHI', 'AHO']
	};
}
