// GuessingGameView.swift
// iOS version of the Guessing Game - iPhone 15 Portrait Optimized

import SwiftUI
import Combine

struct GuessingGameView: View {
    let onFlip: () -> Void
    
    @State private var minRange = "1"
    @State private var maxRange = "100"
    @State private var guess = ""
    @State private var gameStarted = false
    @State private var gameWon = false
    @State private var secretNumber = 0
    @State private var attempts = 0
    @State private var message = "Welcome! Set range and tap 'Start Game'"
    @State private var guessHistory: [GuessEntry] = []
    @State private var showWinConfetti = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // iPhone 15 screen dimensions
    private let screenWidth = UIScreen.main.bounds.width   // 393
    private let screenHeight = UIScreen.main.bounds.height // 852
    private let safeAreaTop: CGFloat = 59
    private let safeAreaBottom: CGFloat = 34
    
    struct GuessEntry: Identifiable {
        let id = UUID()
        let value: Int
        let result: Result
        let attemptNumber: Int
        
        enum Result {
            case low, high, correct
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background - full screen
                Color(red: 0.05, green: 0.06, blue: 0.09)
                    .ignoresSafeArea()
                
                // Subtle grid pattern
                GridBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with safe area
                    HStack {
                        Text("Guessing Game")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: onFlip) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Flip")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(red: 0.15, green: 0.18, blue: 0.23))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, safeAreaTop + 8)
                    .padding(.bottom, 8)
                    
                    Text("Guess the secret number")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.6, green: 0.65, blue: 0.72))
                        .padding(.bottom, 12)
                    
                    Divider()
                        .background(Color(red: 0.2, green: 0.22, blue: 0.28))
                        .padding(.horizontal, 20)
                    
                    // Main content - ScrollView for safety
                    ScrollView {
                        VStack(spacing: 20) {
                            if !gameStarted {
                                setupView
                            } else if !gameWon {
                                playingView
                            } else {
                                wonView
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, safeAreaBottom + 20)
                    }
                    .frame(maxHeight: geometry.size.height - safeAreaTop - safeAreaBottom - 100)
                    
                    // Error toast
                    if showError {
                        ErrorToast(message: errorMessage) {
                            withAnimation { showError = false }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                
                // Confetti overlay
                if showWinConfetti {
                    ConfettiView()
                        .allowsHitTesting(false)
                        .ignoresSafeArea()
                }
            }
            .onChange(of: gameWon) { won in
                if won {
                    triggerConfetti()
                }
            }
        }
    }
    
    // MARK: - Setup View
    private var setupView: some View {
        VStack(spacing: 20) {
            Text("Range")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                // Min input
                VStack(alignment: .leading, spacing: 6) {
                    Text("Min")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.55, green: 0.6, blue: 0.68))
                    TextField("1", text: $minRange)
                        .keyboardType(.numberPad)
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(14)
                        .background(Color(red: 0.1, green: 0.12, blue: 0.16))
                        .cornerRadius(10)
                        .onReceive(Just(minRange)) { newValue in
                            minRange = newValue.filter { $0.isNumber }
                        }
                }
                
