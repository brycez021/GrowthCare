# Integrated QA / Parity Report

Date: 2026-06-15
Owner: current single Codex agent

## Scope

This report covers the single-agent integration pass after replacing the remaining sub-agent plan. It verifies native routing, bottom navigation safe-area behavior, state linkage, asset documentation, and sandbox build health for the current SwiftUI app.

## Routes Checked

- Bottom `预约` tab opens `HomeView`.
- Bottom `接种时间表` tab opens `ScheduleView`.
- Bottom `成长曲线` tab opens `GrowthCurveView`.
- Bottom `我的` tab opens `ProfileView`.
- Calendar and clinic routes open `VaccineCalendarView`, `ClinicListView`, and `AddClinicView`.
- Growth record routes open `GrowthRecordsView` and `AddGrowthRecordView`.
- Profile routes open parent profile, child profile, reminder date, reminder time, shared members, and add shared member pages.
- Vaccine detail and optional vaccine routes remain connected to their native pages.

## Bottom Navigation

- `BottomTabBar` now receives the real `GeometryProxy.safeAreaInsets.bottom`.
- The tappable icon/text content stays above the Home Indicator area through the real bottom safe-area inset.
- Pages using the shared tab bar reserve matching bottom space so content is not hidden behind the bar.
- The pink background still extends to the physical bottom edge, preserving the prototype visual while using native safe-area layout.
- Latest Figma pass sets the laid-out bottom navigation content area to `68pt`; on iPhone devices with a `34pt` bottom safe area this produces the Figma `102pt` visual bar.
- `BottomTabBar.reservedHeight(for:)` now returns `68pt + bottom safe area`, so every tab page reserves the visible bar height without double-counting the Home Indicator.

## Layout Pass: 2026-06-15

- The ordinary appointment home state now uses a `140pt` top band; later layout passes set growth and profile headers to `205pt`.
- The appointment next-dose card is horizontally centered and the vaccine list starts below the card instead of sliding under it.
- The vaccination schedule uses adaptive age and vaccine columns so the third vaccine column remains inside the phone width on smaller screens.
- The schedule's center background band now follows the dynamically computed second vaccine column instead of the original 440px prototype offset.

## Home Appointment Figma Pass: 2026-06-16

- The appointment-state home layout was checked against Figma file `e043UztTYEpBRF8hOZ3WAo`, node `149:1069` (`首页预约001`), with subnodes `181:787` for the next-dose card and `296:4507` for vaccine rows.
- When a future appointment exists, the home top band uses the Figma `205pt` appointment-state height. The no-appointment home state uses the requested `140pt` band.
- The next-dose card now follows the high-fidelity 400 x 166 layout, starts at `y=149pt` from the physical screen top after subtracting the real top safe-area inset, uses a 376 x 96 inner panel, and keeps the larger 119 x 44 `修改计划` action.
- The next-dose card now includes the same glass-card treatment as the profile card: translucent gradient fill, white stroke, soft shadow, and a blurred bottom glow.
- The appointment-state vaccine list now starts from the card's bottom plus `45pt` visually, with the row's internal `7pt` top padding deducted from the spacer so the visible vaccine card edge matches the requested distance.

## Profile Figma Pass: 2026-06-16

- The `我的` layout was checked against Figma file `e043UztTYEpBRF8hOZ3WAo`, frame `1194:8169` (`我的001`).
- The profile top band now uses the requested `205pt` height on `ProfileView`; the profile card's visible top edge is fixed at `y=100pt` from the physical screen top, with a `400 x 133pt` glass card on a 440pt canvas.
- The profile card uses the same blurred bottom glow treatment as the next-dose appointment card.
- The child info, clinic, reminders, and sharing sections use tighter Figma spacing, with titles starting near `269pt`, `434pt`, `584pt`, and `878pt` respectively.
- Existing profile, child, clinic, reminder, and sharing routes remain unchanged; bottom navigation uses a `68pt` content area plus the real bottom safe area.

## Top Spacing Pass: 2026-06-17

- `预约` without a next-dose card uses a `140pt` top band and starts the first vaccine card `34pt` below the band.
- `预约` with a next-dose card keeps the `205pt` top band; the next-dose card starts at physical-screen `y=149pt`, and the first vaccine card starts `45pt` below the next-dose card.
- `预约`, `接种时间表`, and `成长曲线` place the child switcher at `y=66pt`; the appointment calendar button is aligned with the switcher.
- The `我的` parent profile card is rendered as a top overlay so list content cannot cover it; add rows use a `20 x 20pt` plus icon.
- Child profile and clinic add/list headers use a `140pt` top band measured from the screen top.

## iPhone 17 Pro Max Adaptive Pass: 2026-06-17

