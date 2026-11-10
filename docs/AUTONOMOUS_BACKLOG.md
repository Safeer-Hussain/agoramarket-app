# Autonomous Engineering Backlog

## AgoraMarket 25-Day Continuous Delivery Roadmap
**Architect & Engineering Lead:** Safeer Hussain  
**Methodology:** Autonomous Daily Sprint Execution with Zero Anti-AI Footprint  
**Zero Emoji Policy:** Strictly enforced across all tickets, commit messages, and documentation.

---

### [x] Sprint 01: Core Architecture & Dependency Foundation
- Initialize Flutter project with feature-first Clean Architecture directory hierarchy.
- Configure `pubspec.yaml` with production dependencies (`provider`, `get_it`, `sqflite`, `dio`, `flutter_map`, `fl_chart`, `connectivity_plus`, `shared_preferences`).
- Setup custom launcher icons and branded asset hierarchy.
- Deliverable: Clean compile on Android API 36 and iOS 13+.

### [x] Sprint 02: Dynamic Theme System & Color Scheme Parity
- Implement Obsidian Dark and Crisp Light Material 3 color palettes in `AppTheme`.
- Construct `ThemeProvider` with SharedPreferences persistence.
- Enforce dynamic color resolution via `Theme.of(context).colorScheme`.
- Deliverable: Automated theme switching test with zero hardcoded color violations.

### [x] Sprint 03: Offline Database Schema & Seed Data Engine
- Design SQLite database schema across 7 normalized tables in `AppDatabase`.
- Implement robust migration paths and WAL journaling.
- Seed realistic engineering talent profiles, video pitches, comments, and contracts.
- Deliverable: Instant offline database boot with verified query benchmarks.

### [x] Sprint 04: Dio Mock API Interceptor & Network Emulation
- Build `MockApiInterceptor` with synthetic latency emulation (400ms to 900ms).
- Add support for configurable HTTP status codes (200 OK, 503 Unavailable).
- Connect repository layers to interceptor with SQLite fallback.
- Deliverable: Deterministic API emulation requiring zero external network calls.

### [x] Sprint 05: Viewport Frame Latency Telemetry Engine
- Implement `RenderLatencyMonitor` attaching to `SchedulerBinding.addTimingsCallback`.
- Track microsecond frame build, raster, and total rendering durations.
- Create HUD latency pill displaying live frame performance.
- Deliverable: Sustained sub-8ms frame build telemetry at 120 FPS.

### [x] Sprint 06: Animated Branded Splash & Asset Pre-Cache Engine
- Design multi-stage sequential splash screen with scale and fade curves.
- Implement GPU asset pre-caching for avatars, badges, and pitch thumbnails.
- Wire smooth fade transition into main `AdaptiveScaffold`.
- Deliverable: Zero-jank cold launch sequence completing within 1200ms.

### [x] Sprint 07: Adaptive Navigation Shell & Viewport Safety
- Build `AdaptiveScaffold` supporting portrait `NavigationBar` and landscape `NavigationRail`.
- Apply compact landscape AppBar with micro-typography (toolbarHeight: 36).
- Implement global keyboard dismiss gesture detector and `ScrollViewKeyboardDismissBehavior.onDrag`.
- Deliverable: Flawless landscape layout on 360dp height viewports.

### [x] Sprint 08: Custom Canvas Video Reel Renderer
- Construct `VideoReelCanvas` utilizing multi-layered `CustomPainter`.
- Render animated sinusoidal audio waveforms, pulse prisms, and code syntax trees.
- Add playback state controls: play/pause, scrub bar, mute, and speed toggles.
- Deliverable: Hardware-accelerated reel canvas sustaining 120 FPS.

### [x] Sprint 09: Vertical Video Discovery Feed & Overlay HUD
- Build `VideoFeedView` with full-screen `PageView.builder` in portrait.
- Design responsive two-pane split layout for landscape orientation.
- Implement overlay HUD with creator information, rates, skill tags, and like counters.
- Deliverable: Reactive feed with instant optimistic like state mutation.

### [x] Sprint 10: Feed Interactions: Comments & Share Sheets
- Implement `CommentSheet` with persistent SQLite thread storage.
- Add inline validation and character count enforcement.
- Construct native `ShareSheet` supporting clipboard export and card generation.
- Deliverable: Fully functional comment and share workflows.

### [x] Sprint 11: Hire Specialist Flow & Video Pitch Publishing
- Build `HireModal` with USD and PKR budget conversion.
- Create `PublishPitchModal` with multi-step form validation.
- Implement unified feedback via `AppFeedback` snackbars.
- Deliverable: Validated pitch creation and hiring proposal dispatch.

