import Foundation

class GridFromFile: GridFactory {
  func getGrid() -> ([[String]], [String]) {
    return (grid, words)
  }
  let words: [String] = ["PUZZLE", "GAME", "CONSOLE"]

  let grid: [[String]] = [
    ["F", "H", "Q", "V", "P", "R", "Z", "Z", "L", "L"],
    ["H", "Q", "Q", "C", "C", "K", "Y", "E", "O", "I"],
    ["M", "C", "U", "G", "N", "I", "D", "T", "Q", "S"],
    ["Y", "H", "I", "W", "S", "O", "C", "U", "C", "R"],
    ["L", "D", "Y", "P", "O", "P", "W", "P", "O", "G"],
    ["T", "P", "U", "Z", "Z", "L", "E", "A", "N", "A"],
    ["R", "B", "C", "O", "S", "D", "B", "M", "S", "M"],
    ["J", "A", "U", "C", "T", "L", "P", "J", "O", "E"],
    ["K", "W", "F", "E", "G", "T", "Q", "E", "E", "U"],
    ["G", "C", "S", "T", "M", "A", "S", "I", "L", "L"],
  ]

}
