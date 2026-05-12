Project Constitution — Live Pursuit(LP)
1. Product Mission
Enable people to navigate to other people who are actively moving, with zero manual intervention, full consent, and continuous ETA accuracy.
LDN exists to eliminate the friction of coordinating arrival when the destination is not a place—but a person.
2. Problem Statement
Current navigation systems assume destinations are static. When navigating to a person:
Routes are calculated to stale coordinates
ETAs become inaccurate as the destination moves
Users must manually re-check, re-select, and restart navigation
Coordination breaks down during motion
This creates unnecessary friction in everyday scenarios like meeting friends, family coordination, convoys, and real-time meetups.
LDN solves this by treating a person as a live destination, not a fixed pin.
3. Target User
Primary (MVP)
iOS users who already share location with trusted contacts
Users coordinating real-world meetups while both parties are in motion
Explicitly excluded (for MVP)
Anonymous users
Passive location viewers
Large group coordination
Social discovery use cases
4. Core Value Proposition
“Once I start navigating to you, I stay locked onto you, not your last known location.”
The user never has to:
Reopen a map
Re-select a destination
Restart navigation
The system adapts automatically as the destination moves.
5. Product Principles (Non-Negotiable)
5.1 Live Over Static
Destinations are dynamic by default. Static routing is a fallback, not the norm.
5.2 Consent Is Visible
All tracking is explicit, bilateral, and reversible at any moment.
5.3 Minimal User Effort
After navigation begins, the user does nothing.
5.4 Battery-Aware by Design
Location updates and reroutes are throttled intelligently, not continuously.
5.5 Coordination, Not Social
LDN is a utility, not a network.
6. MVP Scope (Hard Boundary)
In Scope
One navigator → one moving destination
Real-time destination updates
Automatic rerouting
Live ETA updates
Visible consent on both sides
Session-based navigation
Out of Scope (Until Later Phases)
Group navigation
Chat or messaging
Meet-point prediction
Offline navigation
Background tracking without an active session
Cross-platform clients
Monetization features
Anything not explicitly listed as “In Scope” is out.
7. Architecture Principles
Client
Native iOS
Swift + MapKit
Responsible for UI, GPS capture, and route rendering
Backend
Owns navigation session state
Relays destination location updates
Applies reroute thresholds and throttling rules
Manages consent and session lifecycle
Business logic lives server-side to preserve cross-platform viability.
8. Navigation Model
Navigation is event-driven.
Destination movement triggers evaluation
Reroutes occur only when thresholds are crossed
Recalculation is silent and automatic
The client does not independently decide to reroute
This prevents route thrashing, battery drain, and user confusion.
9. Consent & Trust Model
Location sharing must already be enabled
Destination user sees active navigation sessions
Destination user can pause or terminate at any time
Revoking sharing immediately ends the session
Sessions auto-expire when inactive
No passive tracking. No ambiguity.
10. Success Definition (MVP)
The MVP is successful only if all of the following are true:
Navigation starts to a shared contact
Routes update automatically as the destination moves
ETA updates without user interaction
Navigation does not require restarting
Consent is clear and visible to both parties
Battery usage is acceptable for a 30–60 minute session
Partial success is failure.
11. Explicit Non-Goals
LDN will not attempt to:
Replace Apple Maps or Google Maps
Optimize for growth or virality
Support social feeds or discovery
Infer intent or predict meeting behavior
Persist long-term movement history
These are deliberate exclusions.
12. Phase Discipline
This document governs all phases unless explicitly amended.
Roadmap decisions live in this thread
Execution details live in phase-specific chats
Scope changes require explicit revision here
Silence does not equal approval.
13. Amendment Process
Any change to:
Mission
MVP scope
Architecture stance
Consent model
Must be:
Proposed explicitly
Evaluated for scope and risk
Approved and logged as a constitutional amendment
No informal drift.
14. Closing Principle
LDN succeeds by being boringly reliable in a place where existing systems are surprisingly clumsy.
Coordination beats cleverness.
Clarity beats features.
Shipping beats perfection.