# GrowthCare AI Contributing Guide

This file defines how Codex should work in this repository. If it conflicts with `AGENTS.md`, follow `AGENTS.md`.

## Default Protocol

For every coding task, provide:
- **Goal:** what the task changes.
- **DoD:** observable success criteria.
- **Plan:** small reversible steps.
- **Files to add/change:** exact paths.
- **Verification:** commands or manual checks.
- **Final output:** concise summary with changed files.
- **Self-check:** `PASS` or `NOT VERIFIED`.

## Single-Agent Protocol

Sub-agent work is retired for this project. Do not create, resume, or delegate to sub-agents unless the user explicitly reinstates multi-agent mode.

Current work should use `docs/solo-execution-plan.md` as the active task order. `docs/multi-agent-plan.md` is retained only as a historical record of the earlier split.

The current Codex agent is responsible for:
- Feature implementation.
- Shared model, route, project, and asset integration.
- Page-specific translation docs.
- Build verification.
- Final QA notes and status updates.

## Scope Discipline

- One task at a time.
- No unrelated cleanup.
- No speculative architecture.
- Match existing project guidance even when another style is personally preferred.
- Ask before changing product semantics.

## HTML-To-SwiftUI Work Rules

Before implementing any SwiftUI screen:
- Read the corresponding HTML file under `reference/html/`.
- Read linked and relevant CSS/JS.
- List images/icons needed from `reference/html/images/`.
- Extract page behavior before coding.

During implementation:
- Use native SwiftUI for UI and interaction.
- Keep iOS 16 compatibility.
- Reuse prototype image assets.
- Translate Web storage into native models, not into Web storage wrappers.

After implementation:
- Run an iOS build when an Xcode project exists.
- Compare the SwiftUI result against the HTML prototype.
- Report parity gaps explicitly.

## Verification Gates

Documentation-only changes:
- Check file presence and content.
- Run `git status --short`.

SwiftUI app changes:
- Prefer XcodeBuildMCP simulator build tools when available.
- Otherwise use `xcodebuild` with the project scheme.
- If UI changed, run the app in Simulator and compare with the prototype.

If a command cannot run, mark it as `NOT VERIFIED` and explain the missing condition.

## Forbidden Shortcuts

- Do not ship a WebView wrapper as the native rewrite.
- Do not replace prototype assets with unrelated SF Symbols or new drawings without approval.
- Do not skip source inspection and implement from memory.
- Do not silently ignore modal flows, gestures, or state transitions.
- Do not delete or rewrite reference HTML files.
