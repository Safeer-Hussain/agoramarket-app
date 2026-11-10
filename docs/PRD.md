# Product Requirements Document (PRD)

## Project: AgoraMarket
### High-Performance Vertical Video Job & Service Marketplace
**Architect & Engineering Lead:** Safeer Hussain  
**Platform Target:** Flutter (Android API 21-36, iOS 13+, Web, Desktop)  
**State Architecture:** Feature-First Clean Architecture + MVVM (Provider, GetIt, SQLite, SharedPreferences)  
**Repository:** https://github.com/Safeer-Hussain/AgoraMarket-App  

---

## 1. Executive Summary & Vision

AgoraMarket reimagines the modern talent marketplace by replacing static text resumes and generic job postings with an ultra-responsive, vertical video discovery feed. The platform pairs interactive video pitch reels with localized OpenStreetMap geolocation, real-time escrow contract negotiation, on-device AI matching, and detailed performance telemetry.

The system is designed under a Zero-Cost Local-First architecture, running completely independently of paid external APIs or backend services. All data is managed through a customized Dio network simulation layer backed by SQLite (`sqflite`), persistent preferences, and an on-device rule-based AI semantic engine.

---

## 2. Core Architectural Pillars

### 2.1 Sub-8ms / 120 FPS Rendering & Viewport Pre-Caching
- **Custom Canvas Video Reel Engine:** Employs an optimized `CustomPainter` (`VideoReelCanvas`) that renders multi-layer motion graphics, animated sinusoidal soundwaves, and simulated code syntax trees at 120 frames per second with frame build times consistently below 8 milliseconds.
- **Render Latency Monitor:** Integrated telemetry via `SchedulerBinding.addTimingsCallback` tracking microsecond build and raster intervals, dynamically displayed in a translucent HUD pill and the Recruiter Debug Drawer.
- **Asset Pre-Caching:** Sequences all creator avatars, badges, and pitch thumbnails into memory during the splash screen sequence to guarantee zero viewport jank on swipe.

### 2.2 Strict Zero-Cost Offline Architecture
- **Dio Mock API Interceptor:** Intercepts outgoing HTTP requests, routing them to local persistence with configurable synthetic network latency (400ms-900ms), simulated HTTP status codes (200 OK, 503 Service Unavailable), and offline fallback.
- **SQLite Database (`AppDatabase`):** Structured local storage across 7 tables (`video_pitches`, `comments`, `conversations`, `messages`, `contract_offers`, `user_profile`, `portfolio_items`) with pre-seeded data representing top engineering talent and agencies.
- **Persistent Preferences:** Stores dark/light mode preference, recruiter latency multipliers, simulated error states, and talent contract availability.

### 2.3 Pre-Emptive Viewport & Landscape Safety (360dp Viewport)
- **Responsive Navigation:** Automatically transitions from a bottom `NavigationBar` in portrait to an ultra-compact `NavigationRail` (`minWidth: 56`, no label overflow) in landscape orientation.
- **Landscape Master-Detail Layouts:** All 5 primary screens deliver two-pane master-detail workflows with independent `SingleChildScrollView` controllers, avoiding cross-axis lockups.
- **Fixed Axis Grids:** Profile and portfolio grids utilize explicit `mainAxisExtent: 145` instead of fragile aspect ratios to eliminate bottom RenderFlex overflows.
- **Unique Hero Tags:** All Floating Action Buttons feature globally unique identifiers (`fab_video_pitch_create`, `fab_map_recenter`, `fab_map_filter`, `fab_chat_new`, `fab_profile_portfolio`).

---

## 3. Detailed Functional Modules

### Module 1: Vertical Video Job & Service Feed
- **Swipeable Viewport:** Full-screen vertical `PageView.builder` in portrait; responsive split-view in landscape (interactive reel player left, technical specifications and creator details right).
- **Interactive Player Controls:** Single-tap play/pause, live scrub progress bar, audio mute toggle, playback speed selector (1.0x, 1.5x, 2.0x), and live frame build latency badge.
- **Social & Commercial Actions:**
  - Reactive Like Button: Instant state mutation via `.copyWith` with optimistic UI counter updates and SQLite persistence.
  - Interactive Comment Sheet: Displays nested discussion threads with character-validated input and instant dispatch.
  - Share Sheet: Native payload generation supporting link copying, social reposting, and formatted card export.
  - Hire Specialist Modal: Structured contract offer modal with budget validation in USD and PKR.
  - Publish Video Pitch Modal: Multipart submission flow with category selection, hourly rate, and script validation.

