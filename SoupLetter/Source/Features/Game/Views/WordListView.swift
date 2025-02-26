import SwiftUI

struct WordListView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @Namespace private var wordTransition

  @State var viewModel: GameViewModel
  @State private var recentlyFoundWord: String?

  private var isCompact: Bool {
    horizontalSizeClass == .compact
  }
  var maxCollumns: Int {
    isCompact ? 4 : 4
  }

  var wordFont: Font {
    isCompact ? .system(size: 18) : .system(size: 32)
  }
  var horizontalSpacing: CGFloat {
    isCompact ? 10 : 22
  }
  var verticalSpacing: CGFloat {
    isCompact ? 4 : 6
  }

  var gridItems: [[WordData]] {
    print("words2: \(maxCollumns)")
    return viewModel.words
      .sorted { word1, word2 in
        // First sort by found status (not found first)
        if word1.isFound != word2.isFound {
          return !word1.isFound
        }
        // Then sort by length
        if word1.word.count != word2.word.count {
          return word1.word.count < word2.word.count
        }
        // Finally sort alphabetically wit same length groups
        return word1.word < word2.word
      }
      .chunked(into: maxCollumns)
  }

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: horizontalSpacing) {
      ForEach(gridItems, id: \.self) { collumn in
        VStack(alignment: .leading, spacing: verticalSpacing) {
          ForEach(collumn, id: \.word) { word in
            Text("\(word.word.capitalized)")
              .font(wordFont)
              .bold(!word.isFound)
              .foregroundColor(word.isFound ? .green.opacity(0.5) : .primary)
              .strikethrough(word.isFound, color: .green.opacity(0.5))
              .scaleEffect(recentlyFoundWord == word.word ? 1.2 : 1.0)
              .animation(.spring(duration: 0.5), value: word.isFound)
              .matchedGeometryEffect(id: word.word, in: wordTransition)
          }
        }
      }
    }
    .onChange(of: viewModel.words) { oldWords, newWords in
      // Find newly discovered word
      if let newlyFound = newWords.first(where: { word in
        word.isFound && !oldWords.contains(where: { $0.word == word.word && $0.isFound })
      }) {
        withAnimation(.spring(duration: 0.3)) {
          recentlyFoundWord = newlyFound.word
        }
        // Reset after animation
        Task { @MainActor in
          try? await Task.sleep(for: .milliseconds(500))
          withAnimation(.spring(duration: 0.3)) {
            recentlyFoundWord = nil
          }
        }
      }
    }
  }
}

#if DEBUG
  #Preview {
    let viewModel = getViewModel(gridSize: 30, wordCount: 4)
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
