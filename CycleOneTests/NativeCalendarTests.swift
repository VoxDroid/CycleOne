import CoreData
@testable import CycleOne
import SwiftUI
import XCTest

final class NativeCalendarTests: XCTestCase {
    func testNativeCalendarView_builds_and_updates() throws {
        let context = TestPersistenceController.empty().container.viewContext
        let viewModel = CycleViewModel(context: context)

        // Initial host to exercise makeUIView
        host(NativeCalendarView(viewModel: viewModel))

        // Modify selected date to exercise updateUIView path
        let newDate = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: 3, to: Date().startOfDay))
        viewModel.selectDate(newDate)

        // Host again to trigger update paths
        host(NativeCalendarView(viewModel: viewModel))
    }
}
