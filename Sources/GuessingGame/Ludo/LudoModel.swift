import SwiftUI

// Ludo — 2-player (you vs CPU) or 4-player (you + 3 CPU).
// Roll 6 to leave base. Captures send tokens home. Safe squares are starred.
// Exact roll to finish; all 4 tokens home wins. Extra roll on 6 or capture.

final class LudoModel: ObservableObject {

    enum Side: String, CaseIterable {
        case you, cpu1, cpu2, cpu3

        var isHuman: Bool { self == .you }

        var displayName: String {
            switch self {
            case .you: return "You"
            case .cpu1: return "CPU"
            case .cpu2: return "CPU 2"
            case .cpu3: return "CPU 3"
            }
        }
    }

    /// 52-cell loop as (row, col) on a 15x15 board, clockwise from red start.
    static let mainPath: [(r: Int, c: Int)] = [
        (6,1),(6,2),(6,3),(6,4),(6,5),
        (5,6),(4,6),(3,6),(2,6),(1,6),(0,6),
        (0,7),(0,8),
        (1,8),(2,8),(3,8),(4,8),(5,8),
        (6,9),(6,10),(6,11),(6,12),(6,13),(6,14),
        (7,14),(8,14),
        (8,13),(8,12),(8,11),(8,10),(8,9),
        (9,8),(10,8),(11,8),(12,8),(13,8),(14,8),
        (14,7),(14,6),
        (13,6),(12,6),(11,6),(10,6),(9,6),
        (8,5),(8,4),(8,3),(8,2),(8,1),(8,0),
        (7,0),(6,0),
    ]
    static let startIndex: [Side: Int] = [.you: 0, .cpu1: 26, .cpu2: 13, .cpu3: 39]
    static let safe: Set<Int> = [0, 8, 13, 21, 26, 34, 39, 47]
    static let homeStretch: [Side: [(r: Int, c: Int)]] = [
        .you: [(7,1),(7,2),(7,3),(7,4),(7,5)],
        .cpu1: [(7,13),(7,12),(7,11),(7,10),(7,9)],
        .cpu2: [(1,7),(2,7),(3,7),(4,7),(5,7)],
        .cpu3: [(13,7),(12,7),(11,7),(10,7),(9,7)],
    ]

    /// Token progress per side: -1 = base, 0...50 = main loop,
    /// 51...55 = home stretch, 56 = finished.
    @Published var tokens: [Side: [Int]] = [
        .you: [-1, -1, -1, -1],
        .cpu1: [-1, -1, -1, -1],
        .cpu2: [-1, -1, -1, -1],
        .cpu3: [-1, -1, -1, -1],
    ]
    /// false = you vs CPU, true = you + 3 CPU.
    @Published var fourPlayer = false
    /// Shortens CPU turn delays for a snappier game.
    @Published var fastCPU = false
    @Published var turn: Side = .you
    @Published var diceValue = 1
    @Published var rolling = false
    /// Token indices the human may move right now (highlighted, tappable).
    @Published var movable: [Int] = []
    @Published var winner: Side? = nil
    @Published var message = "Your turn — tap the dice."
    @Published var youWins = 0
    @Published var cpuWins = 0

    private var lastRoll = 1
    /// Bumps on every newGame(); stale delayed callbacks bail when it mismatches.
    private var generation = 0

    /// Sides currently in play, in turn order.
    var activeSides: [Side] {
        fourPlayer ? [.you, .cpu1, .cpu2, .cpu3] : [.you, .cpu1]
    }

    init() {
        youWins = UserDefaults.standard.integer(forKey: "gg3-ludo-youwins")
        cpuWins = UserDefaults.standard.integer(forKey: "gg3-ludo-cpuwins")
    }

    func newGame() {
        generation += 1
        for side in Side.allCases { tokens[side] = [-1, -1, -1, -1] }
        turn = .you
        diceValue = 1
        rolling = false
        movable = []
        winner = nil
        message = "Your turn — tap the dice."
    }

    func resetForNewGameCommand() { newGame() }

    /// Board cell for a token, or nil when in base / finished.
    func boardCell(side: Side, steps: Int) -> (r: Int, c: Int)? {
        guard steps >= 0 && steps <= 55 else { return nil }
        if steps <= 50 {
            let p = Self.mainPath[(Self.startIndex[side]! + steps) % 52]
            return (p.r, p.c)
        }
        let h = Self.homeStretch[side]![steps - 51]
        return (h.r, h.c)
    }

    // MARK: - Dice

    var diceEnabled: Bool {
        turn == .you && !rolling && movable.isEmpty && winner == nil
    }

    func rollDice() {
        guard diceEnabled else { return }
        startRoll(for: .you)
    }

    /// CPU pacing: scaled down when the fast-CPU toggle is on.
    private func cpuPause(_ full: TimeInterval) -> TimeInterval {
        fastCPU ? max(0.25, full * 0.35) : full
    }

