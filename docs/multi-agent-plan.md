# GrowthCare Multi-Agent Plan

> RETIRED: This plan is no longer active. Do not create, resume, or coordinate sub-agents from this document unless the user explicitly reinstates multi-agent mode.
>
> Active execution plan: `docs/solo-execution-plan.md`.

## Recommended Size

Historical recommendation: **6 sub-agents**.

This was the earlier parallelization plan. The project has now moved to single-agent execution so shared models, routes, project metadata, docs, and QA stay under one owner.

## Current Native Status

Implemented:
- Foundation / Integration shared routing, model boundaries, route placeholders, and persistence interface
- Appointment home page: `reference/html/index.html`
- Vaccination schedule: `reference/html/接种时间表.html`
- Growth curve: `reference/html/成长曲线.html`
- Growth record list and add-record flow: `reference/html/成长记录.html`, `reference/html/成长记录添加.html`
- Vaccine detail and optional vaccine add/restore: `reference/html/疫苗详情.html`, `reference/html/疫苗添加.html`
- Vaccine calendar and clinic management: `reference/html/疫苗日历.html`, `reference/html/接种单位.html`, `reference/html/添加诊所.html`
- Profile, reminders, child profile, and shared members: `reference/html/我的.html`, `reference/html/个人信息.html`, `reference/html/孩子信息.html`, `reference/html/提醒日期.html`, `reference/html/提醒时间.html`, `reference/html/添加共享成员.html`

Still pending outside the retired multi-agent plan:
- Full simulator/device visual QA outside the restricted sandbox
- Real local persistence, if later approved

Single-agent integrated sandbox QA has been completed; see `docs/qa-parity-report.md`.

## Agent Assignments

### 1. Foundation / Integration Agent

Owns shared architecture and merges.

Primary responsibilities:
- App routing and navigation integration.
- Shared native models and state boundaries.
- Persistence design and implementation, when approved.
- Shared design primitives and reusable components.
- Xcode project metadata and build verification.
- Merge shared-file changes from feature agents.

Default owned files:
- `ios/GrowthCare/GrowthCare/GrowthCareApp.swift`
- `ios/GrowthCare/GrowthCare/GrowthCareStore.swift`
- `ios/GrowthCare/GrowthCare/Models.swift`
- `ios/GrowthCare/GrowthCare/DesignSystem.swift`
- `ios/GrowthCare/GrowthCare.xcodeproj/project.pbxproj`
- `ios/AssetSourceMap.md`

Key inputs:
- All translation docs from feature agents.
- New state requirements from vaccine, growth, calendar, and profile flows.

DoD:
- DONE: Shared model/routing changes are integrated once, not duplicated.
- DONE: Accepted sandbox build command succeeds.
- DONE: Feature agents have clear integration hooks.

Completion notes:
- Native files: `GrowthCareApp.swift`, `GrowthCareStore.swift`, `Models.swift`, `GrowthCarePersistence.swift`, `IntegrationPlaceholderViews.swift`, and Xcode project metadata.
- Shared hooks: `AppRoute`, `navigationPath`, typed `open...` route methods, clinic/reminder/profile/shared-member model shells, and snapshot persistence boundary.
- Persistence remains interface-only by design; no `UserDefaults`, file storage, SwiftData, or migration schema has been added.
- Handoff doc: `docs/foundation-integration-handoff.md`.
- Verification: sandbox code-level Xcode build passed with `EXCLUDED_SOURCE_FILE_NAMES='*.xcassets'`; CoreSimulatorService was unavailable for simulator runtime QA.

### 2. Vaccine Education / Optional Vaccine Agent

Owns vaccine education and optional vaccine flows.

Primary HTML sources:
- `reference/html/疫苗详情.html`
- `reference/html/疫苗添加.html`
- `reference/html/js/vaccine-info.js`
- `reference/html/js/vaccine-detail.js`

Primary responsibilities:
- Native vaccine detail page with intro and precautions tabs.
- Links from home and schedule vaccine pills.
- Add optional vaccines and restore hidden vaccines.
- Preserve pinned vaccine rules for `卡介苗` and `乙肝疫苗`.

Expected outputs:
- `VaccineDetailView` and optional-vaccine views.
- A page translation doc under `docs/`.
- Asset additions and mapping requests.

DoD:
- DONE: Home and schedule can navigate to native vaccine detail.
- DONE: Optional vaccine add/restore flows update native state.
- DONE: Hidden/pinned rules match prototype behavior.

Completion notes:
- Native files: `VaccineDetailView.swift`, `AddVaccineView.swift`, `VaccineInfoStore.swift`.
- Translation doc: `docs/vaccine-education-optional-translation.md`.
- Verification: sandbox code-level Xcode build passed with `EXCLUDED_SOURCE_FILE_NAMES='*.xcassets'`.

### 3. Calendar / Clinic Agent

Owns appointment calendar and clinic management.

Primary HTML sources:
- `reference/html/疫苗日历.html`
- `reference/html/接种单位.html`
- `reference/html/添加诊所.html`
- Booking clinic scripts already referenced by home overlays.

Primary responsibilities:
- Native monthly vaccine calendar.
- Appointments for both children with child-specific colors.
- Calendar month navigation and appointment cards.
- Clinic list, clinic selection, add clinic illustration/page.
- Connect home calendar button to native calendar.

