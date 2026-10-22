import Foundation

@MainActor
final class RunLoopTicker: Ticker {
    private var timer: Timer?

    func start(interval: TimeInterval, onTick: @escaping @MainActor () -> Void) {
        cancel()
        let newTimer = Timer(timeInterval: interval, repeats: true) { _ in
            MainActor.assumeIsolated { onTick() }
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
    }
}
