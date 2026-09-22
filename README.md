# Guessing Game - Cross-Platform C++ GUI

A modern, cross-platform GUI for the classic number guessing game, built with **Dear ImGui + SDL2**. Works on Windows and macOS with a single codebase — similar to JavaFX but for C++.

## Features

- 🎮 **Game-like UI** with dark theme, rounded corners, and color-coded feedback
- 📱 **Cross-platform**: Single codebase builds on Windows and macOS
- 🎯 **Smart guess buttons** (Min, 25%, 50%, 75%, Max) for quick binary-search-style play
- 📊 **Guess history** with visual indicators (📈 too low, 📉 too high, ✓ correct)
- 📈 **Statistics** showing efficiency vs theoretical optimum
- ⌨️ **Keyboard support** — press Enter to submit guesses
- 🖱️ **Mouse/gamepad navigation** via ImGui

## Screenshots

*Clean dark-themed interface with intuitive controls*

## Building

### macOS (Apple Silicon / Intel)

**Prerequisites:**
```bash
brew install cmake sdl2
```

**Build:**
```bash
chmod +x build_macos.sh
./build_macos.sh
```

**Run:**
```bash
open ./build/GuessingGame.app
# Or from terminal:
./build/GuessingGame.app/Contents/MacOS/GuessingGame
```

### Windows

**Prerequisites:**
1. Install **Visual Studio 2022** with "Desktop development with C++" workload
2. Install **vcpkg**:
   ```cmd
   git clone https://github.com/microsoft/vcpkg
   cd vcpkg
   .\bootstrap-vcpkg.bat
   ```
3. Install SDL2 via vcpkg:
   ```cmd
   .\vcpkg\vcpkg install sdl2:x64-windows
   ```
4. Set `VCPKG_ROOT` environment variable to your vcpkg directory

**Build:**
```cmd
build_windows.bat
```

**Run:**
```cmd
.\build\Release\GuessingGame.exe
```

## Project Structure

```
guessing_game_gui/
├── main.cpp                 # Game logic + ImGui UI
├── CMakeLists.txt           # Cross-platform build config
├── Info.plist               # macOS app bundle metadata
├── build_macos.sh           # macOS build script
├── build_windows.bat        # Windows build script
├── imgui/                   # Dear ImGui source (included)
│   ├── imgui.cpp
│   ├── imgui_draw.cpp
│   ├── imgui_tables.cpp
│   ├── imgui_widgets.cpp
│   ├── imgui.h
│   ├── imgui_internal.h
│   ├── imstb_rectpack.h
│   ├── imstb_textedit.h
│   ├── imstb_truetype.h
│   └── backends/
│       ├── imgui_impl_sdl2.cpp/.h
│       └── imgui_impl_sdlrenderer2.cpp/.h
└── build/                   # Build output (generated)
```

## How to Play

1. **Set range** — Enter minimum and maximum numbers (default 1-100)
2. **Click "Start Game"** — A random number is generated
3. **Guess** — Type a number and press Enter or click "Guess!"
4. **Use quick picks** — Min/25%/50%/75%/Max buttons for binary search strategy
5. **Win** — Guess the number correctly to see stats and play again

## Tech Stack

| Component | Purpose |
|-----------|---------|
| **Dear ImGui** | Immediate-mode GUI (game-dev standard) |
| **SDL2** | Window/renderer/input abstraction |
| **CMake** | Cross-platform build system |
| **C++17** | Modern C++ with `<random>`, `<string>`, `<vector>` |

## Why ImGui + SDL2?

- **Lightweight** — ~500KB binary, no heavy runtime
- **Game-friendly** — Immediate mode, 60 FPS, no retained widget tree
- **Cross-platform** — Same code on Windows/macOS/Linux
- **No boilerplate** — No MFC, Win32, Cocoa, or Qt object hierarchies
- **Customizable** — Easy theming via `ImGuiStyle`

## License

MIT — Use freely for learning or projects.

---

*Built as a cross-platform "JavaFX for C++" alternative for simple games and tools.*