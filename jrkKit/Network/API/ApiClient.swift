import UIKit

public class ApiClient {
    enum ApiError: Error {
        case noRootDocument
        case decodingError
    }

    // MARK: - Public properties

    public var streamName: String? {
        rootDocument?.streamName
    }

    public var streamPicture: UIImage?

    // MARK: - Internal properties

    var playlistURL: URL? {
        guard let path = rootDocument?.playlist else { return nil }
        return networkClient.rootURL.appendingPathComponent(path)
    }

    // MARK: - Private properties

    private let networkClient: NetworkClientProtocol
    private var rootDocument: RootDTO?

    // MARK: - Init

    /// - Note: This constructor loads the root document. The `initCompletionHandler` will be called with any eventual
    ///         errors that occurred during the initialization.
    public init(networkClient: NetworkClientProtocol, initCompletionHandler: @escaping ((Error?) -> Void)) {
        self.networkClient = networkClient
        loadRootDocument { error in
            initCompletionHandler(error)
        }
    }

    /// - Note: This constructor does **NOT** load the root document. This must be done through `loadRootDocument(completion:)`.
    public init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    // MARK: - Internal methods

    public func loadRootDocument(completion: @escaping (Error?) -> Void) {
        networkClient.get("/", resultHandler: { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let rootDoc = RootDTO.decoded(fromJson: data) else {
                        completion(ApiError.decodingError)
                        return
                    }
                    self?.rootDocument = rootDoc
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            }
        })
    }

    public func loadStreamPicture(completion: @escaping (Result<UIImage,Error>) -> Void) {
        guard let path = rootDocument?.streamPicture else {
            DispatchQueue.main.async {
                completion(.failure(ApiError.noRootDocument))
            }
            return
        }

        networkClient.get(path) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let image = UIImage(data: data) else {
                        completion(.failure(ApiError.decodingError))
                        return
                    }
                    self?.streamPicture = image
                    completion(.success(image))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    public func fetchNowPlaying(completion: @escaping (Result<NowPlayingDTO,Error>) -> Void) {
        guard let path = rootDocument?.nowPlaying else {
            DispatchQueue.main.async {
                completion(.failure(ApiError.noRootDocument))
            }
            return
        }

        networkClient.get(path) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let nowPlaying = NowPlayingDTO.decoded(fromJson: data) else {
                        completion(.failure(ApiError.decodingError))
                        return
                    }
                    completion(.success(nowPlaying))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    public func fetchEpisodeLog(completion: @escaping (Result<[LogEntryDTO],Error>) -> Void) {
        fetchLogs(from: rootDocument?.episodeLog, completion: completion)
    }

    public func fetchEventLog(completion: @escaping (Result<[LogEntryDTO],Error>) -> Void) {
        fetchLogs(from: rootDocument?.eventLog, completion: completion)
    }

    private func fetchLogs(from path: String?, completion: @escaping (Result<[LogEntryDTO],Error>) -> Void) {
        guard let path = path else {
            DispatchQueue.main.async {
                completion(.failure(ApiError.noRootDocument))
            }
            return
        }

        networkClient.get(path) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let logs = LogEntryDTO.decodedArray(fromJson: data) else {
                        completion(.failure(ApiError.decodingError))
                        return
                    }
                    completion(.success(logs))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
