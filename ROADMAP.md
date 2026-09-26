# 🎮 Guessing Game GUI - Development Roadmap

## ✅ Phase 1: Foundation (COMPLETED v1.0.0)
- [x] Cross-platform C++ GUI with Dear ImGui + SDL2
- [x] Modern dark theme (slate/blue palette)
- [x] 720p default window, resizable with DPI handling
- [x] Guessing game logic with quick-picks, history, stats
- [x] macOS app bundle + Windows build scripts
- [x] GitHub repo with professional README, release v1.0.0
- [x] Original console game preserved in `console/`

---

## 🚧 Phase 2: Enhanced Desktop GUI (v2.0.0 - IN PROGRESS)
- [ ] **Flip-card animation** — 3D flip between Guessing Game ↔ Snake Game
- [ ] **Larger UI scale** — Bigger fonts (1.4x), buttons, touch-friendly targets (min 48px)
- [ ] **Snake Game** — Classic snake with score, growth, wall collision, game over
- [ ] **Animations** — Smooth transitions, particle/confetti effects, easing curves
- [ ] **Shared menu bar** — Game selector (tabs), settings, about
- [ ] **Persistence** — High scores saved to disk (JSON)
- [ ] **Sound effects** — Beeps for actions, win/lose sounds (optional)

---

## 📱 Phase 3: iOS Version (v3.0.0 - PLANNED)
- [ ] **Separate Swift/SwiftUI project** — Native iOS app in `ios/` folder
- [ ] **Same game logic** — Ported to Swift
- [ ] **Touch-optimized UI** — Gesture controls for snake (swipe), keypad for guessing
- [ ] **App Store ready** — Bundle ID, icons, launch screen, privacy manifest
- [ ] **Separate repo** — `guessing-game-ios` (or subfolder with own Xcode project)
- [ ] **Haptics** — UIImpactFeedbackGenerator for actions
- [ ] **Safe area handling** — Dynamic Island, home indicator

---

## 🖥️ Phase 4: Platform Polish (v2.1.0+)
- [ ] **Windows installer** — NSIS/Inno Setup, code signing ready
- [ ] **macOS notarization** — Developer ID, notarize, staple, DMG
- [ ] **Linux AppImage** — Single-file distribution
- [ ] **Auto-updater** — Sparkle (macOS), WinSparkle (Windows)
- [ ] **Proper app icons** — .icns (macOS), .ico (Windows), all sizes

---

## 📦 Phase 5: CI/CD & Distribution (v2.2.0+)
- [ ] **GitHub Actions CI** — Build matrix (macOS/Windows/Linux)
- [ ] **Auto-release** — Tag push → build → release assets
- [ ] **Checksums** — SHA256 for all artifacts
- [ ] **Changelog** — Auto-generated from conventional commits
- [ ] **Pre-release builds** — Nightly/beta channel

---

## 🎯 Current Sprint: Phase 2 (v2.0.0)
**This session deliverables:**
1. ✅ Roadmap documented
2. ⬜ **Flip animation system** — ImGui custom rendering with 3D perspective flip
3. ⬜ **Snake Game implementation** — Full mechanics on flip side
4. ⬜ **Larger UI scale** — 1.4x default, configurable
5. ⬜ **Shared navigation** — Tab bar or flip button
6. ⬜ **Particle/confetti system** — Win celebration
7. ⬜ **High score persistence** — JSON file in app data dir
8. ⬜ **Build & test macOS** — Verify 720p, resize, flip works
9. ⬜ **Update GitHub release v2.0.0** — With new features
10. ⬜ **Create iOS starter** — SwiftUI project structure in `ios/`

---

## 📋 Technical Notes

### Flip Animation Approach
- Use ImDrawList for custom 3D flip rendering
- Two "sides": front (guessing), back (snake)
- State machine: IDLE → FLIPPING_TO_BACK → BACK_VISIBLE → FLIPPING_TO_FRONT
- Easing: cubic-bezier(0.4, 0, 0.2, 1) for natural feel
- Duration: ~600ms

### Snake Game in ImGui
- Grid: 20×20 cells, each 20px (scaled)
- Render via ImDrawList::AddRectFilled for body segments
- Head distinct color, food pulsing animation
- Input: WASD / Arrow keys / Gamepad
- 10 FPS fixed timestep (separate from render loop)

### UI Scale System
- Base scale: 1.4x (was 1.0x)
- Configurable via Settings: 1.0x, 1.2x, 1.4x, 1.6x, 2.0x
- Persisted to config.json
- Affects: fonts, padding, button sizes, window size

### File Structure for v2.0.0
```
guessing-game-gui/
├── main.cpp                 # Enhanced: flip, tabs, snake, animations
├── snake_game.h/.cpp        # Snake logic (separated)
├── animation.h/.cpp         # Flip animation, easing, particles
├── persistence.h/.cpp       # High scores, settings (JSON)
├── CMakeLists.txt           # Updated for new sources
├── Info.plist               # macOS bundle
├── build_macos.sh
├── build_windows.bat
├── ROADMAP.md
├── README.md
├── console/
│   └── guessing_game.cpp
├── ios/                     # iOS starter (Phase 3)
│   ├── GuessingGame.xcodeproj/
│   ├── GuessingGame/
│   │   ├── ContentView.swift
│   │   ├── GuessingGameApp.swift
│   │   ├── Games/
│   │   │   ├── GuessingGameView.swift
│   │   │   └── SnakeGameView.swift
│   │   ├── Components/
│   │   │   └── FlipCardView.swift
│   │   └── Assets.xcassets/
│   └── README.md
├── imgui/
└── build/
```

---

## 🏷️ Version Tagging Convention
- `v1.x.x` — Foundation (current: v1.0.0)
- `v2.x.x` — Desktop enhanced (flip, snake, animations)
- `v3.x.x` — iOS native
- `v4.x.x` — Platform polish + CI/CD