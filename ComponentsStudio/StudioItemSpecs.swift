import Foundation

// MARK: - Per-component typed specs
//
// Each struct reads live values from `ComponentSpecState` using the
// stable string keys declared in `StudioItem.specSheet`.

struct SearchBoxSpecs: Equatable {
    var focusResponse: Double
    var focusDamping: Double
    var focusScale: Double
    var auraPeriodFocused: Double
    var auraPeriodRest: Double
    var snakeWidthFocused: Double
    var snakeWidthRest: Double

    @MainActor
    init(_ state: ComponentSpecState, sheet: ComponentSpecSheet) {
        focusResponse = sheet.value("focusResponse", in: state)
        focusDamping = sheet.value("focusDamping", in: state)
        focusScale = sheet.value("focusScale", in: state)
        auraPeriodFocused = sheet.value("auraPeriodFocused", in: state)
        auraPeriodRest = sheet.value("auraPeriodRest", in: state)
        snakeWidthFocused = sheet.value("snakeWidthFocused", in: state)
        snakeWidthRest = sheet.value("snakeWidthRest", in: state)
    }
}

struct SearchModalSpecs: Equatable {
    var blurAmount: Double
    var blurRevealDuration: Double
    var wordStagger: Double
    var cardStagger: Double
    var cardRevealDuration: Double
    var holdDuration: Double

    @MainActor
    init(_ state: ComponentSpecState, sheet: ComponentSpecSheet) {
        blurAmount = sheet.value("blurAmount", in: state)
        blurRevealDuration = sheet.value("blurRevealDuration", in: state)
        wordStagger = sheet.value("wordStagger", in: state)
        cardStagger = sheet.value("cardStagger", in: state)
        cardRevealDuration = sheet.value("cardRevealDuration", in: state)
        holdDuration = sheet.value("holdDuration", in: state)
    }
}

struct PlaceDeckSpecs: Equatable {
    var edgeScale: Double
    var edgeOpacity: Double
    var maxEdgeBlur: Double
    var parallaxAmount: Double
    var settleScale: Double
    var settleDuration: Double

    @MainActor
    init(_ state: ComponentSpecState, sheet: ComponentSpecSheet) {
        edgeScale = sheet.value("edgeScale", in: state)
        edgeOpacity = sheet.value("edgeOpacity", in: state)
        maxEdgeBlur = sheet.value("maxEdgeBlur", in: state)
        parallaxAmount = sheet.value("parallaxAmount", in: state)
        settleScale = sheet.value("settleScale", in: state)
        settleDuration = sheet.value("settleDuration", in: state)
    }
}

struct SampleGlassPillSpecs: Equatable {
    var tintOpacity: Double
    var restScale: Double

    @MainActor
    init(_ state: ComponentSpecState, sheet: ComponentSpecSheet) {
        tintOpacity = sheet.value("tintOpacity", in: state)
        restScale = sheet.value("restScale", in: state)
    }
}

struct PhotoRippleSpecs: Equatable {
    var amplitude: Double
    var frequency: Double
    var decay: Double
    var speed: Double
    var highlight: Double
    var duration: Double

    @MainActor
    init(_ state: ComponentSpecState, sheet: ComponentSpecSheet) {
        amplitude = sheet.value("amplitude", in: state)
        frequency = sheet.value("frequency", in: state)
        decay = sheet.value("decay", in: state)
        speed = sheet.value("speed", in: state)
        highlight = sheet.value("highlight", in: state)
        duration = sheet.value("duration", in: state)
    }
}

struct PhotoRipple2Specs: Equatable {
    var speed: Double
    var bandWidth: Double
    var maxRadius: Double
    var refract: Double
    var glint: Double
    var falloff: Double
    var swirl: Double
    var displacement: Double
    var life: Double
    var emitSpacing: Double
    var chromatic: Double

    @MainActor
    init(_ state: ComponentSpecState, sheet: ComponentSpecSheet) {
        speed = sheet.value("speed", in: state)
        bandWidth = sheet.value("bandWidth", in: state)
        maxRadius = sheet.value("maxRadius", in: state)
        refract = sheet.value("refract", in: state)
        glint = sheet.value("glint", in: state)
        falloff = sheet.value("falloff", in: state)
        swirl = sheet.value("swirl", in: state)
        displacement = sheet.value("displacement", in: state)
        life = sheet.value("life", in: state)
        emitSpacing = sheet.value("emitSpacing", in: state)
        chromatic = sheet.value("chromatic", in: state)
    }
}

// Refractive Sphere is a refractive-glass lens over a black card with a
// centered sphere image; reuses the exact same knob set as Refractive Photo.
struct BubbleTextRippleSpecs: Equatable {
    var refraction: Double
    var falloff: Double
    var swirl: Double
    var glassRadius: Double
    var edgeThickness: Double
    var chromatic: Double
    var rimIntensity: Double
    var shadowStrength: Double
    var shadowBlur: Double
    var shadowOffset: Double

