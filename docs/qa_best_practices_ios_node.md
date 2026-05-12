# QA Best Practices (Node.js Backend + Native iOS App)

## Scope
- MVP validation for iOS simulator flows + backend API correctness.
- Fast feedback: 1–3 critical E2E flows, backed by unit + integration tests.

## Core Principles
- Validate on iOS Simulator only for MVP QA.
- Prefer stable accessibility identifiers over text-only matching.
- Keep E2E flows short and critical-path only.
- Separate backend tests from UI tests to reduce flakiness.

## Smoke Checklist (Automated, iOS Simulator)
- Launch app → home screen renders with key primary content.
- Tap primary CTA → expected next screen loads.
- Back navigation returns to previous screen and preserves state.

Notes:
- There is no external link in the current iOS UI. Remove external-link checks until one exists.

## Automated Tests

### Backend (Node.js) Smoke
Current repo state:
- No `npm test` script exists.
- There is a deterministic smoke script that exercises core session + simulation flows.

Run (requires backend running on `localhost:3000`):
```bash
# Terminal 1
cd backend
npm install
npm start

# Terminal 2 (repo root)
./scripts/qa/run_phase2_sim_tests.sh
```
What we cover:
- Session creation + logs.
- Simulation start + completion.
- Reroute checks/logging behavior across scenarios.

### Backend Integration (Optional, future)
There is no integration test runner configured yet. If you want this:
- Add a `test:integration` script in `backend/package.json`.
- Use a runner like `node:test` or `vitest` and hit `server.js` endpoints.

### iOS UI Tests (Xcode / xcodebuild)
Prereqs:
- App builds for simulator (Debug).
- UI test target configured with XCUITest (not present yet).

Build + Test (example):
```bash
xcodebuild \
  -project ios/LivePursuit.xcodeproj \
  -scheme LivePursuit \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  test
```
What we cover:
- Launch app.
- Primary CTA navigates to key screen.
- Back navigation preserves state.

## Stable Selectors (Accessibility Identifiers)
- There are currently no `accessibilityIdentifier` values in the iOS codebase.
- Add identifiers on primary buttons and headers to keep UI tests stable.
- Minimal identifiers to add:
  - `home-title` (navigation title on the home screen)
  - `primary-cta` (home screen CTA: "Navigate to a Contact")
  - `contact-list-title` (Choose a Contact screen)
  - `navigator-title` (Navigate to {Contact} screen)

## Common QA Pitfalls
- Missing accessibility identifiers → fragile tests.
- Simulator not booted or wrong device target.
- UI tests asserting localized text instead of identifiers.
- Backend tests sharing state between runs.

## Suggested Test Inventory (MVP)
- Backend unit tests: 10–20 focused tests on core logic.
- Backend integration tests: 3–5 tests on critical endpoints.
- iOS UI tests: 2–3 critical flows only.
