import Cocoa

@MainActor
final class PomodoroMenu: NSObject {
    private weak var commands: PomodoroCommands?

    init(commands: PomodoroCommands) {
        self.commands = commands
        super.init()
    }

    func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(makeItem(title: "Reiniciar", action: #selector(restart)))
        menu.addItem(makeItem(title: "Detener", action: #selector(stop)))
        return menu
    }

    private func makeItem(title: String, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        return item
    }

    @objc private func restart() {
        commands?.restart()
    }

    @objc private func stop() {
        commands?.stop()
    }
}