    @MainActor
    init(_ state: ComponentSpecState, sheet: ComponentSpecSheet) {
        refraction = sheet.value("refraction", in: state)
        falloff = sheet.value("falloff", in: state)
        swirl = sheet.value("swirl", in: state)
        glassRadius = sheet.value("glassRadius", in: state)
        edgeThickness = sheet.value("edgeThickness", in: state)
        chromatic = sheet.value("chromatic", in: state)
        rimIntensity = sheet.value("rimIntensity", in: state)
        shadowStrength = sheet.value("shadowStrength", in: state)
        shadowBlur = sheet.value("shadowBlur", in: state)
        shadowOffset = sheet.value("shadowOffset", in: state)
    }
}

struct SphericMeshSpecs: Equatable {
    var gridDensity: Double
    var bulgeStrength: Double
    var dotScale: Double

    @MainActor
    init(_ state: ComponentSpecState, sheet: ComponentSpecSheet) {
        gridDensity = sheet.value("gridDensity", in: state)
        bulgeStrength = sheet.value("bulgeStrength", in: state)
        dotScale = sheet.value("dotScale", in: state)
    }
}

struct DottedBackgroundSpecs: Equatable {
    var mode: Double
    var gridDensity: Double
    var influenceRadius: Double
    var maxDisplacement: Double

    @MainActor
    init(_ state: ComponentSpecState, sheet: ComponentSpecSheet) {
        mode = sheet.value("mode", in: state)
        gridDensity = sheet.value("gridDensity", in: state)
        influenceRadius = sheet.value("influenceRadius", in: state)
        maxDisplacement = sheet.value("maxDisplacement", in: state)
    }
}

struct GlassEffectShaderSpecs: Equatable {
    var lensStrength: Double
    var frostAmount: Double
    var breatheSpeed: Double
    var chromaticSplit: Double

    @MainActor
    init(_ state: ComponentSpecState, sheet: ComponentSpecSheet) {
        lensStrength = sheet.value("lensStrength", in: state)
        frostAmount = sheet.value("frostAmount", in: state)
        breatheSpeed = sheet.value("breatheSpeed", in: state)
        chromaticSplit = sheet.value("chromaticSplit", in: state)
    }
}

struct RefractiveGlassSpecs: Equatable {
    var refraction: Double
    var falloff: Double
    var swirl: Double
    var glassRadius: Double
    var edgeThickness: Double
    var chromatic: Double
    var rimIntensity: Double
    var shadowStrength: Double
    var shadowBlur: Double
    var shadowOffset: Double

    @MainActor
    init(_ state: ComponentSpecState, sheet: ComponentSpecSheet) {
        refraction = sheet.value("refraction", in: state)
        falloff = sheet.value("falloff", in: state)
        swirl = sheet.value("swirl", in: state)
        glassRadius = sheet.value("glassRadius", in: state)
        edgeThickness = sheet.value("edgeThickness", in: state)
        chromatic = sheet.value("chromatic", in: state)
        rimIntensity = sheet.value("rimIntensity", in: state)
        shadowStrength = sheet.value("shadowStrength", in: state)
        shadowBlur = sheet.value("shadowBlur", in: state)
        shadowOffset = sheet.value("shadowOffset", in: state)
    }
}

struct NeumorphicDigitSpecs: Equatable {
    var displayWidth: Double
    var cycleInterval: Double

    @MainActor
    init(_ state: ComponentSpecState, sheet: ComponentSpecSheet) {
        displayWidth = sheet.value("displayWidth", in: state)
        cycleInterval = sheet.value("cycleInterval", in: state)
    }
}

struct InteractiveTilesSpecs: Equatable {
    var influenceDistance: Double
    var grainOpacity: Double
    var minCornerRadius: Double
    var maxCornerRadius: Double
    var animationDuration: Double

    @MainActor
    init(_ state: ComponentSpecState, sheet: ComponentSpecSheet) {
        influenceDistance = sheet.value("influenceDistance", in: state)
        grainOpacity = sheet.value("grainOpacity", in: state)
        minCornerRadius = sheet.value("minCornerRadius", in: state)
        maxCornerRadius = sheet.value("maxCornerRadius", in: state)
        animationDuration = sheet.value("animationDuration", in: state)
    }
}

// MARK: - Registry

extension StudioItem {
    var specSheet: ComponentSpecSheet? {
        Self.allSpecSheets[self]
    }

    var specDefaults: [String: Double] {
        specSheet?.defaults ?? [:]
    }

