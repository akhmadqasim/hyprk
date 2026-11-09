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

    readonly property bool active: ["menu", "context", "alert", "nc"].indexOf(Panels.open) !== -1
                                   && Panels.activeScreen === screen
    visible: active || fadeOut.running

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
        opacity: Panels.open === "nc" ? 1 : 0
        visible: opacity > 0
        transform: Translate { x: Panels.open === "nc" ? 0 : 40; Behavior on x { NumberAnimation { duration: Theme.anim.normal; easing.type: Theme.anim.easing } } }
        Behavior on opacity { NumberAnimation { id: fadeOut; duration: Theme.anim.normal; easing.type: Theme.anim.easing } }
        MouseArea { anchors.fill: parent; z: -1 }
    }
}
