import SwiftUI

/// Custom shader-based frosted glass panel over a drifting AI gradient.
/// Complements the native `.glassEffect` sample — this one is pure Metal.
struct GlassEffectShaderView: View {
    var title: String = StudioItem.glassEffectShader.title
    var specs: GlassEffectShaderSpecs = GlassEffectShaderSpecs(
        ComponentSpecState(defaults: StudioItem.glassEffectShader.specDefaults),
        sheet: StudioItem.glassEffectShader.specSheet!
    )

    @State private var pointer: CGPoint = .zero

    var body: some View {
        ShaderPageLayout(title: title, aspectRatio: 0.85) {
            TimelineView(.animation) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate

                GeometryReader { geo in
                    let size = geo.size

                    ZStack {
                        Aurora.AI.drifting(time: time)
                            .overlay {
                                Circle()
                                    .fill(Color.white.opacity(0.35))
                                    .frame(width: size.width * 0.55)
                                    .blur(radius: 40)
                                    .offset(x: -size.width * 0.15, y: -size.height * 0.1)
                            }

                        RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                            .fill(.white.opacity(0.08))
                            .overlay {
                                VStack(spacing: Theme.Spacing.sm) {
                                    Text("Glass Effect")
                                        .font(AppFont.manrope(22, .semibold, relativeTo: .title3))
                                    Text("Drag to refract")
                                        .font(AppFont.manrope(14, .regular, relativeTo: .subheadline))
                                        .foregroundStyle(Color.secondary)
                                }
                                .foregroundStyle(Aurora.ink)
                            }
                            .layerEffect(
                                ShaderLibrary.glassRefraction(
                                    .float2(Float(size.width), Float(size.height)),
                                    .float2(Float(pointer.x), Float(pointer.y)),
                                    .float(Float(time) * Float(specs.breatheSpeed)),
                                    .float(Float(specs.lensStrength)),
                                    .float(Float(specs.frostAmount)),
                                    .float(Float(specs.chromaticSplit))
                                ),
                                maxSampleOffset: CGSize(width: 40, height: 40)
                            )
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        pointer = value.location
                                    }
                            )
                            .padding(Theme.Spacing.xl)
                    }
                    .onAppear {
                        pointer = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Aurora.canvas.ignoresSafeArea()
        GlassEffectShaderView()
    }
}
