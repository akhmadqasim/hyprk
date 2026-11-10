import QtQuick
import Quickshell.Services.UPower
import Quickshell.Networking
import qs
import qs.components
import "../../lib/state.js" as State

// Status items at the top right of the lock screen, right to left: battery (laptops only), Wi-Fi,
// input source (only with more than one keyboard layout; a click switches to the next one).
// Same services and glyphs as the menu bar; waiting for Q-lockscreen-16 / -17.
Row {
    id: s
    property bool interactive: false
    readonly property var wifiDev: State.wifiDevice(Networking.devices.values)
    readonly property bool laptop: State.hasBattery(UPower.devices.values)

    layoutDirection: Qt.RightToLeft
    spacing: LockTheme.statusGap

    Item {
        visible: s.laptop
        width: LockTheme.statusBox
        height: LockTheme.statusBox
        Item {
            anchors.centerIn: parent
            width: LockTheme.statusGlyph + 8
            height: LockTheme.statusGlyph + 8
            Symbol { anchors.fill: parent; name: "battery"; size: parent.width; color: LockTheme.statusColor }
            Rectangle {   // charge level inside the outline, as in the menu bar
                x: parent.width * 4 / 24
                y: parent.height * 9 / 24
                height: parent.height * 6 / 24
                width: parent.width * 14 / 24 * UPower.displayDevice.percentage
                radius: 1.5
                color: UPower.displayDevice.percentage < 0.2 ? Theme.color.red : LockTheme.statusColor
            }
        }
    }
    Item {
        width: LockTheme.statusBox
        height: LockTheme.statusBox
        Symbol {
            anchors.centerIn: parent
            name: s.wifiDev && s.wifiDev.connected ? "wifi" : "wifi.slash"
            size: LockTheme.statusGlyph
            color: LockTheme.statusColor
            opacity: s.wifiDev && s.wifiDev.connected ? 1 : 0.5
        }
    }
    Item {
        visible: Lock.layoutLabel !== ""
        width: Math.max(LockTheme.statusBox, label.implicitWidth + 10)
        height: LockTheme.statusBox
        Rectangle {
            anchors.centerIn: parent
            width: label.implicitWidth + 8
            height: LockTheme.statusGlyph
            radius: 4
            color: "transparent"
            border.width: 1.2
            border.color: LockTheme.statusColor
        }
        Text {
            id: label
            anchors.centerIn: parent
            text: Lock.layoutLabel
            font.family: Theme.fontText
            font.pixelSize: LockTheme.layoutTextSize
            font.weight: Font.DemiBold
            color: LockTheme.statusColor
        }
        MouseArea { anchors.fill: parent; enabled: s.interactive; onClicked: Lock.nextLayout() }
    }
}
