// ContentView.swift
// Main container with flip-card animation between games - iPhone 15 Portrait Optimized

import SwiftUI

struct ContentView: View {
    @State private var currentGame: GameType = .guessing
    @State private var isFlipping = false
    @State private var flipProgress: Double = 0
    @State private var flipDirection: FlipDirection = .toBack
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    enum GameType {
        case guessing
        case snake
    }
    
    enum FlipDirection {
        case toBack, toFront
    }
    
    // iPhone 15 portrait dimensions: 1179 x 2556
    // Safe area: top ~59, bottom ~34
    private var isPortrait: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }
    
    private var cardWidth: CGFloat {
        isPortrait ? UIScreen.main.bounds.width * 0.94 : UIScreen.main.bounds.width * 0.45
    }
    
    private var cardHeight: CGFloat {
        isPortrait ? UIScreen.main.bounds.height * 0.85 : UIScreen.main.bounds.height * 0.9
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background - fixed to screen bounds
                Color(red: 0.05, green: 0.06, blue: 0.09)
                    .ignoresSafeArea()
                
                // Subtle grid pattern background
                GridBackground()
                    .ignoresSafeArea()
                
                // Flip card container - centered with proper constraints
                FlipCardView(
                    isFlipping: $isFlipping,
                    flipProgress: $flipProgress,
                    flipDirection: $flipDirection,
                    frontView: {
                        GuessingGameView(onFlip: { flipToSnake() })
                    },
                    backView: {
                        SnakeGameView(onFlip: { flipToGuessing() })
                    }
                )
                .frame(width: cardWidth, height: cardHeight)
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2
                )
                .clipped()
                
                // Flip progress indicator at top
                if isFlipping {
                    VStack {
                        FlipProgressBar(progress: flipProgress, direction: flipDirection)
                            .frame(width: 280, height: 6)
                            .padding(.top, geometry.safeAreaInsets.top + 20)
                        
                        // Game name transition
                        HStack(spacing: 20) {
                            Text(flipDirection == .toBack ? "Guessing Game" : "Snake Game")
                                .font(.title2.bold())
                                .foregroundColor(.white.opacity(flipDirection == .toBack ? max(0, 1 - flipProgress * 2) : max(0, flipProgress * 2 - 1)))
                                .animation(.easeInOut(duration: 0.3), value: flipProgress)
                            
                            Text(flipDirection == .toBack ? "Snake Game" : "Guessing Game")
                                .font(.title2.bold())
                                .foregroundColor(.white.opacity(flipDirection == .toBack ? max(0, flipProgress * 2 - 1) : max(0, 1 - flipProgress * 2)))
                                .animation(.easeInOut(duration: 0.3), value: flipProgress)
                        }
                        .offset(y: 80)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
        }
        .statusBarHidden(false)
        .preferredColorScheme(.dark)
    }
    
    private func flipToSnake() {
        guard !isFlipping else { return }
        flipDirection = .toBack
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isFlipping = true
            flipProgress = 0
        }
        animateFlipProgress(to: 1.0) {
            currentGame = .snake
            isFlipping = false
        }
    }
    
    private func flipToGuessing() {
        guard !isFlipping else { return }
        flipDirection = .toFront
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isFlipping = true
            flipProgress = 0
        }
        animateFlipProgress(to: 1.0) {
            currentGame = .guessing
            isFlipping = false
        }
    }
    
    private func animateFlipProgress(to target: Double, completion: @escaping () -> Void) {
        let steps = 30
        let stepDuration = 0.6 / Double(steps)
        let increment = target / Double(steps)
        
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                flipProgress = increment * Double(i)
                if i == steps {
                    completion()
                }
            }
        }
    }
}

// Grid background matching desktop version
struct GridBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let spacing: CGFloat = 50
                let color = Color(red: 0.11, green: 0.125, blue: 0.165)
                
                // Vertical lines
                var x: CGFloat = 0
                while x <= size.width {
                    context.stroke(
                        Path { p in
                            p.move(to: CGPoint(x: x, y: 0))
                            p.addLine(to: CGPoint(x: x, y: size.height))
                        },
                        with: .color(color),
                        lineWidth: 1
                    )
                    x += spacing
                }
                
                // Horizontal lines
                var y: CGFloat = 0
                while y <= size.height {
                    context.stroke(
                        Path { p in
                            p.move(to: CGPoint(x: 0, y: y))
                            p.addLine(to: CGPoint(x: size.width, y: y))
                        },
                        with: .color(color),
                        lineWidth: 1
                    )
                    y += spacing
                }
            }
        }
    }
}

// Flip progress bar
struct FlipProgressBar: View {
    let progress: Double
    let direction: ContentView.FlipDirection
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(red: 0.08, green: 0.09, blue: 0.12))
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(red: 0.31, green: 0.63, blue: 1.0))
                    .frame(width: geometry.size.width * progress)
            }
        }
    }
}