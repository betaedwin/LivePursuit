# Live Pursuit

Live Pursuit is an iOS MVP for navigating to a moving person with explicit session-based location sharing. The iOS app uses SwiftUI, CoreLocation, Contacts, and MapKit. The backend is a lightweight in-memory Node service for sessions, destination location relay, simulation scripts, throttling, and reroute decisions.

## Structure

- `backend/`: Node backend for sessions, location updates, reroute checks, simulation, and health checks.
- `ios/LivePursuit/`: SwiftUI app source.
- `docs/two_phone_field_test.md`: Current two-phone QA checklist.
- `render.yaml`: Render web service blueprint for the backend.

## Backend

Run locally:

```bash
cd backend
npm start
```

Default local URL:

```text
http://localhost:3000
```

Useful endpoints:

```bash
curl http://localhost:3000/healthz
curl http://localhost:3000/sessions
```

The backend stores state in memory. Sessions reset whenever the process or Render service restarts.

## Render Backend

The field-test backend is configured for:

```text
https://livepursuit.onrender.com
```

Render setup:

- Root directory: `backend`
- Build command: `npm install`
- Start command: `npm start`
- Health check: `/healthz`

## iOS

Open `ios/LivePursuit.xcodeproj` in Xcode.

Primary schemes:

- `LivePursuit`: default local/simulator build.
- `LivePursuit Navigator`: field-test navigator build.
- `LivePursuit Destination`: field-test destination build.

Field-test identities:

- Navigator: `You / user-1`
- Destination: `Avery / user-2`

The field-test schemes read the backend URL and identity from build-expanded `Info.plist` values. Confirm them in the app under `Settings > Field Test`.

Build simulator variants:

```bash
xcodebuild -project ios/LivePursuit.xcodeproj \
  -scheme 'LivePursuit Navigator' \
  -configuration Debug-Navigator \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath .build/DerivedData \
  build
```

```bash
xcodebuild -project ios/LivePursuit.xcodeproj \
  -scheme 'LivePursuit Destination' \
  -configuration Debug-Destination \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath .build/DerivedData \
  build
```

Install and launch on a booted simulator:

```bash
xcrun simctl install booted .build/DerivedData/Build/Products/Debug-Navigator-iphonesimulator/LivePursuit.app
xcrun simctl launch booted com.livepursuit.app.navigator
```

## Two-Phone QA

Use two physical iPhones:

1. Install `LivePursuit Navigator` on Phone A.
2. Install `LivePursuit Destination` on Phone B.
3. Verify both point to `https://livepursuit.onrender.com` in `Settings > Field Test`.
4. On Phone B, open `Share My Location`, continue through education, and grant location permission.
5. On Phone A, open `Navigate to a Contact` and select `Avery`, or use `Phone Contacts`.
6. On Phone B, start sharing once the session appears.

Real phone contacts are field-test only: selecting any phone contact displays that contact name in the navigator UI but still maps the live destination to `user-2`.

Full checklist: `docs/two_phone_field_test.md`.

Simulator permission reset helpers:

```bash
xcrun simctl privacy booted reset location com.livepursuit.app.navigator
xcrun simctl privacy booted reset contacts com.livepursuit.app.navigator
```
