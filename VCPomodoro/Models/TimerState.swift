import Foundation

enum TimerState {
    case idle
    case running
    case paused
}

enum SessionType {
    case work
    case rest
    
    var displayName: String {
        switch self {
        case .work: return "Focus Time"
        case .rest: return "Break Time"
        }
    }
}

struct TimerSettings {
    var workDuration: Int // in minutes
    var restDuration: Int // in minutes
    
    static let `default` = TimerSettings(workDuration: 25, restDuration: 5)
}


