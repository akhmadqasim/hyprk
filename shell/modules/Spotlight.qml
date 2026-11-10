import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.services
import qs.HyprK
import "../lib/search.js" as Search
import "../lib/spotlight.js" as SL
import "../lib/spring.js" as SpringLib
import "../lib/appsgrid.js" as AG
import "spotlight"

// Spotlight (Super+Space), macOS 27.2.1 (MAC-ANSWERS.md Q-panels-14..-26): two glass shapes, a 520 x 87 search
// capsule at 22.7 % of the screen height and, 10 below it, one panel:
// - results (520 wide, r 37, rows of 62, at most 410 tall) once text is typed;
// - the mode list (520 x 214) that unfolds while the field is empty and the pointer has entered the bar;
// - a mode (Cmd+1..4 or the list): Applications = the Apps panel (844 x 520, AppsPanel.qml, also the Dock's
//   "Apps"), Files / Actions / Clipboard = a 520 x 490 list (ModeView.qml).
// No magnifier: the left of the field is empty, or holds the mode glyph; the right holds a mic (no action: hyprk
// has no dictation), the top hit's icon once text is typed, or "..." in a mode. Esc: the first returns to the
// plain "Search or Ask" bar (leaves the mode, clears the query), the second closes.
ShellWindow {
    id: sp

    required property var modelData
    screen: modelData

    readonly property bool shown: Panels.open === "spotlight"
    // MAC-ANSWERS.md "REA 27.2.1" section 4 (SpotlightUIInternal, CASpringAnimation(perceptualDuration:bounce:)),
    // each on one exact spring (components/SpringCurve.qml):
    // - open (FUN_2adea2ff0, FUN_2ade9ef14 flag 0): transform.scale.x 1.12 -> 1 on Spring(0.28, 0.41),
    //   scale.y 0.95 -> 1 on Spring(0.28, 0.32), window alpha 0 -> 1 on Spring(0.28, 0.41);
    // - close (FUN_2adea36c8, FUN_2ade9ef14 flag 1): scale.x 1 -> 1.12 and scale.y 1 -> 0.95 on Spring(0.45, 0.05),
    //   alpha 1 -> 0 on Spring(0.28, 0.41). The window is unloaded when the alpha first reaches 0 (0.12 s); it
    //   would only swing back to 0.01 after that.
    // Not done: the open's contentBlurRadius 25 -> 0 on Spring(0.51, 0.05) (no cheap compositor blur of a
    // layer's content; an offscreen QML blur would also miss the plugin glass), and transform.translation.y
    // (its start value is not read). The scale anchor is not read: the search field's centre.
    // The window is created on open: the springs start on its first frame (alpha 0), else creating the surface
    // eats their first frames. Reduce motion: no scale (Theme.travel), the fade stays.
    property real scaleX: 1.12
    property real scaleY: 0.95
    property real alpha: 0
    readonly property var springOpenX: SpringLib.fromBounce(0.28, 0.41)
    readonly property var springOpenY: SpringLib.fromBounce(0.28, 0.32)
    readonly property var springClose: SpringLib.fromBounce(0.45, 0.05)
    readonly property var springAlpha: SpringLib.fromBounce(0.28, 0.41)
    SpringCurve { id: animX; target: sp; property: "scaleX" }
    SpringCurve { id: animY; target: sp; property: "scaleY" }
    SpringCurve {
        id: animAlpha
        target: sp
        property: "alpha"
        spring: sp.springAlpha
        onFinished: if (!sp.shown) sp.gone = true
    }
    property bool gone: false
    function animate(open) {
        gone = false;
        animX.spring = open ? springOpenX : springClose;
        animY.spring = open ? springOpenY : springClose;
        animAlpha.cutAt = open ? 0 : SpringLib.firstCrossing(springAlpha, 0, 0.001);
        animX.go(open ? 1 : 1.12);
        animY.go(open ? 1 : 0.95);
        animAlpha.go(open ? 1 : 0);
        settleGlass(Math.max(animX.duration, animY.duration, animAlpha.duration) + 50);   // the glass follows the scale
    }
    property bool firstFrame: true
    Connections {
        target: sp.firstFrame ? sp.contentItem.Window.window : null
        function onFrameSwapped() { sp.firstFrame = false; if (sp.shown) sp.animate(true); }
    }
    visible: shown || !gone
    lingerAs: "spotlight"
    lingering: !shown && !gone
    glassOpacity: alpha
    // while dematerializing it takes no input, so it never eats the next click
    acceptsInput: shown
    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-spotlight"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property string query: ""
    property string category: ""            // Applications: the chip picked, shown as a token in the field
    property int selected: 0
    readonly property var calcValue: Search.calc(query)
    // browse mode ("" = all results), shared with SpotlightState so global shortcuts and the Dock can open one
    readonly property string mode: SpotlightState.mode
    readonly property var modeInfo: SL.modeInfo(mode)
    readonly property var apps: shown && mode === "" && query.trim() !== "" ? Search.rank(Apps.visibleEntries, query, Theme.spotlight.maxApps) : []
    readonly property var actions: mode === "" && query.trim() !== "" ? SpotlightActions.rank(query, 2) : []
    readonly property bool quickKeyHit: SL.quickKeyAction(SpotlightState.quickKeys, query) !== ""
    readonly property var files: mode === "" ? FileSearch.results.slice(0, 3) : []
    Binding { target: FileSearch; property: "query"; value: sp.mode === "" || sp.mode === "files" ? sp.query : "" }
    // rows: {kind: "calc"|"app"|"action"|"file", ...}; 27.2.1 has no section headers (Q-panels-20)
    readonly property var rows: {
        if (mode !== "" || query.trim() === "") return [];
        const r = [];
        const addActions = () => { for (const a of actions) r.push({ kind: "action", title: a.title, subtitle: a.subtitle || "", action: a }); };
        if (quickKeyHit) addActions();      // a typed quick key puts its action on top
        if (calcValue !== null) r.push({ kind: "calc", title: Search.formatNumber(calcValue), subtitle: query.trim() + " =" });
        for (const a of apps) r.push({ kind: "app", title: a.name, subtitle: "Application", entry: a, icon: a.icon });
        if (!quickKeyHit) addActions();
        for (const f of files) r.push({ kind: "file", title: f.name, subtitle: f.dir, file: f });
        return r;
    }

    // the mode list: once the pointer really moved into the bar while the field is empty (components/
    // PointerGate.qml: the layer maps under a resting pointer); it stays after the pointer leaves
    PointerGate { id: hoverGate }
    property bool modeListArmed: false
    readonly property string below: mode === "apps" ? "apps" : mode !== "" ? "list"
        : rows.length > 0 ? "results" : modeListArmed && query === "" ? "modes" : ""
    // unfolds downward in about 0.18 s, ease-in-out (Q-panels-26); gone at once when text is typed
    property real unfold: below === "modes" ? 1 : 0
    Behavior on unfold {
        enabled: sp.below === "modes" && !A11y.reduceMotion
        NumberAnimation { duration: Theme.spotlight.unfoldMs; easing.type: Easing.InOutSine }
    }
    onBelowChanged: settleGlass(Theme.spotlight.unfoldMs + 50)

    function setMode(m) {
        SpotlightState.mode = m;
        category = "";
        input.text = "";
        input.forceActiveFocus();
    }
    // query field keys without a dedicated handler: Super/Ctrl/Alt+1..4 pick a mode; Left/Right move in the Apps
    // grid (they do not cycle modes on the Mac); Backspace on an empty field drops the category token
    function handleKey(event) {
        const m = SL.modeForKey(event.key, event.modifiers & Qt.MetaModifier, event.modifiers & Qt.ControlModifier, event.modifiers & Qt.AltModifier);
        if (m !== "") { setMode(m === mode ? "" : m); event.accepted = true; return; }
        if (event.key === Qt.Key_Backspace && input.text === "" && category !== "") { category = ""; event.accepted = true; return; }
        const dir = event.key === Qt.Key_Right ? 1 : event.key === Qt.Key_Left ? -1 : 0;
        if (dir !== 0 && mode === "apps" && input.text === "") { modePanel.item.move(dir, 0); event.accepted = true; }
    }
    function moveSel(dir) {
        if (mode === "apps") modePanel.item.move(0, dir);
        else if (mode !== "") modePanel.item.move(dir);
        else step(dir);
    }
    function acceptSel() { if (mode !== "") modePanel.item.accept(); else accept(); }
    function escapeKey() {
        if (mode === "" && input.text === "" && category === "") Panels.close();
        else setMode("");
    }
    function step(dir) { if (rows.length > 0) selected = (selected + dir + rows.length) % rows.length; }

    // the window exists only while open (shell.qml LazyLoader); a query handed over
    // by IPC is taken on creation and whenever a new one arrives
    function takeQuery() {
        if (Panels.spotlightQuery === "") return;
        input.text = Panels.spotlightQuery;
        Panels.spotlightQuery = "";
    }
    function present() { if (!firstFrame) animate(true); takeQuery(); input.forceActiveFocus(); FileSearch.loadRecents(); }
    Component.onCompleted: present()
    onShownChanged: shown ? present() : animate(false)       // present(): also reopened while still fading out
    onModeChanged: category = ""
    Connections {
        target: Panels
        function onSpotlightQueryChanged() { sp.takeQuery(); }
    }
    onQueryChanged: selected = 0
    // rows fill in after the query changed (streamed files, late actions): the selection
    // follows its row by key, so Return never opens a row that slid under the index
    function rowKey(r) {
        if (!r) return "";
        return r.kind + ":" + (r.entry ? r.entry.id : r.action ? r.action.id : r.file ? r.file.path : r.title);
    }
    property string selectedKey: ""
    onSelectedChanged: selectedKey = rowKey(rows[selected])
    onRowsChanged: {
        const i = selectedKey ? rows.findIndex(r => rowKey(r) === selectedKey) : -1;
        selected = Math.max(0, i);
    }

    function accept() {
        const row = rows[selected];
        if (!row) return;
        if (row.kind === "action") { SpotlightActions.run(row.action); return; }
        if (row.kind === "app") Apps.launch(row.entry, row.entry.id);
        else if (row.kind === "file") FileSearch.open(row.file);
        else if (row.kind === "calc") Quickshell.clipboardText = row.title;
        Panels.close();
    }

    MouseArea {
        anchors.fill: parent
        onPressed: Panels.close()
    }

    // bar and panel share the open/close scale, around the field's centre
    Item {
        id: stage
        anchors.fill: parent
        opacity: sp.alpha
        readonly property real barX: Math.round((width - Theme.spotlight.barW) / 2)
        readonly property real barY: Math.round(height * Theme.spotlight.barTop)
        transform: Scale {
            origin.x: stage.width / 2
            origin.y: stage.barY + Theme.spotlight.barH / 2
            xScale: 1 + Theme.travel(sp.scaleX - 1)
            yScale: 1 + Theme.travel(sp.scaleY - 1)
        }

        // ---------- the search capsule ----------
        Item {
            id: bar
            x: stage.barX
            y: stage.barY
            width: Theme.spotlight.barW
            height: Theme.spotlight.barH
            Glass {
                anchors.fill: parent
                radius: Theme.spotlight.barRadius
                sx: bar.x
                sy: bar.y
                tint: Theme.glass.tintStrong
            }
            // the dark vertical gradient (Q-panels-14)
            Rectangle {
                anchors.fill: parent
                radius: Theme.spotlight.barRadius
                gradient: Gradient {
                    GradientStop { position: 0; color: Theme.spotlight.barTopTint }
                    GradientStop { position: 0.5; color: Theme.spotlight.barMidTint }
                    GradientStop { position: 1; color: Theme.spotlight.barBottomTint }
                }
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onPositionChanged: mouse => { if (hoverGate.note(this, mouse.x, mouse.y) && sp.mode === "" && input.text === "") sp.modeListArmed = true; }
            }
            Symbol {
                id: modeGlyph
                visible: sp.modeInfo !== null
                x: Theme.spotlight.modeGlyphX
                anchors.verticalCenter: parent.verticalCenter
                name: sp.modeInfo ? sp.modeInfo.symbol : ""
                size: Theme.spotlight.modeGlyph
                color: Theme.spotlight.placeholder
            }
            // a category picked in Applications: a grey token before the query
            Rectangle {
                id: token
                visible: sp.category !== ""
                x: Theme.spotlight.modeTextX
                anchors.verticalCenter: parent.verticalCenter
                width: visible ? tokenText.implicitWidth + 2 * Theme.spotlight.tokenPad : 0
                height: Theme.spotlight.tokenH
                radius: Theme.spotlight.tokenRadius
                color: Theme.spotlight.tokenFill
                Text {
                    id: tokenText
                    anchors.centerIn: parent
                    text: sp.category
                    font: input.font
                    color: Theme.spotlight.text
                }
            }
            // trailing: the mic (no action), the top hit's icon once text is typed, "..." in Applications, Files
            // and Clipboard (its View as Grid / List menu is not built)
            Item {
                id: trailing
                anchors.right: parent.right
                anchors.rightMargin: Theme.spotlight.trailingRight
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: 28
                Symbol {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    visible: sp.mode === "" && sp.apps.length === 0
                    name: "mic.fill"
                    size: Theme.spotlight.micSize
                    color: Theme.spotlight.placeholder
                }
                AppIcon {
                    anchors.centerIn: parent
                    width: 28 / Theme.appIcon.body       // the top hit's icon art is about 28
                    height: width
                    visible: sp.mode === "" && sp.apps.length > 0
                    size: width
                    icon: sp.apps.length > 0 ? sp.apps[0].icon || "" : ""
                    appId: sp.apps.length > 0 ? sp.apps[0].id : ""
                }
                Symbol {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spotlight.ellipsisRight - Theme.spotlight.trailingRight
                    anchors.verticalCenter: parent.verticalCenter
                    visible: sp.mode !== "" && sp.mode !== "actions"
                    name: "ellipsis"
                    size: 18
                    color: Theme.spotlight.placeholder
                }
            }
            TextInput {
                id: input
                MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton; cursorShape: Qt.IBeamCursor }   // TextInput sets no I-beam itself
                x: sp.category !== "" ? token.x + token.width + 6 : sp.modeInfo ? Theme.spotlight.modeTextX : Theme.spotlight.textX
                width: trailing.x - 12 - x
                anchors.verticalCenter: parent.verticalCenter
                font: Typography.font(Theme.spotlight.inputSize)
                color: Theme.spotlight.text
                selectionColor: Theme.color.accent
                clip: true
                // caret: white, 2 x 26 (its soft multicolour halo is not drawn)
                cursorDelegate: Rectangle { width: 2; height: 26; radius: 1; color: Theme.spotlight.text; visible: input.cursorVisible }
                onTextChanged: { sp.query = text; if (text !== "") sp.modeListArmed = false; }
                Keys.onEscapePressed: sp.escapeKey()
                Keys.onReturnPressed: sp.acceptSel()
                Keys.onEnterPressed: sp.acceptSel()
                Keys.onDownPressed: sp.moveSel(1)
                Keys.onUpPressed: sp.moveSel(-1)
                Keys.onTabPressed: sp.moveSel(1)
                Keys.onPressed: event => sp.handleKey(event)

                Text {
                    visible: input.text === "" && sp.category === ""
                    anchors.verticalCenter: parent.verticalCenter
                    text: sp.modeInfo ? sp.modeInfo.placeholder : "Search or Ask"
                    font: input.font
                    color: Theme.spotlight.placeholder
                }
            }
        }

        // ---------- the panel under it ----------
        Item {
            id: panel
            visible: sp.below !== "" && height > 0.5
            readonly property bool wide: sp.below === "apps"
            width: wide ? AG.metrics().width : Theme.spotlight.barW
            x: Math.round((stage.width - width) / 2)
            y: bar.y + bar.height + Theme.spotlight.gap
            readonly property real resultsH: Math.min(Theme.spotlight.resultsMax, results.contentHeight + 2 * Theme.spotlight.pillInset)
            // results grow and shrink on a spring (kept from before; the Mac's results motion is not measured)
            Spring { id: grow; target: panel.resultsH; response: Theme.anim.resizeResponse; damping: Theme.anim.resizeDamping; epsilon: 0.3; settlesGlass: true }
            height: sp.below === "apps" ? AG.metrics().height
                  : sp.below === "list" ? Theme.spotlight.listPanelH
                  : sp.below === "modes" ? Theme.spotlight.modeListH * sp.unfold
                  : sp.below === "results" ? (A11y.reduceMotion ? resultsH : grow.value) : 0
            clip: true
            Glass {
                anchors.fill: parent
                radius: panel.wide ? Theme.spotlight.appsRadius : Theme.spotlight.panelRadius
                sx: panel.x
                sy: panel.y
                tint: Theme.glass.tintStrong
            }
            Rectangle {
                width: parent.width
                height: sp.below === "modes" ? Theme.spotlight.modeListH : parent.height
                radius: panel.wide ? Theme.spotlight.appsRadius : Theme.spotlight.panelRadius
                gradient: Gradient {
                    GradientStop { position: 0; color: Theme.spotlight.panelTopVeil }
                    GradientStop { position: 1; color: Theme.spotlight.panelBottomVeil }
                }
            }
            MouseArea { anchors.fill: parent }   // clicks on the panel never close Spotlight

            ModeList {
                visible: sp.below === "modes"
                width: parent.width
                height: Theme.spotlight.modeListH
                onPicked: m => sp.setMode(m)
            }

            ListView {
                id: results
                visible: sp.below === "results"
                x: Theme.spotlight.pillInset
                y: Theme.spotlight.pillInset
                width: parent.width - Theme.spotlight.pillInset - Theme.spotlight.pillRightInset
                height: Theme.spotlight.resultsMax - 2 * Theme.spotlight.pillInset
                interactive: contentHeight > height
                boundsBehavior: Flickable.StopAtBounds
                model: sp.rows
                currentIndex: sp.selected
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
                delegate: ResultRow {
                    required property var modelData
                    required property int index
                    width: results.width
                    selected: index === sp.selected
                    readonly property string k: modelData.kind
                    readonly property var d: k === "action" ? modelData.action : k === "file" ? modelData.file : null
                    title: modelData.title
                    subtitle: modelData.subtitle || ""
                    symbol: k === "calc" ? "equal" : k === "action" ? (d.symbol || "bolt") : "doc"
                    appIcon: k === "app" ? (modelData.icon || "") : k === "action" ? (d.appIcon || "") : ""
                    appId: k === "app" ? modelData.entry.id : k === "action" ? (d.appId || "") : ""
                    themeIcon: k === "file" ? SL.fileIcon(d.path, d.isDir, d.mime) : ""
                    accessory: k === "action" ? SL.quickKeyLabel(SpotlightState.quickKeys, d.id, false) : ""
                    badge: accessory !== ""
                    onClicked: { sp.selected = index; sp.accept(); }
                }
            }

            Loader {
                id: modePanel
                active: sp.mode !== ""
                width: parent.width
                height: parent.height
                sourceComponent: sp.mode === "apps" ? appsComp : listComp
            }
            Component {
                id: appsComp
                AppsPanel {
                    query: sp.query
                    category: sp.category
                    onPickCategory: name => { sp.category = name; input.forceActiveFocus(); }
                    onDone: Panels.close()
                }
            }
            Component {
                id: listComp
                ModeView {
                    mode: sp.mode
                    query: sp.query
                    onDone: Panels.close()
                    onEditFinished: input.forceActiveFocus()
                }
            }
        }
    }
}