Expected outputs:
- `VaccineCalendarView` and clinic-management views.
- Calendar/clinic translation docs under `docs/`.
- Asset additions and mapping requests.

DoD:
- DONE: Calendar shows booked appointments for both seed children.
- DONE: Home calendar button opens native calendar.
- DONE: Clinic additions are represented in native state.

Completion notes:
- Native files: `VaccineCalendarView.swift`, `ClinicViews.swift`.
- Translation doc: `docs/calendar-clinic-translation.md`.
- Assets added: `qianyige`, `houyige`, `zhensuo`, `waiting`.
- Verification: sandbox code-level Xcode build passed with `EXCLUDED_SOURCE_FILE_NAMES='*.xcassets'`.

### 4. Growth Records Agent

Owns growth timeline and add-record flow.

Primary HTML sources:
- `reference/html/成长记录.html`
- `reference/html/成长记录添加.html`
- `reference/html/js/baby-profile.js`

Primary responsibilities:
- Native growth record timeline.
- Swipe-to-delete records.
- Add record flow with date, height, and weight selection.
- Update growth curve data through native `growthRecords`.
- Preserve child-specific growth records.

Expected outputs:
- `GrowthRecordsView` and add-record views/sheets.
- Growth record translation docs under `docs/`.
- Asset additions and mapping requests for `height`, `weight`, picker/ruler assets.

DoD:
- `成长曲线` segmented `记录` tab opens native records.
- Add/delete records update the active child and reflect on the curve.
- Empty state and seed record behavior match prototype.

### 5. Profile / Reminder / Sharing Agent

Owns `我的` and related settings flows.

Primary HTML sources:
- `reference/html/我的.html`
- `reference/html/个人信息.html`
- `reference/html/孩子信息.html`
- `reference/html/提醒日期.html`
- `reference/html/提醒时间.html`
- `reference/html/添加共享成员.html`
- `reference/html/js/reminder-date-modal.js`
- `reference/html/js/reminder-time-modal.js`
- `reference/html/js/share-member-modal.js`

Primary responsibilities:
- Native profile tab.
- Parent profile and child profile add/edit forms.
- Reminder alarm toggle, reminder mode, custom days, and reminder time.
- Shared member invite/list flow.
- Clinic entry points owned by Calendar / Clinic Agent should be linked, not duplicated.

Expected outputs:
- `ProfileView` and related modal/form views.
- Profile/reminder/sharing translation docs under `docs/`.
- Asset additions and mapping requests for profile icons.

DoD:
- Bottom `我的` tab opens native profile.
- Reminder settings mutate native state.
- Child profile changes affect shared child switching after integration.

### 6. QA / Parity Agent

Owns integrated verification and acceptance notes.

Primary responsibilities:
- Compare native screens against prototype sources.
- Verify asset names and `ios/AssetSourceMap.md`.
- Run build commands and record environment-specific limitations.
- Check bottom-tab state, child switching, modal sequences, date formatting, and empty/booked/done states.
- Maintain a concise final QA report.

Expected outputs:
- `docs/qa-parity-report.md` or updates to page-specific translation docs.
- Inline findings with file/line references when regressions are found.

DoD:
- Integrated build passes with the accepted command.
- Known gaps are explicit and tied to pending source pages.
- No feature is marked complete without source inspection and parity notes.

## Retired Coordination Rules

- These rules are retained for historical traceability only.
- Do not start sub-agent tasks from this plan.
- Active work should read `docs/solo-execution-plan.md` instead.
- Historical rule: start each sub-agent task by reading `AGENTS.md`, `contributing_ai.md`, `README.md`, `docs/html-to-swiftui.md`, `docs/project-map.md`, and this file.
- Feature agents should create feature-specific files where possible.
- Shared-file edits must be routed through the Foundation / Integration Agent unless they are tiny and explicitly assigned.
- Every asset copied from `reference/html/images/` must be added to `ios/AssetSourceMap.md`.
- Every page rewrite must create or update a translation note under `docs/`.
- Avoid parallel edits to `GrowthCareStore.swift`, `Models.swift`, and `GrowthCareApp.swift`; these are integration-owned.
- If a feature needs new shared state, the feature agent documents the required fields and behavior, then the Foundation / Integration Agent adds them.
- Each handoff must include verification result and whether the result used the sandbox build command or a full Xcode/Simulator run.

## Suggested Order

Historical order:
1. DONE: Foundation / Integration prepared shared routing conventions and state boundaries.
2. DONE: Vaccine Education / Optional Vaccine completed native detail/add flows.
3. DONE: Calendar / Clinic completed native calendar and clinic-management flows.
4. DONE: Growth Records work was completed by the single current Codex agent.
5. DONE: Profile / Reminder / Sharing work was completed by the single current Codex agent.
6. RETIRED: QA / Parity Agent assignment is now owned by the single current Codex agent.

## Verification

Normal local verification should use the full Xcode/Simulator build and manual visual comparison.

Inside the Codex desktop sandbox, `CoreSimulatorService` may be unavailable. Use this code-level build command:

```sh
xcodebuild -project GrowthCare.xcodeproj \
  -scheme GrowthCare \
  -destination 'generic/platform=iOS' \
  -derivedDataPath ../../work/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  EXCLUDED_SOURCE_FILE_NAMES='*.xcassets' \
  build
```

This sandbox command intentionally skips asset catalog compilation. It is not a replacement for final full-device or simulator QA.
