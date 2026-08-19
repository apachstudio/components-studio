import SwiftUI

/// A dimensional credit card with the AI Search pill's rotating snake stroke
/// and a perimeter-adapted version of the supplied projectile particle effect.
struct AnimatedCreditCardView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            GeometryReader { proxy in
                let cardSize = CreditCardMetrics.cardSize(in: proxy.size)
                let time = reduceMotion
                    ? 0
                    : timeline.date.timeIntervalSinceReferenceDate

                ZStack {
                    creditCard(size: cardSize, time: time)

                    if !reduceMotion {
                        CreditCardParticles(size: cardSize, time: time)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .aspectRatio(CreditCardMetrics.stageAspectRatio, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Animated purple credit card")
        .accessibilityValue("Christopher Wallace")
    }

    private func creditCard(size: CGSize, time: Double) -> some View {
        CreditCardFace()
            .frame(width: size.width, height: size.height)
            .overlay {
                CreditCardAura(time: time)
            }
            .overlay {
                CreditCardSnakeStroke(time: time)
            }
            .shadow(
                color: CreditCardPalette.shadow.opacity(0.34),
                radius: CreditCardMetrics.contactShadowRadius,
                y: CreditCardMetrics.contactShadowOffset
            )
            .shadow(
                color: CreditCardPalette.shadow.opacity(0.22),
                radius: CreditCardMetrics.ambientShadowRadius,
                y: CreditCardMetrics.ambientShadowOffset
            )
    }
}

private struct CreditCardFace: View {
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let cardShape = RoundedRectangle(
                cornerRadius: CreditCardMetrics.cornerRadius,
                style: .continuous
            )

            ZStack {
                cardShape
                    .fill(CreditCardPalette.body)

                cardShape
                    .fill(CreditCardPalette.surfaceLight)
                    .blendMode(.screen)

                cardShape
                    .fill(CreditCardPalette.edgeShade)
                    .blendMode(.multiply)

                cardShape
                    .strokeBorder(CreditCardPalette.outerEdge, lineWidth: 1)

                cardShape
                    .inset(by: CreditCardMetrics.innerBorderInset)
                    .strokeBorder(CreditCardPalette.innerEdge, lineWidth: 1)

                cardDetails(size: size)
            }
            .clipShape(cardShape)
        }
    }

    private func cardDetails(size: CGSize) -> some View {
        ZStack {
            brandMark(size: size)
                .position(x: size.width * 0.87, y: size.height * 0.19)

            signatureSlots(size: size)

            verificationDots(size: size)

            embossedName(size: size)
                .position(x: size.width * 0.25, y: size.height * 0.91)
        }
    }

    private func brandMark(size: CGSize) -> some View {
        let diameter = size.height * 0.18

        return ZStack {
            embossedCircle(diameter: diameter)
                .offset(x: -diameter * 0.28)
            embossedCircle(diameter: diameter)
                .offset(x: diameter * 0.28)
        }
        .frame(width: diameter * 1.6, height: diameter)
    }

    private func embossedCircle(diameter: CGFloat) -> some View {
        Circle()
            .stroke(CreditCardPalette.embossedDark, lineWidth: 2)
            .overlay {
                Circle()
                    .stroke(CreditCardPalette.embossedLight, lineWidth: 1)
                    .offset(y: -0.5)
            }
            .frame(width: diameter, height: diameter)
    }

    private func signatureSlots(size: CGSize) -> some View {
        HStack(spacing: size.width * 0.035) {
            embossedSlot(width: size.width * 0.22, height: size.height * 0.037)
            embossedSlot(width: size.width * 0.20, height: size.height * 0.037)
        }
        .position(x: size.width * 0.31, y: size.height * 0.72)
    }

    private func embossedSlot(width: CGFloat, height: CGFloat) -> some View {
        Capsule()
            .fill(CreditCardPalette.embossedDark.opacity(0.72))
            .overlay {
                Capsule()
                    .stroke(CreditCardPalette.embossedLight, lineWidth: 1)
                    .offset(y: -0.5)
            }
            .frame(width: width, height: height)
    }

