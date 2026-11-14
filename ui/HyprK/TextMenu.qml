import QtQuick
import QtQuick.Controls.Basic as C
import "textmenu.js" as TextMenuRows

// The right-click menu of a text field, with macOS 27.2.1's rows (textmenu.js: -[NSTextView menuForEvent:] and
// NSTextViewContextMenu.nib). Put it inside the field: TextMenu { target: input }. A right click away from the
// selection first selects the word under the pointer, as the field editor does (menuForEvent: selectionRangeForProposed
// Range:granularity: then setSelectedRange:), so Look Up / Cut / Copy act on it.
// Look: the shared menu metrics (MAC-ANSWERS.md Q-menubar-12/19/20/22/23): rows 24, padding 5, radius 12, text at x 16
// (x 11 in the row), accent highlight inset 5 with radius 7 and white text, separators 11 pt with the line 16 pt in,
// light black a.10 / dark white a.14, disabled rows tertiary, chevron for a submenu that opens 0.22 s after its row
// lights, 5 pt over the menu. Width: every row ends 48 pt before the edge, the submenu column AppKit keeps for all rows
// once one row has a submenu (shell/lib/menus.js rowEnd; this menu always has Spelling and Grammar ▸), else 17.
// Its own popup window (Popup.Window), so it may leave the field's window; Qt falls back to an in-window popup where the
// platform has none. Material: the live menu is "menu" glass like every NSMenu (Q-menubar-13). With Tokens.popupGlass
// (the liquidglass plugin draws the shell menus' `menu` glass, radius 12 and shadow behind the app's xdg_popups:
// plugin/README.md "Client popups", popup_classes) the menu draws no fill, as Finder's PopupMenu, and the plugin fades it
// out; without it (no plugin, a window not in popup_classes, or Reduce Transparency / Increase Contrast, where the Mac's
// menu is opaque too) the opaque Tokens.control.menuFill with its stroke and a 0.2 s fade (FALLBACKS.md).
// `host` + `glassBackground`: a layer shell's field (Spotlight, the Emoji picker) has no xdg_popup glass from the plugin
// (popup_classes are windows' classes), so the shell opens the menu as an in-window popup inside `host`, an Item of a
// full-screen layer of its own on the shell's menu namespace (hyprk-overlay: the plugin's `menu` recipe, the glass of the
// menu bar's menus, shell/modules/MenuDropdown.qml), and `glassBackground` (the shell's Glass) draws the material. The
// host covers the same screen as the field's own full-screen layer, so window coordinates carry over.
// `host` + `glassBackground`: a layer shell's field (Spotlight, the Emoji picker) has no xdg_popup glass from the plugin
// (popup_classes are windows' classes), so the shell opens the menu as an in-window popup inside `host`, the content of a
// full-screen layer of its own on the shell's menu namespace (hyprk-overlay: the plugin's `menu` recipe, the same glass
// as the menu bar's menus, shell/modules/MenuDropdown.qml), and `glassBackground` (the shell's Glass) draws the material.
// The host covers the same screen as the field's own full-screen layer, so window coordinates carry over.
MouseArea {
    id: area
    property Item target: parent
    property bool secure: false          // a password field: no menu (textmenu.js)
    property Item host: null             // an Item of a full-screen window to open the menu in (see the header)
    property Component glassBackground: null
    property Component subGlassBackground: null   // the submenus' (a glass of its own: one region would merge both)
    // true while the menu is up: the popup takes the keyboard, so a field that ends editing on focus loss (Finder's
    // rename field) waits for it; the field gets the keyboard back when the menu closes, as with the Mac's menu
    readonly property bool open: menu.visible || hostWanted
    // a hosted menu maps its host first (the host binds its visibility to `open`) and opens a frame later: an Item popup
    // in a window that is not shown stays hidden
    property bool hostWanted: false
    anchors.fill: target
    acceptedButtons: Qt.RightButton
    cursorShape: Qt.IBeamCursor

    // closes the menu without choosing (its owner went away: e.g. the shell panel holding the field closed)
    function dismiss() { if (open) { hostWanted = false; menu.close(); } }
    function selectWordAt(x, y) {
        const t = target;
        const p = t.positionAt(x, y);
        if (t.selectionStart !== t.selectionEnd && p >= t.selectionStart && p <= t.selectionEnd) return;
        const s = String(t.text);
        const word = c => /[0-9A-Za-z_'\u00C0-\u024F\u0370-\u1FFF\u3040-\uFFEF]/.test(c);   // QV4 has no \p{L}
        let a = p, b = p;
        while (a > 0 && word(s[a - 1])) a--;
        while (b < s.length && word(s[b])) b++;
        if (b > a) t.select(a, b);
        else t.deselect();
    }
    function run(id) {
        const t = target;
        const ed = !t.readOnly;
        switch (id) {
        case "cut": t.cut(); break;
        case "copy": t.copy(); break;
        case "paste": case "pasteplain": t.paste(); break;   // a plain field: both paste plain text
        case "search": Qt.openUrlExternally("https://www.google.com/search?q=" + encodeURIComponent(t.selectedText)); break;
        default: {
            const out = TextMenuRows.transform(id, t.selectedText);
            if (out === null || !ed) return;
            const a = t.selectionStart;
            t.remove(a, t.selectionEnd);
            t.insert(a, out);
            t.select(a, a + out.length);
        }
        }
    }
    onPressed: mouse => {
        if (secure) return;
        target.forceActiveFocus();
        selectWordAt(mouse.x, mouse.y);
        const list = TextMenuRows.rows({ selected: target.selectedText, editable: !target.readOnly,
                                         canPaste: target.canPaste });
        if (list.length === 0) return;
        menu.items = list;
        const p = area.mapToItem(null, mouse.x, mouse.y);
        menu.parent = area.host || area.Window.contentItem || area;
        // AppKit's popUpMenu at the pointer: the first row's top at the point (Q-menubar-27, generic AppKit case)
        menu.x = p.x;
        menu.y = p.y - menu.padding;
        if (host) { hostWanted = true; Qt.callLater(() => menu.open()); }
        else menu.open();
    }

    component Menu: C.Popup {
        id: m
        popupType: owner && owner.host ? C.Popup.Item : C.Popup.Window
        readonly property bool hosted: !!(owner && owner.host && owner.glassBackground)
        property bool isSub: false
        property var items: []
        property var owner: null   // the TextMenu (inline components do not see the file's ids)
        signal chose()
        padding: 5
        width: list.rowsWidth + 2 * padding   // no minimum on the Mac (Q-menubar-19)
        readonly property bool glass: hosted || (Tokens.popupGlass && !Tokens.reduceTransparency && !Tokens.increaseContrast)
        readonly property real rowEnd: TextMenuRows.rowEnd(items)   // 48 once a row has a submenu, else 17
        implicitHeight: list.implicitHeight + 2 * padding
        modal: false
        focus: true
        closePolicy: C.Popup.CloseOnEscape | C.Popup.CloseOnPressOutside
        onClosed: { subTimer.stop(); if (sub.item) sub.item.close(); }
        enter: Transition { NumberAnimation { property: "opacity"; to: 1; duration: 0 } }
        exit: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: m.glass ? 0 : 200; easing.type: Easing.OutQuad } }
        background: Item {
            Rectangle {
                visible: !m.hosted
                anchors.fill: parent
                radius: Tokens.control.menuRadius
                color: m.glass ? "transparent" : Tokens.control.menuFill
                border.width: m.glass ? 0 : 1
                border.color: Tokens.control.menuStroke
            }
            Loader { anchors.fill: parent; active: m.hosted && m.visible; sourceComponent: !m.owner ? null : m.isSub && m.owner.subGlassBackground ? m.owner.subGlassBackground : m.owner.glassBackground }
        }
        property Component subComponent: null   // set by the TextMenu, as `owner`
        Loader { id: sub; active: false; sourceComponent: m.subComponent }
        Connections { target: sub.item; function onChose() { m.chose(); m.close(); } }
        Timer {   // Q-menubar-23: the submenu shows 0.22 s after its row lights
            id: subTimer
            interval: 220
            property Item row
            onTriggered: {
                if (!row || !m.subComponent) return;
                sub.active = true;
                const s = sub.item;
                s.parent = row;
                s.items = row.modelData.items;
                s.x = row.width + m.padding - 5;
                s.y = -m.padding;
                s.open();
            }
        }
        readonly property Item subRow: sub.item && sub.item.opened ? sub.item.parent : null
        contentItem: Column {
            id: list
            readonly property real rowsWidth: { let w = 0; for (const c of children) w = Math.max(w, c.implicitWidth || 0); return w; }
            Repeater {
                model: m.items
                Item {
                    id: row
                    required property var modelData
                    readonly property bool sep: !!modelData.sep
                    readonly property bool hasSub: !!modelData.items && modelData.items.length !== undefined   // a JS array arrives as a list, not an Array
                    readonly property bool on: !sep && modelData.disabled !== true && (!hasSub || modelData.items.length > 0)
                    readonly property bool lit: on && (hover.hovered || m.subRow === row)
                    width: m.width - 2 * m.padding
                    height: sep ? 11 : 24
                    // text at 16 in the menu (11 in the row), then rowEnd to the menu's edge (5 of it outside the row)
                    implicitWidth: sep ? 0 : label.x + label.implicitWidth + m.rowEnd - m.padding
                    Rectangle {   // Q-menubar-20: 1 pt line, 16 pt in from the menu's edges
                        visible: row.sep
                        x: 11; width: parent.width - 22; height: 1
                        anchors.verticalCenter: parent.verticalCenter
                        color: Tokens.dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.10)
                    }
                    Rectangle {
                        visible: row.lit
                        anchors.fill: parent
                        radius: 7
                        color: Tokens.accent
                    }
                    Text {
                        id: label
                        visible: !row.sep
                        x: 11
                        anchors.verticalCenter: parent.verticalCenter
                        text: row.modelData.label || ""
                        font: Typography.menu
                        color: !row.on ? Tokens.tertiaryLabel : row.lit ? "white" : Tokens.label
                    }
                    SfSymbol {   // Q-menubar-23: the chevron's centre W - 23.25 in the menu, W - 18.25 in the row
                        visible: row.hasSub
                        x: parent.width - 18.25 - width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        name: "chevron.forward"   // = chevron.right left to right; our set has only this name
                        pointSize: 11             // ink about 9.5 pt tall as Q-menubar-23 (size fitted by eye: GUESS)
                        color: !row.on ? Tokens.tertiaryLabel : row.lit ? "white" : Tokens.label
                    }
                    HoverHandler {
                        id: hover
                        enabled: !row.sep
                        onHoveredChanged: if (hovered) {
                            if (row.hasSub && row.on) { if (m.subRow !== row) { if (sub.item) sub.item.close(); subTimer.row = row; subTimer.restart(); } }
                            else { subTimer.stop(); if (sub.item) sub.item.close(); }
                        }
                    }
                    TapHandler {
                        enabled: row.on && !row.hasSub
                        onTapped: { const id = row.modelData.id; m.chose(); m.close(); if (id && m.owner) m.owner.run(id); }
                    }
                }
            }
        }
    }
    Component { id: subMenu; Menu { owner: area; isSub: true } }
    Menu { id: menu; owner: area; subComponent: subMenu; onClosed: { area.hostWanted = false; if (area.target) area.target.forceActiveFocus(); } }
}
