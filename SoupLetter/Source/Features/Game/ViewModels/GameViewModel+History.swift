import Foundation

/*
 * EXAMPLE IMPLEMENTATION
 *
 * This is a template showing how to integrate the GameHistoryService with your GameViewModel.
 * The properties and methods here need to be adapted to match your actual GameViewModel implementation.
 *
 * Required properties in your GameViewModel:
 * - currentGrid: The current WordSearchGrid being played, with an id property
 * - discoveredWords: Array of words found by the player
 * - totalWords: Total number of words in the grid
 * - currentScore: Player's current score
 * - elapsedTime: Time spent playing (in seconds)
 * - gridSize: Size of the grid
 * - difficulty: Enum representing game difficulty
 */

// Extension to integrate game history recording into GameViewModel
extension GameViewModel {
  /// Records the current game to the player's game history
  /// - Parameter gameHistoryService: The game history service
  /// - Returns: The saved game history record
  ///
  /// Example usage:
  /// ```
  /// @Dependency private var gameHistoryService: GameHistoryService
  ///
  /// func endGame() {
  ///     // End game logic
  ///     Task {
  ///         await recordGameToHistory(using: gameHistoryService)
  ///     }
  /// }
  /// ```
  func recordGameToHistory(using gameHistoryService: GameHistoryService) async -> GameHistory? {
    // ADAPT THIS METHOD: Replace with actual properties from your GameViewModel

    // Example implementation:
    // guard let gridId = currentGrid?.id else { return nil }
    //
    // let metadataDict: [String: Any] = [
    //     "foundWords": discoveredWords.map { $0.word },
    //     "totalWords": totalWords,
    //     "gridSize": gridSize,
    //     "difficulty": difficulty.rawValue
    // ]
    //
    // let metadata = GameHistory.createMetadata(from: metadataDict)
    //
    // return await gameHistoryService.recordGame(
    //     gridId: gridId,
    //     score: currentScore,
    //     timeTaken: elapsedTime,
    //     completed: discoveredWords.count == totalWords,
    //     metadata: metadata
    // )

    return nil  // Replace with actual implementation
  }

  /// Checks if the player has already played this grid
  /// - Parameter gameHistoryService: The game history service
  /// - Returns: True if the grid has been played before
  func hasPlayedCurrentGrid(using gameHistoryService: GameHistoryService) async -> Bool {
    // ADAPT THIS METHOD: Replace with actual properties from your GameViewModel

    // Example implementation:
    // guard let gridId = currentGrid?.id else { return false }
    // return await gameHistoryService.hasPlayedGrid(gridId: gridId)

    return false  // Replace with actual implementation
  }

  /// Gets the previous plays of the current grid
  /// - Parameter gameHistoryService: The game history service
  /// - Returns: An array of game history records for this grid
  func getPreviousPlays(using gameHistoryService: GameHistoryService) async -> [GameHistory] {
    // ADAPT THIS METHOD: Replace with actual properties from your GameViewModel

    // Example implementation:
    // guard let gridId = currentGrid?.id else { return [] }
    // return await gameHistoryService.getHistoryForGrid(gridId: gridId)

    return []  // Replace with actual implementation
  }
}