    /// Built-in default preset — the original tuned component. User-pinned
    /// variants are managed at runtime in `UnifiedStudioStage`.
    var presets: [StudioComponentPreset] {
        switch self {
        case .searchPillRest: return Self.searchPillPresets
        case .blurFocusLoading: return Self.blurFocusPresets
        case .bubbleCard: return []
        case .verticalCardDeck: return Self.deckPresets
        case .sampleGlassPill: return Self.glassPillPresets
        case .photoRipple: return Self.photoRipplePresets
        case .photoRipple2: return Self.photoRipple2Presets
        case .bubbleTextRipple: return Self.bubbleTextRipplePresets
        case .refractiveText: return Self.refractiveTextPresets
        case .sphericMesh: return Self.sphericMeshPresets
        case .dottedBackground: return Self.dottedBackgroundPresets
        case .glassEffectShader: return Self.glassEffectPresets
        case .neumorphicDigit: return Self.neumorphicDigitPresets
        case .interactiveTiles: return Self.interactiveTilesPresets
        }
    }

    /// Whether this item uses the shared `UnifiedStudioStage` chrome.
    var usesUnifiedStage: Bool {
        switch self {
        case .bubbleCard: return false
        default: return true
        }
    }

    @MainActor
    func swiftCodeSnippet(state: ComponentSpecState, presetLabel: String) -> String {
        guard let sheet = specSheet else { return "// No spec sheet" }
        switch self {
        case .searchPillRest:
            let s = SearchBoxSpecs(state, sheet: sheet)
            return """
            // Generated by Component Studio · preset: \(presetLabel)
            // SearchBoxView motion specs

            let focusAnimation: Animation = .spring(response: \(fmt(s.focusResponse)), dampingFraction: \(fmt(s.focusDamping)))
            let focusScale: CGFloat = \(fmt(s.focusScale))
            let auraPeriodFocused: Double = \(fmt(s.auraPeriodFocused))
            let auraPeriodRest: Double = \(fmt(s.auraPeriodRest))
            let snakeWidthFocused: CGFloat = \(fmt(s.snakeWidthFocused))
            let snakeWidthRest: CGFloat = \(fmt(s.snakeWidthRest))
            """

        case .blurFocusLoading:
            let s = SearchModalSpecs(state, sheet: sheet)
            return """
            // Generated by Component Studio · preset: \(presetLabel)
            // SearchModalView blur-focus loading specs

            let blurAmount: CGFloat = \(fmt(s.blurAmount))
            let blurRevealDuration: Double = \(fmt(s.blurRevealDuration))
            let wordStagger: Double = \(fmt(s.wordStagger))
            let cardStagger: Double = \(fmt(s.cardStagger))
            let cardRevealDuration: Double = \(fmt(s.cardRevealDuration))
            let holdDuration: Double = \(fmt(s.holdDuration))
            """

        case .verticalCardDeck:
            let s = PlaceDeckSpecs(state, sheet: sheet)
            return """
            // Generated by Component Studio · preset: \(presetLabel)
            // PlaceDeckView scroll / settle specs

            let edgeScale: CGFloat = \(fmt(s.edgeScale))
            let edgeOpacity: Double = \(fmt(s.edgeOpacity))
            let maxEdgeBlur: CGFloat = \(fmt(s.maxEdgeBlur))
            let parallaxAmount: CGFloat = \(fmt(s.parallaxAmount))
            let settleScale: CGFloat = \(fmt(s.settleScale))
            let settleDuration: Double = \(fmt(s.settleDuration))
            """

        case .sampleGlassPill:
            let s = SampleGlassPillSpecs(state, sheet: sheet)
            return """
            // Generated by Component Studio · preset: \(presetLabel)
            // Glass Pill — Liquid Glass specs

            let tintOpacity: Double = \(fmt(s.tintOpacity))
            let restScale: CGFloat = \(fmt(s.restScale))

            // Usage:
            // .glassEffect(
            //     tintOpacity > 0.01
            //         ? .regular.interactive().tint(.white.opacity(tintOpacity))
            //         : .regular.interactive(),
            //     in: Capsule()
            // )
            // .scaleEffect(restScale)
            """

        case .photoRipple:
            let s = PhotoRippleSpecs(state, sheet: sheet)
            return """
            // Generated by Component Studio · preset: \(presetLabel)
            // Liquid Photo — Apple WWDC24 ripple (.layerEffect, photo distorts)

            let amplitude: Float = \(fmt(s.amplitude))   // peak pixel displacement
            let frequency: Float = \(fmt(s.frequency))   // number of crests
            let decay: Float = \(fmt(s.decay))           // how fast the wave fades
            let speed: Float = \(fmt(s.speed))           // propagation speed (px/s)
            let highlight: Float = \(fmt(s.highlight))   // white crest brightness
            let duration: Double = \(fmt(s.duration))    // ripple lifetime (s)
            """

        case .photoRipple2:
            let s = PhotoRipple2Specs(state, sheet: sheet)
            return """
            // Generated by Component Studio · preset: \(presetLabel)
            // Photo Ripple — Liquid Glass fusion (WWDC ripple + Baro refraction),
            // stacked .layerEffect on the photo; finger-following drag trail

            let speed: Float = \(fmt(s.speed))             // wavefront expansion (px/s)
            let bandWidth: Float = \(fmt(s.bandWidth))     // glass band width (px)
            let maxRadius: Float = \(fmt(s.maxRadius))     // radius where the ring dies (px)
            let refract: Float = \(fmt(s.refract))         // Baro radial refraction strength
            let glint: Float = \(fmt(s.glint))             // specular rim highlight
            let falloff: Float = \(fmt(s.falloff))         // lens curve: 1 - pow(r, falloff)
            let swirl: Float = \(fmt(s.swirl))             // tangent rotation at crest (rad)
            let displacement: Float = \(fmt(s.displacement)) // WWDC crest displacement (px)
            let life: Double = \(fmt(s.life))              // ring lifetime (s)
            let emitSpacing: Float = \(fmt(s.emitSpacing)) // px between rings while dragging
            let chromatic: Float = \(fmt(s.chromatic))     // chromatic aberration at band edge
            """

        case .bubbleTextRipple:
            let s = BubbleTextRippleSpecs(state, sheet: sheet)
            return """
            // Generated by Component Studio · preset: \(presetLabel)
            // Refractive Sphere — refractive glass lens over a black card
            // with a centered sphere image; same refractiveGlass shader, draggable lens.
            let refraction: Float = \(fmt(s.refraction))       // Snell-style background bend
            let falloff: Float = \(fmt(s.falloff))             // distortion curve: 1 - pow(r, falloff)
            let swirl: Float = \(fmt(s.swirl))                 // rotation at center (radians)
            let glassRadius: Float = \(fmt(s.glassRadius))     // lens radius (px)
            let edgeThickness: Float = \(fmt(s.edgeThickness)) // rim highlight band (px)
            let chromatic: Float = \(fmt(s.chromatic))         // R/B split toward the edge
            let rimIntensity: Float = \(fmt(s.rimIntensity))   // edge lighting strength
            let shadowStrength: Float = \(fmt(s.shadowStrength)) // occlusion darkening
            let shadowBlur: Float = \(fmt(s.shadowBlur))       // shadow feather ring (px)
            let shadowOffset: Float = \(fmt(s.shadowOffset))   // directional shadow offset (px)
            """

        case .refractiveText:
            let s = BubbleTextRippleSpecs(state, sheet: sheet)
            return """
            // Generated by Component Studio · preset: \(presetLabel)
            // Refractive Text — refractive glass lens over a water-drops photo
            // with "apach" in Dripdrop; same refractiveGlass shader, draggable lens.

            // Scale Dripdrop so "apach" sits 12pt from the card edges.
            let textSidePadding: CGFloat = 12
            let displayFontSize: CGFloat = {
                let available = cardWidth - textSidePadding * 2
                let reference: CGFloat = 100
                let font = UIFont(name: "Dripdrop-Regular", size: reference)
                    ?? UIFont.systemFont(ofSize: reference, weight: .bold)
                let width = ("apach" as NSString).size(withAttributes: [.font: font]).width
                return width > 0 ? reference * (available / width) : reference
            }()
            let displayFont: Font = AppFont.dripdrop(displayFontSize)

            let refraction: Float = \(fmt(s.refraction))
            let falloff: Float = \(fmt(s.falloff))
            let swirl: Float = \(fmt(s.swirl))
            let glassRadius: Float = \(fmt(s.glassRadius))
            let edgeThickness: Float = \(fmt(s.edgeThickness))
            let chromatic: Float = \(fmt(s.chromatic))
            let rimIntensity: Float = \(fmt(s.rimIntensity))
            let shadowStrength: Float = \(fmt(s.shadowStrength))
            let shadowBlur: Float = \(fmt(s.shadowBlur))
            let shadowOffset: Float = \(fmt(s.shadowOffset))
            """

        case .sphericMesh:
            let s = SphericMeshSpecs(state, sheet: sheet)
            return """
            // Generated by Component Studio · preset: \(presetLabel)
            // SphericMeshView specs

            let gridDensity: Double = \(fmt(s.gridDensity))
            let bulgeStrength: Double = \(fmt(s.bulgeStrength))
            let dotScale: Double = \(fmt(s.dotScale))
            """

        case .dottedBackground:
            let s = DottedBackgroundSpecs(state, sheet: sheet)
            return """
            // Generated by Component Studio · preset: \(presetLabel)
            // DottedBackgroundView specs

            let mode: Float = \(fmt(s.mode))               // 0=glow, 1=attraction, 2=repulsion
            let gridDensity: Float = \(fmt(s.gridDensity))
            let influenceRadius: Float = \(fmt(s.influenceRadius))
            let maxDisplacement: Float = \(fmt(s.maxDisplacement))
            """

        case .glassEffectShader:
            let s = GlassEffectShaderSpecs(state, sheet: sheet)
            return """
            // Generated by Component Studio · preset: \(presetLabel)
            // GlassEffectShaderView specs

            let lensStrength: Float = \(fmt(s.lensStrength))
            let frostAmount: Float = \(fmt(s.frostAmount))
            let breatheSpeed: Float = \(fmt(s.breatheSpeed))
            let chromaticSplit: Float = \(fmt(s.chromaticSplit))
            """

        case .neumorphicDigit:
            let s = NeumorphicDigitSpecs(state, sheet: sheet)
            return """
            // Generated by Component Studio · preset: \(presetLabel)
            // Neumorphic Digit — Uladzislau Volchyk seven-segment display
            // (SwiftUI Layout + neumorphic shadows)

            let displayWidth: CGFloat = \(fmt(s.displayWidth))
            let cycleInterval: Double = \(fmt(s.cycleInterval))  // auto-cycle period (s)
            """

        case .interactiveTiles:
            let s = InteractiveTilesSpecs(state, sheet: sheet)
            return """
            // Generated by Component Studio · preset: \(presetLabel)
            // InteractiveTilesView — Uladzislau Volchyk MeshGradient tile grid

            let influenceDistance: CGFloat = \(fmt(s.influenceDistance))
            let grainOpacity: CGFloat = \(fmt(s.grainOpacity))
            let minCornerRadius: CGFloat = \(fmt(s.minCornerRadius))
            let maxCornerRadius: CGFloat = \(fmt(s.maxCornerRadius))
            let animationDuration: Double = \(fmt(s.animationDuration))
            """

        case .bubbleCard:
            return "// Satelite Cards exports code from its embedded toolbar."
        }
    }

