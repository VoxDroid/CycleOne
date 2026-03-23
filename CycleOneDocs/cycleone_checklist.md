# CycleOne Development Checklist

## Foundation & Tooling
- [x] Configure SwiftLint & SwiftFormat
- [x] Set up pre-commit hooks
- [x] Project structure alignment (App, Core, Views, etc.)
- [x] Makefile for common tasks

## Core Logic (CycleEngine)
- [x] Period prediction (avg of last 3 cycles)
- [x] Ovulation prediction (-14 days from next period)
- [x] Irregularity detection (>10 days variation)
- [x] Outlier filtering (21-45 days valid range)

## Data Persistence (Core Data)
- [x] `DayLog` entity (Date, Flow, Mood, Pain, Energy, Symptoms, Notes)
- [x] `Cycle` entity (StartDate, CycleLength, PeriodLength)
- [x] `Symptom` entity & `SymptomType` enum
- [x] Duplicate prevention logic in `LogViewModel`

## UI Implementation (SwiftUI)
- [x] **Calendar**: Modular `CalendarDayCell` and `CycleHeaderView`
- [x] **Logging**: `LogView` with `FlowPicker` and `SymptomGrid`
- [x] **Insights**: `InsightsView` with `CycleHistoryList`
- [x] **Settings**: Persistence via `@AppStorage`, Export CSV, Delete Data

## Testing & CI
- [x] Unit Tests: `CycleEngineTests`, `PersistenceControllerTests`
- [x] UI Tests: `CalendarViewUITests`, `LogFlowUITests`, `SettingsUITests`
- [x] CI/CD: GitHub Actions with Xcode 16.1

## App Store Readiness
- [x] Privacy Manifest (`PrivacyInfo.xcprivacy`)
- [x] Bundled Privacy Policy
- [x] High-resolution App Icon (1024x1024)

## Advanced Features (Phase 7)
- [x] **Calendar**: Swipable `TabView`, Month/Year Picker
- [x] **Theming**: System/Light/Dark mode switcher
- [x] **Stability**: Fixed layout frames for cards

## Robust Overhaul (Phase 8 & 9)
- [x] **Native Calendar**: `UICalendarView` with decorations
- [x] **Logging Flow**: Navigation-based logging (No modals)
- [x] **Auto-Save**: Automatic persistence on dismiss
- [x] **UX Polish**: Scrollable main screen, energy highlights
- [x] **Stability**: Fixed symptom selection & test suite refinement
