import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Studio root
//
// A clean, white-canvas catalog. Pick a component, then record it on the
// stage. Triple-tap the stage to toggle recording mode (hides all chrome).
//
// To add a new component:
//   1. Add a `case` to `StudioItem`.
//   2. Add the title to `StudioItem.title`.
//   3. Add a `case` to `ComponentStudioStage.body` returning the view.
//   4. Register the item under the right `Section` below.

struct ComponentStudioView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Chrome · Liquid Glass") {
                    studioLink(.sampleGlassPill)
                }
                Section("Cards · Motion") {
                    studioLink(.animatedCreditCard)
                }
                // Section("Motion") { … }
            }
            .navigationTitle("Components Studio")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func studioLink(_ item: StudioItem) -> some View {
        NavigationLink(item.title) {
            ComponentStudioStage(item: item)
        }
    }
}

// MARK: - Stage

/// The neutral white canvas every component renders on. Triple-tap hides
/// the nav bar / title for clean screen recordings.
private struct ComponentStudioStage: View {
    let item: StudioItem

    @State private var recordingMode = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            componentView
                .padding(Theme.Spacing.xl)
                .contentShape(Rectangle())
                .onTapGesture(count: 3) {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                        recordingMode.toggle()
                    }
                    haptic()
                }
        }
        .navigationTitle(recordingMode ? "" : item.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(recordingMode ? .hidden : .visible, for: .navigationBar)
    }

    @ViewBuilder
    private var componentView: some View {
        switch item {
        case .sampleGlassPill:
            SampleGlassPill()
        case .animatedCreditCard:
            AnimatedCreditCardView()
        }
    }

    private func haptic() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        #endif
    }
}

// MARK: - Item registry

enum StudioItem: Hashable {
    case sampleGlassPill
    case animatedCreditCard

    var title: String {
        switch self {
        case .sampleGlassPill: return "Sample · glass pill"
        case .animatedCreditCard: return "AI snake · credit card"
        }
    }
}

// MARK: - Sample component (placeholder)
//
// A bare Liquid Glass pill. The whole point is to have ONE working
// component in the catalog from day zero so the studio renders something
// the moment you open it. Replace / delete this when real work begins.

private struct SampleGlassPill: View {
    var body: some View {
        Text("Liquid Glass")
            .font(.system(.body, design: .rounded).weight(.medium))
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.sm)
            .glassEffect(.regular.interactive(), in: Capsule())
    }
}

#Preview("Studio") {
    ComponentStudioView()
}

#Preview("Sample pill") {
    ZStack {
        Color(.systemBackground).ignoresSafeArea()
        SampleGlassPill()
    }
}