    private func fmt(_ value: Double) -> String {
        String(format: "%.2f", value)
    }

    private static let allSpecSheets: [StudioItem: ComponentSpecSheet] = [
        .searchPillRest: searchPillSheet,
        .blurFocusLoading: blurFocusSheet,
        .verticalCardDeck: deckSheet,
        .sampleGlassPill: glassPillSheet,
        .photoRipple: photoRippleSheet,
        .photoRipple2: photoRipple2Sheet,
        .bubbleTextRipple: bubbleTextRippleSheet,
        .refractiveText: refractiveTextSheet,
        .sphericMesh: sphericMeshSheet,
        .dottedBackground: dottedBackgroundSheet,
        .glassEffectShader: glassEffectSheet,
        .neumorphicDigit: neumorphicDigitSheet,
        .interactiveTiles: interactiveTilesSheet,
    ]

    private static let searchPillSheet = ComponentSpecSheet(
        categories: [
            ComponentSpecCategory(
                id: "motion",
                label: "Motion",
                controls: [
                    .init(id: "focusResponse", label: "Response", kind: .slider(0.20...0.80, format: "%.2f")),
                    .init(id: "focusDamping", label: "Damping", kind: .slider(0.50...1.00, format: "%.2f")),
                    .init(id: "focusScale", label: "Scale", kind: .slider(1.00...1.06, format: "%.3f")),
                ]
            ),
            ComponentSpecCategory(
                id: "aura",
                label: "Aura",
                controls: [
                    .init(id: "auraPeriodFocused", label: "Focus cycle", kind: .slider(1.0...6.0, format: "%.1fs")),
                    .init(id: "auraPeriodRest", label: "Rest cycle", kind: .slider(2.0...8.0, format: "%.1fs")),
                    .init(id: "snakeWidthFocused", label: "Stroke+", kind: .slider(0.6...2.0, format: "%.1f")),
                    .init(id: "snakeWidthRest", label: "Stroke", kind: .slider(0.4...1.6, format: "%.1f")),
                ]
            ),
        ],
        defaults: [
            "focusResponse": 0.42, "focusDamping": 0.78, "focusScale": 1.012,
            "auraPeriodFocused": 2.2, "auraPeriodRest": 4.2,
            "snakeWidthFocused": 1.2, "snakeWidthRest": 0.9,
        ]
    )

