import SwiftUI

// Snakes & Ladders board — you (blue) vs the CPU (red).

struct SnakesLaddersView: View {
    @StateObject private var model = SnakesLaddersModel()
    @EnvironmentObject private var coordinator: GameCoordinator

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header

                Divider()
                    .background(Theme.divider)

                board
                    .padding(16)

                HStack(spacing: 20) {
                    DiceView(
                        value: model.diceValue,
                        rolling: model.rolling,
                        enabled: model.turn == .player && model.winner == nil,
                        onTap: { model.rollDice() }
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        Text(model.message)
                            .font(.headline)
                            .foregroundColor(Theme.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: 8) {
                            turnDot(isActive: model.turn == .player, color: .blue, label: "You")
                            turnDot(isActive: model.turn == .cpu, color: .red, label: "CPU")
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)

                if model.winner != nil {
                    winCard
                }

                Spacer(minLength: 8)
        }
        if model.winner == .player {
            ConfettiView()
        }
        }
        .onChange(of: coordinator.newGameID) { _, _ in
            model.resetForNewGameCommand()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Snakes & Ladders")
                    .font(.title2.bold())
                    .foregroundColor(Theme.textPrimary)
                Text("First to 100 wins — exact roll needed")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
            }
            Spacer()
            StatPill(icon: "person.fill", text: "You \(model.playerWins)")
            StatPill(icon: "cpu", text: "CPU \(model.cpuWins)")
            Button(action: { model.newGame() }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Theme.surface2)
                    .cornerRadius(10)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
    }

    private func turnDot(isActive: Bool, color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
                .opacity(isActive ? 1 : 0.3)
            Text(label)
                .font(.subheadline)
                .foregroundColor(isActive ? Theme.textPrimary : Theme.textMuted)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(isActive ? Theme.surface2 : Color.clear)
        .cornerRadius(8)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }

    // MARK: - Board

    private var board: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                cells(size: size)
                links(size: size)
                tokens(size: size)
            }
            .frame(width: size, height: size)
            .background(Theme.surface)
            .cornerRadius(12)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 470, maxHeight: 470)
    }

    /// Center of cell `n` (1...100) inside a `size`-point board.
    private func cellCenter(_ n: Int, size: CGFloat) -> CGPoint {
        let cell = size / 10
        let r = (n - 1) / 10          // 0 = bottom row
        let idx = (n - 1) % 10
        let c = r % 2 == 0 ? idx : 9 - idx
        return CGPoint(x: (CGFloat(c) + 0.5) * cell,
                       y: (CGFloat(9 - r) + 0.5) * cell)
    }

    private func cells(size: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<10) { displayRow in
                HStack(spacing: 0) {
                    ForEach(0..<10) { displayCol in
                        let r = 9 - displayRow
                        let c = displayRow % 2 == 0 ? 9 - displayCol : displayCol
                        let n = r * 10 + c + 1
                        ZStack {
                            Rectangle().fill(cellColor(n))
                            Text("\(n)")
                                .font(.system(size: 8))
                                .foregroundColor(Theme.textMuted.opacity(0.7))
                        }
                        .frame(width: size / 10, height: size / 10)
                    }
                }
            }
        }
    }

    private func cellColor(_ n: Int) -> Color {
        if SnakesLaddersModel.ladders[n] != nil {
            return Color(red: 0.13, green: 0.35, blue: 0.18)
        }
        if SnakesLaddersModel.snakes[n] != nil {
            return Color(red: 0.38, green: 0.14, blue: 0.14)
        }
        if SnakesLaddersModel.ladders.values.contains(n) {
            return Color(red: 0.10, green: 0.24, blue: 0.14)
        }
        if SnakesLaddersModel.snakes.values.contains(n) {
            return Color(red: 0.26, green: 0.10, blue: 0.10)
        }
        let r = (n - 1) / 10
        let idx = (n - 1) % 10
        return (r + idx) % 2 == 0
            ? Color(red: 0.10, green: 0.12, blue: 0.16)
            : Color(red: 0.13, green: 0.15, blue: 0.20)
    }

    private func links(size: CGFloat) -> some View {
        ZStack {
            ForEach(SnakesLaddersModel.ladders.keys.sorted(), id: \.self) { a in
                let b = SnakesLaddersModel.ladders[a]!
                Path { p in
                    p.move(to: cellCenter(a, size: size))
                    p.addLine(to: cellCenter(b, size: size))
                }
                .stroke(Color(red: 0.25, green: 0.85, blue: 0.35), lineWidth: 5)
                .opacity(0.85)
            }
            ForEach(SnakesLaddersModel.snakes.keys.sorted(), id: \.self) { a in
                let b = SnakesLaddersModel.snakes[a]!
                Path { p in
                    p.move(to: cellCenter(a, size: size))
                    p.addLine(to: cellCenter(b, size: size))
                }
                .stroke(Color(red: 1.0, green: 0.35, blue: 0.35), style: StrokeStyle(lineWidth: 5, dash: [7, 4]))
                .opacity(0.85)
            }
        }
        .allowsHitTesting(false)
    }

    private func tokens(size: CGFloat) -> some View {
        let cell = size / 10
        let radius = cell * 0.30
        return ZStack {
            token(at: model.playerPos, size: size, radius: radius, color: .blue,
                  offset: model.playerPos == model.cpuPos ? -radius * 0.55 : 0)
                .animation(.easeInOut(duration: 0.15), value: model.playerPos)
            token(at: model.cpuPos, size: size, radius: radius, color: .red,
                  offset: model.playerPos == model.cpuPos ? radius * 0.55 : 0)
                .animation(.easeInOut(duration: 0.15), value: model.cpuPos)
        }
        .allowsHitTesting(false)
    }

    private func token(at n: Int, size: CGFloat, radius: CGFloat, color: Color, offset: CGFloat) -> some View {
        let c = cellCenter(n, size: size)
        return Circle()
            .fill(color)
            .frame(width: radius * 2, height: radius * 2)
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .shadow(color: color.opacity(0.6), radius: 4)
            .position(x: c.x + offset, y: c.y)
    }

    // MARK: - Win

    private var winCard: some View {
        VStack(spacing: 12) {
            Text(model.winner == .player ? "YOU WIN! 🏆" : "CPU WINS")
                .font(.title2.bold())
                .foregroundColor(model.winner == .player ? Theme.good : Theme.danger)
            Button(action: { model.newGame() }) {
                Text("Play Again")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.18, green: 0.65, blue: 0.30))
                    .cornerRadius(12)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 60)
        }
        .padding(.vertical, 16)
        .background(Theme.surface.opacity(0.6))
        .cornerRadius(16)
        .padding(.horizontal, 24)
        .transition(.scale.combined(with: .opacity))
    }
}
