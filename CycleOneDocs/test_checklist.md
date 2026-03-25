# CycleOne Test Checklist

## Unit Tests
- [x] `CycleEngine`: Predict next period start
- [x] `CycleEngine`: Predict ovulation date
- [x] `CycleEngine`: Detect irregular cycles
- [x] `CycleEngine`: Filter outliers from average
- [x] `Persistence`: CRUD operations for DayLog and Cycle
- [x] `Persistence`: Cascade deletions (Log -> Symptoms)

## UI Tests
- [x] **Navigation**: Tab switching and deep navigation
- [x] **Logging**: Open sheet, log flow/symptoms, and save
- [x] **Insights**: Verify stats calculation and history list
- [x] **Settings**: Toggle predictions and verify persistence
- [x] **Export**: Generate CSV and open share sheet

## Manual Verification
- [x] UI Alignment: Fixed "lowered down" issue via `NavigationStack` refactor
- [x] Persistence: Settings and logs remain after app killed/restarted
- [x] Export: CSV file is valid and contains all logged data
- [x] Disclaimer: Verify "Predictions are estimates only" label visibility
- [x] Onboarding: Verify tip overlay appears on first launch (post-implementation)
- [x] Legend: Verify legend visibility and accuracy on Calendar
- [x] Help: Verify navigation to Help page and content readability
