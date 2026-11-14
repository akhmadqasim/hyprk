import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

// The layer a shell text field's right-click menu (HyprK TextMenu with `host`) opens in, so the liquidglass plugin gives
// it the shell menus' glass: namespace hyprk-overlay = the plugin's `menu` recipe (config/hypr/hyprland.lua materials),
// the same as the menu bar's menus (modules/MenuDropdown.qml in modules/Overlay.qml). The plugin glasses only windows'
// xdg_popups (popup_classes), never a layer surface's popup, so the menu is an in-window popup here instead. Full-screen
// like the Spotlight and Emoji layers (window coordinates carry over), mapped on the Overlay layer after them (above),
// only while the menu is open; it takes the keyboard then (the Mac's menu does) and hands it back when it unmaps.
// Used with the plugin only (Theme.compositorGlass): without it the field keeps the Qt popup and its opaque fill.
ShellWindow {
    id: host

    property bool open: false
    // the field's own layer is shown: maps the submenus' glass layer (below), before this one is mapped on open
    property bool armed: false
    readonly property Item item: content
    readonly property Component glass: glassComponent
    readonly property Component subGlass: subGlassComponent

    visible: open
    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-overlay"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Item { id: content; anchors.fill: parent }

    // A submenu's glass on a layer of its own: on one layer the plugin draws overlapping shapes as one outline (the
    // submenu sits 5 pt over the menu, Q-menubar-23), as MenuDropdown's submenus have their own surface (MenuSubmenu.qml).
    // Glass only (the rows stay in this window), mapped below this layer: under the menu's 5 pt overlap the menu's glass
    // is on top (the Mac draws the submenu on top: those 5 pt differ). Same geometry, so Glass { host } places the shape.
    ShellWindow {
        id: subHost
        screen: host.screen
        visible: host.armed
        anchors { top: true; left: true; right: true; bottom: true }
        exclusionMode: ExclusionMode.Ignore
        namespace: "hyprk-overlay"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        acceptsInput: false
    }

    // the menu's material: MenuDropdown's Glass (radius Theme.menu.radius 12, the strong tint for the QML fallback)
    Component {
        id: glassComponent
        Glass {
            radius: Theme.menu.radius
            readonly property point at: mapToItem(null, 0, 0)
            sx: at.x
            sy: at.y
            tint: Theme.glass.tintStrong
            solidColor: Theme.reduceTransparency ? Theme.color.menuSolid : Theme.glass.solid
        }
    }
    Component {
        id: subGlassComponent
        Glass {
            host: subHost
            radius: Theme.menu.radius
            readonly property point at: mapToItem(null, 0, 0)
            sx: at.x
            sy: at.y
            tint: Theme.glass.tintStrong
            solidColor: Theme.reduceTransparency ? Theme.color.menuSolid : Theme.glass.solid
        }
    }
}
