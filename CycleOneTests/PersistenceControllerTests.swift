//
//  PersistenceControllerTests.swift
//  CycleOneTests
//

import CoreData
@testable import CycleOne
import XCTest

final class PersistenceControllerTests: XCTestCase {
    private final class ThrowingSaveContext: NSManagedObjectContext, @unchecked Sendable {
        override var hasChanges: Bool {
            true
        }

        override func save() throws {
            throw NSError(domain: "PersistenceControllerTests", code: 7)
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

    func testCreateAndFetchDayLog() throws {
        let date = Date().startOfDay
        let log = DayLog(context: context)
        log.id = UUID()
        log.date = date
        log.flowLevel = 3
        log.mood = 1

        try context.save()

        let request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", date as NSDate)
        let results = try context.fetch(request)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.flowLevel, 3)
    }

    func testSymptomRelationship() throws {
        let log = DayLog(context: context)
        log.id = UUID()
        log.date = Date().startOfDay

        let symptom = Symptom(context: context)
        symptom.id = "cramps"
        symptom.name = "Cramps"
        symptom.category = "Physical"
        symptom.dayLog = log

        log.addToSymptoms(symptom)

        try context.save()

        let request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        let results = try context.fetch(request)
        let fetchedLog = try XCTUnwrap(results.first)

        XCTAssertEqual(fetchedLog.symptoms?.count, 1)
        let fetchedSymptom = try XCTUnwrap(fetchedLog.symptoms?.anyObject() as? Symptom)
        XCTAssertEqual(fetchedSymptom.id, "cramps")
    }

    func testSaveWithoutChangesIsNoOp() {
        XCTAssertFalse(context.hasChanges)

        controller.save()

        XCTAssertFalse(context.hasChanges)
    }

    func testSavePersistsPendingChanges() throws {
        let log = DayLog(context: context)
        log.id = UUID()
        log.date = Date().startOfDay
        log.flowLevel = FlowLevel.light.rawValue

        XCTAssertTrue(context.hasChanges)

        controller.save()

        XCTAssertFalse(context.hasChanges)
        let request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        XCTAssertEqual(try context.count(for: request), 1)
    }

    func testModelContainsExpectedEntities() {
        let entityNames = Set(PersistenceController.model.entities.compactMap(\.name))

        XCTAssertTrue(entityNames.contains("DayLog"))
        XCTAssertTrue(entityNames.contains("Cycle"))
        XCTAssertTrue(entityNames.contains("Symptom"))
    }

    func testInMemoryStoreUsesDevNullAndExpectedContextFlags() {
        XCTAssertEqual(
            controller.container.persistentStoreDescriptions.first?.url?.path,
            "/dev/null"
        )
        XCTAssertTrue(context.automaticallyMergesChangesFromParent)
    }

    func testLoadModel_missingURLUsesHandler() {
        let fallback = NSManagedObjectModel()

        let model = PersistenceController.loadModel(
            modelURL: nil,
            missingResourceHandler: { _ in fallback },
            invalidModelHandler: { _ in NSManagedObjectModel() }
        )

        XCTAssertTrue(model === fallback)
    }

    func testLoadModel_invalidURLUsesHandler() throws {
        let invalidURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("momd")
        try Data("not a model".utf8).write(to: invalidURL)
        defer { try? FileManager.default.removeItem(at: invalidURL) }

        let fallback = NSManagedObjectModel()

        let model = PersistenceController.loadModel(
            modelURL: invalidURL,
            missingResourceHandler: { _ in NSManagedObjectModel() },
            invalidModelHandler: { _ in fallback }
        )

        XCTAssertTrue(model === fallback)
    }

    func testStoreLoadResult_variants() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("sqlite")
        let description = NSPersistentStoreDescription(url: url)

        let loaded = PersistenceController.storeLoadResult(description: description, error: nil)
        if case .loaded = loaded {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected loaded result")
        }

        let migrationError = NSError(domain: NSCocoaErrorDomain, code: 134_110)
        let retry = PersistenceController.storeLoadResult(description: description, error: migrationError)
        switch retry {
        case let .resetAndRetry(retryURL):
            XCTAssertEqual(retryURL.path, url.path)
        default:
            XCTFail("Expected resetAndRetry result")
        }

        let generalError = NSError(domain: NSCocoaErrorDomain, code: 999)
        let failed = PersistenceController.storeLoadResult(description: description, error: generalError)
        if case let .failed(message) = failed {
            XCTAssertTrue(message.contains("Unresolved error"))
        } else {
            XCTFail("Expected failed result")
        }
    }

    func testStoreLoadResult_migrationErrorWithoutURLReturnsLoaded() {
        let description = NSPersistentStoreDescription()
        description.url = nil
        let migrationError = NSError(domain: NSCocoaErrorDomain, code: 134_110)

        let result = PersistenceController.storeLoadResult(
            description: description,
            error: migrationError
        )

        if case .loaded = result {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected loaded result when migration error has no URL")
        }
    }

    func testInit_handlesMigrationRetryFailureWithInjectedLoader() {
        var loadCallCount = 0
        var failures: [String] = []
        let description = NSPersistentStoreDescription(
            url: FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("sqlite")
        )

        _ = PersistenceController(
            inMemory: true,
            loadStores: { _, completion in
                loadCallCount += 1
                if loadCallCount == 1 {
                    completion(description, NSError(domain: NSCocoaErrorDomain, code: 134_110))
                } else {
                    completion(description, NSError(domain: NSCocoaErrorDomain, code: 999))
                }
            },
            failureHandler: { failures.append($0) },
            removeItem: { _ in }
        )

        XCTAssertEqual(loadCallCount, 2)
        XCTAssertEqual(failures.count, 1)
        XCTAssertTrue(failures[0].contains("Failed to load store after reset"))
    }

    func testInit_migrationPathUsesDefaultRemoveItem() {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("sqlite")
        FileManager.default.createFile(atPath: fileURL.path, contents: Data(), attributes: nil)
        defer { try? FileManager.default.removeItem(at: fileURL) }

        var loadCallCount = 0

        _ = PersistenceController(
            loadStores: { _, completion in
                loadCallCount += 1
                let description = NSPersistentStoreDescription(url: fileURL)
                if loadCallCount == 1 {
                    completion(description, NSError(domain: NSCocoaErrorDomain, code: 134_110))
                } else {
                    completion(description, nil)
                }
            }
        )

        XCTAssertEqual(loadCallCount, 2)
        XCTAssertFalse(FileManager.default.fileExists(atPath: fileURL.path))
    }

    func testInit_handlesNonMigrationStoreErrorWithInjectedLoader() {
        var failures: [String] = []
        let description = NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))

        _ = PersistenceController(
            inMemory: true,
            loadStores: { _, completion in
                completion(description, NSError(domain: NSCocoaErrorDomain, code: 999))
            },
            failureHandler: { failures.append($0) }
        )

        XCTAssertEqual(failures.count, 1)
        XCTAssertTrue(failures[0].contains("Unresolved error"))
    }

    func testSave_usesFailureHandlerWhenContextSaveThrows() {
        let throwingContext = ThrowingSaveContext(concurrencyType: .mainQueueConcurrencyType)
        var capturedFailure: String?

        controller.save(context: throwingContext) { message in
            capturedFailure = message
        }

        XCTAssertNotNil(capturedFailure)
        XCTAssertTrue(capturedFailure?.contains("Unresolved error") == true)
    }
}
