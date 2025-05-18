import type { Direction } from '../components/Game/Direction';

export class GameConfigurationSetting {
	constructor(config: {
		gridSize: number;
		wordsCount: number | null;
		validDirections: Direction[];
		gameMode: string;
	}) {
		this.gridSize = config.gridSize;
		this.wordsCount = config.wordsCount;
		this.validDirections = config.validDirections;
		this.gameMode = config.gameMode;
	}

	gridSize: number;
	wordsCount: number | null;
	validDirections: Direction[];
	gameMode: string;
}
