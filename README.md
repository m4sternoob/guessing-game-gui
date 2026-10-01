# GameHub

<div align="center">

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-macOS-blue.svg)
![Platform](https://img.shields.io/badge/Platform-macOS%2014%2B-lightgrey.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![Version](https://img.shields.io/badge/Version-v3.1.0-brightgreen.svg)

**Five games, one native macOS app — built with SwiftUI + SpriteKit, zero dependencies.**

[⬇️ Download](#-download) • [🎮 Games](#-games) • [🔨 Build from source](#-build-from-source)

</div>

---

## What's new in v3.1.0

GameHub grows from two games to **five**: Snakes & Ladders, Ludo (you vs the CPU),
and Tic-Tac-Toe join the Guessing Game and Snake. One window, one toolbar switcher,
shared dark theme, per-game stats saved on your Mac.

v3.0.0 was the full from-scratch native macOS rewrite — the old C++/SDL2 builds are
gone (they live on the `legacy/cpp-sdl2` branch for reference). No bundled dylibs:
pure Swift + SwiftUI, packaged as a normal Mac app.

## 🎮 Games

Switch anytime from the segmented control in the toolbar. `⌘N` starts a new game
in whichever game is active.

### 🎯 Guessing Game
- Difficulties: **Easy** (1–50), **Medium** (1–100), **Hard** (1–500), or **Custom** range
- **Attempt limits** (8 / 10 / 15; Custom is unlimited) — run out and the round is lost
- **Hot/cold proximity meter** (🧊 → 🚀) and a live "possible range" readout that narrows as you guess
- Quick picks (Min / 25% / 50% / 75% / Max), color-coded history (↑ too low, ↓ too high, ✓ correct)
- Best score per difficulty, lifetime games played + average attempts + win rate
- Confetti on win, error toasts, `Return` submits

### 🐍 Snake
- 20×20 grid, gradient body, animated eyes, pulsing food
- **Speed selector** (Chill / Normal / Insane) and a **combo multiplier** for chained quick pickups
- **Wrap-walls mode** toggle, floating score popups, eat particles, death shake
- Speeds up as you eat; high score saved on your Mac
- **Arrow keys or WASD** to steer, `Space` to pause, clickable direction pad

### 🪜 Snakes & Ladders
- Classic 100-square board with ladders, snakes, and exact-roll-to-win
- You (blue) vs the CPU (red) — animated dice, hop-by-hop token movement
- Win/loss record saved on your Mac

### 🎲 Ludo
- Full 15×15 board: bases, safe ★ squares, home stretches, captures
- You (red) vs the CPU (yellow) — roll 6 to leave base, extra rolls on 6s and captures
- Glowing tokens show your legal moves; CPU plays a real strategy (captures first, then racing home)

### ⭕ Tic-Tac-Toe
- You are X, CPU is O — Easy (casual) and Hard (unbeatable minimax) difficulties
- Winning-line highlight, score + draw tracking

## ⬇️ Download

Grab the latest `.zip` from the [**Releases**](https://github.com/m4sternoob/guessing-game-gui/releases) page,
unzip, and open `GameHub.app`. Requires macOS 14 (Sonoma) or later, Apple Silicon or Intel.

> The v3.1.0 release build is being finalized — it will appear on the Releases page once published.

## 🔨 Build from source

You need Xcode 15+ (or just the Xcode command line tools):

```bash
swift build -c release
```

Or open `Package.swift` in Xcode and hit Run.

To make the distributable `.app` exactly like the release (bundle + icon + ad-hoc sign + zip),
trigger the **Build macOS app (Swift)** workflow under the repo's Actions tab.

## 📁 Project structure

```
Package.swift                  # Swift package, macOS 14+, zero dependencies
Sources/GuessingGame/
  GuessingGameApp.swift        # @main entry, window, ⌘N menu command
  ContentView.swift            # 5-game toolbar switcher
  Guessing/
    GuessModel.swift           # state machine + hot/cold proximity + stats
    GuessingGameView.swift     # guessing game UI
  Snake/
    SnakeGameModel.swift       # snake rules (movement, food, wrap mode, speeds, combos)
    SnakeScene.swift           # SpriteKit 60fps renderer + juice (popups, particles)
    SnakeGameView.swift        # snake UI (keyboard + direction pad)
  SnakesLadders/
    SnakesLaddersModel.swift   # board rules, you vs CPU, dice flow
    SnakesLaddersView.swift    # 100-square SwiftUI board
  Ludo/
    LudoModel.swift            # 52-cell loop, captures, safe squares, CPU brain
    LudoView.swift             # 15x15 Canvas board + animated tokens
  TicTacToe/
    TicTacToeModel.swift        # rules + minimax AI
    TicTacToeView.swift        # board UI
  Components/
    Theme.swift                # dark theme, grid bg, confetti, toasts
    DiceView.swift             # animated die shared by the board games
packaging/
  Info.plist                   # bundle metadata used by CI
  generate_icon.py             # draws AppIcon-1024.png at build time (no binary in git)
source/ios/                    # iOS/SwiftUI version (separate target)
```

## 📜 Version history

- **v3.1.0** — five-game GameHub: + Snakes & Ladders, Ludo, Tic-Tac-Toe; guessing hot/cold meter; snake wrap mode + juice
- **v3.0.0** — from-scratch native macOS rewrite (Swift/SwiftUI/SpriteKit)
- **v2.5.x** — C++/SDL2 builds (broken, superseded)
- **v1.0.0 / v2.0.0** — early C++/SDL2 builds (ran on dev machine only)

## 📄 License

MIT — see [LICENSE](LICENSE).
