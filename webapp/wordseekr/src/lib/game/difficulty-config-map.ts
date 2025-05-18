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
			gridSize: 6,
			wordsCount: null,
			validDirections: DirectionPresets.veryEasy,
			gameMode: 'classicVeryEasy'
		}),
		[Difficulty.Easy]: new GameConfigurationSetting({
			gridSize: 8,
			wordsCount: null,
			validDirections: DirectionPresets.easy,
			gameMode: 'classicEasy'
		}),
		[Difficulty.Medium]: new GameConfigurationSetting({
			gridSize: 10,
			wordsCount: null,
			validDirections: DirectionPresets.medium,
			gameMode: 'classicMedium'
		}),
		[Difficulty.Hard]: new GameConfigurationSetting({
			gridSize: 12,
			wordsCount: null,
			validDirections: DirectionPresets.hard,
			gameMode: 'classicHard'
		}),
		[Difficulty.VeryHard]: new GameConfigurationSetting({
			gridSize: 16,
			wordsCount: null,
			validDirections: DirectionPresets.veryHard,
			gameMode: 'classicVeryHard'
		})
	};
}
