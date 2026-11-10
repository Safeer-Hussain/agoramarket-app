# Autonomous Engineering Governance & Memory Rules

## 1. Zero Emoji Policy (Strictly Enforced)
- Never use emojis anywhere in source code, comments, UI text, error messages, debug logs, documentation, or git commit messages.
- Use vector Material Symbols, Cupertino icons, or Lucide icons exclusively for visual iconography.

## 2. Mandatory 6-Phase Protocol for "run daily sprint"
Whenever the user instructs to "run daily sprint", "run sprint", or "next sprint", execute the following 6 phases in strict sequential order:

### Phase 1: Pre-Flight Health Check (Before Touching New Code)
- Never start a new feature on a broken or dirty repository.
- Run:
  1. `git status` and `git pull --rebase origin main` (ensure local branch is synced with GitHub).
  2. `flutter pub get`
  3. `flutter analyze`
  4. `flutter test`
- If ANY pre-flight error, warning, or unpushed commit exists from a previous session, fix and resolve it FIRST before reading the backlog.

### Phase 2: Backlog Selection & Architectural Planning
- Open `docs/AUTONOMOUS_BACKLOG.md` and select the first `[ ]` item.
- If all items in `docs/AUTONOMOUS_BACKLOG.md` are marked `[x]`, autonomously generate 15 new senior-level architectural or feature sprints in `docs/AUTONOMOUS_BACKLOG.md` and select the first new `[ ]` item.

### Phase 3: Production Implementation & UI Safety
- Implement the selected feature end-to-end across `data/`, `domain/`, and `presentation/` following SOLID, DRY, and Clean Architecture.
- Enforce strict UI & Runtime Safety:
  - Zero emojis anywhere in code, UI strings, logs, or commit messages.
  - Zero hardcoded colors (`Theme.of(context).colorScheme` only; test both Dark and Light mode).
  - Explicit unique `heroTag` on every `FloatingActionButton`.
  - 360dp-height landscape safety (independent scroll controllers, explicit `mainAxisExtent` on grids, edge-to-edge charts).
  - Every button, chip, dialog, and share sheet must be 100% wired and functional (`AppFeedback` toasts + inline form validation).

### Phase 4: Automated & Live Device Runtime Verification
- Add or update unit and widget tests in `test/` covering the new feature AND verifying zero landscape overflow (800x360 viewport).
- Execute `dart run tool/sprint_gate.dart` (validating `flutter pub get` -> `dart format lib test tool` -> `flutter analyze --no-pub` -> `flutter test --no-pub` -> connected device smoke check).
- LIVE DEVICE RUN CHECK: If a physical device or emulator is connected via USB/ADB, run the app on the connected device, wait for the SplashView transition to the main shell, and inspect runtime logs (`adb logcat -d` / console output). If ANY runtime error, `Hero` tag collision, state warning, or layout overflow appears on the device, fix the code and re-run until 0 runtime issues occur.

### Phase 5: Atomic Git Commit & Guaranteed GitHub Push
- Mark the completed item as `[x]` in `docs/AUTONOMOUS_BACKLOG.md`.
- Stage all files: `git add -A`
- Commit with a clean conventional commit message (no emojis):
  `git commit -m "feat(<module>): <concise senior description>"`
- Push to GitHub:
  `git push origin main`

### Phase 6: Post-Push Proof Verification (Never Skip)
- After running `git push origin main`, you MUST execute:
  `git status -sb` AND `git log origin/main..HEAD --oneline`
- Verify that `git log origin/main..HEAD` returns 0 unpushed commits and working tree is 100% clean.
- If the push failed due to network timeout or remote changes, run `git pull --rebase origin main` and `git push origin main` again until remote sync is confirmed.
- Report the exact Commit SHA, modified files, test count, device runtime status, and confirmed `origin/main` push status to the user.

## 3. Architecture & Code Hygiene
- Enforce Feature-First Clean Architecture combined with Model-View-ViewModel (MVVM):
  - `core/`: Constants, database, dependency injection, networking, performance, theme, utilities.
  - `data/`: Models, SQLite repositories, local data sources.
  - `domain/`: Pure Dart entities and repository contracts.
  - `presentation/`: Views, ViewModels (ChangeNotifier Providers), and modular UI widgets.
- Primary State Management: `Provider` (`ChangeNotifierProvider`, `Consumer`, `Selector`).
- Dependency Injection: `GetIt` (`sl`).
- Local Persistence: `sqflite` for relational entities and `SharedPreferences` for settings.

## 4. UI, Theming & Viewport Safety Rules
- Zero Hardcoded Colors: Resolve all colors dynamically through `Theme.of(context).colorScheme`.
- Unique Hero Tags: Explicitly define unique `heroTag` strings on every `FloatingActionButton` across all views.
- Landscape 360dp Viewport Safety:
  - Transition bottom navigation to a compact `NavigationRail` (`minWidth: 56`, no bulky headers).
  - Use compact `AppBar` with `toolbarHeight: 36`.
  - Implement two-pane master-detail screens with independent vertical `SingleChildScrollView` controllers.
  - In grids, specify explicit `mainAxisExtent: 145` rather than fragile aspect ratios.
- Keyboard Handling: Wrap root in an unfocusing `GestureDetector` and use `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag`. Avoid double-applying bottom view insets in resizing scaffolds.

## 5. Offline-First & Sub-8ms Performance Engine
- No external paid APIs or Firebase dependencies.
- Use `Dio` with `MockApiInterceptor` backed by `sqflite` and `SharedPreferences`.
- Monitor frame times using `RenderLatencyMonitor` via `SchedulerBinding.addTimingsCallback` to sustain sub-8ms / 120 FPS frame rates.
