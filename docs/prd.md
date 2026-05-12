# Product Requirements Document (PRD)
Project: Live Destination Navigation (LDN)
Phase: Phase 1 — iOS MVP (1:1 Navigation)
Status: Ready for Execution
Source of Truth: Project Constitution (Locked)

---

Phase QA Tracking: `docs/phase_status.md`

---

## Seed Summary (Phase 1)

Deliver a minimal iOS MVP that enables one navigator to route to one moving destination with explicit bilateral consent. The backend owns session state, relays destination location updates, and decides when reroutes occur based on fixed thresholds. The iOS client renders native MapKit navigation UI, applies backend reroute signals, and keeps ETA updated without manual restarts. Scope excludes group flows, chat, background tracking without an active session, and any non-iOS clients.

---

## 1. Objective

Build an iOS application that allows one user (“Navigator”) to navigate to another user (“Destination”) whose location is actively changing, with automatic rerouting and live ETA updates, requiring no manual interaction after navigation begins, and with explicit bilateral consent.

---

## 2. Problem Statement

Navigation systems assume destinations are static coordinates. When navigating to a person:

- Routes are calculated to stale locations
- ETAs become inaccurate as the destination moves
- Users must manually restart navigation
- Coordination breaks during motion

LDN treats a person as a live destination, continuously updating routing and ETA as the destination moves.

---

## 3. Target User

### Included (MVP)
- iOS users
- Users with active location sharing enabled with a trusted contact
- Users coordinating real-time meetups while both parties are in motion

### Excluded (MVP)
- Anonymous users
- Non-shared contacts
- Group navigation
- Passive location viewers
- Social discovery users

---

## 4. User Roles

### Navigator
- Initiates navigation to a shared contact
- Receives turn-by-turn directions
- Sees live ETA updates

### Destination
- Shares live location
- Sees when someone is actively navigating to them
- Can pause or stop navigation at any time

---

## 5. Core User Flows

### 5.1 Navigator Flow
1. User opens app
2. User selects a contact with active location sharing
3. User taps “Navigate to [Contact]”
4. Navigation session begins
5. Route and ETA are displayed
6. As destination moves:
   - Route updates automatically
   - ETA updates automatically
7. Session ends when:
   - Navigator arrives
   - Navigator stops navigation
   - Destination revokes consent
   - Session expires

### 5.2 Destination Flow
1. Destination user sees status:
   - “[Navigator Name] is navigating to you”
2. Destination can:
   - Pause navigation
   - Stop navigation entirely
3. Revoking location sharing immediately ends the session

---

## 6. Functional Requirements

### 6.1 Navigation
- Use native iOS turn-by-turn navigation (MapKit)
- Initial route calculated to destination’s current location
- Route updates automatically when reroute conditions are met
- Navigation must not require restarting during reroutes

### 6.2 Live Destination Updates
- Destination location updates streamed to backend
- Backend evaluates reroute conditions
- Client reroutes only when backend signals

### 6.3 Rerouting Logic (MVP Defaults)
Reroute occurs only when all conditions are met:
- Destination moved ≥ 100 meters
- ETA delta ≥ 2 minutes
- At least 30 seconds since last reroute
- Hard cap: 2 reroutes per minute

(Values must exist at launch and be configurable.)

### 6.4 ETA Updates
- ETA updates automatically after reroutes
- No user interaction required

---

## 7. Consent & Trust Requirements

- Location sharing must already be enabled
- Destination must see active navigation sessions
- Destination can pause or stop navigation instantly
- Revoking location sharing ends session immediately
- No background tracking outside an active session
- Sessions auto-expire after inactivity

---

## 8. Non-Functional Requirements

### Performance
- ≤5 seconds perceived lag for updates
- Silent, smooth rerouting

### Battery
- Acceptable battery usage for 30–60 minute sessions
- No continuous rerouting
- Throttled location updates

### Reliability
- Graceful recovery from brief network interruptions
- Backend failure falls back to last known route (no crash)

---

## 9. Platform & Architecture

### Client
- iOS only
- Swift
- MapKit
- Responsibilities:
  - GPS collection
  - Map rendering
  - Turn-by-turn UI
  - Applying backend reroute signals

### Backend
- Cross-platform-ready
- Responsibilities:
  - Navigation session lifecycle
  - Destination location relay
  - Reroute threshold evaluation
  - Consent enforcement

Client does not independently decide reroutes.

---

## 10. Data Model (Conceptual)

