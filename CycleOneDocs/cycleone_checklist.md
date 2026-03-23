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
- [ ] **Entities/Models**: Core Data subclasses
- [ ] **Services**:
    - [x] `CycleEngine`: Prediction logic (Averages, Ovulation, Fertile Window)
    - [ ] `NotificationService`: `UserNotifications` (Local only)
    - [ ] `ExportService`: Plain-text/CSV generation
- [x] **ViewModels**: `ObservableObject` classes with `@Published` state
    - [x] `CycleViewModel`
    - [ ] `LogViewModel`
    - [ ] `InsightsViewModel`

## 5. UI Implementation (MVP)
- [x] **Main Navigation**: `TabView` (Calendar, Insights, Settings)
- [/] **Calendar View**:
    - [ ] Color-coded day states (Period, Predicted, Ovulation, Fertile, Today)
    - [x] Header banner with countdown/prediction string
    - [x] Month navigation (Swipe/Chevrons)
    - [x] Log sheet trigger on day tap
- [/] **Log View (Sheet)**:
    - [x] Flow (Segmented), Pain (Slider), Mood/Energy (Icon Pickers)
    - [ ] Symptom Chip Grid (Multi-select)
    - [x] Notes (Text Field, 500 chars)
    - [x] Auto-save on dismiss (`onDisappear`)
    - [ ] Automatic `Cycle` creation logic
- [ ] **Insights View**:
    - [ ] Stats display (Averages, shortest/longest cycle, top symptoms)
    - [ ] Cycle History List (NavigationLink to details)
- [ ] **Settings View**:
    - [ ] Notification toggles (Period, Fertile Window)
    - [ ] Export button with `UIActivityViewController`
    - [ ] App Info (Version, Local Privacy Policy HTML, Rate deep link)
- [ ] **Shared Components**:
    - [ ] `Color+Theme.swift` tokens used (no hardcoded hex)
    - [ ] Accessibility identifiers set on all interactive elements

## 6. Testing Strategy
- [ ] **Unit Tests (`CycleOneTests`)**:
    - [x] `CycleEngine`: Prediction logic (Averages, Ovulation, Fertile Window)
    - [ ] `NotificationService` (Trigger calculation)
    - [ ] `PersistenceController` (CRUD, In-memory store)
- [ ] **UI Tests (`CycleOneUITests`)**:
    - [ ] Navigation flows
    - [ ] Logging flow E2E

## 7. CI/CD & Build Configuration
- [ ] `.github/workflows/ci.yml` configured (macOS-14, Xcode 15.4)
- [ ] `Release` and `Debug` `.xcconfig` files created
- [ ] `#if DEBUG` used for development-only code (e.g. Loggers)

## 8. App Store Readiness
- [ ] `PrivacyInfo.xcprivacy` declaring zero data collection
- [ ] Local Privacy Policy HTML bundled
- [ ] App description/metadata consistent with "local-only" promise
- [ ] Version and build numbers updated
- [ ] App Icons & Screenshots generated
- [ ] Age rating set to 12+
