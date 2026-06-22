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
                    studioLink(.searchPillRest)
                }
                Section("Search · Loading") {
                    studioLink(.blurFocusLoading)
                }
                Section("Cloud") {
                    studioLink(.bubbleCard)
                }
                Section("Deck") {
                    studioLink(.verticalCardDeck)
                }
                Section("Samples") {
                    studioLink(.sampleGlassPill)
                }
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
    @State private var searchText = ""

    var body: some View {
        ZStack {
            Aurora.canvas.ignoresSafeArea()
            stageContent
                .frame(maxWidth: item.maxWidth)
                .padding(.horizontal, item.horizontalPadding)
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
    private var stageContent: some View {
        switch item {
        case .searchPillRest:
            SearchBoxView(text: $searchText, initialFocused: false)
                .frame(maxWidth: .infinity)

        case .blurFocusLoading:
            SearchModalView(
                query: StudioSampleData.blurFocusQuery,
                onSubmitNewQuery: nil
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()

        case .bubbleCard:
            ExpandingBubbleCard(
                place: StudioSampleData.pizzaPlace,
                satellites: StudioSampleData.pizzaIngredients,
                size: Cloud.bubbleH,
                rotation: 8
            )

        case .verticalCardDeck:
            PlaceDeckView(
                places: StudioSampleData.deckPlaces,
                onTapCard: { _, _ in },
                onTapBackground: {}
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .sampleGlassPill:
            SampleGlassPill()
                .padding(Theme.Spacing.xl)
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
    case searchPillRest
    case blurFocusLoading
    case bubbleCard
    case verticalCardDeck
    case sampleGlassPill

    var title: String {
        switch self {
        case .searchPillRest: return "Search pill (rest)"
        case .blurFocusLoading: return "Blur-focus summary (loading)"
        case .bubbleCard: return "Bubble card"
        case .verticalCardDeck: return "Vertical card deck"
        case .sampleGlassPill: return "Sample · glass pill"
        }
    }

    var maxWidth: CGFloat? {
        switch self {
        case .bubbleCard, .verticalCardDeck, .blurFocusLoading:
            return .infinity
        default:
            return .infinity
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .bubbleCard, .verticalCardDeck, .blurFocusLoading:
            return 0
        case .searchPillRest:
            return Theme.Spacing.xxl
        case .sampleGlassPill:
            return 0
        }
    }
}

// MARK: - Sample component (placeholder)

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
