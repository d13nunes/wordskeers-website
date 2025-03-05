protocol GameConfigurationFactoring {
  func createConfiguration(difficulty: Difficulty) -> GridGenerating
}

protocol GridGenerating {
  var configuration: GameConfiguration { get }
  func generate() -> ([[String]], [WordData])
}
