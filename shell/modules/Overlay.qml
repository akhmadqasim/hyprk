import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.components
import qs.services
import "../lib/menus.js" as Menus
import "../HyprK/panels.js" as P

// Transparent click-catcher below the menu bar that hosts the pull-down
// menus, context menus and alerts. Clicking outside closes. Control Center and
// Notification Center have their own layers (ControlCenterWindow.qml, NotificationCenterWindow.qml).
ShellWindow {
    id: ov

    required property var modelData
    screen: modelData

    // modelData, not screen: mapping the window re-emits screenChanged (binding loop)
    readonly property bool active: ["menu", "context", "alert"].indexOf(Panels.open) !== -1
                                   && Panels.activeScreen === modelData
    // stays mapped while a menu or alert animates out, taking no input then
    visible: active || menu.visible || context.visible || alert.visible || Panels.warmScreen === modelData
    acceptsInput: active

    anchors { top: true; left: true; right: true; bottom: true }
    margins.top: Theme.menuBar.height
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-overlay"
    WlrLayershell.layer: WlrLayer.Overlay
    // the alert must get Return/Escape even when opened without a click (IPC, Dock menu); an open menu takes the keys
    // too (Q-menubar-25: arrows, Return, Esc), although the click that opened it went to the menu bar or the Dock
    WlrLayershell.keyboardFocus: active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    MouseArea {
        anchors.fill: parent
        onPressed: Panels.close()
    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: Panels.close()
        // arrows, Return and typed letters go to the open menu (and on to its submenu, MenuDropdown.key); Left / Right
        // that the menu does not take move to the previous / next menu bar title (Q-menubar-25)
        Keys.onPressed: e => {
            const m = menu.shown ? menu : context.shown ? context : null;
            if (m && m.key(e.key, e.text)) e.accepted = true;
            else if (m === menu && (e.key === Qt.Key_Left || e.key === Qt.Key_Right)) {
                Panels.menuStep(Panels.menuIndex + (e.key === Qt.Key_Right ? 1 : -1));
                e.accepted = true;
            }
        }
    }

    // ---------- context menu (desktop, Dock) ----------
    MenuDropdown {
        id: context
        host: ov
        shown: Panels.open === "context" && Panels.activeScreen === ov.modelData
        items: Panels.contextItems
        // AppKit popUp at a point (MAC-ANSWERS.md Q-menubar-27): x = point, top = point - 5 so the first row
        // starts at the pointer; at the right edge it flips to the left of the point, at the bottom it is
        // shifted up to 6 pt above the edge. Above the Dock it is centred on the point and ends there.
        readonly property real px: Panels.contextAbove ? Panels.contextX - width / 2
                                 : Panels.contextX + width > ov.width - Theme.menu.screenMargin ? Panels.contextX - width : Panels.contextX
        x: Math.max(Theme.menu.screenMargin, Math.min(ov.width - width - Theme.menu.screenMargin, px))
        y: Math.max(0, Math.min(ov.height - height - Theme.menu.screenMargin,
                                Panels.contextY - Theme.menuBar.height - (Panels.contextAbove ? height : Theme.menu.padding)))
        originX: x
        originY: y + Theme.menuBar.height
    }

    // ---------- alert ----------
    AlertDialog {
        id: alert
        shown: Panels.open === "alert" && Panels.activeScreen === ov.modelData
        model: Panels.alert
        x: (ov.width - width) / 2
        // its top at 0.26 of the screen less a quarter of its height (Q-panels-33, HyprK panels.js alertTop); this
        // layer starts under the menu bar
        y: P.alertTop(ov.height + Theme.menuBar.height, height) - Theme.menuBar.height
        originX: x
        originY: y + Theme.menuBar.height
    }

    // ---------- menu ----------
    // shows Panels.menuShown, not menuIndex: while switching by hover the menu follows the title
    // pill a few frames later (Panels.stepMenu)
    MenuDropdown {
        id: menu
        host: ov
        shown: Panels.open === "menu" && Panels.activeScreen === ov.modelData
        // at the title frame x - 5, 1 pt below the bar, kept 6 pt off the right edge (Q-menubar-14)
        x: Math.max(0, Math.min(Panels.menuShownX + Theme.menu.offsetX, ov.width - width - Theme.menu.screenMargin))
        y: Theme.menu.offsetY
        originX: x
        originY: y + Theme.menuBar.height
        items: Panels.menuShown < 0 ? []
             : Menus.forIndex(Panels.menuShown, Apps.appIdOf(Apps.activeToplevel), Apps.activeAppName(), Quickshell.env("USER"))
    }
}
