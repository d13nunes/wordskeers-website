// /// Represents the possible directions a word can be placed in a word search grid
// enum DirectionType: String, Codable, CaseIterable, Equatable {
//   case horizontal = "horizontal"  // →
//   case vertical = "vertical"  // ↓
//   case diagonalDownRight = "diagonal-dr"  // ↘
//   case diagonalDownLeft = "diagonal-dl"  // ↙
//   case diagonalUpRight = "diagonal-ur"  // ↗
//   case diagonalUpLeft = "diagonal-ul"  // ↖
//   case horizontalReverse = "horizontal-r"  // ←
//   case verticalReverse = "vertical-r"  // ↑

//   var dx: Int {
//     switch self {
//     case .horizontal, .diagonalDownRight, .diagonalUpRight:
//       return 1
//     case .horizontalReverse, .diagonalDownLeft, .diagonalUpLeft:
//       return -1
//     case .vertical, .verticalReverse:
//       return 0
//     }
//   }

//   var dy: Int {
//     switch self {
//     case .vertical, .diagonalDownRight, .diagonalDownLeft:
//       return 1
//     case .verticalReverse, .diagonalUpRight, .diagonalUpLeft:
//       return -1
//     case .horizontal, .horizontalReverse:
//       return 0
//     }
//   }

//   var symbol: String {
//     switch self {
//     case .horizontal: return "→"
//     case .vertical: return "↓"
//     case .diagonalDownRight: return "↘"
//     case .diagonalDownLeft: return "↙"
//     case .diagonalUpRight: return "↗"
//     case .diagonalUpLeft: return "↖"
//     case .horizontalReverse: return "←"
//     case .verticalReverse: return "↑"
//     }
//   }

//   /// Convert to the existing Direction struct
//   var toDirection: Direction {
//     switch self {
//     case .horizontal: return .horizontal
//     case .vertical: return .vertical
//     case .diagonalDownRight: return .diagonalDownRight
//     case .diagonalDownLeft: return .diagonalDownLeft
//     case .diagonalUpRight: return .diagonalUpRight
//     case .diagonalUpLeft: return .diagonalUpLeft
//     case .horizontalReverse: return .horizontalReverse
//     case .verticalReverse: return .verticalReverse
//     }
//   }

//   static func == (lhs: DirectionType, rhs: DirectionType) -> Bool {
//     return lhs.rawValue == rhs.rawValue
//   }

//   static func != (lhs: DirectionType, rhs: DirectionType) -> Bool {
//     return lhs.rawValue != rhs.rawValue
//   }
// }

// // extension Array where Element == DirectionType {
// //   ===
// //   func equals(other: [DirectionType]) -> Bool {
// //     return self.sorted() == other.sorted()
// //   }
// // }
