import SwiftUI

// v3.1.0 — 5IN1: five mini-games, one native macOS app.

/// Relays menu-bar commands (⌘N) down to the active game view.
final class GameCoordinator: ObservableObject {
    @Published var newGameID = UUID()
    func requestNewGame() { newGameID = UUID() }
}

@main
struct GuessingGameApp: App {
    @StateObject private var coordinator = GameCoordinator()

    var body: some Scene {
        WindowGroup("5IN1") {
            ContentView()
                .environmentObject(coordinator)
                .frame(minWidth: 600, minHeight: 740)
        }
        .defaultSize(width: 660, height: 800)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Game") { coordinator.requestNewGame() }
                    .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}
