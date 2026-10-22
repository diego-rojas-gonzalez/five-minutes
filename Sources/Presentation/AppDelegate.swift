import Cocoa

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let session = PomodoroSession(ticker: RunLoopTicker())
    private var menu: PomodoroMenu!
    private var menuBar: MenuBarPresenter!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.mainMenu = makeMainMenu()
        menu = PomodoroMenu(commands: session)
        menuBar = MenuBarPresenter(menu: menu)

        session.add(DockIconPresenter())
        session.add(menuBar)
        session.add(SystemAlert())
        session.start()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        session.handleDockClick()
        return true
    }

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        menu.makeMenu()
    }

    private func makeMainMenu() -> NSMenu {
        let mainMenu = NSMenu()
        let appItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Salir de Pomodoro", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appItem.submenu = appMenu
        mainMenu.addItem(appItem)
        return mainMenu
    }
}
