# QA Best Practices (Live Pursuit Phase 1 & Phase 2)

## Scope
- Validate Phase 1 MVP behaviors from the PRD: session start, live destination updates, backend-driven reroutes, live ETA changes, and visible consent.
- Simulator-only for now.
- Use curl-driven backend actions to simulate destination movement and consent changes.
- Phase 2 automation validates simulation scenarios (normal, jitter, network interruption) with backend-driven reroute decisions.

## Prereqs
- Backend running on `http://localhost:3000`
- iOS app built + installed on the simulator

## Build + Run (Simulator)
```bash
cd backend
node server.js
```

```bash
xcodebuild -project ios/LivePursuit.xcodeproj -scheme LivePursuit -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath /Users/edwinbetancourt/Workspace/LivePursuit/.derivedData build
xcrun simctl install booted /Users/edwinbetancourt/Workspace/LivePursuit/.derivedData/Build/Products/Debug-iphonesimulator/LivePursuit.app
xcrun simctl launch booted com.livepursuit.app
```

## Automated Phase 2 Simulation Tests
Runs all Phase 2 simulation scenarios end-to-end (normal driving, GPS jitter, network interruption), including reroute decisions via backend logs.

```bash
bash scripts/qa/run_phase2_sim_tests.sh
```

Expected output includes PASS lines for each scenario. Network interruption allows reroute decisions (pass if simulation completes).

## Manual Smoke Checklist (Simulator)
1. Launch app.
2. Tap `Navigate to a Contact`.
3. Select a contact with sharing enabled.
4. Confirm map renders, route appears, ETA and distance show.
5. Back out to home and open `Share My Location`.
6. Confirm status UI shows consent and sharing controls.

## Phase 3 Manual Simulation Checklist (Simulator)
1. Enable `Simulation Mode` from the Developer section on the home screen.
2. Navigate to `Sim Mode` contact.
3. Select a route script and speed.
4. Tap `Start` to begin simulation.
5. Verify destination marker moves and ETA updates without restarting navigation.
6. Tap `Pause` and confirm simulation stops moving.
7. Tap `Resume` and confirm simulation continues.
8. Tap `Restart` and confirm simulation resets to the start of the script.
9. Open `Debug` panel and confirm reroute reason + thresholds are visible.

## Backend Test Script (curl)
Use these to simulate destination updates and consent changes.

### Create a Session (optional)
If the app didn’t create a session yet, create one:
```bash
curl -X POST http://localhost:3000/sessions \
  -H 'Content-Type: application/json' \
  -d '{"navigatorUserId":"user-1","destinationUserId":"user-2","navigatorDisplayName":"You","destinationDisplayName":"Avery"}'
```

### Get Session ID
```bash
curl http://localhost:3000/sessions
```

### Send Destination Location Update
```bash
curl -X POST http://localhost:3000/sessions/SESSION_ID/location \
  -H 'Content-Type: application/json' \
  -d '{"userId":"user-2","latitude":37.7890,"longitude":-122.4010,"timestamp":'"$(date +%s)000"'}'
```

### Trigger a Reroute (move >100m)
```bash
curl -X POST http://localhost:3000/sessions/SESSION_ID/location \
  -H 'Content-Type: application/json' \
  -d '{"userId":"user-2","latitude":37.7950,"longitude":-122.3910,"timestamp":'"$(date +%s)000"'}'
```

### Pause or Stop (consent control)
```bash
curl -X POST http://localhost:3000/sessions/SESSION_ID/pause \
  -H 'Content-Type: application/json' \
  -d '{"userId":"user-2"}'
```

```bash
curl -X POST http://localhost:3000/sessions/SESSION_ID/stop \
  -H 'Content-Type: application/json' \
  -d '{"userId":"user-2"}'
```

## Expected Results
- Navigation starts without manual restarts.
- ETA and distance update after reroute threshold is met.
- Destination updates flow to the navigator after each location post.
- Consent actions (pause/stop) immediately end or pause the session in the app.
- Phase 2 automated tests pass for all three simulation scenarios.

## Common Issues
- Simulator may refuse `simctl` actions without proper permissions.
- If the backend is down, navigator shows fallback status and does not crash.
- If location permission is denied, sharing UI shows Settings guidance.
