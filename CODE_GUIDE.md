# 5IN1 Code Guide

Five games, one native macOS app (SwiftUI, macOS 14+, arm64). No third-party
dependencies — everything is SwiftUI + AppKit.

## Layout

```
Sources/GuessingGame/
  GuessingGameApp.swift        # @main — single WindowGroup, GameCoordinator env object
  ContentView.swift            # Toolbar game switcher + five game views
  GameCoordinator.swift        # Relays ⌘N (new game) to the active game view
  Components/
    Theme.swift                # Dark-theme palette (surfaces, text, good/bad…)
    Components.swift           # StatPill, ScaleButtonStyle, WinConfetti
    ConfettiView.swift         # Win confetti overlay (timer cleaned up on disappear)
    DiceView.swift             # Animated d6, tap-to-roll
    SoundFX.swift              # System-sound FX singleton, global mute toggle
  Guessing/  Snake/  SnakesLadders/  Ludo/  TicTacToe/
    <Game>Model.swift          # @Published state + rules (UI-agnostic)
    <Game>View.swift            # Layout + Canvas drawing, observes its model
```

## State flow

Each game follows the same pattern:

- **Model** (`ObservableObject`): owns the rules. Game logic runs on
  `@Published` properties; the only UI coupling is `SoundFX.shared.play(...)`
  and (in turn-based games) a `DispatchQueue.main.asyncAfter` chain for CPU
  pacing. Delayed callbacks carry a `generation` counter — `newGame()` bumps
  it, stale callbacks bail. (Tic-Tac-Toe and Ludo use this; the guessing game
  has no delayed callbacks.)
- **View**: a `@StateObject` model + `@EnvironmentObject coordinator`.
  Reacts to `coordinator.newGameID` with `.onChange` to reset. Keyboard games
  (Snake) use `.focusable()` + `.onKeyPress`.

Persistent state (best scores, streaks, sound toggle) uses `@AppStorage` with
`gg3-` prefixed keys. Win/loss counters also go through `UserDefaults`
directly for legacy reasons — treat `@AppStorage` as the convention.

## Shared components

| Piece | Where | Used by |
|---|---|---|
| `Theme` (colors, fonts) | Components/Theme.swift | Everything |
| `StatPill` | Components/Components.swift | All games (score/stat chips) |
| `DiceView` | Components/DiceView.swift | Ludo, Snakes & Ladders |
| `ConfettiView` | Components/ConfettiView.swift | Win overlays |
| `SoundFX` | Components/SoundFX.swift | All games (`.play(.tap/.dice/.eat/.win/.lose)`) |

## Where the v3.2 features live

- **Snake pause menu + game-over stats** — `Snake/SnakeGameModel.swift`
  (`togglePause()`, `finalLength`/`finalTime` set in `gameOver()`);
  `Snake/SnakeGameView.swift` (pause overlay card, `runStat` helper,
  `.onKeyPress("p")`).
- **Guessing streaks + daily challenge** — `Guessing/GuessModel.swift`
  (`@AppStorage streak`, `dailyMode`, `SeededRNG` splitmix64,
  `currentAttemptLimit`, `dailySeed` = yyyymmdd); `Guessing/GuessingGameView.swift`
  (daily toggle, streak `StatPill`, streak line on the win card).
- **Ludo 4-player + fast CPU** — `Ludo/LudoModel.swift` (`Side` enum,
  `activeSides`, per-side `startIndex`/`homeStretch`, `fourPlayer`/`fastCPU`,
  `cpuPause()` scaling CPU delays); `Ludo/LudoView.swift` (`color(for:)`,
  `baseOrigin(for:)`, player-count picker, per-side turn dots).
- **Snakes & Ladders 2-player pass-and-play** —
  `SnakesLadders/SnakesLaddersModel.swift` (`twoPlayer`, `sideName(_:)`,
  manual rolling for both sides); `SnakesLadders/SnakesLaddersView.swift`
  (mode picker, P1/P2 turn dots + labels).
- **Tic-Tac-Toe streaks + CPU-thinks** — `TicTacToe/TicTacToeModel.swift`
  (`@AppStorage playerStreak`, `@Published cpuThinking`);
  `TicTacToe/TicTacToeView.swift` (`ThinkingDots`, streak pill).
- **Sound effects** — `Components/SoundFX.swift` (`NSSound(named:)` system
  sounds, off by default via `gg3-sound-enabled`); toolbar toggle in
  `ContentView.swift`.

## CI build

`.github/workflows/build-macos-swift.yml` compiles on macos-15
(`workflow_dispatch`), bundles 5IN1.app, ad-hoc signs, and zips it. There is
no local Swift toolchain on dev machines here — CI is the first real compile,
so treat unbuilt code as unverified: write with extreme API care, verify
brace balance, never claim it runs until CI is green and a human playtests.
