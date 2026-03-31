import CoreData
@testable import CycleOne
import SwiftUI
import XCTest

final class CoverageIncreaseTests: XCTestCase {
    func testHostRunsOnBackgroundThread() {
        let exp = expectation(description: "host background")
        DispatchQueue.global().async {
            let view = EmptyStateView(icon: "xmark.circle", title: "No Data", message: "Please add data")
            host(view)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

    func testRebuildAllCycles_withDifferentFlowValueTypes_andFullSyncBackground() throws {
        let context = TestPersistenceController.empty().container.viewContext
        let calendar = Calendar(identifier: .gregorian)
        let date1 = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))?.startOfDay)
        let date2 = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 2, day: 1))?.startOfDay)
        let date3 = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 3, day: 3))?.startOfDay)

        let log1 = NSEntityDescription.insertNewObject(forEntityName: "DayLog", into: context)
        log1.setValue(UUID(), forKey: "id")
        log1.setValue(date1, forKey: "date")
        log1.setValue(NSNumber(value: 1), forKey: "flowLevel")

        let log2 = NSEntityDescription.insertNewObject(forEntityName: "DayLog", into: context)
        log2.setValue(UUID(), forKey: "id")
        log2.setValue(date2, forKey: "date")
        log2.setValue(Int(2), forKey: "flowLevel")

        let log3 = NSEntityDescription.insertNewObject(forEntityName: "DayLog", into: context)
        log3.setValue(UUID(), forKey: "id")
        log3.setValue(date3, forKey: "date")
        log3.setValue(Int16(3), forKey: "flowLevel")

        try context.save()

        // Should create three cycles since dates are separated
        CycleManager.shared.rebuildAllCycles(in: context)

        let req: NSFetchRequest<Cycle> = Cycle.fetchRequest()
        let cycles = try context.fetch(req)
        XCTAssertEqual(cycles.count, 3)

        // Exercise fullSync's background path
        let exp = expectation(description: "fullSync background")
        DispatchQueue.global().async {
            CycleManager.shared.fullSync(in: context)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

    func testExportService_replacesCommasAndNewlinesInNotesAndJoinsSymptoms() throws {
        let context = TestPersistenceController.empty().container.viewContext

        let log = DayLog(context: context)
        log.id = UUID()
        log.date = Date().startOfDay
        log.flowLevel = FlowLevel.light.rawValue
        log.notes = "Line1\nLine2, with comma"
        let symptom = Symptom(context: context)
        symptom.id = UUID().uuidString
        symptom.name = "Cramps"
        symptom.category = "Other"
        log.addToSymptoms(symptom)

        try context.save()

        let path = ExportService.shared.generateCSV(context: context)
        XCTAssertNotNil(path)
        if let path {
            let csv = try String(contentsOf: path)
            XCTAssertTrue(csv.contains("Cramps"))
            XCTAssertTrue(csv.contains("Line1 Line2"))
        }
    }
}
