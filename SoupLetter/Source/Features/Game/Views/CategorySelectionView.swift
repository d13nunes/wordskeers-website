import SwiftUI

/// View for selecting game category and difficulty
struct CategorySelectionView: View {
  // MARK: - Properties

  @Environment(\.dismiss) private var dismiss
  @State private var selectedCategory: String?
  @State private var selectedDifficulty: Difficulty?

  let wordStore = WordListStore()
  let onStartGame: (GameConfiguration) -> Void

  private let categories = ["animals", "fruits"]
  private let difficulties = Difficulty.allCases
  private var canStartGame: Bool {
    return selectedCategory != nil && selectedDifficulty != nil
  }

  // MARK: - Body

  var body: some View {
    VStack {
      List {
        Section("Category") {
          ForEach(categories, id: \.self) { category in
            Button {
              selectedCategory = category
            } label: {
              HStack {
                Text(category.capitalized)
                  .foregroundStyle(.primary)
                Spacer()
                if selectedCategory == category {
                  Image(systemName: "checkmark")
                    .foregroundStyle(.blue)
                }
              }
            }
          }
        }

        if let category = selectedCategory {
          Section("Difficulty") {
            ForEach(difficulties, id: \.self) { difficulty in
              let hasWords = wordStore.hasWords(category: category, difficulty: difficulty)
              Button {
                selectedDifficulty = difficulty
              } label: {
                HStack {
                  Text(difficulty.description.capitalized)
                    .foregroundStyle(hasWords ? .primary : .secondary)
                  if !hasWords {
                    Text("(No words available)")
                      .foregroundStyle(.secondary)
                      .font(.caption)
                  }
                  Spacer()
                  if selectedDifficulty == difficulty {
                    Image(systemName: "checkmark")
                      .foregroundStyle(.blue)
                  }
                }
              }
              .disabled(!hasWords)
            }
          }
        }
      }
      HStack {
        Button("Cancel") {
          dismiss()
        }
        Button("Start") {
          if canStartGame {
            let words = wordStore.getWords(
              category: selectedCategory!,
              difficulty: selectedDifficulty!
            )
            let gridSize = selectedDifficulty!.getGridSize()
            let configuration = GameConfiguration(
              gridSize: gridSize,
              words: words
            )
            onStartGame(configuration)
          }
        }
        .disabled(!canStartGame)
      }
      
    }
    .navigationTitle("New Game")
    .navigationBarTitleDisplayMode(.inline)

  }

}

#Preview {
  let wordStore = WordListStore()
  CategorySelectionView { configuration in
    print(configuration)
  }
}