### Navigation Session
- session_id
- navigator_user_id
- destination_user_id
- session_state (active | paused | ended)
- last_reroute_timestamp
- consent_state
- created_at
- expires_at

### Location Update
- user_id
- latitude
- longitude
- timestamp

---

## 11. Explicit Non-Goals (Phase 1)

- Group navigation
- Messaging or chat
- Predictive meeting points
- Offline navigation
- Background navigation without active session
- Android client
- Monetization
- Non-essential analytics

---

## 12. Metrics & Success Criteria

### MVP Success (ALL must be true)
- Navigation starts to a shared contact
- Route updates automatically as destination moves
- ETA updates automatically
- Navigation does not require restart
- Consent visible on both sides
- Battery usage acceptable for 30–60 minutes

### Metrics Tracked
- Session start → completion rate
- Reroutes per session
- Battery drain per 30 minutes
- Manual aborts

---

## 13. Risks & Mitigations

- Battery drain → throttling + reroute caps
- Route thrashing → explicit thresholds
- Privacy concerns → visible consent + session-based tracking
- Platform limits → backend-owned logic

---

## 14. Open Questions (Execution-Time Only)

- Backend stack choice
- Location update frequency tuning
- Session expiration duration

These do not block Phase 1.

---

## 15. Phase Exit Criteria

Phase 1 is complete when:
- All MVP success criteria pass real-world testing
- No critical battery or privacy issues remain
- Navigation is stable for 30–60 minute sessions

---

End of Phase 1 PRD

---

Phase: Phase 2 — Stability, Battery Optimization & Simulated Navigation
Status: Ready for Execution
Source of Truth: Project Constitution (Locked)

---

## 1. Objective

Harden the Phase 1 MVP by improving reliability, battery efficiency, and reroute quality, and **prove correctness end-to-end** through a deterministic, repeatable **simulated navigation to a contact**.

Phase 2 validates that Live Destination Navigation works under real-world conditions before expanding scope.

---

## 2. Phase 2 Success Definition

Phase 2 is successful only if:

- A simulated destination can be navigated to end-to-end
- Reroutes occur based on backend thresholds during simulation
- ETA updates automatically without restarting navigation
- Sessions remain stable through jitter, network loss, and backgrounding
- Battery impact is reduced versus Phase 1
- All reroute and session decisions are observable via logs

---

## 3. In Scope

### 3.1 Simulated Navigation (Mandatory)

A deterministic simulation system that mimics a real destination contact.

#### Requirements
- A **Simulated Destination Contact** selectable by the Navigator
- A **route script** defining destination movement over time
- Backend ingests simulated location updates as if from a real device
- iOS client navigates normally using MapKit
- Simulation can be started, stopped, and replayed

#### Simulation Scenarios (Minimum)
1. **Normal Driving**
   - Continuous movement along a route
   - At least one meaningful reroute triggered
2. **GPS Jitter / Accuracy Swings**
   - Small oscillations within a radius
   - Reroute suppression verified
3. **Network Interruption**
   - Destination updates paused for 10–30 seconds
   - Session continues in degraded mode
   - Recovery without restart

Backend-driven simulation is the default implementation.

---

## 4. Functional Requirements

### 4.1 Backend Simulation Engine

- Accepts route scripts (JSON or GPX-derived)
- Emits location updates on a time schedule
- Supports speed, accuracy, and pause injection
- Produces deterministic output for repeatable runs

#### Route Script (Conceptual)
- waypoint_id
- latitude
- longitude
- timestamp_offset
- speed (optional)
- accuracy (optional)

---

### 4.2 Reroute Decision Engine v2 (Backend)

Backend remains the **single authority** for reroute decisions.

#### Enhancements
- **Jitter filtering**
  - Ignore movement within a configurable radius
- **Hysteresis**
  - After a reroute, require stronger signals to reroute again
- **Cooldown enforcement**
  - Minimum time between reroutes
- **Fallback logic**
  - If ETA delta is unreliable, use distance/time only

#### Default Thresholds (Configurable)
- Movement threshold: ≥ 100 meters
- ETA delta: ≥ 2 minutes
- Cooldown: ≥ 30 seconds
- Reroute cap: 2 per minute
- Jitter radius: 30 meters

---

### 4.3 Adaptive Location Throttling (Destination → Backend)

Reduce unnecessary updates while preserving perceived liveness.

#### Rules
- Speed buckets:
  - Stationary
  - Walking
  - Driving
- Accuracy buckets:
  - Good
  - Medium
  - Poor

Update frequency decreases when:
- Stationary
- Accuracy is poor
- Session is paused

