struct Position: Hashable, Equatable {
  let row: Int
  let col: Int

  static func == (lhs: Position, rhs: Position) -> Bool {
    lhs.row == rhs.row && lhs.col == rhs.col
  }
}
