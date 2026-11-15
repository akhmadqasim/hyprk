import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// General > Startup Disk (27.2.1, live/settings-r12/nav-general--startupDisk-dark.png, ax-nav-...; an AppKit view): one
// card right under the toolbar (y 52, 286 tall): the prompt, a hairline at 40, the selected system's tile 150 x 179
// (its 98 pt icon, the disk's name, the system), a hairline at 242, the selection line and Restart…; Help 19 below.
// The system is this computer's (/etc/os-release) on "/" (settings/FALLBACKS.md "General"); the Mac's disk picture is
// not extracted, so the tile has none. Restart… stays without action: the Mac asks for a password first (R12.3).
Column {
    id: page
    property var pane
    spacing: Theme.content.sectionGap
    property string os: ""
    Component.onCompleted: Backend.readText("/etc/os-release", t => { const m = /^PRETTY_NAME="?([^"\n]*)/m.exec(t); if (m) try { page.os = m[1]; } catch (e) {} })
    Item {
        width: parent.width; height: 286 - Theme.content.top + 9
        Rectangle {
            y: -Theme.content.top; width: parent.width; height: 286
            radius: Theme.content.cardRadius; color: Theme.cardFill; border.color: Theme.cardStroke
            MacText { x: 9; y: 11; text: "Select the system you want to use to start up your computer" }
            Rectangle { x: 10; y: 40; width: parent.width - 20; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); antialiasing: Pixel.soft(Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
            Rectangle {
                x: 159; y: 53; width: 150; height: 179; radius: 10
                color: Theme.dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08)
                MacText { anchors.horizontalCenter: parent.horizontalCenter; y: 128; text: "/" }
                MacText { anchors.horizontalCenter: parent.horizontalCenter; y: 147; width: 140; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight; text: page.os }
            }
            Rectangle { x: 10; y: 242; width: parent.width - 20; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); antialiasing: Pixel.soft(Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
            Text {
                x: 9; y: 256; width: 360; elide: Text.ElideRight
                text: page.os !== "" ? "You have selected " + page.os + " on the disk “/”." : ""
                font: Typography.callout; color: Theme.secondaryLabel
            }
            Button { x: parent.width - width - 9; y: 251; text: "Restart…" }
        }
    }
    PaneFooter { topPadding: 0 }
}