    private func verificationDots(size: CGSize) -> some View {
        HStack(spacing: size.width * 0.019) {
            ForEach(0..<18, id: \.self) { _ in
                Circle()
                    .fill(CreditCardPalette.embossedDark.opacity(0.76))
                    .overlay {
                        Circle()
                            .stroke(CreditCardPalette.embossedLight, lineWidth: 0.7)
                            .offset(y: -0.4)
                    }
                    .frame(width: size.height * 0.038)
            }
        }
        .position(x: size.width * 0.44, y: size.height * 0.82)
    }

    private func embossedName(size: CGSize) -> some View {
        Text("CHRISTOPHER WALLACE")
            .font(.system(size: size.height * 0.037, weight: .medium, design: .rounded))
            .tracking(size.height * 0.012)
            .foregroundStyle(CreditCardPalette.embossedDark.opacity(0.72))
            .shadow(
                color: CreditCardPalette.embossedLight,
                radius: 0,
                y: -0.8
            )
            .lineLimit(1)
    }
}

private struct CreditCardAura: View {
    let time: Double

    var body: some View {
        RoundedRectangle(
            cornerRadius: CreditCardMetrics.cornerRadius,
            style: .continuous
        )
        .fill(
            AngularGradient(
                gradient: Gradient(
                    colors: CreditCardPalette.aiStops + [CreditCardPalette.aiStops[0]]
                ),
                center: .center,
                angle: .degrees(CreditCardMotion.angle(at: time))
            )
        )
        .blur(radius: CreditCardMotion.auraBlurRadius)
        .opacity(CreditCardMotion.auraOpacity)
        .allowsHitTesting(false)
    }
}

private struct CreditCardSnakeStroke: View {
    let time: Double

    var body: some View {
        RoundedRectangle(
            cornerRadius: CreditCardMetrics.cornerRadius,
            style: .continuous
        )
        .strokeBorder(
            AngularGradient(
                gradient: Gradient(stops: CreditCardPalette.snakeStops),
                center: .center,
                angle: .degrees(CreditCardMotion.angle(at: time))
            ),
            lineWidth: CreditCardMotion.snakeWidth
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: CreditCardMetrics.cornerRadius,
                style: .continuous
            )
            .strokeBorder(
                Color.white.opacity(CreditCardMotion.highlightOpacity),
                lineWidth: CreditCardMotion.highlightWidth
            )
        }
        .allowsHitTesting(false)
    }
}

private struct CreditCardParticles: View {
    let size: CGSize
    let time: Double

    var body: some View {
        ZStack {
            ForEach(0..<CreditCardParticleSpecs.count, id: \.self) { index in
                particle(index: index)
            }
        }
        .frame(width: size.width, height: size.height)
        .drawingGroup()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func particle(index: Int) -> some View {
        let age = CreditCardParticleSpecs.age(for: index, at: time)
        let life = (CreditCardParticleSpecs.duration - age)
            / CreditCardParticleSpecs.duration
        let origin = CreditCardPerimeter.pointAndNormal(
            size: size,
            cornerRadius: CreditCardMetrics.cornerRadius,
            fraction: CreditCardParticleSpecs.random(index, salt: 1)
        )
        let spread = CreditCardParticleSpecs.signedRandom(index, salt: 2)
            * CreditCardParticleSpecs.spread
        let direction = Double(
            atan2(-origin.normal.dy, origin.normal.dx)
        ) + spread
        let speed = CreditCardParticleSpecs.speed(for: index)
        let diameter = CreditCardParticleSpecs.diameter(for: index)
        let colorIndex = Int(
            CreditCardParticleSpecs.random(index, salt: 5)
                * Double(CreditCardPalette.aiStops.count)
        ) % CreditCardPalette.aiStops.count

        return Circle()
            .fill(CreditCardPalette.aiStops[colorIndex])
            .frame(width: diameter, height: diameter)
            .scaleEffect(life)
            .opacity(life)
            .modifier(
                CreditCardParticleMotion(
                    time: age,
                    origin: origin.point,
                    speed: speed,
                    angle: direction
                )
            )
            .blendMode(.plusLighter)
    }
}

private struct CreditCardParticleMotion: GeometryEffect {
    var time: Double
    let origin: CGPoint
    let speed: Double
    let angle: Double

