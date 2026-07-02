# Schedule Translation Notes

## Source

- HTML: `reference/html/接种时间表.html`
- CSS inspected: inline page CSS, `css/status-bar.css`, `css/bottom-nav.css`, `css/baby-profile.css`
- JavaScript inspected: `js/load-baby-profile-css.js`, `js/system-time.js`, `js/baby-profile.js`, `js/vaccine-schedule.js`, `js/vaccine-detail.js`, `js/bottom-nav.js`

## Assets

- Reused existing native assets from the home rewrite: `profile-pill-bg`, `avatar-gou`, `unsplash_JfolIjRnveY`, `yuyue`, `yuyueweidianji`, `jiezhongshijianbiao`, `jiezhongshijianbiaoweidianji`, `chengzhangquxian`, `chengzhangquxianno`, `wode`, `wodeweidianji`.
- No new image assets were required for the schedule table itself; its pills and grid are CSS/native shapes in the prototype.
- Prototype-only phone chrome assets such as `Levels.png` were inspected but intentionally not ported.

## Structure And Behavior

- Native target: `ScheduleView`.
- The page keeps the child switcher at the top, followed by a two-column table header: `年龄` and `疫苗种类`.
- The schedule rows, labels, heights, pill colors, dashed optional-vaccine pills, and three-column placement are translated from `VaccineSchedule.SCHEDULE_ROWS`.
- The current active child's age determines the pink highlighted row using the same `BabyProfile.getScheduleHighlightAge` rule: exact birth day highlights `24小时内`; when the child has extra days beyond a month boundary, the next month row is highlighted.
- Pill done state maps each schedule pill back to the home vaccine name and dose number, then uses the native store's dose-completion logic. Done pills receive the prototype-style white horizontal line.
- The bottom tab bar uses the same selected/unselected PNG assets already migrated for the home page.

## Navigation

- The bottom schedule tab now opens the native schedule page instead of showing a placeholder.
- Growth curve and profile now open native SwiftUI pages.
- Schedule pill taps open the native vaccine detail page when the pill maps to a known vaccine name.

## Known Gaps

- Some schedule pills are still best-effort mapped to home vaccine names before opening vaccine detail.
- Visual comparison in Simulator is still required after a successful local build.
