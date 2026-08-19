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
//   2. Add its `title` and layout entries.
//   3. Register controls + presets in `StudioItemSpecs`.
//   4. Add a `case` to `ComponentStudioStage.body` — wire `specState`
//      into the view. The unified toolbar appears automatically.
//   5. Set `usesUnifiedStage = false` only if the component ships its
//      own embedded toolbar (see Satelite Cards).
//   6. Register the item in `StudioCatalog.categories`.
//   7. Set `StudioItem.lastUpdated` for the new item. Whenever you edit
//      a component, bump its `lastUpdated` — the catalog sorts newest first.

struct ComponentStudioView: View {
    var body: some View {
        NavigationStack {
            StudioCatalogScreen()
        }
    }
}

// MARK: - Catalog screen (Figma node 103:3914)
//
// Flat black-on-white catalog: graffiti "APACH" logo + breadcrumb, a ruled
// table (1px vertical rails + horizontal separators) of bold rows with a
// trailing arrow, and a footer. Content/taxonomy come from `StudioCatalog`.

/// Shared "Swiftui Components Studio" tag — pinned to the same screen position
/// (offset from the safe-area top + trailing inset) on the home and detail
/// pages so it reads as one persistent header element.
private enum StudioBreadcrumb {
    static let text = "Swiftui   Components   Studio"
    static let topInset: CGFloat = 46
    static let trailingInset: CGFloat = 44

    static var view: some View {
        Text(text)
            .font(AppFont.display(10))
            .kerning(-0.4)
            .foregroundStyle(Aurora.ink)
    }
}

private struct StudioCatalogScreen: View {
    /// Side margin to the table rails — logo, footer and rails all align here.
    private let railInset: CGFloat = 44
    /// Horizontal padding of text inside the rails.
    private let rowPadH: CGFloat = 24
    private let headerRowHeight: CGFloat = 56
    private let itemRowHeight: CGFloat = 68
    /// Gap between category blocks (Figma ref).
    private let groupSpacing: CGFloat = 32

    private var categories: [StudioCategory] { StudioCatalog.sortedCategories }

    var body: some View {
        ZStack {
            Aurora.canvas.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, railInset)
                    .padding(.top, 12)
                    .padding(.bottom, 36)

                ScrollView {
                    table
                        .padding(.horizontal, railInset)
                }
                .scrollIndicators(.hidden)

                footer
                    .padding(.horizontal, railInset)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
            }
            .overlay(alignment: .topTrailing) {
                StudioBreadcrumb.view
                    .padding(.top, StudioBreadcrumb.topInset)
                    .padding(.trailing, StudioBreadcrumb.trailingInset)
            }
        }
        .navigationDestination(for: StudioItem.self) { item in
            ComponentStudioStage(item: item)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack {
            Image("ApachLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 145, height: 59)
            Spacer()
        }
    }

    /// Each category is its own bordered block; blocks are separated by 32px.
    private var table: some View {
        VStack(spacing: groupSpacing) {
            ForEach(categories) { category in
                categoryBlock(category)
            }
        }
        .padding(.bottom, 8)
    }

    private func categoryBlock(_ category: StudioCategory) -> some View {
        VStack(spacing: 0) {
            headerRow(category.title)
            ForEach(category.items, id: \.self) { item in
                rule
                NavigationLink(value: item) {
                    itemRow(item.title)
                }
                .buttonStyle(.plain)
            }
        }
        .overlay(Rectangle().strokeBorder(Aurora.rule, lineWidth: 1))
    }

    private var rule: some View {
        Rectangle().fill(Aurora.rule).frame(height: 1)
    }

    private func headerRow(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(AppFont.display(12))
                .kerning(-0.2)
                .foregroundStyle(Aurora.ink)
            Spacer()
        }
        .padding(.horizontal, rowPadH)
        .frame(height: headerRowHeight)
    }

    private func itemRow(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(AppFont.display(16))
                .kerning(-0.2)
                .foregroundStyle(Aurora.ink)
            Spacer()
            Image(systemName: "arrow.right")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Aurora.listArrow)
        }
        .padding(.horizontal, rowPadH)
        .frame(height: itemRowHeight)
        .contentShape(Rectangle())
    }

    private var footer: some View {
        HStack {
            Text("All   People   Are   Creative   Humans")
            Spacer()
            Text("All rights reserved ®")
        }
        .font(AppFont.display(10))
        .kerning(-0.4)
        .foregroundStyle(Aurora.ink)
    }
}