    private static let blurFocusSheet = ComponentSpecSheet(
        categories: [
            ComponentSpecCategory(
                id: "blur",
                label: "Blur",
                controls: [
                    .init(id: "blurAmount", label: "Blur", kind: .slider(4.0...16.0, format: "%.0f")),
                    .init(id: "blurRevealDuration", label: "Focus", kind: .slider(0.40...2.00, format: "%.2fs")),
                    .init(id: "wordStagger", label: "Stagger", kind: .slider(0.02...0.12, format: "%.2fs")),
                ]
            ),
            ComponentSpecCategory(
                id: "reveal",
                label: "Reveal",
                controls: [
                    .init(id: "cardStagger", label: "Card gap", kind: .slider(0.03...0.15, format: "%.2fs")),
                    .init(id: "cardRevealDuration", label: "Card ease", kind: .slider(0.25...0.90, format: "%.2fs")),
                    .init(id: "holdDuration", label: "Hold", kind: .slider(0.80...3.00, format: "%.2fs")),
                ]
            ),
        ],
        defaults: [
            "blurAmount": 9.0, "blurRevealDuration": 1.0, "wordStagger": 0.05,
            "cardStagger": 0.07, "cardRevealDuration": 0.5, "holdDuration": 1.9,
        ]
    )

    private static let deckSheet = ComponentSpecSheet(
        categories: [
            ComponentSpecCategory(
                id: "scroll",
                label: "Scroll",
                controls: [
                    .init(id: "edgeScale", label: "Edge scale", kind: .slider(0.70...0.95, format: "%.2f")),
                    .init(id: "edgeOpacity", label: "Edge fade", kind: .slider(0.10...0.60, format: "%.2f")),
                    .init(id: "maxEdgeBlur", label: "Edge blur", kind: .slider(0.0...12.0, format: "%.0f")),
                    .init(id: "parallaxAmount", label: "Parallax", kind: .slider(0.0...24.0, format: "%.0f")),
                ]
            ),
            ComponentSpecCategory(
                id: "settle",
                label: "Settle",
                controls: [
                    .init(id: "settleScale", label: "Breathe", kind: .slider(1.00...1.04, format: "%.3f")),
                    .init(id: "settleDuration", label: "Duration", kind: .slider(0.20...0.80, format: "%.2fs")),
                ]
            ),
        ],
        defaults: [
            "edgeScale": 0.84, "edgeOpacity": 0.30, "maxEdgeBlur": 6.0,
            "parallaxAmount": 14.0, "settleScale": 1.012, "settleDuration": 0.4,
        ]
    )

