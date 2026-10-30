import IOKit.pwr_mgt

@MainActor
protocol WakeLockControlling: AnyObject {
    var isDisplayAwakeLockEnabled: Bool { get }
    func toggleDisplayAwakeLock()
}

@MainActor
final class DisplayWakeLock: WakeLockControlling {
    private(set) var isDisplayAwakeLockEnabled = false
    private var assertionID: IOPMAssertionID = 0

    func toggleDisplayAwakeLock() {
        isDisplayAwakeLockEnabled ? disable() : enable()
    }

    private func enable() {
        var id: IOPMAssertionID = 0
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Pomodoro mantiene la pantalla encendida" as CFString,
            &id
        )
        guard result == kIOReturnSuccess else { return }
        assertionID = id
        isDisplayAwakeLockEnabled = true
    }

    private func disable() {
        IOPMAssertionRelease(assertionID)
        isDisplayAwakeLockEnabled = false
    }
}
