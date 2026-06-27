import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Refractive glass lens card (text or sphere content)
//
// Uses the SAME refractive glass lens as `RefractiveGlassView`
// (the shared `refractiveGlass` Metal shader + draggable lens). Dragging the
// lens magnifies / refracts the card content underneath.

struct BubbleTextRippleView: View {
    enum CardContent: Hashable {
        /// Water-drops photo + "apach" in Dripdrop — Refractive Text.
        case text
        /// Black card + centered sphere image — Refractive Sphere.
        case sphere
    }

    var title: String = StudioItem.bubbleTextRipple.title
    var content: CardContent = .sphere
    var specs: BubbleTextRippleSpecs = BubbleTextRippleSpecs(
        ComponentSpecState(defaults: StudioItem.bubbleTextRipple.specDefaults),
        sheet: StudioItem.bubbleTextRipple.specSheet!
    )

    /// Normalized lens center [0,1]; seeded once the card is laid out.
    @State private var glassCenter: CGPoint? = nil
    @State private var lensVelocity = CGPoint.zero
    @State private var previousSample: (center: CGPoint, time: Date)? = nil

    private let cardShape = RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
    private let idleSwirlSpeed: Double = 0.55

    private static let apachLabel = "apach"
    private static let textHorizontalPadding: CGFloat = 12

    init(
        title: String = StudioItem.bubbleTextRipple.title,
        content: CardContent = .sphere,
        specs: BubbleTextRippleSpecs = BubbleTextRippleSpecs(
            ComponentSpecState(defaults: StudioItem.bubbleTextRipple.specDefaults),
            sheet: StudioItem.bubbleTextRipple.specSheet!
        )
    ) {
        self.title = title
        self.content = content
        self.specs = specs
    }

    var body: some View {
        ShaderPageLayout(title: title, aspectRatio: 0.78) {
            TimelineView(.animation) { context in
                GeometryReader { geo in
                    let size = geo.size
                    let center = glassCenter ?? CGPoint(x: 0.5, y: 0.5)
                    let swirlPhase = Float(context.date.timeIntervalSinceReferenceDate * idleSwirlSpeed)

                    card(size: size)
                        .drawingGroup()
                        .layerEffect(
                            ShaderLibrary.refractiveGlass(
                                .float2(Float(size.width), Float(size.height)),
                                .float2(Float(center.x), Float(center.y)),
                                .float(Float(specs.glassRadius)),
                                .float(Float(specs.refraction)),
                                .float(Float(max(specs.falloff, 0.01))),
                                .float(Float(specs.swirl)),
                                .float(Float(specs.edgeThickness)),
                                .float(Float(specs.chromatic)),
                                .float(Float(specs.rimIntensity)),
                                .float(Float(specs.shadowStrength)),
                                .float(Float(specs.shadowBlur)),
                                .float(Float(specs.shadowOffset)),
                                .float(swirlPhase),
                                .float2(Float(lensVelocity.x), Float(lensVelocity.y))
                            ),
                            maxSampleOffset: CGSize(width: 240, height: 240)
                        )
                        .clipShape(cardShape)
                        .contentShape(cardShape)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let normalized = CGPoint(
                                        x: value.location.x / max(size.width, 1),
                                        y: value.location.y / max(size.height, 1)
                                    )
                                    trackVelocity(center: normalized, at: Date())
                                    glassCenter = normalized
                                }
                                .onEnded { value in
                                    lensVelocity = CGPoint(
                                        x: value.velocity.width / max(size.width, 1),
                                        y: value.velocity.height / max(size.height, 1)
                                    )
                                    previousSample = nil
                                }
                        )
                        .onAppear {
                            if glassCenter == nil {
                                glassCenter = CGPoint(x: 0.5, y: 0.5)
                            }
                        }
                }
            }
        }
    }

    private func trackVelocity(center: CGPoint, at time: Date) {
        if let prev = previousSample {
            let dt = time.timeIntervalSince(prev.time)
            if dt > 1e-4 {
                lensVelocity = CGPoint(
                    x: (center.x - prev.center.x) / dt,
                    y: (center.y - prev.center.y) / dt
                )
            }
        }
        previousSample = (center, time)
    }

    @ViewBuilder
    private func card(size: CGSize) -> some View {
        switch content {
        case .text:
            textCard(size: size)
        case .sphere:
            sphereCard(size: size)
        }
    }

    /// Water-drops photo + "apach" typography.
    private func textCard(size: CGSize) -> some View {
        let fontSize = Self.fittedDripdropSize(cardWidth: size.width)
        let verticalOffset = Self.dripdropVerticalCenterOffset(fontSize: fontSize)

        return ZStack {
            Image("RefractiveTextBG")
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .clipped()

            Text(Self.apachLabel)
                .font(AppFont.dripdrop(fontSize))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .frame(width: size.width, height: size.height)
                .offset(y: verticalOffset)
        }
        .frame(width: size.width, height: size.height)
    }

    /// Black card + centered sphere image.
    private func sphereCard(size: CGSize) -> some View {
        ZStack {
            Color.black

            Image("RefractiveSphere")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: size.width, maxHeight: size.height)
        }
        .frame(width: size.width, height: size.height)
    }

    private static func dripdropUIFont(size: CGFloat) -> UIFont {
        let postScript = "Dripdrop-Regular"
        return UIFont(name: postScript, size: size)
            ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }

    /// Scales Dripdrop so `"apach"` spans the card width minus 12pt side insets.
    private static func fittedDripdropSize(cardWidth: CGFloat) -> CGFloat {
        let availableWidth = max(0, cardWidth - textHorizontalPadding * 2)
        guard availableWidth > 0 else { return 100 }

        let referenceSize: CGFloat = 100
        let referenceFont = dripdropUIFont(size: referenceSize)
        let measuredWidth = (apachLabel as NSString).size(withAttributes: [.font: referenceFont]).width
        guard measuredWidth > 0 else { return referenceSize }
        return referenceSize * (availableWidth / measuredWidth)
    }

    /// Optical vertical correction — Dripdrop's line box sits above the glyph center.
    private static func dripdropVerticalCenterOffset(fontSize: CGFloat) -> CGFloat {
        let font = dripdropUIFont(size: fontSize)
        let rect = (apachLabel as NSString).boundingRect(
            with: .zero,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return (font.lineHeight - rect.height) / 2 - rect.origin.y
    }
}

#Preview("Refractive Sphere") {
    ZStack {
        Aurora.canvas.ignoresSafeArea()
        BubbleTextRippleView(content: .sphere)
    }
}

#Preview("Refractive Text") {
    ZStack {
        Aurora.canvas.ignoresSafeArea()
        BubbleTextRippleView(
            title: "Refractive Text",
            content: .text,
            specs: BubbleTextRippleSpecs(
                ComponentSpecState(defaults: StudioItem.refractiveText.specDefaults),
                sheet: StudioItem.refractiveText.specSheet!
            )
        )
    }
}
