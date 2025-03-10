struct HintPowerUp: PowerUp {
  let type: PowerUpType = .hint
  let icon: String = "lightbulb"
  let description: String = "Get a hint for a word"
  var isAvailable: Bool = true
  var price: String = "100"
  private let setHintedPositions: ([Position]) -> Void

  init(setHintedPositions: @escaping ([Position]) -> Void) {
    self.setHintedPositions = setHintedPositions
  }

  @MainActor
  func canUse() -> Bool {
    return true
  }

  @MainActor
  func use(undiscoveredWords: [WordData]) async -> Bool {
    guard isAvailable else {
      return false
    }
    guard let word = undiscoveredWords.filter({ !$0.isFound }).randomElement() else {
      return false
    }
    setHintedPositions([word.position])
    return true
  }
}
