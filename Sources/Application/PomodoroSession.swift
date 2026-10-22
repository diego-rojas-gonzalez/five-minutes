import Foundation

@MainActor
protocol Ticker: AnyObject {
    func start(interval: TimeInterval, onTick: @escaping @MainActor () -> Void)
    func cancel()
}

@MainActor
protocol PomodoroObserver: AnyObject {
    func timerDidChange(_ timer: PomodoroTimer)
    func timerDidComplete()
}

@MainActor
protocol PomodoroCommands: AnyObject {
    func restart()
    func stop()
}

@MainActor
final class PomodoroSession {
    private(set) var timer = PomodoroTimer()

    private let ticker: Ticker
    private let doubleClickWindow: Duration
    private var observers: [PomodoroObserver] = []
    private var pendingClick: Task<Void, Never>?

    init(ticker: Ticker, doubleClickWindow: Duration = .milliseconds(350)) {
        self.ticker = ticker
        self.doubleClickWindow = doubleClickWindow
    }

    func add(_ observer: PomodoroObserver) {
        observers.append(observer)
        observer.timerDidChange(timer)
    }

    func start() {
        apply { $0.start() }
    }

    func handleDockClick() {
        if pendingClick != nil {
            pendingClick?.cancel()
            pendingClick = nil
            restart()
            return
        }

        let window = doubleClickWindow
        pendingClick = Task { [weak self] in
            try? await Task.sleep(for: window)
            guard !Task.isCancelled, let self else { return }
            self.pendingClick = nil
            self.apply { $0.togglePause() }
        }
    }

    private func tick() {
        guard let outcome = timer.tick() else { return }
        if outcome == .completed {
            ticker.cancel()
            observers.forEach { $0.timerDidComplete() }
        }
        notifyObservers()
    }

    private func apply(_ change: (inout PomodoroTimer) -> Void) {
        change(&timer)
        if timer.state == .running {
            ticker.start(interval: 1) { [weak self] in self?.tick() }
        } else {
            ticker.cancel()
        }
        notifyObservers()
    }

    private func notifyObservers() {
        observers.forEach { $0.timerDidChange(timer) }
    }
}

extension PomodoroSession: PomodoroCommands {
    func restart() {
        pendingClick?.cancel()
        pendingClick = nil
        apply { $0.restart() }
    }

    func stop() {
        apply { $0.stop() }
    }
}
