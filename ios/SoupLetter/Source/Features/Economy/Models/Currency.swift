/// Represents the different types of currency in the game
enum Currency: String, Codable {
  case coins

  var icon: String {
    switch self {
    case .coins: return "coin.fill"  // SF Symbol
    }
  }

  var name: String {
    switch self {
    case .coins: return "Coins"
    }
  }
}
