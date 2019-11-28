import Foundation
import jrkKitWatch
import WatchConnectivity
import UIKit

class StreamPictureFetcher {
    private enum FetchError: String, Error {
        case decodingError = "Failed to decode stream picture response"
    }

    private let session: WCSession
    private lazy var log = Log(for: self)

    public init(session: WCSession) {
        self.session = session
    }

    func fetchImage(forContext context: ApplicationContext, completion: @escaping (Result<UIImage,Error>) -> Void) {
        let request = StreamPictureRequest()
        session.send(request, replyHandler: { result in
            guard
                let response = StreamPictureResponse(fromDictionary: result),
                let image = UIImage(data: response.imageData)
            else {
                completion(.failure(FetchError.decodingError))
                return
            }

            completion(.success(image))
        }, errorHandler: { [weak self] error in
            self?.log.log(.error, "Stream picture request failed: \(error.localizedDescription)")
            completion(.failure(error))
        })
    }
}
