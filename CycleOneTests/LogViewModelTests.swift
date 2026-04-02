import CoreData
@testable import CycleOne
import XCTest

@MainActor
final class LogViewModelTests: XCTestCase {
    private final class SelectiveThrowManagedObjectContext: NSManagedObjectContext, @unchecked Sendable {
        var shouldThrowOnFetch = false
        var shouldThrowOnSave = false

        override func execute(_ request: NSPersistentStoreRequest) throws -> NSPersistentStoreResult {
            if shouldThrowOnFetch, request is NSFetchRequest<NSFetchRequestResult> {
                throw NSError(
                    domain: "LogViewModelTests",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Forced fetch failure"]
                )
            }
            return try super.execute(request)
        }

        override func save() throws {
            if shouldThrowOnSave {
                throw NSError(
                    domain: "LogViewModelTests",
                    code: 2,
                    userInfo: [NSLocalizedDescriptionKey: "Forced save failure"]
                )
            }
            try super.save()
        }
    }

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

    func testInitUsesEmptyNotesWhenStoredNotesAreNil() throws {
        let date = Date().startOfDay

        let log = DayLog(context: context)
        log.id = UUID()
        log.date = date
        log.flowLevel = FlowLevel.light.rawValue
        log.mood = Mood.happy.rawValue
        log.energyLevel = EnergyLevel.high.rawValue
        log.notes = nil

        try context.save()

        let viewModel = LogViewModel(date: date, context: context)

        XCTAssertEqual(viewModel.notes, "")
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
        let firstSymptoms = try XCTUnwrap(log.symptoms as? Set<Symptom>)
        var symptomIDs = try Set(firstSymptoms.map { try XCTUnwrap($0.id) })
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

        let updatedSymptoms = try XCTUnwrap(log.symptoms as? Set<Symptom>)
        symptomIDs = try Set(updatedSymptoms.map { try XCTUnwrap($0.id) })
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

    func testLoadExistingLog_handlesFetchFailure() throws {
        let throwingContext = try makeThrowingContext()
        throwingContext.shouldThrowOnFetch = true

        let viewModel = LogViewModel(date: Date().startOfDay, context: throwingContext)

        XCTAssertFalse(viewModel.hasExistingLog)
        XCTAssertEqual(viewModel.flow, .none)
    }

    func testSave_handlesContextSaveFailure() throws {
        let date = Date().startOfDay
        let throwingContext = try makeThrowingContext()
        throwingContext.shouldThrowOnSave = true

        let viewModel = LogViewModel(date: date, context: throwingContext)
        viewModel.flow = .light
        viewModel.notes = "will fail to save"

        viewModel.save()

        XCTAssertFalse(viewModel.hasExistingLog)
    }

    func testSave_withThrowingContextPassThroughSavesWhenNotThrowing() throws {
        let date = Date().startOfDay
        let throwingContext = try makeThrowingContext()

        let viewModel = LogViewModel(date: date, context: throwingContext)
        viewModel.flow = .light
        viewModel.notes = "saved"

        viewModel.save()

        let request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", date as NSDate)
        let results = try throwingContext.fetch(request)

        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(viewModel.hasExistingLog)
    }

    func testDeleteLog_handlesFetchFailure() throws {
        let date = Date().startOfDay
        let throwingContext = try makeThrowingContext()

        let viewModel = LogViewModel(date: date, context: throwingContext)
        throwingContext.shouldThrowOnFetch = true

        viewModel.deleteLog()

        XCTAssertFalse(viewModel.hasExistingLog)
    }

    func testClampedNotes_returnsOriginalWhenWithinLimit() {
        let input = "short note"

        let output = LogView.clampedNotes(from: input)

        XCTAssertEqual(output, input)
    }

    func testClampedNotes_truncatesWhenOverLimit() {
        let input = String(repeating: "n", count: 800)

        let output = LogView.clampedNotes(from: input)

        XCTAssertEqual(output.count, 500)
    }

    private func makeThrowingContext() throws -> SelectiveThrowManagedObjectContext {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: PersistenceController.model)
        try coordinator.addPersistentStore(
            ofType: NSInMemoryStoreType,
            configurationName: nil,
            at: nil,
            options: nil
        )

        let context = SelectiveThrowManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }
}
