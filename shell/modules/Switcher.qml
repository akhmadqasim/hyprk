import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.components
import qs.HyprK
import qs.services

// Cmd/Super+Tab app switcher: row of large icons on glass, one per running
// app. Tab / Shift+Tab cycle while Super is held, releasing Super switches.
// Motion (27.2.1 Dock -[ASAppSwitcher exit:immediately:], MAC-ANSWERS.md "REA 27.2.1" section 5 and Reconciliation
// (#42) b): it appears complete in one frame (no fade, no scale, no glass materialize) and on releasing Cmd fades
// out in a CATransaction with kCAMediaTimingFunctionEaseInEaseOut over the default 0.25 s (measured fit 0.236 s).
// Material: the Dock's (Q-dock-19: pixel-identical), the plugin's `dock` recipe (config/hypr/hyprland.lua).
ShellWindow {
    id: sw

    required property var modelData
    screen: modelData

    readonly property bool shown: Panels.open === "switcher"
    // one entry per running app, most recently focused first is not tracked by Hyprland IPC,
    // so keep the active app first and the rest in dock order
    readonly property var liveApps: {
        const running = Apps.dockItems.filter(i => (i.windows || []).length > 0);
        const activeIdx = running.findIndex(i => i.windows.indexOf(Hyprland.activeToplevel) !== -1);
        if (activeIdx > 0) running.unshift(running.splice(activeIdx, 1)[0]);
        return running;
    }
    // frozen while dematerializing, so the row does not reorder when the chosen app takes focus
    property var apps: []
    Binding on apps { value: sw.liveApps; when: sw.shown; restoreMode: Binding.RestoreNone }
    property int selected: 0
    // hover selects only after the pointer really moved: a resting pointer gets enter events as the
    // materializing panel scales under it, so a pointer near a cell edge flipped the selection
    // between two apps on every frame of the open (same rule as Spotlight's mode buttons)
    PointerGate { id: hoverGate }
    function notePointer(item, mx, my) { return hoverGate.note(item, mx, my); }

    // 1 = shown. Jumps to 1 Theme.switcher.showDelay after open (Q-dock-22), fades to 0 on close (then the window is
    // unloaded). Before that the surface is mapped but empty: it already holds the keyboard, so releasing Cmd during
    // the delay switches to the selected (previous) app without the panel ever showing (quick tap).
    property bool revealed: false
    Timer { id: revealTimer; interval: Theme.switcher.showDelay; onTriggered: sw.revealed = true }
    // one value per frame of this window (HyprK FrameEase)
    readonly property real fade: fadeEase.value
    FrameEase {
        id: fadeEase
        goal: sw.shown && sw.revealed && sw.liveApps.length > 0 ? 1 : 0
        animate: goal < value                    // fading in is a jump
        duration: Theme.ms(250)
        curve: [0.42, 0, 0.58, 1, 1, 1]
    }
    // the compositor glass fades with the content (ShellWindow.glassOpacity)
    glassOpacity: fade
    visible: (shown && liveApps.length > 0) || fade > 0
    lingerAs: "switcher"
    lingering: !shown && fade > 0
    acceptsInput: shown               // no input while dematerializing
    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-switcher"
    WlrLayershell.layer: WlrLayer.Overlay
    // with the compositor's submap the keys arrive as global shortcuts and the windows keep their focus (the Mac's do)
    readonly property bool compositorKeys: Panels.submap === Panels.switcherSubmap
    WlrLayershell.keyboardFocus: shown && !compositorKeys ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    Connections {
        target: Panels
        enabled: sw.shown
        function onSwitcherKey(k) { sw.key(k); }
    }
    // Tab, `, Shift-Tab and Left/Right move and wrap at both ends, Home/End jump, release commits, Esc cancels (Q-dock-22)
    function key(k) {
        const n = apps.length;
        if (n === 0 && k !== "cancel") return;
        if (k === "next") selected = (selected + 1) % n;
        else if (k === "prev") selected = (selected - 1 + n) % n;
        else if (k === "first") selected = 0;
        else if (k === "last") selected = n - 1;
        else if (k === "commit") commit();
        else if (k === "cancel") Panels.close();
        else if (k === "quit") quit();
    }
    // Q quits the selected app; the switcher stays open and its icon goes as the windows close (Q-dock-22).
    // Its last app quit: nothing left to switch to, so it closes (present() rule)
    function quit() {
        const app = apps[selected];
        if (!app) return;
        (app.windows || []).forEach(Apps.closeWindow);
    }
    onLiveAppsChanged: if (shown && selected >= liveApps.length) selected = Math.max(0, liveApps.length - 1)

    // the window exists only while open or dematerializing (shell.qml LazyLoader)
    function present() {
        if (liveApps.length === 0) { Qt.callLater(Panels.close); return; }   // not during construction
        selected = liveApps.length > 1 ? 1 : 0;
        revealed = false;
        revealTimer.restart();
        keys.forceActiveFocus();
    }
    Component.onCompleted: present()
    onShownChanged: if (shown) present()


    function commit() {
        const app = apps[selected];
        Panels.close();
        if (app) Apps.focusWindow(app.windows[0]);
    }

    Item {
        id: keys
        focus: true
        Keys.onPressed: e => {
            if (e.key === Qt.Key_Tab || e.key === Qt.Key_Right || e.key === Qt.Key_QuoteLeft) sw.key("next");
            else if (e.key === Qt.Key_Backtab || e.key === Qt.Key_Left) sw.key("prev");
            else if (e.key === Qt.Key_Home) sw.key("first");
            else if (e.key === Qt.Key_End) sw.key("last");
            else if (e.key === Qt.Key_Escape) sw.key("cancel");
            else if (e.key === Qt.Key_Return) sw.key("commit");
            else if (e.key === Qt.Key_Q) sw.key("quit");
            e.accepted = true;
        }
        Keys.onReleased: e => {
            if (e.key === Qt.Key_Super_L || e.key === Qt.Key_Super_R || e.key === Qt.Key_Meta) sw.commit();
        }
    }

    MouseArea { anchors.fill: parent; hoverEnabled: true; onPressed: Panels.close(); onPositionChanged: mouse => sw.notePointer(this, mouse.x, mouse.y) }

    // The panel's glass, the selection tile, the icons and the name on one surface, so the first frame that shows the
    // panel shows all of it (two surfaces committed apart: the glass came a frame before the icons in 2 of 5 opens). On the
    // plugin the tile is a cut in the panel's glass region that the plugin fills plus-darker (light) / plus-lighter (dark)
    // over the glass (`cut_fills`, plugin/README.md "Cuts"), as the Mac blends it (Q-dock-20/21, cmdtab-*.png: 41,134,220
    // -> 0,78,161 light; 26,61,179 -> 90,124,240 dark): Qt cannot blend with the compositor's glass.
    Item {
        id: panel
        readonly property int n: Math.max(1, sw.apps.length)
        // 128 pt icons, smaller when the row would come closer than 34 pt to the screen sides (Q-dock-20)
        readonly property real icon: Math.max(Theme.switcher.minIconSize, Math.min(Theme.switcher.iconSize, Math.floor(
            (sw.width - Theme.switcher.screenMargin * 2 - Theme.switcher.padding * 2 + Theme.switcher.gap) / n - Theme.switcher.gap)))
        readonly property real pitch: icon + Theme.switcher.gap
        width: n * pitch - Theme.switcher.gap + Theme.switcher.padding * 2
        height: icon + Theme.switcher.padding * 2
        x: Math.round((sw.width - width) / 2)
        y: Math.round((sw.height - height) / 2)
        opacity: sw.fade

        Glass {
            anchors.fill: parent
            radius: Theme.switcher.radius
            sx: panel.x
            sy: panel.y
            tint: Theme.glass.tintClear
            solidColor: Theme.glass.solidDock
            pluginLift: Theme.dock.pluginLift
            materialize: 1
            subPointEdges: false   // whole points; the tile's cut crosses the marker rows
        }

        // the selection tile: 120 on a 128 icon, centred on the selected one; one cut on the plugin, else a flat colour
        Glass {
            id: tile
            width: Theme.switcher.selectionSize * panel.icon / Theme.switcher.iconSize
            height: width
            x: Theme.switcher.padding + sw.selected * panel.pitch + (panel.icon - width) / 2
            y: Theme.switcher.padding + (panel.icon - height) / 2
            radius: Theme.switcher.selectionRadius * panel.icon / Theme.switcher.iconSize
            cut: true
            visible: Theme.compositorGlass && sw.apps.length > 0
        }
        Rectangle {
            x: tile.x
            y: tile.y
            width: tile.width
            height: tile.height
            radius: tile.radius
            color: Theme.switcher.selection
            visible: !Theme.compositorGlass && sw.apps.length > 0
        }

        Row {
            x: Theme.switcher.padding
            y: Theme.switcher.padding
            spacing: Theme.switcher.gap
            Repeater {
                model: sw.apps
                delegate: Item {
                    id: c
                    required property var modelData
                    required property int index
                    width: panel.icon
                    height: panel.icon
                    AppIcon {
                        anchors.centerIn: parent
                        size: panel.icon
                        icon: c.modelData.icon
                        appId: c.modelData.id
                    }
                    // the selected app's name under its icon, in the bottom padding
                    Text {
                        visible: c.index === sw.selected
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height + Theme.switcher.labelTop
                        width: panel.pitch * 1.6
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: c.modelData.name
                        font: Typography.headline
                        color: Theme.color.label
                    }
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -Theme.switcher.gap / 2
                        hoverEnabled: true
                        onEntered: if (sw.notePointer(this, mouseX, mouseY)) sw.selected = c.index
                        onPositionChanged: mouse => { if (sw.notePointer(this, mouse.x, mouse.y)) sw.selected = c.index; }
                        onClicked: sw.commit()
                    }
                }
            }
        }
    }
}
