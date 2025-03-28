import Foundation

struct DirectionPowerUp: PowerUp {
  let type: PowerUpType = .directional
  let icon: String = "arrow.up.and.down.and.arrow.left.and.right"
  let description: String = "Get a directional hint for a word"
  var isAvailable: Bool = true
  var price: Int = 60
  private let setHintedWord: (WordData) -> Void
  private let wallet: Wallet

  init(setHintedWord: @escaping (WordData) -> Void, wallet: Wallet) {
    self.setHintedWord = setHintedWord
    self.wallet = wallet
  }

  @MainActor
  func use(undiscoveredWords: [WordData]) async -> Bool {
    guard isAvailable else {
      return false
    }
    guard let word = undiscoveredWords.filter({ !$0.isFound }).randomElement() else {
      return false
    }
    setHintedWord(word)
    return true
  }
}
