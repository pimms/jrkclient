@testable import newjrk
import Foundation

class MockNetworkClient: NetworkClientProtocol {

    // MARK: - Internal properties

    let rootURL: URL = URL(string: "https://jrkapi.com")!

    // MARK: - Private properties

    var responseMap: [String:Result<Data,Error>] = [:]

    // MARK: - Internal methods

    func get(_ path: String, parameters: [String:Any], resultHandler: @escaping (Result<Data, Error>) -> Void) {
        guard let response = responseMap[path] else {
            fatalError("No response defined for path: \(path)")
        }

        resultHandler(response)
    }

    func expect(_ response: Data, forPath path: String) {
        responseMap[path] = .success(response)
    }

    func expect(_ error: Error, forPath path: String) {
        responseMap[path] = .failure(error)
    }
}
