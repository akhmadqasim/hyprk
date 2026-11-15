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
    // the alert scales and blurs as a whole window, its drop shadow with it (ShellWindow glassShadowSize / glassSoften)
    glassShadowSize: alert.visible ? alert.pop : 1
    glassSoften: alert.visible ? alert.soften : 0
    // and fades as a window: its glass at full material under the layer's opacity marker (= AppKit's window alpha v / 1 - p),
    // while no menu shares the layer (a menu opened during the Cancel fade: the alert's glass materializes instead).
    // Materialize drew the small alert with a soft edge (1 - m) 10 pt wide and in 1 / (w - 3) steps: light, footprint
    // reach / scale 128-147 pt above its centre at s .07-.18 (Mac 116-120), alpha .13-.17 at v .04-.08 (MOTION-AUDIT.md
    // "Alert, Round R3.1")
    readonly property bool alertAlone: alert.visible && !menu.visible && !context.visible
    glassOpacity: alertAlone ? alert.fade : 1
    WlrLayershell.layer: WlrLayer.Overlay
    // the alert must get Return/Escape even when opened without a click (IPC, Dock menu); an open menu takes the keys
    // too (Q-menubar-25: arrows, Return, Esc), although the click that opened it went to the menu bar or the Dock
    // (not while the button that opened a menu is still down: Panels.pointerHeld)
    WlrLayershell.keyboardFocus: active && !Panels.pointerHeld ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

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

    // if the compositor moved the pointer here while the button was down anyway, the bar has lost the release: the
    // menu takes the keyboard at once and works by hover and clicks
    HoverHandler { onHoveredChanged: if (hovered && Panels.pointerHeld) Panels.pointerHeld = false }
    // press, drag, release from a menu bar title: the bar keeps the grab and passes the pointer on (Panels.menuPointer);
    // this layer starts under the menu bar
    Connections {
        target: ov.active ? Panels : null
        function onMenuPointer(x, y, release) {
            const m = menu.shown ? menu : context.shown ? context : null;
            if (!m) return;
            if (release) m.releaseAt(x, y - Theme.menuBar.height);
            else m.pointAt(x, y - Theme.menuBar.height);
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
        // shifted up to 6 pt above the edge. Above the Dock (the point is the icon centre and the Dock top): the
        // body starts menuLeft - menuInset left of the point and ends menuInset above it (Q-dock-10).
        readonly property real px: Panels.contextAbove ? Panels.contextX - Theme.dock.menuLeft + Theme.dock.menuInset
                                 : Panels.contextX + width > ov.width - Theme.menu.screenMargin ? Panels.contextX - width : Panels.contextX
        x: Math.max(Theme.menu.screenMargin, Math.min(ov.width - width - Theme.menu.screenMargin, px))
        y: Math.max(0, Math.min(ov.height - height - Theme.menu.screenMargin,
                                Panels.contextY - Theme.menuBar.height - (Panels.contextAbove ? height + Theme.dock.menuInset : Theme.menu.padding)))
        originX: x
        originY: y + Theme.menuBar.height
        // above the Dock its bottom edge carries the tail, the tip at the icon centre and on the Dock top (Theme.dock
        // menuInset = the tail's 13 pt height; GAPS-REA-dock.md 1: only a menu opened at a rect has one, so the
        // desktop's has none)
        tailX: Panels.contextAbove ? Panels.contextX - x : -1
        blinkOnMs: Panels.contextAbove ? Theme.menu.blinkOnDock : Theme.menu.blinkOn
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
        windowAlpha: ov.alertAlone
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
             : Menus.forIndex(Panels.menuShown, Apps.appIdOf(Apps.activeToplevel), Apps.activeAppName(), Quickshell.env("USER"),
                              // the Window menu's window list (menus.js windowList): the key window checked, minimised ◆
                              Apps.activeAppWindows().map(w => ({ title: w.title, key: w === Apps.activeToplevel,
                                                                  minimized: Apps.isMinimized(w),
                                                                  action: () => Apps.isMinimized(w) ? Apps.restoreWindow(w) : Apps.focusWindow(w) })))
    }
}
