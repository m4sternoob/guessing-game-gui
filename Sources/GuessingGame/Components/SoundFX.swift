import AppKit
import SwiftUI

/// Dependency-free sound effects: classic macOS system sounds, one global
/// mute toggle. Off by default — the user opts in from the toolbar speaker
/// button. No bundled audio, no third-party code.

final class SoundFX: ObservableObject {
    static let shared = SoundFX()

    /// Global mute switch. Persisted; false on first launch.
    /// willSet publishes so the toolbar icon refreshes on toggle —
    /// @AppStorage alone doesn't emit objectWillChange.
    @AppStorage("gg3-sound-enabled") var isEnabled = false {
        willSet { objectWillChange.send() }
    }

    private init() {}

    enum Sound: String {
        case tap = "Tink"    // UI taps, pauses, token moves
        case dice = "Pop"    // dice rolls
        case eat = "Ping"    // snake eats food
        case win = "Glass"   // victories
        case lose = "Basso"  // defeats
    }

    func play(_ sound: Sound) {
        guard isEnabled else { return }
        NSSound(named: sound.rawValue)?.play()
    }
}
