# Guessing Game Hub

<div align="center">

![C++](https://img.shields.io/badge/C++-17-blue.svg)
![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Windows%20%7C%20Linux-lightgrey.svg)
![GUI](https://img.shields.io/badge/GUI-Dear%20ImGui%20%2B%20SDL2-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![Build](https://img.shields.io/badge/Build-CMake-orange.svg)
![Version](https://img.shields.io/badge/Version-v2.0.0-brightgreen.svg)

**A modern, cross-platform game hub with two games in one — Guessing Game & Snake — featuring smooth flip-card animations, particle effects, and a polished dark theme. Built with Dear ImGui + SDL2.**

[📥 Download Source](#-download-source) • [🍎 macOS Build](#-macos-build) • [🪟 Windows Build](#-windows-build) • [📱 iOS Version](#-ios-version) • [🗺️ Roadmap](#-roadmap)

</div>

---

## 🎮 Overview

This project evolved from a simple console-based [Day 1 C++ learning exercise](https://github.com/m4sternoob/day1-cpp-game) into a **full-featured desktop game hub** with two games, smooth animations, and professional polish. Built as a showcase of cross-platform C++ GUI development using **Dear ImGui** (immediate-mode GUI, standard in game dev) and **SDL2** (window/renderer/input abstraction).

### Why ImGui + SDL2?

| Aspect | Benefit |
|--------|---------|
| **Lightweight** | ~1.6 MB binary, no heavy runtime dependencies |
| **Game-dev native** | Immediate mode, 60 FPS, no retained widget tree |
| **True cross-platform** | Identical code on macOS, Windows, Linux |
| **Zero boilerplate** | No MFC, Win32, Cocoa, or Qt object hierarchies |
| **Customizable** | Full theming via `ImGuiStyle` |

---

## ✨ Features v2.0.0

### 🔄 Flip-Card Animation
- Smooth 3D-style flip between **Guessing Game** ↔ **Snake Game**
- Progress bar + fading game names during transition
- 600ms duration with cubic easing

### 🎯 Guessing Game (Enhanced)
- **BIG buttons** — 60px height for Start/Guess/Play Again
- **Larger inputs** — Comfortable padding, clear labels
- **Quick picks** — Min/25%/50%/75%/Max for binary-search strategy
- **Win celebration** — Centered animated message + **confetti burst**
- **Color-coded history** — 🟡 low, 🔴 high, 🟢 correct
- **Persistent UI scale** — Adjustable 1.0x–2.5x in Settings

### 🐍 Snake Game (New!)
- **20×20 grid** with smooth 24px cells (auto-scaled)
- **Gradient body** — Bright head, darker tail segments
- **Animated eyes** — Direction-aware on head segment
- **Pulsing food** — Red apple with inner glow animation
- **Full mechanics** — Wall collision, self-collision, growing body
- **Progressive difficulty** — Speed increases every 50 points
- **High score persistence** — Survives app restarts
- **Pause/Resume** — Spacebar or button
- **Controls** — WASD / Arrow Keys / Gamepad

### 🎨 Visual Polish
- **Rich slate/blue theme** — Deep backgrounds, vibrant accent
- **16px window rounding** — 12px child, 10px controls
- **Generous spacing** — Touch-friendly 48px+ targets
- **Particle system** — Gravity-based confetti with fade-out
- **High-DPI/Retina ready** — Integer scaling, crisp at any size

### ⚙️ Technical
- **Delta-time game loop** — Frame-rate independent
- **Renderer recreation** — Handles resize without distortion
- **Config persistence** — JSON in platform-appropriate dir
- **Settings panel** — UI scale slider, auto-save
- **Console version preserved** — Original foundation in `console/`

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

### Pre-built App Bundle (Recommended)

| File | Size | SHA256 |
|------|------|--------|
| [`GuessingGame-macOS-v2.0.0.zip`](https://github.com/m4sternoob/guessing-game-gui/releases/download/v2.0.0/GuessingGame-macOS-v2.0.0.zip) | ~1.6 MB | `61b3f11ad03dd92b716074f017f42ab275c64bbbf6fd1451d320c9f03537f17a` |

**Install:**
```bash
# Download and unzip
unzip GuessingGame-macOS-v2.0.0.zip
# Run directly (no install needed)
open GuessingGame.app
```

**Requirements:** macOS 10.13+ (High Sierra), Apple Silicon or Intel

### Build from Source
```bash
# Prerequisites
brew install cmake sdl2

# Build
git clone https://github.com/m4sternoob/guessing-game-gui.git
cd guessing-game-gui
chmod +x build_macos.sh
./build_macos.sh

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
build_windows.bat

REM Output: build\Release\GuessingGame.exe
```

**Requirements:** Windows 10/11 (x64), Visual C++ Redistributable

*Pre-built Windows binary coming in future release (GitHub Actions CI)*

---

## 📱 iOS Version

**Status:** Planned — separate native Swift/SwiftUI implementation

### Target: `guessing-game-ios` (separate repo)
- **Native iOS** — SwiftUI + SpriteKit
- **Same flip UX** — Tap to flip between games
- **Touch-optimized** — Swipe for snake, keypad for guessing
- **Haptics** — UIImpactFeedbackGenerator for actions
- **Safe areas** — Dynamic Island, home indicator support
- **App Store ready** — Bundle ID, icons, privacy manifest

### Structure (when created)
```
ios/
├── GuessingGame.xcodeproj/
├── GuessingGame/
│   ├── GuessingGameApp.swift
│   ├── ContentView.swift
│   ├── Games/
│   │   ├── GuessingGameView.swift
│   │   └── SnakeGameView.swift
│   ├── Components/
│   │   └── FlipCardView.swift
│   └── Assets.xcassets/
└── README.md
```

---

## 🛠️ Tech Stack

| Component | Version | Purpose |
|-----------|---------|---------|
| **C++** | 17 | Core language |
| **Dear ImGui** | Latest (docking branch) | Immediate-mode GUI |
| **SDL2** | 2.28+ | Window, renderer, input |
| **CMake** | 3.16+ | Cross-platform build |
| **std::mt19937** | C++11 | Cryptographic-quality RNG |

---

## 📁 Project Structure

```
guessing-game-gui/
├── main.cpp                 # Enhanced hub: flip, snake, particles, settings (~980 lines)
├── snake_game.h             # Snake logic (grid, movement, collision, persistence)
├── animation.h              # Flip animation, easing, particle system
├── CMakeLists.txt           # Cross-platform build config
├── Info.plist               # macOS app bundle metadata
├── build_macos.sh           # macOS one-command build script
├── build_windows.bat        # Windows one-command build script
├── ROADMAP.md               # Development roadmap
├── README.md                # This file
├── console/                 # Original console version (Day 1 foundation)
│   ├── guessing_game.cpp    # Console game (~80 lines)
│   └── CMakeLists.txt       # Console build config
├── ios/                     # iOS starter (planned - Phase 3)
│   └── (SwiftUI project)
├── imgui/                   # Dear ImGui source (vendored)
│   ├── *.cpp / *.h
│   └── backends/            # SDL2 + SDLRenderer2 backends
└── build/                   # Build output (gitignored)
```

---

## 🎯 How to Play

### Guessing Game
1. **Launch** — Window opens at 1280×720, centered
2. **Set Range** — Enter min/max (default 1–100)
3. **Click "Start Game"** — Random number generated
4. **Guess** — Type number + Enter, or click "Guess"
5. **Use Quick Picks** — Min/25%/50%/75%/Max for optimal binary search
6. **Win** — Confetti burst! Click "Play Again" or "New Range"

### Snake Game
1. **Flip** — Click "Flip to Snake Game" (bottom button)
2. **Control** — WASD / Arrow Keys / Gamepad D-pad
3. **Eat** — Red pulsing food grows snake +10 points
4. **Avoid** — Walls and self-collision
5. **Pause** — Spacebar or "Pause" button
6. **Restart** — R key or "Restart" button after game over
7. **Flip back** — Click "Flip to Guessing Game"

---

## 🗺️ Roadmap

| Phase | Target | Status |
|-------|--------|--------|
| **1. Foundation** | Core GUI, guessing game, macOS/Windows build | ✅ v1.0.0 |
| **2. Enhanced Desktop** | Flip animation, Snake game, particles, settings | ✅ v2.0.0 |
| **3. iOS Native** | SwiftUI app, touch controls, App Store | 📋 Planned |
| **4. Platform Polish** | Notarization, NSIS installer, Linux AppImage | 📋 Planned |
| **5. CI/CD** | GitHub Actions, auto-release, checksums | 📋 Planned |

See [ROADMAP.md](ROADMAP.md) for detailed milestones.

---

## 🔗 Related

- **Original Console Game (Day 1 Foundation):** [`console/guessing_game.cpp`](console/guessing_game.cpp)
- **Development Roadmap:** [`ROADMAP.md`](ROADMAP.md)
- **Dear ImGui:** https://github.com/ocornut/imgui
- **SDL2:** https://www.libsdl.org/

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

**Built with ❤️ as a cross-platform C++ GUI learning exercise — now a dual-game hub!**

*If this helped you learn ImGui/SDL2/CMake, consider ⭐ the repo!*

</div>