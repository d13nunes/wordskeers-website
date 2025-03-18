import SwiftUI

struct WordListView: View {
  @Namespace private var wordTransition

  @State var viewModel: GameViewModel
  @State private var recentlyFoundWord: String?
  let geometry: GeometryProxy

  var hintedWord: WordData? {
    viewModel.powerUpManager.hintedWord
  }

  private let fontSize: CGFloat = 14.0

  @State private var words: [[WordData]] = []

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      ForEach(words, id: \.self) { word in
        HStack(spacing: 4) {
          ForEach(word, id: \.self) { wordData in
            WordDataView(
              word: wordData.word,
              isFound: wordData.isFound,
              direction: wordData.word == hintedWord?.word ? hintedWord?.direction.symbol : nil,
              wordFontSize: fontSize,
              recentlyFoundWord: recentlyFoundWord)
          }
        }
      }
    }
    .padding(12)
    .roundedContainer()
    .onAppear {
      arrangeWordsIntoRows()
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
      arrangeWordsIntoRows()

    }
  }

  /// Function to arrange words into rows dynamically based on screen width
  private func arrangeWordsIntoRows() {

    var currentRow: [WordData] = []
    var newWords: [[WordData]] = []
    var currentWidth: CGFloat = 0
    let componentWidth = geometry.size.width

    let notDiscoveredWords = viewModel.words.filter { !$0.isFound }.sorted {
      $0.word.count < $1.word.count
    }
    let discoveredWords = viewModel.words.filter { $0.isFound }.sorted {
      $0.word.count < $1.word.count
    }

    let sortedWords = notDiscoveredWords + discoveredWords
    for wordData in sortedWords {
      let wordWidth = WordDataView.getSize(for: wordData.word, fontSize: fontSize)

      if currentWidth + wordWidth > componentWidth {
        newWords.append(currentRow)
        currentRow = [wordData]
        currentWidth = wordWidth
      } else {
        currentRow.append(wordData)
        currentWidth += wordWidth + 10  // Include spacing
      }
    }

    if !currentRow.isEmpty {
      newWords.append(currentRow)
    }
    words = newWords
  }

}

#if DEBUG

  #Preview {

    let viewModel = getViewModel(gridSize: 12, wordCount: 10)
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

      GeometryReader { geometry in
        WordListView(viewModel: viewModel, geometry: geometry)
      }
    }
    .background(AppColors.background)

  }
#endif
