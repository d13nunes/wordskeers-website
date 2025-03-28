import SwiftUI

/// An animated toast that shows coins being added to the wallet with confetti effects
struct CoinsToastView: View {
  /// Amount of coins to display
  let coinAmount: Int

  /// Whether the toast is visible
  @Binding var isVisible: Bool

  /// Callback when the animation completes
  var onComplete: (() -> Void)?

  /// Animation states
  @State private var coinsOffset: CGFloat = 200
  @State private var coinsOpacity: Double = 0
  @State private var showConfetti: Bool = false
  @State private var coinScale: CGFloat = 0.5
  @State private var rotationAngle: Double = 0
  @State private var containerOpacity: Double = 0
  @State private var flyingCoins: [FlyingCoin] = []

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        // Flying coins animation
        ForEach(flyingCoins) { coin in
          FlyingCoinView(
            coin: coin,
            targetPosition: CGPoint(
              x: geometry.size.width / 2,
              y: geometry.size.height / 2 + coin.initialOffset
            ))
        }

        VStack {
          Spacer()

          // Toast container
          ZStack {
            // Background
            RoundedRectangle(cornerRadius: 16)
              .fill(Color.black.opacity(0.7))
              .frame(width: 200, height: 70)
              .overlay(
                RoundedRectangle(cornerRadius: 16)
                  .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
              )

            // Coins animation
            HStack(spacing: 12) {
              Image(systemName: "coin.fill")
                .font(.system(size: 30))
                .foregroundStyle(.yellow)
                .rotationEffect(.degrees(rotationAngle))
                .scaleEffect(coinScale)
                .symbolEffect(.bounce, options: .speed(1.5), value: coinScale)

              VStack(alignment: .center) {
                Text("+\(coinAmount)")
                  .font(.title2.bold())
                  .foregroundColor(.white)

                Text("Coins Added")
                  .font(.caption)
                  .foregroundColor(.gray)
              }
            }
          }
          .padding(.bottom, 80)
          .opacity(containerOpacity)
          .offset(y: coinsOffset)

          Spacer()
        }

        // Confetti layer
        if showConfetti {
          ConfettiView()
            .allowsHitTesting(false)
        }
      }
    }
    .ignoresSafeArea()
    .onChange(of: isVisible) { oldValue, newValue in
      print("🎬🎬🎬 CoinsToastView: isVisible changed from \(oldValue) to \(newValue)")
      if newValue {
        startAnimation()
      }
    }
    .onAppear {
      print("🎬🎬🎬 CoinsToastView: onAppear called, isVisible = \(isVisible)")
    }
  }

  /// Generate flying coins
  private func generateFlyingCoins() {
    // Clear existing coins
    flyingCoins = []

    // Determine number of coins to show based on amount (capped at 12)
    let numberOfCoins = min(max(3, coinAmount / 25), 12)

    // Create flying coins with random properties
    for _ in 0..<numberOfCoins {
      let randomX = CGFloat.random(in: 0.2...0.8)
      let randomY = CGFloat.random(in: 0.6...1.0)
      let randomDelay = Double.random(in: 0...0.5)
      let randomDuration = Double.random(in: 0.5...0.9)
      let randomSize = CGFloat.random(in: 20...30)
      let randomRotation = Double.random(in: -45...45)
      let initialOffset = CGFloat.random(in: -20...20)

      flyingCoins.append(
        FlyingCoin(
          id: UUID(),
          startPosition: CGPoint(x: randomX, y: randomY),
          duration: randomDuration,
          delay: randomDelay,
          size: randomSize,
          rotation: randomRotation,
          initialOffset: initialOffset
        ))
    }
  }

  /// Start the animation sequence
  private func startAnimation() {
    print("🎬🎬🎬 CoinsToastView: Starting animation with \(coinAmount) coins")
    // Initial state
    containerOpacity = 0
    coinsOffset = 200
    coinScale = 0.5
    rotationAngle = -30
    showConfetti = false

    // Generate flying coins
    generateFlyingCoins()

    // Animation sequence
    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
      containerOpacity = 1
      coinsOffset = 0
      coinScale = 1
      rotationAngle = 0
    }

    // Show confetti with a slight delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      withAnimation {
        showConfetti = true
      }

      // Play haptic feedback
      let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
      impactFeedback.impactOccurred()

      // Trigger bounce effect for added emphasis
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        coinScale = 1.1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
          coinScale = 1.0
        }
      }
    }

    // Hide after delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
      print("🎬🎬🎬 CoinsToastView: Ending animation")
      withAnimation(.easeOut(duration: 0.5)) {
        containerOpacity = 0
        coinsOffset = -100
      }

      // Clean up
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        print("🎬🎬🎬 CoinsToastView: Animation completed, isVisible = false")
        isVisible = false
        onComplete?()
      }
    }
  }
}

/// Data structure for flying coin animation
struct FlyingCoin: Identifiable {
  let id: UUID
  let startPosition: CGPoint
  let duration: Double
  let delay: Double
  let size: CGFloat
  let rotation: Double
  let initialOffset: CGFloat
}

/// View for a single flying coin
struct FlyingCoinView: View {
  /// Flying coin data
  let coin: FlyingCoin

  /// Target position for the coin to fly towards
  let targetPosition: CGPoint

