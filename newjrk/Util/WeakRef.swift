import Foundation

class WeakRef<Element> {
    private weak var ref: AnyObject?

    var value: Element? {
        return ref as? Element
    }

    init<T: AnyObject>(_ value: T) {
        ref = value
    }
}
