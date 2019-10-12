import UIKit

public extension UIImage {
    /// - Note: Returns an image scaled for the 44mm versions of S4 and S5.
    ///         The image will be scaled to fill the most constraining axis.
    func scaledForWatch() -> UIImage? {
        let watchSize = CGSize(width: 368, height: 448)
        let watchAr = watchSize.width / watchSize.height
        let imageAr = size.width / size.height
        let scale: CGFloat

        if imageAr > watchAr {
            // The image is wider
            scale = watchSize.height / size.height
        } else {
            // The image is taller (or same AR)
            scale = watchSize.width / size.width
        }

        return UIImage.resizeImage(self, scale: scale)
    }

    static private func resizeImage(_ image: UIImage, scale: CGFloat) -> UIImage {
        let newWidth = image.size.width * scale
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
