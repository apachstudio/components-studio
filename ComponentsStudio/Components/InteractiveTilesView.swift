import SwiftUI

/// Interactive gradient tile grid — Uladzislau Volchyk tutorial
/// (MeshGradient + gesture-driven corner radii + Metal grain texture).
struct InteractiveTilesView: View {
    var title: String = StudioItem.interactiveTiles.title
    var specs: InteractiveTilesSpecs = InteractiveTilesSpecs(
        ComponentSpecState(defaults: StudioItem.interactiveTiles.specDefaults),
        sheet: StudioItem.interactiveTiles.specSheet!
    )

    let rows = 6
    let columns = 8
    let tileSize: CGFloat = 48
    let spacing: CGFloat = 2

    var gridSize: CGSize {
        CGSize(
            width: CGFloat(columns) * tileSize + CGFloat(columns - 1) * spacing,
            height: CGFloat(rows) * tileSize + CGFloat(rows - 1) * spacing
        )
    }

    @State private var dragPosition: CGPoint = .zero
    @State private var cornerRadii: [[CGFloat]] = []

    var halfTile: CGFloat { tileSize / 2 }
    var maxCornerRadius: CGFloat { specs.maxCornerRadius }
    var minCornerRadius: CGFloat { specs.minCornerRadius }
    var radiusRange: CGFloat { maxCornerRadius - minCornerRadius }

    private var aspectRatio: CGFloat { gridSize.width / gridSize.height }

    var body: some View {
        ShaderPageLayout(title: title, aspectRatio: aspectRatio) {
            GeometryReader { geometry in
                let offset = CGPoint(
                    x: (geometry.size.width - gridSize.width) / 2,
                    y: (geometry.size.height - gridSize.height) / 2
                )

                MeshGradient(
                    width: 4, height: 3,
                    points: [
                        [0.00, 0.0], [0.33, 0.0], [0.66, 0.0], [1.00, 0.0],
                        [0.00, 0.42], [0.24, 0.38], [0.78, 0.39], [1.00, 0.44],
                        [0.00, 1.00], [0.26, 1.00], [0.40, 1.00], [1.00, 1.00]
                    ],
                    colors: [
                        Color(red: 18/255, green: 20/255, blue: 74/255),
                        Color(red: 110/255, green: 0/255, blue: 170/255),
                        Color(red: 1.00, green: 0.26, blue: 0.68),
                        Color(red: 1.00, green: 0.23, blue: 0.48),

                        Color(red: 0.98, green: 0.20, blue: 0.60),
                        Color(red: 1.00, green: 0.55, blue: 0.10),
                        Color(red: 1.00, green: 0.80, blue: 0.40),
                        Color.white.opacity(0.85),

                        Color(red: 12/255, green: 15/255, blue: 54/255),
                        Color(red: 80/255, green: 60/255, blue: 220/255),
                        Color(red: 93/255, green: 24/255, blue: 120/255),
                        Color(red: 8/255, green: 12/255, blue: 60/255),
                    ]
                )
                .grain(opacity: specs.grainOpacity)
                .frame(width: gridSize.width, height: gridSize.height)
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2
                )
                .mask(
                    InteractiveTilesGridMaskView(
                        rows: rows,
                        columns: columns,
                        tileSize: tileSize,
                        spacing: spacing,
                        offset: offset,
                        gridSize: gridSize,
                        cornerRadii: cornerRadii,
                        minCornerRadius: minCornerRadius,
                        animationDuration: specs.animationDuration
                    )
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            dragPosition = value.location
                            updateCornerRadii(geometry: geometry)
                        }
                        .onEnded { _ in
                            resetCornerRadii()
                        }
                )
                .onAppear {
                    guard cornerRadii.isEmpty else { return }
                    cornerRadii = Array(
                        repeating: Array(repeating: minCornerRadius, count: columns),
                        count: rows
                    )
                }
            }
        }
    }

    private func updateCornerRadii(geometry: GeometryProxy) {
        let offset = CGPoint(
            x: (geometry.size.width - gridSize.width) / 2,
            y: (geometry.size.height - gridSize.height) / 2
        )

        let influenceDistance = specs.influenceDistance

        for (row, rowArray) in cornerRadii.enumerated() {
            for (col, _) in rowArray.enumerated() {
                let squarePosition = CGPoint(
                    x: offset.x + CGFloat(col) * tileSize + halfTile,
                    y: offset.y + CGFloat(row) * tileSize + halfTile
                )

                let distance = dragPosition.distance(to: squarePosition)
                let clampedDistance = min(distance, influenceDistance)
                let normalizedDistance = clampedDistance / influenceDistance
                let cornerRadius = minCornerRadius + radiusRange * (1.0 - normalizedDistance)

                cornerRadii[row][col] = cornerRadius
            }
        }
    }

    private func resetCornerRadii() {
        for (row, rowArray) in cornerRadii.enumerated() {
            for (col, _) in rowArray.enumerated() {
                cornerRadii[row][col] = minCornerRadius
            }
        }
    }
}

private extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = x - point.x
        let dy = y - point.y
        return sqrt(dx * dx + dy * dy)
    }
}

private struct InteractiveTilesGridMaskView: View {
    let rows: Int
    let columns: Int
    let tileSize: CGFloat
    let spacing: CGFloat
    let offset: CGPoint
    let gridSize: CGSize
    let cornerRadii: [[CGFloat]]
    let minCornerRadius: CGFloat
    let animationDuration: Double

    var body: some View {
        Grid(
            alignment: .center,
            horizontalSpacing: spacing,
            verticalSpacing: spacing
        ) {
            ForEach(0..<rows, id: \.self) { row in
                GridRow {
                    ForEach(0..<columns, id: \.self) { col in
                        let cornerRadius = makeCornerRadius(row: row, col: col)

                        Rectangle()
                            .cornerRadius(cornerRadius * tileSize)
                            .frame(width: tileSize, height: tileSize)
                            .animation(.easeOut(duration: animationDuration), value: cornerRadius)
                    }
                }
            }
        }
        .position(
            x: offset.x + gridSize.width / 2,
            y: offset.y + gridSize.height / 2
        )
    }

    private func makeCornerRadius(row: Int, col: Int) -> CGFloat {
        guard
            0..<cornerRadii.count ~= row,
            0..<cornerRadii[row].count ~= col
        else {
            return minCornerRadius
        }
        return cornerRadii[row][col]
    }
}

private struct GrainEffect: ViewModifier {
    let opacity: CGFloat

    func body(content: Content) -> some View {
        content
            .visualEffect { content, proxy in
                content
                    .colorEffect(
                        ShaderLibrary.noiseShader(
                            .float2(proxy.size)
                        )
                    )
            }
            .overlay {
                content
                    .opacity(opacity)
            }
    }
}

private extension View {
    func grain(opacity: CGFloat) -> some View {
        modifier(GrainEffect(opacity: opacity))
    }
}

#Preview {
    ZStack {
        Aurora.canvas.ignoresSafeArea()
        InteractiveTilesView()
    }
}