    var animatableData: Double {
        get { time }
        set { time = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let dx = speed * time * cos(angle)
        let dy = speed * sin(angle) * time
            - 0.5 * CreditCardParticleSpecs.gravity * time * time
        let transform = CGAffineTransform(
            translationX: origin.x + CGFloat(dx),
            y: origin.y - CGFloat(dy)
        )
        return ProjectionTransform(transform)
    }
}

private enum CreditCardPerimeter {
    struct Sample {
        let point: CGPoint
        let normal: CGVector
    }

    static func pointAndNormal(
        size: CGSize,
        cornerRadius: CGFloat,
        fraction: Double
    ) -> Sample {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2
        let radius = min(cornerRadius, halfHeight)
        let horizontal = size.width - 2 * radius
        let vertical = size.height - 2 * radius
        let arc = .pi * radius / 2
        let perimeter = 2 * horizontal + 2 * vertical + 4 * arc
        var distance = CGFloat(fraction) * perimeter

        if distance < horizontal {
            return Sample(
                point: CGPoint(x: -halfWidth + radius + distance, y: -halfHeight),
                normal: CGVector(dx: 0, dy: -1)
            )
        }
        distance -= horizontal

        if distance < arc {
            return arcSample(
                center: CGPoint(x: halfWidth - radius, y: -halfHeight + radius),
                radius: radius,
                angle: -.pi / 2 + distance / radius
            )
        }
        distance -= arc

        if distance < vertical {
            return Sample(
                point: CGPoint(x: halfWidth, y: -halfHeight + radius + distance),
                normal: CGVector(dx: 1, dy: 0)
            )
        }
        distance -= vertical

        if distance < arc {
            return arcSample(
                center: CGPoint(x: halfWidth - radius, y: halfHeight - radius),
                radius: radius,
                angle: distance / radius
            )
        }
        distance -= arc

        if distance < horizontal {
            return Sample(
                point: CGPoint(x: halfWidth - radius - distance, y: halfHeight),
                normal: CGVector(dx: 0, dy: 1)
            )
        }
        distance -= horizontal

        if distance < arc {
            return arcSample(
                center: CGPoint(x: -halfWidth + radius, y: halfHeight - radius),
                radius: radius,
                angle: .pi / 2 + distance / radius
            )
        }
        distance -= arc

        if distance < vertical {
            return Sample(
                point: CGPoint(x: -halfWidth, y: halfHeight - radius - distance),
                normal: CGVector(dx: -1, dy: 0)
            )
        }
        distance -= vertical

        return arcSample(
            center: CGPoint(x: -halfWidth + radius, y: -halfHeight + radius),
            radius: radius,
            angle: .pi + distance / radius
        )
    }

    private static func arcSample(
        center: CGPoint,
        radius: CGFloat,
        angle: CGFloat
    ) -> Sample {
        let normal = CGVector(dx: cos(angle), dy: sin(angle))
        return Sample(
            point: CGPoint(
                x: center.x + radius * normal.dx,
                y: center.y + radius * normal.dy
            ),
            normal: normal
        )
    }
}

private enum CreditCardMotion {
    // These are the AI Search pill's at-rest values.
    static let period: Double = 4.2
    static let snakeWidth: CGFloat = 0.9
    static let auraBlurRadius: CGFloat = 10
    static let auraOpacity: Double = 0.13
    static let highlightOpacity: Double = 0.06
    static let highlightWidth: CGFloat = 0.5

    static func angle(at time: Double) -> Double {
        time.truncatingRemainder(dividingBy: period) / period * 360
    }
}

private enum CreditCardParticleSpecs {
    // Values retained from the supplied ParticleEffectView.swift.
    static let count = 150
    static let duration: Double = 2
    static let minimumSpeed: Double = 40
    static let maximumSpeed: Double = 80
    static let gravity: Double = 15 * 9.81

    // The button emitter is adapted to the card perimeter.
    static let spread: Double = .pi * 0.24
    static let minimumDiameter: Double = 1.5
    static let maximumDiameter: Double = 4

    static func age(for index: Int, at time: Double) -> Double {
        let delay = random(index, salt: 3) * duration
        return (time + delay).truncatingRemainder(dividingBy: duration)
    }

