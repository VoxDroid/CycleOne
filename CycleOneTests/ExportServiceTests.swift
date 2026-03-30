import CoreData
@testable import CycleOne
import XCTest

final class ExportServiceTests: XCTestCase {
    var controller: PersistenceController!
    var context: NSManagedObjectContext {
        controller.container.viewContext
    }

    override func setUp() {
        super.setUp()
        controller = TestPersistenceController.empty()
    }

    override func tearDown() {
        controller = nil
        super.tearDown()
    }

    func testGenerateCSVCreatesFileWithContents() throws {
        let calendar = Calendar(identifier: .gregorian)
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 2, day: 14)))

        let log = DayLog(context: context)
        log.id = UUID()
        log.date = date
        log.flowLevel = FlowLevel.light.rawValue
        log.painLevel = 1
        log.mood = Mood.happy.rawValue
        log.energyLevel = EnergyLevel.medium.rawValue
        log.notes = "Test, notes\nnew line"

        let symptom = Symptom(context: context)
        symptom.id = UUID().uuidString
        symptom.name = "bloating"
        symptom.category = "Physical"
        log.symptoms = NSSet(array: [symptom])

        try context.save()

        let url = ExportService.shared.generateCSV(context: context)
        XCTAssertNotNil(url)

        if let url {
            let content = try String(contentsOf: url)
            XCTAssertTrue(content.contains("Date,Flow,Pain,Mood,Energy,Symptoms,Notes"))
            XCTAssertTrue(content.contains("bloating"))
            XCTAssertTrue(content.contains("Test notes") || content.contains("Test  notes") || content
                .contains("Test notes"))
        }
    }
}
