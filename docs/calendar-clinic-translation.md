# Calendar / Clinic Translation

## Source Files Inspected

- `reference/html/疫苗日历.html`
- `reference/html/接种单位.html`
- `reference/html/添加诊所.html`
- `reference/html/css/status-bar.css`
- `reference/html/js/baby-profile.js`
- `reference/html/js/system-time.js`
- Booking clinic scripts referenced by the home flow: `vaccine-booking-clinic.js` and `vaccine-booking-clinic-select.js`

## Native Implementation

- Added `VaccineCalendarView` for the native monthly vaccine calendar.
- Added `ClinicListView` and `AddClinicView` for clinic management.
- Connected `.vaccineCalendar`, `.clinicList`, and `.addClinic` routes to native SwiftUI pages.
- Calendar appointments are derived from every child in `GrowthCareStore.childData.bookedDoses`. New users start with no booked doses, so calendar content appears after the user books vaccines.
- Clinic list reads `store.clinics`; adding a clinic calls the Foundation hook `store.addClinic(...)`.

## Assets

- Reused existing assets: `fanhui`, `zhentou`, `yuyueqiu`, `jiahao`, child avatars.
- Added prototype assets: `qianyige`, `houyige`, `zhensuo`, `waiting`.
- Updated `ios/AssetSourceMap.md`.

## Parity Notes

- Preserved the calendar gradient background, 7-column weekday grid, selected day circle, child-colored appointment bars, and pink/blue appointment cards.
- Preserved the clinic list header, search row, filter labels, rounded clinic cards, clinic icon, booking tag, and distance text style.
- Did not draw prototype-only fake phone chrome: status bar, Dynamic Island, battery strip, or home indicator.
- The HTML `添加诊所.html` is a "feature in development" placeholder. The native rewrite uses the same header/illustration mood but adds a small functional form so the already-approved `store.addClinic(...)` hook can be exercised.

## Known Differences

- Clinic cards display address and business hours because the current native `Clinic` model does not include phone or real distance fields.
- Filter controls show a placeholder alert; the prototype also uses alert-only filter behavior.
- The calendar defaults to the first upcoming booked appointment month when one exists; otherwise it opens on the current month.

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