---

### 4.4 Client Resilience (iOS)

- Navigation continues using last known route if backend signals are delayed
- Graceful recovery after:
  - brief network loss
  - background → foreground transitions
- Explicit session-ended / expired UX
- No UI “jumping” during reroutes

---

## 5. Telemetry & Observability (Engineering-Focused)

### Required Events
- session_started
- session_paused
- session_resumed
- session_ended (with reason)
- reroute_triggered
- reroute_suppressed
- simulation_started
- simulation_completed

### Reroute Event Must Include
- movement_delta
- eta_delta
- cooldown_state
- cap_state
- threshold_values_used
- reason_code

No growth analytics required.

---

## 6. Non-Functional Requirements

### Performance
- ≤5s perceived lag for simulated and real updates
- Smooth reroute transitions

### Battery
- Demonstrable reduction in update frequency vs Phase 1
- No continuous rerouting loops

### Reliability
- No crashes during simulation scenarios
- Session integrity preserved across interruptions

---

## 7. Platform & Architecture

### Client
- iOS only
- Swift + MapKit
- Supports “Sim Mode” for selecting simulated destination

### Backend
- Cross-platform-ready
- Owns:
  - simulation engine
  - reroute logic
  - session lifecycle
  - throttling rules

Client does not independently decide reroutes.

---

## 8. Explicit Non-Goals (Phase 2)

- Group navigation
- Chat or messaging
- Meet-point prediction
- Android client
- Monetization
- Social features

---

## 9. Phase 2 Exit Criteria

Phase 2 is complete when:

- A full simulated navigation can be run end-to-end
- At least one reroute occurs during simulation
- Jitter simulation does not cause reroute thrashing
- Network interruption simulation recovers without restart
- Battery usage is improved compared to Phase 1
- Logs clearly explain all reroute and session decisions

---

## 10. Open Questions (Do Not Block Execution)

- Final storage format for route scripts
- UI exposure level for Sim Mode
- Long-term retention of telemetry logs

---

End of Phase 2 PRD

---

## 1. Objective

Elevate simulation from a backend-only harness to a **first-class, UI-driven capability** that is visual, replayable, and explainable. Phase 3 proves end-to-end correctness and UX sanity by allowing developers to **see** destination movement, reroutes, and ETA changes directly in the iOS UI—using the same code paths as real navigation.

---

## 2. Phase 3 Success Definition

Phase 3 is successful only if all are true:

- A developer can launch **Simulation Mode** from the iOS UI
- A simulated destination moves visibly on the map
- Routes and ETAs update live without restarting navigation
- Reroutes are visually observable and understandable
- The same simulation produces identical outcomes when replayed
- Simulation and real sessions share identical navigation/reroute code paths
- Reroute reasons can be inspected from the UI (dev/debug mode)

---

## 3. In Scope

### 3.1 Simulation Mode (UI, First-Class)

A dedicated Simulation Mode exposed via a dev flag (or equivalent).

#### Requirements
- Toggle Simulation Mode on/off
- Select a **Simulated Destination Contact**
- Select a **Route Script**
- Start, pause, resume, restart simulation
- Clear visual indicator when Simulation Mode is active

Simulation Mode must be explicit and non-ambiguous.

---

### 3.2 Visual Playback on Map

The map must visually reflect simulation state:

- Destination marker moves along the scripted path
- Navigator route updates automatically
- ETA updates in real time
- Reroutes are visible without UI jumps

Optional enhancements (acceptable if low-cost):
- Route color flash or subtle animation on reroute
- Marker annotation during reroute events

---

### 3.3 Simulation Controls (UI)

Minimum controls:
- Play / Pause
- Restart
- Speed control: 1×, 2×, 5×

Optional (if cheap):
- Jump to timestamp
- Step forward/backward by event

All controls drive the **backend simulation engine**, not a client-only fake.

---

### 3.4 Reroute Reason Visibility (Dev / Debug)

When a reroute occurs, the UI must be able to surface (in debug mode):

- Reason code
- Movement delta
- ETA delta
- Cooldown state
- Threshold values used

Display options:
- Debug overlay
- Bottom sheet
- Long-press gesture on route
- Console-style panel

Visibility must not affect production UX.

---

### 3.5 Event Timeline / Playback (Optional but Strong)

A simple, chronological timeline showing:
- Session started
- Reroute triggered / suppressed
- Network interruption / recovery
- Session ended

Timeline is read-only and for debugging/verification only.

---

## 4. Functional Requirements

