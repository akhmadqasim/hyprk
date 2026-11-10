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
    // stays mapped while a menu, alert or Notification Center animates out, taking no input then
    visible: active || nc.animating || menu.visible || context.visible || alert.visible
    acceptsInput: active
    // NotificationCenter slides itself in and out on its spring; its glass materializes along
    // (menus and alerts materialize on their own; not while one already shows during the NC slide-out)
    readonly property bool ncDrives: nc.animating && (Panels.open === "nc" || !active)
    glassMaterialize: ncDrives && !A11y.reduceMotion ? Math.min(1, nc.progress) : 1
    glassOpacity: ncDrives && A11y.reduceMotion ? Math.max(0, Math.min(1, nc.progress)) : 1   // Reduce motion: crossfade

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
        shown: Panels.open === "context" && Panels.activeScreen === ov.modelData
        items: Panels.contextItems
        x: Math.max(Theme.menu.screenMargin, Math.min(ov.width - width - Theme.menu.screenMargin, Panels.contextAbove ? Panels.contextX - width / 2 : Panels.contextX))
        y: Math.max(0, Math.min(ov.height - height - Theme.menu.screenMargin,
                                Panels.contextY - Theme.menuBar.height - (Panels.contextAbove ? height : 0)))
        originX: x
        originY: y + Theme.menuBar.height
        // from the click point: above the Dock it ends at the point, else it starts there
        anchorX: Panels.contextAbove ? width / 2 : 0
        anchorY: Panels.contextAbove ? height : 0
    }

    // ---------- alert ----------
    AlertDialog {
        id: alert
        shown: Panels.open === "alert" && Panels.activeScreen === ov.modelData
        model: Panels.alert
        x: (ov.width - width) / 2
        y: (ov.height - height) * Theme.alert.verticalBias
        originX: x
        originY: y + Theme.menuBar.height
    }

    // ---------- menu ----------
    MenuDropdown {
        id: menu
        shown: Panels.open === "menu" && Panels.activeScreen === ov.modelData
        x: Math.min(Panels.menuX, ov.width - width - 4)
        y: Theme.menu.offsetY
        originX: x
        originY: y + Theme.menuBar.height
        // from the menu bar title
        anchorX: Panels.menuX - x
        anchorY: -Theme.menu.offsetY
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
        visible: shown || animating            // no glass regions off-screen while a menu shows
        MouseArea { anchors.fill: parent; z: -1 }
    }
}
