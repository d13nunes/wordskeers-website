struct DifficultyConfigMap {
  @available(*, unavailable, message: "Static class, do not instantiate")
  private init() {}

  static func config(for difficulty: Difficulty) -> GameConfigurationSetting {
    difficultyGameConfig[difficulty]!
  }

  static let difficultyGameConfig: [Difficulty: GameConfigurationSetting] = [
    .veryEasy: GameConfigurationSetting(
      gridSize: 6,
      wordsCount: nil,
      validDirections: Direction.veryEasy,
      gameMode: .classicVeryEasy
    ),
    .easy: GameConfigurationSetting(
      gridSize: 8,
      wordsCount: nil,
      validDirections: Direction.easy,
      gameMode: .classicEasy
    ),
    .medium: GameConfigurationSetting(
      gridSize: 10,
      wordsCount: nil,
      validDirections: Direction.medium,
      gameMode: .classicMedium
    ),
    .hard: GameConfigurationSetting(
      gridSize: 12,
      wordsCount: nil,
      validDirections: Direction.hard,
      gameMode: .classicHard
    ),
    // .veryHard: GameConfigurationSetting(
    //   gridSize: 20,
    //   wordsCount: nil,
    //   validDirections: Direction.veryHard,
    //   gameMode: .classicVeryHard
    // ),
  ]
}