                // Max input
                VStack(alignment: .leading, spacing: 6) {
                    Text("Max")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.55, green: 0.6, blue: 0.68))
                    TextField("100", text: $maxRange)
                        .keyboardType(.numberPad)
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(14)
                        .background(Color(red: 0.1, green: 0.12, blue: 0.16))
                        .cornerRadius(10)
                        .onReceive(Just(maxRange)) { newValue in
                            maxRange = newValue.filter { $0.isNumber }
                        }
                }
            }
            
            Button(action: startGame) {
                Text("Start Game")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color(red: 0.2, green: 0.5, blue: 1.0))
                    .cornerRadius(14)
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
    
    // MARK: - Playing View
    private var playingView: some View {
        VStack(spacing: 16) {
            // Info bar
            HStack {
                Text("Range: \(minRange) – \(maxRange)")
                Spacer()
                Text("Attempts: \(attempts)")
            }
            .font(.subheadline)
            .foregroundColor(Color(red: 0.6, green: 0.65, blue: 0.72))
            
            Divider()
                .background(Color(red: 0.2, green: 0.22, blue: 0.28))
            
            // Message with proper wrapping
            Text(message)
                .font(.body)
                .foregroundColor(messageColor)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)
                .animation(.easeInOut(duration: 0.2), value: message)
            
            Divider()
                .background(Color(red: 0.2, green: 0.22, blue: 0.28))
            
            // Guess input
            VStack(alignment: .leading, spacing: 10) {
                Text("Your Guess")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 10) {
                    TextField("Enter number", text: $guess)
                        .keyboardType(.numberPad)
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(16)
                        .background(Color(red: 0.1, green: 0.12, blue: 0.16))
                        .cornerRadius(12)
                        .onReceive(Just(guess)) { newValue in
                            guess = newValue.filter { $0.isNumber }
                        }
                        .onSubmit { submitGuess() }
                    
                    Button(action: submitGuess) {
                        Text("Guess")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.2, green: 0.5, blue: 1.0))
                            .cornerRadius(12)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(guess.isEmpty)
                }
            }
            
            // Quick picks
            VStack(alignment: .leading, spacing: 10) {
                Text("Quick Picks")
                    .font(.headline)
                    .foregroundColor(.white)
                
                let minVal = Int(minRange) ?? 1
                let maxVal = Int(maxRange) ?? 100
                let mid = (minVal + maxVal) / 2
                let q1 = (minVal + mid) / 2
                let q3 = (mid + maxVal) / 2
                
                HStack(spacing: 6) {
                    quickPickButton("Min", minVal)
                    quickPickButton("25%", q1)
                    quickPickButton("50%", mid)
                    quickPickButton("75%", q3)
                    quickPickButton("Max", maxVal)
                }
            }
            
            // History
            if !guessHistory.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("History (\(guessHistory.count))")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.6, green: 0.65, blue: 0.72))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(guessHistory.reversed()) { entry in
                                HistoryEntryView(entry: entry)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
        }
    }
    
    // MARK: - Won View
    private var wonView: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 40)
            
            Text("YOU WON!")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.4, green: 0.95, blue: 0.4))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            
            Text("The number was \(secretNumber)")
                .font(.title3)
                .foregroundColor(Color(red: 0.8, green: 0.85, blue: 0.9))
            
            Text("Guessed in \(attempts) attempt\(attempts == 1 ? "" : "s")!")
                .font(.title3)
                .foregroundColor(Color(red: 0.8, green: 0.85, blue: 0.9))
            
            Divider()
                .background(Color(red: 0.2, green: 0.22, blue: 0.28))
            
            Button(action: { resetGame() }) {
                Text("Play Again")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color(red: 0.18, green: 0.65, blue: 0.3))
                    .cornerRadius(14)
            }
            .buttonStyle(ScaleButtonStyle())
            
            Button(action: { resetGame(); gameStarted = false }) {
                Text("New Range")
                    .font(.headline)
                    .foregroundColor(Color(red: 0.8, green: 0.85, blue: 0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.15, green: 0.18, blue: 0.23))
                    .cornerRadius(12)
            }
            .buttonStyle(ScaleButtonStyle())
            
            Spacer(minLength: 40)
        }
    }
    
    // MARK: - Helpers
    private var messageColor: Color {
        if message.contains("low") { return Color(red: 1.0, green: 0.75, blue: 0.3) }
        if message.contains("high") { return Color(red: 1.0, green: 0.45, blue: 0.45) }
        if message.contains("must be") { return Color(red: 1.0, green: 0.35, blue: 0.35) }
        if gameWon { return Color(red: 0.4, green: 0.95, blue: 0.4) }
        return .white
    }
    
    private func quickPickButton(_ label: String, _ value: Int) -> some View {
        Button(action: { guess = "\(value)"; submitGuess() }) {
            Text(label)
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(red: 0.12, green: 0.14, blue: 0.18))
                .cornerRadius(10)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func startGame() {
        let minVal = max(1, Int(minRange) ?? 1)
        let maxVal = max(minVal + 1, Int(maxRange) ?? 100)
        minRange = "\(minVal)"
        maxRange = "\(maxVal)"
        
        secretNumber = Int.random(in: minVal...maxVal)
        gameStarted = true
        gameWon = false
        attempts = 0
        guess = ""
        guessHistory = []
        message = "Game started! Make your first guess."
    }
    
    private func submitGuess() {
        guard !guess.isEmpty, gameStarted, !gameWon else { return }
        let val = Int(guess) ?? 0
        let minVal = Int(minRange) ?? 1
        let maxVal = Int(maxRange) ?? 100
        
        if val < minVal || val > maxVal {
            showError("Guess must be between \(minVal) and \(maxVal)!")
            return
        }
        
        attempts += 1
        
        if val == secretNumber {
            gameWon = true
            message = "You won! The number was \(secretNumber) in \(attempts) attempts!"
            let entry = GuessEntry(value: val, result: .correct, attemptNumber: attempts)
            guessHistory.append(entry)
        } else if val < secretNumber {
            message = "Too low! Try higher."
            let entry = GuessEntry(value: val, result: .low, attemptNumber: attempts)
            guessHistory.append(entry)
        } else {
            message = "Too high! Try lower."
            let entry = GuessEntry(value: val, result: .high, attemptNumber: attempts)
            guessHistory.append(entry)
        }
        
        guess = ""
    }
    
    private func resetGame() {
        gameStarted = false
        gameWon = false
        secretNumber = 0
        attempts = 0
        guess = ""
        guessHistory = []
        message = "Welcome! Set range and tap 'Start Game'"
    }
    
    private func triggerConfetti() {
        showWinConfetti = true
        // Hide confetti after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showWinConfetti = false
        }
    }
    
    private func showError(_ msg: String) {
        errorMessage = msg
        withAnimation(.spring()) { showError = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { showError = false }
        }
    }
}

