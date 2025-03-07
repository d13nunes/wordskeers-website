struct DifficultyConfigMap {
  @available(*, unavailable, message: "Static class, do not instantiate")
  private init() {}

  static func config(for difficulty: Difficulty) -> GameConfigurationSetting {
    difficultyGameConfig[difficulty]!
  }

  static let difficultyGameConfig: [Difficulty: GameConfigurationSetting] = [
    .veryEasy: GameConfigurationSetting(
      gridSize: 6,
      wordsCount: 6,
      validDirections: Direction.veryEasy,
      gameMode: .classicVeryEasy
    ),
    .easy: GameConfigurationSetting(
      gridSize: 6,
      wordsCount: 8,
      validDirections: Direction.easy,
      gameMode: .classicEasy
    ),
    .medium: GameConfigurationSetting(
      gridSize: 10,
      wordsCount: 15,
      validDirections: Direction.medium,
      gameMode: .classicMedium
    ),
    .hard: GameConfigurationSetting(
      gridSize: 16,
      wordsCount: 20,
      validDirections: Direction.hard,
      gameMode: .classicHard
    ),
    .veryHard: GameConfigurationSetting(
      gridSize: 20,
      wordsCount: 25,
      validDirections: Direction.veryHard,
      gameMode: .classicVeryHard
    ),
  ]
}
