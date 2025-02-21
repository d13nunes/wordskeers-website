import SwiftUI

struct WordListView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @Namespace private var wordTransition

  @State var viewModel: GameViewModel
  @State private var recentlyFoundWord: String?

  private var isCompact: Bool {
    horizontalSizeClass == .compact
  }

  let maxRowCount = 3
  var collumns: Int {
    viewModel.words.count / maxRowCount + ((viewModel.words.count % maxRowCount != 0) ? 1 : 0)
  }

  var wordFont: Font {
    isCompact ? .system(size: 18) : .system(size: 32)
  }
  var horizontalSpacing: CGFloat {
    isCompact ? 10 : 18
  }
  var verticalSpacing: CGFloat {
    isCompact ? 2 : 4
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
      HStack(alignment: .top, spacing: horizontalSpacing) {
        ForEach(gridItems, id: \.self) { collumn in
          VStack(alignment: .leading, spacing: verticalSpacing) {
            ForEach(collumn, id: \.word) { word in
              Text("\(word.word.capitalized)")
                .font(wordFont)

                .bold(!word.isFound)
                .foregroundColor(word.isFound ? .green.opacity(0.5) : .primary)
                .strikethrough(word.isFound, color: .green.opacity(0.5))
                .animation(.easeInOut(duration: 0.5), value: word.isFound)
                .matchedGeometryEffect(id: word.word, in: wordTransition)
            }
          }
        }
      }
      .scrollIndicators(.automatic, axes: .vertical)
      .animation(.spring(response: 0.5, dampingFraction: 0.8), value: gridItems)
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
      Button("Find Random Word") {
        let word = viewModel.wordValidator.findRandomWord()!
        let valid = viewModel.wordValidator.validateWord(word)
        print(word, valid)
      }
      WordListView(viewModel: viewModel)
    }
  }
#endif
