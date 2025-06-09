import { databaseService } from '../database/database.service';
import { Difficulty } from './difficulty';
import { DifficultyConfigMap } from './difficulty-config-map';
import type { GameConfiguration, WordLocation } from '../components/Game/game';
import { convertDatabaseDirection } from '../components/Game/Direction';
import type { WordPlacement } from '$lib/database/types';
import type { DailyChallenge } from '$lib/daily-challenge/models';

export async function getRandomGridForDifficulty(
	difficulty: Difficulty
): Promise<GameConfiguration> {
	// Get the configuration for the selected difficulty
	const config = DifficultyConfigMap.config(difficulty);

	// Get all grids from the database
	const grids = await databaseService.getWordSearchGrids();

	// Filter grids that match the difficulty criteria
	const matchingGrids = grids.filter(
		(grid) =>
			grid.rows === config.rows &&
			grid.columns === config.columns &&
			grid.words_count >= (config.wordsCount ?? 0)
	);

	if (matchingGrids.length === 0) {
		throw new Error(`No grids found for difficulty ${difficulty}`);
	}

	// Select a random grid from the matching ones
	const randomGrid = matchingGrids[Math.floor(Math.random() * matchingGrids.length)];

	// Get the word placements for the selected grid
	const placements = await databaseService.getWordPlacements(randomGrid.id);

	// Convert placements to word locations
	const wordsLocation = placements.map(convertWordPlacement);

	// Create and return the game configuration
	return {
		id: randomGrid.id.toString(),
		wordsLocation,
		rows: randomGrid.rows,
		columns: randomGrid.columns,
		title: randomGrid.name
	};
}

export async function getRandomUnplayedGridID(difficulty: Difficulty): Promise<number> {
	const config = DifficultyConfigMap.config(difficulty);
	const grids = await databaseService.getWordSearchGrids();
	const matchingGrids = grids.filter(
		(grid) => grid.rows === config.rows && grid.columns === config.columns && !grid.played_at
	);
	if (matchingGrids.length > 0) {
		return matchingGrids[Math.floor(Math.random() * matchingGrids.length)].id;
	}
	// if the user already played all the grids for this difficulty, return a random grid
	return grids[Math.floor(Math.random() * grids.length)].id;
}

export async function getRandonGridID(difficulty: Difficulty): Promise<number> {
	const config = DifficultyConfigMap.config(difficulty);
	console.log('config', config);
	const grids = await databaseService.getWordSearchGrids();
	const matchingGrids = grids.filter(
		(grid) => grid.rows === config.rows && grid.columns === config.columns
	);
	return matchingGrids[Math.floor(Math.random() * matchingGrids.length)].id;
}

export async function getDailyChallenge(id: number): Promise<DailyChallenge> {
	const grid = await databaseService.getDailyChallengeById(id);
	if (!grid) {
		throw new Error(`Grid with id ${id} not found`);
	}
	return {
		id: grid.id.toString(),
		title: grid.title,
		rows: grid.rows,
		columns: grid.columns,
		date: grid.date,
		quotes: grid.quotes,
		words: grid.words.map(convertWordPlacement)
	};
}

export async function getGridWithID(id: number): Promise<GameConfiguration> {
	const grid = await databaseService.getWordSearchGridById(id);
	if (!grid) {
		throw new Error(`Grid with id ${id} not found`);
	}
	// Get the word placements for the selected grid
	const placements = await databaseService.getWordPlacements(grid.id);

	const wordsLocation = placements.map(convertWordPlacement);

	// Create and return the game configuration
	return {
		id: grid.id.toString(),
		wordsLocation,
		rows: grid.rows,
		columns: grid.columns,
		title: grid.name
	};
}

export async function getUnplayedAndTotalForDifficulty(difficulty: Difficulty): Promise<{
	unplayed: number;
	total: number;
}> {
	const config = DifficultyConfigMap.config(difficulty);
	const grids = await databaseService.getWordSearchGrids();
	const result = {
		unplayed: grids.filter(
			(grid) => grid.rows === config.rows && grid.columns === config.columns && !grid.played_at
		).length,
		total: grids.filter((grid) => grid.rows === config.rows && grid.columns === config.columns)
			.length
	};
	console.log('result', result);
	return result;
}

export async function getTotalGridCountForDifficulty(difficulty: Difficulty): Promise<number> {
	const config = DifficultyConfigMap.config(difficulty);
	const grids = await databaseService.getWordSearchGrids();
	return grids.filter((grid) => grid.rows === config.rows && grid.columns === config.columns)
		.length;
}

export async function getTotalGridCountUnplayedForDifficulty(
	difficulty: Difficulty
): Promise<number> {
	const config = DifficultyConfigMap.config(difficulty);
	const grids = await databaseService.getWordSearchGrids();
	return grids.filter(
		(grid) => grid.rows === config.rows && grid.columns === config.columns && !grid.played_at
	).length;
}

function convertWordPlacement(placement: WordPlacement): WordLocation {
	const direction = convertDatabaseDirection(placement.direction);
	return {
		word: placement.word.toUpperCase(),
		initialPosition: { row: placement.row, col: placement.col },
		direction
	};
}