    private static let glassPillSheet = ComponentSpecSheet(
        categories: [
            ComponentSpecCategory(
                id: "glass",
                label: "Glass",
                controls: [
                    .init(id: "tintOpacity", label: "Tint", kind: .slider(0.0...0.60, format: "%.2f")),
                    .init(id: "restScale", label: "Scale", kind: .slider(0.96...1.04, format: "%.3f")),
                ]
            ),
        ],
        defaults: ["tintOpacity": 0.0, "restScale": 1.0]
    )

    private static let photoRippleSheet = ComponentSpecSheet(
        categories: [
            ComponentSpecCategory(
                id: "wave",
                label: "Wave",
                controls: [
                    .init(id: "amplitude", label: "Amplitude", kind: .slider(5...60, format: "%.0f")),
                    .init(id: "frequency", label: "Frequency", kind: .slider(4...30, format: "%.0f")),
                    .init(id: "speed", label: "Speed", kind: .slider(400...2000, format: "%.0f")),
                ]
            ),
            ComponentSpecCategory(
                id: "feel",
                label: "Feel",
                controls: [
                    .init(id: "decay", label: "Decay", kind: .slider(3...12, format: "%.1f")),
                    .init(id: "highlight", label: "Highlight", kind: .slider(0.10...0.80, format: "%.2f")),
                    .init(id: "duration", label: "Duration", kind: .slider(0.8...3.0, format: "%.1fs")),
                ]
            ),
        ],
        defaults: [
            "amplitude": 30, "frequency": 15, "decay": 6,
            "speed": 400, "highlight": 0.45, "duration": 1.5,
        ]
    )

