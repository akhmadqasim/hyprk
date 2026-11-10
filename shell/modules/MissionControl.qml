import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs
import qs.components
import qs.HyprK
import qs.services
import "../lib/spring.js" as SpringLib

// Mission Control (Super+Up): live thumbnails of the windows on the current Space laid out
// without overlap, the Spaces bar at the top. Click a window to focus it, a Space to switch,
// empty space or Esc to close.
// macOS 27.2.1 (MAC-ANSWERS.md R2 and Q-dock-27): the windows move and scale from where they are into the
// layout and back, the wallpaper is NOT dimmed or blurred, the menu bar and the desktop widgets go away, the
// Dock stays visible, and the Spaces bar shows the Desktops as small labelled pills with "+" at the right.
// Motion (WindowManager.framework preferences, "REA 27.2.1" section 5): one critically damped spring, response
// 0.25 s, for enter and exit (ExposeSpring*); the Spaces bar leaves on its own one, response 0.125 s
// (SpacesBarExitSpringResponse). Each is one exact NumberAnimation (components/SpringCurve.qml).
// How: this layer draws the plain wallpaper over everything but the Dock's band (Panels.dockZones) at opacity
// `e`, so the real windows and the menu bar (with its top dimming) fade out under it while the thumbnails,
// which start exactly over the real windows, fly to their places: no cross-fade of the windows.
// Reduce motion: the same springs within 0.15 s as a dissolve, no flight.
ShellWindow {
    id: mc

    required property var modelData
    screen: modelData

    readonly property bool shown: Panels.open === "mission"

    // Numbers that are ours (no Theme.qml tokens yet; Q-dock-27..31 will answer the guessed ones)
    readonly property QtObject m: QtObject {
        readonly property var expose: SpringLib.fromResponse(0.25, 1)      // ExposeSpringResponse / DampingRatio
        readonly property var barExit: SpringLib.fromResponse(0.125, 1)    // SpacesBarExitSpringResponse
        // collapsed Spaces bar: labelled pills, guessed (no 27.2.1 screenshot of it yet, Q-dock-31)
        readonly property int barHeight: 44
        readonly property int pillHeight: 26
        readonly property int pillPadding: 12
        readonly property int pillSpacing: 6
        readonly property real labelSize: 13
        readonly property color pill: Qt.rgba(1, 1, 1, 0.24)
        readonly property color pillHover: Qt.rgba(1, 1, 1, 0.14)
        readonly property int plusSize: 28
        readonly property int plusInset: 16          // from the right screen edge
        readonly property int expandMs: 250          // bar grows into thumbnails on hover, guessed
        readonly property int gateMs: 150            // longest wait for the first window captures
        // window layout below the bar, guessed (Q-dock-28)
        readonly property int gridTop: barHeight + Theme.mission.margin / 2
        // wallpaper layer colour when no image is set (Background.qml)
        readonly property color empty: Theme.dark ? "#1c1c1e" : "#3a6fb0"
    }

    // 0 = everything in place, 1 = Mission Control
    property real e: 0
    SpringCurve { id: anim; target: mc; property: "e"; spring: mc.m.expose }
    // Spaces bar: in with the windows, out on its own spring
    property real bar: 0
    SpringCurve { id: barAnim; target: mc; property: "bar"; spring: mc.m.expose }
    function go() {
        anim.go(shown ? 1 : 0);
        barAnim.spring = shown ? m.expose : m.barExit;
        barAnim.go(shown ? 1 : 0);
    }
    readonly property real travel: A11y.reduceMotion ? 0 : 1 - e         // 1 = at the real window rect
    // by value, not anim.running: the window must not blink off between `shown` turning false and the
    // exit animation starting
    visible: shown || e > 0
    lingerAs: "mission"
    lingering: !shown && e > 0
    acceptsInput: shown               // no input while closing
    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    // the Dock's band stays uncovered and clickable
    readonly property int dockZone: (screen && Panels.dockZones[screen.name]) || 0
    inputMask: Region { x: 0; y: 0; width: mc.width; height: mc.height - mc.dockZone }
    namespace: "hyprk-mission"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // frozen while closing, so the windows fly back to where they were. Ordered top to bottom, then
    // left to right by where they are, so each fills the nearest cell (short flights).
    property var windows: []
    Binding on windows { value: mc.byPosition(Hyprland.toplevels.values.filter(t => t.workspace && t.workspace === Hyprland.focusedWorkspace)); when: mc.shown; restoreMode: Binding.RestoreNone }
    property var spaces: []
    Binding on spaces { value: Hyprland.workspaces.values.filter(w => w.id > 0).sort((a, b) => a.id - b.id); when: mc.shown; restoreMode: Binding.RestoreNone }

    function centreOf(t) {
        const o = t.lastIpcObject;
        return o && o.at && o.size ? { x: o.at[0] + o.size[0] / 2, y: o.at[1] + o.size[1] / 2 } : { x: 0, y: 0 };
    }
    // rows of `cols` by centre y, each row by centre x
    function byPosition(list) {
        const n = list.length, cols = Math.max(1, Math.ceil(Math.sqrt(n)));
        const sorted = list.slice().sort((a, b) => centreOf(a).y - centreOf(b).y);
        const out = [];
        for (let i = 0; i < n; i += cols)
            out.push(...sorted.slice(i, i + cols).sort((a, b) => centreOf(a).x - centreOf(b).x));
        return out;
    }

    // the window exists only while open (shell.qml LazyLoader)
    // The motion starts once every thumbnail has its first frame (at most m.gateMs): until then the
    // thumbnails sit, invisible, exactly over their windows. Started earlier, a capture that comes
    // in late would pop up away from its window while the window already fades out.
    property bool pending: false
    function present() {
        Hyprland.refreshToplevels();
        keys.forceActiveFocus();
        pending = true;
        gate.restart();
        maybeGo();
    }
    function maybeGo() {
        if (!pending || thumbs.count < windows.length) return;
        for (let i = 0; i < thumbs.count; i++) {
            const c = thumbs.itemAt(i);
            if (c && !c.ready) return;
        }
        pending = false;
        gate.stop();
        go();
    }
    Timer { id: gate; interval: mc.m.gateMs; onTriggered: { mc.pending = false; mc.go(); } }
    // onShownChanged also fires while the bindings are set up on creation: present() once, when complete
    property bool completed: false
    Component.onCompleted: { completed = true; present(); }
    onShownChanged: if (completed) shown ? present() : go()

    // grid geometry: as square as possible, cells share the area below the Spaces bar
    readonly property int cols: Math.max(1, Math.ceil(Math.sqrt(windows.length)))
    readonly property int rows: Math.max(1, Math.ceil(windows.length / cols))
    readonly property real cellW: (width - Theme.mission.margin * 2 - Theme.mission.gap * (cols - 1)) / cols
    readonly property real cellH: (height - dockZone - m.gridTop - Theme.mission.margin * 1.5 - Theme.mission.gap * (rows - 1)) / rows

    Item {
        id: keys
        focus: true
        Keys.onEscapePressed: Panels.close()
    }

    // the plain wallpaper, as the wallpaper layer draws it (Background.qml), over everything below but the Dock
    Rectangle {
        width: parent.width
        height: parent.height - mc.dockZone
        clip: true
        color: mc.m.empty
        opacity: mc.e
        Image {
            width: mc.width
            height: mc.height
            source: Wallpaper.url
            sourceSize: Qt.size(mc.screen ? mc.screen.width : 1920, mc.screen ? mc.screen.height : 1080)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
        }
    }
    MouseArea { width: parent.width; height: parent.height - mc.dockZone; onClicked: Panels.close() }

    // Spaces bar. Collapsed (27.2.1): a labelled pill per Desktop, the current one filled, "+" at the
    // right. Pointing at it expands it to wallpaper thumbnails with the names under them (macOS
    // behaviour; the expanded look is the earlier hyprk one, not checked against 27.2.1).
    Item {
        id: spacesBar
        width: parent.width
        height: expanded ? Theme.mission.spacesTop + expandedRow.height + Theme.mission.spaceLabelGap : mc.m.barHeight
        y: -(A11y.reduceMotion ? 0 : 1 - mc.bar) * mc.m.barHeight
        opacity: mc.bar
        readonly property bool expanded: barHover.hovered && mc.shown
        property real grow: expanded ? 1 : 0
        Behavior on grow { NumberAnimation { duration: Theme.ms(mc.m.expandMs); easing.type: Easing.OutCubic } }
        HoverHandler { id: barHover }

        Row {
            id: pills
            anchors.horizontalCenter: parent.horizontalCenter
            y: (mc.m.barHeight - mc.m.pillHeight) / 2
            spacing: mc.m.pillSpacing
            opacity: 1 - spacesBar.grow
            visible: opacity > 0
            Repeater {
                model: mc.spaces
                delegate: Rectangle {
                    id: pill
                    required property var modelData
                    readonly property bool current: modelData === Hyprland.focusedWorkspace
                    width: label.implicitWidth + mc.m.pillPadding * 2
                    height: mc.m.pillHeight
                    radius: height / 2
                    color: current ? mc.m.pill : pm.containsMouse ? mc.m.pillHover : "transparent"
                    Text {
                        id: label
                        anchors.centerIn: parent
                        text: "Desktop " + pill.modelData.id
                        font: Typography.font(mc.m.labelSize, pill.current ? Typography.semibold : Typography.medium)
                        color: Theme.mission.text
                    }
                    MouseArea {
                        id: pm
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: mc.openSpace(pill.modelData)
                    }
                }
            }
        }

        Row {
            id: expandedRow
            anchors.horizontalCenter: parent.horizontalCenter
            y: Theme.mission.spacesTop
            spacing: Theme.mission.spaceSpacing
            opacity: spacesBar.grow
            visible: opacity > 0
            Repeater {
                model: spacesBar.expanded || spacesBar.grow > 0 ? mc.spaces : []
                delegate: Column {
                    id: sp
                    required property var modelData
                    readonly property bool current: modelData === Hyprland.focusedWorkspace
                    spacing: Theme.mission.spaceLabelGap

                    ClippingRectangle {
                        width: Theme.mission.spaceThumbWidth
                        height: width * mc.height / Math.max(1, mc.width)
                        radius: Theme.mission.spaceRadius
                        color: Theme.glass.solid
                        border.width: sp.current ? Theme.mission.hoverBorder : 0
                        border.color: Theme.mission.text
                        scale: spm.containsMouse ? Theme.mission.hoverScale : 1
                        Behavior on scale { NumberAnimation { duration: Theme.anim.fast } }
                        Image {
                            anchors.fill: parent
                            source: Wallpaper.url
                            sourceSize.width: Wallpaper.thumbWidth
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }
                        MouseArea {
                            id: spm
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: mc.openSpace(sp.modelData)
                        }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Desktop " + sp.modelData.id
                        font: Typography.font(Theme.mission.labelSize, sp.current ? Typography.semibold : Typography.regular)
                        color: Theme.mission.text
                    }
                }
            }
        }

        // "+": a new empty Desktop (Hyprland makes it current; macOS adds it without switching)
        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: mc.m.plusInset
            y: (mc.m.barHeight - height) / 2
            width: mc.m.plusSize
            height: width
            radius: width / 2
            color: plus.containsMouse ? mc.m.pill : mc.m.pillHover
            Rectangle { anchors.centerIn: parent; width: 12; height: 1.5; radius: 0.75; color: Theme.mission.text }
            Rectangle { anchors.centerIn: parent; width: 1.5; height: 12; radius: 0.75; color: Theme.mission.text }
            MouseArea {
                id: plus
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Hyprland.dispatch('hl.dsp.focus({ workspace = "emptynm" })')
            }
        }
    }
    function openSpace(ws) {
        Panels.close();
        ws.activate();
    }

    // windows
    Repeater {
        id: thumbs
        model: mc.windows
        delegate: Item {
            id: cell
            required property var modelData
            required property int index
            // a short last row is centered
            readonly property int row: Math.floor(index / mc.cols)
            readonly property int inRow: Math.min(mc.cols, mc.windows.length - row * mc.cols)
            x: Theme.mission.margin + (mc.cols - inRow) * (mc.cellW + Theme.mission.gap) / 2
               + (index % mc.cols) * (mc.cellW + Theme.mission.gap)
            y: mc.m.gridTop + row * (mc.cellH + Theme.mission.gap)
            width: mc.cellW
            height: mc.cellH

            // where the window really is (Hyprland logical layout px, made screen-local); the
            // thumbnail starts and ends there. Unknown (no IPC data yet): it stays in the grid.
            readonly property var ipcRect: {
                const o = cell.modelData.lastIpcObject;
                if (!o || !o.at || !o.size || !mc.screen) return null;
                return Qt.rect(o.at[0] - mc.screen.x, o.at[1] - mc.screen.y, o.size[0], o.size[1]);
            }
            // taken only before the fly-in is under way (IPC data arrives asynchronously: no jump)
            property var real: null
            function takeRect() { if (mc.e < 0.05) real = ipcRect; }
            onIpcRectChanged: takeRect()
            readonly property real fly: real && thumb.width > 0 ? mc.travel : 0
            // its capture is in (or there is nothing to fly from)
            readonly property bool ready: view.hasContent || !real
            onReadyChanged: mc.maybeGo()
            Component.onCompleted: { takeRect(); mc.maybeGo(); }
            Item {
                id: thumb
                anchors.centerIn: parent
                opacity: cell.real && !A11y.reduceMotion ? 1 : mc.e
                transform: [
                    Scale {
                        xScale: 1 + cell.fly * (cell.real ? cell.real.width / thumb.width - 1 : 0)
                        yScale: 1 + cell.fly * (cell.real ? cell.real.height / thumb.height - 1 : 0)
                    },
                    Translate {
                        x: cell.fly * (cell.real ? cell.real.x - cell.x - thumb.x : 0)
                        y: cell.fly * (cell.real ? cell.real.y - cell.y - thumb.y : 0)
                    }
                ]
                width: view.width
                height: view.height
                scale: wma.containsMouse ? Theme.mission.hoverScale : 1
                Behavior on scale { NumberAnimation { duration: Theme.anim.fast } }
                // window shadow, comes in with the layout (the real window's own shadow fades out
                // under the wallpaper); radius and offset as the glass shadow, guessed for here
                RectangularShadow {
                    anchors.fill: parent
                    radius: Theme.mission.thumbRadius
                    blur: Theme.glass.shadowRadius
                    offset.y: Theme.glass.shadowYOffset
                    color: Theme.glass.shadow
                    opacity: mc.e
                }
                ClippingRectangle {
                    anchors.fill: parent
                    radius: Theme.mission.thumbRadius
                    color: "transparent"
                    ScreencopyView {
                        id: view
                        captureSource: cell.modelData.wayland
                        live: mc.shown
                        // fit the cell but never grow past Theme.mission.maxScale of the real window
                        readonly property real dpr: mc.screen ? mc.screen.devicePixelRatio : 1
                        readonly property real maxW: cell.width
                        readonly property real maxH: cell.height
                        constraintSize: Qt.size(Math.min(maxW, sourceSize.width / dpr * Theme.mission.maxScale || maxW),
                                                Math.min(maxH, sourceSize.height / dpr * Theme.mission.maxScale || maxH))
                    }
                    // fallback while no frame is available: app icon on a plain card
                    Rectangle {
                        anchors.fill: parent
                        visible: !view.hasContent
                        color: Theme.glass.solid
                        IconImage {
                            anchors.centerIn: parent
                            implicitSize: Theme.mission.placeholderIcon
                            source: Apps.iconUrl(Apps.appIdOf(cell.modelData), Apps.appIdOf(cell.modelData))
                        }
                    }
                }
                Rectangle {
                    anchors.fill: parent
                    radius: Theme.mission.thumbRadius
                    color: "transparent"
                    border.width: wma.containsMouse ? Theme.mission.hoverBorder : 0
                    border.color: Theme.color.accent
                }
            }
            // title on hover, centred on the window (Q-dock-29)
            Rectangle {
                visible: wma.containsMouse && mc.shown
                anchors.centerIn: parent
                width: Math.min(cell.width, title.implicitWidth + Theme.mission.titlePadding * 2)
                height: Theme.mission.titleHeight
                radius: height / 2
                color: Theme.mission.titleFill
                Text {
                    id: title
                    anchors.centerIn: parent
                    width: Math.min(implicitWidth, cell.width - Theme.mission.titlePadding * 2)
                    elide: Text.ElideRight
                    text: cell.modelData.title
                    font: Typography.font(Theme.font.missionTitle, Typography.bold)
                    color: Theme.mission.titleText
                }
            }
            MouseArea {
                id: wma
                x: thumb.x; y: thumb.y; width: thumb.width; height: thumb.height
                hoverEnabled: true
                onClicked: { Panels.close(); Apps.focusWindow(cell.modelData); }
            }
        }
    }
}
