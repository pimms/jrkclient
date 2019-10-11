import Foundation

public class DelegateCollection<T> {
    private var delegates: [WeakRef<AnyObject>] = []

    public init() { }

    public func add(_ delegate: T) {
        delegates.append(WeakRef(delegate as AnyObject))
        compact()
    }

    public func invoke(action: (T) -> Void) {
        delegates
            .compactMap { $0.value as? T }
            .forEach { action($0) }
    }

    private func compact() {
        delegates = delegates.filter { $0.value != nil }
    }
}
