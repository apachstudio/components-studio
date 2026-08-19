import SwiftUI

/// Touch-driven dot grid with glow, attraction, and repulsion modes.
struct DottedBackgroundView: View {
    var title: String = StudioItem.dottedBackground.title
    var specs: DottedBackgroundSpecs = DottedBackgroundSpecs(
        ComponentSpecState(defaults: StudioItem.dottedBackground.specDefaults),
        sheet: StudioItem.dottedBackground.specSheet!
    )

    @State private var touchPosition: CGPoint = .zero
    @State private var intensity: CGFloat = 0

    var body: some View {
        ShaderPageLayout(title: title, aspectRatio: 0.72) {
            GeometryReader { geo in
                let size = geo.size

                Color.black
                    .colorEffect(
                        ShaderLibrary.dottedBackground(
                            .float2(Float(size.width), Float(size.height)),
                            .float2(Float(touchPosition.x), Float(touchPosition.y)),
                            .float(Float(specs.mode)),
                            .float(Float(intensity)),
                            .float(Float(specs.gridDensity)),
                            .float(Float(specs.influenceRadius)),
                            .float(Float(specs.maxDisplacement))
                        )
                    )
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                touchPosition = value.location
                                withAnimation(.easeOut(duration: 0.15)) {
                                    intensity = 1
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.easeOut(duration: 0.5)) {
                                    intensity = 0
                                }
                            }
                    )
                    .onAppear {
                        touchPosition = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
                    }
            }
        }
    }
}

#Preview {
    ZStack {
        Aurora.canvas.ignoresSafeArea()
        DottedBackgroundView()
    }
}
