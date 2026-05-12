# Two Phone Field Test

## Backend Setup

Deploy `backend/` to Render as a Node web service.

- Build command: `npm install`
- Start command: `npm start`
- Health check: `https://livepursuit.onrender.com/healthz`

The `Debug-Navigator` and `Debug-Destination` build configurations currently point at `https://livepursuit.onrender.com`.

Backend state is in memory. Sessions reset whenever the Render service restarts.

## Phone Builds

- Phone A: install the `LivePursuit Navigator` scheme. Expected identity: `You / user-1`.
- Phone B: install the `LivePursuit Destination` scheme. Expected identity: `Avery / user-2`.

Open `Settings` in the app and verify the `Field Test` section shows the expected identity and backend URL before testing.

## Backend Inspection

```bash
curl https://livepursuit.onrender.com/healthz
curl https://livepursuit.onrender.com/sessions
curl https://livepursuit.onrender.com/sessions/SESSION_ID/logs
```

Create a backend smoke session:

```bash
curl -X POST https://livepursuit.onrender.com/sessions \
  -H 'Content-Type: application/json' \
  -d '{"navigatorUserId":"user-1","destinationUserId":"user-2","navigatorDisplayName":"You","destinationDisplayName":"Avery"}'
```

## Manual Field Checklist

1. On Phone B, open `Share My Location`, tap `Continue` on the education screen, and grant location permission.
2. On Phone A, open `Navigate to a Contact` and select `Avery`, or grant Contacts access and select a real contact from `Phone Contacts`.
3. On Phone B, start sharing when the active session appears.
4. Confirm Phone A renders Avery's destination marker and route.
5. Stationary test: keep both phones still and confirm the first location appears.
6. Walking test: move Phone B at least 100 meters and confirm marker movement or route update.
7. Stale test: background Phone B for more than 30 seconds and confirm Phone A shows delayed location.
8. Consent test: pause and stop sharing from Phone B and confirm Phone A updates session state.
9. Network test: switch one phone between Wi-Fi and cellular and confirm the app does not crash.

## Pass Criteria

- Navigator session uses `navigatorUserId=user-1`.
- Destination uploads use `userId=user-2`.
- Any selected phone contact maps to `destinationUserId=user-2` while showing the selected contact name in the navigator UI.
- `GET /sessions?destinationUserId=user-2` returns the active session on the destination phone.
- `GET /sessions/:id/target-location?userId=user-1` returns the latest destination location on the navigator phone.
