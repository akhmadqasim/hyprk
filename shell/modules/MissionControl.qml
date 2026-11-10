import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs
import qs.components
import qs.services
import qs.HyprK

// Mission Control (Super+Up): Spaces bar on top, live thumbnails of the
// windows on the current Space laid out in a grid over the dimmed desktop.
// Click a window to focus it, a Space to switch, empty space or Esc to close.
// Motion: on the Exposé spring (WindowManager ExposeSpringResponse 0.25, damping 1.0, SPEC 11.4)
// the windows fly from where they are on screen into the grid and back on close, the backdrop
// darkens and the Spaces bar slides down (on close it leaves in 0.125 s, SPEC 11.4).
// Reduce motion: a crossfade.
ShellWindow {
    id: mc

    required property var modelData
    screen: modelData

    readonly property bool shown: Panels.open === "mission"
    Spring {
        id: expose
        initial: 0
        target: mc.shown ? 1 : 0
        response: A11y.reduceMotion ? Tokens.motion.crossfade : Theme.anim.exposeResponse
        damping: A11y.reduceMotion ? 1 : Theme.anim.exposeDamping
    }
    readonly property real e: Math.max(0, Math.min(1, expose.value))   // 0 = windows in place
    readonly property real travel: A11y.reduceMotion ? 0 : 1 - e         // 1 = at the real window rect
    // Spaces bar: in with the Exposé spring, out in 0.125 s
    Spring {
        id: barSpring
        initial: 0
        target: mc.shown ? 1 : 0
        response: mc.shown ? Theme.anim.exposeResponse : Theme.anim.spacesBarExit / 1000
    }
    readonly property real bar: Math.max(0, Math.min(1, barSpring.value))
    visible: shown || expose.moving
    lingerAs: "mission"
    lingering: !shown && expose.moving
    acceptsInput: shown               // no input while closing
    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-mission"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // frozen while closing, so the windows fly back to where they were
    property var windows: []
    Binding on windows { value: Hyprland.toplevels.values.filter(t => t.workspace && t.workspace === Hyprland.focusedWorkspace); when: mc.shown; restoreMode: Binding.RestoreNone }
    property var spaces: []
    Binding on spaces { value: Hyprland.workspaces.values.filter(w => w.id > 0).sort((a, b) => a.id - b.id); when: mc.shown; restoreMode: Binding.RestoreNone }

    // the window exists only while open (shell.qml LazyLoader)
    function present() { Hyprland.refreshToplevels(); keys.forceActiveFocus(); }
    Component.onCompleted: present()
    onShownChanged: if (shown) present()

    // grid geometry: as square as possible, cells share the area below the Spaces bar
    readonly property int cols: Math.max(1, Math.ceil(Math.sqrt(windows.length)))
    readonly property int rows: Math.max(1, Math.ceil(windows.length / cols))
    readonly property real gridTop: Theme.mission.spacesHeight + Theme.mission.margin / 2
    readonly property real cellW: (width - Theme.mission.margin * 2 - Theme.mission.gap * (cols - 1)) / cols
    readonly property real cellH: (height - gridTop - Theme.mission.margin * 1.5 - Theme.mission.gap * (rows - 1)) / rows

    Item {
        id: keys
        focus: true
        Keys.onEscapePressed: Panels.close()
    }

    // backdrop: blurred wallpaper, dimmed
    Image {
        anchors.fill: parent
        opacity: mc.e
        readonly property string path: Wallpaper.blurred || Wallpaper.wallpaper
        source: path ? "file://" + path : ""
        asynchronous: true
    }
    Rectangle { anchors.fill: parent; color: Qt.rgba(0, 0, 0, Theme.mission.dim); opacity: mc.e }
    MouseArea { anchors.fill: parent; onClicked: Panels.close() }

    // Spaces bar: a wallpaper thumbnail per Space with its name under it,
    // the current one outlined (macOS shows these when the bar is expanded)
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.mission.spacesTop - (A11y.reduceMotion ? 0 : 1 - mc.bar) * (height + Theme.mission.spacesTop)
        opacity: mc.bar
        spacing: Theme.mission.spaceSpacing
        Repeater {
            model: mc.spaces
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
                        onClicked: sp.modelData.activate()
                    }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Desktop " + sp.modelData.id
                    font.family: Theme.fontText
                    font.pixelSize: Theme.mission.labelSize
                    font.weight: sp.current ? Font.DemiBold : Font.Normal
                    color: Theme.mission.text
                }
            }
        }
    }

    // windows
    Repeater {
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
            y: mc.gridTop + row * (mc.cellH + Theme.mission.gap)
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
            Component.onCompleted: takeRect()
            readonly property real fly: real && thumb.width > 0 ? mc.travel : 0
            ClippingRectangle {
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
                radius: Theme.mission.thumbRadius
                color: "transparent"
                scale: wma.containsMouse ? Theme.mission.hoverScale : 1
                Behavior on scale { NumberAnimation { duration: Theme.anim.fast } }
                ScreencopyView {
                    id: view
                    captureSource: cell.modelData.wayland
                    live: mc.shown
                    // fit the cell but never grow past Theme.mission.maxScale of the real window
                    readonly property real dpr: mc.screen ? mc.screen.devicePixelRatio : 1
                    readonly property real maxW: cell.width
                    readonly property real maxH: cell.height - Theme.mission.titleReserve
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
                Rectangle {
                    anchors.fill: parent
                    radius: Theme.mission.thumbRadius
                    color: "transparent"
                    border.width: wma.containsMouse ? Theme.mission.hoverBorder : 0
                    border.color: Theme.color.accent
                }
            }
            // title under the hovered window, styled like the Dock tooltip
            Rectangle {
                visible: wma.containsMouse && mc.shown
                anchors.horizontalCenter: parent.horizontalCenter
                y: thumb.y + thumb.height + Theme.dock.tooltipGap
                width: Math.min(cell.width, title.implicitWidth + Theme.dock.tooltipHPad * 2)
                height: Theme.dock.tooltipHeight
                radius: Theme.dock.tooltipRadius
                color: Theme.color.tooltipBg
                border.width: 1
                border.color: Theme.glass.hairline
                Text {
                    id: title
                    anchors.centerIn: parent
                    width: Math.min(implicitWidth, cell.width - Theme.dock.tooltipHPad * 2)
                    elide: Text.ElideRight
                    text: cell.modelData.title
                    font.family: Theme.fontText
                    font.pixelSize: Theme.font.dockTooltip
                    color: Theme.color.label
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
