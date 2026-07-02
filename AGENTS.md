# GrowthCare — Agent Guide

> This file is the highest-priority project guide for Codex and other coding agents working in this repository.
> If this file conflicts with any other project document, follow `AGENTS.md`.

## 1. Product Identity

**Project name:** GrowthCare

GrowthCare is an iOS app for child vaccine scheduling and growth tracking. The current source of truth is a high-fidelity HTML prototype under `reference/html/`.

Core product areas:
- Vaccine appointment home page
- Vaccination schedule
- Vaccine calendar
- Vaccine detail and precautions
- Growth curve and growth records
- Child profile switching and editing
- Parent profile
- Reminder settings
- Clinic management
- Shared family member flow

The app should feel like the HTML prototype: soft pediatric visual language, rounded cards, illustrated medical assets, child profile context, and bottom-tab navigation.

## 2. Technical Direction

- Rewrite the product as a fully native SwiftUI iOS app.
- Minimum supported version is **iOS 16**.
- Do not use `WKWebView` to host the HTML pages as the production implementation.
- Do not continue from `SwiftConvertedApp`; it was an interim WebView wrapper and is intentionally excluded from this repository.
- HTML, CSS, JavaScript, and images in `reference/html/` are reference material for visual, logic, and interaction parity.
- Do not recreate HTML-only device chrome in SwiftUI. The prototype may draw a fake status bar, time, Wi-Fi/cellular/battery indicators, Dynamic Island/notch, or home indicator to simulate a phone frame; native iOS provides these system areas. SwiftUI pages must respect safe areas and use the real system chrome instead of drawing those elements.

For iOS 16-compatible SwiftUI:
- Use `NavigationStack` for navigation.
- Use `ObservableObject`, `@StateObject`, `@ObservedObject`, `@State`, and `@Binding` for state.
- Do not depend on iOS 17+ Observation APIs for core app architecture.
- Prefer native SwiftUI controls and composition, but match the prototype's final behavior and look.

## 3. Non-Negotiable HTML-To-SwiftUI Workflow

Every page or component rewrite must follow this process. Skipping these steps is a project violation.

### 3.1 Find The Exact HTML Source

Before writing SwiftUI, identify the exact prototype source:
- The HTML page, for example `reference/html/index.html`
- All linked CSS files
- All linked JavaScript files
- Inline `<style>` and inline `<script>` blocks in the HTML
- All referenced image/icon files under `reference/html/images/`

Do not implement from memory, screenshots, or guessed structure when the HTML source exists.

### 3.2 Read The Corresponding Original Files First

Before editing Swift files, read the relevant original files:
- Page markup and inline styles from the HTML file
- Shared styles such as `css/status-bar.css`, `css/bottom-nav.css`, modal CSS, and feature CSS. Treat `status-bar.css` and similar phone-frame files as prototype context only; do not translate fake status bars, Dynamic Island/notch, Wi-Fi/cellular/battery indicators, or home indicators into SwiftUI.
- Feature logic such as `js/baby-profile.js`, `js/vaccine-schedule.js`, booking modal scripts, reminder scripts, and growth scripts
- Asset names and dimensions where images are used

For shared UI, read the shared source once and reference it in the implementation notes. Examples:
- Bottom navigation: `reference/html/js/bottom-nav.js`
- Child switching and growth data: `reference/html/js/baby-profile.js`
- Vaccine schedule and dose state: `reference/html/js/vaccine-schedule.js`
- System time formatting: `reference/html/js/system-time.js`

### 3.3 Extract A Translation Spec Before Coding

For each rewritten screen, write or update a short translation note in the task output or relevant docs. It must include:
- Source HTML path
- CSS files inspected
- JavaScript files inspected
- Images/icons required
- Page structure and visual hierarchy
- Text content and button labels
- Navigation destinations
- Modal/sheet flows
- State changes and derived states
- Gestures, animations, and scroll behavior
- Prototype storage keys referenced, if any

Do not silently simplify interactions. If a detail cannot be implemented exactly in the current step, record the gap and why.

### 3.4 Reuse Prototype Images And Icons

All icons and images must come from `reference/html/images/` first.

Rules:
- Do not redraw, restyle, or replace an existing icon/image unless the user approves.
- When moving assets into the iOS app, copy them into the Xcode asset catalog or resource folder with a traceable source-name mapping.
- Keep the original filename in the asset name or in an asset mapping document.
- If a PNG can be used directly, use it directly.
- If an SVG cannot be used directly in the target iOS setup, explain the conversion and convert it to a suitable asset format; do not silently substitute another asset.
- If an icon is represented inline as SVG in HTML/JS, recreate it as a native SwiftUI shape only when there is no file asset to reuse, and document the source.

### 3.5 Translate Web State Into Native State

The prototype uses `localStorage` and `sessionStorage` as demo storage. SwiftUI must not copy that storage model directly.

Translate prototype state into native models:
- Children and active child
- Added/hidden vaccines
- Vaccine dose status: future, booked, done
- Appointment date, clinic, remark
- Completed doses
- Growth records
- Reminder mode, reminder date offset, reminder time, alarm enabled
- User profile and shared members

Use local native persistence only after the model boundaries are clear. The prototype's storage keys are reference evidence, not the iOS architecture.