// MARK: - Stage

/// The neutral white canvas every component renders on. Triple-tap hides
/// the nav bar / title for clean screen recordings.
private struct ComponentStudioStage: View {
    let item: StudioItem

    @State private var recordingMode = false
    @State private var searchText = ""
    @State private var specState: ComponentSpecState

    init(item: StudioItem) {
        self.item = item
        _specState = State(initialValue: ComponentSpecState(defaults: item.specDefaults))
    }

    var body: some View {
        ZStack {
            Aurora.canvas.ignoresSafeArea()
            stageWithToolbar
                .contentShape(Rectangle())
                .onTapGesture(count: 3) {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                        recordingMode.toggle()
                    }
                    haptic()
                }
                // Breadcrumb pinned to the same position as on the home screen.
                .overlay(alignment: .topTrailing) {
                    if item.usesShaderChrome && !recordingMode {
                        StudioBreadcrumb.view
                            .padding(.top, StudioBreadcrumb.topInset)
                            .padding(.trailing, StudioBreadcrumb.trailingInset)
                    }
                }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        // Shader pages draw their own back + breadcrumb in ShaderPageLayout,
        // so the system nav bar is hidden for them.
        .navigationBarBackButtonHidden(item.usesShaderChrome)
        .toolbar((recordingMode || item.usesShaderChrome) ? .hidden : .visible, for: .navigationBar)
    }

    @ViewBuilder
    private var stageWithToolbar: some View {
        if item.usesUnifiedStage, let sheet = item.specSheet {
            UnifiedStudioStage(
                item: item,
                sheet: sheet,
                state: specState,
                showToolbar: !recordingMode
            ) {
                stageContent
                    .frame(maxWidth: item.maxWidth)
                    .padding(.horizontal, item.horizontalPadding)
            }
        } else {
            stageContent
                .frame(maxWidth: item.maxWidth)
                .padding(.horizontal, item.horizontalPadding)
        }
    }

