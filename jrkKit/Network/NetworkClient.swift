import Foundation

public class NetworkClient: NetworkClientProtocol {
    enum NetworkError: Error, Equatable {
        case unknownError
    }

    // MARK: - Public properties

    public let rootURL: URL

    // MARK: - Private properties

    private let session: URLSession = .shared

    // MARK: - Init

    public init(rootURL: URL) {
        self.rootURL = rootURL
    }

    public func get(_ path: String, parameters: [String:Any] = [:], resultHandler: @escaping (Result<Data, Error>) -> Void) {
        let url = rootURL.appendingPathComponent(path)
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                resultHandler(.failure(error))
                return
            }

            guard let data = data else {
                resultHandler(.failure(NetworkError.unknownError))
                return
            }

            resultHandler(.success(data))
        }

        task.resume()
    }
}
