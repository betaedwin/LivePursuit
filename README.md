# Live Pursuit (Phase 1 MVP)

This repo contains a minimal Phase 1 implementation aligned to the PRD.

## Structure
- `backend/`: In-memory backend for sessions, live destination updates, and reroute evaluation.
- `ios/LivePursuit/`: SwiftUI app source files (drop into an Xcode SwiftUI project).

## Backend

```bash
cd backend
node server.js
```

## iOS

Open `ios/LivePursuit.xcodeproj` in Xcode.
Update `ios/LivePursuit/Services/AppConfig.swift` if running on a physical device.
