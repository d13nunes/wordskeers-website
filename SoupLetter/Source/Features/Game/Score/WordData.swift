struct WordData: Hashable {
  let word: String
  let isFound: Bool
  let position: Position
  let direction: Direction

  func copy(isFound: Bool) -> WordData {
    WordData(word: word, isFound: isFound, position: position, direction: direction)
  }
}
