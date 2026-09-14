import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Flex debit + checking cards in a horizontal, peek-paged carousel.
/// Front faces match the Figma `card carrousel` file (342×216, Inter / ABC Diatype
/// layout, Mastercard, copy affordances). The fill is a pixel-faithful port of
/// the attached Figma "Moving gradient" shader. Tap flips the card vertically
/// with a spring lift; drag pages. Flip kicks the particle field so the card
/// lifts dust ("levantando a poeira").
struct AnimatedCreditCardView: View {
    let specs: AnimatedCreditCardSpecs

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var centeredID: FlexCardKind? = .debit

    var body: some View {
        GeometryReader { proxy in
            let layout = CreditCardMetrics.layout(in: proxy.size)

            TimelineView(.animation(paused: reduceMotion)) { timeline in
                let time = reduceMotion
                    ? 0
                    : timeline.date.timeIntervalSinceReferenceDate

                VStack(spacing: layout.dotSpacing) {
                    carousel(layout: layout, time: time)
                    pageDots
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Flex card carousel")
        .accessibilityHint("Swipe to switch cards. Tap a card to flip it.")
    }

    private func carousel(layout: CreditCardLayout, time: Double) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: layout.cardSpacing) {
                ForEach(FlexCardKind.allCases) { kind in
                    FlexCardPage(
                        kind: kind,
                        size: layout.cardSize,
                        time: time,
                        specs: specs,
                        isCentered: centeredID == kind,
                        reduceMotion: reduceMotion
                    )
                    .frame(width: layout.cardSize.width, height: layout.cardSize.height)
                    .id(kind)
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, layout.peekInset, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $centeredID, anchor: .center)
        .scrollBounceBehavior(.basedOnSize)
        .sensoryFeedback(.selection, trigger: centeredID)
        .modifier(CreditCardScrollEdgeMask())
        .frame(height: layout.cardSize.height + layout.shadowRoom)
    }

    private var pageDots: some View {
        HStack(spacing: Theme.Spacing.xs) {
            ForEach(FlexCardKind.allCases) { kind in
                Circle()
                    .fill(centeredID == kind ? Aurora.ink : Aurora.ink.opacity(0.22))
                    .frame(
                        width: centeredID == kind ? 7 : 6,
                        height: centeredID == kind ? 7 : 6
                    )
                    .animation(CreditCardMotion.pageSpring, value: centeredID)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Card page

private struct FlexCardPage: View {
    let kind: FlexCardKind
    let size: CGSize
    let time: Double
    let specs: AnimatedCreditCardSpecs
    let isCentered: Bool
    let reduceMotion: Bool

    /// 0 = front, 1 = back. Interpolated by the flip spring so lift/dust
    /// can track the motion instead of jumping at the end.
    @State private var flipProgress: Double = 0
    @State private var dustImpulse: Double = 0
    @State private var breathe: CGFloat = 1
    @State private var suppressFlip = false

    private var shader: MovingGradientCardSpecs {
        kind == .debit ? specs.debit : specs.checking
    }

    private var isShowingBack: Bool { flipProgress > 0.5 }

    var body: some View {
        let lift = sin(flipProgress * .pi) * specs.flipLift

        ZStack {
            flippingCard
            if !reduceMotion {
                CreditCardParticles(
                    size: size,
                    time: time,
                    specs: specs,
                    dustImpulse: dustImpulse,
                    lift: lift
                )
            }
        }
        .frame(width: size.width, height: size.height)
        .offset(y: reduceMotion ? 0 : -lift)
        .scaleEffect(breathe)
        .shadow(
            color: CreditCardPalette.shadow.opacity(isCentered ? 0.34 : 0.16),
            radius: isCentered ? CreditCardMetrics.contactShadowRadius : 6,
            y: isCentered ? CreditCardMetrics.contactShadowOffset : 3
        )
        .shadow(
            color: CreditCardPalette.shadow.opacity(isCentered ? 0.22 : 0.10),
            radius: isCentered ? CreditCardMetrics.ambientShadowRadius : 12,
            y: isCentered ? CreditCardMetrics.ambientShadowOffset : 8
        )
        .scrollTransition(.interactive, axis: .horizontal) { content, phase in
            let t = abs(phase.value)
            let scale: CGFloat = reduceMotion
                ? 1
                : 1 - t * 0.06
            let opacity: CGFloat = reduceMotion ? 1 : 1 - t * 0.12
            return content
                .scaleEffect(scale)
                .opacity(opacity)
        }
        .animation(.easeOut(duration: 0.28), value: isCentered)
        .onChange(of: isCentered) { _, centered in
            guard centered, !reduceMotion else { return }
            withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                breathe = 1.016
            } completion: {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) {
                    breathe = 1
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(kind.accessibilityLabel)
        .accessibilityValue(isShowingBack ? "Back" : "Front")
        .accessibilityHint("Tap to flip. Swipe to switch cards.")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: "Flip") { flip() }
    }

    private var flippingCard: some View {
        ZStack {
            face(isBack: false)
                .opacity(isShowingBack ? 0 : 1)
                .accessibilityHidden(isShowingBack)

            face(isBack: true)
                .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
                .opacity(isShowingBack ? 1 : 0)
                .accessibilityHidden(!isShowingBack)
        }
        .rotation3DEffect(
            .degrees(flipProgress * 180),
            axis: (x: 1, y: 0, z: 0),
            perspective: specs.flipPerspective
        )
        .modifier(
            CreditCardPressModifier(
                reduceMotion: reduceMotion,
                onTap: { flip() },
                suppressFlip: $suppressFlip
            )
        )
    }

    private var flipAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.01)
            : .spring(
                response: specs.flipResponse,
                dampingFraction: specs.flipDamping
            )
    }

    private func face(isBack: Bool) -> some View {
        let shape = RoundedRectangle(
            cornerRadius: CreditCardMetrics.cornerRadius,
            style: .continuous
        )

        return ZStack {
            MovingGradientFill(time: time, specs: shader, reduceMotion: reduceMotion)

            if isBack {
                FlexCardBack(kind: kind, size: size)
            } else {
                FlexCardFront(
                    kind: kind,
                    size: size,
                    onCopy: { copied in
                        suppressFlip = true
                        copyToClipboard(copied)
                    }
                )
            }

            shape
                .strokeBorder(CreditCardPalette.outerEdge, lineWidth: 1)

            shape
                .inset(by: CreditCardMetrics.innerBorderInset)
                .strokeBorder(CreditCardPalette.innerEdge, lineWidth: 1)
        }
        .overlay {
            CreditCardAura(time: time, specs: specs)
        }
        .overlay {
            CreditCardSnakeStroke(time: time, specs: specs)
        }
        .clipShape(shape)
        .contentShape(shape)
    }

    private func flip() {
        if suppressFlip {
            suppressFlip = false
            return
        }
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        if !reduceMotion {
            dustImpulse = specs.dustImpulse
            withAnimation(.easeOut(duration: max(0.45, specs.particleDuration * 0.7))) {
                dustImpulse = 0
            }
        }
        withAnimation(flipAnimation) {
            flipProgress = flipProgress < 0.5 ? 1 : 0
        }
    }

    private func copyToClipboard(_ value: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = value
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
}

// MARK: - Faces

private struct FlexCardFront: View {
    let kind: FlexCardKind
    let size: CGSize
    let onCopy: (String) -> Void

    var body: some View {
        let pad = CreditCardMetrics.innerPadding
        VStack(alignment: .leading, spacing: 0) {
            topRow
            Spacer(minLength: 0)
            bottomBlock
        }
        .padding(pad)
        .frame(width: size.width, height: size.height, alignment: .topLeading)
    }

    private var topRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("flex")
                .font(.system(size: size.height * 0.111, weight: .bold, design: .default))
                .tracking(-0.6)
                .foregroundStyle(CreditCardPalette.offWhite)

            Text(kind.subtitle)
                .font(.system(size: size.height * 0.065, weight: .regular, design: .default))
                .foregroundStyle(CreditCardPalette.offWhite.opacity(0.72))
                .lineLimit(1)

            Spacer(minLength: 8)
            MastercardMark(height: size.height * 0.15)
        }
        .frame(height: size.height * 0.167, alignment: .top)
    }

    @ViewBuilder
    private var bottomBlock: some View {
        switch kind {
        case .debit:
            debitNumbers
        case .checking:
            checkingNumbers
        }
    }

    private var debitNumbers: some View {
        VStack(alignment: .leading, spacing: size.height * 0.055) {
            HStack(alignment: .center, spacing: 8) {
                Text(kind.primaryValue)
                    .font(.system(size: size.height * 0.074, weight: .regular, design: .default))
                    .tracking(1.1)
                    .monospacedDigit()
                    .foregroundStyle(CreditCardPalette.offWhite.opacity(0.92))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                copyGlyph { onCopy(kind.primaryValue) }
            }

            HStack(alignment: .firstTextBaseline, spacing: size.width * 0.08) {
                labeledValue(label: "Exp", value: kind.secondaryValue, copyable: false)
                labeledValue(label: "CVC", value: kind.tertiaryValue, copyable: false)
                Spacer(minLength: 0)
            }
        }
    }

    private var checkingNumbers: some View {
        VStack(alignment: .leading, spacing: size.height * 0.07) {
            checkingRow(label: "Routing number", value: kind.primaryValue)
            checkingRow(label: "Account number", value: kind.secondaryValue)
        }
    }

    private func checkingRow(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label)
                .font(.system(size: size.height * 0.056, weight: .regular, design: .default))
                .foregroundStyle(CreditCardPalette.offWhite.opacity(0.70))
            Spacer(minLength: 8)
            Text(value)
                .font(.system(size: size.height * 0.065, weight: .regular, design: .default))
                .tracking(0.4)
                .monospacedDigit()
                .foregroundStyle(CreditCardPalette.offWhite.opacity(0.94))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            copyCaption { onCopy(value) }
        }
    }

    private func labeledValue(label: String, value: String, copyable: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(label)
                .font(.system(size: size.height * 0.056, weight: .regular, design: .default))
                .foregroundStyle(CreditCardPalette.offWhite.opacity(0.62))
            Text(value)
                .font(.system(size: size.height * 0.074, weight: .regular, design: .default))
                .tracking(0.6)
                .monospacedDigit()
                .foregroundStyle(CreditCardPalette.offWhite.opacity(0.94))
            if copyable {
                copyGlyph { onCopy(value) }
            }
        }
    }

