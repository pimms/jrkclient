@testable import newjrk
import Foundation
import XCTest

class ApiClientTests: XCTestCase {
    private let networkClient = MockNetworkClient()

    func testCompletionHandlerGetsCalledOnSuccess() {
        networkClient.expect(TestData.rootDocumentResponse, forPath: "/")

        let expect = expectation(description: "init completion handler called")
        let _ = ApiClient(networkClient: networkClient) { error in
            XCTAssertNil(error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testCompletionHandlerCalledOnFailure() {
        let expectedError = NetworkClient.NetworkError.unknownError
        networkClient.expect(expectedError, forPath: "/")

        let expect = expectation(description: "init completion handler called")
        let _ = ApiClient(networkClient: networkClient) { error in
            guard let networkError = error as? NetworkClient.NetworkError else {
                XCTFail()
                return
            }

            XCTAssertEqual(expectedError, networkError)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testStreamName() {
        let client = createClient()
        XCTAssertEqual("test stream", client.streamName ?? "")
    }

    func testPlaylistURL() {
        let client = createClient()
        let url = networkClient.rootURL.appendingPathComponent("playlist.m3u8")
        XCTAssertEqual(url, client.playlistURL!)
    }

    func testDownloadImage() {
        guard
            let image = UIImage(named: "testImage", in: Bundle(for: ApiClientTests.self), compatibleWith: nil),
            let expectedData = image.pngData()
        else {
            XCTFail()
            return
        }

        let client = createClient()
        networkClient.expect(expectedData, forPath: "/picture.png")

        client.loadStreamPicture { result in
            switch result {
            case .success(let resultImage):
                // Comparing the raw bytes won't work, but they should at least have the same size lol
                XCTAssertEqual(resultImage.size, image.size)
            case .failure:
                XCTFail()
            }
        }
    }

    func testDownloadImageWithoutRootDocument() {
        networkClient.expect(NetworkClient.NetworkError.unknownError, forPath: "/")
        let client = createClient(mockSuccessfulResponse: false)

        let expect = expectation(description: "image handler called")
        client.loadStreamPicture { result in
            switch result {
            case .failure(let error):
                guard let error = error as? ApiClient.ApiError else {
                    XCTFail()
                    fatalError()
                }
                XCTAssertEqual(ApiClient.ApiError.noRootDocument, error)
            case .success:
                XCTFail()
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testNowPlayingSuccess() {
        let client = createClient()
        networkClient.expect(TestData.nowPlayingResponse, forPath: "/live/nowPlaying")

        let expect = expectation(description: "nowPlaying completiong handler called")
        client.fetchNowPlaying { result in
            switch result {
            case .failure:
                XCTFail()
            case .success(let nowPlaying):
                XCTAssertEqual("2016", nowPlaying.season)
                XCTAssertEqual("Mandag 19/12", nowPlaying.name)
                XCTAssertEqual("20161219.mp3", nowPlaying.key)
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Private methods

    private func createClient(mockSuccessfulResponse: Bool = true) -> ApiClient {
        if mockSuccessfulResponse {
            networkClient.expect(TestData.rootDocumentResponse, forPath: "/")
        }

        let expect = expectation(description: "init completion handler called")
        let client = ApiClient(networkClient: networkClient) { error in
            if mockSuccessfulResponse {
                XCTAssertNil(error)
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
        return client
    }
}
