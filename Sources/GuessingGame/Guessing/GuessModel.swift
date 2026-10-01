import SwiftUI
import Combine

// Game logic for the number guessing game. UI-agnostic state machine:
// setup -> playing -> won.

final class GuessModel: ObservableObject {

    enum Phase { case setup, playing, won }
    enum Tone { case neutral, low, high, error, win }

    struct Attempt: Identifiable {
        let id = UUID()
        let value: Int
        let hint: Hint
        let number: Int

        enum Hint { case low, high, correct }
    }

    enum Difficulty: String, CaseIterable, Identifiable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        case custom = "Custom"

        var id: String { rawValue }

        /// Fixed range, or nil for custom.
        var range: (Int, Int)? {
            switch self {
            case .easy: return (1, 50)
            case .medium: return (1, 100)
            case .hard: return (1, 500)
            case .custom: return nil
            }
        }
    }

    @Published var phase: Phase = .setup
    @Published var difficulty: Difficulty = .medium
    @Published var minText = "1"
    @Published var maxText = "100"
    @Published var guessText = ""
    @Published var attempts: [Attempt] = []
    @Published var message = "Pick a difficulty and press Start."
    @Published var tone: Tone = .neutral
    @Published var errorMessage: String? = nil
    @Published var best: Int? = nil
    @Published var isNewBest = false

    private var secret = 0
    private var lower = 1
    private var upper = 100

    var rangeLabel: String { "\(lower)–\(upper)" }

    init() {
        loadBest()
    }

    // MARK: - Setup

    func selectDifficulty(_ d: Difficulty) {
        difficulty = d
        isNewBest = false
        if let r = d.range {
            minText = "\(r.0)"
            maxText = "\(r.1)"
        }
        loadBest()
    }

    func startGame() {
        let lo = max(1, Int(minText) ?? 1)
        let hi = max(lo + 1, Int(maxText) ?? 100)
        lower = lo
        upper = hi
        minText = "\(lo)"
        maxText = "\(hi)"
        secret = Int.random(in: lo...hi)
        attempts = []
        guessText = ""
        errorMessage = nil
        isNewBest = false
        phase = .playing
        message = "I'm thinking of a number between \(lo) and \(hi)."
        tone = .neutral
    }

    // MARK: - Play

    func submitGuess() {
        guard phase == .playing else { return }
        guard let val = Int(guessText), !guessText.isEmpty else {
            showError("Enter a number first.")
            return
        }
        guard val >= lower && val <= upper else {
            showError("Guess must be between \(lower) and \(upper).")
            return
        }

        let n = attempts.count + 1
        if val == secret {
            attempts.append(Attempt(value: val, hint: .correct, number: n))
            phase = .won
            message = "Correct! The number was \(secret)."
            tone = .win
            if best == nil || n < best! {
                best = n
                isNewBest = true
                saveBest()
            }
        } else if val < secret {
            attempts.append(Attempt(value: val, hint: .low, number: n))
            message = "\(val) is too low — try higher."
            tone = .low
        } else {
            attempts.append(Attempt(value: val, hint: .high, number: n))
            message = "\(val) is too high — try lower."
            tone = .high
        }
        guessText = ""
    }

    func quickPick(_ value: Int) {
        guard phase == .playing else { return }
        guessText = "\(value)"
        submitGuess()
    }

    var quickPicks: [(String, Int)] {
        let mid = (lower + upper) / 2
        let q1 = (lower + mid) / 2
        let q3 = (mid + upper) / 2
        return [("Min", lower), ("25%", q1), ("50%", mid), ("75%", q3), ("Max", upper)]
    }

    /// ⌘N / Play Again: same range, new secret.
    func playAgain() {
        startGame()
    }

    func backToSetup() {
        phase = .setup
        attempts = []
        guessText = ""
        errorMessage = nil
        isNewBest = false
        message = "Pick a difficulty and press Start."
        tone = .neutral
    }

    func resetForNewGameCommand() {
        if phase == .playing || phase == .won {
            startGame()
        }
    }

    // MARK: - Best score (fewest attempts, per difficulty)

    private var bestKey: String { "gg3-best-\(difficulty.rawValue.lowercased())" }

    private func loadBest() {
        let v = UserDefaults.standard.integer(forKey: bestKey)
        best = v > 0 ? v : nil
    }

    private func saveBest() {
        if let b = best {
            UserDefaults.standard.set(b, forKey: bestKey)
        }
    }

    // MARK: - Errors (auto-dismissing)

    func showError(_ text: String) {
        errorMessage = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            if self?.errorMessage == text {
                self?.errorMessage = nil
            }
        }
    }

    func dismissError() {
        errorMessage = nil
    }
}
