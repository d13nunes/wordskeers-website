struct RotateBoardPowerUp: PowerUp {
  let type: PowerUpType = .rotateBoard
  let icon: String = "arrow.counterclockwise"
  let description: String = "Rotate the board"
  var isAvailable: Bool = true
  var price: Int = 100

  private let doRotation: (Int) -> Void
  private let wallet: Wallet

  init(doRotation: @escaping (Int) -> Void, wallet: Wallet) {
    self.doRotation = doRotation
    self.wallet = wallet
  }

  @MainActor
  func use(undiscoveredWords: [WordData]) async -> Bool {
    guard isAvailable else {
      return false
    }
    doRotation(180)
    return true
  }
}
