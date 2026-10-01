import SwiftUI

// Animated die used by the board games. While `rolling` is true it shuffles
// faces; when it stops, it settles on `value`.

struct DiceView: View {
    let value: Int          // 1...6 — the settled face
    let rolling: Bool
    var size: CGFloat = 84
    var enabled: Bool = true
    var onTap: () -> Void = {}

    @State private var display = 1
    @State private var timer: Timer?

    private static let pips: [Int: [Int]] = [
        1: [4],
        2: [0, 8],
        3: [0, 4, 8],
        4: [0, 2, 6, 8],
        5: [0, 2, 4, 6, 8],
        6: [0, 2, 3, 5, 6, 8],
    ]

    var body: some View {
        Button(action: { if enabled && !rolling { onTap() } }) {
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.22)
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color(red: 0.88, green: 0.89, blue: 0.93)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.35), radius: 6, y: 3)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 3),
                          spacing: 0) {
                    ForEach(0..<9) { i in
                        Group {
                            if Self.pips[display]?.contains(i) == true {
                                Circle()
                                    .fill(Color(red: 0.12, green: 0.13, blue: 0.18))
                            } else {
                                Color.clear
                            }
                        }
                        .frame(width: size * 0.16, height: size * 0.16)
                    }
                }
                .padding(size * 0.18)
            }
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rolling ? 8 : 0))
            .scaleEffect(rolling ? 1.06 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: rolling)
            .opacity(enabled ? 1.0 : 0.45)
        }
        .buttonStyle(.plain)
        .onChange(of: rolling) { _, isRolling in
            if isRolling {
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
                    display = Int.random(in: 1...6)
                }
            } else {
                timer?.invalidate()
                timer = nil
                withAnimation(.spring(response: 0.25, dampingFraction: 0.55)) {
                    display = max(1, min(6, value))
                }
            }
        }
        .onAppear { display = max(1, min(6, value)) }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}

// Small stat readout used in game headers.
struct StatPill: View {
    let icon: String
    let text: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(.subheadline.bold())
            .foregroundColor(Theme.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Theme.surface2)
            .cornerRadius(8)
    }
}
