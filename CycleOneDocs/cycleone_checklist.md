# CycleOne Comprehensive Project Checklist

This checklist is derived from `project_overview.md` to track the full development lifecycle of CycleOne.

## 1. Project Foundation & Identity
- [ ] Bundle ID configured: `com.drei.CycleOne`
- [ ] Deployment Target: iOS 16.0+
- [ ] Language: Swift 5.9
- [ ] UI Framework: SwiftUI
- [ ] Persistence: Core Data (on-device, SQLite)
- [ ] **NO** Third-party SDKs or dependencies (SPM/CocoaPods/Carthage)
- [ ] Privacy-first focus: No accounts, no cloud, no cloud-sync (iCloud disabled)

## 2. Tech Stack & Tooling Setup
- [ ] Xcode 15.0+ installed
- [ ] Homebrew tools:
    - [ ] `swiftlint`
    - [ ] `swiftformat`
    - [ ] `pre-commit`
- [ ] Pre-commit hooks installed (`pre-commit install`)
- [ ] `.swiftlint.yml` created and configured
- [ ] `.swiftformat` created and configured
- [ ] `Makefile` created for common tasks (`lint`, `format`, `test`, `build`)
- [ ] `.gitignore` configured for iOS/macOS/Xcode

## 3. Core Data Architecture
- [ ] `PersistenceController` (singleton) implemented
- [ ] `CycleOne.xcdatamodeld` defined with:
    - [ ] `Cycle` entity (id, startDate, endDate, cycleLength, periodLength, createdAt, notes)
    - [ ] `DayLog` entity (id, date, flowLevel, mood, energyLevel, painLevel, notes)
    - [ ] `Symptom` entity (id, name, category)
- [ ] Relationships configured:
    - [ ] `Cycle` (1) <---> (N) `DayLog` (Cascade delete)
    - [ ] `DayLog` (1) <---> (N) `Symptom` (Cascade delete)
- [ ] Constraints & Indices:
    - [ ] Unique constraint on `DayLog.date`
    - [ ] `NSMergeByPropertyObjectTrumpMergePolicy` configured
    - [ ] Index on `Cycle.startDate` and `DayLog.date`

## 4. MVVM Architecture
- [ ] **Entities/Models**: Core Data subclasses
- [ ] **Services**:
    - [ ] `CycleEngine`: Prediction logic (Averages, Ovulation, Fertile Window)
    - [ ] `NotificationService`: `UserNotifications` (Local only)
    - [ ] `ExportService`: Plain-text/CSV generation
- [ ] **ViewModels**: `ObservableObject` classes with `@Published` state
    - [ ] `CycleViewModel`
    - [ ] `LogViewModel`
    - [ ] `InsightsViewModel`

## 5. UI Implementation (MVP)
- [ ] **Main Navigation**: `TabView` (Calendar, Insights, Settings)
- [ ] **Calendar View**:
    - [ ] Color-coded day states (Period, Predicted, Ovulation, Fertile, Today)
    - [ ] Header banner with countdown/prediction string
    - [ ] Month navigation (Swipe/Chevrons)
    - [ ] Log sheet trigger on day tap
- [ ] **Log View (Sheet)**:
    - [ ] Flow (Segmented), Pain (Slider), Mood/Energy (Icon Pickers)
    - [ ] Symptom Chip Grid (Multi-select)
    - [ ] Notes (Text Field, 500 chars)
    - [ ] Auto-save on dismiss (`onDisappear`)
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
    - [ ] `CycleEngine` (Prediction math, irregular cycles)
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
