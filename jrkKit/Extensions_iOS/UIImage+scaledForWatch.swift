import UIKit

public extension UIImage {
    /// - Note: Returns an image scaled for the 44mm versions of S4 and S5.
    ///         The image will be scaled to fill the most constraining axis.
    func scaledForWatch() -> UIImage? {
        guard let cgImage = cgImage else { return nil }

        let watchSize = CGSize(width: 368, height: 448)
        let watchAr = watchSize.width / watchSize.height
        let imageAr = size.width / size.height
        let scale: CGFloat

        if imageAr > watchAr {
            // The image is wider
            scale = size.height / watchSize.height
        } else {
            // The image is taller (or same AR)
            scale = size.width / watchSize.width
        }

        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }
}
