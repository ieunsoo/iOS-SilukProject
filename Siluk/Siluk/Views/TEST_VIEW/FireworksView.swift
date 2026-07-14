////
////  FireworksView.swift
////  Siluk
////
////  A reusable, time-based fireworks (폭죽) animation overlay.
////
//
//import SwiftUI
//
//// MARK: - Model
//
///// A single firework: a rocket that rises, then bursts into radiating particles.
//private struct Firework: Identifiable {
//    let id = UUID()
//    /// When this firework was launched (seconds, in the timeline's reference clock).
//    let birth: TimeInterval
//    /// Horizontal position of the rocket / burst, in unit coordinates (0...1).
//    let x: CGFloat
//    /// Height at which the rocket bursts, in unit coordinates (0 = bottom, 1 = top).
//    let burstHeight: CGFloat
//    let color: Color
//    /// Pre-computed particle directions & speeds so the animation is deterministic.
//    let particles: [Particle]
//
//    let riseDuration: TimeInterval
//    let explodeDuration: TimeInterval
//
//    var totalDuration: TimeInterval { riseDuration + explodeDuration }
//
//    struct Particle {
//        let angle: CGFloat   // radians
//        let speed: CGFloat   // unit-space distance per second
//        let size: CGFloat
//    }
//
//    static func random(at birth: TimeInterval) -> Firework {
//        let colors: [Color] = [.red, .orange, .yellow, .green, .cyan, .blue, .purple, .pink, .white]
//        let particleCount = Int.random(in: 28...44)
//        let baseSpeed = CGFloat.random(in: 0.18...0.28)
//
//        let particles = (0..<particleCount).map { i -> Particle in
//            // Even angular spread with a little jitter for a natural burst.
//            let angle = (CGFloat(i) / CGFloat(particleCount)) * (.pi * 2)
//                + CGFloat.random(in: -0.12...0.12)
//            return Particle(
//                angle: angle,
//                speed: baseSpeed * CGFloat.random(in: 0.7...1.15),
//                size: CGFloat.random(in: 2.5...5.0)
//            )
//        }
//
//        return Firework(
//            birth: birth,
//            x: CGFloat.random(in: 0.15...0.85),
//            burstHeight: CGFloat.random(in: 0.55...0.85),
//            color: colors.randomElement()!,
//            particles: particles,
//            riseDuration: TimeInterval.random(in: 0.55...0.85),
//            explodeDuration: TimeInterval.random(in: 1.1...1.6)
//        )
//    }
//}
//
//// MARK: - View
//
///// An overlay that plays fireworks bursts. Increment `trigger` to launch a new volley.
//struct FireworksView: View {
//    /// Change this value (e.g. on a button tap) to launch a new burst.
//    var trigger: Int
//    /// How many fireworks to launch per trigger.
//    var burstCount: Int = 5
//
//    @State private var fireworks: [Firework] = []
//    @State private var lastTrigger: Int = 0
//
//    var body: some View {
//        TimelineView(.animation) { context in
//            let now = context.date.timeIntervalSinceReferenceDate
//
//            Canvas { canvas, size in
//                for firework in fireworks {
//                    draw(firework, at: now, in: canvas, size: size)
//                }
//            }
//            .onChange(of: context.date) { _, _ in
//                // Prune finished fireworks so the array doesn't grow forever.
//                fireworks.removeAll { now - $0.birth > $0.totalDuration }
//            }
//        }
//        .allowsHitTesting(false)
//        .ignoresSafeArea()
//        .onChange(of: trigger) { _, newValue in
//            guard newValue != lastTrigger else { return }
//            lastTrigger = newValue
//            launchVolley()
//        }
//    }
//
//    private func launchVolley() {
//        let now = Date().timeIntervalSinceReferenceDate
//        for i in 0..<burstCount {
//            // Stagger the launches slightly for a lively cascade.
//            let delay = TimeInterval(i) * TimeInterval.random(in: 0.12...0.28)
//            fireworks.append(.random(at: now + delay))
//        }
//    }
//
//    // MARK: Drawing
//
//    private func draw(_ firework: Firework, at now: TimeInterval, in canvas: GraphicsContext, size: CGSize) {
//        let elapsed = now - firework.birth
//        guard elapsed >= 0 else { return }
//
//        let originX = firework.x * size.width
//        let bottomY = size.height
//        let burstY = (1 - firework.burstHeight) * size.height
//
//        if elapsed < firework.riseDuration {
//            // --- Rocket rising ---
//            let t = CGFloat(elapsed / firework.riseDuration)
//            let easedT = 1 - pow(1 - t, 2) // ease-out: fast, then slowing near the top
//            let y = bottomY + (burstY - bottomY) * easedT
//
//            var rocket = canvas
//            rocket.addFilter(.blur(radius: 1))
//            let dot = CGRect(x: originX - 2, y: y - 2, width: 4, height: 4)
//            rocket.fill(Circle().path(in: dot), with: .color(firework.color))
//
//            // A short glowing trail behind the rocket.
//            let trailLength: CGFloat = 22
//            let trail = Path { p in
//                p.move(to: CGPoint(x: originX, y: y))
//                p.addLine(to: CGPoint(x: originX, y: min(bottomY, y + trailLength)))
//            }
//            canvas.stroke(
//                trail,
//                with: .color(firework.color.opacity(0.5)),
//                style: StrokeStyle(lineWidth: 2, lineCap: .round)
//            )
//        } else {
//            // --- Explosion ---
//            let explodeElapsed = elapsed - firework.riseDuration
//            let progress = CGFloat(explodeElapsed / firework.explodeDuration) // 0...1
//            let fade = max(0, 1 - progress)
//            let gravity: CGFloat = 0.35 * size.height // downward pull
//
//            var burst = canvas
//            burst.addFilter(.blur(radius: 0.5))
//
//            for particle in firework.particles {
//                let distance = particle.speed * CGFloat(explodeElapsed) * size.height
//                let dx = cos(particle.angle) * distance
//                // Vertical offset plus gravity so sparks arc and fall.
//                let dy = sin(particle.angle) * distance
//                    + gravity * pow(CGFloat(explodeElapsed), 2)
//
//                let px = originX + dx
//                let py = burstY + dy
//                let radius = particle.size * fade
//
//                guard radius > 0.2 else { continue }
//                let rect = CGRect(x: px - radius, y: py - radius, width: radius * 2, height: radius * 2)
//                burst.fill(
//                    Circle().path(in: rect),
//                    with: .color(firework.color.opacity(Double(fade)))
//                )
//            }
//        }
//    }
//}
//
//#Preview {
//    struct PreviewHost: View {
//        @State private var trigger = 0
//        var body: some View {
//            ZStack {
//                Color.black
//                Button("폭죽 터뜨리기") { trigger += 1 }
//                    .buttonStyle(.borderedProminent)
//            }
//            .overlay(FireworksView(trigger: trigger))
//        }
//    }
//    return PreviewHost()
//}
