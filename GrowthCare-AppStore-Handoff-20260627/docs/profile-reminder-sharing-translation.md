# Profile / Reminder / Sharing Translation Notes

Status: implemented
Last verified: 2026-06-16 sandbox build

## Sources Inspected

- `reference/html/我的.html`
- `reference/html/个人信息.html`
- `reference/html/孩子信息.html`
- `reference/html/提醒日期.html`
- `reference/html/提醒时间.html`
- `reference/html/添加共享成员.html`
- `reference/html/js/reminder-date-modal.js`
- `reference/html/js/reminder-time-modal.js`
- `reference/html/js/share-member-modal.js`
- `reference/html/css/status-bar.css`
- `reference/html/css/bottom-nav.css`
- `reference/html/css/reminder-date-modal.css`
- `reference/html/css/reminder-time-modal.css`
- `reference/html/css/modal-animations.css`
- Figma high-fidelity reference: file `e043UztTYEpBRF8hOZ3WAo`, frame `1194:8169` (`我的001`)

## Assets Reused

- `profile-avatar-mom`
- `profile-icon-edit`
- `profile-icon-baby`
- `profile-icon-plus`
- `profile-icon-bell`
- `profile-icon-caret-right`
- `profile-icon-check`
- `profile-toggle-bell`
- `profile-icon-users`
- `profile-avatar-edit`
- `vector-down`
- Existing `fanhui`, `zhensuo`, `unsplash_JfolIjRnveY`, `avatar-gou`

All new assets are registered in `ios/AssetSourceMap.md`.

## Native Mapping

- `reference/html/我的.html` maps to `ProfileView`.
- `reference/html/个人信息.html` maps to `ParentProfileView`.
- `reference/html/孩子信息.html` maps to `ChildProfileView`.
- `reference/html/提醒日期.html` maps to `ReminderDateView`.
- `reference/html/提醒时间.html` maps to `ReminderTimeView`.
- `reference/html/添加共享成员.html` maps to `AddSharedMemberView`.
- Shared member list management maps to `SharedMembersView`.

## Implemented Behavior

- Bottom `我的` tab opens a native profile page instead of `ProfileIntegrationView`.
- Parent profile edits update `ParentProfile` through `GrowthCareStore`.
- Child profile edit/add updates `children`, preserves child-specific data, and adds new child data buckets for new children.
- Reminder alarm toggle, same-day/one-day/two-day/custom date modes, custom days, and reminder time update native `ReminderSettings`.
- Shared members can be listed, added, and deleted through native state.
- The first clinic row links to the native clinic list; add row links to add clinic.
- Bottom navigation uses the shared safe-area-aware `BottomTabBar`.
- The native `我的` page follows the latest layout pass: the profile top band is `205pt`, the profile card's visible top edge is fixed at `y=100pt` from the physical screen top after subtracting the real top safe-area inset, and the card remains a `400 x 133pt` Figma-style glass card on a 440pt canvas.
- The parent profile card includes a native approximation of the Figma glass-card depth: translucent gradient fill, white stroke, soft shadow, and a blurred bottom glow.

## Intentional Differences

- The HTML reminder date/time controls use custom JavaScript wheels. Native SwiftUI uses `Stepper` and wheel `Picker`s for iOS 16 reliability and accessibility.
- The HTML `添加共享成员.html` redirects back to `我的.html` and opens a copy-link/share-WeChat modal. Native SwiftUI implements a direct add-member form because the app already has a `SharedMember` model and route.
- Real local persistence remains out of scope; edits stay inside the existing in-memory snapshot boundary.
- Fake prototype status bar, Dynamic Island, battery indicators, and home indicator are not rendered.

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
