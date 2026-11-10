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
import qs.HyprK
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
    // 12/24h and date order follow the time locale like macOS (LC_ALL > LC_TIME > LANG)
    readonly property var clockStyle: Clock.styleFor(Quickshell.env("LC_ALL") || Quickshell.env("LC_TIME") || Quickshell.env("LANG"))

    // ---------- left: distro logo (the Apple menu) + app name + menus ----------
    Row {
        id: left
        anchors.left: parent.left
        anchors.leftMargin: Theme.menuBar.sidePadding - Theme.menuBar.titleHPadding
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.menuBar.titleSpacing

        MenuTitle {
            menuIndex: 0
            DistroLogo {
                anchors.centerIn: parent
                size: Theme.menuBar.logoSize
                color: bar.fg
            }
            contentWidth: Theme.menuBar.logoSize
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
        // Wi-Fi: always shown like macOS; slashed and dimmed when off or absent
        StatusItem {
            Symbol {
                anchors.centerIn: parent
                name: bar.wifiDev && bar.wifiDev.connected ? "wifi" : "wifi.slash"
                size: Theme.menuBar.statusIconSize
                color: bar.fg
                opacity: bar.wifiDev && bar.wifiDev.connected ? 1 : 0.5
            }
            onClicked: Panels.toggle("cc", bar.screen)
        }
        // Focus: shown only while Do Not Disturb is on, like macOS
        StatusItem {
            visible: Notifs.dnd
            Symbol { anchors.centerIn: parent; name: "moon"; size: Theme.menuBar.statusIconSize - 1; color: bar.fg }
            onClicked: Panels.toggle("cc", bar.screen)
        }
        StatusItem {
            Symbol { anchors.centerIn: parent; name: "magnifyingglass"; size: Theme.menuBar.statusIconSize - 1; color: bar.fg }
            onClicked: Panels.toggle("spotlight")
        }
        StatusItem {
            active: Panels.open === "cc" && Panels.activeScreen === bar.screen
            Symbol { anchors.centerIn: parent; name: "controlcenter"; size: Theme.menuBar.statusIconSize; color: bar.fg }
            onClicked: Panels.toggle("cc", bar.screen)
        }
        StatusItem {
            active: Panels.open === "nc" && Panels.activeScreen === bar.screen
            contentWidth: clockText.implicitWidth
            Text {
                id: clockText
                anchors.centerIn: parent
                text: Clock.format(clock.date, bar.clockStyle)
                color: bar.fg
                font.family: Theme.fontText
                font.pixelSize: Theme.font.clock
            }
            onClicked: Panels.toggle("nc", bar.screen)
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
        readonly property bool open: Panels.open === "menu" && Panels.menuIndex === menuIndex && Panels.activeScreen === bar.screen

        width: contentWidth + Theme.menuBar.titleHPadding * 2
        height: Theme.menuBar.titleHeight

        HighlightPill { shown: mt.open; pressed: titleMa.containsPress; instant: true }
        Text {
            id: label
            anchors.centerIn: parent
            visible: mt.text !== ""
            text: mt.text
            color: bar.fg
            font.family: Theme.fontText
            font.pixelSize: Theme.font.menuBar
            // bold app name: DemiBold + wght 700, not Font.Bold (Qt fakes bold on top of SF Pro's variable
            // Bold instance, see AlertDialog.qml)
            font.weight: mt.bold ? Theme.font.semibold : Theme.font.regular
            font.variableAxes: mt.bold ? ({ "wght": 700 }) : ({})
        }
        Item { id: holder; anchors.fill: parent }
        MouseArea {
            id: titleMa
            anchors.fill: parent
            hoverEnabled: true
            onPressed: {
                if (mt.open) Panels.close();
                else Panels.openMenu(mt.menuIndex, mt.mapToItem(null, 0, 0).x, bar.screen);
            }
            // macOS: while any menu is open, hovering another title switches to it
            onEntered: if (Panels.open === "menu" && !mt.open && Panels.activeScreen === bar.screen) Panels.openMenu(mt.menuIndex, mt.mapToItem(null, 0, 0).x, bar.screen)
        }
    }

    // open/hovered state of a title or status item: a small glass capsule (macOS 26+) that
    // materializes in and out and lifts while pressed (interactive glass, ultraSmall preset).
    // The Glass (and its Region) exists only while shown or animating, not one per title.
    // `instant` (menu titles): the highlight follows the open menu at once like the menu itself
    // (LIVE-27.2.1.md: a menu opens without animation), so moving across the titles never shows
    // two pills or a pill still materializing; it goes away with no fade when another title takes
    // over, and fades with the menu (0.2 s OutQuad, Theme.anim.menuFadeOut) on the final close.
    // That the title fades along with its menu is guessed (MAC-REQUESTS.md R2 asks).
    component HighlightPill: Item {
        id: hp
        property bool shown: false
        property bool pressed: false
        property bool instant: false
        anchors.fill: parent
        Materializer { id: pm; shown: hp.shown && !hp.instant }
        // instant mode: 1 while shown, cut to 0 when another menu took over, else fades out
        property real fade: 0
        NumberAnimation { id: pillFade; target: hp; property: "fade"; to: 0; duration: Theme.anim.menuFadeOut; easing.type: Easing.OutQuad }
        onShownChanged: {
            if (!instant) return;
            pillFade.stop();
            if (shown) fade = 1;
            else if (Panels.open === "menu") fade = 0;
            else pillFade.start();
        }
        Component.onCompleted: if (instant && shown) fade = 1
        readonly property real progress: instant ? fade : pm.progress
        PressSpring { id: pp; pressed: hp.pressed && hp.shown; w: hp.width; h: hp.height }
        transform: Scale {
            origin.x: hp.width / 2
            origin.y: hp.height / 2
            xScale: (hp.instant ? 1 : pm.scaleFor(hp.width)) * pp.scale
            yScale: (hp.instant ? 1 : pm.scaleFor(hp.height)) * pp.scale
        }
        Loader {
            anchors.fill: parent
            active: hp.instant ? hp.shown || hp.fade > 0 : pm.active
            sourceComponent: Glass {
                radius: Theme.menuBar.titleRadius
                // the bar sits at the screen origin, so the scene position is the screen position
                // re-evaluated when the title/status item moves inside its Row
                readonly property point pos: hp.parent.x + hp.parent.y >= -1e9 ? hp.parent.mapToItem(null, 0, 0) : Qt.point(0, 0)   // parent: no materialize/press scale
                onPosChanged: remeasure()
                sx: pos.x
                sy: pos.y
                tint: Theme.color.menuBarHighlight
                pluginLift: Theme.color.menuBarHighlight
                shadow: false
                materialize: hp.progress
            }
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

        // macOS 27 status items: the pill shows on hover too
        HighlightPill { shown: si.active || sma.containsMouse || sma.pressed; pressed: sma.containsPress }
        Item { id: sholder; anchors.fill: parent }
        MouseArea { id: sma; anchors.fill: parent; hoverEnabled: true; onClicked: si.clicked() }
    }
}
