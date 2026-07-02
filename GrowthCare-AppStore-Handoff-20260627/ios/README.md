# iOS Workspace

This directory contains the native SwiftUI implementation of GrowthCare.

Current status:
- `GrowthCare/` contains an XcodeGen-backed Xcode project.
- The home page has been rewritten from `reference/html/index.html`.
- The vaccination schedule, growth curve, vaccine detail, optional vaccine add/restore, vaccine calendar, and clinic-management pages have native SwiftUI implementations.
- Growth-record and profile/reminder/sharing detail pages still use integration placeholders until their HTML source files are translated.
- The app targets iOS 16 minimum.
- No WebView wrapper is allowed for production pages.

Useful files:
- `GrowthCare/project.yml`: XcodeGen project definition.
- `GrowthCare/GrowthCare.xcodeproj`: generated Xcode project.
- `GrowthCare/GrowthCare/`: SwiftUI source and asset catalog.
- `AssetSourceMap.md`: trace from Swift assets back to prototype image files.

Workflow:
- Follow `../AGENTS.md` and `../docs/html-to-swiftui.md` for every page rewrite.
- Before translating a page, inspect its HTML, CSS, JS, and image assets under `../reference/html/`.
- Import needed image assets from `../reference/html/images/` and update `AssetSourceMap.md`.
- After translating, run the app in Simulator and compare against the HTML prototype.

Codex sandbox verification:
- The desktop sandbox may block `CoreSimulatorService`, which makes `simctl` and Xcode asset catalog thinning fail even when Swift code is valid.
- For code-level verification inside the sandbox, use:

```sh
xcodebuild -project GrowthCare.xcodeproj \
  -scheme GrowthCare \
  -destination 'generic/platform=iOS' \
  -derivedDataPath ../../work/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  EXCLUDED_SOURCE_FILE_NAMES='*.xcassets' \
  build
```

- This intentionally skips asset catalog compilation only for sandbox verification. Normal local Xcode/Simulator verification should still build the full app with assets.
