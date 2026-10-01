import SwiftUI

// Root container: segmented switcher across the five games.
// (macOS idiom — a segmented toolbar control, not the iOS flip-card.)

enum ActiveGame: String, CaseIterable, Identifiable {
    case guessing
    case snake
    case ladders
    case ludo
    case tictactoe

    var id: Self { self }

    var title: String {
        switch self {
        case .guessing: return "Guess"
        case .snake: return "Snake"
        case .ladders: return "Ladders"
        case .ludo: return "Ludo"
        case .tictactoe: return "TicTac"
        }
    }

    var icon: String {
        switch self {
        case .guessing: return "questionmark.circle"
        case .snake: return "gamecontroller"
        case .ladders: return "dice.fill"
        case .ludo: return "circle.grid.3x3.fill"
        case .tictactoe: return "grid"
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
                case .ladders:
                    SnakesLaddersView()
                case .ludo:
                    LudoView()
                case .tictactoe:
                    TicTacToeView()
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
                .frame(width: 460)
            }
        }
    }
}
