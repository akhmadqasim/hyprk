import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs
import qs.components
import qs.services

// Cmd/Super+Tab app switcher: row of large icons on glass, one per running
// app. Tab / Shift+Tab cycle while Super is held, releasing Super switches.
PanelWindow {
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
    color: "transparent"
    WlrLayershell.namespace: "hyprk-switcher"
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
        readonly property real cell: Theme.switcher.iconSize + Theme.switcher.cellPadding * 2
        width: sw.apps.length * cell + Theme.switcher.padding * 2
        height: cell + Theme.switcher.padding * 2
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
                        color: Theme.color.switcherSelection
                        visible: c.index === sw.selected
                    }
                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: Theme.switcher.iconSize
                        source: Apps.iconUrl(c.modelData.icon, c.modelData.id)
                        mipmap: true
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

    Text {
        anchors.horizontalCenter: panel.horizontalCenter
        anchors.top: panel.bottom
        anchors.topMargin: 8
        text: sw.apps[sw.selected] ? sw.apps[sw.selected].name : ""
        font.family: Theme.fontText
        font.pixelSize: Theme.font.switcherLabel
        font.weight: Theme.font.medium
        color: Theme.color.menuBarText
        style: Text.Raised
        styleColor: Theme.color.menuBarShadow
    }
}
