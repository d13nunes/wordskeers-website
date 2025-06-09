import type { DirectionSymbol } from './direction-presets';

export class GameConfigurationSetting {
	constructor(config: {
		rows: number;
		columns: number;
		wordsCount: number | null;
		validDirections: DirectionSymbol[];
		gameMode: string;
	}) {
		this.rows = config.rows;
		this.columns = config.columns;
		this.wordsCount = config.wordsCount;
		this.validDirections = config.validDirections;
		this.gameMode = config.gameMode;
	}

	rows: number;
	columns: number;
	wordsCount: number | null;
	validDirections: DirectionSymbol[];
	gameMode: string;
}