    @ViewBuilder
    private var stageContent: some View {
        let sheet = item.specSheet
        switch item {
        case .searchPillRest:
            let specs = SearchBoxSpecs(specState, sheet: sheet!)
            SearchBoxView(text: $searchText, initialFocused: false, motionSpecs: specs)
                .frame(maxWidth: .infinity)

        case .blurFocusLoading:
            let specs = SearchModalSpecs(specState, sheet: sheet!)
            SearchModalView(
                query: StudioSampleData.blurFocusQuery,
                onSubmitNewQuery: nil,
                motionSpecs: specs
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
            let specs = PlaceDeckSpecs(specState, sheet: sheet!)
            PlaceDeckView(
                places: StudioSampleData.deckPlaces,
                onTapCard: { _, _ in },
                onTapBackground: {},
                motionSpecs: specs
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .sampleGlassPill:
            let specs = SampleGlassPillSpecs(specState, sheet: sheet!)
            GlassPillView(specs: specs)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .photoRipple:
            let specs = PhotoRippleSpecs(specState, sheet: sheet!)
            PhotoRippleView(specs: specs)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .photoRipple2:
            let specs = PhotoRipple2Specs(specState, sheet: sheet!)
            PhotoRipple2View(specs: specs)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .refractiveText:
            let specs = BubbleTextRippleSpecs(specState, sheet: sheet!)
            BubbleTextRippleView(title: item.title, content: .text, specs: specs)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .bubbleTextRipple:
            let specs = BubbleTextRippleSpecs(specState, sheet: sheet!)
            BubbleTextRippleView(title: item.title, content: .sphere, specs: specs)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .sphericMesh:
            let specs = SphericMeshSpecs(specState, sheet: sheet!)
            SphericMeshView(specs: specs)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .dottedBackground:
            let specs = DottedBackgroundSpecs(specState, sheet: sheet!)
            DottedBackgroundView(specs: specs)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .glassEffectShader:
            let specs = GlassEffectShaderSpecs(specState, sheet: sheet!)
            GlassEffectShaderView(specs: specs)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .neumorphicDigit:
            let specs = NeumorphicDigitSpecs(specState, sheet: sheet!)
            NeumorphicDigitView(specs: specs)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .interactiveTiles:
            let specs = InteractiveTilesSpecs(specState, sheet: sheet!)
            InteractiveTilesView(specs: specs)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func haptic() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        #endif
    }
}

// MARK: - Catalog categories

struct StudioCategory: Identifiable {
    let id: String
    let title: String
    let items: [StudioItem]
    /// Latest `StudioItem.lastUpdated` in this section — drives section order.
    let lastUpdated: Date
}

private enum StudioCatalog {
    private static let categoryDefinitions: [(id: String, title: String, items: [StudioItem])] = [
        (id: "shaders", title: "Shaders", items: [
            .interactiveTiles, .dottedBackground, .neumorphicDigit, .photoRipple2,
            .photoRipple, .refractiveText, .bubbleTextRipple, .sphericMesh, .glassEffectShader,
        ]),
        (id: "cards", title: "Cards", items: [.bubbleCard]),
        (id: "pills", title: "Pills", items: [.sampleGlassPill]),
        (id: "loading", title: "Loading", items: [.blurFocusLoading]),
        (id: "scroll", title: "Scroll", items: [.verticalCardDeck]),
        (id: "search", title: "Search", items: [.searchPillRest]),
    ]

    static var sortedCategories: [StudioCategory] {
        categoryDefinitions
            .map { def in
                let sortedItems = def.items.sorted { $0.lastUpdated > $1.lastUpdated }
                return StudioCategory(
                    id: def.id,
                    title: def.title,
                    items: sortedItems,
                    lastUpdated: sortedItems.first?.lastUpdated ?? .distantPast
                )
            }
            .sorted { $0.lastUpdated > $1.lastUpdated }
    }
}

// MARK: - Item registry

enum StudioItem: Hashable {
    case searchPillRest
    case blurFocusLoading
    case bubbleCard
    case verticalCardDeck
    case sampleGlassPill
    case photoRipple
    case photoRipple2
    case refractiveText
    case bubbleTextRipple
    case sphericMesh
    case dottedBackground
    case glassEffectShader
    case neumorphicDigit
    case interactiveTiles

    /// Bump this timestamp whenever the component (view, specs, or sample data) changes.
    /// The catalog sorts items and sections by this date, newest first.
    var lastUpdated: Date {
        switch self {
        case .interactiveTiles: return studioCatalogDate(2026, 6, 27, 17, 0)
        case .refractiveText: return studioCatalogDate(2026, 6, 27, 16, 30)
        case .dottedBackground: return studioCatalogDate(2026, 6, 27, 16, 0)
        case .neumorphicDigit: return studioCatalogDate(2026, 6, 27, 15, 0)
        case .photoRipple2: return studioCatalogDate(2026, 6, 27, 14, 0)
        case .photoRipple: return studioCatalogDate(2026, 6, 27, 13, 0)
        case .bubbleTextRipple: return studioCatalogDate(2026, 6, 27, 19, 0)
        case .sphericMesh: return studioCatalogDate(2026, 6, 27, 11, 0)
        case .glassEffectShader: return studioCatalogDate(2026, 6, 27, 10, 0)
        case .bubbleCard: return studioCatalogDate(2026, 6, 26, 21, 11, 28)
        case .sampleGlassPill: return studioCatalogDate(2026, 6, 26, 21, 11, 25)
        case .blurFocusLoading: return studioCatalogDate(2026, 6, 26, 21, 4, 5)
        case .verticalCardDeck: return studioCatalogDate(2026, 6, 26, 21, 1, 47)
        case .searchPillRest: return studioCatalogDate(2026, 6, 26, 21, 1, 34)
        }
    }

    var title: String {
        switch self {
        case .searchPillRest: return "AI Search"
        case .blurFocusLoading: return "Summary Blur Loading"
        case .bubbleCard: return "Satelite Cards"
        case .verticalCardDeck: return "Vertical card deck"
        case .sampleGlassPill: return "Glass Pill"
        case .photoRipple: return "Liquid Photo"
        case .photoRipple2: return "Photo Ripple"
        case .refractiveText: return "Refractive Text"
        case .bubbleTextRipple: return "Refractive Sphere"
        case .sphericMesh: return "Spheric Mesh"
        case .dottedBackground: return "Dotted Background"
        case .glassEffectShader: return "Glass Effect"
        case .neumorphicDigit: return "Neumorphic Digit"
        case .interactiveTiles: return "Interactive Tiles"
        }
    }

    /// Stable per-item key for persisting user-pinned presets.
    var storageKey: String { String(describing: self) }

    /// Items that render through `ShaderPageLayout`, which draws its own
    /// back button + breadcrumb. For these the system nav bar is hidden.
    var usesShaderChrome: Bool {
        switch self {
        case .interactiveTiles, .dottedBackground, .neumorphicDigit, .photoRipple2,
             .photoRipple, .refractiveText, .bubbleTextRipple, .sphericMesh, .glassEffectShader:
            return true
        default:
            return false
        }
    }

    var maxWidth: CGFloat? {
        switch self {
        case .bubbleCard, .verticalCardDeck, .blurFocusLoading,
             .photoRipple, .photoRipple2, .refractiveText, .bubbleTextRipple, .sphericMesh, .dottedBackground, .glassEffectShader,
             .neumorphicDigit, .interactiveTiles:
            return .infinity
        default:
            return .infinity
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .bubbleCard, .verticalCardDeck, .blurFocusLoading,
             .photoRipple, .photoRipple2, .refractiveText, .bubbleTextRipple, .sphericMesh, .dottedBackground, .glassEffectShader,
             .neumorphicDigit, .interactiveTiles:
            return 0
        case .searchPillRest:
            return StudioLayout.horizontalPadding
        case .sampleGlassPill:
            return 0
        }
    }
}

// MARK: - Sample component (placeholder)

private struct SampleGlassPill: View {
    var specs: SampleGlassPillSpecs = SampleGlassPillSpecs(
        ComponentSpecState(defaults: StudioItem.sampleGlassPill.specDefaults),
        sheet: StudioItem.sampleGlassPill.specSheet!
    )

    var body: some View {
        Text("Liquid Glass")
            .font(.system(.body, design: .rounded).weight(.medium))
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.sm)
            .scaleEffect(specs.restScale)
            .glassEffect(
                specs.tintOpacity > 0.01
                    ? .regular.interactive().tint(.white.opacity(specs.tintOpacity))
                    : .regular.interactive(),
                in: Capsule()
            )
    }
}

/// Glass Pill stage with a dark-mode toggle so the Liquid Glass pill can be
/// previewed on both light and dark backgrounds.
private struct GlassPillView: View {
    let specs: SampleGlassPillSpecs
    @State private var darkMode = false

    var body: some View {
        ZStack {
            (darkMode ? Color.black : Aurora.canvas)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                SampleGlassPill(specs: specs)

                HStack(spacing: 12) {
                    Image(systemName: darkMode ? "moon.fill" : "sun.max.fill")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Dark Mode")
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                    Toggle("Dark Mode", isOn: $darkMode.animation(.easeInOut(duration: 0.25)))
                        .labelsHidden()
                        .tint(darkMode ? Color.white.opacity(0.85) : Aurora.ink.opacity(0.85))
                }
                .foregroundStyle(darkMode ? Color.white : Aurora.ink)
            }
            .padding(Theme.Spacing.xl)
        }
        .environment(\.colorScheme, darkMode ? .dark : .light)
    }
}

private func studioCatalogDate(
    _ year: Int,
    _ month: Int,
    _ day: Int,
    _ hour: Int,
    _ minute: Int,
    _ second: Int = 0
) -> Date {
    Calendar(identifier: .gregorian).date(from: DateComponents(
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second
    ))!
}

#Preview("Studio") {
    ComponentStudioView()
}

#Preview("Glass Pill") {
    ZStack {
        Color(.systemBackground).ignoresSafeArea()
        SampleGlassPill()
    }
}
