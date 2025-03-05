import Foundation

struct GridModel: Codable {
  let grids: [GridDataDTO]
  let mode: String
}

struct GridDataDTO: Codable {
  let category: String
  let size: Int
  let placedWordsCount: Int
  let placedWords: [WordPlacementDTO]
}

struct WordPlacementDTO: Codable {
  let word: String
  let row: Int
  let col: Int
  let direction: String
}

extension String {
  func toDirection() -> Direction {
    switch self {
    case "horizontal": return Directions.right
    case "vertical": return Directions.down
    case "diagonal-ur": return Directions.diagonalRightUp
    case "diagonal-ul": return Directions.diagonalLeftUp
    case "diagonal-dr": return Directions.diagonalRightDown
    case "diagonal-dl": return Directions.diagonalLeftDown
    case "horizontal-r": return Directions.left
    case "vertical-r": return Directions.up
    default: return Directions.right
    }
  }
}

struct CategoriesModelParser: Codable {
  static func parse(data: Data) -> [GridModel]? {
    do {
      let start = CFAbsoluteTimeGetCurrent()
      let model = try JSONDecoder().decode([GridModel].self, from: data)
      let end = CFAbsoluteTimeGetCurrent()
      print("JSON decoding took \(end - start) seconds")
      return model
    } catch {
      print("Error decoding JSON: \(error)")
      return nil
    }
  }

  static func fromBundle() -> [GridModel]? {
    do {
      let url = Bundle.main.url(forResource: "categories", withExtension: "json")
      let data = try Data(contentsOf: url!)
      let model = CategoriesModelParser.parse(data: data)
      return model
    } catch {
      return nil
    }
  }
}
