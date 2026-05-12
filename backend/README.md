# Live Pursuit Backend (MVP)

Minimal in-memory backend to support Phase 1 flows.

## Run

```bash
cd backend
node server.js
```

Default port: `3000`

## Core Endpoints

- `POST /sessions`
  - Body: `{ "navigatorUserId": "nav-1", "destinationUserId": "dest-1", "navigatorDisplayName": "Alex" }`
- `GET /sessions?destinationUserId=dest-1&state=active`
- `GET /sessions/:id`
- `POST /sessions/:id/location`
  - Body: `{ "userId": "dest-1", "latitude": 37.78, "longitude": -122.41, "timestamp": 1738700000000, "accuracy": 12, "speed": 9 }`
- `GET /sessions/:id/target-location?userId=nav-1`
- `POST /sessions/:id/reroute-check`
  - Body: `{ "userId": "nav-1", "currentEtaSeconds": 640, "candidateEtaSeconds": 470 }`
- `POST /sessions/:id/pause|resume|stop`
  - Body: `{ "userId": "dest-1" }` (stop can be destination or navigator)
- `GET /sessions/:id/logs`
- `GET /simulation-scripts`
- `POST /sessions/:id/simulation/start`
  - Body: `{ "scriptId": "normal-driving" }`
- `POST /sessions/:id/simulation/pause`
- `POST /sessions/:id/simulation/resume`
- `POST /sessions/:id/simulation/restart`
- `POST /sessions/:id/simulation/speed`
  - Body: `{ "speedMultiplier": 2 }`
- `POST /sessions/:id/simulation/replay`
  - Body: `{ "scriptId": "gps-jitter" }`
- `POST /sessions/:id/simulation/stop`

## Notes
- Data is stored in memory and resets on restart.
- Reroute thresholds, jitter filtering, and throttling defaults are configured in `backend/config.js`.
