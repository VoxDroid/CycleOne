@testable import CycleOne
import SwiftUI
import XCTest

final class CoverageViewComputationTests: XCTestCase {
    @MainActor
    func testCycleHeaderView_bodyComputationBranches() {
        _ = CycleHeaderView(daysUntilPeriod: nil, daysUntilOvulation: nil, isIrregular: false).body
        _ = CycleHeaderView(daysUntilPeriod: -2, daysUntilOvulation: nil, isIrregular: false).body
        _ = CycleHeaderView(daysUntilPeriod: 0, daysUntilOvulation: 0, isIrregular: true).body
        _ = CycleHeaderView(daysUntilPeriod: 5, daysUntilOvulation: 2, isIrregular: true).body
    }

    @MainActor
    func testOnboardingTipView_bodyComputation() {
        _ = OnboardingTipView(onDismiss: {}).body
    }

    @MainActor
    func testOnboardingTipView_lastPageBodyComputation() {
        _ = OnboardingTipView(onDismiss: {}, initialPage: 3).body
    }

    @MainActor
    func testNotificationSettingsView_bodyComputation_defaultState() {
        withNotificationDefaults(
            remindBeforePeriod: false,
            remindBeforeFertile: false,
            daysBeforePeriod: 1
        ) {
            _ = NotificationSettingsView().body
        }
    }

    @MainActor
    func testNotificationSettingsView_bodyComputation_withPeriodPicker() {
        withNotificationDefaults(
            remindBeforePeriod: true,
            remindBeforeFertile: true,
            daysBeforePeriod: 5
        ) {
            _ = NotificationSettingsView().body
        }
    }

    @MainActor
    func testPhaseIndicatorAndCalendarDayCell_bodyComputation() {
        _ = PhaseIndicator(phase: "Legacy", color: .blue).body

        let status = DayStatus(
            flow: .none,
            isPredicted: false,
            isOvulation: false,
            isFertile: false,
            hasLogs: false
        )
        _ = CalendarDayCell(
            date: Date().startOfDay,
            status: status,
            isToday: false,
            isSelected: false
        ).body
    }

    func testDayStatus_fillColor_ovulationAndNilBranches() {
        let ovulation = DayStatus(
            flow: .none,
            isPredicted: false,
            isOvulation: true,
            isFertile: false,
            hasLogs: false
        )
        XCTAssertEqual(ovulation.fillColor, .themeOvulation)

        let none = DayStatus(
            flow: .none,
            isPredicted: false,
            isOvulation: false,
            isFertile: false,
            hasLogs: false
        )
        XCTAssertNil(none.fillColor)
    }

    private func withNotificationDefaults(
        remindBeforePeriod: Bool,
        remindBeforeFertile: Bool,
        daysBeforePeriod: Int,
        run: () -> Void
    ) {
        let defaults = UserDefaults.standard
        let periodValue = defaults.object(forKey: "remindBeforePeriod")
        let fertileValue = defaults.object(forKey: "remindBeforeFertile")
        let daysValue = defaults.object(forKey: "daysBeforePeriod")

        defer {
            if let periodValue {
                defaults.set(periodValue, forKey: "remindBeforePeriod")
            } else {
                defaults.removeObject(forKey: "remindBeforePeriod")
            }

            if let fertileValue {
                defaults.set(fertileValue, forKey: "remindBeforeFertile")
            } else {
                defaults.removeObject(forKey: "remindBeforeFertile")
            }

            if let daysValue {
                defaults.set(daysValue, forKey: "daysBeforePeriod")
            } else {
                defaults.removeObject(forKey: "daysBeforePeriod")
            }
        }

        defaults.set(remindBeforePeriod, forKey: "remindBeforePeriod")
        defaults.set(remindBeforeFertile, forKey: "remindBeforeFertile")
        defaults.set(daysBeforePeriod, forKey: "daysBeforePeriod")

        run()
    }
}
