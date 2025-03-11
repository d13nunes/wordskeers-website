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
          enabled: powerUp.isAvailable, icon: powerUp.icon, price: "\(powerUp.price)"
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
      let success = await powerUpManager.requestPowerUp(
        type: powerUp.type,
        undiscoveredWords: viewModel.words,
        on: viewController
      )
      if !success {
        viewModel.showNotEnoughCoinsAlert = true
        viewModel.isShowingStoreView = true
      }
    }
  }

}

#if DEBUG
  #Preview {
    PowerUpsStackView(viewModel: getViewModel(gridSize: 15, wordCount: 10))
  }
#endif
