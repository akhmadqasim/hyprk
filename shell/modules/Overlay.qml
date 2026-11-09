import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.components
import qs.services
import "../lib/menus.js" as Menus

// Transparent click-catcher below the menu bar that hosts the pull-down
// menus, Control Center and Notification Center. Clicking outside closes.
PanelWindow {
    id: ov

    required property var modelData
    screen: modelData

    readonly property bool active: ["menu", "context", "alert", "cc", "nc"].indexOf(Panels.open) !== -1
    visible: active || fadeOut.running

    anchors { top: true; left: true; right: true; bottom: true }
    margins.top: Theme.menuBar.height
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.namespace: "hyprk-overlay"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: active ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    MouseArea {
        anchors.fill: parent
        onPressed: Panels.close()
    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: Panels.open === "alert" ? alert.pressCancel() : Panels.close()
        Keys.onReturnPressed: if (Panels.open === "alert") alert.pressDefault()
        Keys.onEnterPressed: if (Panels.open === "alert") alert.pressDefault()
    }

    // ---------- context menu (desktop, Dock) ----------
    MenuDropdown {
        id: context
        visible: Panels.open === "context"
        items: visible ? Panels.contextItems : []
        x: Math.max(4, Math.min(ov.width - width - 4, Panels.contextAbove ? Panels.contextX - width / 2 : Panels.contextX))
        y: Math.max(0, Panels.contextY - Theme.menuBar.height - (Panels.contextAbove ? height : 0))
        originX: x
        originY: y + Theme.menuBar.height
    }

    // ---------- alert ----------
    AlertDialog {
        id: alert
        visible: Panels.open === "alert"
        model: Panels.alert
        x: (ov.width - width) / 2
        y: (ov.height - height) / 3
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

    // ---------- control center ----------
    ControlCenter {
        id: cc
        anchors.right: parent.right
        anchors.rightMargin: Theme.cc.marginRight
        y: Theme.cc.marginTop
        originX: ov.width - width - Theme.cc.marginRight
        originY: y + Theme.menuBar.height
        opacity: Panels.open === "cc" ? 1 : 0
        visible: opacity > 0
        scale: Panels.open === "cc" ? 1 : 0.96
        transformOrigin: Item.TopRight
        Behavior on opacity { NumberAnimation { duration: Theme.anim.normal; easing.type: Theme.anim.easing } }
        Behavior on scale { NumberAnimation { duration: Theme.anim.normal; easing.type: Theme.anim.easing } }
        MouseArea { anchors.fill: parent; z: -1 }   // swallow clicks so they don't close
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
