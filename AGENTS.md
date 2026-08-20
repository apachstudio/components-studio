# AGENTS.md

## Cursor Cloud specific instructions

**This repository is a native iOS app and cannot be built, run, or tested on the
Cursor Cloud Agent VM (Linux x86_64 / Ubuntu 24.04).** Plan accordingly: code can
be edited and reviewed here, but verification must happen on macOS.

### What this project is
- An **iOS 26+ SwiftUI** sandbox app ("Components Studio"), built as an Xcode
  project that is generated from `project.yml` via **XcodeGen** (the
  `.xcodeproj` is intentionally not committed — see `.gitignore`).
- Every source file under `ComponentsStudio/` imports `SwiftUI` (and `UIKit`),
  and the code uses iOS 26-only APIs such as `glassEffect` (Liquid Glass) and
  `UIImpactFeedbackGenerator`.

### Why it can't run on the Cloud VM (hard platform limitation)
- `SwiftUI`, `UIKit`, the iOS 26 SDK, and the iOS Simulator ship **only with
  Xcode on macOS**. They are not part of the open-source Swift toolchain.
- Installing Swift on Linux does **not** help: a working `swiftc` on Linux still
  reports `error: no such module 'SwiftUI'` / `no such module 'UIKit'`, so even
  type-checking the real sources fails.
- `xcodebuild`, `xcrun`, `simctl`, `xcodegen`, and `brew` are all unavailable
  here, and `xcodegen` only produces a project that still requires Xcode to build.
- Net effect: there is **no lint/build/test/run command that works on this Linux
  VM**. Do not attempt to "fix the environment" by installing Swift — it will not
  make the app compile.

### How it is actually built/run (requires macOS + Xcode 26 + iOS 26 simulator)
The canonical commands live in `README.md`. In short, on a Mac:
1. `brew install xcodegen` (one-time)
2. `xcodegen generate` (regenerate `ComponentsStudio.xcodeproj` after adding/renaming files)
3. `open ComponentsStudio.xcodeproj` and run on an **iOS 26+ simulator**

### Design-system / code conventions
See `GUIDELINES.md` (Liquid Glass dialects + rules) and `SKILLS.md` (recurring
SwiftUI patterns and gotchas) before editing any `.swift` file.
