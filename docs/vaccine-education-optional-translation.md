# Vaccine Education / Optional Vaccine Translation

## Source Files Inspected

- `reference/html/疫苗详情.html`
- `reference/html/疫苗添加.html`
- `reference/html/css/vaccine-detail.css`
- `reference/html/css/status-bar.css`
- `reference/html/js/vaccine-info.js`
- `reference/html/js/vaccine-detail.js`
- `reference/html/js/vaccine-schedule.js`
- `reference/html/js/baby-profile.js`
- Relevant home add/hide/detail hooks in `reference/html/index.html`

## Native Implementation

- Added `VaccineDetailView` for the native vaccine education page.
- Added `AddVaccineView` for optional vaccine add/restore management.
- Added `VaccineInfoStore` with all 19 vaccine info entries migrated from `vaccine-info.js`.
- Added native route support for `.vaccineDetail(name:initialTab:)` and `.addVaccine`.
- Connected home vaccine help icons, home add button, and schedule pills to native routes.
- Added optional vaccine state handling in `GrowthCareStore`:
  - Optional vaccines: `五联疫苗`, `五价轮状疫苗`, `13价肺炎疫苗`, `手足口疫苗`, `水痘疫苗`, `流感疫苗`.
  - Add/restore removes the vaccine from `hiddenVaccines`.
  - Non-default optional vaccines are appended to `addedVaccines`.
  - `卡介苗` and `乙肝疫苗` remain pinned and cannot be hidden.

## Assets

- Reused existing assets: `zhentou`, `kepuwenhao`, `jiahao`.
- Added `fanhui` from `reference/html/images/fanhui.png` for native detail/add-page back buttons.
- Updated `ios/AssetSourceMap.md`.

## Parity Notes

- Preserved the detail page pink header, rounded back button, segmented `疫苗简介 / 注意事项` control, section tags, schedule table, reason list, side-effect card, and precaution blocks.
- Preserved add-page pink header, rounded rows, syringe/help icons, disabled already-added state, and plus/check button behavior.
- Did not draw prototype-only fake phone chrome: status bar, Dynamic Island, battery strip, or home indicator.
- Unknown vaccines, including `流感疫苗`, show the same fallback intent as the prototype: consult the vaccination clinic.

## Verification

Sandbox code-level build passed:

```sh
xcodebuild -project GrowthCare.xcodeproj \
  -scheme GrowthCare \
  -destination 'generic/platform=iOS' \
  -derivedDataPath ../../work/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  EXCLUDED_SOURCE_FILE_NAMES='*.xcassets' \
  build
```

Result: `BUILD SUCCEEDED`.

Full simulator visual QA was not run because this Codex sandbox cannot connect to `CoreSimulatorService`; the accepted sandbox build intentionally skips asset catalog compilation.
