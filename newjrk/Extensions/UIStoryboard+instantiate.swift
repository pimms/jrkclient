import UIKit

extension UIStoryboard {
    static var mainStoryboard = UIStoryboard(name: "Main", bundle: .main)

    static func instantiate<T: UIViewController>(_ type: T.Type) -> T {
        let id = String(describing: type.self)
        return instantiate(type, withId: id)
    }

    static func instantiate<T: UIViewController>(_ type: T.Type, withId id: String) -> T {
        guard let vc = mainStoryboard.instantiateViewController(identifier: id) as? T else {
            fatalError("Failed to instantiate view controller of type '\(type.description())' with ID '\(id)'")
        }

        return vc
    }
}
