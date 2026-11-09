import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.components
import qs.services

// Cmd/Super+Tab app switcher: row of large icons on glass, one per running
// app. Tab / Shift+Tab cycle while Super is held, releasing Super switches.
ShellWindow {
    id: sw

    required property var modelData
    screen: modelData

    readonly property bool shown: Panels.open === "switcher"
    // one entry per running app, most recently focused first is not tracked by Hyprland IPC,
    // so keep the active app first and the rest in dock order
    readonly property var apps: {
        const running = Apps.dockItems.filter(i => (i.windows || []).length > 0);
        const activeIdx = running.findIndex(i => i.windows.indexOf(Hyprland.activeToplevel) !== -1);
        if (activeIdx > 0) running.unshift(running.splice(activeIdx, 1)[0]);
        return running;
    }
    property int selected: 0

    visible: shown && apps.length > 0
    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-switcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onShownChanged: {
        if (!shown) return;
        if (apps.length === 0) { Panels.close(); return; }
        selected = apps.length > 1 ? 1 : 0;
        keys.forceActiveFocus();
    }

    function commit() {
        const app = apps[selected];
        Panels.close();
        if (app) Apps.focusWindow(app.windows[0]);
    }

    MouseArea { anchors.fill: parent; onPressed: Panels.close() }

    Item {
        id: keys
        focus: true
        Keys.onPressed: e => {
            if (e.key === Qt.Key_Tab || e.key === Qt.Key_Right) sw.selected = (sw.selected + 1) % sw.apps.length;
            else if (e.key === Qt.Key_Backtab || e.key === Qt.Key_Left) sw.selected = (sw.selected - 1 + sw.apps.length) % sw.apps.length;
            else if (e.key === Qt.Key_Escape) Panels.close();
            else if (e.key === Qt.Key_Return) sw.commit();
            e.accepted = true;
        }
        Keys.onReleased: e => {
            if (e.key === Qt.Key_Super_L || e.key === Qt.Key_Super_R || e.key === Qt.Key_Meta) sw.commit();
        }
    }

    Item {
        id: panel
        // 128pt icons unless the row would not fit the screen
        readonly property real icon: Math.max(Theme.switcher.minIconSize, Math.min(Theme.switcher.iconSize,
            (sw.width * Theme.switcher.maxWidthFraction - Theme.switcher.padding * 2) / Math.max(1, sw.apps.length) - Theme.switcher.cellPadding * 2))
        readonly property real cell: icon + Theme.switcher.cellPadding * 2
        width: sw.apps.length * cell + Theme.switcher.padding * 2
        height: cell + Theme.switcher.labelHeight + Theme.switcher.padding * 2
        anchors.centerIn: parent

        Glass {
            anchors.fill: parent
            radius: Theme.switcher.radius
            sx: panel.x
            sy: panel.y
            tint: Theme.glass.tintStrong
        }

        Row {
            x: Theme.switcher.padding
            y: Theme.switcher.padding
            Repeater {
                model: sw.apps
                delegate: Item {
                    id: c
                    required property var modelData
                    required property int index
                    width: panel.cell
                    height: panel.cell
                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.switcher.selectionRadius
                        color: Theme.switcher.selection
                        visible: c.index === sw.selected
                    }
                    AppIcon {
                        anchors.centerIn: parent
                        size: panel.icon
                        icon: c.modelData.icon
                        appId: c.modelData.id
                    }
                    // macOS shows the name of the selected app under its icon
                    Text {
                        visible: c.index === sw.selected
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height + (Theme.switcher.labelHeight - height) / 2
                        width: panel.cell * 1.6
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: c.modelData.name
                        font.family: Theme.fontText
                        font.pixelSize: Theme.font.switcherLabel
                        color: Theme.color.label
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: sw.selected = c.index
                        onClicked: sw.commit()
                    }
                }
            }
        }
    }
}
