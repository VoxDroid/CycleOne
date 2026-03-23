# CycleOne Test Checklist

## 1. Unit Tests (`CycleOneTests`)

### 1.1 Cycle Engine
- [x] **Prediction Logic**: Correct average calculation (Last 3 cycles).
- [x] **Outlier Handling**: Ignores cycles < 21 or > 45 days.
- [x] **Irregularity Detection**: Correctly flags standard deviation > constant.
- [x] **Cycle Length Bounds**: Minimum 21 days, maximum 45 days.

### 1.2 Notification Service
- [x] **Trigger Date**: Scheduled correctly (8 AM day before).
- [x] **Identifiers**: Date-specific IDs (prevents overwriting same-day alerts).
- [x] **Cancellation**: `cancelAll()` clears pending requests.
- [x] **Permission**: Handled via `requestAuthorization` (XCTest limited).

### 1.3 Persistence Controller
- [x] **CRUD operations**: Save, Fetch, and Delete Cycle/DayLog/Symptom.
- [x] **Relationships**: Cascade delete works (Deleting Cycle deletes DayLogs).
- [x] **Unique Constraints**: Preventing duplicate `DayLog` for the same date (Manual check in `LogView`).
- [x] **Merge Policy**: `NSMergeByPropertyObjectTrumpMergePolicy` works as expected.

## 2. UI Tests (`CycleOneUITests`)
- [x] **Launch**: App launches directly to Calendar.
- [x] **Month Navigation**: Graphical DatePicker identifies its month header.
- [x] **Today Indicator**: Navigation title/label exists.
- [x] **Tab Switch**: Navigation between Calendar, Insights, and Settings.
- [x] **Log Button**: Tapping `LogDayButton` opens the sheet.
- [x] **Data Entry**: Selecting flow, mood, energy, and symptoms updates UI.
- [x] **Auto-save**: `onDisappear` triggers `saveLog()`.
- [x] **Calendar Reflects State**: Verified by navigation and logging flows.
- [x] **Cycle Creation**: Automated cycle check in `saveLog()`.
- [x] **Export Trigger**: Tapping export opens share sheet (Manual/CI check).
- [x] **Privacy Link**: Tapping privacy policy opens local HTML (Manual/CI check).
