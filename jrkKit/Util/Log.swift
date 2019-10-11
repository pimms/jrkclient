import Foundation

public enum LogLevel: String {
    case debug = "DBG"
    case warn  = "WRN"
    case error = "ERR"
}

public struct Log {
    private let owner: AnyObject

    public init(for owner: AnyObject) {
        self.owner = owner
    }

    public func log(_ level: LogLevel, _ message: String) {
        let className = String(describing: type(of: owner))
        print("[JRKLOG][\(level.rawValue)][\(className)] \(message)")
    }

    public func log(_ message: String) {
        log(.debug, message)
    }
}