  /// Animation states
  @State private var position: CGPoint
  @State private var scale: CGFloat = 0
  @State private var opacity: Double = 0
  @State private var rotation: Double = 0

  /// Initialize with coin data
  init(coin: FlyingCoin, targetPosition: CGPoint) {
    self.coin = coin
    self.targetPosition = targetPosition

    // Set initial position
    self._position = State(initialValue: CGPoint.zero)
  }

  var body: some View {
    GeometryReader { geometry in
      Image(systemName: "coin.fill")
        .font(.system(size: coin.size))
        .foregroundStyle(.yellow)
        .position(
          x: position.x * geometry.size.width,
          y: position.y * geometry.size.height
        )
        .rotationEffect(.degrees(rotation))
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
          // Set initial position
          position = coin.startPosition
          rotation = coin.rotation
          scale = 0
          opacity = 0

          // Start animation after delay
          DispatchQueue.main.asyncAfter(deadline: .now() + coin.delay) {
            // Appear animation
            withAnimation(.easeIn(duration: 0.1)) {
              opacity = 1
              scale = 1
            }

            // Fly animation
            withAnimation(
              .easeOut(duration: coin.duration)
                .delay(0.1)
            ) {
              position = CGPoint(
                x: targetPosition.x / geometry.size.width,
                y: targetPosition.y / geometry.size.height
              )
              rotation += Double.random(in: -180...180)
            }

            // Disappear at end
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 + coin.duration) {
              withAnimation(.easeOut(duration: 0.1)) {
                scale = 0
                opacity = 0
              }
            }
          }
        }
    }
  }
}

/// A view that displays confetti particles
struct ConfettiView: View {
  /// Colors for confetti particles
  private let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]

  /// Number of confetti particles
  private let particleCount = 50

  /// Particle animation states
  @State private var particles: [ConfettiParticle] = []

  var body: some View {
    ZStack {
      ForEach(particles) { particle in
        ConfettiParticleView(particle: particle)
      }
    }
    .onAppear {
      generateParticles()
    }
  }

  /// Generate random confetti particles
  private func generateParticles() {
    particles = (0..<particleCount).map { _ in
      let randomX = CGFloat.random(in: 0.3...0.7)
      let randomSize = CGFloat.random(in: 5...12)
      let randomColor = colors.randomElement() ?? .yellow
      let randomRotation = Double.random(in: 0...360)
      let randomRotationSpeed = Double.random(in: 120...360) * (Bool.random() ? 1 : -1)
      let randomSpeed = Double.random(in: 0.8...1.6)
      let randomDelay = Double.random(in: 0...0.5)

      return ConfettiParticle(
        id: UUID(),
        position: .init(x: randomX, y: 0.3),
        size: randomSize,
        color: randomColor,
        rotation: randomRotation,
        rotationSpeed: randomRotationSpeed,
        speed: randomSpeed,
        delay: randomDelay
      )
    }
  }
}

/// Single confetti particle view
struct ConfettiParticleView: View {
  /// Particle data
  let particle: ConfettiParticle

  /// Animation states
  @State private var position: CGPoint = .zero
  @State private var rotation: Double = 0
  @State private var opacity: Double = 0
  @State private var scale: CGFloat = 0.1

  var body: some View {
    GeometryReader { geometry in
      Rectangle()
        .fill(particle.color)
        .frame(width: particle.size, height: particle.size * 0.6)
        .position(
          x: geometry.size.width * position.x,
          y: geometry.size.height * position.y
        )
        .rotationEffect(.degrees(rotation))
        .opacity(opacity)
        .scaleEffect(scale)
        .onAppear {
          position = CGPoint(
            x: particle.position.x,
            y: particle.position.y
          )

          rotation = particle.rotation
          opacity = 0
          scale = 0.1

          // Delay animation start
          DispatchQueue.main.asyncAfter(deadline: .now() + particle.delay) {
            // Fade in
            withAnimation(.easeOut(duration: 0.2)) {
              opacity = 1
              scale = 1
            }

            // Fall animation
            withAnimation(
              .easeOut(duration: 1.5 * particle.speed)
                .delay(particle.delay)
            ) {
              position = CGPoint(
                x: particle.position.x + CGFloat.random(in: -0.1...0.1),
                y: 1.2
              )
            }

            // Rotation animation
            withAnimation(
              .linear(duration: 1.5 * particle.speed)
                .delay(particle.delay)
            ) {
              rotation += particle.rotationSpeed
            }

            // Fade out towards the end
            withAnimation(
              .easeOut(duration: 0.3)
                .delay(particle.delay + 1.2 * particle.speed)
            ) {
              opacity = 0
            }
          }
        }
    }
  }
}

/// Data structure for confetti particle
struct ConfettiParticle: Identifiable {
  let id: UUID
  let position: CGPoint
  let size: CGFloat
  let color: Color
  let rotation: Double
  let rotationSpeed: Double
  let speed: Double
  let delay: Double
}

#Preview {
  struct PreviewWrapper: View {
    @State private var isVisible = false

    var body: some View {
      ZStack {
        Color.gray.opacity(0.3)
          .ignoresSafeArea()

        VStack {
          Spacer()

          Button("Show Toast") {
            isVisible = true
          }
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)

          Spacer().frame(height: 50)
        }

        CoinsToastView(coinAmount: 100, isVisible: $isVisible)
      }
    }
  }

  return PreviewWrapper()
}
