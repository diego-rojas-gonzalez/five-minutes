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
    func togglePause()
}

@MainActor
final class PomodoroSession {
    private(set) var timer = PomodoroTimer()

    private let ticker: Ticker
    private var observers: [PomodoroObserver] = []

    init(ticker: Ticker) {
        self.ticker = ticker
    }

    func add(_ observer: PomodoroObserver) {
        observers.append(observer)
        observer.timerDidChange(timer)
    }

    func start() {
        apply { $0.start() }
    }

    func handleDockClick() {
        restart()
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
        apply { $0.restart() }
    }

    func stop() {
        apply { $0.stop() }
    }

    func togglePause() {
        apply { $0.togglePause() }
    }
}
