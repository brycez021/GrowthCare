# Foundation / Integration Handoff

## Goal

Prepare the shared native SwiftUI foundation so feature agents can replace placeholders without duplicating routing, model, persistence-boundary, or Xcode project changes.

## Source Files Inspected

- `AGENTS.md`
- `contributing_ai.md`
- `README.md`
- `docs/html-to-swiftui.md`
- `docs/project-map.md`
- `docs/multi-agent-plan.md`
- Existing SwiftUI shared files under `ios/GrowthCare/GrowthCare/`

## Shared Changes

- Added app-level route coverage in `AppRoute` for vaccine detail, add vaccine, calendar, clinic list/add clinic, growth records/add record, parent/child profile, reminder date/time, shared members, and add shared member.
- Added typed store routing hooks including `openCalendar`, `openClinicList`, `openGrowthRecords`, `openParentProfile`, `openReminderDate`, and `openSharedMembers`.
- Added shared model shells for `Clinic`, `ParentProfile`, `ReminderSettings`, `SharedMember`, and `OptionalVaccine`.
- Added `GrowthCareSnapshot`, `GrowthCarePersistence`, and `InMemoryGrowthCarePersistence` as an interface-only persistence boundary.
- Added `RoutePlaceholderView` and `ProfileIntegrationView` during the original foundation pass so pending feature areas had stable native entry points instead of bouncing back to Home. Later single-agent work replaced the active routes with native pages.
- Updated the Xcode project metadata so new Swift files are compiled by the app target.

## Integration Hooks

- Calendar / Clinic routes now point to `VaccineCalendarView`, `ClinicListView`, and `AddClinicView`, reusing `store.clinics` plus `store.addClinic(...)`.
- Growth Records routes now point to `GrowthRecordsView` and `AddGrowthRecordView`, mutating child-specific `growthRecords` inside `ChildData`.
- Profile / Reminder / Sharing routes now point to native profile, child profile, reminder date/time, shared members, and add shared member pages.
- Vaccine detail and add vaccine routes already point to native SwiftUI views; schedule pills and home help buttons use `openVaccineDetail`.

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

CoreSimulatorService was unavailable in the Codex sandbox, so simulator runtime interaction and visual QA were not performed in this handoff.

## Known Gaps

- Persistence is intentionally not real local storage yet; the boundary remains in-memory until model behavior stabilizes.
- Calendar, clinic, growth record, and profile/reminder/sharing screens have been translated to native SwiftUI after this foundation handoff.
- The home remark editor still shows a local placeholder because it belongs to the existing booking overlay flow, not the cross-feature route foundation.
