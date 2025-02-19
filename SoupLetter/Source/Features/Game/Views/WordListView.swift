import SwiftUI

struct WordListView: View {
  @State var viewModel: GameViewModel
  @State private var recentlyFoundWord: String?
  @Namespace private var wordTransition

  let maxRowCount = 3
  var collumns: Int {
    viewModel.words.count / 3 + ((viewModel.words.count % 3 != 0) ? 1 : 0)
  }

  var gridItems: [[WordData]] {
    viewModel.words
      .sorted { word1, word2 in
        // First sort by found status (not found first)
        if word1.isFound != word2.isFound {
          return !word1.isFound
        }
        // Then sort by length
        if word1.word.count != word2.word.count {
          return word1.word.count < word2.word.count
        }
        // Finally sort alphabetically within same length groups
        return word1.word < word2.word
      }
      .chunked(into: maxRowCount)
  }

  var body: some View {
    ScrollView(.horizontal) {
      HStack(alignment: .top, spacing: 4) {
        ForEach(gridItems, id: \.self) { collumn in
          VStack(alignment: .leading) {
            ForEach(collumn, id: \.word) { word in
              let isRecentlyFound = word.word == recentlyFoundWord

              HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(
                  systemName: word.isFound ? "checkmark.square.fill" : "square"
                )
                .foregroundColor(word.isFound ? .green : .gray)

                Text(word.word.capitalized)
                  .font(.subheadline)
                  .foregroundColor(word.isFound ? .primary : .secondary)
              }
              .padding(.horizontal, 12)
              .padding(.vertical, 6)
              .background {
                RoundedRectangle(cornerRadius: 8)
                  .fill(word.isFound ? Color.green.opacity(0.1) : Color.clear)
              }
              .scaleEffect(isRecentlyFound ? 1.1 : 1.0)
              .matchedGeometryEffect(id: word.word, in: wordTransition)
              .animation(.spring(response: 0.5, dampingFraction: 0.7), value: word.isFound)
              .animation(.spring(response: 0.5, dampingFraction: 0.7), value: gridItems)
            }
          }
        }
      }
      .scrollIndicators(.automatic, axes: .vertical)
      .animation(.spring(response: 0.5, dampingFraction: 0.7), value: gridItems)
    }
    .onChange(of: viewModel.words) { oldWords, newWords in
      // Find newly discovered word
      if let newlyFound = newWords.first(where: { word in
        word.isFound && !oldWords.contains(where: { $0.word == word.word && $0.isFound })
      }) {
        recentlyFoundWord = newlyFound.word
        // Reset after animation
        Task { @MainActor in
          try? await Task.sleep(for: .milliseconds(500))
          recentlyFoundWord = nil
        }
      }
    }
  }
}
#if DEBUG
  #Preview {
    let viewModel = getViewModel(gridSize: 16, wordCount: 15)
    VStack {
      Button("Hint") {
        let word = viewModel.wordValidator.findRandomWord()!
        let valid = viewModel.wordValidator.validateWord(word)
        print(word, valid)
      }
      WordListView(viewModel: viewModel)
    }
  }
#endif
