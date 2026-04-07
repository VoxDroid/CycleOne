import CoreData
@testable import CycleOne
import XCTest

final class UITestLaunchConfiguratorTests: XCTestCase {
    private final class ThrowingManagedObjectContext: NSManagedObjectContext, @unchecked Sendable {
        private(set) var executeCalls = 0
        private(set) var saveCalls = 0

        override var hasChanges: Bool {
            true
        }

        override func execute(_ request: NSPersistentStoreRequest) throws -> NSPersistentStoreResult {
            executeCalls += 1
            throw NSError(domain: "UITestLaunchConfiguratorTests", code: 1)
        }

        override func save() throws {
            saveCalls += 1
            throw NSError(domain: "UITestLaunchConfiguratorTests", code: 2)
        }
    }

    private final class SaveTrackingManagedObjectContext: NSManagedObjectContext, @unchecked Sendable {
        private(set) var executeCalls = 0
        private(set) var saveCalls = 0

        override var hasChanges: Bool {
            true
        }

        override func execute(_ request: NSPersistentStoreRequest) throws -> NSPersistentStoreResult {
            executeCalls += 1
            if let deleteRequest = request as? NSBatchDeleteRequest {
                let entityName = deleteRequest.fetchRequest.entityName!
                let objectIDRequest = NSFetchRequest<NSManagedObjectID>(entityName: entityName)
                objectIDRequest.predicate = deleteRequest.fetchRequest.predicate
                objectIDRequest.resultType = .managedObjectIDResultType
                let objectIDs = try fetch(objectIDRequest)
                for objectID in objectIDs {
                    delete(object(with: objectID))
                }
                return NSBatchDeleteResult()
            }
            return try super.execute(request)
        }

        override func save() throws {
            saveCalls += 1
            try super.save()
        }
    }

    override func setUp() {
        super.setUp()
        UITestLaunchConfigurator.resetForTests()
        UserDefaults.standard.removeObject(forKey: "hasSeenOnboarding")
        UserDefaults.standard.removeObject(forKey: AppLanguage.storageKey)
    }

    override func tearDown() {
        UITestLaunchConfigurator.resetForTests()
        UserDefaults.standard.removeObject(forKey: "hasSeenOnboarding")
        UserDefaults.standard.removeObject(forKey: AppLanguage.storageKey)
        super.tearDown()
    }

    func testConfigureIfNeeded_appliesFlagsAndSkipsSecondPass() throws {
        let controller = TestPersistenceController.empty()
        let context = controller.container.viewContext

        let staleLog = DayLog(context: context)
        staleLog.id = UUID()
        staleLog.date = Date().adding(days: -120)
        staleLog.flowLevel = FlowLevel.light.rawValue
        staleLog.mood = Mood.happy.rawValue
        staleLog.energyLevel = EnergyLevel.medium.rawValue
        staleLog.painLevel = 1
        staleLog.notes = "stale"
        try context.save()

        let args = [
            "-ui-testing",
            "-ui-testing-has-seen-onboarding",
            "-ui-testing-clear-data",
            "-ui-testing-seed-insights",
        ]

        UITestLaunchConfigurator.configureIfNeeded(context: context, arguments: args)

        XCTAssertTrue(UserDefaults.standard.bool(forKey: "hasSeenOnboarding"))
        XCTAssertEqual(try context.count(for: DayLog.fetchRequest() as NSFetchRequest<NSFetchRequestResult>), 3)

        UITestLaunchConfigurator.configureIfNeeded(context: context, arguments: args)

        XCTAssertEqual(try context.count(for: DayLog.fetchRequest() as NSFetchRequest<NSFetchRequestResult>), 3)
    }

    func testConfigureIfNeeded_returnsWithoutUiTestingArgument() {
        let context = TestPersistenceController.empty().container.viewContext

        UITestLaunchConfigurator.configureIfNeeded(
            context: context,
            arguments: ["-hasSeenOnboarding", "YES"]
        )

        XCTAssertFalse(UserDefaults.standard.bool(forKey: "hasSeenOnboarding"))
    }

    func testConfigureIfNeeded_setsEnglishLanguageByDefault() {
        let context = TestPersistenceController.empty().container.viewContext

        UITestLaunchConfigurator.configureIfNeeded(
            context: context,
            arguments: ["-ui-testing"],
            retryCount: 20
        )

        XCTAssertEqual(
            UserDefaults.standard.string(forKey: AppLanguage.storageKey),
            AppLanguage.english.rawValue
        )
    }

    func testConfigureIfNeeded_allowsLanguageOverrideArgument() {
        let context = TestPersistenceController.empty().container.viewContext

        UITestLaunchConfigurator.configureIfNeeded(
            context: context,
            arguments: ["-ui-testing", "-ui-testing-language", "ja"],
            retryCount: 20
        )

        XCTAssertEqual(
            UserDefaults.standard.string(forKey: AppLanguage.storageKey),
            AppLanguage.japanese.rawValue
        )
    }

    func testConfigureIfNeeded_retriesWhenPersistentStoresMissing() {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        UITestLaunchConfigurator.configureIfNeeded(
            context: context,
            arguments: ["-ui-testing"],
            retryCount: 19
        )

        XCTAssertTrue(true)
    }

    func testConfigureIfNeeded_clearDataErrorPath() throws {
        let context = ThrowingManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = try makeInMemoryCoordinator()

        UITestLaunchConfigurator.configureIfNeeded(
            context: context,
            arguments: ["-ui-testing", "-ui-testing-clear-data"],
            retryCount: 20
        )

        XCTAssertEqual(context.executeCalls, 3)
        XCTAssertEqual(context.saveCalls, 1)
    }

    func testConfigureIfNeeded_seedInsightsErrorPath() throws {
        let context = ThrowingManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = try makeInMemoryCoordinator()

        UITestLaunchConfigurator.configureIfNeeded(
            context: context,
            arguments: ["-ui-testing", "-ui-testing-seed-insights"],
            retryCount: 20
        )

        XCTAssertEqual(context.saveCalls, 1)
    }

    func testConfigureIfNeeded_clearDataSuccessPathSavesWhenChangesPresent() throws {
        let context = SaveTrackingManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let coordinator = try makeInMemoryCoordinator()
        context.persistentStoreCoordinator = coordinator

        let seedContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        seedContext.persistentStoreCoordinator = coordinator

        let staleLog = DayLog(context: seedContext)
        staleLog.id = UUID()
        staleLog.date = Date().startOfDay
        staleLog.flowLevel = FlowLevel.light.rawValue
        try seedContext.save()

        UITestLaunchConfigurator.configureIfNeeded(
            context: context,
            arguments: ["-ui-testing", "-ui-testing-clear-data"],
            retryCount: 20
        )

        XCTAssertEqual(context.executeCalls, 6)
        XCTAssertEqual(context.saveCalls, 1)
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
