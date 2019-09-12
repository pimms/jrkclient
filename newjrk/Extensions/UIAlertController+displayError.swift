import UIKit

extension UIAlertController {
    static func display(error: Error?,
                        withTitle title: String = "Error",
                        message: String? = nil,
                        in presentingViewController: UIViewController,
                        completionHandler: (() -> Void)? = nil) {
        var errorText = message ?? "An error occurred."
        if let error = error {
            errorText += "\n\nError: \(error)"
        }

        let action = UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler?()
        }

        let alert = UIAlertController(title: title, message: errorText, preferredStyle: .alert)
        alert.addAction(action)

        presentingViewController.present(alert, animated: false, completion: nil)
    }
}
