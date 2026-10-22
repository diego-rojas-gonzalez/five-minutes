import Cocoa

enum DockIconRenderer {
    private static let canvas: CGFloat = 512

    static func image(for timer: PomodoroTimer) -> NSImage {
        let minutes = timer.minutes
        let seconds = timer.seconds
        let paused = timer.state == .paused

        return NSImage(size: NSSize(width: canvas, height: canvas), flipped: false) { rect in
            let body = rect.insetBy(dx: 48, dy: 48)
            let shape = NSBezierPath(roundedRect: body, xRadius: 92, yRadius: 92)

            let background = paused
                ? NSColor(calibratedRed: 0.078, green: 0.078, blue: 0.075, alpha: 1)
                : NSColor(calibratedRed: 0.918, green: 0.392, blue: 0.235, alpha: 1)
            let textColor = paused
                ? NSColor(calibratedRed: 0.933, green: 0.933, blue: 0.933, alpha: 1)
                : NSColor.white
            background.setFill()
            shape.fill()

            let minuteFont = NSFont.monospacedDigitSystemFont(ofSize: 300, weight: .bold)
            let secondFont = NSFont.monospacedDigitSystemFont(ofSize: 210, weight: .semibold)
            let gap: CGFloat = 24
            let stackHeight = minuteFont.capHeight + gap + secondFont.capHeight
            let minuteBaseline = canvas / 2 + stackHeight / 2 - minuteFont.capHeight
            let secondBaseline = minuteBaseline - gap - secondFont.capHeight

            drawCentered(String(format: "%02d", minutes), font: minuteFont, color: textColor,
                         baseline: minuteBaseline, in: rect)
            drawCentered(String(format: "%02d", seconds), font: secondFont, color: textColor,
                         baseline: secondBaseline, in: rect)
            return true
        }
    }

    private static func drawCentered(_ text: String, font: NSFont, color: NSColor,
                                     baseline: CGFloat, in rect: NSRect) {
        let string = NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
        let size = string.size()
        string.draw(at: NSPoint(x: rect.midX - size.width / 2, y: baseline + font.descender))
    }
}

@MainActor
final class DockIconPresenter: PomodoroObserver {
    func timerDidChange(_ timer: PomodoroTimer) {
        NSApp.applicationIconImage = DockIconRenderer.image(for: timer)
    }

    func timerDidComplete() {}
}
