import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs
import qs.components
import qs.HyprK
import qs.services
import "../lib/menus.js" as Menus

// Menu of macOS 27.2.1, one component for every menu: menu bar pull-downs and the context menus of the
// desktop and the Dock (Overlay.qml). Pull-down and context menu are the same glass, radius 12, with
// identical rows (MAC-ANSWERS.md Q-menubar-13, -27). Rows 24 pt, separators 11, 5 pt top/bottom padding;
// solid accent selection inset 5, radius 7 (Q-menubar-12); text at x 16, 30 when some row has a state
// (`checked`: true or "mixed"), 40 / 51 for rows with an `icon` (Q-menubar-15..17); key column right-aligned
// at W - 18.5 with modifiers 3 pt before it (Q-menubar-18). No minimum width (Q-menubar-19).
// Motion: appears complete at once, a chosen row blinks once (off 67 ms, on 50 ms) and then the menu runs
// the item and fades out in 0.2 s ease-out, as on Esc (Q-menubar-23, -24). The selection jumps from row to
// row in one frame, no glide (MAC-ANSWERS "No animation: the highlight moves within 1 frame").
// Submenus (Q-menubar-23): a row with `submenu: true` and `items` opens them 0.22 s after it is highlighted (at once on
// a click, Right or Return), on its own surface (MenuSubmenu.qml) overlapping this menu's right edge by 5 pt with its
// first row level with the row; the row stays highlighted while it is open; another row closes it in the same frame.
// Keys (Q-menubar-25, handed in by the Overlay): Up/Down without wrap, Right/Return open a submenu with its first row
// selected, Left closes it, Return runs a row.
Item {
    id: root

    property var items: []
    property bool shown: false
    property real originX: 0       // screen position of this item, for the glass backdrop
    property real originY: 0
    property var host: null        // the window this menu is in (Overlay or a submenu surface), for submenus
    // a submenu's parent menu: closing with the parent (Esc, a chosen row) fades, a move to another parent row hides
    // the submenu in one frame (read when it closes, not bound: the two change in the same event)
    property var parentMenu: null
    property bool selectFirst: false   // select the first row when shown (a submenu opened from the keyboard)

    // the items stay while the menu fades out. The menu bar clears them on close, and that arrives
    // while `shown` is still true (Panels resets menuIndex first), so an empty list is never taken
    property var shownItems: []
    function latchItems() { if (shown && items.length > 0) shownItems = items; }
    onItemsChanged: latchItems()
    // 1 while shown, then down to 0 on close: glass materialize and content opacity
    property real fade: 0
    visible: shown || fade > 0
    NumberAnimation { id: fadeOut; target: root; property: "fade"; to: 0; duration: Theme.anim.menuFadeOut; easing.type: Easing.OutQuad }
    Component.onCompleted: { latchItems(); if (shown) fade = 1; }

    // ---------- columns ----------
    FontMetrics { id: metrics; font: Typography.menu }
    function keyOf(s) { const a = Array.from(s || ""); return a.length ? a[a.length - 1] : ""; }
    function modsOf(s) { return Array.from(s || "").slice(0, -1).join("").trim(); }
    // the state column exists as soon as one row has a state; it is per menu, not per row
    readonly property bool hasState: shownItems.some(it => !it.sep && !!it.checked)
    function textXOf(it) {
        if (it.icon) return hasState ? Theme.menu.stateIconTextX : Theme.menu.iconTextX;
        return hasState ? Theme.menu.stateTextX : Theme.menu.textX;
    }
    // key column = the widest key glyph of this menu, each key centred in it
    readonly property real keyWidth: {
        let w = 0;
        for (const it of shownItems)
            if (!it.sep && it.shortcut) w = Math.max(w, metrics.advanceWidth(keyOf(it.shortcut)));
        return w;
    }
    // width = the widest row: its text plus what trails it (shortcut columns, chevron field or the plain end)
    readonly property real contentWidth: {
        let w = 0;
        for (const it of shownItems) {
            if (it.sep) continue;
            const m = modsOf(it.shortcut);
            const tail = it.shortcut ? Theme.menu.shortcutGap + (m ? metrics.advanceWidth(m) + Theme.menu.modifierGap : 0) + keyWidth + Theme.menu.keyRight
                       : it.submenu ? Theme.menu.shortcutGap + Theme.menu.chevronField
                       : Theme.menu.trailing;
            w = Math.max(w, textXOf(it) + metrics.advanceWidth(it.label || "") + tail);
        }
        return Math.ceil(w);
    }
    width: contentWidth
    height: list.height + Theme.menu.padding * 2

    signal triggered()

    function trigger(action) {
        Panels.close();
        triggered();
        if (typeof action === "function") {
            action();
            return;
        }
        // parameterised actions (menus.js): the app's own shortcut, a Finder location, an About box, a Spotlight mode
        const keys = Menus.keysOf(action);
        if (keys) {
            Hyprland.dispatch(`hl.dsp.send_shortcut({ mods = "${keys.mods}", key = "${keys.key}", window = "activewindow" })`);
            return;
        }
        const arg = String(action).replace(/^[^:]*:?/, "");
        switch (String(action).split(":")[0]) {
        case "finder": Apps.openFinder(arg); return;
        case "about-app": Panels.showAlert({
            icon: arg === "Finder" ? "hyprk-finder" : ((Apps.entryFor(Apps.appIdOf(Hyprland.activeToplevel)) || {}).icon || ""),
            title: arg,
            message: "",
            buttons: [{ label: "OK", isDefault: true }],
        }); return;
        case "spotlight": if (arg) { SpotlightState.openIn(arg); return; } break;
        }
        switch (action) {
        case "empty-trash": Apps.confirmEmptyTrash(); break;
        case "minimize": Hyprland.dispatch('hl.dsp.window.move({ workspace = "special:minimized" })'); break;
        case "center": Hyprland.dispatch("hl.dsp.window.center()"); break;
        case "cycle": Hyprland.dispatch("hl.dsp.window.cycle_next()"); break;
        case "settings": Apps.openSettings(); break;
        case "about": Panels.showAlert({
            icon: Distro.aboutIcon,
            title: "About This Computer",
            message: Distro.prettyName + (Distro.kernel ? "\nLinux " + Distro.kernel : ""),
            buttons: [{ label: "More Info…", action: Apps.openSettings }, { label: "OK", isDefault: true }],
        }); break;
        case "forcequit": Hyprland.dispatch("hl.dsp.window.kill()"); break;
        case "close": Hyprland.dispatch("hl.dsp.window.close()"); break;
        case "fullscreen": Hyprland.dispatch("hl.dsp.window.fullscreen()"); break;
        case "zoom": Hyprland.dispatch("hl.dsp.window.fullscreen({ mode = \"maximized\" })"); break;
        case "spotlight": Panels.open = "spotlight"; break;
        case "apps": AppsView.show(); break;
        case "sleep": Power.sleep(); break;
        case "restart": Power.restart(); break;
        case "shutdown": Power.shutdown(); break;
        case "lock": Power.lock(); break;
        case "logout": Power.logout(); break;
        case "widgets": Panels.open = "nc"; break;
        case "desktop-new-folder":
            Quickshell.execDetached(["sh", "-c", 'd="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"; n="$d/untitled folder"; i=2; while [ -e "$n" ]; do n="$d/untitled folder $i"; i=$((i+1)); done; mkdir -p "$n"']);
            break;
        }
    }

    // a click blinks the row once (highlight off, then on) and then runs it; the menu takes no input meanwhile
    property bool activating: false
    property bool blinkOff: false
    property var pendingAction
    function activate(i, action) {
        if (activating) return;
        activating = true;
        hover = i;
        pendingAction = action;
        blinkOff = true;
        blinkOffTimer.start();
    }
    Timer { id: blinkOffTimer; interval: Theme.menu.blinkOff; onTriggered: { root.blinkOff = false; blinkOnTimer.start(); } }
    Timer { id: blinkOnTimer; interval: Theme.menu.blinkOn; onTriggered: { root.activating = false; root.trigger(root.pendingAction); } }

    Glass {
        anchors.fill: parent
        radius: Theme.menu.radius
        sx: root.originX
        sy: root.originY
        tint: Theme.glass.tintStrong
        solidColor: Theme.reduceTransparency ? Theme.color.menuSolid : Theme.glass.solid
        materialize: root.fade
    }

    // selection: one inset pill that jumps to the hovered row
    property int hover: -1
    property real hoverY: 0
    function enterRow(i, y) {
        // another row: an open submenu goes in the same frame; a submenu row starts the open delay
        if (i !== subIndex) {
            closeSub();
            if (Menus.opens(shownItems[i])) {
                subPending = i;
                subTimer.restart();
            }
        }
        hover = i;
        hoverY = y;
    }
    // leaving a row and entering the next arrive in one pointer event: clear only if none took over
    // (a closing menu keeps its selection while it fades out)
    // The row of an open submenu stays highlighted (the pointer went into the submenu); leaving a row whose delay is
    // still running cancels it
    function leaveRow(i) {
        Qt.callLater(() => {
            if (!root.shown || root.activating || root.hover !== i || root.subIndex === i) return;
            root.hover = -1;
            if (root.subPending === i) root.closeSub();
        });
    }
    onShownItemsChanged: { hover = -1; closeSub(); }
    onVisibleChanged: if (!visible) closeSub()   // faded out with its submenu: nothing left open for the next time
    onShownChanged: {
        if (shown) {
            latchItems();
            hover = -1;
            closeSub();
            fadeOut.stop();
            fade = 1;
            if (selectFirst) selectRow(Menus.step(shownItems, -1, 1));
        } else {
            blinkOffTimer.stop();
            blinkOnTimer.stop();
            subTimer.stop();
            activating = false;
            blinkOff = false;
            if (!parentMenu || !parentMenu.shown) fadeOut.start();
            else {
                fadeOut.stop();
                fade = 0;
            }
        }
    }
    function selectRow(i) {
        if (i < 0) return;
        enterRow(i, Menus.rowTop(shownItems, i, Theme.menu.itemHeight, Theme.menu.separatorHeight));
        if (subPending === i) {   // a key highlights a submenu row without the hover delay: Right or Return opens it
            subTimer.stop();
            subPending = -1;
        }
    }

    // ---------- submenu ----------
    property int subIndex: -1          // row whose submenu is open
    property int subPending: -1        // row whose submenu opens when the hover delay ends
    property bool subKeyboard: false   // opened by a key: its first row is selected
    readonly property var submenu: subLoader.item ? subLoader.item.menu : null
    function openSub(i, keyboard) {
        subTimer.stop();
        subPending = -1;
        if (!Menus.opens(shownItems[i])) return;
        subKeyboard = !!keyboard;
        subIndex = i;
    }
    function closeSub() {
        subTimer.stop();
        subPending = -1;
        subIndex = -1;
    }
    Timer { id: subTimer; interval: Theme.menu.submenuDelay; onTriggered: root.openSub(root.subPending, false) }
    Loader {
        id: subLoader
        active: root.host !== null && root.visible && (root.subIndex >= 0 || root.subPending >= 0)
        source: "MenuSubmenu.qml"
        onLoaded: item.owner = root
    }

    // keys from the Overlay; true when used. The deepest open submenu that has a selection takes them first.
    function key(k) {
        const sub = subIndex >= 0 ? submenu : null;
        if (sub && sub.hover >= 0 && sub.key(k)) return true;
        if (sub && k === Qt.Key_Left) {
            closeSub();
            return true;
        }
        if (k === Qt.Key_Down || k === Qt.Key_Up) {
            selectRow(Menus.step(shownItems, hover, k === Qt.Key_Down ? 1 : -1));
            return true;
        }
        const it = hover >= 0 ? shownItems[hover] : null;
        if ((k === Qt.Key_Right || k === Qt.Key_Return || k === Qt.Key_Enter) && Menus.opens(it)) {
            openSub(hover, true);
            return true;
        }
        if ((k === Qt.Key_Return || k === Qt.Key_Enter) && Menus.selectable(it) && !it.submenu) {
            activate(hover, it.action);
            return true;
        }
        return false;
    }

    Rectangle {
        visible: root.hover >= 0 && !root.blinkOff
        x: Theme.menu.itemInset
        y: list.y + root.hoverY
        width: parent.width - Theme.menu.itemInset * 2
        height: Theme.menu.itemHeight
        radius: Theme.menu.itemRadius
        color: Theme.color.menuSelection
        opacity: root.fade
    }

    Column {
        id: list
        y: Theme.menu.padding
        width: parent.width
        opacity: root.fade

        Repeater {
            model: root.shownItems
            delegate: Item {
                id: row
                required property var modelData
                required property int index
                readonly property bool enabled: !modelData.sep && !modelData.disabled
                readonly property bool hovered: ma.containsMouse && enabled
                readonly property bool selected: root.hover === index && !root.blinkOff
                // label, check, icon and chevron share the row colour; shortcuts are tertiary unless selected
                readonly property color ink: !enabled ? Theme.color.tertiaryLabel : selected ? Theme.color.menuSelectionText : Theme.color.label
                onHoveredChanged: if (!root.activating) hovered ? root.enterRow(index, y) : root.leaveRow(index)
                width: list.width
                height: modelData.sep ? Theme.menu.separatorHeight : Theme.menu.itemHeight

                Rectangle {
                    visible: row.modelData.sep === true
                    x: Theme.menu.separatorInset
                    y: Math.floor((parent.height - 1) / 2)
                    width: parent.width - Theme.menu.separatorInset * 2
                    height: 1
                    color: Theme.color.menuSeparator
                }
                Symbol {   // checkmark, centred in the state column
                    visible: row.modelData.checked === true
                    anchors.verticalCenter: parent.verticalCenter
                    x: Theme.menu.checkX - width / 2
                    name: "checkmark"
                    size: 11
                    color: row.ink
                }
                Rectangle {   // mixed state: an 8.5 pt dash
                    visible: row.modelData.checked === "mixed"
                    anchors.verticalCenter: parent.verticalCenter
                    x: Theme.menu.checkX + 0.5 - width / 2
                    width: 8.5
                    height: 2
                    radius: 1
                    color: row.ink
                }
                Symbol {
                    visible: !!row.modelData.icon
                    anchors.verticalCenter: parent.verticalCenter
                    x: (root.hasState ? Theme.menu.stateIconX : Theme.menu.iconX) - width / 2
                    name: row.modelData.icon || ""
                    size: 13
                    color: row.ink
                }
                Text {
                    visible: !row.modelData.sep
                    anchors.verticalCenter: parent.verticalCenter
                    x: root.textXOf(row.modelData)
                    text: row.modelData.label || ""
                    font: Typography.menu
                    color: row.ink
                }
                Text {   // modifiers, right-aligned before the key column
                    visible: !row.modelData.sep && !!row.modelData.shortcut
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: key.left
                    anchors.rightMargin: Theme.menu.modifierGap
                    text: root.modsOf(row.modelData.shortcut)
                    font: Typography.menu
                    color: row.selected ? Theme.color.menuSelectionText : Theme.color.tertiaryLabel
                }
                Text {
                    id: key
                    visible: !row.modelData.sep && !!row.modelData.shortcut
                    anchors.verticalCenter: parent.verticalCenter
                    x: parent.width - Theme.menu.keyRight - width
                    width: root.keyWidth
                    horizontalAlignment: Text.AlignHCenter
                    text: root.keyOf(row.modelData.shortcut)
                    font: Typography.menu
                    color: row.selected ? Theme.color.menuSelectionText : Theme.color.tertiaryLabel
                }
                Symbol {
                    visible: row.modelData.submenu === true
                    anchors.verticalCenter: parent.verticalCenter
                    x: parent.width - Theme.menu.chevronX - width / 2
                    name: "chevron.right"
                    size: 11
                    color: row.ink
                }
                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: root.shown && !root.activating
                    onClicked: {
                        if (!row.enabled) return;
                        if (row.modelData.submenu) root.openSub(row.index, false);   // a click opens it at once
                        else root.activate(row.index, row.modelData.action);
                    }
                }
            }
        }
    }
}
