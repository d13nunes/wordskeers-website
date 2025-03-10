struct RotateBoardPowerUp: PowerUp {
  let type: PowerUpType = .rotateBoard
  let icon: String = "arrow.counterclockwise"
  let description: String = "Rotate the board"
  var isAvailable: Bool = true
  var price: String = "100"

  private let doRotation: (Int) -> Void

  init(doRotation: @escaping (Int) -> Void) {
    self.doRotation = doRotation
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
