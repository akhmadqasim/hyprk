import QtQuick
import QtQuick.Effects
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

// macOS 27 menu bar: no background and no glass of its own. It always shows the desktop picture (windows
// stay below it), with text coloured for the wallpaper behind it, not for the appearance
// (reference/re/MAC-ANSWERS.md Q9.1). The top dimming of bright wallpapers is drawn by Background.qml.
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
    readonly property var wifiNet: wifiDev ? wifiDev.networks.values.find(n => n.connected) || null : null
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
                    font: Typography.font(12)   // battery percentage, 12 by eye (not measured)
                }
                BatteryIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    level: UPower.displayDevice.percentage
                    charging: UPower.displayDevice.state === UPowerDeviceState.Charging
                    color: bar.fg
                }
            }
        }
        // Wi-Fi: always shown like macOS; slashed and dimmed when off or absent
        StatusItem {
            Symbol {
                anchors.centerIn: parent
                name: bar.wifiDev && bar.wifiDev.connected ? "wifi" : "wifi.slash"
                surface: "menubar"
                size: Theme.menuBar.statusIconSize
                variableValue: bar.wifiNet ? bar.wifiNet.signalStrength : -1   // 0..1 -> bars lit (sf.js pick)
                color: bar.fg
                opacity: bar.wifiDev && bar.wifiDev.connected ? 1 : 0.5
            }
            onClicked: Panels.toggle("cc", bar.screen)
        }
        // Focus: shown only while Do Not Disturb is on, like macOS
        StatusItem {
            visible: Notifs.dnd
            Symbol { anchors.centerIn: parent; name: "moon"; surface: "menubar"; size: Theme.menuBar.statusIconSize - 1; color: bar.fg }
            onClicked: Panels.toggle("cc", bar.screen)
        }
        StatusItem {
            Symbol { anchors.centerIn: parent; name: "magnifyingglass"; surface: "menubar"; size: Theme.menuBar.statusIconSize - 1; color: bar.fg }
            onClicked: Panels.toggle("spotlight")
        }
        StatusItem {
            // lit while Control Center is open and while the volume/brightness HUD shows (it hangs under this item)
            active: (Panels.open === "cc" && Panels.activeScreen === bar.screen) || (Hud.shown && Hud.screen === bar.modelData)
            Symbol { anchors.centerIn: parent; name: "controlcenter"; surface: "menubar"; size: Theme.menuBar.statusIconSize; color: bar.fg }
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
                font: Typography.menuBar
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

        // the pill moves at once; the dropdown follows a few frames later (Panels.stepMenu)
        HighlightPill {
            shown: mt.open
            pressed: titleMa.containsPress
            instant: true
        }
        Text {
            id: label
            anchors.centerIn: parent
            visible: mt.text !== ""
            text: mt.text
            color: bar.fg
            // menuBarFont 13; the app name in bold (boldSystemFont 13, real wght 700: Typography)
            font: mt.bold ? Typography.systemBold : Typography.menuBar
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

    // open/hovered state of a title or status item: a capsule of blurred, brightened desktop picture
    // with a faint shadow, the same in light and dark (MAC-ANSWERS.md Q9.1, measured over a checker and
    // over solid blue). It materializes in and out and lifts while pressed (interactive glass, ultraSmall
    // preset). Nothing but the wallpaper is ever under the bar, so the pre-blurred wallpaper that the
    // QML glass samples is the exact backdrop: no compositor glass region, and no per-frame work while
    // it stands still. The pill exists only while shown or animating, not one per title.
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
            sourceComponent: Item {
                opacity: Math.max(0, hp.progress)
                // faint shadow under the pill: 206 -> 196 just below it over solid blue (measured);
                // offset and blur guessed
                RectangularShadow {
                    anchors.fill: parent
                    radius: Theme.menuBar.titleRadius
                    offset.y: 1
                    blur: 2
                    color: Theme.color.menuBarPillShadow
                }
                Rectangle {   // Reduce transparency / no blurred wallpaper
                    anchors.fill: parent
                    visible: Theme.solidMaterial
                    radius: Theme.menuBar.titleRadius
                    color: Theme.glass.solid
                }
                // the pre-blurred wallpaper under the pill, with the same top dimming as the desktop
                // (shaders/topdim.frag), brightened and cut to the capsule in one pass
                Image {
                    id: pillBackdrop
                    visible: false
                    source: Theme.solidMaterial ? "" : Wallpaper.blurredUrl
                    sourceSize: Qt.size(Wallpaper.width, Wallpaper.height)
                    cache: true
                }
                ShaderEffect {
                    anchors.fill: parent
                    visible: !Theme.solidMaterial && pillBackdrop.status === Image.Ready
                    // the bar sits at the screen origin, so the scene position is the screen position;
                    // re-evaluated when the title/status item moves inside its Row
                    readonly property point pos: hp.parent.x + hp.parent.y >= -1e9 ? hp.parent.mapToItem(null, 0, 0) : Qt.point(0, 0)   // parent: no materialize/press scale
                    property var src: pillBackdrop
                    // the blurred wallpaper covers the whole screen: map by this bar's screen size
                    readonly property size screenSize: Qt.size(bar.width, bar.screen ? bar.screen.height : Wallpaper.height)
                    property rect srcRect: Qt.rect(pos.x / screenSize.width, pos.y / screenSize.height,
                                                   width / screenSize.width, height / screenSize.height)
                    property size sizePt: Qt.size(width, height)
                    property real topPt: pos.y
                    property real radius: Theme.menuBar.titleRadius
                    property real saturation: Theme.menuBar.pillSaturation
                    property real gain: Theme.menuBar.pillGain
                    fragmentShader: Qt.resolvedUrl("../shaders/topdim.frag.qsb")
                }
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
