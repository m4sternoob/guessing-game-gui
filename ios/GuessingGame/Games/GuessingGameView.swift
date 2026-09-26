// GuessingGameView.swift
// iOS version of the Guessing Game with native SwiftUI

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
    @State private var winAnimTimer = 0.0
    
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
        ZStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Guessing Game")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: onFlip) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Flip")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(red: 0.15, green: 0.18, blue: 0.23))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 8)
                
                Text("Guess the secret number")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.6, green: 0.65, blue: 0.72))
                    .padding(.bottom, 16)
                
                Divider()
                    .background(Color(red: 0.2, green: 0.22, blue: 0.28))
                    .padding(.horizontal, 24)
                
                ScrollView {
                    VStack(spacing: 24) {
                        if !gameStarted {
                            // Setup phase
                            setupView
                        } else if !gameWon {
                            // Playing phase
                            playingView
                        } else {
                            // Won state
                            wonView
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }
            }
            
            // Confetti overlay
            if showWinConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
        .onChange(of: gameWon) { won in
            if won {
                triggerConfetti()
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
            
            HStack(spacing: 16) {
                // Min input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Min")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.55, green: 0.6, blue: 0.68))
                    TextField("1", text: $minRange)
                        .keyboardType(.numberPad)
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(16)
                        .background(Color(red: 0.1, green: 0.12, blue: 0.16))
                        .cornerRadius(12)
                        .onReceive(Just(minRange)) { newValue in
                            minRange = newValue.filter { $0.isNumber }
                        }
                }
                
                // Max input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Max")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.55, green: 0.6, blue: 0.68))
                    TextField("100", text: $maxRange)
                        .keyboardType(.numberPad)
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(16)
                        .background(Color(red: 0.1, green: 0.12, blue: 0.16))
                        .cornerRadius(12)
                        .onReceive(Just(maxRange)) { newValue in
                            maxRange = newValue.filter { $0.isNumber }
                        }
                }
            }
            
            Button(action: startGame) {
                Text("Start Game")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color(red: 0.2, green: 0.5, blue: 1.0))
                    .cornerRadius(16)
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
    
    // MARK: - Playing View
    private var playingView: some View {
        VStack(spacing: 20) {
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
            
            // Message
            Text(message)
                .font(.body)
                .foregroundColor(messageColor)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .animation(.easeInOut(duration: 0.2), value: message)
            
            Divider()
                .background(Color(red: 0.2, green: 0.22, blue: 0.28))
            
            // Guess input
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Guess")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    TextField("Enter number", text: $guess)
                        .keyboardType(.numberPad)
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(20)
                        .background(Color(red: 0.1, green: 0.12, blue: 0.16))
                        .cornerRadius(14)
                        .onReceive(Just(guess)) { newValue in
                            guess = newValue.filter { $0.isNumber }
                        }
                        .onSubmit { submitGuess() }
                    
                    Button(action: submitGuess) {
                        Text("Guess")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 18)
                            .background(Color(red: 0.2, green: 0.5, blue: 1.0))
                            .cornerRadius(14)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(guess.isEmpty)
                }
            }
            
            // Quick picks
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Picks")
                    .font(.headline)
                    .foregroundColor(.white)
                
                let minVal = Int(minRange) ?? 1
                let maxVal = Int(maxRange) ?? 100
                let mid = (minVal + maxVal) / 2
                let q1 = (minVal + mid) / 2
                let q3 = (mid + maxVal) / 2
                
                HStack(spacing: 8) {
                    quickPickButton("Min", minVal)
                    quickPickButton("25%", q1)
                    quickPickButton("50%", mid)
                    quickPickButton("75%", q3)
                    quickPickButton("Max", maxVal)
                }
            }
            
            // History
            if !guessHistory.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("History (\(guessHistory.count))")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.6, green: 0.65, blue: 0.72))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(guessHistory.reversed()) { entry in
                                HistoryEntryView(entry: entry)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }
    
    // MARK: - Won View
    private var wonView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("YOU WON!")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.4, green: 0.95, blue: 0.4))
            
            Text("The number was \(secretNumber)")
                .font(.title2)
                .foregroundColor(Color(red: 0.8, green: 0.85, blue: 0.9))
            
            Text("Guessed in \(attempts) attempt\(attempts == 1 ? "" : "s")!")
                .font(.title3)
                .foregroundColor(Color(red: 0.8, green: 0.85, blue: 0.9))
            
            Divider()
                .background(Color(red: 0.2, green: 0.22, blue: 0.28))
            
            Button(action: { resetGame() }) {
                Text("Play Again")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color(red: 0.18, green: 0.65, blue: 0.3))
                    .cornerRadius(16)
            }
            .buttonStyle(ScaleButtonStyle())
            
            Button(action: { resetGame(); gameStarted = false }) {
                Text("New Range")
                    .font(.title3.bold())
                    .foregroundColor(Color(red: 0.8, green: 0.85, blue: 0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.15, green: 0.18, blue: 0.23))
                    .cornerRadius(14)
            }
            .buttonStyle(ScaleButtonStyle())
            
            Spacer()
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
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(red: 0.12, green: 0.14, blue: 0.18))
                .cornerRadius(12)
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
            message = "Guess must be between \(minVal) and \(maxVal)!"
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
        winAnimTimer = 0
        // Hide confetti after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showWinConfetti = false
        }
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
        VStack(spacing: 4) {
            Text("#\(entry.attemptNumber)")
                .font(.caption)
                .foregroundColor(Color(red: 0.55, green: 0.6, blue: 0.68))
            Text("\(entry.value)\(indicator)")
                .font(.title2.bold())
                .foregroundColor(color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 0.1, green: 0.12, blue: 0.16))
        .cornerRadius(12)
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

// Confetti view
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
                        .frame(width: particle.scale * 12, height: particle.scale * 8)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onAppear {
                // Emit particles from center
                let centerX = geometry.size.width / 2
                let centerY = geometry.size.height / 2
                
                for i in 0..<80 {
                    let angle = Double(i) / 80.0 * 2 * .pi
                    let speed = CGFloat.random(in: 200...500)
                    let particle = ConfettiParticle(
                        x: centerX,
                        y: centerY,
                        rotation: Double.random(in: 0...360),
                        scale: CGFloat.random(in: 0.5...1.5),
                        color: colors.randomElement()!,
                        velocityX: cos(angle) * speed,
                        velocityY: sin(angle) * speed - 200
                    )
                    particles.append(particle)
                }
                
                // Animate
                animateParticles(geometry: geometry)
            }
        }
    }
    
    private func animateParticles(geometry: GeometryProxy) {
        Timer.scheduledTimer(withTimeInterval: 1/60.0, repeats: true) { timer in
            for i in particles.indices {
                particles[i].x += particles[i].velocityX / 60.0
                particles[i].y += particles[i].velocityY / 60.0
                particles[i].velocityY += 400 / 60.0 // gravity
                particles[i].rotation += Double.random(in: -10...10)
            }
            
            // Remove off-screen
            particles.removeAll { $0.y > geometry.size.height + 100 }
            
            if particles.isEmpty {
                timer.invalidate()
            }
        }
    }
}