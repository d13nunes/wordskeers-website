import Foundation

struct MockGridFetcher: GridFetching {
  func getGridRandom(config: GameConfigurationSetting) -> GridDataDTO {
    return GridDataDTO(
      id: -1,
      category: "animals",
      size: 10,
      placedWordsCount: 10,
      placedWords: [
        WordPlacementDTO(
          word: "dog",
          row: 0,
          col: 0,
          direction: .horizontal
        ),
        WordPlacementDTO(
          word: "cat",
          row: 0,
          col: 1,
          direction: .horizontal
        ),

      ]
    )
  }
}