### 4.1 Backend Simulation Engine (Parity Requirement)

Backend remains the source of truth for:
- Simulation clock
- Destination movement
- Reroute decisions

Simulation output must be deterministic.

#### Route Script (Conceptual)
- waypoint_id
- latitude
- longitude
- timestamp_offset
- speed (optional)
- accuracy (optional)

Same scripts used in Phase 2 remain valid.

---

### 4.2 Client–Backend Contract

- UI sends simulation control commands (start/pause/resume/restart/speed)
- Backend emits:
  - destination updates
  - reroute signals
  - session state changes
- Client renders navigation and applies reroutes exactly as in real sessions

No simulation-specific navigation logic in the client.

---

### 4.3 Navigation Parity Rule (Hard Requirement)

- Simulation must exercise the **same navigation, reroute, and ETA code paths** as real navigation.
- Any divergence is considered a Phase 3 failure.

---

## 5. Telemetry & Observability

### Required UI-Visible Signals (Debug Mode)
- Current simulation time
- Active thresholds
- Cooldown timer
- Last reroute reason

### Required Logged Events
- simulation_started
- simulation_paused
- simulation_resumed
- simulation_completed
- reroute_triggered
- reroute_suppressed
- session_ended (with reason)

Logs must correlate UI events to backend decisions.

---

## 6. Non-Functional Requirements

### Performance
- UI remains responsive during simulation
- No frame drops during reroute animations
- ≤5s perceived lag for updates

### Reliability
- Simulation can be replayed multiple times without drift
- Restarting simulation fully resets state
- No crashes during simulation control changes

---

## 7. Platform & Architecture

### Client
- iOS only
- Swift + MapKit
- Simulation Mode gated behind dev flag
- Acts as controller + observer

### Backend
- Cross-platform-ready
- Owns:
  - simulation clock
  - destination movement
  - reroute decisions
  - session lifecycle

Backend remains authoritative.

---

## 8. Explicit Non-Goals (Phase 3)

- Group simulation
- Android UI
- End-user-facing simulation features
- Monetization
- Social features
- Analytics beyond debugging/telemetry

---

## 9. Phase 3 Exit Criteria

Phase 3 is complete when:

- A developer can run a full simulation from the UI
- Destination movement, reroutes, and ETA changes are visible
- Reroute reasons can be inspected in the UI
- Replay produces identical results
- No simulation-only code paths exist for navigation logic
- Simulation meaningfully increases confidence in real-world behavior

---

## 10. Open Questions (Do Not Block Execution)

- Final UI placement of Simulation Mode toggle
- Persistence of simulation logs
- Whether timeline UI is required or optional

---

End of Phase 3 PRD

---

Phase: Phase 3.0.1 — Pursuit Simulation & Map UI Controls
Status: Ready for Execution
Source of Truth: Project Constitution (Locked)
Depends On: Phase 3 — Interactive Simulation & Visual Debugging (Completed)

---

## 1. Objective

Refine the Phase 3 simulation by introducing a **pursuit-style dual-motion scenario**, where the destination represents a **police officer in active pursuit**, and the navigator (client user) follows the officer in real time.

Phase 3.0.1 validates that Live Destination Navigation performs correctly when:
- The destination is **continuously moving at vehicle speeds**
- The navigator is also **moving and navigating dynamically**
- The system behaves like a real-time “follow the unit” experience

Additionally, improve usability by allowing the **simulation control menu to be minimized** on the map UI.

---

## 2. Phase 3.0.1 Success Definition

Phase 3.0.1 is successful only if all are true:

- A simulated **police officer destination** moves continuously on the map
- The navigator is simultaneously simulated as moving and routing toward the officer
- Navigation updates, reroutes, and ETA changes occur while **both entities are in motion**
- The navigator can effectively “follow” the officer in real time
- Reroute decisions remain backend-authoritative and deterministic
- The simulation control menu can be minimized and restored without disrupting navigation
- The experience feels smooth, stable, and believable under pursuit dynamics

---

## 3. In Scope

### 3.1 Police Pursuit Destination Simulation

Introduce a **Pursuit Profile** for simulated destinations.

#### Requirements
- Destination represents a police officer in a moving vehicle
- Continuous movement with realistic driving speeds
- Support for turns, accelerations, decelerations, and route changes
- No artificial stops unless explicitly scripted

#### Pursuit Profile (Conceptual Defaults, Configurable)
- Speed range: 25–70 mph
- Variable speed over time (acceleration/deceleration supported)
- GPS accuracy within realistic vehicle bounds
- Path changes that can trigger meaningful reroutes

