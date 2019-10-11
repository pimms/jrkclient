import Foundation

public enum PlayerState: String, CaseIterable {
    case notPlaying
    case buffering
    case playing
    case paused
    case failed
}
