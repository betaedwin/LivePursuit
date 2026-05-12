# Phase 4 SwiftUI Component Tickets

Scope: Engineering-ready SwiftUI tasks for Phase 4 that follow iOS HIG, accessibility, and system integration guidance.

---

**Ticket UI-401: HomeView (Contacts + Session Entry)**

Goal: Provide a clear, minimal entry point for shared contacts and any active session.

Includes:
- Shared contacts list with “Navigate” affordance
- Active session banner entry point if a session exists
- Empty state for no shared contacts

Acceptance Criteria:
- Uses `NavigationStack` with clear title and large title behavior
- List rows meet 44x44 pt tap target minimums
- Active session banner is visible within one tap from Home
- Empty state offers a primary action to invite or manage sharing
- Uses semantic colors and fonts only

Accessibility:
- VoiceOver reads contact name, sharing status, and primary action
- Dynamic Type supported at all content sizes
- High contrast mode remains legible

Dependencies:
- Contact list data and sharing status
- Session state from backend

Estimate: M (3-5 dev days)
Priority: P1

Engineering Notes:
- Use `List` with `NavigationLink` for contact rows
- Use `@Environment(\.dynamicTypeSize)` to confirm layout flexibility
- Use `ContentUnavailableView` for empty state (iOS 17+) or custom equivalent

Test Notes:
- Manual: Dynamic Type to XXXL, VoiceOver on, Dark Mode, High Contrast
- UI Test: Active session banner appears when session is active

---

**Ticket UI-402: ActiveSessionMapView (Map + Overlays Container)**

Goal: Present MapKit navigation with stable, safe-area aware overlays.

Includes:
- MapKit route display
- Safe-area bottom overlay container for HUD elements

Acceptance Criteria:
- Overlays do not occlude turn-by-turn instructions
- Overlay layout is stable during reroutes and orientation changes
- Tap targets are 44x44 pt minimums
- Uses `safeAreaInset` for bottom controls

Accessibility:
- Map controls and overlays are VoiceOver discoverable
- Reduce Motion disables any non-essential animation

Dependencies:
- MapKit route rendering
- Session state and reroute signals

Estimate: L (5-8 dev days)
Priority: P1

Engineering Notes:
- Use `Map` or `MKMapView` wrapper with routing overlays
- Keep overlay container separate from map content to avoid layout jumps
- Use `@Environment(\.accessibilityReduceMotion)` to gate animations

Test Notes:
- Manual: Reroute during active navigation and confirm overlays do not shift
- Manual: Rotate device and confirm stable overlay placement

---

**Ticket UI-403: RouteSummaryCard**

Goal: Display ETA, distance, and arrival time in a readable card.

Includes:
- ETA, distance, arrival time
- Optional reroute indicator

Acceptance Criteria:
- Uses semantic fonts (`.headline`, `.body`, `.caption`)
- Uses semantic colors only
- Supports Dynamic Type without truncation at large sizes

Accessibility:
- VoiceOver reads labels and values in a logical order
- Supports Reduce Transparency

Dependencies:
- ETA and distance values from session

Estimate: S (1-2 dev days)
Priority: P1

Engineering Notes:
- Use `Grid` or `VStack` with flexible wrapping for large Dynamic Type
- Use `.accessibilityElement(children: .combine)` for the card

Test Notes:
- Manual: Large Dynamic Type with long ETA values
- Manual: VoiceOver reads ETA, distance, arrival time

---

**Ticket UI-404: SessionStatusChip**

Goal: Show session state at a glance (Active, Paused, Ended).

Includes:
- Compact, pill-style chip with icon and text

Acceptance Criteria:
- Color meanings remain legible in Dark Mode and High Contrast
- State changes animate subtly and respect Reduce Motion

Accessibility:
- VoiceOver announces state changes

Dependencies:
- Session state from backend

Estimate: S (1-2 dev days)
Priority: P1

Engineering Notes:
- Use `Label` with SF Symbols for consistent iconography
- Use `.symbolRenderingMode(.hierarchical)` to keep contrast

Test Notes:
- Manual: Toggle state and confirm accessible announcements
- Manual: Reduce Motion enabled disables animations

---

**Ticket UI-405: ConsentStatusRow**

Goal: Make consent visible and actionable within one tap.

Includes:
- Consent status label
- Primary action: Pause or Stop

Acceptance Criteria:
- Action is reachable without secondary menus
- Uses semantic colors and fonts
- 44x44 pt minimum tap target

Accessibility:
- VoiceOver label includes current consent state and action

Dependencies:
- Consent state from backend
- Destination controls availability

Estimate: M (2-4 dev days)
Priority: P1

Engineering Notes:
- Use `Button` with clear role for Stop and Pause actions
- Include confirmation sheet for Stop if required by policy

Test Notes:
- Manual: Pause and Stop actions are reachable within one tap
- Manual: VoiceOver reads consent state and action hint

---

**Ticket UI-406: StatusToast**

Goal: Provide transient, accessible status updates.

Includes:
- Reroute notifications
- Network degraded mode notice
- Session ended notice

