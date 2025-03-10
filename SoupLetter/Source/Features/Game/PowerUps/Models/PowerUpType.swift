enum PowerUpType: Int, CaseIterable {
  case none = 0
  case hint = 1
  case directional = 2
  case fullWord = 3
  case rotateBoard = 4

}

extension PowerUpType {
  var analyticsEvent: AnalyticsEvent {
    switch self {
    case .hint: return .gameHintPowerUpUsed
    case .directional: return .gameDirectionalPowerUpUsed
    case .fullWord: return .gameFullWordPowerUpUsed
    case .rotateBoard: return .gameRotateBoardPowerUpUsed
    case .none: fatalError("PowerUpType.none is not a valid power-up type")
    }
  }
}