    private static let photoRipple2Sheet = ComponentSpecSheet(
        categories: [
            ComponentSpecCategory(
                id: "wave",
                label: "Wave",
                controls: [
                    .init(id: "speed", label: "Speed", kind: .slider(200...1400, format: "%.0f")),
                    .init(id: "bandWidth", label: "Band", kind: .slider(24...140, format: "%.0f")),
                    .init(id: "maxRadius", label: "Max R", kind: .slider(200...900, format: "%.0f")),
                    .init(id: "displacement", label: "Crest", kind: .slider(0...40, format: "%.0f")),
                ]
            ),
            ComponentSpecCategory(
                id: "glass",
                label: "Glass",
                controls: [
                    .init(id: "refract", label: "Refract", kind: .slider(0...90, format: "%.0f")),
                    .init(id: "glint", label: "Glint", kind: .slider(0...0.8, format: "%.2f")),
                    .init(id: "chromatic", label: "Chroma", kind: .slider(0...1.5, format: "%.2f")),
                    .init(id: "falloff", label: "Falloff", kind: .slider(1.0...12.0, format: "%.1f")),
                    .init(id: "swirl", label: "Swirl", kind: .slider(0.0...2.5, format: "%.2f")),
                ]
            ),
            ComponentSpecCategory(
                id: "trail",
                label: "Trail",
                controls: [
                    .init(id: "life", label: "Life", kind: .slider(0.8...2.5, format: "%.1fs")),
                    .init(id: "emitSpacing", label: "Spacing", kind: .slider(8...60, format: "%.0f")),
                ]
            ),
        ],
        defaults: [
            "speed": 200, "bandWidth": 24, "maxRadius": 640,
            "refract": 0, "glint": 0.16, "falloff": 10.3, "swirl": 0.59,
            "displacement": 6, "life": 1.7, "emitSpacing": 30, "chromatic": 0.00,
        ]
    )

    // Refractive Sphere — default tuning from reference screenshots.
    private static let bubbleTextRippleSheet = ComponentSpecSheet(
        categories: [
            ComponentSpecCategory(
                id: "lens",
                label: "Lens",
                controls: [
                    .init(id: "refraction", label: "Refract", kind: .slider(0.0...0.6, format: "%.2f")),
                    .init(id: "falloff", label: "Falloff", kind: .slider(1.0...16.0, format: "%.1f")),
                    .init(id: "swirl", label: "Swirl", kind: .slider(0.0...6.28, format: "%.2f")),
                    .init(id: "glassRadius", label: "Radius", kind: .slider(60...260, format: "%.0f")),
                    .init(id: "chromatic", label: "Chroma", kind: .slider(0.0...0.4, format: "%.2f")),
                ]
            ),
            ComponentSpecCategory(
                id: "edge",
                label: "Edge",
                controls: [
                    .init(id: "edgeThickness", label: "Thickness", kind: .slider(2...40, format: "%.0f")),
                    .init(id: "rimIntensity", label: "Glint", kind: .slider(0.0...2.0, format: "%.2f")),
                ]
            ),
            ComponentSpecCategory(
                id: "shadow",
                label: "Shadow",
                controls: [
                    .init(id: "shadowStrength", label: "Strength", kind: .slider(0.0...0.5, format: "%.2f")),
                    .init(id: "shadowBlur", label: "Blur", kind: .slider(10...140, format: "%.0f")),
                    .init(id: "shadowOffset", label: "Offset", kind: .slider(0...48, format: "%.0f")),
                ]
            ),
        ],
        defaults: [
            "refraction": 0.60, "falloff": 8.1, "swirl": 0.00, "glassRadius": 88, "chromatic": 0.00,
            "edgeThickness": 23, "rimIntensity": 0.60,
            "shadowStrength": 0.31, "shadowBlur": 35, "shadowOffset": 0,
        ]
    )

    // Refractive Text — original Liquid preset tuning over water-drops + typography.
    private static let refractiveTextSheet = ComponentSpecSheet(
        categories: bubbleTextRippleSheet.categories,
        defaults: [
            "refraction": 0.36, "falloff": 15.4, "swirl": 0.86, "glassRadius": 86, "chromatic": 0.00,
            "edgeThickness": 2, "rimIntensity": 0.00,
            "shadowStrength": 0.00, "shadowBlur": 10, "shadowOffset": 0,
        ]
    )

    private static let sphericMeshSheet = ComponentSpecSheet(
        categories: [
            ComponentSpecCategory(
                id: "mesh",
                label: "Mesh",
                controls: [
                    .init(id: "gridDensity", label: "Density", kind: .slider(10.0...28.0, format: "%.0f")),
                    .init(id: "bulgeStrength", label: "Bulge", kind: .slider(0.4...1.5, format: "%.2f")),
                    .init(id: "dotScale", label: "Dot scale", kind: .slider(0.5...2.5, format: "%.2f")),
                ]
            ),
        ],
        defaults: ["gridDensity": 18.0, "bulgeStrength": 1.0, "dotScale": 1.35]
    )

    private static let dottedBackgroundSheet = ComponentSpecSheet(
        categories: [
            ComponentSpecCategory(
                id: "interaction",
                label: "Interaction",
                controls: [
                    .init(id: "mode", label: "Mode", kind: .slider(0.0...2.0, format: "%.0f")),
                    .init(id: "influenceRadius", label: "Radius", kind: .slider(0.15...0.60, format: "%.2f")),
                    .init(id: "maxDisplacement", label: "Push", kind: .slider(0.20...1.00, format: "%.2f")),
                ]
            ),
            ComponentSpecCategory(
                id: "grid",
                label: "Grid",
                controls: [
                    .init(id: "gridDensity", label: "Density", kind: .slider(20.0...60.0, format: "%.0f")),
                ]
            ),
        ],
        defaults: [
            "mode": 0.0, "gridDensity": 40.0,
            "influenceRadius": 0.40, "maxDisplacement": 0.60,
        ]
    )

