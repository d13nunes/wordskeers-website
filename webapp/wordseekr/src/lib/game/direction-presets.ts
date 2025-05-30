export enum DirectionSymbol {
	HORIZONTAL = '→',
	VERTICAL = '↓',
	DIAGONAL_DOWN_RIGHT = '↘',
	DIAGONAL_DOWN_LEFT = '↙',
	DIAGONAL_UP_RIGHT = '↗',
	DIAGONAL_UP_LEFT = '↖',
	HORIZONTAL_REVERSE = '←',
	VERTICAL_REVERSE = '↑'
}

export const DirectionPresets = {
	veryEasy: [
		DirectionSymbol.HORIZONTAL,
		DirectionSymbol.VERTICAL,
		DirectionSymbol.DIAGONAL_DOWN_RIGHT,
		DirectionSymbol.DIAGONAL_UP_LEFT
	],
	easy: [
		DirectionSymbol.HORIZONTAL,
		DirectionSymbol.VERTICAL,
		DirectionSymbol.DIAGONAL_DOWN_RIGHT,
		DirectionSymbol.DIAGONAL_UP_LEFT
	],
	medium: [
		DirectionSymbol.HORIZONTAL,
		DirectionSymbol.HORIZONTAL_REVERSE,
		DirectionSymbol.VERTICAL,
		DirectionSymbol.VERTICAL_REVERSE,
		DirectionSymbol.DIAGONAL_DOWN_RIGHT,
		DirectionSymbol.DIAGONAL_UP_LEFT
	],
	hard: Object.values(DirectionSymbol),
	veryHard: Object.values(DirectionSymbol)
};