This profile must reuse the existing simulation engine and route script format.

---

### 3.2 Dual-Motion Simulation (Navigator Following Destination)

Both participants move simultaneously.

#### Requirements
- Navigator position advances continuously along its calculated route
- Destination position advances independently per pursuit simulation script
- Backend evaluates reroute thresholds based on **relative motion**
- ETA updates dynamically reflect whether the navigator is closing distance or falling behind

Simulation must demonstrate:
- The navigator actively “following” the destination
- Rational reroute behavior when the officer changes direction or speed
- No route thrashing caused by continuous movement

No simulation-only shortcuts or special-case logic are allowed.

---

### 3.3 Backend Enhancements (Simulation Context)

- Support synchronized simulation clocks for:
  - pursuit destination movement
  - navigator movement
- Ensure reroute logic remains stable under higher-speed, continuous motion
- Preserve determinism across repeated simulation runs

Backend remains the single authority for:
- session state
- movement updates
- reroute decisions

---

### 3.4 UI: Map Menu Minimization

Improve map usability during pursuit simulation.

#### Requirements
- Simulation control menu can be minimized
- Minimized state:
  - preserves full map visibility
  - allows uninterrupted navigation playback
- Menu can be restored via a clear affordance (icon or gesture)
- Transitions must be smooth and non-disruptive

Applies to Simulation Mode only.

---

## 4. Functional Requirements

### 4.1 Simulation Controls (Extended)

Simulation Mode must support:
- Selecting **Pursuit (Police Officer) Profile**
- Enabling **Dual-Motion Follow Mode**
- Adjusting simulation speed (1×, 2×, 5×)
- Starting, pausing, restarting simulation

All controls interact with backend simulation APIs.

---

### 4.2 Navigation & Reroute Behavior

- Reroutes must trigger based on backend thresholds during pursuit
- ETA updates continuously without reset
- Navigation must remain stable despite frequent destination movement

Simulation must clearly show:
- Destination leading
- Navigator following
- Backend-driven reroute decisions as the officer changes route

---

## 5. UI & UX Requirements

### Map Presentation
- Navigator and destination markers are clearly distinct
- Destination marker visually indicates “pursuit unit” (iconography optional)
- Both markers move smoothly and continuously
- Route updates are visually smooth and comprehensible

### Menu Minimization
- Default state: expanded
- Minimized state:
  - compact control affordance
  - no loss of simulation state or controls
- Minimize/maximize state persists through play/pause actions

---

## 6. Telemetry & Observability

### Required Logged Events
- pursuit_simulation_started
- pursuit_profile_enabled
- navigator_simulation_position_update
- destination_simulation_position_update
- menu_minimized
- menu_restored
- reroute_triggered (with relative-motion context)
- follow_distance_delta (navigator vs destination)

Telemetry is for debugging and verification only.

---

## 7. Non-Functional Requirements

### Performance
- Continuous high-speed motion without UI stutter
- No noticeable lag between backend updates and UI movement

### Reliability
- Simulation restart fully resets navigator and destination
- Replays remain deterministic and repeatable

---

## 8. Explicit Non-Goals (Phase 3.0.1)

- Real-world law enforcement integrations
- Tactical pursuit optimization
- Group pursuit scenarios
- Android support
- Public-facing simulation features
- Monetization

---

## 9. Phase 3.0.1 Exit Criteria

Phase 3.0.1 is complete when:

- A pursuit-style simulation runs end-to-end
- Police officer destination moves continuously at vehicle speeds
- Navigator follows and reroutes dynamically in real time
- ETA updates accurately during pursuit
- Simulation menu can be minimized/restored cleanly
- Replay produces identical outcomes
- No simulation-only navigation logic exists

---

## 10. Open Questions (Do Not Block Execution)

- Default pursuit speed profiles
- Visual styling for pursuit marker
- Whether follow-distance indicators should be shown in UI

---

End of Phase 3.0.1 PRD

---

Phase: Phase 4 — iOS UX Polish, Accessibility & Trust Surface
Status: Ready for Execution
Source of Truth: Project Constitution (Locked)
Depends On: Phase 3.0.1 — Pursuit Simulation & Map UI Controls (Completed)

---

## 1. Objective

Deliver a production-quality iOS experience that aligns with Apple Human Interface Guidelines, clarifies consent and session state, and is fully accessible (Dynamic Type, VoiceOver, Reduce Motion, high contrast). Phase 4 focuses on **native iOS UI polish** and **trust surfaces**, without changing backend logic or navigation behavior.