// Error toast view
struct ErrorToast: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(14)
        .background(Color(red: 0.18, green: 0.12, blue: 0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.5), lineWidth: 1)
        )
    }
}

// History entry view
struct HistoryEntryView: View {
    let entry: GuessingGameView.GuessEntry
    
    var color: Color {
        switch entry.result {
        case .low: return Color(red: 1.0, green: 0.75, blue: 0.3)
        case .high: return Color(red: 1.0, green: 0.45, blue: 0.45)
        case .correct: return Color(red: 0.4, green: 0.95, blue: 0.4)
        }
    }
    
    var indicator: String {
        switch entry.result {
        case .low: return " ^"
        case .high: return " v"
        case .correct: return " *"
        }
    }
    
    var body: some View {
        VStack(spacing: 3) {
            Text("#\(entry.attemptNumber)")
                .font(.caption2)
                .foregroundColor(Color(red: 0.55, green: 0.6, blue: 0.68))
            Text("\(entry.value)\(indicator)")
                .font(.title3.bold())
                .foregroundColor(color)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(red: 0.1, green: 0.12, blue: 0.16))
        .cornerRadius(10)
    }
}

// Scale button style for tactile feedback
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Confetti view - optimized for iPhone 15
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    struct ConfettiParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var rotation: Double
        var scale: CGFloat
        var color: Color
        var velocityX: CGFloat
        var velocityY: CGFloat
    }
    
    let colors = [
        Color(red: 1.0, green: 0.3, blue: 0.3),
        Color(red: 0.3, green: 1.0, blue: 0.3),
        Color(red: 0.3, green: 0.5, blue: 1.0),
        Color(red: 1.0, green: 0.8, blue: 0.2),
        Color(red: 1.0, green: 0.4, blue: 1.0),
        Color(red: 0.2, green: 1.0, blue: 1.0),
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(particle.color)
                        .frame(width: particle.scale * 10, height: particle.scale * 6)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onAppear {
                let centerX = geometry.size.width / 2
                let centerY = geometry.size.height / 2
                
                for i in 0..<60 {
                    let angle = Double(i) / 60.0 * 2 * .pi
                    let speed = CGFloat.random(in: 150...350)
                    let particle = ConfettiParticle(
                        x: centerX,
                        y: centerY,
                        rotation: Double.random(in: 0...360),
                        scale: CGFloat.random(in: 0.5...1.2),
                        color: colors.randomElement()!,
                        velocityX: cos(angle) * speed,
                        velocityY: sin(angle) * speed - 150
                    )
                    particles.append(particle)
                }
                
                animateParticles(geometry: geometry)
            }
        }
    }
    
    private func animateParticles(geometry: GeometryProxy) {
        Timer.scheduledTimer(withTimeInterval: 1/60.0, repeats: true) { timer in
            for i in particles.indices {
                particles[i].x += particles[i].velocityX / 60.0
                particles[i].y += particles[i].velocityY / 60.0
                particles[i].velocityY += 300 / 60.0 // gravity
                particles[i].rotation += Double.random(in: -8...8)
            }
            
            particles.removeAll { $0.y > geometry.size.height + 80 }
            
            if particles.isEmpty {
                timer.invalidate()
            }
        }
    }
}

// Grid background
struct GridBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let spacing: CGFloat = 50
                let color = Color(red: 0.11, green: 0.125, blue: 0.165)
                
                var x: CGFloat = 0
                while x <= size.width {
                    context.stroke(
                        Path { p in
                            p.move(to: CGPoint(x: x, y: 0))
                            p.addLine(to: CGPoint(x: x, y: size.height))
                        },
                        with: .color(color),
                        lineWidth: 0.5
                    )
                    x += spacing
                }
                
                var y: CGFloat = 0
                while y <= size.height {
                    context.stroke(
                        Path { p in
                            p.move(to: CGPoint(x: 0, y: y))
                            p.addLine(to: CGPoint(x: size.width, y: y))
                        },
                        with: .color(color),
                        lineWidth: 0.5
                    )
                    y += spacing
                }
            }
        }
    }
}