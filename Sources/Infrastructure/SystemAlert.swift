import Cocoa

@MainActor
final class SystemAlert: PomodoroObserver {
    func timerDidChange(_ timer: PomodoroTimer) {}

    func timerDidComplete() {
        NSSound(named: "Glass")?.play()
        NSApp.requestUserAttention(.informationalRequest)
    }
}
