import SwiftUI

/// Touch-driven fisheye bulge over a monochrome dot grid on black.
struct SphericMeshView: View {
    var title: String = StudioItem.sphericMesh.title
    var specs: SphericMeshSpecs = SphericMeshSpecs(
        ComponentSpecState(defaults: StudioItem.sphericMesh.specDefaults),
        sheet: StudioItem.sphericMesh.specSheet!
    )

    @State private var pointer: CGPoint = .zero

    var body: some View {
        ShaderPageLayout(title: title, aspectRatio: 0.72) {
            GeometryReader { geo in
                let size = geo.size

                Rectangle()
                    .fill(.black)
                    .colorEffect(
                        ShaderLibrary.sphericMesh(
                            .float2(Float(size.width), Float(size.height)),
                            .float2(Float(pointer.x), Float(pointer.y)),
                            .float(Float(specs.gridDensity)),
                            .float(Float(specs.bulgeStrength)),
                            .float(Float(specs.dotScale))
                        )
                    )
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                pointer = value.location
                            }
                    )
                    .onAppear {
                        pointer = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
                    }
            }
        }
    }
}

#Preview {
    ZStack {
        Aurora.canvas.ignoresSafeArea()
        SphericMeshView()
    }
}