---

## 2. Phase 4 Success Definition

Phase 4 is successful only if all are true:

- Navigator and Destination UI flows are **clear, minimal, and HIG-compliant**
- Consent and session state are visible within **one tap**
- Dynamic Type and VoiceOver work across all screens
- UI is stable during reroutes (no jumps, no layout thrash)
- Dark Mode and high-contrast modes are fully supported
- Errors and recovery states are explicit, actionable, and accessible

---

## 3. In Scope

### 3.1 Information Architecture (iOS)

Minimum surfaces:
- **Home**: shared contacts list and current session entry point
- **Active Session**: map + navigation HUD
- **Destination Status**: “Someone is navigating to you” + controls
- **Settings**: location sharing status, privacy, permissions

Simulation Mode remains dev-only and must be hidden in production builds.

---

### 3.2 Onboarding & Permissions UX

- Pre-permission education screens (location + notifications)
- System prompt timing aligned with user intent
- Clear fallback UX if permissions are denied
- All permission screens must support Dynamic Type and VoiceOver

---

### 3.3 Navigation HUD & Map Overlays

The session screen must include:
- **Route summary card** (ETA, distance, arrival time)
- **Session status chip** (Active / Paused / Ended)
- **Consent indicator** (destination visible + controllable)
- **Primary action** (Stop Navigation)

Placement requirements:
- Use safe-area aware bottom overlays (no hardcoded offsets)
- Controls must maintain 44x44 pt tap targets
- Avoid occluding turn-by-turn instructions

---

### 3.4 Consent & Trust Surfaces

- Destination must see a persistent “Navigator is heading to you” state
- Pause and Stop must be immediately reachable (no hidden menus)
- Revocation messaging must be explicit and non-ambiguous

---

### 3.5 Error, Recovery, and Empty States

Required states:
- Destination unavailable / sharing stopped
- Network interruption (degraded mode)
- Session expired or ended remotely

Each state must provide:
- A clear explanation
- A single primary action
- VoiceOver labels and hints

---

### 3.6 Accessibility & System Integration

- Support Dynamic Type for all text
- Support VoiceOver on all controls and key status labels
- Respect Reduce Motion and Reduce Transparency
- Use semantic colors and SF Symbols
- Maintain color contrast in Light/Dark/High Contrast modes

---

## 4. Functional Requirements (iOS UI)

### 4.1 Navigation Structure

- Use `NavigationStack` for hierarchical flows
- Use sheets for secondary controls (e.g., session details)
- Avoid deep stacks during active navigation

---

### 4.2 Component Requirements

Minimum reusable components:
- **SessionHeader**: contact name, role (Navigator/Destination), session state
- **RouteSummaryCard**: ETA, distance, arrival time
- **ConsentStatusRow**: status + action (Pause / Stop)
- **StatusToast**: transient, accessible notifications

All components must:
- Use semantic fonts (`.headline`, `.body`, `.caption`)
- Use semantic colors (`.primary`, `.secondary`, `.background`)
- Adapt to Dynamic Type

---

### 4.3 Motion & Feedback

- Subtle animation on reroute (e.g., route color flash)
- Haptic feedback on start/stop/pause
- No continuous animations that would conflict with Reduce Motion

---

## 5. Telemetry & Observability (UI-Focused)

Required UI events:
- screen_home_viewed
- session_started_tapped
- session_stopped_tapped
- consent_panel_opened
- destination_pause_tapped
- destination_stop_tapped
- permission_denied_state_viewed

UI events are for QA and debugging only.

---

## 6. Non-Functional Requirements

### Performance
- UI overlays render at 60 fps during navigation
- No frame drops when reroutes occur

### Reliability
- UI recovers cleanly after background → foreground
- Session state is always in sync with backend

---

## 7. Explicit Non-Goals (Phase 4)

- New backend or reroute logic
- Group navigation or shared destinations
- Android UX work
- Monetization or growth analytics

---

## 8. Phase 4 Exit Criteria

Phase 4 is complete when:

- All Phase 4 success criteria pass on-device testing
- Dynamic Type and VoiceOver validation completed
- Consent and session states are unambiguous for both roles
- UX remains stable through reroutes and interruptions

---

## 9. Open Questions (Do Not Block Execution)

- Final UI placement for consent indicator (top bar vs bottom sheet)
- Whether haptics should be optional via settings
- Default typography scale for large text sizes

---

End of Phase 4 PRD
