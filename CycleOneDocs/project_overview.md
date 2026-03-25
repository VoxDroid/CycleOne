# CycleOne — Project Overview
> A privacy-first, one-time-purchase iOS period & cycle tracker.
> No subscriptions. No cloud. No account. Your data stays on your phone — forever.

---

## Table of Contents

1. [Project Identity](#1-project-identity)
2. [Market Opportunity](#2-market-opportunity)
3. [Product Philosophy](#3-product-philosophy)
4. [Tech Stack](#4-tech-stack)
5. [System Architecture](#5-system-architecture)
6. [Project Structure](#6-project-structure)
7. [Data Model](#7-data-model)
8. [Screen Flow & Navigation](#8-screen-flow--navigation)
9. [Feature Specifications (MVP)](#9-feature-specifications-mvp)
10. [Development Environment Setup](#10-development-environment-setup)
11. [Code Style — SwiftLint](#11-code-style--swiftlint)
12. [Code Formatter — SwiftFormat](#12-code-formatter--swiftformat)
13. [Testing Strategy](#13-testing-strategy)
14. [Build Configurations](#14-build-configurations)
15. [Pre-commit Hook](#15-pre-commit-hook)
16. [.gitignore](#16-gitignore)
17. [CI/CD — GitHub Actions](#17-cicd--github-actions)
18. [App Store Submission Checklist](#18-app-store-submission-checklist)
19. [Roadmap (Post-MVP)](#19-roadmap-post-mvp)

---

## 1. Project Identity

| Field | Value |
|---|---|
| App Name | CycleOne |
| Bundle ID | `com.drei.CycleOne` |
| Platform | iOS 16.0+ |
| Language | Swift 5.9 |
| UI Framework | SwiftUI |
| Persistence | Core Data (on-device only) |
| Monetization | One-time purchase — $2.99 USD |
| Backend | None |
| Account required | No |
| Analytics/Tracking | None |
| Third-party SDKs | None |

---

## 2. Market Opportunity

The cycle-tracking app market is dominated by subscription-gated apps that have created a large, vocal base of frustrated users.

- **Flo** — $275M revenue in 2025, 77M active users, $39.99/year or $11.49/month
- **Clue** — subscription-gated premium features
- **Natural Cycles** — $99.99/year FDA-cleared app

The common complaint across all competitors is the same: *"Why am I paying every month just to see my own data?"*

Post-Roe v. Wade privacy concerns created a second wave of users abandoning cloud-connected period trackers. Users do not want their cycle data synced to remote servers or used for ad targeting.

**CycleOne's positioning is surgical:**
- No subscription — ever
- No cloud — ever
- No account — ever
- $2.99 once, use forever

This is not a feature gap. It is a trust gap. You are filling it.

---

## 3. Product Philosophy

### Three Rules That Cannot Be Broken

1. **Data never leaves the device.** No network calls. No analytics. No crash reporting SDKs that phone home. The app has no entitlement for network access in production.
2. **No dark patterns.** No "remind me to upgrade" alerts. No locked screens. No fake loading spinners. The app opens and works immediately.
3. **Scope discipline.** Every feature request gets evaluated against one question: *does this help someone track their cycle?* If the answer is no, it doesn't ship in the MVP.

### What CycleOne Is

A focused, beautiful tool for logging menstrual cycles, predicting future cycles, estimating ovulation windows, and logging daily symptoms — all stored locally on the user's iPhone.

### What CycleOne Is Not

- A fertility monitor (that requires medical device certification)
- A health advice platform
- A social app
- A subscription business

---

## 4. Tech Stack

| Layer | Technology | Reason |
|---|---|---|
| Language | Swift 5.9 | Native performance, SwiftUI compatibility |
| UI | SwiftUI | Declarative, fast to build, looks great |
| Persistence | Core Data | On-device, Apple-native, no dependency |
| Notifications | UserNotifications framework | Local only, no server push |
| Testing | XCTest | Built-in, no extra dependency — `CycleOneTests` (unit) + `CycleOneUITests` (UI) |
| Linting | SwiftLint | Industry standard |
| Formatting | SwiftFormat | Deterministic formatting |
| Version Control | Git + GitHub | Standard |
| CI | GitHub Actions | Free for public repos |
| Build | Xcode 15+ | Required |

**Zero third-party dependencies.** This is intentional. No SPM packages, no CocoaPods, no Carthage. Every feature uses Apple-native frameworks. This means:
- No supply chain risk
- No broken dependencies after Xcode updates
- Faster build times
- Simpler App Store review

---

## 5. System Architecture

### Overview

CycleOne uses a simple, single-target iOS app architecture. There is no backend, no API layer, and no authentication system. The entire data stack runs on-device using Core Data.

```
┌─────────────────────────────────────────────────────────┐
│                      iOS Device                         │
│                                                         │
│   ┌─────────────────────────────────────────────────┐   │
│   │                  SwiftUI Views                  │   │
│   │  CalendarView  │  LogView  │  InsightsView  │   │   │
│   └────────────────────┬────────────────────────────┘   │
│                        │                                │
│   ┌────────────────────▼────────────────────────────┐   │
│   │              ViewModels (ObservableObject)       │   │
│   │   CycleViewModel  │  LogViewModel  │  StatsVM   │   │
│   └────────────────────┬────────────────────────────┘   │
│                        │                                │
│   ┌────────────────────▼────────────────────────────┐   │
│   │                  Services                        │   │
│   │  CycleEngine  │  NotificationService  │  Export  │   │
│   └────────────────────┬────────────────────────────┘   │
│                        │                                │
│   ┌────────────────────▼────────────────────────────┐   │
│   │              Core Data Stack                     │   │
│   │   PersistenceController  (NSPersistentContainer) │   │
│   │   Entities: Cycle │ DayLog │ Symptom              │   │
│   └────────────────────┬────────────────────────────┘   │
│                        │                                │
│   ┌────────────────────▼────────────────────────────┐   │
│   │           SQLite (on-device only)                │   │
│   │   ~/Library/Application Support/CycleOne.sqlite  │   │
│   └─────────────────────────────────────────────────┘   │
│                                                         │
│   ┌─────────────────────────────────────────────────┐   │
│   │       Local Notifications (UNUserNotification)   │   │
│   │    Period reminder  │  Ovulation window alert     │   │
│   └─────────────────────────────────────────────────┘   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

#### SwiftUI Views
Pure UI layer. Views observe ViewModels via `@StateObject` and `@ObservedObject`. Views contain zero business logic. They render state and forward user actions to ViewModels.

#### ViewModels
`ObservableObject` classes that hold `@Published` state. They call Services for computation and Core Data for persistence. They never reference UIKit. They never make network calls.

#### Services
Stateless or lightly stateful pure-Swift classes. Business logic lives here, not in ViewModels or Views.

- `CycleEngine` — predicts next period, ovulation window, fertile days based on logged cycles
- `NotificationService` — schedules and cancels local UNNotificationRequests
- `ExportService` — generates a plain text or CSV export of cycle history (in-memory, shared via UIActivityViewController)

#### Core Data Stack
A single `PersistenceController` (singleton) holds the `NSPersistentContainer`. All saves happen on the main context for simplicity at MVP scale. The SQLite store is in the app's sandboxed Application Support directory. iCloud sync is explicitly disabled — this is a privacy feature.

#### Local Notifications
Scheduled by `NotificationService` using `UNUserNotificationCenter`. All triggers are `UNCalendarNotificationTrigger` (date-based). No push notification capability is required or requested.

### Data Flow Pattern

```
User taps "Log period start"
        │
        ▼
  LogView.onTapGesture
        │
        ▼
  LogViewModel.logPeriodStart(date:)
        │
        ▼
  PersistenceController.save(cycle: newCycle)
        │
        ▼
  Core Data writes to SQLite
        │
        ▼
  CycleEngine.recalculate(from: allCycles)
        │
        ▼
  CycleViewModel.nextPeriodDate updated (@Published)
        │
        ▼
  CalendarView re-renders predicted days
        │
        ▼
  NotificationService.reschedule(nextPeriod: date)
```

---

## 6. Project Structure

```
CycleOne/
├── CycleOne.xcodeproj/
│   └── project.pbxproj
│
├── CycleOne/                          # App target
│   ├── App/
│   │   ├── CycleOneApp.swift          # @main entry point
│   │   └── AppDelegate.swift          # Minimal — notification delegate only
│   │
│   ├── Core/
│   │   ├── Persistence/
│   │   │   ├── PersistenceController.swift
│   │   │   └── CycleOne.xcdatamodeld/ # Core Data model
│   │   │       └── CycleOne.xcdatamodel/
│   │   │           └── contents
│   │   │
│   │   ├── Models/                    # NSManagedObject subclasses
│   │   │   ├── Cycle+CoreDataClass.swift
│   │   │   ├── Cycle+CoreDataProperties.swift
│   │   │   ├── DayLog+CoreDataClass.swift
│   │   │   ├── DayLog+CoreDataProperties.swift
│   │   │   ├── Symptom+CoreDataClass.swift
│   │   │   └── Symptom+CoreDataProperties.swift
│   │   │
│   │   └── Extensions/
│   │       ├── Date+Extensions.swift
│   │       ├── Color+Theme.swift
│   │       └── View+Extensions.swift
│   │
│   ├── Services/
│   │   ├── CycleEngine.swift          # Prediction logic
│   │   ├── NotificationService.swift  # Local notification scheduling
│   │   └── ExportService.swift        # CSV / text export
│   │
│   ├── ViewModels/
│   │   ├── CycleViewModel.swift       # Calendar + prediction state
│   │   ├── LogViewModel.swift         # Day logging state
│   │   └── InsightsViewModel.swift    # Statistics + averages
│   │
│   ├── Views/
│   │   ├── Calendar/
│   │   │   ├── CalendarView.swift     # Main calendar screen
│   │   │   ├── CalendarDayCell.swift  # Individual day cell
│   │   │   └── CycleHeaderView.swift  # "Next period in X days" banner
│   │   │
│   │   ├── Log/
│   │   │   ├── LogView.swift          # Daily log entry sheet
│   │   │   ├── FlowPickerView.swift   # Light/medium/heavy selector
│   │   │   └── SymptomGridView.swift  # Symptom chip grid
│   │   │
│   │   ├── Insights/
│   │   │   ├── InsightsView.swift     # Stats overview
│   │   │   └── CycleHistoryList.swift # Past cycles list
│   │   │
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift
│   │   │   ├── NotificationSettingsView.swift
│   │   │   └── ExportView.swift
│   │   │
│   │   └── Shared/
│   │       ├── PillBadge.swift
│   │       ├── PhaseIndicator.swift
│   │       └── EmptyStateView.swift
│   │
│   ├── Resources/
│   │   ├── Assets.xcassets/
│   │   ├── Localizable.strings        # en only at MVP
│   │   └── Info.plist
│   │
│   └── Supporting/
│       └── PrivacyInfo.xcprivacy      # Required for App Store — no data collected
│
├── CycleOneTests/                     # Unit test target
│   ├── CycleEngineTests.swift
│   ├── NotificationServiceTests.swift
│   ├── PersistenceControllerTests.swift
│   └── Helpers/
│       └── TestPersistenceController.swift  # In-memory Core Data for tests
│
├── CycleOneUITests/                   # UI test target
│   ├── CalendarViewUITests.swift
│   ├── LogFlowUITests.swift
│   └── SettingsUITests.swift
│
├── .swiftlint.yml
├── .swiftformat
├── .gitignore
├── .pre-commit-config.yaml
├── Makefile
├── README.md
└── project_overview.md                # This file
```

---

## 7. Data Model

### Core Data Entities

#### `Cycle`
Represents a single menstrual cycle — from the start of one period to the start of the next.

| Attribute | Type | Notes |
|---|---|---|
| `id` | UUID | Primary key. Set on creation. |
| `startDate` | Date | First day of period. Required. |
| `endDate` | Date? | Last day of period. Optional — user may not log end. |
| `cycleLength` | Int16 | Days from this start to next start. Computed on next cycle entry. |
| `periodLength` | Int16 | Days of active bleeding. Computed from endDate − startDate. |
| `createdAt` | Date | Timestamp of record creation. |
| `notes` | String? | Optional free-text note. |

Relationship: `Cycle` has many `DayLog` (one per day of the cycle).

#### `DayLog`
A log entry for a single calendar day. One per day maximum.

| Attribute | Type | Notes |
|---|---|---|
| `id` | UUID | Primary key. |
| `date` | Date | The calendar day. Unique constraint. |
| `flowLevel` | Int16 | 0 = none, 1 = spotting, 2 = light, 3 = medium, 4 = heavy |
| `mood` | Int16 | 0 = not set, 1 = happy, 2 = neutral, 3 = sad, 4 = irritable, 5 = anxious |
| `energyLevel` | Int16 | 0 = not set, 1 = low, 2 = medium, 3 = high |
| `painLevel` | Int16 | 0–10 scale. 0 = not set. |
| `notes` | String? | Optional free-text. |

Relationship: `DayLog` has many `Symptom`. `DayLog` belongs to one `Cycle`.

#### `Symptom`
A symptom tag logged on a given day.

| Attribute | Type | Notes |
|---|---|---|
| `id` | UUID | Primary key. |
| `name` | String | e.g. "cramps", "headache", "bloating", "tender breasts", "acne", "fatigue", "nausea" |
| `category` | String | "physical", "emotional", "digestive" |

Relationship: `Symptom` belongs to one `DayLog`.

### Constraints

- `DayLog.date` has a unique constraint in the Core Data model to prevent duplicate entries for the same day.
- All entities have `id: UUID` as the merge policy key, using `NSMergeByPropertyObjectTrumpMergePolicy`.
- Cascade delete: deleting a `Cycle` deletes all its `DayLog` records, which deletes all their `Symptom` records.

### Indices

- `Cycle.startDate` — indexed for sort performance
- `DayLog.date` — indexed for O(1) lookup by date

---

## 8. Screen Flow & Navigation

```
App Launch
    │
    ▼
ContentView (TabView)
    ├── Tab 1: CalendarView            ← Default tab
    │       │
    │       └── [Tap day] → LogView (NavigationLink)
    │                   │
    │                   └── SymptomGridView (inline in form)
    │
    ├── Tab 2: InsightsView
    │       │
    │       └── CycleHistoryList (NavigationLink)
    │
    └── Tab 3: SettingsView
            ├── NotificationSettingsView (NavigationLink)
            └── ExportView (NavigationLink)
```

### Navigation Rules

- The app uses a `TabView` with three tabs. No nested navigation stacks except inside Calendar (log flow), Insights (history list) and Settings.
- `LogView` is a navigation destination presented from the calendar via `NavigationLink`.
- There is no onboarding flow at MVP. The calendar screen is the first screen the user sees on first launch.
- A lightweight first-launch tip overlay (shown once, dismissed by tapping anywhere) explains the three main actions: tap a day to log, swipe months to navigate, check the header for your next predicted period.

---

## 9. Feature Specifications (MVP)

### 9.1 Calendar View

**Purpose:** The home screen. Shows the current month with color-coded days.

**Day states (UICalendarView decorations):**
- Period day (logged) — rose/red circle decoration
- Predicted period day — gray dot decoration
- Ovulation day (estimated) — teal dot decoration
- Fertile window day — light teal dot decoration
- Today — standard native selection/today outline
- Logged (symptom/mood only, no flow) — small dot indicator
- Future days — default, no fill

**Header Banner:**
- Shows "Your next period is in X days" or "Your period is expected today"
- Shows "Ovulation window: in Y days" as a secondary line
- If fewer than 2 cycles are logged, shows "Log your first period to see predictions"

**Interactions:**
- Tap any day → opens `LogView` for that day
- Swipe left/right to navigate months
- Pull-to-refresh is not relevant (no network). Month navigation is via chevron buttons or swipe gesture.

### 9.2 Log View

**Purpose:** Log data for a selected day.

**Sections:**
1. **Flow** — segmented control: None / Spotting / Light / Medium / Heavy
2. **Pain** — horizontal slider 0–10 with emoji anchors (😌 at 0, 😣 at 10)
3. **Mood** — icon picker: happy / neutral / sad / irritable / anxious
4. **Energy** — icon picker: low / medium / high
5. **Symptoms** — chip grid, multi-select. Preset symptoms:
   - Physical: Cramps, Headache, Bloating, Tender breasts, Acne, Fatigue, Back pain, Nausea
   - Emotional: Mood swings, Anxiety, Low libido, Crying
   - Digestive: Diarrhea, Constipation
6. **Notes** — optional text field, plain text, max 500 characters

**Save behavior:**
- Auto-saves on view dismiss (no explicit "Save" button needed — use `onDisappear` on the ViewModel)
- If it is the first day of a new cycle (user sets flow > 0 on a day with no recent period), a new `Cycle` record is created automatically

**Period start / end detection logic:**
- When a user logs any flow level > 0, the app checks if there is an open `Cycle` (no end date, started within the last 14 days). If yes, this day is added to that cycle. If no, a new cycle is started.
- When a user logs flow level = 0 on a day after a period started, the app marks the previous period's last bleeding day as the period end.

### 9.3 Cycle Prediction Engine (`CycleEngine`)

**Input:** Array of all `Cycle` records with known `cycleLength`.

**Algorithm (MVP — keep it simple and honest):**
1. Require a minimum of 1 logged cycle to show any prediction.
2. Calculate average cycle length from the last 3 cycles (or however many exist if fewer than 3).
3. Next period predicted start = last period start date + average cycle length.
4. Period length prediction = average of last 3 period lengths (default to 5 days if only 1 cycle logged).
5. Ovulation estimated day = next period start − 14 days (standard luteal phase assumption).
6. Fertile window = ovulation day − 5 days to ovulation day + 1 day.

**Important disclaimer:** The app shows a small "ⓘ Predictions are estimates only. Not medical advice." label below the header banner at all times. This is both legally prudent and Apple App Review friendly.

**Edge cases:**
- If cycle lengths vary by more than 10 days, show "Your cycles are irregular — predictions may be less accurate."
- If no cycles logged: show onboarding prompt only.
- Minimum 21-day, maximum 45-day cycle length accepted. Values outside this range are flagged with a gentle note.

### 9.4 Insights View

**Stats shown:**
- Average cycle length (last 6 cycles)
- Average period length (last 6 cycles)
- Shortest cycle / Longest cycle
- Most common symptoms (top 3)
- Cycle count total

**Cycle History List:**
- Each cycle as a row: "Cycle starting [Month Day, Year] — X days"
- Tap a cycle row to see its logged days and symptoms in a detail view

### 9.5 Settings View

**Notification Settings:**
- Toggle: "Remind me before my period" — off by default, user must opt in
- Picker: How many days before? (1 / 2 / 3 / 5 days)
- Toggle: "Remind me about my fertile window" — off by default
- Notification permission request is shown only when user first enables a toggle (not on app launch)

**Export:**
- "Export my data" button → generates a plain text file listing all cycles and symptoms
- Shared via `UIActivityViewController` (user's choice: AirDrop, Files, Notes, etc.)
- Export is plaintext only — no proprietary format, no lock-in

**App Info:**
- Version number
- "Privacy Policy" — taps open a local HTML file bundled in the app (no external URL needed, no network)
- "Rate CycleOne" — deep links to App Store review page
- "Made with ❤️ by [Your Name]"

---

## 10. Development Environment Setup

### Prerequisites

| Tool | Version |
|---|---|
| macOS | Sonoma 14.0+ |
| Xcode | 15.0+ |
| Swift | 5.9+ |
| Git | Any recent version |
| Homebrew | For installing tools |

### Initial Setup

```bash
# 1. Clone the repo
git clone https://github.com/VoxDroid/cycleone.git
cd cycleone

# 2. Install tooling via Homebrew
brew install swiftlint
brew install swiftformat
brew install pre-commit

# 3. Install pre-commit hooks
pre-commit install

# 4. Open in Xcode
open CycleOne.xcodeproj
```

### Makefile

A `Makefile` at the project root wraps common tasks:

```makefile
# Makefile

.PHONY: lint format test clean build

# Run SwiftLint and report violations
lint:
	swiftlint lint --config .swiftlint.yml

# Run SwiftLint with autocorrect
lint-fix:
	swiftlint --fix --config .swiftlint.yml

# Run SwiftFormat
format:
	swiftformat . --config .swiftformat

# Run all unit tests (no simulator — use xcodebuild)
test:
	xcodebuild test \
		-project CycleOne.xcodeproj \
		-scheme CycleOne \
		-destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
		-resultBundlePath TestResults.xcresult \
		| xcpretty

# Run UI tests
test-ui:
	xcodebuild test \
		-project CycleOne.xcodeproj \
		-scheme CycleOneUITests \
		-destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
		| xcpretty

# Build release archive (for distribution)
build:
	xcodebuild archive \
		-project CycleOne.xcodeproj \
		-scheme CycleOne \
		-configuration Release \
		-archivePath build/CycleOne.xcarchive

# Clean derived data
clean:
	rm -rf ~/Library/Developer/Xcode/DerivedData/CycleOne-*
	rm -rf build/

# Run lint + format + test in one shot (use before committing)
check: lint format test
	@echo "All checks passed."
```

---

## 11. Code Style — SwiftLint

Create `.swiftlint.yml` at the project root:

```yaml
# .swiftlint.yml

# ── Paths ──────────────────────────────────────────────────────────────────
included:
  - CycleOne
  - CycleOneTests
  - CycleOneUITests

excluded:
  - CycleOne/Resources
  - CycleOne/Core/Models  # Core Data generated files — skip linting
  - Pods
  - .build

# ── Rules — disabled ───────────────────────────────────────────────────────
disabled_rules:
  - trailing_whitespace          # SwiftFormat handles this
  - todo                         # TODOs are fine during active development
  - opening_brace                # SwiftFormat handles brace style

# ── Rules — opt-in ─────────────────────────────────────────────────────────
opt_in_rules:
  - array_init
  - closure_spacing
  - collection_alignment
  - contains_over_filter_count
  - contains_over_filter_is_empty
  - contains_over_first_not_nil
  - contains_over_range_nil_comparison
  - empty_collection_literal
  - empty_count
  - empty_string
  - enum_case_associated_values_count
  - explicit_init
  - extension_access_modifier
  - fallthrough
  - fatal_error_message
  - file_header
  - first_where
  - flatmap_over_map_reduce
  - force_unwrapping
  - identical_operands
  - joined_default_parameter
  - last_where
  - legacy_multiple
  - literal_expression_end_indentation
  - lower_acl_than_parent
  - modifier_order
  - multiline_arguments
  - multiline_function_chains
  - multiline_literal_brackets
  - multiline_parameters
  - operator_usage_whitespace
  - optional_enum_case_matching
  - overridden_super_call
  - prefer_self_type_over_type_of_self
  - redundant_nil_coalescing
  - redundant_type_annotation
  - strict_fileprivate
  - toggle_bool
  - unavailable_function
  - unneeded_parentheses_in_closure_argument
  - untyped_error_in_catch
  - vertical_whitespace_between_cases
  - vertical_whitespace_closing_braces
  - yoda_condition

# ── Rule configuration ─────────────────────────────────────────────────────
line_length:
  warning: 120
  error: 160
  ignores_comments: true
  ignores_urls: true

file_length:
  warning: 400
  error: 600

type_body_length:
  warning: 250
  error: 350

function_body_length:
  warning: 40
  error: 60

function_parameter_count:
  warning: 5
  error: 8

type_name:
  min_length: 3
  max_length: 50

identifier_name:
  min_length:
    warning: 2
  excluded:
    - id
    - x
    - y

cyclomatic_complexity:
  warning: 10
  error: 20

nesting:
  type_level:
    warning: 2
  function_level:
    warning: 3

force_cast: error
force_try: error

# ── Custom rules ───────────────────────────────────────────────────────────
custom_rules:
  no_print_in_release:
    name: "No print statements"
    regex: '^\s*print\('
    message: "Use Logger (os.log) instead of print(). Remove before shipping."
    severity: warning

  no_hardcoded_colors:
    name: "No hardcoded hex colors"
    regex: 'Color\(hex:'
    message: "Use Color+Theme.swift tokens instead of hardcoded hex values."
    severity: warning

  no_uikit_import_in_views:
    name: "No UIKit in SwiftUI Views"
    regex: 'import UIKit'
    included: ".*Views/.*\\.swift"
    message: "SwiftUI views should not import UIKit directly."
    severity: warning
```

### How to run

```bash
# Check for violations (no autofix)
make lint

# Autofix what can be fixed automatically
make lint-fix
```

---

## 12. Code Formatter — SwiftFormat

Create `.swiftformat` at the project root:

```
# .swiftformat

# ── Version ─────────────────────────────────────────────────────────────────
--swiftversion 5.9

# ── Indentation ──────────────────────────────────────────────────────────────
--indent 4
--indentcase false
--ifdef indent

# ── Line length ──────────────────────────────────────────────────────────────
--maxwidth 120

# ── Braces ───────────────────────────────────────────────────────────────────
--allman false
--elseOnSameLine always

# ── Spacing ──────────────────────────────────────────────────────────────────
--trimwhitespace always
--insertlines enabled
--removelines enabled
--emptybraces no-space

# ── Imports ──────────────────────────────────────────────────────────────────
--importgrouping alpha

# ── Self ─────────────────────────────────────────────────────────────────────
--self insert
--selfrequired

# ── Types ────────────────────────────────────────────────────────────────────
--shortoptionals always
--typedelimiter spaced

# ── Closures ─────────────────────────────────────────────────────────────────
--trailingclosures always
--nospaceoperators ...,..<

# ── Comments ─────────────────────────────────────────────────────────────────
--comments indent

# ── Disable rules that conflict with SwiftLint ──────────────────────────────
--disable redundantSelf
--disable unusedArguments
```

### How to run

```bash
# Format all Swift files in place
make format

# Dry run (see what would change without writing)
swiftformat . --config .swiftformat --dryrun
```

---

## 13. Testing Strategy

### Philosophy

Test the logic, not the framework. SwiftUI views are not unit-tested. Core Data models are not unit-tested in isolation. The things we test are the things that can be wrong without the compiler catching it:
- Cycle prediction math
- Date calculations
- Core Data save/fetch/delete
- Notification scheduling logic

### Test Targets

| Target | Type | What it covers |
|---|---|---|
| `CycleOneTests` | Unit | CycleEngine, NotificationService, Persistence |
| `CycleOneUITests` | UI / Integration | Critical user flows end-to-end |

### In-Memory Core Data for Tests

All tests that touch Core Data use an in-memory store. This avoids writing to disk, is faster, and is isolated between test runs.

```swift
// CycleOneTests/Helpers/TestPersistenceController.swift

import CoreData
@testable import CycleOne

final class TestPersistenceController {
    static let shared = TestPersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "CycleOne")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func reset() {
        let context = container.viewContext
        let entities = container.managedObjectModel.entities
        for entity in entities {
            guard let name = entity.name else { continue }
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try? context.execute(deleteRequest)
        }
        try? context.save()
    }
}
```

### Unit Test Files

#### `CycleEngineTests.swift`

```swift
// CycleOneTests/CycleEngineTests.swift

import XCTest
@testable import CycleOne

final class CycleEngineTests: XCTestCase {
    var engine: CycleEngine!

    override func setUp() {
        super.setUp()
        engine = CycleEngine()
    }

    override func tearDown() {
        engine = nil
        super.tearDown()
    }

    // MARK: - Next period prediction

    func testPredictNextPeriod_withOneCycle_returnsStartPlusLength() {
        let start = makeDate(year: 2024, month: 1, day: 1)
        let cycles = [makeCycle(start: start, length: 28)]

        let predicted = engine.predictNextPeriodStart(from: cycles)

        let expected = makeDate(year: 2024, month: 1, day: 29)
        XCTAssertEqual(predicted, expected)
    }

    func testPredictNextPeriod_withThreeCycles_usesAverage() {
        let cycles = [
            makeCycle(start: makeDate(year: 2024, month: 1, day: 1), length: 28),
            makeCycle(start: makeDate(year: 2024, month: 1, day: 29), length: 30),
            makeCycle(start: makeDate(year: 2024, month: 2, day: 28), length: 26),
        ]

        let predicted = engine.predictNextPeriodStart(from: cycles)

        // Average = (28+30+26)/3 = 28. Last start = Feb 28. Expected = Mar 27.
        let expected = makeDate(year: 2024, month: 3, day: 27)
        XCTAssertEqual(predicted, expected)
    }

    func testPredictNextPeriod_withNoCycles_returnsNil() {
        let predicted = engine.predictNextPeriodStart(from: [])
        XCTAssertNil(predicted)
    }

    func testPredictNextPeriod_usesLastThreeCyclesOnly() {
        let cycles = [
            makeCycle(start: makeDate(year: 2023, month: 6, day: 1), length: 50), // outlier, should be ignored
            makeCycle(start: makeDate(year: 2024, month: 1, day: 1), length: 28),
            makeCycle(start: makeDate(year: 2024, month: 1, day: 29), length: 28),
            makeCycle(start: makeDate(year: 2024, month: 2, day: 26), length: 28),
        ]

        let predicted = engine.predictNextPeriodStart(from: cycles)

        let expected = makeDate(year: 2024, month: 3, day: 25)
        XCTAssertEqual(predicted, expected)
    }

    // MARK: - Ovulation prediction

    func testOvulationDate_is14DaysBeforeNextPeriod() {
        let nextPeriod = makeDate(year: 2024, month: 3, day: 1)
        let ovulation = engine.estimatedOvulationDate(nextPeriodStart: nextPeriod)

        let expected = makeDate(year: 2024, month: 2, day: 16)
        XCTAssertEqual(ovulation, expected)
    }

    // MARK: - Fertile window

    func testFertileWindow_is6DaysEndingOnOvulationPlusOne() {
        let ovulation = makeDate(year: 2024, month: 2, day: 16)
        let window = engine.fertileWindow(ovulationDate: ovulation)

        XCTAssertEqual(window.count, 6)
        XCTAssertEqual(window.first, makeDate(year: 2024, month: 2, day: 11))
        XCTAssertEqual(window.last, makeDate(year: 2024, month: 2, day: 16))
    }

    // MARK: - Irregularity detection

    func testIrregularCycles_whenVarianceOver10Days_flaggedAsIrregular() {
        let cycles = [
            makeCycle(start: makeDate(year: 2024, month: 1, day: 1), length: 21),
            makeCycle(start: makeDate(year: 2024, month: 1, day: 22), length: 35),
        ]

        XCTAssertTrue(engine.cyclesAreIrregular(cycles))
    }

    func testRegularCycles_whenVarianceUnder10Days_notFlagged() {
        let cycles = [
            makeCycle(start: makeDate(year: 2024, month: 1, day: 1), length: 28),
            makeCycle(start: makeDate(year: 2024, month: 1, day: 29), length: 30),
        ]

        XCTAssertFalse(engine.cyclesAreIrregular(cycles))
    }

    // MARK: - Helpers

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)!
    }

    private func makeCycle(start: Date, length: Int) -> CycleSnapshot {
        CycleSnapshot(startDate: start, cycleLength: length, periodLength: 5)
    }
}
```

> **Note:** `CycleSnapshot` is a plain Swift value type (struct) that `CycleEngine` operates on. The engine should not take `NSManagedObject` directly — this keeps it testable without Core Data.

#### `PersistenceControllerTests.swift`

```swift
// CycleOneTests/PersistenceControllerTests.swift

import XCTest
import CoreData
@testable import CycleOne

final class PersistenceControllerTests: XCTestCase {
    var controller: PersistenceController!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        controller = PersistenceController(inMemory: true)
        context = controller.container.viewContext
    }

    override func tearDown() {
        context = nil
        controller = nil
        super.tearDown()
    }

    func testSaveCycle_persistsStartDate() throws {
        let cycle = Cycle(context: context)
        cycle.id = UUID()
        cycle.startDate = Date()
        cycle.createdAt = Date()

        try context.save()

        let request = Cycle.fetchRequest()
        let results = try context.fetch(request)

        XCTAssertEqual(results.count, 1)
        XCTAssertNotNil(results.first?.startDate)
    }

    func testDeleteCycle_cascadeDeletesDayLogs() throws {
        let cycle = Cycle(context: context)
        cycle.id = UUID()
        cycle.startDate = Date()
        cycle.createdAt = Date()

        let log = DayLog(context: context)
        log.id = UUID()
        log.date = Date()
        log.cycle = cycle

        try context.save()

        context.delete(cycle)
        try context.save()

        let logRequest = DayLog.fetchRequest()
        let logs = try context.fetch(logRequest)
        XCTAssertEqual(logs.count, 0, "Cascade delete should remove DayLogs when Cycle is deleted")
    }

    func testDayLogUniqueConstraint_preventsDuplicatesForSameDate() throws {
        let date = Date()

        let log1 = DayLog(context: context)
        log1.id = UUID()
        log1.date = date

        let log2 = DayLog(context: context)
        log2.id = UUID()
        log2.date = date

        // With merge policy set to NSMergeByPropertyObjectTrumpMergePolicy,
        // saving two logs on the same date should resolve to one record.
        try context.save()

        let request = DayLog.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", date as NSDate)
        let results = try context.fetch(request)

        XCTAssertLessThanOrEqual(results.count, 1)
    }
}
```

#### `NotificationServiceTests.swift`

```swift
// CycleOneTests/NotificationServiceTests.swift

import XCTest
import UserNotifications
@testable import CycleOne

final class NotificationServiceTests: XCTestCase {
    var service: NotificationService!

    override func setUp() {
        super.setUp()
        service = NotificationService()
    }

    func testScheduleNotification_setsCorrectTriggerDate() async {
        let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        let daysBefore = 2

        let trigger = service.buildTrigger(for: futureDate, daysBefore: daysBefore)

        let expectedDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: futureDate)!
        let expectedComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: expectedDate)

        XCTAssertEqual(trigger.dateComponents.day, expectedComponents.day)
        XCTAssertEqual(trigger.dateComponents.month, expectedComponents.month)
    }

    func testNotificationIdentifiers_areConsistentForSameDate() {
        let date = Date()
        let id1 = service.notificationID(for: date, type: .periodReminder)
        let id2 = service.notificationID(for: date, type: .periodReminder)
        XCTAssertEqual(id1, id2)
    }
}
```

### UI Test Files

#### `LogFlowUITests.swift`

```swift
// CycleOneUITests/LogFlowUITests.swift

import XCTest

final class LogFlowUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-data"]
        app.launch()
    }

    func testTappingCalendarDayOpensLogSheet() {
        let todayCell = app.buttons["CalendarDay_today"]
        XCTAssertTrue(todayCell.waitForExistence(timeout: 3))
        todayCell.tap()

        let logSheet = app.otherElements["LogView"]
        XCTAssertTrue(logSheet.waitForExistence(timeout: 2))
    }

    func testLoggingFlowSavesAndReflectsOnCalendar() {
        app.buttons["CalendarDay_today"].tap()

        let mediumButton = app.buttons["FlowPicker_medium"]
        XCTAssertTrue(mediumButton.waitForExistence(timeout: 2))
        mediumButton.tap()

        app.swipeDown() // Dismiss sheet

        // Calendar day should now show period indicator
        let todayCell = app.buttons["CalendarDay_today"]
        XCTAssertTrue(todayCell.isSelected || todayCell.value as? String == "period")
    }
}
```

> **Note:** Accessibility identifiers like `"CalendarDay_today"`, `"LogView"`, and `"FlowPicker_medium"` must be set on corresponding SwiftUI views via `.accessibilityIdentifier()`. Add these when building views.

---

## 14. Build Configurations

### Xcode Schemes

| Scheme | Configuration | Use |
|---|---|---|
| `CycleOne` | Debug | Day-to-day development |
| `CycleOneRelease` | Release | App Store submission |
| `CycleOneTests` | Debug | Unit test runs |

### User-Defined Build Settings

Add these in your `.xcconfig` files (create `Configurations/` directory):

**`Debug.xcconfig`**
```
// Debug.xcconfig
SWIFT_OPTIMIZATION_LEVEL = -Onone
SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG
GCC_PREPROCESSOR_DEFINITIONS = DEBUG=1
ENABLE_TESTABILITY = YES
DEBUG_INFORMATION_FORMAT = dwarf
```

**`Release.xcconfig`**
```
// Release.xcconfig
SWIFT_OPTIMIZATION_LEVEL = -O
SWIFT_ACTIVE_COMPILATION_CONDITIONS =
GCC_PREPROCESSOR_DEFINITIONS =
ENABLE_TESTABILITY = NO
DEBUG_INFORMATION_FORMAT = dwarf-with-dsym
DEAD_CODE_STRIPPING = YES
STRIP_INSTALLED_PRODUCT = YES
```

### Conditional Compilation

Use `#if DEBUG` for anything that should only run in development:

```swift
#if DEBUG
import OSLog
let logger = Logger(subsystem: "com.drei.CycleOne", category: "debug")
#endif
```

---

## 15. Pre-commit Hook

### Setup

Install `pre-commit`:
```bash
brew install pre-commit
pre-commit install
```

### `.pre-commit-config.yaml`

```yaml
# .pre-commit-config.yaml

repos:
  # ── SwiftLint ──────────────────────────────────────────────────────────────
  - repo: local
    hooks:
      - id: swiftlint
        name: SwiftLint
        language: system
        entry: swiftlint lint --config .swiftlint.yml --strict
        types: [swift]
        pass_filenames: false

  # ── SwiftFormat ────────────────────────────────────────────────────────────
  - repo: local
    hooks:
      - id: swiftformat
        name: SwiftFormat
        language: system
        entry: swiftformat --config .swiftformat
        types: [swift]
        pass_filenames: true

  # ── Trailing whitespace ────────────────────────────────────────────────────
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
        exclude: '\.md$'
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-merge-conflict
      - id: check-added-large-files
        args: ['--maxkb=500']
      - id: mixed-line-ending
        args: ['--fix=lf']

  # ── Secrets detection ──────────────────────────────────────────────────────
  # Prevents accidentally committing API keys or credentials.
  # CycleOne has no secrets, but this is good hygiene.
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
```

### Bypass (emergency only)

```bash
# Skip hooks for a single commit — use sparingly
git commit --no-verify -m "your message"
```

---

## 16. .gitignore

```gitignore
# .gitignore — CycleOne iOS Project

# ── macOS ──────────────────────────────────────────────────────────────────
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# ── Xcode ──────────────────────────────────────────────────────────────────
build/
DerivedData/
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
xcuserdata/
*.xccheckout
*.moved-aside
*.xcuserstate
*.xcscmblueprint

# ── Xcode Previews ─────────────────────────────────────────────────────────
**/__Previews/

# ── Swift Package Manager ──────────────────────────────────────────────────
# (No external packages in this project, but good to have)
.build/
.swiftpm/
*.resolved

# ── CocoaPods ──────────────────────────────────────────────────────────────
# (Not used — kept for safety if ever adopted)
Pods/
Podfile.lock

# ── Carthage ───────────────────────────────────────────────────────────────
Carthage/Build/

# ── Archives & Exports ─────────────────────────────────────────────────────
*.xcarchive
*.ipa
*.dSYM.zip
*.dSYM

# ── Test Results ───────────────────────────────────────────────────────────
TestResults.xcresult/
*.xcresult

# ── Instruments ────────────────────────────────────────────────────────────
*.trace

# ── Fastlane ───────────────────────────────────────────────────────────────
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output

# ── Environment & Secrets ──────────────────────────────────────────────────
.env
.env.local
.env.*.local
*.p12
*.mobileprovision
AuthKey_*.p8
*.pem

# ── Pre-commit ─────────────────────────────────────────────────────────────
.secrets.baseline

# ── Logs ───────────────────────────────────────────────────────────────────
*.log
npm-debug.log*

# ── Editor / IDE ───────────────────────────────────────────────────────────
.vscode/
.idea/
*.swp
*.swo
*~

# ── Homebrew ───────────────────────────────────────────────────────────────
.brew/
```

---

## 17. CI/CD — GitHub Actions

Create `.github/workflows/ci.yml`:

```yaml
# .github/workflows/ci.yml

name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  lint:
    name: SwiftLint
    runs-on: macos-14
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install SwiftLint
        run: brew install swiftlint

      - name: Run SwiftLint
        run: swiftlint lint --config .swiftlint.yml --strict

  test:
    name: Unit Tests
    runs-on: macos-14
    needs: lint
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.4.app

      - name: Run unit tests
        run: |
          xcodebuild test \
            -project CycleOne.xcodeproj \
            -scheme CycleOne \
            -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5' \
            -resultBundlePath TestResults.xcresult \
            | xcpretty && exit ${PIPESTATUS[0]}

      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results
          path: TestResults.xcresult

  build:
    name: Release Build Check
    runs-on: macos-14
    needs: test
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Build Release
        run: |
          xcodebuild build \
            -project CycleOne.xcodeproj \
            -scheme CycleOne \
            -configuration Release \
            -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5' \
            | xcpretty && exit ${PIPESTATUS[0]}
```

---

## 18. App Store Submission Checklist

Work through this list before submitting to App Store Connect.

### Legal & Privacy

- [ ] `PrivacyInfo.xcprivacy` file is present and declares zero data collection
- [ ] Privacy policy is bundled as a local HTML file (no external URL needed)
- [ ] App description includes "your data never leaves your device"
- [ ] No network entitlement in `CycleOne.entitlements`
- [ ] No `NSAppTransportSecurity` exceptions in `Info.plist`
- [ ] No third-party analytics, crash reporting, or advertising SDKs

### Technical

- [ ] Deployment target is iOS 16.0
- [ ] All device orientations handled (portrait primary, landscape optional)
- [ ] Dark Mode works and looks correct
- [ ] Dynamic Type tested at all accessibility sizes
- [ ] VoiceOver tested — all interactive elements have accessibility labels
- [ ] No `force_cast` violations in release build (`make lint`)
- [ ] No `force_try` violations in release build
- [ ] All unit tests pass (`make test`)
- [ ] Release build compiles clean with zero warnings
- [ ] No `print()` statements in release build (caught by SwiftLint custom rule)

### App Store Connect

- [ ] App icon (1024×1024 PNG, no alpha channel, no rounded corners)
- [ ] Screenshots for all required device sizes:
  - 6.9" (iPhone 16 Pro Max)
  - 6.5" (iPhone 11 Pro Max / 12 Pro Max)
  - 5.5" (iPhone 8 Plus)
  - 12.9" iPad Pro (only if iPad is supported)
- [ ] App preview video (optional but improves conversion)
- [ ] App description (max 4000 characters)
- [ ] Subtitle (max 30 characters) — "Track your cycle. Pay once."
- [ ] Keywords (max 100 characters) — "period tracker, cycle, ovulation, no subscription, private"
- [ ] What's new text for first version (can be brief)
- [ ] Age rating set correctly (12+ for health and reproductive content)
- [ ] Pricing: $2.99 one-time purchase
- [ ] Category: Health & Fitness (primary), Medical (secondary)

### Review Notes for Apple

Include in the "Notes for Reviewer" field in App Store Connect:

> This app is a period and cycle tracker. It stores all user data locally on-device using Core Data and makes no network requests. There is no account, no backend, no analytics, and no advertising. The app requires no special permissions beyond local notifications (which are entirely optional and only requested when the user enables reminders in Settings). The app is fully functional without granting any permissions.

---

## 19. Roadmap (Post-MVP)

These are things deliberately cut from MVP to ship faster. Do not build these until the app is live and earning.

### v1.1 — Quality of Life
- [ ] iCloud sync opt-in (user's explicit choice — they turn it on knowing it leaves device)
- [ ] Widget (Next period in X days) — WidgetKit
- [ ] Apple Watch complication (period count-down)
- [ ] Cycle comparison chart in Insights

### v1.2 — Depth
- [ ] Partner mode — share predictions with a partner via local export (no cloud)
- [ ] Temperature tracking (BBT) for users who track basal body temperature
- [ ] Pill / medication reminders (local only)
- [ ] Custom symptoms (user-defined tags)

### v2.0 — Potential Paid Upgrade
- [ ] If the app earns well, consider a "Pro" one-time IAP (not subscription) for advanced features
- [ ] Cycle analysis with trend charts
- [ ] PDF health report export (for sharing with a doctor)

**Reminder:** The $2.99 price point is the product. Do not bloat the app trying to justify a higher price. Ship lean, get reviews, let word-of-mouth do the work.

---

*Last updated: 2026 · CycleOne — Built lean, priced honest.*
