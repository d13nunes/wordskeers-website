protocol PowerUp {
  var type: PowerUpType { get }
  var price: Int { get }
  var isAvailable: Bool { get }

  @MainActor
  func use(undiscoveredWords: [WordData]) async -> Bool
}
