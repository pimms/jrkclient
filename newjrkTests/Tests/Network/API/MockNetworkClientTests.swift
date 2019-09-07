@testable import newjrk
import Foundation
import XCTest

class MockNetworkClientTests: XCTestCase {
    func testExpectedSuccessfulResponse() {
        let expectedData = "test response".data(using: .ascii)!
        let client = MockNetworkClient()
        client.expect(expectedData, forPath: "/successPlease")

        let expect = expectation(description: "resultHandler called")
        client.get("/successPlease") { result in
            switch result {
            case .success(let data):
                XCTAssertEqual(data, expectedData)
            case .failure:
                XCTFail()
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testExpectedFailedResponse() {
        let expectedError = NetworkClient.NetworkError.unknownError
        let client = MockNetworkClient()
        client.expect(expectedError, forPath: "/shouldFail")

        let expect = expectation(description: "resultHandler called")
        client.get("/shouldFail") { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                guard let networkError = error as? NetworkClient.NetworkError else {
                    XCTFail()
                    return
                }

                XCTAssertEqual(expectedError, networkError)
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
}

