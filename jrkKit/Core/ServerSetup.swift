import UIKit

public protocol ServerSetupDelegate: AnyObject {
    func serverSetup(_ serverSetup: ServerSetup, initializedPlayer player: StreamPlayer)
}

public class ServerSetup {
    enum SetupError: String, Error {
        case imagePersistFailure = "Failed to persist stream image"
        case playerInitializationError = "Failed to initialize the stream player"
    }

    // MARK: - Public properties

    weak var delegate: ServerSetupDelegate?
    var streamPlayer: StreamPlayer?

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

    public func performInitialSetup(completion: @escaping (Error?) -> Void) {
        apiClient.loadStreamPicture { [weak self] imageResult in
            guard let self = self else { return }
            switch imageResult {
            case .success(let image):
                guard self.persistImage(image) else {
                    completion(SetupError.imagePersistFailure)
                    return
                }
                self.updateStreamName()

                guard self.initializePlayer() else {
                    completion(SetupError.playerInitializationError)
                    return
                }

                completion(nil)
            case .failure(let error):
                completion(error)
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
        delegate?.serverSetup(self, initializedPlayer: player)
        return true
    }
}