    private func copyGlyph(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "square.on.square")
                .font(.system(size: size.height * 0.055, weight: .medium))
                .foregroundStyle(CreditCardPalette.offWhite.opacity(0.72))
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Copy")
    }

    private func copyCaption(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("COPY")
                .font(.system(size: size.height * 0.048, weight: .regular, design: .default))
                .tracking(0.8)
                .foregroundStyle(CreditCardPalette.offWhite.opacity(0.78))
                .padding(.horizontal, 4)
                .padding(.vertical, 6)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Copy")
    }
}

private struct FlexCardBack: View {
    let kind: FlexCardKind
    let size: CGSize

    var body: some View {
        let pad = CreditCardMetrics.innerPadding
        VStack(alignment: .leading, spacing: size.height * 0.08) {
            HStack(alignment: .firstTextBaseline) {
                Text("flex")
                    .font(.system(size: size.height * 0.111, weight: .bold, design: .default))
                    .tracking(-0.6)
                    .foregroundStyle(CreditCardPalette.offWhite)
                Spacer()
                Text("Connected")
                    .font(.system(size: size.height * 0.056, weight: .regular, design: .default))
                    .foregroundStyle(CreditCardPalette.offWhite.opacity(0.70))
            }

            HStack(spacing: size.width * 0.035) {
                ForEach(kind.billers, id: \.self) { biller in
                    Image(biller)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: size.height * 0.28,
                            height: size.height * 0.28
                        )
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.chip, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: Theme.Radius.chip, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5)
                        }
                        .accessibilityLabel(biller.replacingOccurrences(of: "Biller", with: ""))
                }
                Spacer(minLength: 0)
            }

            Spacer(minLength: 0)

            Text(kind.backCaption)
                .font(.system(size: size.height * 0.052, weight: .regular, design: .default))
                .foregroundStyle(CreditCardPalette.offWhite.opacity(0.62))
        }
        .padding(pad)
        .frame(width: size.width, height: size.height, alignment: .topLeading)
    }
}

