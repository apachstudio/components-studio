import SwiftUI

// MARK: - Uladzislau Volchyk — Animating Neumorphic Digits with SwiftUI
//
// https://uvolchyk.me/blog/animating-neumorphic-digits-with-swiftui
//
// Seven-segment display built with SwiftUI `Layout`, neumorphic shadows, and
// animated digit transitions. Tutorial sequence: DigitSegment → DigitLayout →
// SegmentRotation → DigitView → neumorphic Color extension.

// MARK: - Digit Segmentation

struct DigitSegment: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.size.width
        let height = rect.size.height
        let heightCenter = height * 0.5
        return Path { path in
            path.move(to: CGPoint(x: .zero, y: heightCenter))
            path.addLine(to: CGPoint(x: heightCenter, y: .zero))
            path.addLine(to: CGPoint(x: width - heightCenter, y: .zero))
            path.addLine(to: CGPoint(x: width, y: heightCenter))
            path.addLine(to: CGPoint(x: width - heightCenter, y: height))
            path.addLine(to: CGPoint(x: heightCenter, y: height))
            path.closeSubpath()
        }
    }
}

// MARK: - Layout Segmentation

struct DigitLayout: Layout {
    private enum Ratio {
        static let width = 0.8
        static let height = 0.2
        static let spacing = 0.05
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let width = proposal.width ?? .zero
        return CGSize(
            width: width,
            height: width * (2 * Ratio.width + Ratio.height)
        )
    }

    private struct LayoutConfiguration {
        let xOffset: CGFloat
        let yOffset: CGFloat
        let rotation: Angle
    }

    private let segments: [LayoutConfiguration] = [
        /// top
        .init(
            xOffset: Ratio.height * 0.5,
            yOffset: .zero,
            rotation: .zero
        ),
        /// top-left
        .init(
            xOffset: -Ratio.height * 1.5,
            yOffset: Ratio.width * 0.5,
            rotation: .degrees(90.0)
        ),
        /// top-right
        .init(
            xOffset: 0.5,
            yOffset: Ratio.width * 0.5,
            rotation: .degrees(90.0)
        ),
        /// center
        .init(
            xOffset: Ratio.height * 0.5,
            yOffset: Ratio.width,
            rotation: .zero
        ),
        /// bottom-left
        .init(
            xOffset: -Ratio.height * 1.5,
            yOffset: Ratio.width + 2 * Ratio.height,
            rotation: .degrees(90.0)
        ),
        /// bottom-right
        .init(
            xOffset: 0.5,
            yOffset: Ratio.width + 2 * Ratio.height,
            rotation: .degrees(90.0)
        ),
        /// bottom
        .init(
            xOffset: Ratio.height * 0.5,
            yOffset: Ratio.width * 2,
            rotation: .zero
        ),
    ]

    /// Fixed per-segment rotations mirrored from `segments` — same values
    /// `placeSubviews` assigns through `SegmentRotation` in the tutorial.
    static let segmentRotations: [Angle] = [
        .zero, .degrees(90.0), .degrees(90.0), .zero,
        .degrees(90.0), .degrees(90.0), .zero,
    ]

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let segmentWidth = bounds.width * (Ratio.width - 2 * Ratio.spacing)
        let segmentHeight = bounds.width * Ratio.height

        let originX = bounds.minX + Ratio.spacing * bounds.width
        let originY = bounds.minY

        subviews.enumerated().forEach { (index, subview) in
            let size = subview.sizeThatFits(proposal)
            let segment = segments[index]
            let point = CGPoint(
                x: size.width * segment.xOffset,
                y: size.width * segment.yOffset
            )
            subview.place(
                at: CGPoint(x: originX + point.x, y: originY + point.y),
                proposal: .init(width: segmentWidth, height: segmentHeight)
            )
        }
    }
}

struct SegmentRotation: LayoutValueKey {
    static let defaultValue: Binding<Angle>? = nil
}

// MARK: - Encoding + Design Segmentation

struct DigitView: View {
    static let states: [[Bool]] = [
        [true, true, true, false, true, true, true],
        [false, false, true, false, false, true, false],
        [true, false, true, true, true, false, true],
        [true, false, true, true, false, true, true],
        [false, true, true, true, false, true, false],
        [true, true, false, true, false, true, true],
        [true, true, false, true, true, true, true],
        [true, false, true, false, false, true, false],
        [true, true, true, true, true, true, true],
        [true, true, true, true, false, true, true],
    ]

    @Binding var digit: Int
    @State var rotations: [Angle] = Array<Angle>(repeating: .zero, count: 7)

    init(digit: Binding<Int>) {
        let clamped = min(max(digit.wrappedValue, 0), 9)
        _digit = digit
        if digit.wrappedValue != clamped {
            digit.wrappedValue = clamped
        }
    }

    var body: some View {
        DigitLayout {
            ForEach(0..<7) { idx in
                DigitSegment()
                    .fill(Color.neuBackground)
                    .rotationEffect(rotations[idx])
                    .layoutValue(key: SegmentRotation.self, value: $rotations[idx])
                    .shadow(
                        color: .dropShadow,
                        radius: Self.states[digit][idx] ? 4 : .zero,
                        x: Self.states[digit][idx] ? 4 : .zero,
                        y: Self.states[digit][idx] ? 4 : .zero
                    )
                    .shadow(
                        color: .dropLight,
                        radius: Self.states[digit][idx] ? 2 : .zero,
                        x: Self.states[digit][idx] ? -2 : .zero,
                        y: Self.states[digit][idx] ? -2 : .zero
                    )
                    .animation(.easeInOut, value: digit)
            }
        }
        .onAppear {
            rotations = DigitLayout.segmentRotations
        }
    }
}

private extension Color {
    static let neuBackground = Color(red: 240 / 255, green: 240 / 255, blue: 243 / 255)
    static let dropShadow = Color(red: 174 / 255, green: 174 / 255, blue: 192 / 255, opacity: 0.4)
    static let dropLight = Color.white
}

// MARK: - Component Studio stage

struct NeumorphicDigitView: View {
    var title: String = StudioItem.neumorphicDigit.title
    var specs: NeumorphicDigitSpecs = NeumorphicDigitSpecs(
        ComponentSpecState(defaults: StudioItem.neumorphicDigit.specDefaults),
        sheet: StudioItem.neumorphicDigit.specSheet!
    )

    @State private var digit = 0

    var body: some View {
        ShaderPageLayout(title: title, aspectRatio: 1.0) {
            ZStack {
                Color.neuBackground

                DigitView(digit: $digit)
                    .frame(width: specs.displayWidth)
            }
            .task(id: specs.cycleInterval) {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(specs.cycleInterval))
                    withAnimation(.easeInOut) {
                        digit = (digit + 1) % 10
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Aurora.canvas.ignoresSafeArea()
        NeumorphicDigitView()
    }
}
