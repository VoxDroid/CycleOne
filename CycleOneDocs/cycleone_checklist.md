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

## Robust Overhaul (Phase 8, 9 & 10)
- [x] **Native Calendar**: `UICalendarView` with red circle decorations
- [x] **Logging Flow**: Navigation-based logging (No modals)
- [x] **Auto-Save**: Automatic persistence on dismiss
- [x] **UX Polish**: Scrollable main screen, energy highlights
- [x] **Stability**: Fixed symptom selection & navigation bugs
- [x] **Onboarding**: Lightweight first-launch tip overlay (Section 8 & 9.1)
- [x] **UI Polish**: Prediction Engine Disclaimer Label (Section 9.3)
- [x] **UI Polish**: Ovulation window line in Header Banner (Section 9.1)

## UX Upgrades (Phase 11)
- [x] **Legend**: Calendar legend for dot decorations
- [x] **Guide**: Dedicated Help & Guide page in Settings
- [x] **Navigation**: Navigation tips and support links

## Premium UI/UX Overhaul (Phase 12)
- [x] **Cleanup**: Removed `TestDataSeeder` from app
- [x] **Theming**: Premium gradient palette & animation constants
- [x] **Splash Screen**: Animated launch with logo, gradient ring, sliding text
- [x] **Onboarding**: Multi-page carousel (4 steps) with skip & page indicators
- [x] **Calendar**: Gradient background, staggered fade-slide animations
- [x] **Header**: Gradient icon, pulsing day counter, gradient border
- [x] **Day Detail**: Gradient buttons, color-coded symptom pills
- [x] **Log View**: Date header, staggered animations, emoji pain anchors
- [x] **Flow Picker**: SF Symbol icons, gradient selection, spring animation
- [x] **Symptoms**: Category icons/colors, spring bounce on selection
- [x] **Insights**: Gradient stat cards, mini variation cards, medal symptoms
- [x] **History**: Timeline-style design, staggered row animations
- [x] **Settings**: Logo header, Apple Settings-style colored icon rows
- [x] **Help**: Guide cards, numbered tips, philosophy items
- [x] **App Logo**: Generated and added to Assets.xcassets
- [x] **Enums**: Added icon/color to `FlowLevel`, `SymptomCategory`

## Phase 13: Theme Refinement & Feature Expansion
- [x] **Bug Fix**: Fixed FlowPicker "stuck on Heavy" bug (`.buttonStyle(.plain)`)
- [x] **Bug Fix**: Fixed invalid SF Symbol in `FlowLevel.heavy` icon
- [x] **UI Cleanup**: Removed all emojis app-wide (replaced with SF Symbols)
- [x] **UI Cleanup**: Removed all gradients in favor of unified accent themes
- [x] **Theming**: Added 5-accent color themes (Rose, Lavender, Ocean, Sage, Sunset)
- [x] **Splash**: Added smooth exit animation (scale-up + fade-out)
- [x] **Assets**: Transitioned to App Icon as the primary app logo
- [x] **Privacy**: Improved Privacy Policy with dark mode & expanded sections
- [x] **Copyright**: Updated footer to "© 2026 CycleOne by VoxDroid"
- [x] **Feature**: Implemented "Delete Log" functionality with confirmation
- [x] **Symptoms**: Expanded symptom list (Mood swings, Irritability, Fatigue, etc.)
- [x] **Charts**: Added Cycle Length Trend bar chart to Insights
- [x] **Analytics**: Added Mood Distribution & Symptom Breakdown visualizations
- [x] **Metrics**: Added Avg Pain Level & Total Logged Days counters
- [x] **Bug Fix**: Fixed stale insights data bug with `NSManagedObjectContextDidSave` refresh logic
- [x] **Splash**: Enhanced with floating animation, ring burst effect, and upward fly-off exit
- [x] **Feature**: Added `CycleComparisonView` for current vs previous cycle analysis
- [x] **Feature**: Added `AboutView` with developer info (VoxDroid), email, and GitHub links
