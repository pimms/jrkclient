import Foundation
import jrkKitWatch
import UIKit

class StreamPictureStore {
    var urlForCurrentImage: String? {
        UserDefaults.standard.value(forKey: contextUrlKey) as? String
    }

    var streamPicture: UIImage? {
        do {
            let imageData = try Data(contentsOf: imageFilePath)
            return UIImage(data: imageData)
        } catch {
            return nil
        }
    }

    private let contextUrlKey = "streamPictureFetcher.contextUrl"
    private lazy var log = Log(for: self)

    private var imageFilePath: URL {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let path = paths.first, let docUrl = URL(string: path) else {
            fatalError("Failed to get documents-directory")
        }

        return docUrl.appendingPathComponent("streamPicture.png", isDirectory: false)
    }

    func saveImage(_ image: UIImage, forContext context: ApplicationContext) {
        guard let imageData = image.pngData() else { return }

        do {
            try imageData.write(to: imageFilePath)
        } catch {
            log.log(.error, "Failed to save stream picture: \(error.localizedDescription)")
            return
        }

        UserDefaults.standard.setValue(context.url, forKey: contextUrlKey)
    }
}