### [x] Sprint 12: OpenStreetMap Integration & Custom Vector Pins
- Integrate `flutter_map` with free OpenStreetMap tile server.
- Center default map coordinate on Lahore tech hub.
- Construct custom vector marker badges for Jobs, Freelancers, and Agencies.
- Deliverable: Hardware-accelerated map canvas with smooth multi-touch pan and zoom.

### [x] Sprint 13: Spatial Filters & Dynamic Route Plotting
- Build interactive radius filter slider (1km to 50km).
- Add category filter chips and hourly rate threshold sliders.
- Implement `latlong2` distance calculation and dynamic polyline drawing.
- Deliverable: Interactive talent radar with synchronized detail cards.

### [x] Sprint 14: Real-Time Messaging Hub & Responsive Inbox
- Build `ChatInboxView` with unread indicators and online presence badges.
- Implement two-pane master-detail inbox layout for landscape viewports.
- Construct search filtering across conversations and participant names.
- Deliverable: Sub-millisecond conversation switching and search.

### [x] Sprint 15: Chat Thread & Transient Typing Simulation
- Build `ChatConversationView` with auto-scrolling message streams.
- Implement simulated incoming replies with typing bubble indicators.
- Guard async operations with strict `try ... finally` state resets.
- Deliverable: Stable chat loop with zero dangling typing states.

### [x] Sprint 16: Milestone Escrow Contract Negotiation Engine
- Design `ContractProposalCard` embedded within message threads.
- Implement milestone terms, delivery timelines, and currency equivalency.
- Add reactive "Accept Offer" and "Counter Terms" state mutators.
- Deliverable: End-to-end contract negotiation workflow backed by SQLite.

### [x] Sprint 17: On-Device AI Marketplace Concierge
- Implement `AiConciergeProvider` with local matching heuristics.
- Build interactive chat interface with suggested prompt chips.
- Add simulated word-by-word token streaming and reasoning indicators.
- Deliverable: Autonomous concierge matching requirements to verified talent.

### [x] Sprint 18: On-Device Technical Pitch Analyzer
- Build 4-dimensional pitch scoring algorithm.
- Evaluate Problem-Solution Fit, Technical Depth, Delivery Clarity, and Market Rates.
- Present visual scorecard with actionable improvement tips.
- Deliverable: Instant on-device evaluation of published pitches.

### [x] Sprint 19: Creator Profile & Performance Analytics (`fl_chart`)
- Build `UserProfileView` showcasing verified skills and escrow track record.
- Implement multi-metric interactive line chart with tooltip overlays.
- Add contract availability toggle with instant SQLite and preference sync.
- Deliverable: Comprehensive executive portfolio and analytics dashboard.

### [x] Sprint 20: Recruiter Debug Drawer & Network Chaos Engine
- Build `RecruiterDebugDrawer` accessible via long-press on app version.
- Implement simulated latency sliders and forced HTTP 503 error toggles.
- Add mock incoming message injector and live FPS counters.
- Deliverable: Complete testing and evaluation toolbox for recruiters.

### [x] Sprint 21: Viewport & Layout Regression Testing
- Author widget tests verifying zero `RenderFlex` overflow errors on 800x360 landscape screens.
- Author widget tests verifying globally unique Hero tags across all tabs.
- Author widget tests verifying dynamic Dark/Light theme switching.
- Deliverable: Automated widget test suite passing with zero exceptions.

### [x] Sprint 22: Unit Test Suite & State Mutation Coverage
- Author comprehensive unit tests for `VideoFeedProvider`.
- Author unit tests for `ChatProvider` contract negotiation workflows.
- Author unit tests for `MapFilterProvider` spatial calculations.
- Author unit tests for `ProfileProvider` and `ThemeProvider`.
- Deliverable: 22+ unit and widget tests with high coverage metrics.

### [x] Sprint 23: Accessibility & Screen Reader Optimization
- Add semantic labels across all icon buttons and custom canvas components.
- Verify minimum 48x48dp touch targets on all interactive elements.
- Validate color contrast ratios against WCAG 2.1 AA standards.
- Deliverable: Full screen reader compatibility across iOS VoiceOver and Android TalkBack.

### [x] Sprint 24: Continuous Integration & Automated Delivery
- Build `.github/workflows/ci.yml` using `subosito/flutter-action@v2` on stable channel.
- Configure steps for dependency installation, static analysis, and test coverage.
- Enforce zero warning tolerance on `flutter analyze`.
- Deliverable: Green CI pipeline badge integrated into README.

### [x] Sprint 25: Production Hardening & Release Documentation
- Finalize Product Requirements Document (`docs/PRD.md`).
- Update architecture documentation and sequence diagrams in `README.md`.
- Conduct memory leak profiling and unmounted provider audit.
- Deliverable: Production-ready AgoraMarket release tag on GitHub.
