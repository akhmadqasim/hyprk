import QtQuick
import ".."
import "../HyprK"

// The small spinning progress indicator (27.2.1 AX BusyIndicator 16 x 16: Software Update's "Checking for updates…",
// Storage's "Calculating…" rows; live/settings-r12/nav-general--softwareUpdate-dark.png: ink 16 x 16 pt, eight spokes,
// the strongest at the secondary label's level, 155 on the card's 37). It turns a spoke at a time, as
// NSProgressIndicator's spinning style; still under Reduce motion.
Item {
    id: spinner
    property bool running: true
    property color color: Theme.secondaryLabel
    property int step: 0
    width: 16; height: 16
    Repeater {
        model: 8
        Rectangle {
            required property int index
            x: 7; y: 0; width: 2; height: 5; radius: 1
            color: spinner.color
            opacity: 1 - ((spinner.step - index + 8) % 8) / 9
            antialiasing: true
            transform: Rotation { origin.x: 1; origin.y: 8; angle: index * 45 }
        }
    }
    Timer { running: spinner.running && spinner.visible && !Tokens.reduceMotion; interval: 125; repeat: true; onTriggered: spinner.step = (spinner.step + 1) % 8 }
}
