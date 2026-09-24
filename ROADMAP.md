# 🎮 Guessing Game GUI - Development Roadmap

## ✅ Phase 1: Foundation (COMPLETED)
- [x] Cross-platform C++ GUI with Dear ImGui + SDL2
- [x] Modern dark theme (slate/blue palette)
- [x] 720p default window, resizable with DPI handling
- [x] Guessing game logic with quick-picks, history, stats
- [x] macOS app bundle + Windows build scripts
- [x] GitHub repo with professional README, release v1.0.0
- [x] Original console game preserved in `console/`

---

## 🚧 Phase 2: Enhanced Desktop GUI (IN PROGRESS)
- [ ] **Flip-card animation** — 3D flip between Guessing Game ↔ Snake Game
- [ ] **Larger UI scale** — Bigger fonts, buttons, touch-friendly targets
- [ ] **Snake Game** — Classic snake with score, growth, wall collision, game over
- [ ] **Animations** — Smooth transitions, particle effects, easing
- [ ] **Shared menu bar** — Game selector, settings, about
- [ ] **Persistence** — High scores saved to disk

---

## 📱 Phase 3: iOS Version (PLANNED)
- [ ] **Separate Swift/SwiftUI project** — Native iOS app
- [ ] **Same game logic** — Ported to Swift
- [ ] **Touch-optimized UI** — Gesture controls for snake
- [ ] **App Store ready** — Bundle ID, icons, launch screen
- [ ] **Separate repo** — `guessing-game-ios`

---

## 🖥️ Phase 4: Platform Polish
- [ ] **Windows installer** — NSIS/Inno Setup, signed
- [ ] **macOS notarization** — Developer ID, notarize, staple
- [ ] **Linux AppImage** — Single-file distribution
- [ ] **Auto-updater** — Sparkle (macOS), WinSparkle (Windows)

---

## 📦 Phase 5: Distribution
- [ ] **GitHub Actions CI** — Build matrix (macOS/Windows/Linux)
- [ ] **Auto-release** — Tag push → build → release assets
- [ ] **Checksums** — SHA256 for all artifacts
- [ ] **Changelog** — Auto-generated from commits

---

## 🎯 Current Sprint: Phase 2
**Next steps:**
1. Add flip-card animation system
2. Implement Snake game with ImGui
3. Create shared navigation/menu
4. Scale up UI for better visibility
5. Build & test on macOS
6. Update README + release v2.0.0