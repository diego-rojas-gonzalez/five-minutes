import Cocoa

@MainActor
final class PomodoroMenu: NSObject, PomodoroObserver {
    private weak var commands: PomodoroCommands?
    private var currentState: PomodoroTimer.State = .ready

    private let menu = NSMenu()
    private let headerItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let pauseItem = NSMenuItem(title: "Pausar", action: #selector(togglePause), keyEquivalent: "")
    private let restartItem = NSMenuItem(title: "Reiniciar", action: #selector(restart), keyEquivalent: "")
    private let stopItem = NSMenuItem(title: "Detener", action: #selector(stop), keyEquivalent: "")

    init(commands: PomodoroCommands) {
        self.commands = commands
        super.init()

        headerItem.isEnabled = false

        for item in [pauseItem, restartItem, stopItem] {
            item.target = self
        }
        pauseItem.image = symbol("pause.circle")
        restartItem.image = symbol("arrow.clockwise.circle")
        stopItem.image = symbol("stop.circle")

        menu.addItem(headerItem)
        menu.addItem(.separator())
        menu.addItem(pauseItem)
        menu.addItem(restartItem)
        menu.addItem(stopItem)
    }

    func makeMenu() -> NSMenu {
        menu
    }

    func timerDidChange(_ timer: PomodoroTimer) {
        currentState = timer.state

        let statusLabel: String
        let statusIcon: String
        switch timer.state {
        case .running:
            statusLabel = "En curso"
            statusIcon = "timer"
        case .paused:
            statusLabel = "En pausa"
            statusIcon = "pause.circle.fill"
        case .ready:
            statusLabel = "Detenido"
            statusIcon = "stop.circle.fill"
        }
        headerItem.title = "\(statusLabel) · \(timer.clockText)"
        headerItem.image = symbol(statusIcon)

        let canResume = timer.state != .running
        pauseItem.title = canResume ? "Reanudar" : "Pausar"
        pauseItem.image = symbol(canResume ? "play.circle" : "pause.circle")
        stopItem.isEnabled = timer.state != .ready
    }

    func timerDidComplete() {}

    private func symbol(_ name: String) -> NSImage? {
        NSImage(systemSymbolName: name, accessibilityDescription: nil)
    }

    @objc private func togglePause() {
        if currentState == .ready {
            commands?.restart()
        } else {
            commands?.togglePause()
        }
    }

    @objc private func restart() {
        commands?.restart()
    }

    @objc private func stop() {
        commands?.stop()
    }
}
