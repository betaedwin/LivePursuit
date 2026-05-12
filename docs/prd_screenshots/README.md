# Live Pursuit PRD Screenshots

Captured on May 9, 2026 using iPhone 17 Simulator, iOS 26.2.

Automated QA command:

```bash
xcodebuild test -project ios/LivePursuit.xcodeproj -scheme LivePursuit -configuration Debug -destination 'platform=iOS Simulator,id=350ED871-AB7A-4C50-AB21-6393B2915012' -derivedDataPath .build/DerivedData -only-testing:LivePursuitUITests/LivePursuitUITests/testPRDScreenshots
```

Screenshot index:

| File | View |
| --- | --- |
| `01-home.png` | Clean home screen |
| `02-home-simulation-enabled.png` | Home with Simulation Mode enabled |
| `03-contact-list.png` | Contact selection |
| `04-navigation-simulation-ready.png` | Navigation map with simulation controls ready |
| `05-navigation-simulation-running.png` | Navigation map with active pursuit simulation |
| `06-navigation-controls-hidden.png` | Navigation map with simulation controls minimized |
| `07-location-education.png` | First-run location education |
| `08-sharing-status.png` | Location sharing status |
| `09-settings.png` | Permissions and privacy settings |

QA result:

- `testPRDScreenshots` passed with 0 failures.
- `01-home.png` was captured separately without UI-test launch arguments to show the clean default home state.
- Backend was reachable at `http://localhost:3000`.
- Simulator location was set to `37.7749,-122.4194`.
- Location permission alert was handled by the UI test.
