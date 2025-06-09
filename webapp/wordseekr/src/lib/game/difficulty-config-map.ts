import { Difficulty } from '../game/difficulty';
import { GameConfigurationSetting } from '../game/game-configuration-setting';
import { DirectionPresets } from '../game/direction-presets';

export class DifficultyConfigMap {
	private constructor() {
		// Static class, do not instantiate
	}

	static config(difficulty: Difficulty): GameConfigurationSetting {
		return DifficultyConfigMap.difficultyGameConfig[difficulty]!;
	}

	static readonly difficultyGameConfig: Record<Difficulty, GameConfigurationSetting> = {
		[Difficulty.VeryEasy]: new GameConfigurationSetting({
			rows: 6,
			columns: 6,
			wordsCount: null,
			validDirections: DirectionPresets.veryEasy,
			gameMode: 'classicVeryEasy'
		}),
		[Difficulty.Easy]: new GameConfigurationSetting({
			rows: 8,
			columns: 8,
			wordsCount: null,
			validDirections: DirectionPresets.easy,
			gameMode: 'classicEasy'
		}),
		[Difficulty.Medium]: new GameConfigurationSetting({
			rows: 10,
			columns: 10,
			wordsCount: null,
			validDirections: DirectionPresets.medium,
			gameMode: 'classicMedium'
		}),
		[Difficulty.Hard]: new GameConfigurationSetting({
			rows: 12,
			columns: 12,
			wordsCount: null,
			validDirections: DirectionPresets.hard,
			gameMode: 'classicHard'
		}),
		[Difficulty.VeryHard]: new GameConfigurationSetting({
			rows: 16,
			columns: 16,
			wordsCount: null,
			validDirections: DirectionPresets.veryHard,
			gameMode: 'classicVeryHard'
		})
	};
}
