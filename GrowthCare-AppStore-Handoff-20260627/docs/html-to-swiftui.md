# HTML To SwiftUI Rewrite Guide

This document expands the required process in `AGENTS.md`. It is meant to be followed page by page.

## Goal

Rewrite the HTML prototype as a native SwiftUI iOS app while preserving page appearance, logic, and interaction details.

The HTML prototype is not production code, but it is the best available product specification.

## Required Page Rewrite Checklist

For each page:

1. Identify the page.
   - Example: `reference/html/index.html`.
   - Record the target SwiftUI screen name.

2. Read source files.
   - Read the HTML file.
   - Read linked CSS files.
   - Read inline CSS.
   - Read linked JS files.
   - Read inline JS.
   - Identify image/icon references.

3. Extract behavior.
   - Page layout.
   - Navigation targets.
   - Buttons and controls.
   - Modal/sheet flows.
   - Form fields.
   - Gestures.
   - Animations.
   - State reads/writes.
   - Date, age, and sorting calculations.

4. Map to SwiftUI.
   - Define the SwiftUI view hierarchy.
   - Define owned state and injected state.
   - Define navigation route(s).
   - Define sheet/full-screen/modal state.
   - Define models needed by the screen.
   - Define assets to import into the iOS project.
   - Exclude HTML-only phone chrome from the SwiftUI hierarchy.

5. Implement natively.
   - Use SwiftUI views and modifiers.
   - Use native gestures and scroll views.
   - Use iOS 16-compatible state management.
   - Do not use WebView as the screen implementation.
   - Do not draw fake status bars, time labels, Wi-Fi/cellular/battery indicators, Dynamic Island/notch shapes, or home indicators. Native iOS owns these areas; use safe-area-aware layout instead.

6. Verify.
   - Build the app.
   - Run the target screen.
   - Exercise interactions.
   - Compare against the HTML prototype.

7. Report parity.
   - Source files inspected.
   - Assets reused.
   - What matches.
   - What differs.
   - Any intentional deviations.

## Asset Migration Rules

Prototype assets live in `reference/html/images/`.

When a SwiftUI page needs an asset:
- Copy the original file into the iOS asset catalog or resource folder.
- Keep a source mapping from Swift asset name to original prototype filename.
- Prefer the exact PNG/SVG from the prototype.
- Do not replace prototype icons with SF Symbols unless the user explicitly approves.
- For SVG conversion, document the conversion and preserve visual parity.

Suggested mapping document once the iOS project exists:

`ios/AssetSourceMap.md`

Each entry should include:
- Swift asset name
- Original file path
- Where it is used
- Whether it was copied directly or converted

## Web State To Native State

The prototype uses browser storage only for demo state. Convert it into native app state.

Important prototype state areas:
- `activeChildId`
- `babyProfileChildData`
- `addedVaccines`
- `hiddenVaccines`
- `bookedDoses`
- `completedDoses`
- `growthRecords`
- `userProfile`
- `childrenList`
- `sharedMembers`
- `reminderMode`
- `customReminderDays`
- `reminderTime`
- `extraClinics`

Native models should be designed around product concepts, not around these storage keys.

## iOS 16 SwiftUI Constraints

Use:
- `NavigationStack`
- `ObservableObject`
- `@StateObject`
- `@ObservedObject`
- `@State`
- `@Binding`
- `.sheet(item:)` where possible for selected model flows

Avoid:
- iOS 17-only Observation as a required core dependency
- WebView for page rendering
- Multiple unrelated boolean flags for mutually exclusive modal states
- Huge SwiftUI views that mix layout, business logic, persistence, and routing

## Comparison Standard

A page is not done until it has been compared against the prototype for:
- Layout
- Native safe-area behavior, excluding prototype-only phone chrome
- Color
- Typography
- Spacing
- Assets
- Text
- Navigation
- Modal sequence
- State transitions
- Gesture behavior
- Date and age formatting
- Empty, booked, done, hidden, and completed states

If exact parity is not practical in the current task, document the gap and leave a clear follow-up.
