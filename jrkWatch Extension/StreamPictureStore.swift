import Foundation
import jrkKitWatch
import UIKit
import SwiftUI

class StreamPictureStore: ObservableObject {
    var urlForCurrentImage: String? {
        UserDefaults.standard.value(forKey: contextUrlKey) as? String
    }

    @Published var streamPicture: UIImage?

    private let contextUrlKey = "streamPictureFetcher.contextUrl"
    private lazy var log = Log(for: self)

    private var imageFilePath: URL {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let path = paths.first else {
            fatalError("Failed to get documents-directory")
        }

        let docUrl = URL(fileURLWithPath: path)
        return docUrl.appendingPathComponent("streamPicture.png", isDirectory: false)
    }

    init() {
        loadPicture()
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
        loadPicture()
    }

    private func loadPicture() {
        if let imageData = try? Data(contentsOf: imageFilePath) {
            DispatchQueue.main.async {
                self.streamPicture = UIImage(data: imageData)
            }
        }
    }
}
