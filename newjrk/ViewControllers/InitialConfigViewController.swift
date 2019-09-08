import UIKit

class InitialConfigViewController: UIViewController {
    @IBOutlet private var urlField: UITextField?
    @IBOutlet private var errorLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        #if !targetEnvironment(macCatalyst)
        urlField?.becomeFirstResponder()
        #endif
    }

    private func submit(url: URL) {
        print("Submitted URL: \(url)")
        let loadingView = LoadingView.show(in: self, withMessage: "Testing stuff")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            loadingView?.remove()
        })
    }
}

// MARK: - UITextFieldDelegate

extension InitialConfigViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let inputError = validateInput()

        guard inputError == nil, let url = enteredURL() else {
            displayError(inputError ?? .unknownError)
            animateErrorLabel()
            return false
        }

        submit(url: url)
        return true
    }
}

// MARK: - Input validation

extension InitialConfigViewController {
    private enum InputError: String, Error {
        case noInput = "Enter a JRK URL"
        case invalidScheme = "Only HTTPS scheme is supported"
        case invalidURL = "Invalid URL"
        case unknownError = "Unknown error"
    }

    private func validateInput() -> InputError? {
        guard let text = urlField?.text else { return .noInput }
        guard text.count > 0 else { return .noInput }
        guard let url = URL(string: text) else { return .invalidURL }

        if let scheme = url.scheme {
            guard scheme.lowercased() == "https" else { return .invalidScheme }
        }

        return nil
    }

    private func enteredURL() -> URL? {
        guard let text = urlField?.text, let url = URL(string: text) else {
            return nil
        }

        if url.scheme == nil {
            return URL(string: "https://\(url.absoluteString)")
        }

        return url
    }

    private func displayError(_ error: InputError) {
        errorLabel?.text = error.rawValue
        view.layoutIfNeeded()
    }

    private func animateErrorLabel() {
        let sourceTransform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
        errorLabel?.alpha = 0
        errorLabel?.transform = sourceTransform
        errorLabel?.layer.removeAllAnimations()

        UIView.animate(withDuration: 0.45, delay: 0, options: .curveEaseOut, animations: {
            self.errorLabel?.transform = CGAffineTransform.identity
            self.errorLabel?.alpha = 1.0
            self.view.layoutIfNeeded()
        }, completion: nil)

        UIView.animate(withDuration: 0.3, delay: 3, options: .curveEaseOut, animations: {
            self.errorLabel?.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