// MARK: - Mastercard

private struct MastercardMark: View {
    let height: CGFloat

    var body: some View {
        let diameter = height
        HStack(spacing: -diameter * 0.38) {
            Circle().fill(Color(red: 0.922, green: 0.0, blue: 0.106))
            Circle().fill(Color(red: 0.969, green: 0.620, blue: 0.106))
        }
        .frame(width: diameter * 1.62, height: diameter)
        .accessibilityLabel("Mastercard")
        .accessibilityHidden(true)
    }
}

// MARK: - Moving gradient fill

private struct MovingGradientFill: View {
    let time: Double
    let specs: MovingGradientCardSpecs
    let reduceMotion: Bool

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let aspect = size.width / max(size.height, 1)
            let zoom = CreditCardMetrics.mappedZoom(percent: specs.zoom, aspect: aspect)
            let rotationSpeed = reduceMotion
                ? 0
                : min(0.25, max(0, specs.rotationSpeed / 100 * 0.25))
            let shading = specs.material < 0.5 ? 0.0 : 0.5

            Rectangle()
                .fill(Color.white)
                .colorEffect(
                    ShaderLibrary.movingGradient(
                        .float2(Float(size.width), Float(size.height)),
                        .float(Float(time)),
                        .float4(
                            Float(specs.detail),
                            Float(specs.intensity),
                            Float(specs.twist),
                            Float(specs.warp)
                        ),
                        .float4(
                            Float(zoom),
                            Float(rotationSpeed),
                            Float(specs.morphSpeed),
                            Float(specs.material)
                        ),
                        .float4(
                            Float(specs.gradientBalance / 100),
                            Float(specs.gradientMethod),
                            3,
                            Float(shading)
                        ),
                        .float4(
                            Float(specs.stop0R), Float(specs.stop0G), Float(specs.stop0B), 1
                        ),
                        .float4(
                            Float(specs.stop1R), Float(specs.stop1G), Float(specs.stop1B), 1
                        ),
                        .float4(
                            Float(specs.stop2R), Float(specs.stop2G), Float(specs.stop2B), 1
                        ),
                        .float4(
                            Float(specs.stop2R), Float(specs.stop2G), Float(specs.stop2B), 1
                        ),
                        .float4(0, 0.5, 1, 1)
                    )
                )
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Stroke + aura (kept from the AI card)

private struct CreditCardAura: View {
    let time: Double
    let specs: AnimatedCreditCardSpecs

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
                angle: .degrees(angle)
            )
        )
        .blur(radius: specs.auraBlur)
        .opacity(specs.auraOpacity)
        .allowsHitTesting(false)
    }

    private var angle: Double {
        time.truncatingRemainder(dividingBy: specs.snakePeriod)
            / specs.snakePeriod * 360
    }
}

