import Foundation

public enum PlayerState: String, CaseIterable, Codable {
    case notPlaying
    case buffering
    case playing
    case paused
    case failed
}
