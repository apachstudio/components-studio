# Components Studio

A standalone Xcode app — the **SwiftUI Components Studio** catalog for building,
tweaking, and recording **iOS 26+ Liquid Glass** components. Each item opens on
a stage with pin-based presets and a unified spec toolbar so you can iterate on
visuals and motion in isolation.

This is the sibling of `ComponentStudioView` from
[bubble-cloud](https://github.com/apachstudio/bubble-cloud), expanded into its
own catalog (shaders, cards, pills, loading, scroll, search).

---

## Run it

The `.xcodeproj` is not committed — generate it from `project.yml`:

```sh
brew install xcodegen      # one-time
xcodegen generate          # creates ComponentsStudio.xcodeproj
open ComponentsStudio.xcodeproj
```

Then run on an **iOS 26 (or later) simulator**.

Re-run `xcodegen generate` whenever you add or rename source files.

---

## Layout

```
ComponentsStudio/
├── ComponentsStudioApp.swift    @main entry
├── ComponentStudioView.swift    Catalog + stage + StudioItem registry
├── ComponentSpecToolbar.swift   Unified pin / preset toolbar
├── StudioItemSpecs.swift        Per-item controls and presets
├── StudioSampleData.swift       Sample places for studio stages
├── Theme.swift                  Geometric tokens (radii, spacing)
├── Info.plist                   App fonts (Dripdrop)
├── Assets.xcassets/             Logo, icon, shader backgrounds
├── Fonts/                       Bundled display font
├── Shaders/StudioShaders.metal  Shader catalog kernels
├── DS/                          Aurora tokens + font registration
├── Models/                      Place / Catalog sample models
└── Components/                  One view file per catalog item
```

Add a new component:

1. Add a `case` to `StudioItem`.
2. Add its `title` and layout entries.
3. Register controls + presets in `StudioItemSpecs`.
4. Wire `specState` in `ComponentStudioStage.body`.
5. Register the item in `StudioCatalog.categories`.
6. Set `StudioItem.lastUpdated` (catalog sorts newest first).

---

## Catalog

| Section | Items |
| --- | --- |
| Shaders | Interactive Tiles, Dotted Background, Neumorphic Digit, Photo Ripple, Liquid Photo, Refractive Text, Refractive Sphere, Spheric Mesh, Glass Effect |
| Cards | Satelite Cards |
| Pills | Glass Pill |
| Loading | Summary Blur Loading |
| Scroll | Vertical card deck |
| Search | AI Search |

---

## Design system

**Liquid Glass only.** The two dialects (input surfaces vs chrome) and the
rules of the road are spelled out in [`GUIDELINES.md`](GUIDELINES.md). The
recurring SwiftUI patterns and gotchas live in [`SKILLS.md`](SKILLS.md).

`Theme` owns radii and spacing. Aurora (`DS/Aurora.swift`) owns ink / canvas
colour and the display font.

---

## Recording mode

Triple-tap the stage to hide chrome for a clean screen recording. Triple-tap
again to bring it back.
