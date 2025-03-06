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
      validDirections: Direction.veryEasy
    ),
    .easy: GameConfigurationSetting(
      gridSize: 6,
      wordsCount: 8,
      validDirections: Direction.easy
    ),
    .medium: GameConfigurationSetting(
      gridSize: 10,
      wordsCount: 15,
      validDirections: Direction.medium
    ),
    .hard: GameConfigurationSetting(
      gridSize: 16,
      wordsCount: 20,
      validDirections: Direction.hard
    ),
    .veryHard: GameConfigurationSetting(
      gridSize: 20,
      wordsCount: 25,
      validDirections: Direction.veryHard
    ),
  ]
}
