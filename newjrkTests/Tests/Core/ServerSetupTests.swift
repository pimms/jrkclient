@testable import newjrk
import Foundation
import XCTest

class ServerSetupTests: XCTestCase {

    // MARK: - Setup

    private var apiClient: ApiClient!
    private var networkClient: MockNetworkClient!

    override func setUp() {
        let expect = expectation(description: "ApiClient completion handler called")

        networkClient = MockNetworkClient()
        networkClient.expect(TestData.successfulRootDocumentResponse, forPath: "/")

        apiClient = ApiClient(networkClient: networkClient) { error in
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Test cases

    func testSuccessfulSetup() {
        guard
            let image = UIImage(named: "testImage", in: Bundle(for: ServerSetupTests.self), compatibleWith: nil),
            let data = image.pngData()
        else {
            XCTFail()
            return
        }

        networkClient.expect(data, forPath: "/picture.png")

        let dataStack = TestDataStack()
        let serverConfig = dataStack.createEntity(ServerConfiguration.self)
        serverConfig.url = networkClient.rootURL
        XCTAssertNil(serverConfig.name)

        let expect = expectation(description: "setup completed")
        let setup = ServerSetup(apiClient: apiClient, dataStack: TestDataStack(), serverConfig: serverConfig)
        setup.performInitialSetup { error in
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual("test stream", serverConfig.name)
    }

    func testFailedSetup() {
        let expectedError = NetworkClient.NetworkError.unknownError
        networkClient.expect(expectedError, forPath: "/picture.png")

        let dataStack = TestDataStack()
        let serverConfig = dataStack.createEntity(ServerConfiguration.self)
        serverConfig.url = networkClient.rootURL

        let expect = expectation(description: "setup completed")
        let setup = ServerSetup(apiClient: apiClient, dataStack: TestDataStack(), serverConfig: serverConfig)
        setup.performInitialSetup { error in
            guard let networkError = error as? NetworkClient.NetworkError else {
                XCTFail()
                return
            }

            XCTAssertEqual(expectedError, networkError)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }
}
