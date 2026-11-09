import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Quickshell.Networking
import qs
import qs.components
import qs.services
import "../lib/menus.js" as Menus
import "../lib/clock.js" as Clock
import "../lib/state.js" as State

// macOS 26+ menu bar: transparent, white text over the wallpaper.
ShellWindow {
    id: bar

    required property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true }
    implicitHeight: Theme.menuBar.height
    color: Theme.color.menuBarBackground
    namespace: "hyprk-menubar"
    WlrLayershell.layer: WlrLayer.Top

    readonly property string appId: Apps.appIdOf(Hyprland.activeToplevel)
    readonly property var appMenus: Menus.forApp(appId)
    readonly property color fg: Theme.color.menuBarText

    // ---------- left: Apple + app name + menus ----------
    Row {
        id: left
        anchors.left: parent.left
        anchors.leftMargin: Theme.menuBar.sidePadding - Theme.menuBar.titleHPadding
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.menuBar.titleSpacing

        MenuTitle {
            menuIndex: 0
            Symbol {
                anchors.centerIn: parent
                name: "apple"
                size: Theme.menuBar.appleLogoSize + 2
                color: bar.fg
            }
            contentWidth: Theme.menuBar.appleLogoSize + 2
        }
        MenuTitle {
            menuIndex: 1
            text: Apps.activeAppName()
            bold: true
        }
        Repeater {
            model: bar.appMenus
            MenuTitle {
                required property var modelData
                required property int index
                text: modelData.title
                menuIndex: index + 2
            }
        }
    }

    // ---------- right: status items + clock ----------
    readonly property var wifiDev: State.wifiDevice(Networking.devices.values)
    readonly property bool laptop: State.hasBattery(UPower.devices.values)

    Row {
        anchors.right: parent.right
        anchors.rightMargin: Theme.menuBar.sidePadding - Theme.menuBar.statusHPadding
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.menuBar.statusSpacing

        // Battery: hidden on desktops (no system battery)
        StatusItem {
            visible: bar.laptop
            contentWidth: batteryRow.implicitWidth
            Row {
                id: batteryRow
                anchors.centerIn: parent
                spacing: 4
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(UPower.displayDevice.percentage * 100) + "%"
                    color: bar.fg
                    font.family: Theme.fontText
                    font.pixelSize: Theme.font.menuBar - 1
                }
                Item {
                    width: Theme.menuBar.statusIconSize + 8
                    height: Theme.menuBar.statusIconSize + 8
                    anchors.verticalCenter: parent.verticalCenter
                    Symbol { anchors.fill: parent; name: "battery"; size: parent.width; color: bar.fg }
                    Rectangle {   // charge level inside the outline (x 2.5..19.5 of 24)
                        x: parent.width * 4 / 24
                        y: parent.height * 9 / 24
                        height: parent.height * 6 / 24
                        width: parent.width * 14 / 24 * UPower.displayDevice.percentage
                        radius: 1.5
                        color: UPower.displayDevice.percentage < 0.2 ? Theme.color.red : bar.fg
                    }
                }
            }
        }
        // Wi-Fi: hidden without a NetworkManager wifi device
        StatusItem {
            visible: bar.wifiDev !== null
            Symbol {
                anchors.centerIn: parent
                name: bar.wifiDev && bar.wifiDev.connected ? "wifi" : "wifi.slash"
                size: Theme.menuBar.statusIconSize
                color: bar.fg
                opacity: bar.wifiDev && bar.wifiDev.connected ? 1 : 0.5
            }
            onClicked: Panels.toggle("cc")
        }
        // Focus: shown only while Do Not Disturb is on, like macOS
        StatusItem {
            visible: Notifs.dnd
            Symbol { anchors.centerIn: parent; name: "moon"; size: Theme.menuBar.statusIconSize - 1; color: bar.fg }
            onClicked: Panels.toggle("cc")
        }
        StatusItem {
            Symbol { anchors.centerIn: parent; name: "magnifyingglass"; size: Theme.menuBar.statusIconSize - 1; color: bar.fg }
            onClicked: Panels.toggle("spotlight")
        }
        StatusItem {
            active: Panels.open === "cc"
            Symbol { anchors.centerIn: parent; name: "controlcenter"; size: Theme.menuBar.statusIconSize; color: bar.fg }
            onClicked: Panels.toggle("cc")
        }
        StatusItem {
            active: Panels.open === "nc"
            contentWidth: clockText.implicitWidth
            Text {
                id: clockText
                anchors.centerIn: parent
                text: Clock.format(clock.date)
                color: bar.fg
                font.family: Theme.fontText
                font.pixelSize: Theme.font.clock
            }
            onClicked: Panels.toggle("nc")
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // ---------- inline components ----------
    component MenuTitle: Item {
        id: mt
        property int menuIndex: -1
        property string text
        property bool bold: false
        property real contentWidth: label.implicitWidth
        default property alias content: holder.data
        readonly property bool open: Panels.open === "menu" && Panels.menuIndex === menuIndex

        width: contentWidth + Theme.menuBar.titleHPadding * 2
        height: Theme.menuBar.titleHeight

        Rectangle {
            anchors.fill: parent
            radius: Theme.menuBar.titleRadius
            color: Theme.color.menuBarHighlight
            opacity: mt.open ? 1 : 0
        }
        Text {
            id: label
            anchors.centerIn: parent
            visible: mt.text !== ""
            text: mt.text
            color: bar.fg
            font.family: Theme.fontText
            font.pixelSize: Theme.font.menuBar
            font.weight: mt.bold ? Theme.font.bold : Theme.font.regular
        }
        Item { id: holder; anchors.fill: parent }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onPressed: {
                if (mt.open) Panels.close();
                else Panels.openMenu(mt.menuIndex, mt.mapToItem(null, 0, 0).x);
            }
            // macOS: while any menu is open, hovering another title switches to it
            onEntered: if (Panels.open === "menu" && !mt.open) Panels.openMenu(mt.menuIndex, mt.mapToItem(null, 0, 0).x)
        }
    }

    component StatusItem: Item {
        id: si
        property bool active: false
        property real contentWidth: Theme.menuBar.statusIconSize
        default property alias content: sholder.data
        signal clicked()

        width: contentWidth + Theme.menuBar.statusHPadding * 2
        height: Theme.menuBar.titleHeight

        Rectangle {
            anchors.fill: parent
            radius: Theme.menuBar.titleRadius
            color: Theme.color.menuBarHighlight
            opacity: si.active || sma.pressed ? 1 : 0
        }
        Item { id: sholder; anchors.fill: parent }
        MouseArea { id: sma; anchors.fill: parent; onClicked: si.clicked() }
    }
}
