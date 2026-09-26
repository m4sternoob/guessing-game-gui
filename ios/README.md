# Guessing Game Hub — iOS Version

Native iOS implementation of the Guessing Game Hub with SwiftUI + SpriteKit.

## Features

- **Flip-card animation** — Native 3D flip between Guessing Game ↔ Snake Game
- **Guessing Game** — Full SwiftUI implementation with confetti, quick picks, history
- **Snake Game** — SpriteKit scene for 60fps smooth rendering
- **Touch-optimized** — Swipe gestures for snake, keypad for guessing
- **Haptics** — UIImpactFeedbackGenerator for actions
- **Dark theme** — Matches desktop aesthetic
- **High score persistence** — UserDefaults

## Structure

```
ios/
├── GuessingGame.xcodeproj/          # Xcode project (create in Xcode)
├── GuessingGame/
│   ├── GuessingGameApp.swift        # App entry point
│   ├── ContentView.swift            # Main container with flip animation
│   ├── Components/
│   │   └── FlipCardView.swift       # Reusable 3D flip card
│   └── Games/
│       ├── GuessingGameView.swift   # Guessing game logic + UI
│       └── SnakeGameView.swift      # Snake game (SwiftUI + SpriteKit)
└── Assets.xcassets/                 # App icons, colors
```

## Setup

1. Open Xcode 15+
2. Create new project: **iOS App** → **SwiftUI** → **Swift**
3. Name: `GuessingGame`
4. Replace generated files with these
5. Add `Assets.xcassets` with:
   - AppIcon (all sizes)
   - AccentColor (blue: #3399FF)
6. Build & run on simulator or device

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Architecture

### ContentView
- Manages flip state and game switching
- Custom 3D flip animation with progress bar
- Shared background grid pattern

### GuessingGameView
- Pure SwiftUI implementation
- @State for all game logic
- Confetti particle system on win
- Keyboard with number pad

### SnakeGameView
- SwiftUI wrapper around SpriteKit scene
- SnakeGameModel as @ObservableObject
- 60fps rendering via SpriteKit
- Swipe gesture support for direction

## Customization

### Colors (match desktop)
```swift
let bgColor = Color(red: 0.05, green: 0.06, blue: 0.09)
let accentColor = Color(red: 0.2, green: 0.5, blue: 1.0)
let gridColor = Color(red: 0.11, green: 0.125, blue: 0.165)
```

### Flip Animation
```swift
withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
    isFlipping = true
}
```

## App Store Checklist

- [ ] App icons (all sizes in Assets.xcassets)
- [ ] Launch screen
- [ ] Privacy manifest (NSPrivacyTracking: false)
- [ ] Bundle ID configured
- [ ] TestFlight build
- [ ] App Store screenshots
- [ ] Description + keywords

## License

MIT — same as desktop version.