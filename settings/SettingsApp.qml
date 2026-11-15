import QtQuick
import QtQuick.Effects
import "controls"
import "HyprK"
// not used here: Quickshell only registers the QML types of directories reached by static imports, and the Accessibility
// sub-panes (loaded by URL) are built from these
import "panes/accessibility/parts" as AxParts
import "Panes.js" as Panes
import "Parsers.js" as Parsers

// The whole System Settings UI. Hosts (main.qml for `qml`, shell.qml for
// Quickshell) give it a window and handle the window signals.
Item {
    // wallpaper mean for the chameleon tint (computed once per wallpaper): the part under the window where Hyprland
    // opens it, 740 x 625 centred on the output (settings/hyprland-rules.lua `center`). The Mac's follows a moved
    // window (MAC-ANSWERS C3.1); ours stays at the default place, and the size, not a resize, so no new mean per step
    WallpaperTint {
        path: AppState.desktopPicture(Theme.dark)
        screenSize: Qt.size(Screen.width, Screen.height)
        windowSize: Qt.size(Theme.window.width, Theme.window.height)
        onTintChanged: Theme.chameleon = tint
    }
    id: app
    // the account row, the Family row and the group break after them (27.2.1: the first pane row's top at y 188,
    // 90 below the list top; *-light.png have both rows blanked flat, so the Family row's look is not measured)
    readonly property int accountHeight: Theme.sidebar.accountHeight + Theme.sidebar.rowHeight + Theme.sidebar.groupGap
    property bool windowActive: Window.active || keepActive   // forced on for snapshots
    // the host keeps the key look (settings/shell.qml: Emoji & Symbols open over this window)
    property bool keepActive: false
    // A sheet is on the window (set by controls/SubSheet.qml). The window stays main, not key: its sidebar takes the
    // inactive look and, in dark, the toolbar strip its lighter tone, while the tiles keep their colours (live/
    // settings-r13 dest-controlCenter--clock-options-*.png against dest-controlCenter-*.png: the selected row goes from
    // accent to grey (171 light / (32,32,39) dark, veiled), labels read 155 / 60 = labelInactive under the veil, the
    // tiles keep .38 of their colour, the dark strip reads (27,27,32) over the pane's (24,26,29))
    property bool underSheet: false
    readonly property bool keyLook: windowActive && !underSheet
    // what a sheet draws without saturation under its veil: the pane and the toolbar, not the sidebar
    readonly property real sheetGreyFrom: Theme.sidebar.width
    Binding { target: Theme; property: "windowActive"; value: app.windowActive }
    Binding { target: Tokens; property: "windowActive"; value: app.windowActive }
    onSnapshotPathChanged: if (snapshotPath !== "") windowActive = true
    onWindowActiveChanged: if (windowActive) { AppState.autoSync(); AppState.refreshHardware(); }   // Appearance > Auto after a sleep; a dongle plugged in
    property string currentId: "appearance"
    // Non-empty: render once, save a PNG here and quit (reference comparisons).
    property string snapshotPath: ""
    property real snapshotScroll: 0   // the snapshot is taken at this scroll offset of the pane (HYPRK_SNAPSHOT_SCROLL / --scroll=)
    signal closeRequested()
    signal minimizeRequested()
    signal zoomRequested()
    signal moveRequested()

    readonly property var visiblePanes: Panes.visible(AppState.hasBattery, search.text, AppState.hw)
    readonly property var current: Panes.panes.find(p => p.id === currentId) || Panes.panes[0]
    // Navigation, as System Settings 27.2.1 (reference/re/MAC-ANSWERS-12.md R12.1, R12.2; re/27.2.1/SETTINGS-CLICK-AUDIT.md
    // "Sub-pane chrome"): a sub-pane replaces the pane's content and the toolbar title in one frame, forward and back
    // (a cut: no push, no fade, no title animation). The chrome is the pane's own: the same back/forward capsule
    // (AX 240,8 73 x 36) with Go Back enabled and Go Forward disabled until a Go Back, and one title, left-aligned
    // right after the capsule (AX 317,0 411 x 52), showing the sub-pane's name. No centred title, no back link in the
    // content, and the sidebar keeps the pane selected. One history holds panes and sub-panes alike (SettingsApp
    // SettingsNavigationHistoryManager: appendItemToHistory, canGoBack / canGoForward).
    // A pane with sub-panes has `page` (the sub-pane's id, "" = its root) and `pageTitle`; it pushes by setting `page`.
    property string subId: ""
    property var history: []          // { id, sub, y }: y = the root's scroll offset, kept for the way back
    property int historyPos: -1

    function sidebarRow(name) { return list.rowCentre(name); }
    function open(id, sub) {
        sub = sub || "";
        // the sidebar row of the pane that is open pops its stack (SwiftUI's list selection clears the stack path:
        // `_listSelectionAutomaticallyClearsNavigationStackPath` in System Settings.app)
        if (id === currentId && sub === subId) return;
        if (historyPos >= 0) history[historyPos].y = flick.contentY;
        history = history.slice(0, historyPos + 1).concat([{ id: id, sub: sub, y: 0 }]);
        historyPos = history.length - 1;
        show(history[historyPos]);
    }
    function go(delta) {
        const n = historyPos + delta;
        if (n < 0 || n >= history.length) return;
        history[historyPos].y = flick.contentY;
        historyPos = n;
        show(history[n]);
    }
    function show(entry) {
        // popping to the pane's root shows it where it was left (the root stays in the stack); anything else opens at its top
        const y = entry.id === currentId && entry.sub === "" ? entry.y : 0;
        subId = entry.sub;
        currentId = entry.id;
        applySub();
        scroller._silent = true; flick.contentY = 0; scroller._silent = false; scroller.hide();
        _restoreY = y;
        restoreScroll();
    }
    // the root's offset, set once the pane has its height again (its Column is laid out on polish)
    property real _restoreY: 0
    function restoreScroll() {
        if (_restoreY <= 0 || flick.contentHeight - flick.height < _restoreY) return;
        scroller._silent = true; flick.contentY = _restoreY; scroller._silent = false; scroller.hide();
        _restoreY = 0;
    }
    function applySub() {
        const it = pane.item;
        if (it && it.page !== undefined && it.page !== subId) it.page = subId;
    }
    // a sub-pane to open at start (snapshots, deep links: HYPRK_SETTINGS_SUB / --sub=), pushed over its pane's root
    property string startSub: ""
    Component.onCompleted: { history = [{ id: currentId, sub: "", y: 0 }]; historyPos = 0; if (startSub !== "") open(currentId, startSub); }
    // a pane's button into another pane or its sub-pane (Appearance: More in Accessibility Settings…)
    Connections { target: AppState; function onNavigate(id, sub) { app.open(id, sub); } }
    // View > Back ⌘[, Forward ⌘], Search ⌘F (System Settings.app SettingsAppCommands, shell/lib/menus.js settingsView)
    // the mouse's side buttons go back and forward (the user's choice, 2026-11-15; macOS does not map them)
    TapHandler {
        acceptedButtons: Qt.BackButton | Qt.ForwardButton
        onTapped: (point, button) => app.go(button === Qt.BackButton ? -1 : 1)
    }
    Shortcut { sequence: "Ctrl+["; onActivated: app.go(-1) }
    Shortcut { sequence: "Ctrl+]"; onActivated: app.go(1) }
    Shortcut { sequence: "Ctrl+F"; onActivated: search.focusField() }
    Timer {
        running: app.snapshotPath !== ""; interval: 4000
        onTriggered: {
            if (app.snapshotScroll > 0) { flick.contentY = Math.min(app.snapshotScroll, Math.max(0, flick.contentHeight - flick.height)); scroller.hide(); }
            Qt.callLater(() => app.grabToImage(r => { r.saveToFile(app.snapshotPath); Qt.quit(); }));
        }
    }

    // Battery and Energy swap: keep selection valid when hasBattery resolves.
    Connections {
        target: AppState
        function onHasBatteryChanged() {
            const from = AppState.hasBattery ? "energy" : "battery";
            const to = AppState.hasBattery ? "battery" : "energy";
            app.history = app.history.map(e => e.id === from ? { id: to, sub: e.sub, y: e.y } : e);
            if (app.currentId === from) app.currentId = to;
        }
    }

    // A pane whose hardware is absent is not listed (Panes.js `needs`): when the open one goes (the hardware answer
    // arrives, a dongle is pulled), the first pane of the list takes its place.
    Connections {
        target: AppState
        function onHwChanged() {
            const shown = Panes.visible(AppState.hasBattery, "", AppState.hw);
            const gone = id => Panes.panes.some(p => p.id === id && p.needs) && !shown.some(p => p.id === id);
            if (!shown.length || !gone(app.currentId) && !app.history.some(e => gone(e.id))) return;
            if (gone(app.currentId)) { app.subId = ""; app.currentId = shown[0].id; }
            app.history = [{ id: app.currentId, sub: app.subId, y: 0 }];
            app.historyPos = 0;
        }
    }

    Rectangle { // content background; the sidebar area stays translucent for blur
        x: Theme.sidebar.width
        width: parent.width - x
        height: parent.height
        topRightRadius: Theme.window.radius
        bottomRightRadius: Theme.window.radius
        color: Theme.windowBg
    }

    // ---------- sidebar (flush left, translucent unless Reduce transparency) ----------
    Rectangle {
        id: sidebar
        width: Theme.sidebar.width
        height: parent.height
        topLeftRadius: Theme.window.radius
        bottomLeftRadius: Theme.window.radius
        color: Theme.sidebar.fill
        Rectangle { anchors.right: parent.right; width: Theme.sidebar.strokeWidth; height: parent.height; color: Theme.sidebar.stroke }

        TitleArea { // dragging the empty top of the sidebar moves the window, a double-click zooms it
            width: parent.width; height: Theme.window.toolbarHeight
        }
        TrafficLights {
            id: lights
            x: Theme.lights.left
            y: (Theme.window.toolbarHeight - Tokens.lights.size) / 2
            // the liquidglass plugin learns where they are, so a press on them in an inactive window does not activate
            // it (R6.4; plugin/src/ClientLights.hpp, as Finder's Main.qml). Again whenever the window turns inactive: a
            // plugin reload forgets it. Hyprland only (Backend.compositorBlur); hyprctl refuses it without the plugin
            function report() {
                if (!Backend.compositorBlur || app.snapshotPath !== "") return;
                const p = lights.mapToItem(null, 0, 0);
                Backend.run(["hyprctl", "liquidglass", "lights", "org.hyprk.Settings", String(p.x), String(p.y), String(lights.width), String(lights.height)], null);
            }
            Component.onCompleted: Qt.callLater(report)
            Connections { target: app; function onWindowActiveChanged() { if (!app.windowActive) lights.report(); } }
            active: app.windowActive
            onCloseClicked: app.closeRequested()
            onMinimizeClicked: app.minimizeRequested()
            onZoomClicked: app.zoomRequested()
        }
        // The list scrolls up behind the search field (R3.9, sidebar-scrolled-{1,2,5}-*.png, sidebar-scroll-*.mov; the
        // HIG's scroll edge effect): the field floats over the rows, which pass under it and are gone above its top
        // edge (nothing of them shows in the traffic-light strip in any frame). At rest the first row is where it was
        // (y 98, the AX scroll area's top): the list starts at the field's top with a 37 pt content inset. Under the
        // field a row shows only as a faint blur through its glass: the dark Wi-Fi icon darkens the field by about 20
        // of 214 levels (frame 0.6 s / 1.0 s of the clip, 207-210 against 228); here the rows under the field are cut
        // out of the list and drawn blurred and faint in the field (searchGlass), under the field's own fill.
        ListView {
            id: list
            objectName: "sidebarList"
            anchors.top: parent.top; anchors.topMargin: Theme.sidebar.searchTop
            anchors.bottom: parent.bottom; anchors.bottomMargin: 8
            x: Theme.sidebar.rowMargin; width: parent.width - 2 * Theme.sidebar.rowMargin
            topMargin: Theme.sidebar.listTop - Theme.sidebar.searchTop
            readonly property bool underField: contentY > originY - topMargin + 0.5
            // the field's capsule cut out of the rows while any row can be under it
            layer.enabled: underField
            layer.effect: MultiEffect {
                maskEnabled: true; maskInverted: true; maskSource: fieldHole
                maskThresholdMin: 0.5; maskSpreadAtMin: 0.2   // a wide spread leaks the masked-off side
            }
            clip: true
            boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
            acceptedButtons: Qt.NoButton                  // no mouse-drag scrolling (AppKit)
            RubberBand { flickable: list }
            model: app.visiblePanes
            // Keep the selected pane visible (deep links, back/forward). Rows have fixed
            // heights, so the row's y is computed instead of waiting for delegates; the
            // list only scrolls when the row is out of view and normally stays at the top.
            function reveal() {
                const panes = app.visiblePanes;
                const i = panes.findIndex(p => p.id === app.currentId);
                if (i < 0) return;
                // content coordinates: rows start at 0, the header (account) sits above at originY
                let y = 0;
                for (let k = 0; k <= i; k++)
                    y += Theme.sidebar.rowHeight + (k > 0 && panes[k - 1].group !== panes[k].group ? Theme.sidebar.groupGap : 0);
                // a row is in view below the field: from the list's 37 pt inset (where the rows rest) to its bottom
                if (y - Theme.sidebar.rowHeight < contentY + topMargin) contentY = Math.max(originY - topMargin, y - Theme.sidebar.rowHeight - topMargin);
                else if (y > contentY + height) positionViewAtIndex(i, ListView.Contain);
            }
            // where a pane's row is, by title or id: "x y" of its centre in the window (pt) after scrolling it into
            // view, "" when the sidebar does not list it (a live check clicks rows by name: the rows above depend on
            // the machine, e.g. no Wi-Fi row without a Wi-Fi device; scripts/motion-capture/sheet-depth.py)
            function rowCentre(name) {
                const i = app.visiblePanes.findIndex(p => p.title === name || p.id === name);
                if (i < 0) return "";
                positionViewAtIndex(i, ListView.Contain);
                const d = itemAtIndex(i);
                if (!d) return "";
                const p = d.mapToItem(null, d.width / 2, d.height - Theme.sidebar.rowHeight / 2);
                return Math.round(p.x) + " " + Math.round(p.y);
            }
            // once laid out: a 0-height list would scroll on its own
            property bool _revealed: false
            onHeightChanged: if (!_revealed && height > 0) { _revealed = true; reveal(); }
            Connections { target: app; function onCurrentIdChanged() { list.reveal(); } }
            header: search.text === "" ? accountCard : null
            delegate: Item {
                id: d
                required property var modelData
                required property int index
                readonly property bool newGroup: index > 0 && app.visiblePanes[index - 1].group !== modelData.group
                readonly property bool selected: app.currentId === modelData.id
                // the accent pill only while the window is key and the list (not the search field) has focus
                readonly property bool emphasized: app.keyLook && !search.inputFocus
                width: list.width
                height: Theme.sidebar.rowHeight + (newGroup ? Theme.sidebar.groupGap : 0)
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width; height: Theme.sidebar.rowHeight
                    radius: Theme.sidebar.rowRadius
                    color: !d.selected ? "transparent" : d.emphasized ? Theme.sidebar.selection : Theme.sidebar.selectionInactive
                    PaneIcon {
                        id: ic
                        size: Theme.sidebar.iconSize
                        x: Theme.sidebar.iconCenter - width / 2; anchors.verticalCenter: parent.verticalCenter
                        iconId: d.modelData.id
                        tint: Theme.tile[d.modelData.tint]
                    }
                    MacText {
                        x: Theme.sidebar.labelLeft; width: parent.width - x - 6
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                        text: d.modelData.title
                        size: Theme.sidebar.fontSize
                        weight: d.selected ? Typography.semibold : Typography.regular
                        color: d.selected && d.emphasized ? Theme.sidebar.selectionText
                             : app.keyLook ? Theme.label : Theme.sidebar.labelInactive
                    }
                    MouseArea { anchors.fill: parent; onClicked: app.open(d.modelData.id) }
                }
            }
        }
        Item {   // the mask: the field's capsule in the list's coordinates
            id: fieldHole
            visible: false; layer.enabled: true
            width: list.width; height: list.height
            Rectangle { x: search.x - list.x; y: search.y - list.y; width: search.width; height: search.height; radius: search.radius }
        }
        Item {
            id: searchGlass
            x: search.x; y: search.y; width: search.width; height: search.height
            visible: list.underField && !Theme.reduceTransparency
            readonly property real pad: 16
            ShaderEffectSource {   // the rows behind the field (list content coordinates), with a margin for the blur
                id: behind
                visible: false
                sourceItem: list.contentItem
                sourceRect: Qt.rect(search.x - list.x + list.contentX - searchGlass.pad, search.y - list.y + list.contentY - searchGlass.pad,
                                    search.width + 2 * searchGlass.pad, search.height + 2 * searchGlass.pad)
                width: sourceRect.width; height: sourceRect.height
            }
            Item {
                id: glassMask
                visible: false; layer.enabled: true
                width: behind.width; height: behind.height
                Rectangle { x: searchGlass.pad; y: searchGlass.pad; width: search.width; height: search.height; radius: search.radius }
            }
            MultiEffect {
                x: -searchGlass.pad; y: -searchGlass.pad; width: behind.width; height: behind.height
                source: behind
                autoPaddingEnabled: false   // the margin is in `behind` already; padding would shift the mask
                blurEnabled: true; blurMax: 32; blur: 0.5
                maskEnabled: true; maskSource: glassMask; maskThresholdMin: 0.5; maskSpreadAtMin: 0.2
                opacity: 0.2
            }
        }
        SearchField {
            id: search
            x: Theme.sidebar.rowMargin; width: parent.width - 2 * Theme.sidebar.rowMargin
            y: Theme.sidebar.searchTop
        }
    }

    Component {
        id: accountCard
        Item {
            width: list.width; height: app.accountHeight
            Item { // Family: a row like a pane row (people glyph in a grey circle, label); no pane behind it here
                y: Theme.sidebar.accountHeight
                width: parent.width; height: Theme.sidebar.rowHeight
                Rectangle {
                    width: Theme.sidebar.iconSize; height: width; radius: width / 2
                    x: Theme.sidebar.iconCenter - width / 2; anchors.verticalCenter: parent.verticalCenter
                    color: Theme.tile.gray
                    // person.2.fill; the row is blanked on every Mac shot, so the picture and its size are not measured
                    // (FamilySettings.appex also holds a 24 pt bitmap, family_icon-macos-24)
                    SfSymbol { anchors.centerIn: parent; name: "person.2.fill"; pointSize: parent.width * 0.42; color: "white" }
                }
                MacText {
                    x: Theme.sidebar.labelLeft; anchors.verticalCenter: parent.verticalCenter
                    text: "Family"
                    size: Theme.sidebar.fontSize
                    color: app.keyLook ? Theme.label : Theme.sidebar.labelInactive
                }
            }
            Rectangle {
                id: avatar
                x: 6; y: (Theme.sidebar.accountHeight - height) / 2   // the account button starts at window x 16
                width: Theme.sidebar.accountAvatar; height: width; radius: width / 2
                gradient: Gradient {
                    GradientStop { position: 0; color: "#A8A8AE" }
                    GradientStop { position: 1; color: "#7C7C82" }
                }
                // person.fill; the Mac's own avatar is blanked on every shot, so its glyph and size are not measured
                SfSymbol { anchors.centerIn: parent; name: "person.fill"; pointSize: parent.width * 0.55; color: "white" }
            }
            Column {
                anchors.left: avatar.right; anchors.leftMargin: 9; anchors.verticalCenter: avatar.verticalCenter
                spacing: 1
                MacText {
                    text: AppState.userName
                    weight: Typography.semibold
                    color: Theme.label
                }
                Text {   // System Settings.app Localizable.loctable "Apple Account, iCloud+, and more" (mac rule)
                    text: "Apple Account"
                    font: Typography.subheadline
                    color: Theme.secondaryLabel
                }
            }
        }
    }

    // ---------- content ----------
    // The scroll view fills the column under the toolbar too (PC #60 section 5): the document starts at the toolbar's
    // bottom (offset 0: first card 12 below it) and scrolls under the toolbar strip, which fades it. Appearance:
    // 573 pt visible, document 1036.5, max offset 463.5.
    Flickable {
        id: flick
        anchors.left: sidebar.right; anchors.right: parent.right
        anchors.top: parent.top; anchors.bottom: parent.bottom
        clip: true
        // the scroll edge (pocket and hairline) shows once scrolled, except over a pinned pane header
        readonly property bool edgeShown: contentY > 0 && !(pane.item && pane.item.pinnedHeader === true)
        contentHeight: pane.y + pane.height + Theme.content.padding   // bottom margin 20
        onContentHeightChanged: app.restoreScroll()
        boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
        // AppKit scroll views do not scroll by a mouse drag (wheel, trackpad and the scroller only); Qt 6.9+
        acceptedButtons: Qt.NoButton
        RubberBand { flickable: flick }
        Loader {
            id: pane
            x: Math.max(Theme.content.padding, (flick.width - width) / 2)
            y: Theme.window.toolbarHeight + Theme.content.top
            width: Math.min(Theme.content.maxWidth, flick.width - 2 * Theme.content.padding)
            source: "panes/" + app.current.file + ".qml"
            onSourceChanged: { scroller._silent = true; flick.contentY = 0; scroller._silent = false; scroller.hide(); }
            onLoaded: app.applySub()
            // a row of the pane pushed a sub-pane (or the pane opened one itself: HYPRK_A11Y_PAGE)
            Connections {
                target: pane.item
                ignoreUnknownSignals: true
                function onPageChanged() { app.open(app.currentId, pane.item.page); }
            }
        }
    }
    ScrollEdge { // the toolbar strip over scrolled content: AppKit's scroll pocket (HyprK ScrollEdge)
        active: flick.edgeShown
        source: flick
        x: flick.x; width: flick.width; height: Theme.window.toolbarHeight
        dark: Theme.dark
        windowColor: Theme.windowBg
        cornerRadius: Theme.window.radius
    }
    OverlayScrollbar {
        id: scroller
        objectName: "paneScroller"
        flickable: flick
        x: parent.width - Tokens.scroller.inset - width
        y: Theme.window.toolbarHeight + Tokens.scroller.inset
        height: parent.height - y - Tokens.scroller.inset
    }

    // The title bar and toolbar's empty space: a press moves the window (xdg move), a second press within the Mac's 0.5 s
    // zooms it (Parsers.isDoubleClick; MouseArea.onDoubleClicked used Qt's 400 ms and never fired after the move grab)
    component TitleArea: MouseArea {
        property var last: null
        onPressed: mouse => {
            const p = mapToItem(null, mouse.x, mouse.y), now = { t: Date.now(), x: p.x, y: p.y };
            if (Parsers.isDoubleClick(last, now)) { last = null; app.zoomRequested(); return; }
            last = now;
            app.moveRequested();
        }
    }

    // ---------- toolbar ----------
    // no fill and no glass: only the back/forward capsule is drawn (macOS 27.2.1, MAC-ANSWERS.md Q9.2)
    Item {
        id: toolbar
        anchors.left: sidebar.right; anchors.right: parent.right
        height: Theme.window.toolbarHeight
        TitleArea { anchors.fill: parent }
        ToolbarPlatter { // back / forward share one 74 x 36 capsule with a 1 x 20 divider (27.2.1)
            id: nav
            relief: true   // the platter's own shading and edge (Tokens.toolbar.relief*, settings/appearance-*.png)
            x: 7.5; anchors.verticalCenter: parent.verticalCenter; anchors.alignWhenCentered: false   // settings-toolbar-dark.png: sidebar line px 463, capsule 479..626
            width: Tokens.toolbar.navWidth; height: Tokens.toolbar.reliefHeight   // light: 37 pt, edge rows 15 / 88 px
            // the divider hides while either half is hovered or pressed (toolbar-backforward-rest-hover-press-dark.png)
            Rectangle { anchors.centerIn: parent; width: 1; height: Tokens.toolbar.dividerHeight; color: Tokens.toolbar.separator
                        visible: !navLight.hovered && !navLight.pressed }
            Row {
                anchors.fill: parent
                Repeater {
                    // SF chevron.backward / chevron.forward from their real outlines, regular, 16.5 pt: ink 16 x 28 px, tip
                    // rows 4-5 px, arm 5 px on settings-toolbar-light.png, and here (medium: 29 px tall, 5-6; the Material
                    // font's chevron before: tip 8 px, judge #4)
                    model: [{ g: "chevron.backward", d: -1 }, { g: "chevron.forward", d: 1 }]
                    Item {
                        required property var modelData
                        readonly property bool can: modelData.d < 0 ? app.historyPos > 0 : app.historyPos < app.history.length - 1
                        width: nav.width / 2; height: nav.height
                        SfSymbol {
                            anchors.centerIn: parent
                            name: modelData.g; pointSize: 16.5
                            color: parent.can ? Theme.label : Theme.tertiaryLabel
                        }
                        MouseArea { anchors.fill: parent; onClicked: app.go(modelData.d) }
                    }
                }
            }
        }
        ToolbarHighlight {   // hover and press light of back / forward (an AppKit platter: one glass, lifted and lit whole)
            id: navLight
            x: nav.x; y: nav.y; width: nav.width; height: nav.height
            source: nav
            backdrop: Theme.windowBg
            centres: [nav.width / 4, nav.width * 3 / 4]
            disabled: [app.historyPos <= 0, app.historyPos >= app.history.length - 1]   // no light on a disabled half (Q-finder-10)
        }
        MacText {
            objectName: "toolbarTitle"
            // R12.1: one left-aligned title right after the capsule, for a pane and a pushed sub-pane alike (AX 317,0
            // 411 x 52; its ink starts 12 pt after the capsule on accessibility-00-light.png and every acc-*-00-light.png)
            anchors.left: nav.right; anchors.leftMargin: 11.5; anchors.verticalCenter: parent.verticalCenter
            // a pushed sub-pane: its own title (the extension's navigation title, `navigationTitleOverride`)
            text: pane.item && pane.item.pageTitle ? pane.item.pageTitle : app.current.title
            // a pane with a full hero card (General) has no toolbar title until the hero's own title has gone under the
            // toolbar (general-00-light.png: none at offset 0; general-01/02: "General"); the pane gives the y of its
            // hero title's bottom (`toolbarTitleAfter`)
            visible: app.subId !== "" || !(pane.item && pane.item.toolbarTitleAfter > 0)
                     || flick.contentY + Theme.window.toolbarHeight >= pane.y + pane.item.toolbarTitleAfter
            font: Typography.toolbarTitle   // 15 Semibold, measured on 27.2.1 (was 16 Bold)
            color: Theme.toolbarTitle
        }
        HoverHandler { id: toolbarHover }
        // dark: the strip and the capsule lighten while the pointer is in the toolbar (Theme.toolbarHoverWash). The strip
        // of a window that is not key has the same tone: (37,38,39) over the pane's (29,30,32) (settings/
        // desktop-dock-inactive-dark-iconDark.png, 31 while key), and under a sheet (27,27,32) over (24,26,29), the same
        // 8 levels through the veil
        Rectangle {
            anchors.fill: parent
            visible: (toolbarHover.hovered || !app.keyLook) && Theme.dark
            color: Theme.toolbarHoverWash
        }
    }

    Rectangle { // scroll edge: a 0.5 pt hairline at y 52 from the first scrolled frame, no fade-in (Q-settings-04);
        // none over a pinned pane header (Wallpaper: its own divider is the edge)
        visible: flick.edgeShown
        x: flick.x; width: flick.width; y: toolbar.height
        height: Pixel.stroke(0.5, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio))   // exact, antialiased at a fractional scale like the Mac's downsample (HyprK pixel.js)
        antialiasing: Pixel.soft(Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio))
        color: Theme.scrollEdge
    }

    // inner white rim over everything; the compositor draws the outer black one (Tokens.frame)
    Rectangle {
        anchors.fill: parent
        radius: Theme.window.radius
        color: "transparent"
        border.width: Tokens.frame.rimWidth
        border.color: Tokens.frame.rim(app.windowActive)
    }
}
