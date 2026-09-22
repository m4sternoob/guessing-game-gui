# Guessing Game GUI

<div align="center">

![C++](https://img.shields.io/badge/C++-17-blue.svg)
![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Windows-lightgrey.svg)
![GUI](https://img.shields.io/badge/GUI-Dear%20ImGui%20%2B%20SDL2-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![Build](https://img.shields.io/badge/Build-CMake-orange.svg)

**A modern, cross-platform GUI for the classic number guessing game — built with Dear ImGui + SDL2. Clean dark theme, 720p default, high-DPI ready, single codebase for macOS & Windows.**

[📥 Download Source](#-download-source) • [🍎 macOS Build](#-macos-build) • [🪟 Windows Build](#-windows-build) • [📖 Documentation](#-features)

</div>

---

## 🎮 Overview

This project transforms the original console-based [day1-cpp-game](https://github.com/m4sternoob/day1-cpp-game) into a polished desktop application with a modern graphical interface. Built as a learning exercise in cross-platform C++ GUI development using **Dear ImGui** (immediate-mode GUI, standard in game dev) and **SDL2** (window/renderer/input abstraction).

### Why ImGui + SDL2?

| Aspect | Benefit |
|--------|---------|
| **Lightweight** | ~1.4 MB binary, no heavy runtime dependencies |
| **Game-dev native** | Immediate mode, 60 FPS, no retained widget tree |
| **True cross-platform** | Identical code on macOS, Windows, Linux |
| **Zero boilerplate** | No MFC, Win32, Cocoa, or Qt object hierarchies |
| **Customizable** | Full theming via `ImGuiStyle` |

---

## ✨ Features

- **🎨 Modern Dark UI** — Slate/blue palette, 12px window rounding, consistent 6px control rounding
- **📐 720p Default** — Launches at 1280×720, fully resizable with crisp rendering at any size
- **🖥️ High-DPI / Retina Ready** — Automatic DPI detection, integer scaling, no text distortion on resize
- **🎯 Smart Quick-Picks** — Min/25%/50%/75%/Max buttons for binary-search strategy
- **📊 Guess History** — Scrollable, color-coded entries (🟢 correct, 🟡 low, 🔴 high)
- **📈 Statistics Panel** — Attempts, range, efficiency vs theoretical optimum
- **⌨️ Keyboard Support** — Enter to submit, full gamepad/keyboard navigation
- **🔄 Play Again** — One-click reset for instant replay

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
| [`GuessingGame-macOS-v1.0.0.zip`](https://github.com/m4sternoob/guessing-game-gui/releases/download/v1.0.0/GuessingGame-macOS-v1.0.0.zip) | ~1.5 MB | `332acce510a48b5e71424ccb8b83e5ced33cf003d7740f15a64d31d3bfd11c82` |

**Install:**
```bash
# Download and unzip
unzip GuessingGame-macOS-v1.0.0.zip
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

### Pre-built Executable (Recommended)
| File | Size | SHA256 |
|------|------|--------|
| [`GuessingGame-Windows-v1.0.0.zip`](https://github.com/m4sternoob/guessing-game-gui/releases/download/v1.0.0/GuessingGame-Windows-v1.0.0.zip) | ~1.5 MB | *pending release* |

**Install:**
1. Download `GuessingGame-Windows-v1.0.0.zip`
2. Extract to any folder
3. Run `GuessingGame.exe`

**Requirements:** Windows 10/11 (x64), Visual C++ Redistributable (usually pre-installed)

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
├── main.cpp                 # Game logic + ImGui UI (~580 lines)
├── CMakeLists.txt           # Cross-platform build config
├── Info.plist               # macOS app bundle metadata
├── build_macos.sh           # macOS one-command build script
├── build_windows.bat        # Windows one-command build script
├── README.md                # This file
├── imgui/                   # Dear ImGui source (vendored)
│   ├── *.cpp / *.h
│   └── backends/            # SDL2 + SDLRenderer2 backends
└── build/                   # Build output (gitignored)
```

---

## 🎯 How to Play

1. **Launch** the app — window opens at 1280×720, centered
2. **Set Range** — Enter min/max (default 1–100)
3. **Click "Start Game"** — Random number generated
3. **Guess** — Type number + Enter, or click "Guess"
4. **Use Quick Picks** — Min/25%/50%/75%/Max for optimal binary search
5. **Win** — See stats, click "Play Again" for instant replay

---

## 🔗 Related

- **Original Console Game:** [m4sternoob/day1-cpp-game](https://github.com/m4sternoob/day1-cpp-game) — The Day 1 C++ learning project this GUI wraps
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

**Built with ❤️ as a cross-platform C++ GUI learning exercise**

*If this helped you learn ImGui/SDL2/CMake, consider ⭐ the repo!*

</div>