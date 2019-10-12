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
        session.send(request, replyHandler: { [weak self] response in
            guard
                let response = StreamPictureResponse(fromDictionary: response),
                let image = UIImage(data: response.imageData)
            else {
                self?.log.log(.error, "Failed to decode stream picture response")
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