private struct CreditCardSnakeStroke: View {
    let time: Double
    let specs: AnimatedCreditCardSpecs

    var body: some View {
        RoundedRectangle(
            cornerRadius: CreditCardMetrics.cornerRadius,
            style: .continuous
        )
        .strokeBorder(
            AngularGradient(
                gradient: Gradient(stops: CreditCardPalette.snakeStops),
                center: .center,
                angle: .degrees(angle)
            ),
            lineWidth: specs.snakeWidth
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: CreditCardMetrics.cornerRadius,
                style: .continuous
            )
            .strokeBorder(
                Color.white.opacity(CreditCardMetrics.highlightOpacity),
                lineWidth: CreditCardMetrics.highlightWidth
            )
        }
        .allowsHitTesting(false)
    }

    private var angle: Double {
        time.truncatingRemainder(dividingBy: specs.snakePeriod)
            / specs.snakePeriod * 360
    }
}

// MARK: - Particles

private struct CreditCardParticles: View {
    let size: CGSize
    let time: Double
    let specs: AnimatedCreditCardSpecs
    let dustImpulse: Double
    let lift: Double

    var body: some View {
        ZStack {
            ForEach(0..<specs.particleCount, id: \.self) { index in
                particle(index: index)
            }
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func particle(index: Int) -> some View {
        let age = CreditCardParticleEngine.age(
            for: index,
            at: time,
            duration: specs.particleDuration
        )
        let life = (specs.particleDuration - age) / specs.particleDuration
        var origin = CreditCardParticleEngine.origin(for: index, size: size)
        // Flip lifts dust off the card face, not just the top edge.
        let fromFace = CreditCardParticleEngine.random(index, salt: 11)
        origin.y += CGFloat(dustImpulse * fromFace * Double(size.height) * 0.55)

        let spread = CreditCardParticleEngine.signedRandom(index, salt: 2)
            * specs.particleSpread * .pi
        let direction = Double.pi / 2 + spread
            + CreditCardParticleEngine.signedRandom(index, salt: 12) * dustImpulse * 0.55
        let speed = CreditCardParticleEngine.speed(for: index, maximum: specs.particleSpeed)
            + dustImpulse * specs.dustSpeed
            + lift * 1.4
        let diameter = CreditCardParticleEngine.diameter(
            for: index,
            maximum: specs.particleSize * (1 + dustImpulse * 0.35)
        )
        let opacity = CreditCardParticleEngine.opacity(
            for: index,
            maximum: min(1, specs.particleOpacity * (1 + dustImpulse * 0.8))
        )
        let colorIndex = Int(
            CreditCardParticleEngine.random(index, salt: 5)
                * Double(CreditCardPalette.particleColors.count)
        ) % CreditCardPalette.particleColors.count
        let color = CreditCardPalette.particleColors[colorIndex]

        return Circle()
            .fill(color)
            .frame(width: diameter, height: diameter)
            .scaleEffect(life)
            .opacity(life * opacity)
            .modifier(
                CreditCardParticleMotion(
                    time: age,
                    origin: origin,
                    speed: speed,
                    angle: direction,
                    gravity: specs.particleGravity * (1 - dustImpulse * 0.22)
                )
            )
            .shadow(color: color.opacity(0.42), radius: diameter)
            .blendMode(.plusLighter)
    }
}

private struct CreditCardParticleMotion: GeometryEffect {
    var time: Double
    let origin: CGPoint
    let speed: Double
    let angle: Double
    let gravity: Double

    var animatableData: Double {
        get { time }
        set { time = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let dx = speed * time * cos(angle)
        let dy = speed * sin(angle) * time - 0.5 * gravity * time * time
        let transform = CGAffineTransform(
            translationX: origin.x + CGFloat(dx),
            y: origin.y - CGFloat(dy)
        )
        return ProjectionTransform(transform)
    }
}

private enum CreditCardParticleEngine {
    static let horizontalStart: Double = 0.18
    static let horizontalSpan: Double = 0.64
    static let verticalJitter: Double = 8

    static func age(for index: Int, at time: Double, duration: Double) -> Double {
        let delay = random(index, salt: 3) * duration
        return (time + delay).truncatingRemainder(dividingBy: duration)
    }

    static func speed(for index: Int, maximum: Double) -> Double {
        maximum * (0.5 + random(index, salt: 4) * 0.5)
    }

    static func diameter(for index: Int, maximum: Double) -> CGFloat {
        CGFloat(maximum * (0.36 + random(index, salt: 6) * 0.64))
    }

    static func opacity(for index: Int, maximum: Double) -> Double {
        maximum * (0.33 + random(index, salt: 7) * 0.67)
    }

    static func origin(for index: Int, size: CGSize) -> CGPoint {
        let horizontalFraction = horizontalStart + random(index, salt: 1) * horizontalSpan
        return CGPoint(
            x: (horizontalFraction - 0.5) * size.width,
            y: -size.height / 2 - CGFloat(random(index, salt: 8) * verticalJitter)
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

// MARK: - Gestures

/// Press scales the card 2%. A short release flips; a real drag is left
/// for the horizontal carousel (same 10pt threshold as the vertical deck).
private struct CreditCardPressModifier: ViewModifier {
    let reduceMotion: Bool
    let onTap: () -> Void
    @Binding var suppressFlip: Bool

    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed && !reduceMotion ? 0.985 : 1)
            .animation(
                isPressed
                    ? .easeOut(duration: 0.12)
                    : .spring(response: 0.32, dampingFraction: 0.82),
                value: isPressed
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed { isPressed = true }
                    }
                    .onEnded { value in
                        isPressed = false
                        let dx = abs(value.translation.width)
                        let dy = abs(value.translation.height)
                        if suppressFlip {
                            suppressFlip = false
                            return
                        }
                        if dx < 10 && dy < 10 {
                            onTap()
                        }
                    }
            )
    }
}

private struct CreditCardScrollEdgeMask: ViewModifier {
    func body(content: Content) -> some View {
        content.scrollEdgeEffectHidden(true, for: [.leading, .trailing])
    }
}

// MARK: - Model

private enum FlexCardKind: String, CaseIterable, Identifiable, Hashable {
    case debit
    case checking

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .debit: return "Debit Card"
        case .checking: return "Checking Account"
        }
    }

    var primaryValue: String {
        switch self {
        case .debit: return "1234 5678 9012 1234"
        case .checking: return "9876543212834"
        }
    }

    var secondaryValue: String {
        switch self {
        case .debit: return "08/30"
        case .checking: return "093809328912"
        }
    }

    var tertiaryValue: String { "783" }

    var billers: [String] {
        switch self {
        case .debit: return ["BillerTMobile", "BillerEducation", "BillerGeico"]
        case .checking: return ["BillerStateFarm", "BillerYardi", "BillerGeico"]
        }
    }

    var backCaption: String {
        switch self {
        case .debit: return "Billers on this card"
        case .checking: return "Accounts linked here"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .debit: return "Flex debit card ending 1234"
        case .checking: return "Flex checking account"
        }
    }
}

private enum CreditCardMotion {
    static let pageSpring: Animation = .spring(response: 0.42, dampingFraction: 0.82)
}

private struct CreditCardLayout {
    let cardSize: CGSize
    let peekInset: CGFloat
    let cardSpacing: CGFloat
    let dotSpacing: CGFloat
    let shadowRoom: CGFloat
}

private enum CreditCardMetrics {
    /// Figma debit card on the 402pt iPhone frame.
    static let designWidth: CGFloat = 342
    static let designHeight: CGFloat = 216
    static let designCanvasWidth: CGFloat = 402
    static let cardAspectRatio: CGFloat = designWidth / designHeight
    static let cornerRadius: CGFloat = 24
    static let innerPadding: CGFloat = Theme.Spacing.sm
    static let innerBorderInset: CGFloat = 4
    static let contactShadowRadius: CGFloat = 8
    static let contactShadowOffset: CGFloat = 4
    static let ambientShadowRadius: CGFloat = 24
    static let ambientShadowOffset: CGFloat = 16
    static let highlightOpacity: Double = 0.06
    static let highlightWidth: CGFloat = 0.5

