import SwiftUI

struct WordListView: View {
  @Namespace private var wordTransition

  @State var viewModel: GameViewModel
  @State private var recentlyFoundWord: String?
  @State private var mostRecentlyFoundWords: [String] = []

  var hintedWord: WordData? {
    viewModel.powerUpManager.hintedWord
  }

  private let fontSize: CGFloat = 14.0

  private var words: [WordData] {
    // Track if a word was most recently found (to move it to the end)
    let isRecentlyFound: (WordData) -> Bool = { word in
      return mostRecentlyFoundWords.contains(word.word)
    }

    // Group 1: Not discovered words (sorted by length)
    let notDiscoveredWords = viewModel.words
      .filter { !$0.isFound }
      .sorted { $0.word.count < $1.word.count }

    // Group 2: Discovered words (not most recent, sorted by length)
    let discoveredWords = viewModel.words
      .filter { $0.isFound && !isRecentlyFound($0) }
      .sorted { $0.word.count < $1.word.count }

    // Group 3: Most recently discovered words (in reverse order of discovery - newest last)
    let recentlyDiscoveredWords =
      mostRecentlyFoundWords
      .reversed()  // Newest words last
      .compactMap { recentWord in
        viewModel.words.first { $0.word == recentWord && $0.isFound }
      }

    // Combine all groups with recently found at the end
    let sortedWords = notDiscoveredWords + discoveredWords + recentlyDiscoveredWords
    return sortedWords
  }
  var height: CGFloat {
    if isSmallScreen() {
      print(" ✅ screen is small")
      return 76
    } else if viewModel.words.count > 20 {
      return 148
    } else if viewModel.words.count > 11 {
      return 120
    } else if viewModel.words.count > 6 {
      return 80
    } else {
      return 60
    }
  }
  var maxRows: Int {
    if isSmallScreen() {
      print(" ✅ screen is small")
      return 2
    } else if viewModel.words.count > 20 {
      return 4
    } else if viewModel.words.count > 11 {
      return 3
    } else if viewModel.words.count > 6 {
      return 2
    } else {
      return 2
    }
  }
  @State private var currentPageIndex: Int = 0
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      PaginatedFlowView(
        items: words,
        viewModel: viewModel,
        recentlyFoundWord: recentlyFoundWord,
        maxRows: maxRows,  // Maximum 3 rows per page
        spacing: isSmallScreen() ? 4 : 8,
        currentPageIndex: $currentPageIndex
      )
      .frame(height: height)
      .padding(isSmallScreen() ? 6 : 12)
      .roundedContainer()
    }
    .onChange(of: viewModel.words) { oldWords, newWords in
      // Find newly discovered word
      if let newlyFound = newWords.first(where: { word in
        word.isFound && !oldWords.contains(where: { $0.word == word.word && $0.isFound })
      }) {
        withAnimation(.spring(duration: 0.3)) {
          recentlyFoundWord = newlyFound.word

          // Add to recently found words list (maintaining order of discovery)
          if !mostRecentlyFoundWords.contains(newlyFound.word) {
            // Remove if already in list (shouldn't happen, but just in case)
            if let existingIndex = mostRecentlyFoundWords.firstIndex(of: newlyFound.word) {
              mostRecentlyFoundWords.remove(at: existingIndex)
            }

            // Add to the list
            mostRecentlyFoundWords.append(newlyFound.word)

            // Limit the number of recent words to remember
            if mostRecentlyFoundWords.count > 10 {
              mostRecentlyFoundWords.removeFirst()
            }
          }
        }

        // Reset highlight after animation
        Task { @MainActor in
          try? await Task.sleep(for: .milliseconds(500))
          withAnimation(.spring(duration: 0.3)) {
            recentlyFoundWord = nil
          }
        }
      }
    }
    .onChange(of: viewModel.gridId) { oldId, newId in
      if oldId != newId {
        currentPageIndex = 0
      }
    }
  }
}

#if DEBUG

  #Preview {

    let viewModel = getViewModel(gridSize: 12, wordCount: 40)
    VStack {
      Button("Find Random Word") {
        let word = viewModel.wordValidator.findRandomWord()!
        let valid = viewModel.wordValidator.validateWord(word)
        print(word, valid)
      }

      Button("Use Direction Power Up") {
        Task { @MainActor in
          let success = await viewModel.powerUpManager.requestPowerUp(
            type: .directional,
            undiscoveredWords: viewModel.words.filter { !$0.isFound },
            on: UIApplication.shared.rootViewController()!
          )
          print("Direction Power Up requested: \(success)")
        }
      }
      WordListView(viewModel: viewModel)
    }
    .padding(12)
    .background(AppColors.background)

  }
#endif
