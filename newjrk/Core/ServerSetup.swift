import UIKit

class ServerSetup {
    enum SetupError: String, Error {
        case imagePersistFailure = "Failed to persist stream image"
    }

    // MARK: - Private properties

    private let apiClient: ApiClient
    private let dataStack: CoreDataStackProtocol
    private let serverConfig: ServerConfiguration

    // MARK: - Init

    init(apiClient: ApiClient, dataStack: CoreDataStackProtocol, serverConfig: ServerConfiguration) {
        self.apiClient = apiClient
        self.dataStack = dataStack
        self.serverConfig = serverConfig
    }

    // MARK: - Internal methods

    func performInitialSetup(completion: @escaping (Error?) -> Void) {
        apiClient.loadStreamPicture { [weak self] imageResult in
            guard let self = self else { return }
            switch imageResult {
            case .success(let image):
                guard self.persistImage(image) else {
                    completion(SetupError.imagePersistFailure)
                    return
                }
                self.updateStreamName()
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
}
