import SwiftUI

// Root container: toolbar switcher between the two games.
// (macOS idiom — a segmented toolbar control, not the iOS flip-card.)

enum ActiveGame: String, CaseIterable, Identifiable {
    case guessing
    case snake

    var id: Self { self }

    var title: String {
        switch self {
        case .guessing: return "Guessing Game"
        case .snake: return "Snake"
        }
    }

    var icon: String {
        switch self {
        case .guessing: return "questionmark.circle"
        case .snake: return "gamecontroller"
        }
    }
}

struct ContentView: View {
    @State private var activeGame: ActiveGame = .guessing

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            GridBackground().ignoresSafeArea()

            Group {
                switch activeGame {
                case .guessing:
                    GuessingGameView()
                case .snake:
                    SnakeGameView()
                }
            }
        }
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Picker("Game", selection: $activeGame) {
                    ForEach(ActiveGame.allCases) { game in
                        Label(game.title, systemImage: game.icon).tag(game)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 300)
            }
        }
    }
}
