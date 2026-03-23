# CycleOne Comprehensive Project Checklist

This checklist is derived from `project_overview.md` to track the full development lifecycle of CycleOne.

## 1. Project Foundation & Identity
- [x] Bundle ID configured: `com.drei.CycleOne`
- [x] Deployment Target: iOS 16.0+
- [x] Language: Swift 5.9
- [x] UI Framework: SwiftUI
- [x] Persistence: Core Data (on-device, SQLite)
- [x] **NO** Third-party SDKs or dependencies (SPM/CocoaPods/Carthage)
- [x] Privacy-first focus: No accounts, no cloud, no cloud-sync (iCloud disabled)

## 2. Tech Stack & Tooling Setup
- [x] Xcode 15.0+ installed
- [x] Homebrew tools:
    - [x] `swiftlint`
    - [x] `swiftformat`
    - [x] `pre-commit`
- [x] Pre-commit hooks installed (`pre-commit install`)
- [x] Added `Xcode Build` to pre-commit (`.pre-commit-config.yaml`)
- [x] `.swiftlint.yml` created and configured
- [x] `.swiftformat` created and configured
- [x] `Makefile` created for common tasks (`lint`, `format`, `test`, `build`)
- [x] `.gitignore` configured for iOS/macOS/Xcode

## 3. Core Data Architecture
- [x] `PersistenceController` (singleton) implemented
- [x] `CycleOne.xcdatamodeld` defined with:
    - [x] `Cycle` entity (id, startDate, endDate, cycleLength, periodLength, createdAt, notes)
    - [x] `DayLog` entity (id, date, flowLevel, mood, energyLevel, painLevel, notes)
    - [x] `Symptom` entity (id, name, category)
- [x] Relationships configured:
    - [x] `Cycle` (1) <---> (N) `DayLog` (Cascade delete)
    - [x] `DayLog` (1) <---> (N) `Symptom` (Cascade delete)
- [x] Constraints & Indices:
    - [x] Unique constraint on `DayLog.date`
    - [x] `NSMergeByPropertyObjectTrumpMergePolicy` configured
    - [x] Index on `Cycle.startDate` and `DayLog.date`

## 4. MVVM Architecture
- [x] **Entities/Models**: Core Data subclasses
- [x] **Services**:
    - [x] `CycleEngine`: Prediction logic (Averages, Ovulation, Fertile Window)
    - [x] `NotificationService`: `UserNotifications` (Local only)
    - [x] `ExportService`: Plain-text/CSV generation
- [x] **ViewModels**: `ObservableObject` classes with `@Published` state
    - [x] `CycleViewModel`
    - [x] `LogViewModel` (Integrated in views)
    - [x] `InsightsViewModel`

## 5. UI Implementation (MVP)
- [x] **Main Navigation**: `TabView` (Calendar, Insights, Settings)
- [x] **Calendar View**:
    - [x] Color-coded day states (Period, Predicted, Ovulation, Fertile, Today)
    - [x] Header banner with countdown/prediction string
    - [x] Month navigation (Swipe/Chevrons)
    - [x] Log sheet trigger on day tap
- [x] **Log View (Sheet)**:
    - [x] Flow (Segmented), Pain (Slider), Mood/Energy (Icon Pickers)
    - [x] Symptom Chip Grid (Multi-select)
    - [x] Notes (Text Field, 500 chars)
    - [x] Auto-save on dismiss (`onDisappear`)
    - [x] Automatic `Cycle` creation logic
- [x] **Insights View**:
    - [x] Stats display (Averages, shortest/longest cycle, top symptoms)
    - [x] Cycle History List (NavigationLink to details)
- [x] **Settings View**:
    - [x] Notification toggles (Period, Fertile Window)
    - [x] Export button with `UIActivityViewController` (Using `ShareLink`)
    - [x] App Info (Version, Local Privacy Policy HTML, Rate deep link)
- [x] **Shared Components**:
    - [x] `Color+Theme.swift` tokens used (no hardcoded hex)
    - [x] Accessibility identifiers set on all interactive elements

## 6. Testing Strategy
- [x] **Unit Tests (`CycleOneTests`)**:
    - [x] `CycleEngine`: Prediction logic (Averages, Ovulation, Fertile Window)
    - [x] `NotificationService` (Trigger calculation)
    - [x] `PersistenceController` (CRUD, In-memory store)
- [x] **UI Tests (`CycleOneUITests`)**:
    - [x] Navigation flows
    - [x] Logging flow E2E

## 7. CI/CD & Build Configuration
- [x] `.github/workflows/ci.yml` configured (macOS-14, Xcode 15.4)
- [x] `Release` and `Debug` `.xcconfig` files created
- [x] `#if DEBUG` used for development-only code (e.g. Loggers)

## 8. App Store Readiness
- [x] `PrivacyInfo.xcprivacy` declaring zero data collection
- [x] Local Privacy Policy HTML bundled
- [x] App description/metadata consistent with "local-only" promise
- [x] Version and build numbers updated
- [x] App Icons & Screenshots generated (Generated custom Bubu/Dudu icon)
- [ ] Age rating set to 12+ (Requires setting in App Store Connect)
