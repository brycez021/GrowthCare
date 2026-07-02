# Growth Curve Translation Notes

## Source

- HTML: `reference/html/成长曲线.html`
- CSS inspected: inline page CSS, `css/status-bar.css`, `css/bottom-nav.css`, `css/baby-profile.css`
- JavaScript inspected: `js/load-baby-profile-css.js`, `js/system-time.js`, `js/baby-profile.js`, `js/growth-curve.js`, `js/bottom-nav.js`
- Figma parity nodes:
  - Curve state: file `1enm3HFjsV7KMuqwHLsz1J`, node `5:850`
  - Records state: file `1enm3HFjsV7KMuqwHLsz1J`, node `5:964`
  - Add-record overlay: file `1enm3HFjsV7KMuqwHLsz1J`, node `5:1069`
- The user-provided `34:1113` link resolves to `我的001`, so it is not used as a growth-page layout source.

## Assets

- `growth-shade-height`: copied from `reference/html/images/growth-shade-height.svg`
- `growth-shade-weight`: copied from `reference/html/images/growth-shade-weight.svg`
- Existing reused assets: child avatars, active child pill background, and bottom navigation icons.
- Prototype-only phone chrome such as the fake status bar, Dynamic Island, signal/battery strip, and home indicator is intentionally excluded.

## Structure And Behavior

- Native target: `GrowthCurveView`.
- The page keeps the pink header, child switcher, `曲线 / 记录` segmented control, WHO label, white chart card, height/weight legend, and bottom navigation.
- The chart keeps the prototype's 324 x 444 plot coordinate system, grid positions, axis labels, and color mapping.
- Growth data points use the same `growth-curve.js` mapping:
  - Months clamp from 0 to 12.
  - Weight maps 2-18 kg to y 415-35.
  - Height maps 30-100 cm to y 364-28.
  - Record x positions use age in months plus `days / 30.4375`.
- Native state adds `GrowthRecord` and child-specific `growthRecords`. New users start with one placeholder child (`孩子1`) whose birthday defaults to the current day, and growth records start empty until the user adds them.

## Navigation

- The bottom `成长曲线` tab now opens the native curve page.
- The `曲线 / 记录` segmented control switches content inside `GrowthCurveView`; it no longer pushes or pops a growth-record route, so the secondary tab switch does not use a horizontal page transition.
- Both curve and records states now use the requested `205pt` top band. The `曲线 / 记录` segmented control switches in place, uses equal-height segment buttons, and sits `20pt` above the bottom edge of the header band.
- The standalone `GrowthRecordsView` remains as a compatibility route wrapper, but the growth-page secondary tab now embeds the shared record timeline directly.
- The add-record flow still uses the existing route. Saving a new growth record pops the overlay route and returns to the embedded `记录` tab because the parent page state is preserved.
- The `我的` bottom tab opens the native profile/reminder/sharing page.

## Known Gaps

- Simulator visual comparison still depends on the local Xcode/CoreSimulator environment being available.
- The growth header now follows the requested native `205pt` height for both curve and records states, while still excluding Figma-only phone chrome.
