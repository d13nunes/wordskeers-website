// import SwiftUI

// /// A view modifier that adds a coin toast animation
// struct CoinToastModifier: ViewModifier {
//   /// The amount of coins to display
//   let coinAmount: Int

//   /// Whether to show the toast
//   @Binding var isPresented: Bool

//   /// Callback when animation completes
//   var onComplete: (() -> Void)?

//   func body(content: Content) -> some View {
//     // Debug logging outside the view
//     if isPresented {
//       print("💰💰💰 CoinToastModifier: Toast should be visible with \(coinAmount) coins")
//     }

//     return ZStack {
//       content

//       if isPresented {
//         CoinsToastView(
//           coinAmount: coinAmount,
//           isVisible: $isPresented,
//           onComplete: {
//             print("💰💰💰 Coin toast animation completed")
//             onComplete?()
//           }
//         )
//       }
//     }
//     .onChange(of: isPresented) { oldValue, newValue in
//       print("💰💰💰 isPresented changed from \(oldValue) to \(newValue)")
//     }
//   }
// }

// extension View {
//   /// Shows a toast animation with flying coins and confetti when coins are added
//   /// - Parameters:
//   ///   - isPresented: Binding that controls whether the toast is visible
//   ///   - coinAmount: The amount of coins to display in the toast
//   ///   - onComplete: Optional callback triggered when the animation completes
//   /// - Returns: A view with the coin toast animation added
//   func coinToast(
//     isPresented: Binding<Bool>,
//     coinAmount: Int,
//     onComplete: (() -> Void)? = nil
//   ) -> some View {
//     modifier(
//       CoinToastModifier(
//         coinAmount: coinAmount,
//         isPresented: isPresented,
//         onComplete: onComplete
//       )
//     )
//   }
// }

// #Preview {
//   struct PreviewWrapper: View {
//     @State private var showToast = false
//     @State private var coinAmount = 100

//     var body: some View {
//       ZStack {
//         Color.white
//           .ignoresSafeArea()

//         VStack(spacing: 20) {
//           Stepper("Coins: \(coinAmount)", value: $coinAmount, in: 10...1000, step: 50)
//             .padding()
//             .background(Color.gray.opacity(0.2))
//             .cornerRadius(8)

//           Button("Show Coin Toast") {
//             showToast = true
//           }
//           .padding()
//           .background(Color.blue)
//           .foregroundColor(.white)
//           .cornerRadius(8)
//         }
//         .padding()
//       }
//       .coinToast(isPresented: $showToast, coinAmount: coinAmount) {
//         print("Toast animation completed!")
//       }
//     }
//   }

//   return PreviewWrapper()
// }
