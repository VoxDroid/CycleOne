import CoreData
@testable import CycleOne
import XCTest

@MainActor
final class LogViewModelTests: XCTestCase {
    private var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = TestPersistenceController.empty().container.viewContext
    }

    override func tearDown() {
        context = nil
        super.tearDown()
    }

    func testInitLoadsExistingLogValuesAndSymptoms() throws {
        let date = Date().startOfDay

        let log = DayLog(context: context)
        log.id = UUID()
        log.date = date
        log.flowLevel = FlowLevel.heavy.rawValue
        log.mood = Mood.sad.rawValue
        log.energyLevel = EnergyLevel.low.rawValue
        log.painLevel = 4
        log.notes = "Loaded note"

        let cramps = Symptom(context: context)
        cramps.id = "cramps"
        cramps.name = "Cramps"
        cramps.category = "Physical"

        let fatigue = Symptom(context: context)
        fatigue.id = "fatigue"
        fatigue.name = "Fatigue"
        fatigue.category = "Mood & Mental"

        log.symptoms = NSSet(array: [cramps, fatigue])
        try context.save()

        let viewModel = LogViewModel(date: date, context: context)

        XCTAssertTrue(viewModel.hasExistingLog)
        XCTAssertEqual(viewModel.flow, .heavy)
        XCTAssertEqual(viewModel.mood, .sad)
        XCTAssertEqual(viewModel.energy, .low)
        XCTAssertEqual(viewModel.painLevel, 4)
        XCTAssertEqual(viewModel.notes, "Loaded note")
        XCTAssertEqual(viewModel.selectedSymptoms, Set(["cramps", "fatigue"]))
    }

    func testInitFallsBackForInvalidStoredEnumValues() throws {
        let date = Date().startOfDay

        let log = DayLog(context: context)
        log.id = UUID()
        log.date = date
        log.flowLevel = 99
        log.mood = 99
        log.energyLevel = 99
        log.painLevel = 1
        log.notes = "x"

        try context.save()

        let viewModel = LogViewModel(date: date, context: context)

        XCTAssertEqual(viewModel.flow, .none)
        XCTAssertEqual(viewModel.mood, .neutral)
        XCTAssertEqual(viewModel.energy, .medium)
        XCTAssertTrue(viewModel.hasExistingLog)
    }

    func testSaveSkipsWhenContentIsEmpty() throws {
        let date = Date().startOfDay
        let viewModel = LogViewModel(date: date, context: context)

        viewModel.save()

        let request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", date as NSDate)
        let results = try context.fetch(request)

        XCTAssertTrue(results.isEmpty)
    }

    func testSaveCreatesAndUpdatesSingleLogAndReplacesSymptoms() throws {
        let date = Date().startOfDay
        let viewModel = LogViewModel(date: date, context: context)

        viewModel.flow = .light
        viewModel.mood = .happy
        viewModel.energy = .high
        viewModel.painLevel = 3
        viewModel.notes = "first"
        viewModel.selectedSymptoms = ["cramps", "unknown_symptom"]
        viewModel.save()

        var request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", date as NSDate)
        var results = try context.fetch(request)

        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(viewModel.hasExistingLog)

        var log = try XCTUnwrap(results.first)
        var symptomIDs = Set((log.symptoms as? Set<Symptom>)?.compactMap(\.id) ?? [])
        XCTAssertEqual(symptomIDs, ["cramps"])

        viewModel.flow = .medium
        viewModel.notes = "second"
        viewModel.selectedSymptoms = ["fatigue"]
        viewModel.save()

        request = DayLog.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", date as NSDate)
        results = try context.fetch(request)

        XCTAssertEqual(results.count, 1)
        log = try XCTUnwrap(results.first)
        XCTAssertEqual(log.flowLevel, FlowLevel.medium.rawValue)
        XCTAssertEqual(log.notes, "second")

        symptomIDs = Set((log.symptoms as? Set<Symptom>)?.compactMap(\.id) ?? [])
        XCTAssertEqual(symptomIDs, ["fatigue"])
    }

    func testSaveTruncatesNotesToModelMaximumLength() throws {
        let date = Date().startOfDay
        let viewModel = LogViewModel(date: date, context: context)

        viewModel.flow = .light
        viewModel.notes = String(repeating: "a", count: 800)
        viewModel.save()

        let request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", date as NSDate)
        let log = try XCTUnwrap(context.fetch(request).first)

        XCTAssertEqual(log.notes?.count, 500)
    }

    func testDeleteLogRemovesEntriesAndResetsFields() throws {
        let date = Date().startOfDay
        let viewModel = LogViewModel(date: date, context: context)

        viewModel.flow = .heavy
        viewModel.mood = .angry
        viewModel.energy = .low
        viewModel.painLevel = 7
        viewModel.notes = "to be deleted"
        viewModel.selectedSymptoms = ["cramps", "fatigue"]
        viewModel.save()

        viewModel.deleteLog()

        let logRequest: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        logRequest.predicate = NSPredicate(format: "date == %@", date as NSDate)
        let logs = try context.fetch(logRequest)

        let symptomRequest: NSFetchRequest<Symptom> = Symptom.fetchRequest()
        let symptoms = try context.fetch(symptomRequest)

        XCTAssertTrue(logs.isEmpty)
        XCTAssertTrue(symptoms.isEmpty)
        XCTAssertFalse(viewModel.hasExistingLog)
        XCTAssertEqual(viewModel.flow, .none)
        XCTAssertEqual(viewModel.mood, .neutral)
        XCTAssertEqual(viewModel.energy, .medium)
        XCTAssertEqual(viewModel.painLevel, 0)
        XCTAssertEqual(viewModel.notes, "")
        XCTAssertEqual(viewModel.selectedSymptoms, [])
    }
}
