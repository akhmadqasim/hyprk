import QtQuick
import Quickshell.Services.UPower
import Quickshell.Networking
import qs
import qs.HyprK
import qs.components
import qs.services
import "../../lib/state.js" as State

// Status items at the top right of the lock screen (LOCKSCREEN-27.2.1.md A7), right to left: Wi-Fi (26 pt),
// battery (28 pt, laptops only), the input source ("ABC" + keyboard glyph, 54 pt; a click switches to the next
// layout). Right margin 19, gaps 12, y 8 to 25, white, no background. Same services and glyphs as the menu bar.
Row {
    id: s
    property bool interactive: false
    readonly property var wifiDev: State.wifiDevice(Networking.devices.values)
    readonly property bool laptop: Hardware.battery

    layoutDirection: Qt.RightToLeft
    spacing: LockTheme.statusGap
    height: LockTheme.statusRowHeight

    Item {
        visible: Hardware.wifi   // no Wi-Fi adapter: not drawn, as in the menu bar
        width: LockTheme.wifiWidth
        height: s.height
        Symbol {
            anchors.centerIn: parent
            name: s.wifiDev && s.wifiDev.connected ? "wifi" : "wifi.slash"
            size: LockTheme.statusGlyph
            color: LockTheme.statusColor
        }
    }
    Item {
        visible: s.laptop
        width: LockTheme.batteryWidth
        height: s.height
        BatteryIcon {   // the 26 x 14 bitmap macOS draws, as in the menu bar
            anchors.centerIn: parent
            level: UPower.displayDevice.percentage
            charging: UPower.displayDevice.state === UPowerDeviceState.Charging
            color: LockTheme.statusColor
        }
    }
    Item {
        visible: Lock.layoutLabel !== ""
        width: Math.max(LockTheme.inputWidth, input.implicitWidth)
        height: s.height
        Row {
            id: input
            anchors.centerIn: parent
            spacing: 4
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Lock.layoutLabel
                font: Typography.font(LockTheme.inputTextSize, Typography.medium)
                color: LockTheme.statusColor
            }
            Symbol {
                anchors.verticalCenter: parent.verticalCenter
                name: "keyboard"
                size: LockTheme.statusGlyph
                color: LockTheme.statusColor
            }
        }
        MouseArea { anchors.fill: parent; enabled: s.interactive; onClicked: Lock.nextLayout() }
    }
}
