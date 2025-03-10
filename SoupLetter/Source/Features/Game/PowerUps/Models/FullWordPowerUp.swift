struct FullWordPowerUp: PowerUp {
  let type: PowerUpType = .fullWord
  let icon: String = "text.book.closed"
  let description: String = "Get a full word hint"
  var isAvailable: Bool = true
  var price: String = "100"

  private let setHintedPositions: ([Position]) -> Void

  init(setHintedPositions: @escaping ([Position]) -> Void) {
    self.setHintedPositions = setHintedPositions
  }

  @MainActor
  func use(undiscoveredWords: [WordData]) async -> Bool {
    guard isAvailable else {
      return false
    }
    guard let word = undiscoveredWords.filter({ !$0.isFound }).randomElement() else {
      return false
    }
    setHintedPositions(word.allPositions())
    return true
  }
}
