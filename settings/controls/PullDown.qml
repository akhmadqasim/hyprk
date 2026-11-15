import QtQuick
import QtQuick.Controls.Basic as C
import QtQuick.Effects
import ".."
import "../HyprK"

// A pull-down menu button as System Settings 27.2.1 draws one (AXMenuButton: Network's "More", 61.5 x 24, VPN's "Add",
// 61 x 24; MAC-ANSWERS-13.md R13.2, live/settings-r13/pop-network-00-dark.png, popups.json "network"): a push button
// holding a glyph (ellipsis / plus, centre 19 pt in) and a chevron.down (centre 48 pt in). The menu is a plain NSMenu,
// not a pop-up's: no checked row on the button; it hangs 5.5 pt left of the button and, for `above`, ends 3 pt over it
// (menu 619,426 229 x 152 for the button at 624.5,581). Rows 24, padding 5, separators 11, text 16 pt in (25 when a
// row is checked), every row ending 48 pt before the edge once a row has a submenu, else 17 (HyprK TextMenu's metrics).
// A row with `sub` opens its submenu beside it, 5 pt over the menu. Material as HyprK Popup: the plugin's menu glass
// when it draws popups, else the flat fill.
// items: [{ title, sub: [items], checked }] and { sep: true }. `chosen(title)` when a leaf row is picked.
// { title, header: true } is a disabled heading row (Displays' Add menu: "Mirror or extend to", MAC-ANSWERS-14.md R14.5)
// and `glyph` an SF Symbol before the title (its devices).
Rectangle {
    id: pd
    property string glyph: "ellipsis"
    property var items: []
    property bool above: false
    signal chosen(string title)
    readonly property bool opened: menu.visible
    function open() { menu.open(); }
    function close() { subMenu.close(); menu.close(); }
    // the titles of the open menu's rows, and of the open submenu's (tests)
    function titles(of) { return (of || items).filter(i => !i.sep).map(i => i.title); }
    readonly property bool _glass: Tokens.popupGlass && !Tokens.reduceTransparency && !Tokens.increaseContrast
    function _height(list) { let h = 10; for (const i of list) h += i.sep ? 11 : 24; return h; }

    width: 61.5; height: 24; radius: 6
    color: Qt.alpha(Tokens.control.pushFill, Tokens.control.pushFill.a * (enabled ? 1 : Tokens.control.disabledOpacity))
    Rectangle { anchors.fill: parent; radius: parent.radius; visible: ma.pressed || menu.visible; color: Tokens.control.pressOverlay }
    SfSymbol { x: 19 - width / 2; anchors.verticalCenter: parent.verticalCenter; name: pd.glyph; pointSize: 12; weight: pd.glyph === "ellipsis" ? "medium" : "regular"; color: Theme.label }
    SfSymbol { x: 48 - width / 2; anchors.verticalCenter: parent.verticalCenter; name: "chevron.down"; pointSize: 9; weight: "regular"; color: Theme.label }
    MouseArea { id: ma; anchors.fill: parent; onPressed: menu.visible ? pd.close() : pd.open() }

    component MenuBody: C.Popup {
        id: m
        property var rows: []
        property bool top: true          // the root menu (its rows may open the submenu)
        readonly property bool marks: rows.some(r => r.checked)
        readonly property bool subs: rows.some(r => r.sub)
        padding: 5
        margins: pd._glass ? -1 : 4
        popupType: pd._glass ? C.Popup.Window : C.Popup.Item
        width: col.widest + 10
        height: pd._height(rows)
        enter: null; exit: null
        background: Item {
            visible: !pd._glass
            RectangularShadow { anchors.fill: parent; radius: Tokens.control.menuRadius; blur: 34; color: Qt.rgba(0, 0, 0, 0.2) }
            Rectangle {
                anchors.fill: parent; radius: Tokens.control.menuRadius
                color: Tokens.dark ? Qt.rgba(63 / 255, 64 / 255, 70 / 255, 1) : Qt.rgba(249 / 255, 249 / 255, 249 / 255, 1)
                border.width: 0.5; border.color: Tokens.dark ? Qt.rgba(0, 0, 0, 0.75) : Qt.rgba(0, 0, 0, 0.33)
            }
        }
        readonly property bool hovered: over.hovered
        Column {
            id: col
            HoverHandler { id: over }
            readonly property real widest: { let w = 0; for (let i = 0; i < children.length; i++) w = Math.max(w, children[i].need || 0); return w; }
            Repeater {
                model: m.rows
                Item {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool sep: modelData.sep === true
                    readonly property real need: sep ? 0 : t.x + t.implicitWidth + (m.subs ? 48 : 17) - 5
                    readonly property bool header: modelData.header === true
                    readonly property string glyph: modelData.glyph || ""
                    readonly property bool hot: !sep && !header && (hover.containsMouse || (m.top && subMenu.visible && subMenu.from === index))
                    objectName: "menuRow" + index
                    width: m.width - 10; height: sep ? 11 : 24
                    Rectangle { visible: row.sep; x: 11; y: 5; width: parent.width - 22; height: 1; color: Tokens.dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.10) }
                    Rectangle { visible: row.hot; anchors.fill: parent; radius: Tokens.control.menuHighlightRadius; color: Tokens.accent }
                    SfSymbol { visible: !row.sep && row.modelData.checked === true; x: 8.5; anchors.verticalCenter: parent.verticalCenter; name: "checkmark"; weight: "semibold"; pointSize: 10.7; color: row.hot ? "white" : Tokens.label }
                    SfSymbol { visible: row.glyph !== ""; x: 11; anchors.verticalCenter: parent.verticalCenter; name: row.glyph; pointSize: 12; color: row.hot ? "white" : Tokens.label }
                    Text { id: t; visible: !row.sep; x: (m.marks ? 25 : 11) + (row.glyph !== "" ? 22 : 0); anchors.verticalCenter: parent.verticalCenter; text: row.modelData.title || ""; font: Typography.menu; color: row.hot ? "white" : row.header ? Tokens.control.disabledText : Tokens.label }
                    SfSymbol { visible: !row.sep && !!row.modelData.sub; x: parent.width - 16; anchors.verticalCenter: parent.verticalCenter; name: "chevron.forward"; weight: "semibold"; pointSize: 9.5; color: row.hot ? "white" : Tokens.label }
                    MouseArea {
                        id: hover
                        anchors.fill: parent; hoverEnabled: true; enabled: !row.sep
                        function sub() {
                            if (!m.top) return;
                            if (!row.modelData.sub) { subMenu.close(); return; }
                            subMenu.from = row.index;
                            subMenu.rows = row.modelData.sub;
                            subMenu.x = menu.x + menu.width - 5;
                            subMenu.y = menu.y + row.y;
                            subMenu.open();
                        }
                        onContainsMouseChanged: if (containsMouse) sub()
                        onClicked: {
                            if (row.header) return;                 // a heading takes the press and does nothing
                            if (row.modelData.sub) { sub(); return; }
                            pd.close();
                            pd.chosen(row.modelData.title);
                        }
                    }
                }
            }
        }
    }
    MenuBody {
        id: menu
        objectName: "menu"
        rows: pd.items
        x: -5.5
        y: pd.above ? -height - 3 : pd.height + 3
        // with the submenu up a press outside goes to the submenu first (it closes, and this menu with it unless the
        // press was on one of this menu's rows)
        closePolicy: subMenu.visible ? C.Popup.CloseOnEscape : C.Popup.CloseOnEscape | C.Popup.CloseOnPressOutside
        onClosed: subMenu.close()
    }
    MenuBody {
        id: subMenu
        objectName: "subMenu"
        top: false
        property int from: -1
        onClosed: if (!menu.hovered) menu.close()
    }
}
