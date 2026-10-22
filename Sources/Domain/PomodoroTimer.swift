struct PomodoroTimer: Equatable {
    enum State: Equatable {
        case ready
        case running
        case paused
    }

    enum TickOutcome: Equatable {
        case ticked
        case completed
    }

    let duration: Int
    private(set) var remainingSeconds: Int
    private(set) var state: State = .ready

    init(duration: Int = 25 * 60) {
        self.duration = duration
        self.remainingSeconds = duration
    }

    var minutes: Int { remainingSeconds / 60 }
    var seconds: Int { remainingSeconds % 60 }

    mutating func start() {
        guard state == .ready else { return }
        state = .running
    }

    mutating func togglePause() {
        switch state {
        case .running: state = .paused
        case .paused: state = .running
        case .ready: break
        }
    }

    mutating func restart() {
        remainingSeconds = duration
        state = .running
    }

    /// Cancela la cuenta y vuelve al reposo con la duración completa.
    mutating func stop() {
        remainingSeconds = duration
        state = .ready
    }

    @discardableResult
    mutating func tick() -> TickOutcome? {
        guard state == .running else { return nil }
        remainingSeconds -= 1
        guard remainingSeconds <= 0 else { return .ticked }
        remainingSeconds = duration
        state = .ready
        return .completed
    }
}
