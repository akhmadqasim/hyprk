import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.services
import "../lib/menus.js" as Menus

// The open submenu of a MenuDropdown (loaded by it), on its own layer surface: same namespace (hyprk-overlay, the
// menu glass) and layer as the Overlay, mapped above it. In the parent's window its region would overlap the parent's
// by 5 pt and the plugin would take both as one shape; as its own surface it is a second glass drawn over the parent,
// like the Mac's second menu window (MAC-ANSWERS.md Q-menubar-23). Same geometry as the Overlay, so positions carry
// over. It is mapped from the moment the hover delay starts (the delay covers the new surface's first frames) and
// shows nothing and takes no input until the submenu opens.
ShellWindow {
    id: sw

    property var owner: null                  // the parent MenuDropdown (set by its Loader)
    readonly property alias menu: sub
    readonly property int row: owner ? (owner.subIndex >= 0 ? owner.subIndex : owner.subPending) : -1

    screen: owner && owner.host ? owner.host.screen : null
    anchors { top: true; left: true; right: true; bottom: true }
    margins.top: Theme.menuBar.height
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-overlay"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None   // keys reach the Overlay, which hands them down
    inputMask: Region { item: sub.visible ? sub : null }

    // the parent's top-left in window coordinates, taken again whenever the parent or the row changes
    readonly property point at: {
        if (!owner) return Qt.point(0, 0);
        void (owner.x + owner.y + owner.width + row);
        return owner.mapToItem(null, 0, 0);
    }
    readonly property var frame: !owner || row < 0 ? ({ x: 0, y: 0 }) : Menus.submenuFrame({
        menuX: at.x, menuY: at.y, menuW: owner.width,
        rowTop: Theme.menu.padding + Menus.rowTop(owner.shownItems, row, Theme.menu.itemHeight, Theme.menu.separatorHeight),
        subW: sub.width, subH: sub.height, areaW: sw.width, areaH: sw.height,
        overlap: Theme.menu.submenuOverlap, pad: Theme.menu.padding, margin: Theme.menu.screenMargin,
    })

    MenuDropdown {
        id: sub
        host: sw
        items: sw.owner && sw.row >= 0 ? sw.owner.shownItems[sw.row].items || [] : []
        shown: !!sw.owner && sw.owner.shown && sw.owner.subIndex >= 0
        parentMenu: sw.owner
        selectFirst: !!sw.owner && sw.owner.subKeyboard   // opened with Right / Return: first row selected
        x: sw.frame.x
        y: sw.frame.y
        originX: x
        originY: y + Theme.menuBar.height
    }
}
