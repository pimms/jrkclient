import UIKit

class InitialConfigViewController: UIViewController {
    @IBOutlet private var urlField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        urlField?.becomeFirstResponder()
    }
}