    private func startRoll(for side: Side) {
        rolling = true
        movable = []
        message = side.isHuman ? "Rolling…" : "\(side.displayName) is rolling…"
        SoundFX.shared.play(.dice)
        let gen = generation
        let delay = side.isHuman ? 0.7 : cpuPause(0.7)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self, gen == self.generation else { return }
            self.rolling = false
            let roll = Int.random(in: 1...6)
            self.lastRoll = roll
            self.diceValue = roll
            self.resolveRoll(side: side, roll: roll)
        }
    }

    private func resolveRoll(side: Side, roll: Int) {
        let options = movableTokens(side: side, roll: roll)
        if options.isEmpty {
            let who = side.isHuman ? "You rolled \(roll)" : "\(side.displayName) rolled \(roll)"
            message = who + " — no moves."
            let gen = generation
            let delay = side.isHuman ? 1.1 : cpuPause(1.1)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self, gen == self.generation else { return }
                self.nextTurn(after: side, extraRoll: false)
            }
            return
        }
        if side.isHuman {
            movable = options
            if options.count == 1 {
                // Only one legal move — highlight it briefly, then play it.
                let gen = generation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { [weak self] in
                    guard let self, gen == self.generation else { return }
                    self.tapToken(options[0])
                }
            } else {
                message = "You rolled \(roll) — pick a glowing token."
            }
        } else {
            let pick = cpuChoose(side: side, roll: roll, options: options)
            message = "\(side.displayName) rolled \(roll)."
            let gen = generation
            DispatchQueue.main.asyncAfter(deadline: .now() + cpuPause(0.8)) { [weak self] in
                guard let self, gen == self.generation else { return }
                self.applyMove(side: side, index: pick, roll: roll)
            }
        }
    }

    // MARK: - Moves

    func tapToken(_ index: Int) {
        guard turn == .you, movable.contains(index), winner == nil else { return }
        SoundFX.shared.play(.tap)
        movable = []
        applyMove(side: .you, index: index, roll: lastRoll)
    }

    private func movableTokens(side: Side, roll: Int) -> [Int] {
        let t = tokens[side]!
        var result: [Int] = []
        for (i, s) in t.enumerated() {
            if s == -1 {
                if roll == 6 { result.append(i) }
            } else if s < 56, s + roll <= 56 {
                result.append(i)
            }
        }
        return result
    }

    private func applyMove(side: Side, index: Int, roll: Int) {
        if side.isHuman { movable = [] }
        var t = tokens[side]!
        let s = t[index]
        let ns = (s == -1) ? 0 : s + roll
        t[index] = ns

        var captured = false
        if ns <= 50 {
            let mainIdx = (Self.startIndex[side]! + ns) % 52
            if !Self.safe.contains(mainIdx) {
                for opp in activeSides where opp != side {
                    var ot = tokens[opp]!
                    var hit = false
                    for (j, os) in ot.enumerated()
                    where os >= 0 && os <= 50 && (Self.startIndex[opp]! + os) % 52 == mainIdx {
                        ot[j] = -1
                        captured = true
                        hit = true
                    }
                    if hit { tokens[opp] = ot }
                }
            }
        }
        tokens[side] = t

        if t.allSatisfy({ $0 == 56 }) {
            winner = side
            message = side.isHuman ? "YOU WIN! 🏆" : "\(side.displayName) wins this one."
            recordWin(side)
            SoundFX.shared.play(side.isHuman ? .win : .lose)
            return
        }

        var bits: [String] = []
        if s == -1 { bits.append("Token out!") }
        if captured { bits.append("Capture! ⚔️") }
        if ns == 56 { bits.append("Token home! 🏠") }
        let who = side.isHuman ? "You moved. " : "\(side.displayName) moved. "
        message = (who + bits.joined(separator: " "))
            .trimmingCharacters(in: .whitespaces)

        nextTurn(after: side, extraRoll: roll == 6 || captured)
    }

    private func nextTurn(after side: Side, extraRoll: Bool) {
        guard winner == nil else { return }
        if extraRoll {
            if side.isHuman {
                message += " Rolled \(lastRoll) — go again!"
                turn = .you
            } else {
                message += " \(side.displayName) rolls again."
                let gen = generation
                DispatchQueue.main.asyncAfter(deadline: .now() + cpuPause(1.0)) { [weak self] in
                    guard let self, gen == self.generation, self.winner == nil else { return }
                    self.startRoll(for: side)
                }
            }
            return
        }
        let order = activeSides
        let next = order[(order.firstIndex(of: side)! + 1) % order.count]
        if next.isHuman {
            turn = .you
            message = "Your turn — tap the dice."
        } else {
            turn = next
            let gen = generation
            DispatchQueue.main.asyncAfter(deadline: .now() + cpuPause(1.0)) { [weak self] in
                guard let self, gen == self.generation, self.winner == nil else { return }
                self.startRoll(for: next)
            }
        }
    }

    // MARK: - CPU brain

    private func cpuChoose(side: Side, roll: Int, options: [Int]) -> Int {
        let t = tokens[side]!
        for i in options where moveCaptures(side: side, index: i, roll: roll) { return i }
        if roll == 6, let i = options.first(where: { t[$0] == -1 }) { return i }
        if let i = options.first(where: { t[$0] + roll == 56 }) { return i }
        return options.max(by: { t[$0] < t[$1] }) ?? options[0]
    }

    private func moveCaptures(side: Side, index: Int, roll: Int) -> Bool {
        let t = tokens[side]!
        let s = t[index]
        let ns = (s == -1) ? 0 : s + roll
        guard ns <= 50 else { return false }
        let mainIdx = (Self.startIndex[side]! + ns) % 52
        guard !Self.safe.contains(mainIdx) else { return false }
        return activeSides.contains { opp in
            opp != side && tokens[opp]!.contains { os in
                os >= 0 && os <= 50 && (Self.startIndex[opp]! + os) % 52 == mainIdx
            }
        }
    }

    private func recordWin(_ side: Side) {
        if side.isHuman {
            youWins += 1
            UserDefaults.standard.set(youWins, forKey: "gg3-ludo-youwins")
        } else {
            cpuWins += 1
            UserDefaults.standard.set(cpuWins, forKey: "gg3-ludo-cpuwins")
        }
    }
}