    static func speed(for index: Int) -> Double {
        minimumSpeed + random(index, salt: 4) * (maximumSpeed - minimumSpeed)
    }

    static func diameter(for index: Int) -> CGFloat {
        CGFloat(
            minimumDiameter
                + random(index, salt: 6) * (maximumDiameter - minimumDiameter)
        )
    }

    static func signedRandom(_ index: Int, salt: UInt64) -> Double {
        random(index, salt: salt) * 2 - 1
    }

    static func random(_ index: Int, salt: UInt64) -> Double {
        var value = UInt64(index + 1) &* 0x9E3779B97F4A7C15
        value &+= salt &* 0xBF58476D1CE4E5B9
        value = (value ^ (value >> 30)) &* 0xBF58476D1CE4E5B9
        value = (value ^ (value >> 27)) &* 0x94D049BB133111EB
        value ^= value >> 31
        return Double(value & 0x00FF_FFFF) / Double(0x0100_0000)
    }
}

private enum CreditCardMetrics {
    static let cardAspectRatio: CGFloat = 1.72
    static let stageAspectRatio: CGFloat = 1.34
    static let cornerRadius = Theme.Radius.card
    static let innerBorderInset: CGFloat = 4
    static let contactShadowRadius: CGFloat = 8
    static let contactShadowOffset: CGFloat = 4
    static let ambientShadowRadius: CGFloat = 24
    static let ambientShadowOffset: CGFloat = 16

    static func cardSize(in available: CGSize) -> CGSize {
        let width = min(
            available.width * 0.84,
            available.height * cardAspectRatio * 0.62
        )
        return CGSize(width: width, height: width / cardAspectRatio)
    }
}

private enum CreditCardPalette {
    static let aiStops: [Color] = [
        Color(red: 0.40, green: 0.30, blue: 1.00),
        Color(red: 0.74, green: 0.38, blue: 1.00),
        Color(red: 1.00, green: 0.45, blue: 0.62),
        Color(red: 1.00, green: 0.62, blue: 0.40),
    ]

    static let snakeStops: [Gradient.Stop] = [
        .init(color: .white, location: 0.00),
        .init(color: aiStops[2], location: 0.05),
        .init(color: aiStops[1], location: 0.14),
        .init(color: aiStops[1].opacity(0), location: 0.30),
        .init(color: .clear, location: 1.00),
    ]

    static let body = LinearGradient(
        colors: [
            Color(red: 0.13, green: 0.06, blue: 0.28),
            Color(red: 0.08, green: 0.035, blue: 0.19),
            Color(red: 0.12, green: 0.05, blue: 0.25),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let surfaceLight = RadialGradient(
        colors: [
            Color(red: 0.52, green: 0.35, blue: 0.90).opacity(0.18),
            .clear,
        ],
        center: UnitPoint(x: 0.72, y: 0.10),
        startRadius: 0,
        endRadius: 360
    )
    static let edgeShade = LinearGradient(
        colors: [.clear, Color.black.opacity(0.34)],
        startPoint: .top,
        endPoint: .bottom
    )
    static let outerEdge = LinearGradient(
        colors: [
            Color.white.opacity(0.42),
            Color(red: 0.55, green: 0.34, blue: 1).opacity(0.76),
            Color.black.opacity(0.70),
        ],
        startPoint: .topTrailing,
        endPoint: .bottomLeading
    )
    static let innerEdge = LinearGradient(
        colors: [
            Color.white.opacity(0.25),
            Color(red: 0.48, green: 0.28, blue: 0.90).opacity(0.18),
            Color.black.opacity(0.42),
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    static let embossedDark = Color(red: 0.025, green: 0.012, blue: 0.06)
    static let embossedLight = Color(red: 0.49, green: 0.34, blue: 0.82).opacity(0.40)
    static let shadow = Color(red: 0.08, green: 0.025, blue: 0.18)
}

#Preview("Animated credit card") {
    ZStack {
        Color(.systemBackground).ignoresSafeArea()
        AnimatedCreditCardView()
            .padding(Theme.Spacing.xl)
    }
}
