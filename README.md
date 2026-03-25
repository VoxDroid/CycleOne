# CycleOne

<p align="center">
  <img src="CycleOne/Assets.xcassets/AppIcon.appiconset/appicon_1024.png" width="128" height="128" alt="CycleOne App Icon">
</p>

## Overview

CycleOne is a sophisticated, privacy-centric menstrual cycle and fertility tracking application for iOS. Engineered with a strict "local-only" architecture, it provides a comprehensive suite of tools for cycle logging, symptomatic analysis, and physiological predictions without the use of cloud-based storage, user accounts, or third-party telemetry.

The application serves as a high-performance, subscription-free alternative to market-leading trackers, prioritizing data sovereignty and user trust.

## Core Features

### Advanced Cycle Prediction Engine
The proprietary `CycleEngine` utilizes historically logged data to provide accurate estimations for:
- Menstrual period commencement and duration.
- Ovulation dates based on luteal phase assumptions.
- Fertile window windows, calculated for optimized awareness.
- Identification of cycle irregularities based on statistical variance.

### Comprehensive Health Logging
A streamlined, navigation-based interface facilitates the logging of multidimensional health data:
- **Menstrual Flow**: Categorical tracking from spotting to heavy flow.
- **Physical Symptoms**: A curated database of physical, emotional, and digestive indicators.
- **Biometric Indicators**: High-fidelity tracking of pain levels, mood, and energy.
- **Annotations**: Support for detailed, encrypted local notes.

### Native Calendar Integration
CycleOne leverages the native iOS `UICalendarView` framework, enhanced with custom decorations to provide a high-contrast, at-a-glance view of cycle phases, predicted states, and historical data.

### Secure Data Management
- **Zero Cloud Footprint**: Data is stored exclusively within a sandboxed Core Data environment.
- **Data Portability**: Users retain full control via a localized CSV export utility.
- **Local Notifications**: Time-sensitive alerts for period and fertile window commencement are handled entirely by the on-device `UserNotifications` framework.

## Product Philosophy

CycleOne is governed by three fundamental principles:
1. **Absolute Privacy**: No network entitlements are requested or utilized. Data never leaves the physical device.
2. **Subscription-Free Model**: A one-time purchase unlocks the full capabilities of the application indefinitely.
3. **Architectural Integrity**: Built using 100% native Swift and SwiftUI, with zero third-party dependencies, ensuring long-term maintenance stability and optimal performance.

## Technical Specifications

| Layer | Technology |
|---|---|
| Platform | iOS 16.0+ |
| Language | Swift 5.9+ |
| UI Framework | SwiftUI |
| Persistence | Core Data (SQLite) |
| Tooling | SwiftLint, SwiftFormat, XCTest |

## Development Environment Setup

### Prerequisites
- macOS 14.0 or higher
- Xcode 15.0 or higher
- Homebrew for dependency management

### Quick Start
1. Clone the repository:
   ```bash
   git clone https://github.com/VoxDroid/CycleOne.git
   ```
2. Install development tools and pre-commit hooks:
   ```bash
   brew install swiftlint swiftformat pre-commit
   pre-commit install
   ```
3. Open the project in Xcode:
   ```bash
   open CycleOne.xcodeproj
   ```

### Automation and Quality Control
The project utilizes a `Makefile` to standardize development workflows:
- `make check`: Executes the full verification suite (Linting, Formatting, Unit Tests, UI Tests).
- `make test`: Executes all unit tests.
- `make test-ui`: Executes all UI-driven integration tests.
- `make format`: Applies deterministic code formatting via SwiftFormat.

## Documentation
For detailed architectural overviews and implementation checklists, refer to the `CycleOneDocs` directory.

---

Designed and developed by VoxDroid.
