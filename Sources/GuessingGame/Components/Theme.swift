import SwiftUI

// Shared dark theme + reusable components for the macOS app.

enum Theme {
    static let background = Color(red: 0.05, green: 0.06, blue: 0.09)
    static let surface = Color(red: 0.10, green: 0.12, blue: 0.16)
    static let surface2 = Color(red: 0.15, green: 0.18, blue: 0.23)
    static let divider = Color(red: 0.20, green: 0.22, blue: 0.28)
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.60, green: 0.65, blue: 0.72)
    static let textMuted = Color(red: 0.55, green: 0.60, blue: 0.68)
    static let accent = Color(red: 0.20, green: 0.50, blue: 1.0)
    static let good = Color(red: 0.40, green: 0.95, blue: 0.40)
    static let warnLow = Color(red: 1.0, green: 0.75, blue: 0.30)
    static let warnHigh = Color(red: 1.0, green: 0.45, blue: 0.45)
    static let danger = Color(red: 1.0, green: 0.35, blue: 0.35)
}

// Subtle grid backdrop used behind both games.
struct GridBackground: View {
    var body: some View {
        GeometryReader { _ in
            Canvas { context, size in
                let spacing: CGFloat = 50
                let color = Color(red: 0.11, green: 0.125, blue: 0.165)
                var x: CGFloat = 0
                while x <= size.width {
                    context.stroke(
                        Path { p in
                            p.move(to: CGPoint(x: x, y: 0))
                            p.addLine(to: CGPoint(x: x, y: size.height))
                        },
                        with: .color(color),
                        lineWidth: 0.5
                    )
                    x += spacing
                }
                var y: CGFloat = 0
                while y <= size.height {
                    context.stroke(
                        Path { p in
                            p.move(to: CGPoint(x: 0, y: y))
                            p.addLine(to: CGPoint(x: size.width, y: y))
                        },
                        with: .color(color),
                        lineWidth: 0.5
                    )
                    y += spacing
                }
            }
        }
    }
}

// Tactile press feedback for buttons.
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Dismissible error toast.
struct ErrorToast: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(.white.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color(red: 0.18, green: 0.12, blue: 0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.5), lineWidth: 1)
        )
    }
}

// Confetti burst shown on win.
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var timer: Timer?

    struct ConfettiParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var rotation: Double
        var scale: CGFloat
        var color: Color
        var velocityX: CGFloat
        var velocityY: CGFloat
    }

    private let colors: [Color] = [
        Color(red: 1.0, green: 0.3, blue: 0.3),
        Color(red: 0.3, green: 1.0, blue: 0.3),
        Color(red: 0.3, green: 0.5, blue: 1.0),
        Color(red: 1.0, green: 0.8, blue: 0.2),
        Color(red: 1.0, green: 0.4, blue: 1.0),
        Color(red: 0.2, green: 1.0, blue: 1.0),
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(particle.color)
                        .frame(width: particle.scale * 10, height: particle.scale * 6)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onAppear {
                let centerX = geometry.size.width / 2
                let centerY = geometry.size.height / 2
                for i in 0..<60 {
                    let angle = Double(i) / 60.0 * 2 * .pi
                    let speed = CGFloat.random(in: 150...350)
                    particles.append(ConfettiParticle(
                        x: centerX,
                        y: centerY,
                        rotation: Double.random(in: 0...360),
                        scale: CGFloat.random(in: 0.5...1.2),
                        color: colors.randomElement() ?? .white,
                        velocityX: cos(angle) * speed,
                        velocityY: sin(angle) * speed - 150
                    ))
                }
                animateParticles(in: geometry.size)
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
        }
    }

    private func animateParticles(in size: CGSize) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { t in
            for i in particles.indices {
                particles[i].x += particles[i].velocityX / 60.0
                particles[i].y += particles[i].velocityY / 60.0
                particles[i].velocityY += 300 / 60.0 // gravity
                particles[i].rotation += Double.random(in: -8...8)
            }
            particles.removeAll { $0.y > size.height + 80 }
            if particles.isEmpty {
                t.invalidate()
                timer = nil
            }
        }
    }
}
