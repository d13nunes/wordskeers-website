import type { Direction } from './Direction';
import type { Position } from './Position';
import { directionMap } from './Direction';
import { randomFromStringArray } from '$lib/utils/random-utils';

export interface Word {
	word: string;
	position: Position;
	direction: Direction;

	color?: string;
	textColor?: string;
	isDiscovered: boolean;
}

export interface Game {
	grid: string[][];
	words: Word[];
	title: string;
	config: GameConfiguration;
}

export interface WordLocation {
	word: string;
	initialPosition: Position;
	direction: Direction;
}

export interface GameConfiguration {
	id: string;
	wordsLocation: WordLocation[];
	size: number;
	title: string;
}

export function createGridFor(wordsLocation: WordLocation[], size: number): string[][] {
	const filler = '';
	const grid: string[][] = Array(size)
		.fill(null)
		.map(() => Array(size).fill(filler));
	console.log('❤️Generated grid: ', grid);

	for (const wordLocation of wordsLocation) {
		const word = wordLocation.word;
		const initialPosition = wordLocation.initialPosition;
		const dx = wordLocation.direction.dx;
		const dy = wordLocation.direction.dy;
		for (let index = 0; index < word.length; index++) {
			const row = initialPosition.row + index * dy;
			const column = initialPosition.col + index * dx;
			const letter = word[index];
			grid[row][column] = letter.toUpperCase();
		}
	}
	console.log('❤️Grid with words: ', grid);
	const randomLetters: string[] = [
		'A',
		'B',
		'C',
		'D',
		'E',
		'F',
		'G',
		'H',
		'I',
		'J',
		'K',
		'L',
		'M',
		'N',
		'O',
		'P',
		'Q',
		'R',
		'S',
		'T',
		'U',
		'V',
		'W',
		'X',
		'Y',
		'Z'
	];
	for (let row = 0; row < grid.length; row++) {
		for (let column = 0; column < grid[row].length; column++) {
			if (grid[row][column] === filler) {
				grid[row][column] = randomFromStringArray(randomLetters);
			}
		}
	}
	console.log('❤️Grid final: ', grid);
	return grid;
}

export function getWordPositions(word: Word): Position[] {
	const positions: Position[] = [];
	const wordLength = word?.word?.length ?? 0;
	for (let i = 0; i < wordLength; i++) {
		const position = {
			row: word.position.row + i * word.direction.dy,
			col: word.position.col + i * word.direction.dx
		};
		positions.push(position);
	}
	return positions;
}

export function createGameForConfiguration(config: GameConfiguration): Game {
	return {
		grid: createGridFor(config.wordsLocation, config.size),
		title: config.title,
		words: config.wordsLocation.map((w) => ({
			word: w.word,
			position: w.initialPosition,
			direction: w.direction,
			isDiscovered: false
		})),
		config: config
	};
}

export interface Cell {
	letter: string;
	row: number;
	col: number;
	isDiscovered: boolean;
	isDiscoveredColor?: string;
	isSelected: boolean;
	isHinted: boolean;
}

export function mockGameConfiguration(): GameConfiguration {
	return {
		id: 'mock',
		wordsLocation: [
			{
				word: 'STRAIT',
				initialPosition: { row: 1, col: 4 },
				direction: directionMap.DOWN_RIGHT
			},
			{
				word: 'ATLANTIC',
				initialPosition: { row: 9, col: 1 },
				direction: directionMap.UP_RIGHT
			},
			{
				word: 'SEABED',
				initialPosition: { row: 2, col: 3 },
				direction: directionMap.DOWN_RIGHT
			},
			{
				word: 'LAGOON',
				initialPosition: { row: 0, col: 2 },
				direction: directionMap.RIGHT
			},
			{
				word: 'CARIBBEAN',
				initialPosition: { row: 1, col: 0 },
				direction: directionMap.DOWN
			},
			{
				word: 'ARCTIC',
				initialPosition: { row: 7, col: 2 },
				direction: directionMap.UP
			},
			{
				word: 'BLACK',
				initialPosition: { row: 8, col: 9 },
				direction: directionMap.LEFT
			},
			{
				word: 'SOUTHERN',
				initialPosition: { row: 9, col: 9 },
				direction: directionMap.LEFT
			},
			{
				word: 'ADRIATIC',
				initialPosition: { row: 8, col: 1 },
				direction: directionMap.UP
			},
			{
				word: 'CURRENT',
				initialPosition: { row: 0, col: 9 },
				direction: directionMap.DOWN
			},
			{
				word: 'CHANNEL',
				initialPosition: { row: 8, col: 4 },
				direction: directionMap.UP
			},
			{
				word: 'PACIFIC',
				initialPosition: { row: 0, col: 8 },
				direction: directionMap.DOWN
			},
			{
				word: 'WAVES',
				initialPosition: { row: 6, col: 3 },
				direction: directionMap.UP
			},
			{
				word: 'GULF',
				initialPosition: { row: 7, col: 5 },
				direction: directionMap.UP_RIGHT
			},
			{
				word: 'RED',
				initialPosition: { row: 1, col: 5 },
				direction: directionMap.RIGHT
			},
			{
				word: 'TIDE',
				initialPosition: { row: 7, col: 6 },
				direction: directionMap.RIGHT
			}
		],
		size: 10,
		title: 'Ocean Words'
	};
}