    private static let glassEffectSheet = ComponentSpecSheet(
        categories: [
            ComponentSpecCategory(
                id: "lens",
                label: "Lens",
                controls: [
                    .init(id: "lensStrength", label: "Strength", kind: .slider(0.5...2.0, format: "%.2f")),
                    .init(id: "frostAmount", label: "Frost", kind: .slider(0.0...0.50, format: "%.2f")),
                    .init(id: "breatheSpeed", label: "Breathe", kind: .slider(0.5...2.5, format: "%.1fx")),
                    .init(id: "chromaticSplit", label: "Chroma", kind: .slider(0.8...1.4, format: "%.2f")),
                ]
            ),
        ],
        defaults: [
            "lensStrength": 1.0, "frostAmount": 0.22,
            "breatheSpeed": 1.0, "chromaticSplit": 1.0,
        ]
    )

    private static let neumorphicDigitSheet = ComponentSpecSheet(
        categories: [
            ComponentSpecCategory(
                id: "display",
                label: "Display",
                controls: [
                    .init(id: "displayWidth", label: "Width", kind: .slider(60...160, format: "%.0f")),
                    .init(id: "cycleInterval", label: "Cycle", kind: .slider(0.4...3.0, format: "%.1fs")),
                ]
            ),
        ],
        defaults: ["displayWidth": 100.0, "cycleInterval": 1.0]
    )

    private static let interactiveTilesSheet = ComponentSpecSheet(
        categories: [
            ComponentSpecCategory(
                id: "interaction",
                label: "Interaction",
                controls: [
                    .init(id: "influenceDistance", label: "Influence", kind: .slider(80.0...320.0, format: "%.0f")),
                    .init(id: "minCornerRadius", label: "Min radius", kind: .slider(0.05...0.35, format: "%.2f")),
                    .init(id: "maxCornerRadius", label: "Max radius", kind: .slider(0.35...0.65, format: "%.2f")),
                    .init(id: "animationDuration", label: "Ease", kind: .slider(0.05...0.40, format: "%.2fs")),
                ]
            ),
            ComponentSpecCategory(
                id: "texture",
                label: "Texture",
                controls: [
                    .init(id: "grainOpacity", label: "Grain", kind: .slider(0.50...1.00, format: "%.2f")),
                ]
            ),
        ],
        defaults: [
            "influenceDistance": 200.0,
            "grainOpacity": 0.88,
            "minCornerRadius": 0.2,
            "maxCornerRadius": 0.5,
            "animationDuration": 0.15,
        ]
    )

    // MARK: - Presets

    private static let searchPillPresets: [StudioComponentPreset] = [
        .init(id: "default", label: "Default", values: [:]),
    ]

    private static let blurFocusPresets: [StudioComponentPreset] = [
        .init(id: "default", label: "Default", values: [:]),
    ]

    private static let deckPresets: [StudioComponentPreset] = [
        .init(id: "default", label: "Default", values: [:]),
    ]

    private static let glassPillPresets: [StudioComponentPreset] = [
        .init(id: "default", label: "Default", values: [:]),
    ]

    private static let photoRipplePresets: [StudioComponentPreset] = [
        .init(id: "default", label: "Default", values: [:]),
    ]

    private static let photoRipple2Presets: [StudioComponentPreset] = [
        .init(id: "default", label: "Default", values: [:]),
    ]

    private static let bubbleTextRipplePresets: [StudioComponentPreset] = [
        .init(id: "default", label: "Default", values: [:]),
    ]

    private static let refractiveTextPresets: [StudioComponentPreset] = [
        .init(id: "default", label: "Default", values: [:]),
    ]

    private static let sphericMeshPresets: [StudioComponentPreset] = [
        .init(id: "default", label: "Default", values: [:]),
    ]

    private static let dottedBackgroundPresets: [StudioComponentPreset] = [
        .init(id: "default", label: "Default", values: [:]),
    ]

    private static let glassEffectPresets: [StudioComponentPreset] = [
        .init(id: "default", label: "Default", values: [:]),
    ]

    private static let neumorphicDigitPresets: [StudioComponentPreset] = [
        .init(id: "default", label: "Default", values: [:]),
    ]

    private static let interactiveTilesPresets: [StudioComponentPreset] = [
        .init(id: "default", label: "Default", values: [:]),
    ]
}