### 3.6 Build Native SwiftUI, Not Web Equivalents

Implement native views and components:
- Screens should be SwiftUI `View`s.
- Modal flows should use SwiftUI sheets, full-screen covers, overlays, or custom bottom sheets as appropriate.
- Gesture behavior should use native gestures and scroll coordination.
- Calendars, wheels, cards, and tabs should be native SwiftUI components unless a specific asset must be rendered.
- Device/system UI must remain native. Do not draw fake status bars, time labels, Wi-Fi/cellular/battery indicators, Dynamic Island/notch shapes, or home indicators from the HTML prototype.

Do not embed HTML, CSS, or JS in the app as the primary UI.

### 3.7 Compare After Implementation

After a SwiftUI page is implemented, compare it against the HTML prototype before calling the task complete.

The comparison must check:
- Layout and safe-area behavior
- Colors and gradients
- Typography scale and weight
- Spacing and card shape
- Image/icon usage
- Text content
- Bottom navigation state
- Child profile switcher state
- Modal/sheet sequence
- Button enabled/disabled states
- Gestures such as swipe, drag, scroll reveal, and wheel selection
- Date formatting and age calculations
- Empty, booked, done, hidden, and completed states

Any difference must be fixed or explicitly documented as a known intentional difference.

## 4. Prototype Reference Structure

Primary reference directory:
- `reference/html/*.html`
- `reference/html/css/`
- `reference/html/js/`
- `reference/html/images/`

Important entry points:
- `reference/html/index.html`: appointment home page and main booking/edit/hide modal stack
- `reference/html/接种时间表.html`: vaccine schedule table and current age highlighting
- `reference/html/疫苗日历.html`: monthly appointment calendar
- `reference/html/成长曲线.html`: growth chart
- `reference/html/成长记录.html`: growth timeline and swipe delete
- `reference/html/成长记录添加.html`: add growth record wheel/dial flow
- `reference/html/我的.html`: profile, reminders, shared members
- `reference/html/疫苗详情.html`: vaccine education detail shell

See `docs/project-map.md` for the current prototype map.

## 5. Product Behavior To Preserve

Do not break these behaviors:
- Bottom tabs are: `预约`, `接种时间表`, `成长曲线`, `我的`.
- The appointment home page is the main entry.
- Child switching affects vaccine, calendar, and growth data.
- `卡介苗` and `乙肝疫苗` are pinned and cannot be hidden.
- Future dose balls open the booking flow.
- Booking flow is date selection -> clinic selection -> confirmation.
- Existing appointment can be modified, deleted, or completed.
- Hidden vaccine confirmation requires explicit confirmation.
- Vaccine detail has intro and precautions tabs.
- Growth record list supports swipe-to-delete.
- Growth record add flow captures date, height, and weight.
- Reminder settings support same-day, one-day, two-days, custom days, and reminder time.
- Calendar shows appointments for both children with child-specific colors.

## 6. Development Rules

- Keep changes surgical and tied to the current task.
- Do not add speculative features.
- Do not refactor unrelated prototype docs or assets.
- Do not delete prototype reference files unless the user explicitly asks.
- Before changing architecture or persistence, explain the tradeoff and get confirmation.
- If a behavior is unclear after reading the prototype source, ask the user before guessing.

## 7. Required Agent Output For Implementation Tasks

For any future SwiftUI implementation task, the final response must include:
- Goal
- Source files inspected
- Assets reused
- Swift files changed
- Verification performed
- HTML parity notes
- Known gaps, if any

If verification cannot run, mark it as `NOT VERIFIED` and explain why.

## 8. Reading Order

At the start of each coding session, read:
1. `AGENTS.md`
2. `contributing_ai.md`
3. `README.md`
4. `docs/html-to-swiftui.md`
5. `docs/project-map.md`
6. `docs/solo-execution-plan.md`
7. `docs/multi-agent-plan.md` only as retired historical context when needed

When implementing a page, then read that page's exact HTML/CSS/JS/assets before writing SwiftUI.

## 9. Single-Agent Execution Rules

The multi-agent plan is retired. Do not create, resume, or delegate to sub-agents unless the user explicitly reinstates multi-agent mode.

The current Codex agent owns:
- Feature implementation
- Shared models, routing, and Xcode project metadata
- Asset mapping
- Translation and handoff documentation
- Build verification and QA notes

Work in this order unless the user changes priority:
1. Keep guidance files in single-agent mode.
2. Fix bottom-tab safe-area behavior across all pages that use the shared tab bar.
3. Implement Growth Records: list, add record, delete record, and growth-curve synchronization.
4. Implement Profile / Reminder / Sharing: profile tab, parent profile, child profile, reminder date/time, and shared members.
5. Run final integrated QA and update status docs.

Single-agent discipline:
- Read exact HTML/CSS/JS/assets before each page rewrite.
- Keep shared model and route changes centralized; do not duplicate types or helper logic.
- Update `ios/AssetSourceMap.md` whenever prototype assets are copied into the app.
- Create or update a page-specific translation document under `docs/` for every implemented page group.
- Run the accepted build command after each implementation stage when possible.
- Record known differences instead of silently simplifying behavior.
