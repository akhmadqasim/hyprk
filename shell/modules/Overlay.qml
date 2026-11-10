import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.components
import qs.services
import "../lib/menus.js" as Menus

// Transparent click-catcher below the menu bar that hosts the pull-down
// menus, context menus, alerts and Notification Center. Clicking outside
// closes. Control Center has its own layer (ControlCenterWindow.qml).
ShellWindow {
    id: ov

    required property var modelData
    screen: modelData

    // modelData, not screen: mapping the window re-emits screenChanged (binding loop)
    readonly property bool active: ["menu", "context", "alert", "nc"].indexOf(Panels.open) !== -1
                                   && Panels.activeScreen === modelData
    visible: active || nc.opacity > 0
    // NC fades its compositor glass with it (menus and alerts do not animate)
    glassOpacity: nc.visible ? nc.opacity : 1

    anchors { top: true; left: true; right: true; bottom: true }
    margins.top: Theme.menuBar.height
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-overlay"
    WlrLayershell.layer: WlrLayer.Overlay
    // the alert must get Return/Escape even when opened without a click (IPC, Dock menu)
    WlrLayershell.keyboardFocus: !active ? WlrKeyboardFocus.None : Panels.open === "alert" ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand

    MouseArea {
        anchors.fill: parent
        onPressed: Panels.close()
    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: Panels.close()
    }

    // ---------- context menu (desktop, Dock) ----------
    MenuDropdown {
        id: context
        visible: Panels.open === "context"
        items: visible ? Panels.contextItems : []
        x: Math.max(Theme.menu.screenMargin, Math.min(ov.width - width - Theme.menu.screenMargin, Panels.contextAbove ? Panels.contextX - width / 2 : Panels.contextX))
        y: Math.max(0, Math.min(ov.height - height - Theme.menu.screenMargin,
                                Panels.contextY - Theme.menuBar.height - (Panels.contextAbove ? height : 0)))
        originX: x
        originY: y + Theme.menuBar.height
    }

    // ---------- alert ----------
    AlertDialog {
        id: alert
        visible: Panels.open === "alert"
        model: Panels.alert
        x: (ov.width - width) / 2
        y: (ov.height - height) * Theme.alert.verticalBias
        originX: x
        originY: y + Theme.menuBar.height
    }

    // ---------- menu ----------
    MenuDropdown {
        id: menu
        visible: Panels.open === "menu"
        x: Math.min(Panels.menuX, ov.width - width - 4)
        y: Theme.menu.offsetY
        originX: x
        originY: y + Theme.menuBar.height
        items: Panels.menuIndex < 0 ? []
             : Menus.forIndex(Panels.menuIndex, Apps.appIdOf(Hyprland.activeToplevel), Apps.activeAppName(), Quickshell.env("USER"))
    }

    // ---------- notification center ----------
    NotificationCenter {
        id: nc
        anchors.right: parent.right
        anchors.rightMargin: Theme.nc.marginRight
        y: Theme.nc.marginTop
        maxHeight: ov.height - y - 20
        originX: ov.width - width - Theme.nc.marginRight
        originY: y + Theme.menuBar.height
        opacity: 0
        visible: opacity > 0
        transform: Translate { id: ncSlide; x: 40 }
        MouseArea { anchors.fill: parent; z: -1 }

        // open on the SwiftUI spring, close fast; each starts from wherever the other left off
        readonly property bool shown: Panels.open === "nc"
        onShownChanged: {
            ncOpen.stop();
            ncClose.stop();
            (shown ? ncOpen : ncClose).start();
        }
        ParallelAnimation {
            id: ncOpen
            NumberAnimation { target: nc; property: "opacity"; to: 1; duration: Theme.anim.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.spring }
            NumberAnimation { target: ncSlide; property: "x"; to: 0; duration: Theme.anim.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.spring }
        }
        ParallelAnimation {
            id: ncClose
            NumberAnimation { target: nc; property: "opacity"; to: 0; duration: Theme.anim.close; easing.type: Theme.anim.easing }
            NumberAnimation { target: ncSlide; property: "x"; to: 40; duration: Theme.anim.close; easing.type: Theme.anim.easing }
        }
    }
}
