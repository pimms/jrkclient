import Foundation

class DelegateCollection<T> {
    private var delegates: [WeakRef<AnyObject>] = []

    func add(_ delegate: T) {
        delegates.append(WeakRef(delegate as AnyObject))
        compact()
    }

    func invoke(action: (T) -> Void) {
        delegates
            .compactMap { $0.value as? T }
            .forEach { action($0) }
    }

    private func compact() {
        delegates = delegates.filter { $0.value != nil }
    }
}
