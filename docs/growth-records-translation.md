# Growth Records Translation Notes

Status: implemented
Last verified: 2026-06-17 sandbox build

## Sources Inspected

- `reference/html/成长记录.html`
- `reference/html/成长记录添加.html`
- `reference/html/js/baby-profile.js`
- `reference/html/css/status-bar.css`
- `reference/html/css/bottom-nav.css`
- `reference/html/css/modal-animations.css`
- Figma parity node: file `e043UztTYEpBRF8hOZ3WAo`, node `84:3175`
- Figma add-record overlay node: file `e043UztTYEpBRF8hOZ3WAo`, node `1161:8134`

## Assets Reused

- `height` from `reference/html/images/height.png`
- `weight` from `reference/html/images/weight.png`
- `height-picker-line` from `reference/html/images/height-picker-line.svg`
- `height-picker-ruler` from `reference/html/images/height-picker-ruler.svg`

All are registered in `ios/AssetSourceMap.md`.

## Native Mapping

- `reference/html/成长记录.html` maps to `GrowthRecordsView`.
- `reference/html/成长记录添加.html` maps to `AddGrowthRecordView`.
- `BabyProfile.getGrowthRecords`, `addGrowthRecord`, `removeGrowthRecord`, and `formatAgeZh` map to `GrowthCareStore` methods.
- New users start with one placeholder child (`孩子1`) whose birthday defaults to the current day; growth records start empty until the user edits or adds records.
- The `曲线/记录` segmented control switches between `GrowthCurveView` and `GrowthRecordsView`.
- Growth records remain child-specific and in memory through the existing snapshot boundary.

## Implemented Behavior

- Growth record list shows timeline dots, record cards, height/weight rows, and the add card.
- The initial default child has no seeded growth records; the record list starts with the add card.
- Records sort by date, then id.
- Swipe left opens a native delete action area; delete updates the active child immediately.
- Add flow opens a Figma-style overlay on top of the dimmed records page. The white panel uses the 440pt reference canvas coordinates (`x=22`, `y=102`, `400 x 750pt`, `15pt` radius) and returns to records after saving.
- Add flow captures date, height, and weight through custom visual controls: a three-column date wheel, a vertical height ruler, and a semicircle weight dial. The height ruler and red indicator line stay fixed on the right while the centered number column scrolls vertically; whichever number reaches the center line becomes black. Weight changes by clockwise/counter-clockwise rotation at `0.1kg` per `2°` dial step.
- Added/deleted records feed the existing growth curve because `GrowthCurveView` reads `store.activeGrowthRecords()`.
- Bottom navigation uses the shared safe-area-aware `BottomTabBar`.

## Intentional Differences

- The HTML add page uses JavaScript wheel and dial controls. Native SwiftUI now recreates that visual language with custom draggable views, rather than system `DatePicker` or `Slider` controls. The weight dial uses the same circular angle-delta model as the prototype instead of a horizontal drag shortcut.
- The HTML delete icon is inline SVG. SwiftUI uses the native trash symbol because there is no standalone prototype asset for that icon.
- Fake prototype status bar, Dynamic Island, battery indicators, and home indicator are not rendered.
- The Figma `84:3175` growth-record screen has no gray fade immediately below the red header. The native list therefore starts directly on the page background; only the shared bottom-navigation shadow remains above the tab bar.
- The Figma `1161:8134` add overlay shows the records page dimmed behind the panel. Native SwiftUI keeps the same interaction model: tapping outside dismisses without saving, and the yellow circular save button writes to the existing child-specific in-memory records.

## Verification

Passed:

```sh
xcodebuild -project GrowthCare.xcodeproj \
  -scheme GrowthCare \
  -destination 'generic/platform=iOS' \
  -derivedDataPath ../../work/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  EXCLUDED_SOURCE_FILE_NAMES='*.xcassets' \
  build
```

Sandbox notes: CoreSimulatorService warnings are expected in this environment; this command validates Swift compilation and project membership but skips asset compilation.