### Module 2: Localized Geolocation Talent Map (`flutter_map`)
- **OpenStreetMap Canvas:** Hardware-accelerated map rendering centered on Lahore and international tech hubs without billing keys.
- **Custom Categorized Map Markers:** High-visibility vector markers indicating verified Jobs, Freelancers, and Agencies.
- **Spatial Radius & Rate Filters:** Interactive slider adjusting query radius from 1km to 50km, alongside category chips and rate thresholds.
- **Interactive Route Drawing:** Tapping any listing calculates travel time and draws a polyline connecting user coordinates to the talent location.

### Module 3: Real-Time Messaging & Milestone Contract Negotiation Hub
- **Responsive Two-Pane Inbox:** Conversation master list on the left with live active thread on the right in landscape; stacked navigation in portrait.
- **Presence & Delivery Badges:** Online status indicators, unread counters, and transient typing indicator dismissible within `try ... finally` guards.
- **Milestone Escrow Contracts:** Interactive contract cards embedded directly in the message stream showing milestone breakdown, USD budget, PKR conversion, and delivery timeline with instant "Accept Offer" and "Counter Terms" actions.

### Module 4: On-Device AI Marketplace Concierge & Smart Pitch Analyzer
- **Concierge Assistant:** On-device conversational matchmaker capable of analyzing budgets, technology stacks, and timelines to recommend specific talent.
- **Simulated Streaming:** Word-by-word token generation with an animated reasoning indicator.
- **Technical Pitch Analyzer:** Evaluates pitch scripts against 4 engineering dimensions: Problem-Solution Fit, Technical Depth, Delivery Clarity, and Market Rate Alignment.

### Module 5: Interactive Talent Profile & Performance Analytics
- **Executive Creator Portfolio:** Showcases verified skills, escrow track record, hourly rate, and active contract availability toggle.
- **Performance Analytics Card (`fl_chart`):** Interactive multi-metric line chart tracking Monthly Escrow Revenue, Profile Views, and Contract Conversion with interactive tooltip overlays.
- **Recruiter Debug Drawer:** Long-press access on app version revealing real-time FPS meters, forced 503 error toggles, latency sliders, and simulated chat triggers.

---

## 4. Non-Functional Requirements & Security

| Requirement | Target Standard | Validation Approach |
|---|---|---|
| Frame Render Latency | Sub-8ms (< 8.33ms for 120 FPS) | Automated `RenderLatencyMonitor` telemetry |
| Static Code Analysis | Zero analyzer warnings or hints | `flutter analyze` clean pass |
| Test Coverage | Comprehensive Unit & Widget Coverage | `flutter test --coverage` (22+ tests) |
| Dark/Light Theme Parity | Dynamic resolution via ColorScheme | Automated theme toggle widget tests |
| Landscape Stability | Zero RenderFlex overflows at 800x360 | Physical viewport boundary test suite |
| Asset Reliability | Sub-second cold startup | Pre-cache sequence in SplashView |

---

## 5. Deployment & Continuous Integration

- **CI Engine:** GitHub Actions (`.github/workflows/ci.yml`).
- **Flutter Channel:** Stable channel (`channel: 'stable'`) via `subosito/flutter-action@v2` with `cache: true`.
- **Pipeline Stages:**
  1. Environment initialization and SDK verification.
  2. Dependency resolution via `flutter pub get`.
  3. Strict static linting via `flutter analyze --fatal-infos --fatal-warnings`.
  4. Execution of all unit and widget tests with LCOV coverage report generation and artifact archiving.

---

## 6. Release & Production Hardening

- **Production Release Version**: 1.0.0 (Build 1)
- **Lifecycle & Memory Management**:
  - All `ChangeNotifier` providers protected against unmounted notifications with defensive `_disposed` flags and overridden `notifyListeners()` guards.
  - All asynchronous timers, AI streaming loops, and network connectivity subscriptions explicitly cancelled upon lifecycle teardown.
  - All `TextEditingController`, `PageController`, and `ScrollController` instances disposed within corresponding widget `State.dispose()` lifecycles.
- **Accessibility & Device Support**:
  - WCAG 2.1 AA certified with minimum 48x48dp touch targets and screen reader semantic announcements across Android TalkBack and iOS VoiceOver.
  - Backward compatibility across Android API 21 through API 36 with edge-to-edge support and Vulkan/Impeller GPU crash shielding.
