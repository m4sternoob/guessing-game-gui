# Guessing Game Hub

<div align="center">

![C++](https://img.shields.io/badge/C++-17-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Windows%20%7C%20iOS%20%7C%20Linux-lightgrey.svg)
![GUI](https://img.shields.io/badge/Gui-Desktop%3A%20ImGui%20%2B%20SDL2%20%7C%20iOS%3A%20SwiftUI%20%2B%20SpriteKit-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![Build](https://img.shields.io/badge/Build-CMake%20%7C%20Xcode-orange.svg)
![Version](https://img.shields.io/badge/Version-v2.5.1-brightgreen.svg)

**A cross-platform game hub with two games in one — Guessing Game & Snake — featuring smooth flip-card animations, particle effects, and polished UI. Desktop: C++/ImGui/SDL2. iOS: SwiftUI/SpriteKit.**

[📥 Download Source](#-download-source) • [🍎 macOS Build](#-macos-build) • [🪟 Windows Build](#-windows-build) • [📱 iOS Build](#-ios-build) • [🗺️ Roadmap](#-roadmap)

</div>

---

## 🎮 Overview

A modern game hub with **two games** sharing a flip-card interface:
- **Guessing Game** — Binary-search style number guessing with confetti celebration
- **Snake Game** — Classic 20×20 grid snake with high-score persistence

**Desktop:** C++17 + Dear ImGui + SDL2 (single codebase, macOS/Windows/Linux)  
**iOS:** Swift 5.9 + SwiftUI + SpriteKit (native iPhone 15 portrait)

---

## ✨ Features

### 🔄 Flip-Card Animation (Both Platforms)
- Smooth 3D-style flip between games (600ms, cubic easing)
- Progress bar + fading game names during transition

### 🎯 Guessing Game
- Binary-search strategy with quick-pick buttons (Min/25%/50%/75%/Max)
- Confetti burst on win (desktop: ImGui particles, iOS: SwiftUI Canvas)
- Color-coded history: 🟡 low, 🔴 high, 🟢 correct
- Error validation with toast notifications

### 🐍 Snake Game
- 20×20 grid, gradient body, animated eyes, pulsing food
- Wall/self collision, progressive speed increase
- High-score persistence (UserDefaults on iOS, JSON on desktop)
- Pause/Resume, Restart
- **Desktop:** WASD/Arrows/Gamepad | **iOS:** Swipe gestures

### 🎨 Visual Theme
- **Dark slate/blue palette** — Deep backgrounds (#0D0F14), vibrant accent (#3399FF)
- **Portrait mode** — 720×1280 desktop, native iPhone 15 (393×852) iOS
- **Smaller UI elements** — Compact, information-dense layouts

---

## 📁 Project Structure

```
guessing-game-hub/
├── source/
│   ├── shared/                    # Cross-platform C++ core
│   │   ├── main.cpp               # Desktop entry (ImGui + SDL2)
│   │   ├── snake_game.h           # Snake logic (grid, collision, persistence)
│   │   ├── animation.h            # Flip animation, easing, particles
│   │   ├── imgui/                 # Dear ImGui (vendored)
│   │   │   ├── *.cpp / *.h
│   │   │   └── backends/          # SDL2 + SDLRenderer2
│   │   └── console/               # Original Day 1 foundation
│   │       ├── guessing_game.cpp
│   │       └── CMakeLists.txt
│   ├── macos/                     # macOS-specific
│   │   ├── build_macos.sh         # One-command build
│   │   └── Info.plist             # App bundle metadata
│   ├── windows/                   # Windows-specific
│   │   └── build_windows.bat      # vcpkg + VS2022 build
│   └── ios/                       # iOS (SwiftUI + SpriteKit)
│       ├── GuessingGameApp.swift
│       ├── ContentView.swift      # Flip container
│       ├── Components/
│       │   └── FlipCardView.swift
│       └── Games/
│           ├── GuessingGameView.swift
│           └── SnakeGameView.swift
├── CMakeLists.txt                 # Cross-platform desktop build
├── README.md                      # This file
├── ROADMAP.md                     # Development roadmap
└── .gitignore
```

---

## 📥 Download Source

| Method | Command |
|--------|---------|
| **HTTPS** | `git clone https://github.com/m4sternoob/guessing-game-gui.git` |
| **SSH** | `git clone git@github.com:m4sternoob/guessing-game-gui.git` |
| **ZIP** | [Download main.zip](https://github.com/m4sternoob/guessing-game-gui/archive/refs/heads/main.zip) |
| **GitHub CLI** | `gh repo clone m4sternoob/guessing-game-gui` |

**Repository:** https://github.com/m4sternoob/guessing-game-gui

---

## 🍎 macOS Build

### Pre-built App Bundle (v2.5.1)

| File | Size | SHA256 |
|------|------|--------|
| [`GuessingGame-macOS-v2.5.1.zip`](https://github.com/m4sternoob/guessing-game-gui/releases/download/v2.5.1/GuessingGame-macOS-v2.5.1.zip) | ~1.0 MB | `e45df2ef85d729f517fa83908c4454a80ce4a2e03b468255f5716f4ccfdb7043` |

**Install:**
```bash
unzip GuessingGame-macOS-v2.5.1.zip
open GuessingGame.app
```

**Requirements:** macOS 11+ (Big Sur), Apple Silicon (arm64)

### Build from Source
```bash
# Prerequisites
brew install cmake sdl2

# Build
git clone https://github.com/m4sternoob/guessing-game-gui.git
cd guessing-game-gui
chmod +x source/macos/build_macos.sh
./source/macos/build_macos.sh

# Run
open build/GuessingGame.app
```

---

## 🪟 Windows Build

### Build from Source
```cmd
REM Prerequisites:
REM 1. Visual Studio 2022 with "Desktop development with C++"
REM 2. vcpkg: git clone https://github.com/microsoft/vcpkg && .\vcpkg\bootstrap-vcpkg.bat
REM 3. SDL2: .\vcpkg\vcpkg install sdl2:x64-windows
REM 4. Set VCPKG_ROOT env var to vcpkg directory

git clone https://github.com/m4sternoob/guessing-game-gui.git
cd guessing-game-gui
source\windows\build_windows.bat

REM Output: build\Release\GuessingGame.exe
```

**Requirements:** Windows 10/11 (x64), Visual C++ Redistributable

*Pre-built Windows binary coming in future release (GitHub Actions CI)*

---

## 📱 iOS Build

### Requirements
- **Xcode 15+** (Swift 5.9)
- **iOS 17+** deployment target
- **iPhone 15** (393×852 pt) or compatible

### Setup
```bash
# 1. Clone
git clone https://github.com/m4sternoob/guessing-game-gui.git
cd guessing-game-gui

# 2. Open in Xcode
open source/ios/
```

### Xcode Configuration
1. **Create new project:** iOS App → SwiftUI → Swift
2. **Bundle ID:** `com.yourname.guessinggamehub`
3. **Deployment Target:** iOS 17.0
4. **Supported Orientations:** Portrait only (uncheck Landscape)
5. **Add files:** Drag `source/ios/` contents into Xcode project
6. **Assets.xcassets:** Add AppIcon (all sizes), AccentColor (#3399FF)
7. **Info.plist:** Add `UIRequiresFullScreen = YES`, `UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait`

### Build & Run
- **Simulator:** Select iPhone 15 Pro → ▶️ Run
- **Device:** Connect iPhone → Select device → ▶️ Run
- **TestFlight:** Product → Archive → Distribute App

### iOS-Specific Features
| Feature | Implementation |
|---------|----------------|
| **Portrait Lock** | `UISupportedInterfaceOrientations = Portrait` |
| **Safe Areas** | 59pt top (Dynamic Island), 34pt bottom |
| **Flip Animation** | SwiftUI `.rotation3DEffect` + spring |
| **Snake Controls** | `DragGesture` on SpriteView |
| **Confetti** | `Canvas` + `TimelineView` particles |
| **Haptics** | `UIImpactFeedbackGenerator` on actions |
| **Persistence** | `UserDefaults` for high score |

---

## 🛠️ Tech Stack

| Platform | Language | GUI Framework | Build System |
|----------|----------|---------------|--------------|
| **Desktop** | C++17 | Dear ImGui + SDL2 | CMake 3.16+ |
| **iOS** | Swift 5.9 | SwiftUI + SpriteKit | Xcode 15+ |
| **Shared Logic** | — | Algorithm ports | Manual sync |

---

## 🎯 How to Play

### Guessing Game
1. **Launch** — Portrait window (720×1280 desktop / full screen iOS)
2. **Set Range** — Enter min/max (default 1–100)
3. **Start Game** — Random number generated
4. **Guess** — Type + Enter (desktop) / Keypad (iOS)
5. **Quick Picks** — Min/25%/50%/75%/Max for optimal binary search
6. **Win** — Confetti! Tap "Play Again" or "New Range"

### Snake Game
1. **Flip** — Tap "Flip" button (bottom)
2. **Control** — Desktop: WASD/Arrows | iOS: Swipe on game area
3. **Eat** — Red pulsing food = +10 points, snake grows
4. **Avoid** — Walls and self-collision
5. **Pause** — Space (desktop) / Pause button (iOS)
6. **Restart** — R key / Restart button after game over
7. **Flip Back** — Tap "Flip" to return

---

## 🗺️ Roadmap

| Phase | Target | Status |
|-------|--------|--------|
| **1. Foundation** | Core desktop GUI, guessing game, macOS/Windows build | ✅ v1.0.0 |
| **2. Enhanced Desktop** | Flip animation, Snake game, particles, settings | ✅ v2.0.0 |
| **3. iOS Native** | SwiftUI app, touch controls, TestFlight | ✅ v2.2.0 |
| **4. Platform Polish** | Notarization, NSIS installer, Linux AppImage | 📋 Planned |
| **5. CI/CD** | GitHub Actions (macOS/Windows/Linux/iOS), auto-release | 📋 Planned |

See [ROADMAP.md](ROADMAP.md) for detailed milestones.

---

## 🔗 Links

| Platform | Link |
|----------|------|
| **Repository** | https://github.com/m4sternoob/guessing-game-gui |
| **Releases** | https://github.com/m4sternoob/guessing-game-gui/releases |
| **macOS v2.5.1** | [Download](https://github.com/m4sternoob/guessing-game-gui/releases/download/v2.5.1/GuessingGame-macOS-v2.5.1.zip) |
| **iOS Source** | `source/ios/` |
| **Windows Build** | `source/windows/build_windows.bat` |
| **macOS Build** | `source/macos/build_macos.sh` |

---

## 📄 License

MIT License — free for personal, educational, and commercial use.

```
Copyright (c) 2024 m4sternoob

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

---

<div align="center">

**Built with ❤️ as a cross-platform learning exercise — C++/ImGui desktop + SwiftUI iOS**

*If this helped you learn ImGui/SDL2/CMake or SwiftUI/SpriteKit, consider ⭐ the repo!*

</div>
