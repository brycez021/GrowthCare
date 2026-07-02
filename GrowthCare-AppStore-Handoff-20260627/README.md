# GrowthCare

GrowthCare is a child vaccine appointment and growth tracking iOS app project.

The current repository is a clean Codex-ready workspace for rewriting an existing high-fidelity HTML prototype into a fully native SwiftUI app.

## Current Stage

This repo currently contains:
- Project guidance for AI coding agents.
- The original HTML prototype as reference material.
- Documentation for translating the prototype into native SwiftUI.
- A native SwiftUI iOS workspace under `ios/GrowthCare`.
- A retired historical multi-agent plan and an active single-agent execution plan.

Current implementation status:
- Foundation / Integration is prepared: shared routing, model boundaries, Xcode source membership, and persistence interfaces are in place.
- Home page (`reference/html/index.html`) has been rewritten as native SwiftUI.
- Vaccination schedule (`reference/html/接种时间表.html`) has been rewritten as native SwiftUI.
- Growth curve (`reference/html/成长曲线.html`) has been rewritten as native SwiftUI.
- Growth records and add-record flow (`reference/html/成长记录.html`, `reference/html/成长记录添加.html`) are native SwiftUI.
- Vaccine detail and optional vaccine add/restore flows (`reference/html/疫苗详情.html`, `reference/html/疫苗添加.html`) are native SwiftUI.
- Vaccine calendar and clinic management (`reference/html/疫苗日历.html`, `reference/html/接种单位.html`, `reference/html/添加诊所.html`) are native SwiftUI.
- Profile, reminder, child profile, and sharing flows (`reference/html/我的.html`, `reference/html/个人信息.html`, `reference/html/孩子信息.html`, `reference/html/提醒日期.html`, `reference/html/提醒时间.html`, `reference/html/添加共享成员.html`) are native SwiftUI.
- Final integrated sandbox QA has passed with the accepted build command. Remaining follow-up is full simulator/device visual verification outside the restricted sandbox.
- Persistence remains the current in-memory snapshot boundary by design; real local storage is a future decision.
- All future work is owned by the current single Codex agent; sub-agent execution is retired.

## Source Of Truth

The visual design, product behavior, and interaction details come from:

`reference/html/`

This folder contains:
- HTML pages
- CSS
- JavaScript logic
- Images and icons

Future SwiftUI work must inspect these files before implementation and compare the result against them after implementation.

## Technical Direction

- Native SwiftUI rewrite
- Minimum iOS version: iOS 16
- No production WebView wrapper
- Prototype assets should be reused in the iOS app
- Prototype `localStorage` / `sessionStorage` should become native Swift models and persistence

## Repository Layout

- `AGENTS.md`: highest-priority project instructions
- `contributing_ai.md`: AI collaboration protocol
- `docs/html-to-swiftui.md`: required rewrite workflow
- `docs/project-map.md`: map of prototype pages, scripts, and state
- `docs/solo-execution-plan.md`: active single-agent work order and verification gates
- `docs/multi-agent-plan.md`: retired historical multi-agent split
- `docs/home-translation.md`: first-page rewrite notes and verification result
- `docs/schedule-translation.md`: vaccination schedule rewrite notes
- `docs/growth-curve-translation.md`: growth curve rewrite notes
- `docs/growth-records-translation.md`: growth record list and add-record rewrite notes
- `docs/vaccine-education-optional-translation.md`: vaccine detail and optional vaccine rewrite notes
- `docs/calendar-clinic-translation.md`: vaccine calendar and clinic-management rewrite notes
- `docs/profile-reminder-sharing-translation.md`: profile, reminder, and sharing rewrite notes
- `docs/qa-parity-report.md`: final integrated sandbox QA notes and remaining visual-QA boundary
- `docs/foundation-integration-handoff.md`: shared routing, model, persistence-boundary, and verification handoff
- `reference/html/`: original HTML prototype reference
- `ios/GrowthCare/`: native SwiftUI app, iOS 16 minimum

## Important Rule

Before rewriting any page, first read its corresponding HTML, CSS, JavaScript, and image references. After rewriting, compare the SwiftUI result against the HTML prototype and fix or document any difference.