- Layout is now checked against a `440 x 956pt` portrait baseline for iPhone 17 Pro Max-style screens.
- Shared layout constants include `maxDesignWidth = 440`, `bottomTabBarHeight = 68`, `profileTopBandHeight = 205`, `growthTopBandHeight = 205`, `childSwitcherHeight = 40`, and `growthSegmentBottomPadding = 20`.
- Growth chart sizing is now driven by the parent container width instead of `UIScreen.main.bounds`, so the chart scales within the current SwiftUI layout.
- Schedule content caps at the 440pt design width and stays centered on wider canvases while keeping the adaptive vaccine columns.
- Profile and modal card widths use the shared design-width cap instead of repeating raw `400pt` limits.
- Figma bottom navigation node `1194:8241` uses a 102pt visual bar with 16pt top padding and 34pt bottom safe-area padding; SwiftUI now models that as a 68pt content bar plus the real safe-area inset.
- The four bottom-tab pages now share one `BottomNavShadow` layer. Its 64pt black-to-transparent gradient is offset by the `68pt` bottom-tab content height only, so the gradient bottom meets the pink navigation bar's top edge on devices with or without a bottom safe area.

## Growth Segment Pass: 2026-06-15

- Growth Figma references were checked against file `1enm3HFjsV7KMuqwHLsz1J`: curve node `5:850`, records node `5:964`, and add-record overlay node `5:1069`. The supplied `34:1113` link is a profile screen and was excluded from growth layout decisions.
- The `曲线 / 记录` secondary tab now switches inside `GrowthCurveView` with local state instead of pushing `GrowthRecordsView`, removing the horizontal page-slide transition between those two states.
- Both curve and records states now use the requested native `205pt` top band; the secondary segmented control keeps equal-height buttons and sits `20pt` above the header edge.
- The records timeline is shared between the embedded growth page and the compatibility `GrowthRecordsView` route; add/delete actions still update the same child-specific growth records used by the curve.
- The timeline dot/content alignment now follows Figma's approximate x positions: dot near `25pt`, content starting near `54pt`, with record cards around `366pt` wide and the add card around `83pt` tall on a 440pt canvas.

## Growth Records Figma Pass: 2026-06-17

- Growth-record Figma node `e043UztTYEpBRF8hOZ3WAo` / `84:3175` was checked for the records layout.
- Fresh app state now starts with one placeholder child (`孩子1`) whose birthday is the current day; growth records are empty until the user adds them.
- Removed the gray fade layer immediately below the red growth-record header. The only remaining bottom fade is the shared shadow above the bottom tab bar.
- Add-growth-record overlay was checked against Figma node `1161:8134`. The route still uses `AddGrowthRecordView`, but it now renders a dimmed records-page backdrop with a white `400 x 750pt` rounded panel positioned at the Figma `440pt` canvas coordinates.
- The add overlay no longer shows system picker/slider controls. Date, height, and weight use custom native SwiftUI visuals matching the Figma wheel/ruler/dial layout, while preserving the existing save and outside-tap-dismiss behavior.
- The height picker now follows the prototype's fixed-ruler behavior: the right ruler and red line stay fixed, the centered number column scrolls vertically, and the number closest to the center line turns black. The weight picker follows the circular dial behavior (`0.1kg` per `2°`, clockwise/counter-clockwise) instead of a left/right drag shortcut.

## State And Behavior

- Growth records are child-specific. Add/delete operations update the active child's `growthRecords`, and the growth curve reads from the same data.
- Profile, reminder, child profile, and shared members mutate the existing Foundation models and in-memory snapshot boundary.
- Clinic additions update `store.clinics` and appear in the clinic list.
- The app intentionally keeps native iOS chrome and does not draw the HTML prototype's fake status bar, Dynamic Island, battery strip, or Home Indicator.

## Assets And Docs

- `ios/AssetSourceMap.md` includes the growth record picker assets and profile/reminder/sharing assets copied from `reference/html/images/`.
- Translation docs exist for home, schedule, growth curve, growth records, vaccine detail/optional vaccine, calendar/clinic, and profile/reminder/sharing.
- `docs/multi-agent-plan.md` is retired and points to `docs/solo-execution-plan.md`.
- `AGENTS.md` and `contributing_ai.md` now forbid creating or resuming sub-agents unless the user explicitly reinstates multi-agent mode.

## Known Differences

- Full simulator/device visual QA was not run inside the restricted Codex sandbox because CoreSimulatorService is unavailable.
- The accepted sandbox build skips asset catalog compilation with `EXCLUDED_SOURCE_FILE_NAMES='*.xcassets'`; full asset rendering still needs a normal Xcode/simulator pass.
- Real local persistence is not implemented; the project intentionally keeps the current in-memory persistence boundary.
- The home booking remark editor remains a follow-up placeholder inside the already-translated appointment overlay flow.
- The `添加诊所.html` prototype itself is a development placeholder; the native app provides a functional add-clinic form using the existing store hook.

## Verification

Accepted sandbox command:

```sh
xcodebuild -project GrowthCare.xcodeproj \
  -scheme GrowthCare \
  -destination 'generic/platform=iOS' \
  -derivedDataPath ../../work/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  EXCLUDED_SOURCE_FILE_NAMES='*.xcassets' \
  build
```

Latest integrated result after the 140pt/205pt top-spacing pass: `BUILD SUCCEEDED`.

Latest growth segment pass result: `BUILD SUCCEEDED`.

Latest iPhone 17 Pro Max adaptive pass result: `BUILD SUCCEEDED`.

Latest top spacing/profile overlay pass result: `BUILD SUCCEEDED`.

Latest growth add overlay pass result: `BUILD SUCCEEDED`.
