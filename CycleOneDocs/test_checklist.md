# CycleOne Test Checklist

## Current Automated Status (2026-04-01)
- Full suite passes: 99 tests, 0 failures (`TestResults-run9.xcresult`)
- `ThemeManagerTests` pass both in isolation and in the full unit suite
- Coverage from latest stable full run:
  - `CycleOne.app`: 5,076 / 10,235 lines (49.59%)
  - `CycleOneTests.xctest`: 1,799 / 1,817 lines (99.01%)
  - `CycleOneUITests.xctest`: 201 / 229 lines (87.77%)

## Security and Edge-Case Checks (2026-04-01)
- [x] CSV export formula injection mitigation verified (`=`, `+`, `-`, `@` leading values are prefixed safely)
- [x] CSV export quote escaping verified (embedded quotes are doubled per CSV rules)
- [x] Cycle rebuild persistence paths now log Core Data fetch/save errors instead of failing silently
- [x] Log notes are truncated to Core Data max length (500) before save to avoid validation failures

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
