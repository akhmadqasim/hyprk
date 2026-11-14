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
import qs.HyprK
import qs.services
import "../lib/menus.js" as Menus
import "../lib/clock.js" as Clock
import "../lib/state.js" as State

// macOS 27 menu bar: no background and no glass of its own. It always shows the desktop picture (windows
// stay below it), with text coloured for the wallpaper behind it, not for the appearance
// (reference/re/MAC-ANSWERS.md Q-menubar-02, -03). The contrast gradient behind it is drawn by Background.qml.
// Geometry from the 27.2.1 AX frames (Q-menubar-05, -09): titles = text + 10.5 a side, overlapping 1 pt.
ShellWindow {
    id: bar

    required property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true }
    implicitHeight: Theme.menuBar.height
    color: Theme.color.menuBarFill   // opaque only under Reduce Transparency
    namespace: "hyprk-menubar"
    // full screen: Hyprland hides Top layers on a full-screen workspace at once. On enter the bar fades out over
    // 0.15 s on Overlay; on exit it is shown again by Hyprland and fades in over 0.5 s from the start
    // (Theme.anim.menuBarFullscreen*; the Mac's curve is not decoded: CA's default ease-in-ease-out)
    readonly property var hyprMonitor: Hyprland.monitorFor(screen)
    // A real full screen only: a zoomed (maximized) window also sets the workspace's hasFullscreen, and the Mac keeps
    // menu bar and Dock for Zoom. Hyprland reports the two apart as toplevel states (ForeignToplevelWlr.cpp:
    // FSMODE_FULLSCREEN -> fullscreen, any other mode -> maximized), with the change, no IPC round trip.
    readonly property bool fullscreen: {
        const ws = hyprMonitor ? hyprMonitor.activeWorkspace : null;
        return !!ws && ws.hasFullscreen && ws.toplevels.values.some(t => t.wayland && t.wayland.fullscreen);
    }
    // Full screen below the bar strip (plugin-motion fullscreen_top: the notched Air keeps the 34 pt strip, black,
    // Q-menubar-33): the pointer at the top edge shows the titles and status items in place on the black and they go
    // when it leaves the bar ("peek"). Whether the window is below a strip is read from its top edge once per full
    // screen change; a true full screen (other outputs, not measured on the Mac) shows nothing.
    // `strip` follows the full-screen window's last IPC geometry: Hyprland answers refreshToplevels() later, so a
    // read right after the call could see the window as it was before the change and the peek never came for that
    // full screen (judge #4: 1 of 3 entries). It is asked again a few times while the window settles.
    readonly property var fsWindow: {
        const ws = hyprMonitor ? hyprMonitor.activeWorkspace : null;
        return fullscreen && ws ? ws.toplevels.values.find(t => t.lastIpcObject && t.lastIpcObject.fullscreen > 0) ?? null : null;
    }
    readonly property bool strip: !!fsWindow && !!fsWindow.lastIpcObject.at && fsWindow.lastIpcObject.at[1] - hyprMonitor.y >= height - 1
    readonly property bool peek: topHover.hovered && fullscreen && strip
    readonly property bool peeking: fullscreen && strip && (peek || (Panels.open === "menu" && Panels.activeScreen === screen))
    function askStrip() { stripRead.tries = 4; stripRead.interval = 50; stripRead.restart(); }
    Connections {
        target: bar.fullscreen ? Hyprland : null
        function onRawEvent(event: HyprlandEvent): void { if (event.name === "fullscreen") bar.askStrip(); }
    }
    Timer {
        id: stripRead
        property int tries: 0     // not `left`: that is the title row's id, and `--left` threw (the read ran once)
        onTriggered: { Hyprland.refreshToplevels(); if (--tries > 0) { interval = 250; restart(); } }
    }
    // set only by fade() (and once at start): a binding on `fullscreen` re-evaluated after the exit fade had started
    // and drew one frame at 1 (the titles at full alpha over the window's lights in the exit's first frame)
    property real fsAlpha: 1
    Component.onCompleted: fsAlpha = fullscreen ? 0 : 1
    // The peek's linear fades take one value per frame of this window (FrameClock, like the lock overlay): a
    // NumberAnimation's first frame repeated the start value (judge #4: 6 of 6), and a FrameAnimation ticked by Qt's
    // 16 ms timer lost one value in most fades (.20 -> .40, MOTION-MEASURED sessions 9 and 10)
    property real fadeFrom: 0
    property real fadeTo: 0
    property int fadeMs: 1
    FrameClock {
        id: fadeClock
        onTick: {
            // the first tick's frame is one interval into the fade: the frame before it shows the start value
            const p = Math.min(1, (elapsed + interval) / bar.fadeMs);
            bar.fsAlpha = bar.fadeFrom + (bar.fadeTo - bar.fadeFrom) * p;
            if (p >= 1) stop();
        }
    }
    function fade(to, ms, linear) {
        fsAnim.stop();
        fadeClock.stop();
        if (linear) {
            fadeFrom = fsAlpha; fadeTo = to; fadeMs = Math.max(1, Theme.ms(ms));
            fadeClock.start();
            return;
        }
        fsAnim.to = to;
        fsAnim.duration = Theme.ms(ms);
        fsAnim.start();
    }
    property bool peeked: false   // shown on the strip at least once in this full screen (white titles from then on)
    onFullscreenChanged: {
        peeked = false;
        if (fullscreen) askStrip(); else stripRead.stop();
        fade(fullscreen ? 0 : 1, fullscreen ? Theme.anim.menuBarFullscreenOut : Theme.anim.menuBarFullscreenIn, false);
    }
    onPeekingChanged: if (fullscreen) {
        if (peeking) peeked = true;
        fade(peeking ? 1 : 0, peeking ? Theme.anim.menuBarPeekIn : Theme.anim.menuBarPeekOut, true);
    }
    FrameAnim { id: fsAnim; target: bar; property: "fsAlpha"; curve: [0.42, 0, 0.58, 1, 1, 1] }
    Binding { target: bar.contentItem; property: "opacity"; value: bar.fsAlpha }
    // on Overlay for the whole full screen, taking input in its top 1 pt row until it shows: layer and input region
    // are sent with a frame, and nothing is drawn once it has faded out (whether there is a strip is known later)
    WlrLayershell.layer: fullscreen ? WlrLayer.Overlay : WlrLayer.Top
    inputMask: fullscreen && !peeking ? edgeRow : null
    Region { id: edgeRow; width: bar.width; height: 1 }
    HoverHandler { id: topHover }

    readonly property string appId: Apps.appIdOf(Apps.activeToplevel)
    readonly property var appMenus: Menus.forApp(appId)
    // on the black full-screen strip the dark-wallpaper colours (white titles)
    readonly property bool onBlack: fullscreen && peeked
    readonly property color fg: onBlack ? "#FFFFFF" : Theme.color.menuBarText          // titles
    readonly property color statusFg: onBlack ? Qt.rgba(1, 1, 1, 0.9) : Theme.color.menuBarStatusText   // status glyphs and the clock
    // 12/24h and date order follow the time locale like macOS (LC_ALL > LC_TIME > LANG)
    readonly property var clockStyle: Clock.styleFor(Quickshell.env("LC_ALL") || Quickshell.env("LC_TIME") || Quickshell.env("LANG"))

    // ---------- left: Apple logo (the Apple menu) + app name + menus ----------
    Row {
        id: left
        anchors.left: parent.left
        anchors.leftMargin: Theme.menuBar.leftMargin
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.menuBar.titleSpacing
        // the Overlay maps while the pointer is over the titles (Panels.warmScreen)
        HoverHandler {
            onHoveredChanged: {
                if (hovered) Panels.warmScreen = bar.modelData;
                else if (Panels.warmScreen === bar.modelData) Panels.warmScreen = null;
            }
        }

        MenuTitle {
            menuIndex: 0
            // the Mac's glyph: SF Pro U+F8FF at the measured ink box and position (Theme.menuBar.appleSize)
            Text {
                readonly property real s: Theme.menuBar.appleSize
                // ink x 95..1356 of 2048 units: centre the ink, not the advance, in the 13 pt content
                x: Theme.menuBar.titleHPadding + (Theme.menuBar.appleWidth - 1261 / 2048 * s) / 2 - 95 / 2048 * s
                y: Theme.menuBar.appleBaseline - baselineOffset
                text: ""
                color: bar.fg
                font.family: "SF Pro"
                font.pixelSize: s
            }
            contentWidth: Theme.menuBar.appleWidth
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

    // the menu title under window x, or null
    function titleAt(x) {
        const p = left.mapFromItem(null, x, height / 2);
        const t = left.childAt(p.x, p.y);
        return t && t.menuIndex !== undefined ? t : null;
    }

    // ---------- right: status items + clock ----------
    readonly property var wifiDev: State.wifiDevice(Networking.devices.values)
    readonly property var wifiNet: wifiDev ? wifiDev.networks.values.find(n => n.connected) || null : null
    readonly property bool laptop: State.hasBattery(UPower.devices.values) || Quickshell.env("HYPRK_STATUS_STUB") === "1"

    Row {
        anchors.right: parent.right
        anchors.rightMargin: Theme.menuBar.rightMargin
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.menuBar.statusSpacing

        // Battery: hidden on desktops (no system battery)
        // A click opens its ControlCenter module under the item (STATUS-REA-27.2.1.md; StatusModuleWindow.qml)
        StatusItem {
            visible: bar.laptop
            hPad: 0   // the battery glyph fills its item (Q-menubar-09)
            contentWidth: batteryRow.implicitWidth
            active: bar.moduleOpen("battery")
            onClicked: openModule("battery")
            Row {
                id: batteryRow
                anchors.centerIn: parent
                spacing: 4
                Text {
                    // the Mac hides the percentage by default (Q-menubar-29: no BatteryShowPercentage key, no text
                    // drawn); the Battery module's header shows it instead (STATUS-REA, BatteryView)
                    visible: false
                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(UPower.displayDevice.percentage * 100) + "%"
                    color: bar.statusFg
                    font: Typography.font(12)   // battery percentage, 12 by eye (not measured)
                }
                BatteryIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    level: UPower.displayDevice.percentage
                    charging: UPower.displayDevice.state === UPowerDeviceState.Charging
                    color: bar.statusFg
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
                color: bar.statusFg
                opacity: bar.wifiDev && bar.wifiDev.connected ? 1 : 0.5
            }
            active: bar.moduleOpen("wifi")
            onClicked: openModule("wifi")
        }
        // Focus: shown only while Do Not Disturb is on, like macOS
        StatusItem {
            visible: Notifs.dnd
            Symbol { anchors.centerIn: parent; name: "moon"; surface: "menubar"; size: Theme.menuBar.statusIconSize - 1; color: bar.statusFg }
            active: bar.moduleOpen("focus")
            onClicked: openModule("focus")
        }
        // Spotlight: -[SPUISpotlightMenuItem _handleStatusItemPress:] (0x2ade56b60, an NSPressGestureRecognizer): opens on
        // mouse-down; a click while it is open closes it on mouse-up; a press held 1.0 s (the NSTimer, 0x2ade56bcc)
        // keeps it open (reference/re/27.2.1/SPOTLIGHT-27.2.1.md section 3)
        StatusItem {
            id: spotItem
            function publish() { const p = mapToItem(null, 0, 0); if (bar.screen) Panels.setSpotlightItem(bar.screen.name, { x: p.x, w: width }); }
            // where it is when Spotlight opens (the status row is laid out from the right after this item is made)
            Connections { target: Panels; function onOpenChanged() { if (Panels.open === "spotlight") spotItem.publish(); } }
            property bool wasOpen: false
            property bool longPress: false
            Symbol { anchors.centerIn: parent; name: "magnifyingglass"; surface: "menubar"; size: Theme.menuBar.statusIconSize - 1; color: bar.statusFg }
            onPressedDown: {
                wasOpen = Panels.open === "spotlight";
                longPress = false;
                if (!wasOpen) Panels.toggle("spotlight");
                spotHold.restart();
            }
            onReleasedUp: {
                spotHold.stop();
                if (wasOpen && !longPress && Panels.open === "spotlight") Panels.close();
                wasOpen = false;
            }
            Timer { id: spotHold; interval: 1000; onTriggered: { spotItem.longPress = true; if (Panels.open !== "spotlight") Panels.toggle("spotlight"); } }
        }
        StatusItem {
            // lit while Control Center is open and while the volume/brightness HUD shows (it hangs under this item)
            active: (Panels.open === "cc" && Panels.activeScreen === bar.screen) || (Hud.shown && Hud.screen === bar.modelData)
            hPad: 5   // CC item 26 around a 13.5 glyph (Q-menubar-09)
            Symbol { anchors.centerIn: parent; name: "controlcenter"; surface: "menubar"; size: Theme.menuBar.statusIconSize; color: bar.statusFg }
            onClicked: Panels.toggle("cc", bar.screen)
        }
        StatusItem {
            active: Panels.open === "nc" && Panels.activeScreen === bar.screen
            hPad: 0   // clock ink fills its item (Q-menubar-09)
            contentWidth: clockText.implicitWidth
            Text {
                id: clockText
                anchors.horizontalCenter: parent.horizontalCenter
                y: Theme.menuBar.titleBaseline - baselineOffset
                text: Clock.format(clock.date, bar.clockStyle)
                color: bar.statusFg
                font: Typography.menuBar
            }
            onClicked: Panels.toggle("nc", bar.screen)
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
        onDateChanged: Theme.autoCheck()   // Appearance > Auto after a sleep or a clock change (Theme.autoCheck)
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
        height: bar.height

        // the pill jumps at once (MAC-ANSWERS.md R2); the dropdown follows a few frames later (Panels.stepMenu)
        HighlightPill { shown: mt.open; outset: Theme.menuBar.titlePillOutset; pillHeight: Theme.menuBar.titlePillHeight }
        Text {
            id: label
            anchors.horizontalCenter: parent.horizontalCenter
            y: Theme.menuBar.titleBaseline - baselineOffset   // cap ink 11..21 like the Mac (Q-menubar-06)
            visible: mt.text !== ""
            text: mt.text
            color: bar.fg
            // menuBarFont 13; the app name in bold (boldSystemFont 13, real wght 700: Typography)
            font: mt.bold ? Typography.systemBold : Typography.menuBar
        }
        Item { id: holder; anchors.fill: parent }
        function openHere() { Panels.openMenu(mt.menuIndex, mt.mapToItem(null, 0, 0).x, bar.screen); }
        function openIfOther() { if (Panels.open === "menu" && !mt.open && Panels.activeScreen === bar.screen) openHere(); }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onPressed: {
                if (mt.open) Panels.close();
                else {
                    mt.openHere();
                    Panels.pointerHeld = true;
                }
            }
            // press, drag, release (Q-menubar-24): this surface keeps the grab while the button is down; over the
            // titles the menu follows the pointer as on hover, below the bar the open menu takes the position, and
            // a release on one of its rows runs it. A release on the bar leaves the menu open (click, then click).
            onPositionChanged: m => {
                if (!pressed || !Panels.pointerHeld) return;
                const p = mapToItem(null, m.x, m.y);
                if (p.y < bar.height) {
                    const t = bar.titleAt(p.x);
                    if (t) t.openIfOther();
                } else Panels.menuPointer(p.x, p.y, false);
            }
            onReleased: m => {
                if (!Panels.pointerHeld) return;
                const p = mapToItem(null, m.x, m.y);
                Panels.pointerHeld = false;
                if (p.y >= bar.height) Panels.menuPointer(p.x, p.y, true);
            }
            onCanceled: Panels.pointerHeld = false
            // macOS: while any menu is open, hovering another title switches to it
            onEntered: mt.openIfOther()
        }
        Connections {   // the keyboard steps here from the neighbouring title (Q-menubar-25: opens with no row selected)
            target: Panels
            function onMenuStep(target) {
                if (Panels.open === "menu" && Panels.activeScreen === bar.screen && target === mt.menuIndex)
                    mt.openHere();
            }
        }
    }

    // open state of a title or status item. No glass (MENUBAR-REA-27.2.1.md): a capsule of the
    // blurred desktop picture through a colour matrix (shaders/menupill.frag), with a faint shadow
    // (MAC-ANSWERS.md Q9.1). Nothing but the wallpaper is ever under the bar, so the pre-blurred wallpaper
    // is the exact backdrop: no compositor blur and no per-frame work while it stands still. The pill
    // exists only while shown, not one per title.
    // Per-frame alpha on 27.2.1 (relay #52): full in the first frame of an open, jumps between titles within
    // one frame (no slide), and is gone in one frame on close (Esc or click) while the dropdown still fades.
    component HighlightPill: Item {
        id: hp
        property bool shown: false
        property real outset: 0        // beyond the item frame on each side
        property real pillHeight: 0    // centred on the bar
        x: -outset
        y: (parent.height - pillHeight) / 2
        width: parent.width + outset * 2
        height: pillHeight
        Loader {
            anchors.fill: parent
            active: hp.shown
            sourceComponent: Item {
                // faint shadow under the pill: 206 -> 196 just below it over solid blue (measured);
                // offset and blur guessed
                RectangularShadow {
                    anchors.fill: parent
                    radius: Math.min(Theme.menuBar.titleRadius, height / 2)
                    offset.y: 1
                    blur: 2
                    color: Theme.color.menuBarPillShadow
                }
                Rectangle {   // Reduce transparency / no blurred wallpaper
                    anchors.fill: parent
                    visible: Theme.solidMaterial
                    radius: Math.min(Theme.menuBar.titleRadius, height / 2)
                    color: Theme.color.menuBarPillSolid
                }
                // the pre-blurred wallpaper under the pill, colour-matrixed and cut to the capsule in one pass
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
                    readonly property point pos: hp.parent.x + hp.parent.y >= -1e9 ? mapToItem(null, 0, 0) : Qt.point(0, 0)
                    property var src: pillBackdrop
                    // the blurred wallpaper covers the whole screen: map by this bar's screen size
                    readonly property size screenSize: Qt.size(bar.width, bar.screen ? bar.screen.height : Wallpaper.height)
                    property rect srcRect: Qt.rect(pos.x / screenSize.width, pos.y / screenSize.height,
                                                   width / screenSize.width, height / screenSize.height)
                    property size sizePt: Qt.size(width, height)
                    property real radius: Math.min(Theme.menuBar.titleRadius, height / 2)
                    property real lightText: Theme.menuBarLight ? 0 : 1
                    fragmentShader: Qt.resolvedUrl("../shaders/menupill.frag.qsb")
                }
            }
        }
    }

    function moduleOpen(name) { return Panels.open === name && Panels.activeScreen === bar.screen; }

    component StatusItem: Item {
        id: si
        property bool active: false
        function openModule(name) { const p = mapToItem(null, 0, 0); Panels.toggleStatus(name, p.x, width, bar.screen); }
        property real contentWidth: Theme.menuBar.statusIconSize
        property real hPad: Theme.menuBar.statusHPadding
        default property alias content: sholder.data
        signal clicked()
        signal pressedDown()
        signal releasedUp()

        width: contentWidth + hPad * 2
        height: bar.height

        // pressed or open only: hovering a status item shows no pill (27.2.1, relay #52)
        HighlightPill { shown: si.active || sma.pressed; outset: Theme.menuBar.statusPillOutset; pillHeight: Theme.menuBar.statusPillHeight }
        Item { id: sholder; anchors.fill: parent }
        MouseArea { id: sma; anchors.fill: parent; onClicked: si.clicked(); onPressed: si.pressedDown(); onReleased: si.releasedUp() }
    }
}
