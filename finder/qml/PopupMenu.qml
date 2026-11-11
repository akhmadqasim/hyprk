import QtQuick
import HyprK
import QtQuick.Controls.Basic
import Finder.Native

// Finder menu (context menus, Group and Action pull-downs): rows 24, padding 5, r 12, the accent highlight inset
// 5 with r 7 and white text, moving in one frame; text at x 16, or 28 when an item has a checkmark; closes with a
// 0.2 s fade (MAC-ANSWERS.md Q-finder-24, Q-menubar-12/22/24). Drawn flat with the shared menu fill.
// items: [{ text, shortcut, checked, enabled, action, icon, submenu }], { separator: true }, or
// { tagRow: true, action(tagName) } for Finder's row of tag color dots. icon: a leading SF Symbol (the 27.2.1
// context menu: icon centre x 23, its row's text x 39 instead of 16; context-menu-*-light.png); submenu: items of
// a menu that opens to the right while the row is hovered, the row showing a chevron.
// A popup surface of its own (xdg_popup), as the Mac's NSPopupMenuWindow: it may leave the Finder window, and the
// compositor's popup grab closes it on a click anywhere outside (an in-window popup only saw clicks inside Finder).
// The live menu is "menu" glass (Q-menubar-13). With the liquidglass plugin (plugin/README.md "Client popups", option
// popup_classes) the compositor draws that glass, radius 12, and its shadow behind this popup surface, so the menu draws
// no fill, as the shell's MenuDropdown over its glass; closing is then Hyprland's popup fadeout (fadePopupsOut, 0.2 s),
// which dematerializes the glass with the content. Without the plugin: the opaque shared menu fill and a 0.2 s fade.
Popup {
    id: root
    popupType: Popup.Window
    readonly property bool glass: Hypr.option("plugin:liquidglass:enabled", 0) === 1

    property var items: []
    signal chose()   // a row ran its action (a submenu closes its parent through this)
    onClosed: if (sub.item) sub.item.close()
    Loader { id: sub; active: false; source: "PopupMenu.qml" }
    Connections { target: sub.item; function onChose() { root.chose(); root.close(); } }
    function openSub(row, list) {
        sub.active = true;
        const m = sub.item;
        if (m.opened && m.items === list) return;
        m.parent = row;
        m.items = list;
        m.x = row.width + root.padding - 1;
        m.y = -root.padding;
        m.open();
    }
    function closeSub() { if (sub.item) sub.item.close(); }

    padding: 5
    // the widest row's own width (a Column sizes to its rows' widths, which follow the menu's: circular)
    width: Math.max(200, list.rowsWidth + 2 * padding)
    implicitHeight: list.implicitHeight + 2 * padding
    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    readonly property bool hasChecks: items.some(i => i.checked !== undefined)
    readonly property bool hasIcons: items.some(i => !!i.icon)
    enter: Transition { NumberAnimation { property: "opacity"; to: 1; duration: 0 } }
    exit: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: root.glass ? 0 : 200; easing.type: Easing.OutQuad } }

    background: Rectangle {
        radius: Tokens.control.menuRadius
        color: root.glass ? "transparent" : Tokens.control.menuFill
        border.width: root.glass ? 0 : 1
        border.color: Tokens.control.menuStroke
    }

    contentItem: Column {
        id: list
        readonly property real rowsWidth: { let w = 0; for (const c of children) w = Math.max(w, c.implicitWidth || 0); return w; }
        Repeater {
            model: root.items
            Item {
                id: it
                required property var modelData
                readonly property bool sep: !!modelData.separator
                readonly property bool tagRow: !!modelData.tagRow
                readonly property bool plain: !sep && !tagRow
                readonly property bool on: modelData.enabled !== false
                width: root.width - 2 * root.padding
                height: sep ? 11 : tagRow ? 30 : 24
                readonly property bool hasSub: !!modelData.submenu
                implicitWidth: !plain ? 0 : label.x + label.implicitWidth + shortcutText.implicitWidth + (hasSub ? 40 : 0) + 53

                Rectangle {
                    visible: it.sep
                    anchors.centerIn: parent
                    width: parent.width - 20
                    height: 1
                    color: Theme.color.separator
                }
                Rectangle {
                    visible: it.plain && it.on && hover.hovered
                    anchors.fill: parent
                    radius: 7
                    color: Theme.color.accent
                }
                Text {
                    visible: it.plain && !!it.modelData.checked
                    x: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: "✓"
                    color: hover.hovered ? "white" : Theme.color.label
                    font: Typography.body
                }
                Symbol {   // leading symbol: 10.4 pt (ink of trash / share / gearshape 20x23 / 18x23 / 22x22 px in
                    // crops/context-menu-file-light.png, 2x; at 14 pt they were 26x31 / 24x30 / 30x30)
                    visible: it.plain && !!it.modelData.icon
                    x: 18 - 8
                    size: 16
                    pointSize: 10.4
                    weight: "medium"
                    anchors.verticalCenter: parent.verticalCenter
                    name: it.modelData.icon || ""
                    color: !it.on ? Theme.color.tertiaryLabel : hover.hovered ? "white" : Theme.color.label
                }
                Symbol {
                    visible: it.plain && it.hasSub
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    size: 13
                    name: visible ? "chevron.right" : ""
                    color: !it.on ? Theme.color.tertiaryLabel : hover.hovered ? "white" : Theme.color.label
                }
                Text {
                    id: label
                    visible: it.plain
                    x: it.modelData.icon ? 34 : root.hasChecks ? 23 : 11
                    anchors.verticalCenter: parent.verticalCenter
                    text: it.modelData.text || ""
                    color: !it.on ? Theme.color.tertiaryLabel : hover.hovered ? "white" : Theme.color.label
                    font: Typography.body
                }
                Text {
                    id: shortcutText
                    visible: it.plain
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: it.modelData.shortcut || ""
                    color: hover.hovered && it.on ? "white" : Theme.color.secondaryLabel
                    font: Typography.body
                }
                HoverHandler {
                    id: hover
                    enabled: it.plain
                    onHoveredChanged: if (hovered) { if (it.hasSub && it.on) root.openSub(it, it.modelData.submenu); else root.closeSub(); }
                }
                Row {
                    visible: it.tagRow
                    x: 14
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 9
                    Repeater {
                        model: it.tagRow ? Theme.color.tags : []
                        Rectangle {
                            required property var modelData
                            width: 15; height: 15; radius: 7.5
                            color: modelData.color
                            scale: dotHover.hovered ? 1.2 : 1
                            HoverHandler { id: dotHover }
                            TapHandler {
                                onTapped: {
                                    root.chose();
                                    root.close();
                                    it.modelData.action(parent.modelData.name);
                                }
                            }
                        }
                    }
                }
                TapHandler {
                    enabled: it.plain && it.on && !it.hasSub
                    onTapped: {
                        root.chose();
                        root.close();
                        if (it.modelData.action) it.modelData.action();
                    }
                }
            }
        }
    }
}
