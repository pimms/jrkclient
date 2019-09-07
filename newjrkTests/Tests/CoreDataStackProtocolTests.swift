@testable import newjrk
import Foundation
import XCTest

class CoreDataStackProtocolTests: XCTestCase {
    override func setUp() {
        UserDefaults.standard.clearAll()
    }

    func testSynchronousSetup() {
        // If this crashes, something has gone horribly wrong
        let _ = TestDataStack()
    }

    func testSimpleCreationOfEntity() {
        let stack = TestDataStack()
        let _: ServerConfiguration = stack.createEntity()
    }

    func testStoreIsInitiallyEmpty() {
        let expect = expectation(description: "fetch completion was called")

        let stack = TestDataStack()
        stack.fetch(ServerConfiguration.self) { results, error in
            XCTAssertNil(error)
            XCTAssertNotNil(results)
            XCTAssertTrue(results!.count == 0)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchWorksWithoutSaving() {
        let stack = TestDataStack()

        let entity = stack.createEntity(ServerConfiguration.self)
        entity.name = "1234"

        let fetchExpectation = expectation(description: "fetch completion was called")
        stack.fetch(ServerConfiguration.self) { results, _ in
            guard let results = results else {
                XCTFail()
                fatalError()
            }
            XCTAssertEqual(1, results.count)
            XCTAssertEqual("1234", results[0].name ?? "")
            fetchExpectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testUniqueInstances() {
        let stack1 = TestDataStack()
        let stack2 = TestDataStack()

        let _ = stack1.createEntity(ServerConfiguration.self)

        let exp1 = expectation(description: "fetch completion for stack1 should be called")
        let exp2 = expectation(description: "fetch completion for stack2 should be called")

        stack1.fetch(ServerConfiguration.self) { results, _ in
            XCTAssertNotNil(results)
            XCTAssertEqual(1, results!.count)
            exp1.fulfill()
        }

        stack2.fetch(ServerConfiguration.self) { results, _ in
            XCTAssertNotNil(results)
            XCTAssertEqual(0, results!.count)
            exp2.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchById() {
        let stack = TestDataStack()
        let entity = stack.createEntity(ServerConfiguration.self)
        entity.name = "12345"
        entity.url = URL(string: "https://www.google.com")

        guard let copy = stack.fetch(ServerConfiguration.self, byURIRepresentation: entity.uriRepresentation) else {
            XCTFail("Failed to fetch copy by ID")
            return
        }

        XCTAssertEqual(copy.name, entity.name)
        XCTAssertEqual(copy.url, entity.url)
    }

    func testPreferredConfigurationIsNilByDefault() {
        let stack = TestDataStack()
        XCTAssertNil(stack.preferredServerConfiguration())
    }

    func testSetPreferredConfiguration() {
        let stack = TestDataStack()

        let entity = stack.createEntity(ServerConfiguration.self)
        entity.name = "pref"
        entity.url = URL(string: "https://www.pref.com")

        stack.setPreferredServerConfiguration(entity)
        XCTAssertEqual(stack.preferredServerConfiguration(), entity)
    }

    func testOverridePreferredConfiguration() {
        let stack = TestDataStack()

        let config1 = stack.createEntity(ServerConfiguration.self)
        config1.name = "pref1"
        config1.url = URL(string: "https://www.pref1.com")

        let config2 = stack.createEntity(ServerConfiguration.self)
        config2.name = "pref2"
        config2.url = URL(string: "https://www.pref2.com")

        XCTAssertNil(stack.preferredServerConfiguration())
        stack.setPreferredServerConfiguration(config1)
        XCTAssertEqual(stack.preferredServerConfiguration(), config1)
        stack.setPreferredServerConfiguration(config2)
        XCTAssertEqual(stack.preferredServerConfiguration(), config2)
    }
}
