# CycleOne Test Checklist

Specific test cases for `CycleOne` logic, UI, and edge cases.

## 1. Unit Tests (`CycleOneTests`)

### 1.1 Cycle Engine (Prediction Logic)
- [ ] **One Cycle logged**: Next period = start + cycleLength.
- [ ] **Multiple Cycles (up to 3)**: Next period uses average of last 3 cycles.
- [ ] **Outliers**: Engine correctly uses only the last 3 cycles for prediction.
- [ ] **No Cycles**: Returns `nil` or appropriate empty state.
- [ ] **Ovulation**: Correctly estimated at 14 days before predicted next period start.
- [ ] **Fertile Window**: Correctly calculated as 6 days ending on ovulation day + 1.
- [ ] **Irregularity Detection**: Flagged correctly if variance exceeds 10 days.
- [ ] **Cycle Length Bounds**: Minimum 21 days, maximum 45 days.

### 1.2 Notification Service
- [ ] **Trigger Date**: Scheduled correctly based on "X days before" settings.
- [ ] **Identifiers**: Consistent IDs for the same date/type (prevents duplicates).
- [ ] **Cancellation**: Notifications are cleared if cycle data is modified/deleted.
- [ ] **Permission**: Handled gracefully if user denies.

### 1.3 Persistence Controller
- [ ] **CRUD operations**: Save, Fetch, and Delete Cycle/DayLog/Symptom.
- [ ] **Relationships**: Cascade delete works (Deleting Cycle deletes DayLogs).
- [ ] **Unique Constraints**: Preventing duplicate `DayLog` for the same date.
- [ ] **Merge Policy**: `NSMergeByPropertyObjectTrumpMergePolicy` works as expected.

## 2. UI Tests (`CycleOneUITests`)

### 2.1 Calendar & Navigation
- [ ] **Launch**: App launches directly to Calendar (no onboarding after setup).
- [ ] **Month Navigation**: Swipe and chevron buttons change the displayed month.
- [ ] **Today Indicator**: Today is highlighted correctly.
- [ ] **Tab Switch**: Navigation between Calendar, Insights, and Settings.

### 2.2 Logging Flow
- [ ] **Log Sheet Open**: Tapping a day opens the `LogView` sheet.
- [ ] **Data Entry**: Selecting flow, mood, energy, and symptoms updates the UI.
- [ ] **Auto-save**: Dismissing the sheet saves data to Core Data.
- [ ] **Calendar Reflects State**: Logged days show correct color/dot on the calendar.
- [ ] **Cycle Creation**: Logging flow > 0 on a fresh day creates a new `Cycle`.

### 2.3 Settings & Export
- [ ] **Notification Toggle**: Enabling/disabling toggles works.
- [ ] **Export Trigger**: Tapping export opens the system share sheet.
- [ ] **Privacy Link**: Tapping privacy policy opens the local HTML document.

## 3. Manual / Integration Checks
- [ ] **First Launch**: Shows the lightweight "tip overlay".
- [ ] **Irregularity Note**: Shown in the header if cycles are irregular.
- [ ] **Disclaimer**: "Not medical advice" label is visible.
- [ ] **Dark Mode**: Colors remain accessible and beautiful.
- [ ] **Dynamic Type**: Text scales correctly at large accessibility sizes.
- [ ] **Disk Usage**: App remains lean (Core Data storage only).
