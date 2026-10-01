import SwiftUI
import SpriteKit

// Snake on macOS: SpriteKit board, arrow keys / WASD to steer,
// clickable direction pad for mouse players.

struct SnakeGameView: View {
    @StateObject private var model = SnakeGameModel()
    @EnvironmentObject private var coordinator: GameCoordinator
    @FocusState private var boardFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()
                .background(Theme.divider)

            SpriteView(scene: model.scene, options: [.allowsTransparency])
                .frame(minWidth: 340, idealWidth: 420, minHeight: 340, idealHeight: 420)
                .background(Theme.surface)
                .cornerRadius(12)
                .padding(16)
                .focusable()
                .focused($boardFocused)
                .onKeyPress(.leftArrow) { model.setDirection(.left); return .handled }
                .onKeyPress(.rightArrow) { model.setDirection(.right); return .handled }
                .onKeyPress(.upArrow) { model.setDirection(.up); return .handled }
                .onKeyPress(.downArrow) { model.setDirection(.down); return .handled }
                .onKeyPress("a") { model.setDirection(.left); return .handled }
                .onKeyPress("d") { model.setDirection(.right); return .handled }
                .onKeyPress("w") { model.setDirection(.up); return .handled }
                .onKeyPress("s") { model.setDirection(.down); return .handled }
                .onKeyPress(.space) { model.togglePause(); return .handled }

            controlsHint

            directionPad
                .padding(.bottom, 8)

            if model.isGameOver {
                gameOverCard
            }

            Spacer(minLength: 8)
        }
        .onAppear { boardFocused = true }
        .onChange(of: coordinator.newGameID) { _, _ in
            model.restart()
            boardFocused = true
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Snake")
                    .font(.title2.bold())
                    .foregroundColor(Theme.textPrimary)
                Text("Eat the red dots. Don't hit the walls.")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 8) {
                    if model.combo > 1 {
                        Text("×\(model.combo) COMBO")
                            .font(.caption.bold())
                            .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.25))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(red: 1.0, green: 0.72, blue: 0.25).opacity(0.15))
                            .cornerRadius(6)
                    }
                    Text("Score: \(model.score)")
                        .font(.title3.bold())
                        .foregroundColor(Theme.textPrimary)
                }
                Label("Best: \(model.highScore)", systemImage: "trophy.fill")
                    .font(.subheadline)
                    .foregroundColor(Theme.warnLow)
            }
            Button(action: { model.togglePause() }) {
                Image(systemName: model.isPaused ? "play.fill" : "pause.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Theme.surface2)
                    .cornerRadius(10)
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(model.isGameOver)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
    }

    // MARK: - Controls

    private var controlsHint: some View {
        HStack {
            Text("Arrow keys or WASD • Space pauses")
                .font(.subheadline)
                .foregroundColor(Theme.textMuted)
            Spacer()
            Picker("Speed", selection: $model.speed) {
                ForEach(SnakeGameModel.Speed.allCases) { s in
                    Text(s.rawValue).tag(s)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 190)
            Toggle("Wrap", isOn: $model.wrapMode)
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
                .toggleStyle(.switch)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 10)
    }

    private var directionPad: some View {
        VStack(spacing: 6) {
            padButton(.up, icon: "chevron.up")
            HStack(spacing: 6) {
                padButton(.left, icon: "chevron.left")
                padButton(.down, icon: "chevron.down")
                padButton(.right, icon: "chevron.right")
            }
        }
        .opacity(model.isGameOver || model.isPaused ? 0.4 : 1.0)
    }

    private func padButton(_ direction: SnakeDirection, icon: String) -> some View {
        Button(action: {
            model.setDirection(direction)
            boardFocused = true
        }) {
            Image(systemName: icon)
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(width: 44, height: 36)
                .background(Theme.surface2)
                .cornerRadius(8)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Game over

    private var gameOverCard: some View {
        VStack(spacing: 12) {
            Text("GAME OVER")
                .font(.title2.bold())
                .foregroundColor(Theme.danger)
            Text("Final Score: \(model.score)")
                .font(.title3)
                .foregroundColor(Theme.textSecondary)
            Button(action: {
                model.restart()
                boardFocused = true
            }) {
                Text("Restart")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.18, green: 0.65, blue: 0.30))
                    .cornerRadius(12)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 60)
        }
        .padding(.vertical, 20)
        .background(Theme.surface.opacity(0.6))
        .cornerRadius(16)
        .padding(.horizontal, 24)
        .transition(.scale.combined(with: .opacity))
    }
}
