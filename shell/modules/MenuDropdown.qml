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
// (`checked`: true or "mixed"), 40 / 51 for rows with an `icon` (Q-menubar-15..17); key column = the widest key ink,
// right edge W - 18.5, each key centred by its ink; modifiers one glyph at a time 3.5 pt apart, ending 3 pt before
// it (Q-menubar-18). Width: AppKit's columns (Theme.menu.columnGap); no minimum width (Q-menubar-19).
// Motion: appears complete at once, a chosen row blinks once (off 4 frames, on 3; on 4 in a menu above the Dock) and
// then the menu runs the item and fades out on CA default over 236 ms, as on Esc (Q-menubar-23, -24; R16.1: an
// `afterFade` item, the Dock's Remove from Dock, runs when the fade has ended). The selection jumps from row to
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
    // the Dock menu's tail: the tip's x from this menu's left edge on its bottom edge (Overlay: the icon centre), < 0 none
    property real tailX: -1
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
    FrameAnim {
        id: fadeOut; target: root; property: "fade"; to: 0; duration: Theme.anim.menuFadeOut; curve: Theme.anim.menuFadeCurve
        lead: root.blinked ? 2 : 1      // after a chosen item's blink the Mac's first fading frame is 1.6-1.9 frames in
        onFinished: if (root.afterFade) afterFadePause.restart()
    }
    // the Dock's first moving frame is the 2nd after the menu's last fading one (R16.1: 4.867 and 4.900 s). A Timer:
    // the menu's window may be unmapped by now and draws no frames to count
    Timer { id: afterFadePause; interval: Theme.menu.afterFadePause; onTriggered: root.runAfterFade() }
    Component.onCompleted: { latchItems(); if (shown) fade = 1; }

    // ---------- columns ----------
    FontMetrics { id: metrics; font: Typography.menu }
    // glyph ink at 10x: FontMetrics rounds the tight box to whole pixels (⌘ 10 for 9.4 at 13 px)
    FontMetrics {
        id: ink10
        font: Qt.font({ family: Typography.menu.family, pixelSize: Typography.menu.pixelSize * 10,
                        weight: Typography.menu.weight, variableAxes: Typography.menu.variableAxes })
    }
    function inkOf(t) {
        const r = ink10.tightBoundingRect(t);
        return Qt.rect(r.x / 10, r.y / 10, r.width / 10, r.height / 10);
    }
    function keyOf(s) { const a = Array.from(s || ""); return a.length ? a[a.length - 1] : ""; }
    function modsOf(s) { return Array.from(s || "").slice(0, -1).join("").trim(); }
    // the modifier run, laid out by ink: [{t, x}] from the run's left ink edge, and its ink width ("fn" stays whole)
    function modsLayout(s) {
        const toks = (modsOf(s).match(/fn|\S/gu) || []);
        let cursor = 0;
        const items = [];
        for (const t of toks) {
            const r = inkOf(t);
            if (items.length) cursor += Theme.menu.modifierSpacing;
            items.push({ t: t, x: cursor - r.x });
            cursor += r.width;
        }
        return { items: items, width: cursor };
    }
    // the state column exists as soon as one row has a state; it is per menu, not per row
    readonly property bool hasState: shownItems.some(it => !it.sep && !!it.checked)
    function textXOf(it) {
        if (it.icon) return hasState ? Theme.menu.stateIconTextX : Theme.menu.iconTextX;
        return hasState ? Theme.menu.stateTextX : Theme.menu.textX;
    }
    // key column = the widest key ink of this menu, each key centred in it; modifier column = the widest run
    readonly property real keyWidth: {
        let w = 0;
        for (const it of shownItems)
            if (!it.sep && it.shortcut) w = Math.max(w, inkOf(keyOf(it.shortcut)).width);
        return w;
    }
    readonly property real modsWidth: {
        let w = 0;
        for (const it of shownItems)
            if (!it.sep && it.shortcut) w = Math.max(w, modsLayout(it.shortcut).width);
        return w;
    }
    readonly property real keyLeft: width - Theme.menu.keyRight - keyWidth
    // width: the label column (plain text x + widest label; the row icons do not widen it) + the shortcut columns,
    // and no row cut short: every row ends `end` before the edge, the submenu column's 48 for all rows of a menu
    // with a submenu row (Menus.rowEnd: AppKit reserves that column, desktop menu 198.5 pt on context-dark.png)
    readonly property real contentWidth: {
        const base = hasState ? Theme.menu.stateTextX : Theme.menu.textX;
        const end = Menus.rowEnd(shownItems, Theme.menu.trailing, Theme.menu.submenuTrailing);
        let w = 0, label = 0, keys = false;
        for (const it of shownItems) {
            if (it.sep) continue;
            const lw = metrics.advanceWidth(it.label || "");
            keys = keys || !!it.shortcut;
            label = Math.max(label, base + lw);
            w = Math.max(w, textXOf(it) + lw + end);
        }
        if (keys) w = Math.max(w, label + Theme.menu.columnGap + (modsWidth > 0 ? modsWidth + Theme.menu.modifierGap : 0)
                                  + keyWidth + Theme.menu.keyRight);
        return Math.ceil(w);
    }
    width: contentWidth
    height: list.height + Theme.menu.padding * 2

    signal triggered()

    // An item with `afterFade: true` runs when the menu has faded out, not when the fade starts: the Dock's Remove
    // from Dock by a real click (MAC-ANSWERS-16.md R16.1, sound/dock-remove-menu-real-click.mov: blink, the fade's 14
    // frames, and the Dock's first moving frame and the poof 22 frames after the highlight went off). Only that item is
    // filmed; every other item runs with the fade's start as before.
    // It waits in the top menu: a submenu is unloaded when its parent's fade ends, which may be a frame before its own.
    property var afterFade: null
    readonly property alias fading: fadeOut.running
    function runAfterFade() {
        afterFadePause.stop();
        const a = afterFade;
        afterFade = null;
        if (typeof a === "function") a();
    }
    function trigger(action, late) {
        if (late && typeof action === "function") {
            let top = root;
            while (top.parentMenu) top = top.parentMenu;
            top.afterFade = action;
            Panels.close();
            triggered();
            if (!top.fading) top.runAfterFade();    // nothing fades (closed another way): run it now
            return;
        }
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
            icon: arg === "Finder" ? "hyprk-finder" : ((Apps.entryFor(Apps.appIdOf(Apps.activeToplevel)) || {}).icon || ""),
            title: arg,
            message: "",
            buttons: [{ label: "OK", isDefault: true }],
        }); return;
        case "spotlight": if (arg) { SpotlightState.openIn(arg); return; } break;
        }
        switch (action) {
        case "empty-trash": Apps.confirmEmptyTrash(); break;
        case "emoji": Panels.toggle("emoji"); break;
        case "minimize": Hyprland.dispatch('hl.dsp.window.move({ workspace = "special:minimized" })'); break;
        case "center": Hyprland.dispatch("hl.dsp.window.center()"); break;
        case "cycle": Apps.cycleAppWindows(1); break;
        case "settings": Apps.openSettings(); break;
        // the Mac's About window has no "About This ..." text (it heads with the model name, then the OS line); the
        // alert heads with the OS name instead of an invented title (EXTRAS-AUDIT.md)
        case "about": Panels.showAlert({
            icon: Distro.aboutIcon,
            title: Distro.prettyName || "Linux",
            message: Distro.kernel ? "Linux " + Distro.kernel : "",
            buttons: [{ label: "More Info…", action: Apps.openSettings }, { label: "OK", isDefault: true }],
        }); break;
        case "forcequit": Hyprland.dispatch("hl.dsp.window.kill()"); break;
        case "close": Hyprland.dispatch("hl.dsp.window.close()"); break;
        case "hide-app": Apps.hideActiveApp(); break;
        case "hide-others": Apps.hideOthers(); break;
        case "show-all": Apps.showAll(); break;
        case "quit-app": Apps.quitActiveApp(); break;
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
    property bool pendingLate: false
    function activate(i, action) {
        if (activating) return;
        activating = true;
        hover = i;
        pendingAction = action;
        pendingLate = !!(shownItems[i] && shownItems[i].afterFade);
        blink.start();
        for (let m = parentMenu; m; m = m.parentMenu) m.keepPace();
    }
    // A submenu's item blinks: this menu's window draws frames for the length of the blink too. A window that has been
    // drawing shows a value two frames after its tick, one that starts from idle after one, so the parent's fade began
    // two frames before the submenu's (mcap, Dock menu > Options > Remove from Dock: parent from 123 ms, submenu from
    // 154); the Mac's two menus fade in the same frame (R16.1)
    function keepPace() { pace.duration = Theme.menu.blinkOff + blinkOnMs + 100; pace.restart(); }
    FrameAnim { id: pace; from: 0; to: 1 }
    // the highlight's second half: 3 frames in AppKit's menus (Q-menubar-24, R3.5), 4 in the Dock's own (R16.1: off
    // 4.533-4.600, on 4.600-4.667, one clip); a submenu blinks as its parent
    property int blinkOnMs: parentMenu ? parentMenu.blinkOnMs : Theme.menu.blinkOn
    // counted in frames of this window (HyprK FrameAnim used as a pause: 58 ms ends with the 4th frame, 42 ms with
    // the 3rd), so the blink is off 4 frames and on 3 whatever the click's phase (two Timers gave 3 to 5 frames per
    // half, and a SequentialAnimation on Qt's 16 ms timer 4 / 3 in 5 of 8 runs, mcap)
    QtObject {
        id: blink
        function start(): void { stop(); root.blinkOff = true; blinkOffWait.start(); }
        function stop(): void { blinkOffWait.stop(); blinkOnWait.stop(); }
    }
    FrameAnim { id: blinkOffWait; to: 1; from: 0; duration: Theme.menu.blinkOff; onFinished: { root.blinkOff = false; blinkOnWait.start(); } }
    FrameAnim { id: blinkOnWait; to: 1; from: 0; duration: root.blinkOnMs; onFinished: { root.activating = false; root.markBlinked(); root.trigger(root.pendingAction, root.pendingLate); } }
    // this fade follows a blink (this menu's or its submenu's): FrameAnim lead 2
    property bool blinked: false
    function markBlinked() { for (let m = root; m; m = m.parentMenu) m.blinked = true; }

    // a submenu is moved to its row when it opens (MenuSubmenu.frame follows its new size): the glass is placed from
    // its window position, so it is placed again in the same frame. Before, it followed on the next settle tick and the
    // first frame drew the labels at the new place with the glass still at the old one (trace: 354,34 then 610,674)
    onXChanged: menuGlass.remeasure()
    onYChanged: menuGlass.remeasure()
    Glass {
        id: menuGlass
        anchors.fill: parent
        radius: Theme.menu.radius
        sx: root.originX
        sy: root.originY
        tint: Theme.glass.tintStrong
        solidColor: Theme.reduceTransparency ? Theme.color.menuSolid : Theme.glass.solid
        materialize: root.fade
        tail: root.tailX
    }

    // selection: one inset pill that jumps to the hovered row
    property int hover: -1
    property real hoverY: 0
    function enterRow(i, y) {
        // heading for the open submenu: a row reached on the way waits for the next pointer move to tell (pointerMoved)
        if (predicting && i !== subIndex) { notePredictRow(i); return; }
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
        if (i === subIndex && submenu && submenu.shown && !activating) beginPredict(lastPt);
        if (predicting && i === predictRow) predictRow = -1;      // left the row it would take
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
            runAfterFade();     // reopened before the fade ended: the waiting item runs now
            blinked = false;
            fade = 1;
            if (selectFirst) selectRow(Menus.step(shownItems, -1, 1));
        } else {
            blink.stop();
            subTimer.stop();
            activating = false;
            blinkOff = false;
            if (!parentMenu || !parentMenu.shown) fadeOut.start();
            else {
                fadeOut.stop();
                fade = 0;
                runAfterFade();
            }
        }
    }
    function selectRow(i) {
        if (i < 0) return;
        endPredict(false);
        enterRow(i, Menus.rowTop(shownItems, i, Theme.menu.itemHeight, Theme.menu.separatorHeight));
        if (subPending === i) {   // a key highlights a submenu row without the hover delay: Right or Return opens it
            subTimer.stop();
            subPending = -1;
        }
    }

    // ---------- moving towards an open submenu ----------
    // AppKit's predictive tracking (-[NSMenuTrackingSession _trackMovedDraggedEventHandler:] 0x18a9af79c,
    // _beginPredictiveTrackingAtPoint: 0x18a9b0488): leaving the submenu's row starts it at that point; while the
    // pointer stays in the cone towards the submenu (Menus.towardSubmenu) the rows it crosses are not taken. It ends
    // when the pointer leaves the cone, 0.5 s after its first point in the cone, after a 0.4 s rest on one row (moves of
    // 3 pt or less) or 1.0 s after the row under it last changed; then the row under the pointer is taken. Where AppKit
    // starts it (leaving the row) is read from the begin point and the row test, not from its caller (not traced).
    property point lastPt: Qt.point(-1, -1)     // the pointer in window coordinates (the submenu shares them)
    property bool predicting: false
    property point apex: Qt.point(0, 0)
    property int predictRow: -1                // the row under the pointer while predicting (-1: none)
    readonly property var predictT: Menus.predictTimes()
    function beginPredict(p) {
        if (p.x < 0) return;
        predicting = true;
        apex = p;
        predictRow = -1;
        predictEnd.stop();
        predictRest.stop();
        predictRowTimer.restart();
    }
    function predictKeeps(p) {
        const m = submenu;
        if (!m || !m.shown) return false;
        if (!Menus.towardSubmenu(apex, p, { x: m.x, y: m.y, width: m.width, height: m.height })) return false;
        if (!predictEnd.running) predictEnd.start();
        return true;
    }
    function notePredictRow(i) {
        if (i === predictRow) return;
        predictRow = i;
        predictRowTimer.restart();
        predictRest.restart();
    }
    function endPredict(take) {
        if (!predicting) return;
        predicting = false;
        predictEnd.stop();
        predictRest.stop();
        predictRowTimer.stop();
        const i = predictRow;
        predictRow = -1;
        if (take && i >= 0 && i !== subIndex) enterRow(i, Menus.rowTop(shownItems, i, Theme.menu.itemHeight, Theme.menu.separatorHeight));
    }
    // a pointer move over the rows, in window coordinates
    function pointerMoved(p) {
        const moved = Math.abs(p.x - lastPt.x) + Math.abs(p.y - lastPt.y);
        lastPt = p;
        if (!predicting) return;
        if (!predictKeeps(p)) { endPredict(true); return; }
        if (moved > predictT.restPt) predictRest.restart();
    }
    // the pointer reached the submenu: it takes over
    onHoverChanged: if (hover >= 0 && parentMenu) parentMenu.endPredict(false)
    Timer { id: predictEnd; interval: root.predictT.ms; onTriggered: root.endPredict(true) }
    Timer { id: predictRest; interval: root.predictT.restMs; onTriggered: root.endPredict(true) }
    Timer { id: predictRowTimer; interval: root.predictT.rowMs; onTriggered: root.endPredict(true) }

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
        endPredict(false);
        subTimer.stop();
        subPending = -1;
        subIndex = -1;
    }
    // counted in frames of this window (HyprK FrameAnim as a pause, like the blink): on Qt's timer the submenu showed
    // 13 to 15 frames after its row (session 20, mcap), the Mac's is 13
    FrameAnim { id: subTimer; from: 0; to: 1; duration: Theme.menu.submenuDelay; onFinished: root.openSub(root.subPending, false) }
    Loader {
        id: subLoader
        active: root.host !== null && root.visible && (root.subIndex >= 0 || root.subPending >= 0)
        source: "MenuSubmenu.qml"
        onLoaded: item.owner = root
    }

    // Press, drag, release (Q-menubar-24, Overlay): the held pointer at (x, y) in this menu's window (the Overlay and the
    // submenu surfaces share one geometry). Over a row it selects the row as hover does (a submenu row starts its
    // delay); the deepest open submenu takes it first. True when the point is over this menu or a submenu.
    // the row under window point (x, y): its index (-1 off the rows) or null outside this menu
    function rowAt(x, y) {
        const p = mapFromItem(null, x, y);
        if (p.x < 0 || p.y < 0 || p.x >= width || p.y >= height) return null;
        return Menus.rowAt(shownItems, p.y - list.y, Theme.menu.itemHeight, Theme.menu.separatorHeight);
    }
    function pointAt(x, y) {
        if (!shown || activating) return false;
        if (submenu && submenu.shown && submenu.pointAt(x, y)) { endPredict(false); return true; }
        const i = rowAt(x, y);
        pointerMoved(Qt.point(x, y));
        if (i !== null && i !== hover && hover === subIndex && subIndex >= 0) beginPredict(lastPt);
        if (i !== null && Menus.selectable(shownItems[i])) {
            if (hover !== i) enterRow(i, Menus.rowTop(shownItems, i, Theme.menu.itemHeight, Theme.menu.separatorHeight));
            return true;
        }
        // off the enabled rows (a separator, a disabled row, outside): as leaving the row on hover
        if (hover >= 0) leaveRow(hover);
        return i !== null;
    }
    // the button went up at (x, y): true when over this menu or a submenu
    function releaseAt(x, y) {
        if (!shown || activating) return false;
        if (submenu && submenu.shown && submenu.releaseAt(x, y)) return true;
        const i = rowAt(x, y);
        if (i === null) return false;
        switch (Menus.releaseOn(shownItems, i)) {
        case "open": openSub(i, false); break;
        case "run": activate(i, shownItems[i].action); break;
        }
        return true;
    }

    // keys from the Overlay; true when used. The deepest open submenu that has a selection takes them first.
    // text: the typed character, for type-to-select
    function key(k, text) {
        const sub = subIndex >= 0 ? submenu : null;
        if (sub && sub.hover >= 0 && sub.key(k, text)) return true;
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
        const typed = Menus.typeSelect(shownItems, text);
        if (typed >= 0) {
            selectRow(typed);
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
                // label, check, icon and chevron share the row colour; shortcuts are tertiary unless selected.
                // Not vibrant on 27.2.1: the Mac's disabled text and shortcuts are a plain alpha over any backdrop
                // (black .26 / white .25, separators .10 / .14: the same alpha on every channel over white, grey and
                // Tahoe; reference/re/27.2.1/VIBRANCY-REA.md), so Tokens' alphas are the Mac's
                readonly property color ink: !enabled ? Theme.color.tertiaryLabel : selected ? Theme.color.menuSelectionText : Theme.color.label
                onHoveredChanged: if (!root.activating) hovered ? root.enterRow(index, y) : root.leaveRow(index)
                width: list.width
                height: modelData.sep ? Theme.menu.separatorHeight : Theme.menu.itemHeight

                Rectangle {
                    visible: row.modelData.sep === true
                    x: Theme.menu.separatorInset
                    y: Math.floor((parent.height - 1) / 2)
                    width: parent.width - Theme.menu.separatorInset * 2
                    height: Pixel.stroke(1, QsWindow.window ? QsWindow.window.devicePixelRatio : Screen.devicePixelRatio)   // exact, antialiased at a fractional scale like the Mac's downsample (HyprK pixel.js, SCALING-AUDIT R3.3)
                    antialiasing: Pixel.soft(QsWindow.window ? QsWindow.window.devicePixelRatio : Screen.devicePixelRatio)
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
                Rectangle {   // a minimised window in the Window menu's list (NSMenuItemDiamond, "◆" in the AX dump); its
                    // size was not measured on the Mac: a 5 pt square turned 45° (GUESS)
                    visible: row.modelData.checked === "diamond"
                    anchors.verticalCenter: parent.verticalCenter
                    x: Theme.menu.checkX - width / 2
                    width: 5
                    height: 5
                    rotation: 45
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
                // modifiers, glyph by glyph, the run's ink ending 3 pt before the key column
                readonly property var mods: !modelData.sep && modelData.shortcut ? root.modsLayout(modelData.shortcut) : null
                Repeater {
                    model: row.mods ? row.mods.items : []
                    Text {
                        required property var modelData
                        anchors.verticalCenter: parent.verticalCenter
                        x: root.keyLeft - Theme.menu.modifierGap - row.mods.width + modelData.x
                        text: modelData.t
                        font: Typography.menu
                        color: row.selected ? Theme.color.menuSelectionText : Theme.color.tertiaryLabel
                    }
                }
                Text {   // key, its ink centred in the key column
                    readonly property rect ink: root.inkOf(text)
                    visible: !row.modelData.sep && !!row.modelData.shortcut
                    anchors.verticalCenter: parent.verticalCenter
                    x: root.keyLeft + (root.keyWidth - ink.width) / 2 - ink.x
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
                    onPositionChanged: mouse => root.pointerMoved(mapToItem(null, mouse.x, mouse.y))
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
