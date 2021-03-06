import UIKit

public class ServerSetup {
    enum SetupError: String, Error {
        case imagePersistFailure = "Failed to persist stream image"
        case playerInitializationError = "Failed to initialize the stream player"
    }

    // MARK: - Public properties

    public internal(set) var streamPlayer: StreamPlayer?

    // MARK: - Private properties

    private let apiClient: ApiClient
    private let dataStack: CoreDataStackProtocol
    private let serverConfig: ServerConfiguration

    // MARK: - Init

    public init(apiClient: ApiClient, dataStack: CoreDataStackProtocol, serverConfig: ServerConfiguration) {
        self.apiClient = apiClient
        self.dataStack = dataStack
        self.serverConfig = serverConfig
    }

    // MARK: - Public methods

    public func performInitialSetup(completion: @escaping (Result<StreamPlayer,Error>) -> Void) {
        apiClient.loadStreamPicture { [weak self] imageResult in
            guard let self = self else { return }
            switch imageResult {
            case .success(let image):
                guard self.persistImage(image) else {
                    completion(.failure(SetupError.imagePersistFailure))
                    return
                }
                self.updateStreamName()

                guard self.initializePlayer(), let streamPlayer = self.streamPlayer else {
                    completion(.failure(SetupError.playerInitializationError))
                    return
                }

                completion(.success(streamPlayer))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private methods

    private func persistImage(_ image: UIImage) -> Bool {
        guard let filePath = serverConfig.picturePath else { return false }
        guard let data = image.pngData() else { return false }

        do {
            try data.write(to: filePath)
            return true
        } catch {
            print("Failed to save stream picture: \(error)")
            return false
        }
    }

    private func updateStreamName() {
        let streamName = apiClient.streamName ?? "Unnamed JRK Stream"
        serverConfig.name = streamName
        dataStack.save()
    }

    private func initializePlayer() -> Bool {
        guard let player = StreamPlayer(serverConfiguration: serverConfig, apiClient: apiClient) else {
            return false
        }

        streamPlayer = player
        return true
    }
}