    static func layout(in available: CGSize) -> CreditCardLayout {
        let scale = min(1.15, available.width / designCanvasWidth)
        let width = min(designWidth * scale, available.width * 0.88)
        let height = width / cardAspectRatio
        let peek = max(24, (available.width - width) / 2)
        return CreditCardLayout(
            cardSize: CGSize(width: width, height: height),
            peekInset: peek,
            cardSpacing: Theme.Spacing.sm,
            dotSpacing: Theme.Spacing.md,
            shadowRoom: 28
        )
    }

    /// Port of the Figma shader's zoom-percent → camera zoom mapping.
    static func mappedZoom(percent: Double, aspect: CGFloat) -> Double {
        let maximumZoom = 10.0
        let diagonal = sqrt(1 + Double(aspect * aspect))
        let safeRadius = 0.72
        let cameraDistance = 3.0
        let baseFocalLength = 1.73
        let targetCoverZoom = 4.0
        let targetFocalLength = baseFocalLength * targetCoverZoom
        let requiredRadius = cameraDistance * diagonal
            / sqrt(targetFocalLength * targetFocalLength + diagonal * diagonal)
        let sphereScale = max(0.82, requiredRadius / safeRadius)
        let conservativeRadius = min(cameraDistance - 0.001, sphereScale * safeRadius)
        let perspectiveDepth = sqrt(
            max(0.0001, cameraDistance * cameraDistance - conservativeRadius * conservativeRadius)
        )
        let unclampedMinimumCoverZoom =
            (diagonal * perspectiveDepth / (baseFocalLength * conservativeRadius)) * 1.12
        let minimumCoverZoom = min(maximumZoom, max(0.5, unclampedMinimumCoverZoom))
        let minimumZoom = min(maximumZoom, max(0.5, minimumCoverZoom * 0.65))
        let zoomProgress = min(100, max(0, percent)) / 100
        let unclampedZoom = minimumZoom * pow(maximumZoom / minimumZoom, zoomProgress)
        return min(maximumZoom, max(minimumZoom, unclampedZoom))
    }
}

private enum CreditCardPalette {
    static let offWhite = Color(red: 0.98, green: 0.98, blue: 1.0)

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

    static let particleColors: [Color] = [
        .white,
        aiStops[0],
        aiStops[1],
    ]

    static let outerEdge = LinearGradient(
        colors: [
            Color.white.opacity(0.42),
            Color(red: 0.55, green: 0.34, blue: 1).opacity(0.55),
            Color.black.opacity(0.45),
        ],
        startPoint: .topTrailing,
        endPoint: .bottomLeading
    )

    static let innerEdge = LinearGradient(
        colors: [
            Color.white.opacity(0.22),
            Color(red: 0.48, green: 0.28, blue: 0.90).opacity(0.14),
            Color.black.opacity(0.28),
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let shadow = Color(red: 0.08, green: 0.025, blue: 0.18)
}

#Preview("Flex card carousel") {
    let item = StudioItem.animatedCreditCard
    let specs = AnimatedCreditCardSpecs(
        ComponentSpecState(defaults: item.specDefaults),
        sheet: item.specSheet!
    )

    ZStack {
        Color(.systemBackground).ignoresSafeArea()
        AnimatedCreditCardView(specs: specs)
            .padding(.vertical, Theme.Spacing.xl)
    }
}
