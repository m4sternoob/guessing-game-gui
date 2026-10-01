import SwiftUI

// v3.0.0 — native macOS entry point.

/// Relays menu-bar commands (⌘N) down to the active game view.
final class GameCoordinator: ObservableObject {
    @Published var newGameID = UUID()
    func requestNewGame() { newGameID = UUID() }
}

@main
struct GuessingGameApp: App {
    @StateObject private var coordinator = GameCoordinator()

    var body: some Scene {
        WindowGroup("Guessing Game") {
            ContentView()
                .environmentObject(coordinator)
                .frame(minWidth: 540, minHeight: 700)
        }
        .defaultSize(width: 560, height: 740)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Game") { coordinator.requestNewGame() }
                    .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}
