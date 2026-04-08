# CycleOne Test Checklist

## Current Automated Status (2026-04-08)
- `make check` passes end-to-end.
- `pre-commit run --all-files` passes all hooks.
- Latest run counts:
  - `CycleOneTests.xctest`: 182 tests, 0 failures.
  - `CycleOneUITests.xctest`: 22 tests, 0 failures.
- Coverage from latest merged run (`UnitCoverage.xcresult` + `UICoverage.xcresult`):
  - `CycleOne.app`: 10,893 / 10,893 lines (100.00%)
  - `CycleOneTests.xctest`: 4,298 / 4,316 lines (99.58%)
  - `CycleOneUITests.xctest`: 955 / 962 lines (99.27%)

## Security and Edge-Case Checks (2026-04-02)
- [x] CSV export formula injection mitigation verified (`=`, `+`, `-`, `@` leading values are prefixed safely)
- [x] CSV export quote escaping verified (embedded quotes are doubled per CSV rules)
- [x] Cycle rebuild persistence paths now log Core Data fetch/save errors instead of failing silently
- [x] Log notes are truncated to Core Data max length (500) before save to avoid validation failures
- [x] Privacy policy fallback message path verified for missing bundled HTML resource
- [x] Notification days-before picker rendering path verified for all supported day options
- [x] Delete-log cancel flow verified in UI runtime test
- [x] Cycle comparison empty-state/diff/date helper branches verified
- [x] UITest launch data-reset helper verified against object-ID batch-delete results (no crash path)

## Localization & Internationalization Checks (2026-04-07)
- [x] Localization key parity verified across `en`, `fil`, and `ja`
- [x] Source-to-strings coverage test verifies all user-facing view strings exist in English table
- [x] Language-specific resource checks validate localized Privacy Policy HTML availability
- [x] App language model tests validate stored selection, locale mapping, and localized bundle lookup
- [x] UI language-switch flow validated from Settings (English -> Japanese)
- [x] UI language round-trip validated (Japanese -> English) with translated Calendar legend assertions
- [x] Calendar legend regression check verifies localization keys are never rendered literally in UI
- [x] Locale-sensitive UI tests now prefer accessibility identifiers over display text where practical

## Unit Tests
- [x] `CycleEngine`: Predict next period start
- [x] `CycleEngine`: Predict ovulation date
- [x] `CycleEngine`: Detect irregular cycles
- [x] `CycleEngine`: Filter outliers from average
- [x] `Persistence`: CRUD operations for DayLog and Cycle
- [x] `Persistence`: Cascade deletions (Log -> Symptoms)

## UI Tests
- [x] **Navigation**: Tab switching and deep navigation
- [x] **Logging**: Open log view, log flow/symptoms, and auto-save
- [x] **Insights**: Verify stats calculation and history list
- [x] **Settings**: Toggle predictions and verify persistence
- [x] **Export**: Generate CSV and open share sheet
- [x] **Splash/Onboarding**: Wait for splash dismiss, handle multi-page onboarding (Skip/Get Started)

## Manual Verification
- [x] UI Alignment: Fixed "lowered down" issue via `NavigationStack` refactor
- [x] Persistence: Settings and logs remain after app killed/restarted
- [x] Export: CSV file is valid and contains all logged data
- [x] Disclaimer: Verify "Predictions are estimates only" label visibility
- [x] Onboarding: Multi-page tutorial with 4 steps, page indicators, skip button
- [x] Legend: Verify legend visibility and accuracy on Calendar
- [x] Help: Verify navigation to Help page and content readability
- [x] Splash Screen: Animated logo, gradient ring, sliding title, auto-dismiss
- [x] Animations: Staggered fade-slide on calendar, insights, and log views
- [x] Theme: Gradient headers, gradient buttons, premium card styling
- [x] Logo: Appears in splash screen, onboarding, and settings header
- [x] TestDataSeeder: Removed — no longer seeds test data on launch
- [x] FlowPicker: Verified fix for selection bug and gesture conflict
- [x] Accent Themes: Verified UI updates across all screens when accent color changes
- [x] Delete Log: Verified log and symptom removal from Core Data
- [x] Emojis: Verified zero emojis in Log, Insights, and Settings views
- [x] Splash: Verified exit animation transition
- [x] Insights: Verified reactive refresh on data change
- [x] Charts: Visual verification of trend bars and distribution widths
- [x] Comparison: Verified side-by-side logic for current vs previous
- [x] About: Verified developer links and navigation
- [x] Splash: Verified improved animation sequence and exit effects
