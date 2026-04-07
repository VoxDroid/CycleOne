import CoreData
@testable import CycleOne
import XCTest

final class ExportServiceTests: XCTestCase {
    private final class ThrowingExecuteContext: NSManagedObjectContext, @unchecked Sendable {
        override func execute(_ request: NSPersistentStoreRequest) throws -> NSPersistentStoreResult {
            throw NSError(domain: "ExportServiceTests", code: 99)
        }
    }

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
            XCTAssertTrue(content.contains(L10n.string(
                "export.csv.header",
                default: "Date,Flow,Pain,Mood,Energy,Symptoms,Notes"
            )))
            XCTAssertTrue(content.contains("bloating"))
            XCTAssertTrue(content.contains("\"Test, notes new line\""))
        }
    }

    func testGenerateCSV_handlesEmptyFields() throws {
        let calendar = Calendar(identifier: .gregorian)
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 2, day: 15)))

        let log = DayLog(context: context)
        log.id = UUID()
        log.date = date
        log.flowLevel = FlowLevel.none.rawValue
        log.painLevel = 0
        log.mood = Mood.neutral.rawValue
        log.energyLevel = EnergyLevel.low.rawValue

        try context.save()

        let url = ExportService.shared.generateCSV(context: context)
        XCTAssertNotNil(url)

        if let url {
            let content = try String(contentsOf: url)
            XCTAssertTrue(content.contains(L10n.string(
                "export.csv.header",
                default: "Date,Flow,Pain,Mood,Energy,Symptoms,Notes"
            )))
            // Should include the flow description for `none`
            let expectedFlowValue = L10n.string("flow.none", default: "None")
            XCTAssertTrue(content.contains("\"\(expectedFlowValue)\""))
        }
    }

    func testGenerateCSV_usesFallbacksForMissingAndInvalidValues() throws {
        let log = DayLog(context: context)
        log.id = UUID()
        log.date = Date().startOfDay
        log.flowLevel = 99
        log.painLevel = 0
        log.mood = 99
        log.energyLevel = 99
        log.notes = nil
        log.symptoms = nil

        try context.save()

        let url = ExportService.shared.generateCSV(context: context)
        XCTAssertNotNil(url)

        if let url {
            let content = try String(contentsOf: url)
            XCTAssertTrue(content.contains(",\"0\","))
            XCTAssertTrue(content.contains("\"\",\"\",\"\",\"\""))
        }
    }

    func testGenerateCSV_ignoresSymptomsWithNilName() throws {
        let log = DayLog(context: context)
        log.id = UUID()
        log.date = Date().startOfDay
        log.flowLevel = FlowLevel.light.rawValue
        log.painLevel = 1
        log.mood = Mood.happy.rawValue
        log.energyLevel = EnergyLevel.medium.rawValue

        let symptom = Symptom(context: context)
        symptom.id = UUID().uuidString
        symptom.name = nil
        symptom.category = "Physical"
        log.addToSymptoms(symptom)

        // Keep the object unsaved so we can exercise nil-name filtering without
        // violating the Core Data required-field validation for Symptom.name.

        let url = ExportService.shared.generateCSV(context: context)
        XCTAssertNotNil(url)

        if let url {
            let content = try String(contentsOf: url)
            XCTAssertTrue(content.contains("\"\",\"\""))
        }
    }

    func testGenerateCSV_multipleSymptoms_joined() throws {
        let calendar = Calendar(identifier: .gregorian)
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 2, day: 16)))

        let log = DayLog(context: context)
        log.id = UUID()
        log.date = date
        log.flowLevel = FlowLevel.light.rawValue
        log.painLevel = 1
        log.mood = Mood.happy.rawValue
        log.energyLevel = EnergyLevel.medium.rawValue

        let s1 = Symptom(context: context)
        s1.id = UUID().uuidString
        s1.name = "sym1"
        s1.category = "Other"

        let s2 = Symptom(context: context)
        s2.id = UUID().uuidString
        s2.name = "sym2"
        s2.category = "Other"

        log.symptoms = NSSet(array: [s1, s2])

        try context.save()

        let url = ExportService.shared.generateCSV(context: context)
        XCTAssertNotNil(url)

        if let url {
            let content = try String(contentsOf: url)
            XCTAssertTrue(content.contains("\"sym1;sym2\"") || content.contains("\"sym2;sym1\""))
            // symptoms should be joined by ';'
            let order1 = content.contains("sym1;sym2")
            let order2 = content.contains("sym2;sym1")
            // ensure both expressions are evaluated for coverage
            _ = order1
            _ = order2
            XCTAssertTrue(order1 || order2)
        }
    }

    func testGenerateCSV_mitigatesFormulaInjectionInNotesAndSymptoms() throws {
        let date = Date().startOfDay

        let log = DayLog(context: context)
        log.id = UUID()
        log.date = date
        log.flowLevel = FlowLevel.medium.rawValue
        log.painLevel = 2
        log.mood = Mood.neutral.rawValue
        log.energyLevel = EnergyLevel.medium.rawValue
        log.notes = "=SUM(A1:A2)"

        let symptom = Symptom(context: context)
        symptom.id = UUID().uuidString
        symptom.name = "@risk"
        symptom.category = "Other"
        log.symptoms = NSSet(array: [symptom])

        try context.save()

        let url = ExportService.shared.generateCSV(context: context)
        XCTAssertNotNil(url)

        if let url {
            let content = try String(contentsOf: url)
            XCTAssertTrue(content.contains("\"'=SUM(A1:A2)\""))
            XCTAssertTrue(content.contains("\"'@risk\""))
        }
    }

    func testGenerateCSV_escapesEmbeddedQuotes() throws {
        let date = Date().startOfDay

        let log = DayLog(context: context)
        log.id = UUID()
        log.date = date
        log.flowLevel = FlowLevel.light.rawValue
        log.painLevel = 1
        log.mood = Mood.happy.rawValue
        log.energyLevel = EnergyLevel.high.rawValue
        log.notes = "She said \"hello\""

        try context.save()

        let url = ExportService.shared.generateCSV(context: context)
        XCTAssertNotNil(url)

        if let url {
            let content = try String(contentsOf: url)
            XCTAssertTrue(content.contains("\"She said \"\"hello\"\"\""))
        }
    }

    func testGenerateCSV_returnsNilWhenFetchThrows() throws {
        let throwingContext = ThrowingExecuteContext(concurrencyType: .mainQueueConcurrencyType)
        throwingContext.persistentStoreCoordinator = try makeInMemoryCoordinator()

        let url = ExportService.shared.generateCSV(context: throwingContext)

        XCTAssertNil(url)
    }

    func testSymptomsText_helper_handlesNilAndValues() {
        XCTAssertEqual(ExportService.symptomsText(from: nil), "")

        let symptom = Symptom(context: context)
        symptom.id = UUID().uuidString
        symptom.name = "cramps"
        symptom.category = "Physical"

        XCTAssertEqual(
            ExportService.symptomsText(from: NSSet(array: [symptom])),
            "cramps"
        )
    }

    private func makeInMemoryCoordinator() throws -> NSPersistentStoreCoordinator {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: PersistenceController.model)
        try coordinator.addPersistentStore(
            ofType: NSInMemoryStoreType,
            configurationName: nil,
            at: nil,
            options: nil
        )
        return coordinator
    }
}
