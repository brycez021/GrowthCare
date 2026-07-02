# Home Page Translation Notes

## Source

Target SwiftUI screen:
- `ios/GrowthCare/GrowthCare/HomeView.swift`
- `ios/GrowthCare/GrowthCare/HomeOverlays.swift`

Prototype files inspected:
- `reference/html/index.html`
- `reference/html/css/status-bar.css`
- `reference/html/css/bottom-nav.css`
- `reference/html/css/baby-profile.css`
- `reference/html/js/system-time.js`
- `reference/html/js/baby-profile.js`
- `reference/html/js/vaccine-schedule.js`
- `reference/html/js/bottom-nav.js`
- `reference/html/js/vaccine-booking-time.js`
- `reference/html/js/vaccine-booking-clinic.js`
- `reference/html/js/vaccine-booking-clinic-select.js`
- `reference/html/js/vaccine-booking-confirm.js`
- `reference/html/js/vaccine-edit-plan.js`
- `reference/html/js/vaccine-hide-confirm.js`

Figma high-fidelity reference:
- File `e043UztTYEpBRF8hOZ3WAo`, node `149:1069` (`首页预约001`) for the home page with an active appointment plan.
- Subnode `181:787` for the next-appointment card.
- Subnode `296:4507` for the vaccine timeline row component.

## Implemented

- Native SwiftUI app scaffold under `ios/GrowthCare`.
- Home header with native safe-area handling, child switcher, and calendar button. Prototype-only phone chrome is intentionally not translated.
- Bottom navigation with original selected/unselected tab icons.
- Native vaccine list using prototype vaccine seed data, dose states, due highlight, pinned vaccine rules, hidden vaccine state, and schedule-based done calculation.
- Dose balls using original image assets.
- Swipe-to-hide card interaction with hide confirmation.
- Next appointment card when a booked future appointment exists.
- When a next appointment exists, the home header switches to the Figma `205pt` appointment-state top band. The appointment card uses the Figma 400 x 166 layout, starts at `y=149pt` from the physical screen top after subtracting the real top safe-area inset, and the first vaccine card starts `45pt` below the appointment card after accounting for the timeline row's internal padding.
- The next-appointment card includes a native approximation of the Figma glass card depth: translucent gradient fill, white stroke, soft shadow, and a blurred bottom glow.
- Native booking flow inside the home page:
  - Date selection modal
  - Clinic detail modal
  - Clinic select modal
  - Confirmation modal
- Native edit-plan modal with delete, complete, edit time, and edit clinic actions.

## Assets Imported

Assets were copied from `reference/html/images/` into `ios/GrowthCare/GrowthCare/Assets.xcassets` with matching asset names:

- `rili.png`
- `next-card-inner.svg`
- `profile-pill-bg.svg`
- `avatar-gou.png`
- `unsplash_JfolIjRnveY.svg`
- `yuyue.png`
- `yuyueweidianji.png`
- `jiezhongshijianbiao.png`
- `jiezhongshijianbiaoweidianji.png`
- `chengzhangquxian.png`
- `chengzhangquxianno.png`
- `wode.png`
- `wodeweidianji.png`
- `zhentou.png`
- `kepuwenhao.png`
- `yizhongqiu.png`
- `yuyueqiu.png`
- `jiahao.png`
- `xuxianqiuyi.png`
- `xuxianqiuer.png`
- `xuxianqiusan.png`
- `xuxianqiusi.png`
- `xuxianqiuwu.png`
- `jiantouyihao.svg`
- `jiantouerhao.svg`
- `jiezhongmenzhen.png`
- `xiangxidizhi.png`
- `yingyeshijian.png`

`profile-pill-bg.svg` keeps the original source in `reference/html/images/`. The iOS asset copy replaces the SVG CSS variable fill with the resolved source color `#F47C7E`, because Xcode asset rendering does not reliably honor `var(--fill-0, #F47C7E)`.

## Intentional Gaps

- Schedule, growth curve, growth records, vaccine detail, optional vaccine, vaccine calendar, clinic management, and profile/reminder/sharing flows are now native SwiftUI pages.
- The booking remark editor remains a follow-up subflow inside the existing home overlay.
- The prototype has a completed-vaccine pull/reveal interaction. The SwiftUI home currently follows the default collapsed behavior by hiding completed cards from the active list.

## Verification

- Built and launched successfully with XcodeBuildMCP on the iOS Simulator.
- Opened `reference/html/index.html` locally and captured the first viewport for side-by-side visual comparison.
- Captured the SwiftUI simulator first viewport after launch. The current initial state matches the HTML prototype state for June 11, 2026 after excluding HTML-only phone chrome: no future appointment card, visible active vaccine list starts at Hepatitis B, and the same app header, child switcher, timeline cards, dose images, help icons, and bottom tab assets are present.
- Rebuilt after removing prototype-only phone chrome. The SwiftUI page now uses the native iOS status bar and safe area instead of drawing the prototype's fake time, Wi-Fi/cellular/battery strip, Dynamic Island/notch, or home indicator.
- Automatic tap verification was not completed because the local XcodeBuildMCP accessibility snapshot failed to load SimulatorKit from `/Users/zhangsiyuan/Downloads/Xcode-beta.app/Contents/Developer/Library/PrivateFrameworks/SimulatorKit.framework`. Screenshot capture, build, install, and launch all succeeded.
- Later single-agent integration replaced the previously pending calendar, clinic, growth record, and profile routes with native SwiftUI pages. The accepted sandbox build passed after these integrations; full simulator/device visual QA remains outside the restricted sandbox.