Acceptance Criteria:
- Toasts are non-blocking and dismiss automatically
- Stack multiple toasts without overlap
- Respect Reduce Motion with fade instead of slide

Accessibility:
- Announced via `UIAccessibility.post` or SwiftUI `.accessibilityAnnouncement`
- Toast content readable with Dynamic Type

Dependencies:
- Status events from session or network layer

Estimate: M (2-4 dev days)
Priority: P2

Engineering Notes:
- Use a toast manager with a queue to prevent overlap
- Avoid covering primary actions in the HUD

Test Notes:
- Manual: Multiple toasts appear in sequence without overlap
- Manual: Reduce Motion enabled uses fade

---

**Ticket UI-407: DestinationStatusView**

Goal: Destination user sees persistent “Navigator is heading to you” state.

Includes:
- Navigator identity
- Pause and Stop controls
- Consent explanation text

Acceptance Criteria:
- Controls are primary and visible on first view
- State updates immediately when navigator starts or stops

Accessibility:
- VoiceOver announces navigator name and action buttons
- Dynamic Type supported

Dependencies:
- Session and consent state

Estimate: M (3-5 dev days)
Priority: P1

Engineering Notes:
- Use `Section` layout with a clear primary action cluster
- Consider `confirmationDialog` for destructive Stop

Test Notes:
- Manual: Session start/stop reflected immediately
- Manual: VoiceOver reads navigator identity and actions

---

**Ticket UI-408: SettingsView (Permissions + Privacy)**

Goal: Surface location sharing status and permission guidance.

Includes:
- Current location permission state
- Link to system settings
- Privacy summary

Acceptance Criteria:
- Clear call-to-action for denied permissions
- Uses system colors and fonts only

Accessibility:
- VoiceOver labels on all toggles and links
- High contrast text remains readable

Dependencies:
- Permission state from CLLocationManager

Estimate: M (2-4 dev days)
Priority: P1

Engineering Notes:
- Use `@Environment(\.openURL)` for Settings deep link
- Display status with `CLAuthorizationStatus` mapping

Test Notes:
- Manual: Denied state shows CTA to Settings
- Manual: VoiceOver reads permission state and CTA

---

**Ticket UI-409: PermissionEducationView (Pre-Prompt)**

Goal: Educate users before system permission prompts.

Includes:
- Why location is needed
- When it is used
- Primary action to continue

Acceptance Criteria:
- Shown only when permission has not been requested
- System prompt follows user intent

Accessibility:
- Supports Dynamic Type and VoiceOver

Dependencies:
- Permission state

Estimate: S (1-2 dev days)
Priority: P1

Engineering Notes:
- Use a single primary CTA that triggers the system prompt
- Persist that the education view was shown

Test Notes:
- Manual: View does not show after permission granted
- Manual: VoiceOver reads the explanation and CTA

---

**Ticket UI-410: ErrorStateView (Reusable Empty/Error)**

Goal: Standardize error and recovery UI for Phase 4 states.

Includes:
- Destination unavailable
- Network degraded mode
- Session expired or ended remotely

Acceptance Criteria:
- One clear explanation and one primary action
- Reusable across Home and Active Session screens

Accessibility:
- VoiceOver labels and hints on primary action

Dependencies:
- Error and session end reasons

Estimate: M (2-4 dev days)
Priority: P1

Engineering Notes:
- Use a single reusable component with parameterized title, body, CTA
- Use SF Symbols and semantic colors only

Test Notes:
- Manual: Each error state displays correct CTA
- Manual: VoiceOver reads error title, body, and CTA

---

**Ticket UI-411: RerouteFeedback (Visual + Haptic)**

Goal: Provide subtle reroute feedback without UI jumps.

Includes:
- Route color flash or short emphasis
- Haptic feedback on reroute and stop

Acceptance Criteria:
- Animation is subtle and short
- Disabled when Reduce Motion is enabled

Accessibility:
- Respect Reduce Motion and Reduce Transparency

Dependencies:
- Reroute events
- Haptic capability

Estimate: S (1-2 dev days)
Priority: P2

Engineering Notes:
- Use `UINotificationFeedbackGenerator` for reroute feedback
- Use non-invasive route overlay styling changes

Test Notes:
- Manual: Reduce Motion disables animation
- Manual: Haptics fire on reroute and stop

---

**Ticket UI-412: Accessibility Pass (Phase 4 Validation)**

Goal: Validate Dynamic Type, VoiceOver, Reduce Motion, and contrast across all Phase 4 surfaces.

Includes:
- Audit Home, Active Session, Destination Status, Settings
- Log and fix accessibility blockers

Acceptance Criteria:
- All Phase 4 success criteria for accessibility are met
- No layout breaks at largest Dynamic Type sizes

Dependencies:
- Completed Phase 4 UI components

Estimate: M (3-5 dev days)
Priority: P1

Engineering Notes:
- Use Accessibility Inspector for label and hint validation
- Verify contrast in Light, Dark, and High Contrast modes

Test Notes:
- Manual: Full accessibility sweep on device
- Manual: Record issues and link to fixes

