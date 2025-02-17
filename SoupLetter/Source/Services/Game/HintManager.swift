import Foundation

/// Manages the hint system for the word search game
@Observable class HintManager {
  // MARK: - Properties

  private(set) var hintPosition: Position?
  var canRequestHint: Bool {
    hintPosition == nil
  }

  // MARK: - Public Methods

  /// Provides a hint by finding the first letter position of a random unfound word
  /// Returns true if a hint was successfully provided
  func requestHint(words: [WordData]) -> Bool {
    let unfoundWords = words.filter { !$0.isFound }
    if let word = unfoundWords.randomElement() {
      self.hintPosition = word.position
      return true
    }
    return false
  }

  func clearHint() {
    hintPosition = nil
  }
}
