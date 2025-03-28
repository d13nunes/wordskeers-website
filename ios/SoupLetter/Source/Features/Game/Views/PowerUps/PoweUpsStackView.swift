import SwiftUI

struct PowerUpsStackView: View {
  let viewModel: GameViewModel

  var powerUpManager: PowerUpManager {
    viewModel.powerUpManager
  }

  var body: some View {
    HStack(alignment: .bottom, spacing: 2) {
      ForEach(powerUpManager.powerUps, id: \.type) { powerUp in
        PowerUpButtonView(
          viewModel: .getViewModel(powerUp: powerUp)
        ) {
          print("clicked")
          onPowerUpClicked(powerUp)
        }
      }
    }
  }
  @MainActor
  private func onPowerUpClicked(_ powerUp: PowerUp) {
    guard let viewController = UIApplication.shared.rootViewController() else {
      return
    }
    Task {
      let undiscoveredWords = viewModel.words.filter { !$0.isFound }
      let success = await powerUpManager.requestPowerUp(
        type: powerUp.type,
        undiscoveredWords: undiscoveredWords,
        on: viewController
      )
      if !success {
        viewModel.showNotEnoughCoinsAlert = true
        viewModel.showStoreView()
      }
    }
  }

}

#if DEBUG
  #Preview {
    PowerUpsStackView(viewModel: getViewModel(gridSize: 5, wordCount: 10))
  }
#endif
