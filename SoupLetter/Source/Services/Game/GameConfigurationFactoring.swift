protocol GameConfigurationFactoring {
  func createConfiguration(configuration: GameConfigurationSetting) -> GridGenerating
}

protocol GridGenerating {
  var configuration: GameConfiguration { get }
  func generate() -> ([[String]], [WordData])
}
