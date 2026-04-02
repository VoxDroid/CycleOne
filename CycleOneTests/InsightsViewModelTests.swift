import CoreData
@testable import CycleOne
import XCTest

final class InsightsViewModelTests: XCTestCase {
    private final class SelectiveThrowManagedObjectContext: NSManagedObjectContext, @unchecked Sendable {
        var failingFetchEntities = Set<String>()

        override func execute(_ request: NSPersistentStoreRequest) throws -> NSPersistentStoreResult {
            if let fetchRequest = request as? NSFetchRequest<NSFetchRequestResult>,
               let entityName = fetchRequest.entityName,
               failingFetchEntities.contains(entityName)
            {
                throw NSError(
                    domain: "InsightsViewModelTests",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Forced fetch failure for \(entityName)"]
                )
            }
            return try super.execute(request)
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

    func testCalculateStatsFromLogsAndSymptoms() throws {
        let calendar = Calendar(identifier: .gregorian)
        let date1 = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))?.startOfDay)
        let date2 = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 1, day: 29))?.startOfDay)

        // Create two flow logs which should result in two cycles after fullSync
        let log1 = DayLog(context: context)
        log1.id = UUID()
        log1.date = date1
        log1.flowLevel = FlowLevel.medium.rawValue
        log1.painLevel = 2
        log1.mood = Mood.happy.rawValue

        let log2 = DayLog(context: context)
        log2.id = UUID()
        log2.date = date2
        log2.flowLevel = FlowLevel.heavy.rawValue
        log2.painLevel = 4
        log2.mood = Mood.neutral.rawValue

        // Symptom attached to a log
        let symptom = Symptom(context: context)
        symptom.id = UUID().uuidString
        symptom.name = "cramps"
        symptom.category = "Physical"
        log1.symptoms = NSSet(array: [symptom])

        try context.save()

        // Instantiate view model; init performs fullSync and initial calculateStats
        let viewModel = InsightsViewModel(context: context)

        // Verify cycles derived from logs
        XCTAssertEqual(viewModel.totalCycles, 2)

        // Average cycle length should be set (derived from cycles -> 28.0)
        XCTAssertEqual(viewModel.avgCycleLength, 28.0, accuracy: 0.001)

        // Top symptom should include our symptom
        XCTAssertTrue(viewModel.topSymptoms.contains("cramps"))

        // Mood distribution must contain counts for moods we set
        XCTAssertEqual(viewModel.moodDistribution[Mood(rawValue: log1.mood)?.description ?? ""], 1)

        // Pain average should be computed (only pain logs are considered)
        XCTAssertEqual(viewModel.avgPainLevel, 3.0, accuracy: 0.001)
    }

    @MainActor
    func testInit_refreshesWhenContextSaves() throws {
        let viewModel = InsightsViewModel(context: context)
        XCTAssertEqual(viewModel.totalCycles, 0)

        let cycle = Cycle(context: context)
        cycle.id = UUID()
        cycle.startDate = Date().startOfDay
        cycle.createdAt = Date()
        cycle.cycleLength = 28
        cycle.periodLength = 5
        try context.save()

        let expectation = expectation(description: "view model refreshed after save notification")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if viewModel.totalCycles == 1 {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2)
    }

    func testCalculateStats_handlesCycleFetchFailure() throws {
        let throwingContext = try makeThrowingContext(failingEntities: ["Cycle"])

        let viewModel = InsightsViewModel(context: throwingContext)
        viewModel.calculateStats()

        XCTAssertEqual(viewModel.totalCycles, 0)
    }

    func testCalculateStats_handlesSymptomFetchFailure() throws {
        let throwingContext = try makeThrowingContext(failingEntities: ["Symptom"])

        let viewModel = InsightsViewModel(context: throwingContext)
        viewModel.calculateStats()

        XCTAssertTrue(viewModel.topSymptoms.isEmpty)
    }

    func testCalculateStats_handlesMoodAndPainFetchFailure() throws {
        let throwingContext = try makeThrowingContext(failingEntities: ["DayLog"])

        let viewModel = InsightsViewModel(context: throwingContext)
        viewModel.calculateStats()

        XCTAssertTrue(viewModel.moodDistribution.isEmpty)
        XCTAssertEqual(viewModel.totalLogsCount, 0)
        XCTAssertEqual(viewModel.avgPainLevel, 0)
    }

    func testCalculateStats_invalidMoodFallsBackToNeutral() throws {
        let log = DayLog(context: context)
        log.id = UUID()
        log.date = Date().startOfDay
        log.flowLevel = FlowLevel.light.rawValue
        log.mood = 99
        log.energyLevel = EnergyLevel.medium.rawValue
        log.painLevel = 1

        try context.save()

        let viewModel = InsightsViewModel(context: context)

        XCTAssertEqual(viewModel.moodDistribution[Mood.neutral.description], 1)
    }

    private func makeThrowingContext(
        failingEntities: Set<String>
    ) throws -> NSManagedObjectContext {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: PersistenceController.model)
        try coordinator.addPersistentStore(
            ofType: NSInMemoryStoreType,
            configurationName: nil,
            at: nil,
            options: nil
        )

        let context = SelectiveThrowManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        context.failingFetchEntities = failingEntities
        return context
    }
}
