import Foundation

protocol NetworkClientProtocol {
    var rootURL: URL { get }

    func get(_: String, parameters: [String:Any], resultHandler: @escaping (Result<Data,Error>) -> Void)
}

extension NetworkClientProtocol {
    func get(_ path: String, resultHandler: @escaping (Result<Data,Error>) -> Void) {
        get(path, parameters: [:], resultHandler: resultHandler)
    }
}
