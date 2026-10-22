import Cocoa

extension PomodoroTimer {
    var clockText: String {
        String(format: "%02d:%02d", minutes, seconds)
    }
}

@MainActor
final class MenuBarPresenter: PomodoroObserver {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    init(menu: PomodoroMenu) {
        statusItem.button?.font = .monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        statusItem.menu = menu.makeMenu()
    }

    func timerDidChange(_ timer: PomodoroTimer) {
        statusItem.button?.title = timer.clockText
    }

    func timerDidComplete() {}
}
