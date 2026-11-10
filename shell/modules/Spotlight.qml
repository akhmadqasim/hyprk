import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.services
import "../lib/search.js" as Search
import "../lib/spotlight.js" as SL
import "spotlight"

// Spotlight (Super+Space): capsule search bar, results below in a second
// glass panel. Apps from .desktop entries, inline calculator, actions (quick keys
// first), files. Browse modes (macOS 26/27, Super/Ctrl/Alt+1..4 or the mode buttons):
// Applications, Files, Actions, Clipboard, drawn by spotlight/ModeView.qml.
ShellWindow {
    id: sp

    required property var modelData
    screen: modelData

    readonly property bool shown: Panels.open === "spotlight"
    visible: shown

    fadeIn: true                 // created on open: fade and scale in from creation, glass included
    glassOpacity: appear
    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-spotlight"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property string query: ""
    property int selected: 0
    readonly property var calcValue: Search.calc(query)
    readonly property var apps: shown && mode === "" && query.trim() !== "" ? Search.rank(Apps.visibleEntries, query, Theme.spotlight.maxApps) : []
    // browse mode ("" = all results), shared with SpotlightState so global shortcuts can open one
    readonly property string mode: SpotlightState.mode
    readonly property var modeInfo: SL.modeInfo(mode)
    // the mode buttons show once the pointer moves over Spotlight, or while a mode is active
    property bool pointerMoved: false
    readonly property var actions: mode === "" && query.trim() !== "" ? SpotlightActions.rank(query, 2) : []
    readonly property bool quickKeyHit: SL.quickKeyAction(SpotlightState.quickKeys, query) !== ""
    readonly property var files: mode === "" ? FileSearch.results.slice(0, 3) : []
    Binding { target: FileSearch; property: "query"; value: sp.mode === "" || sp.mode === "files" ? sp.query : "" }
    // rows: {kind: "calc"|"app"|"action"|"file", ...}
    // macOS 26/27 layout: section headers, few tall rows, no per-row type column
    readonly property var rows: {
        if (mode !== "" || query.trim() === "") return [];
        const r = [];
        const addActions = () => {
            if (actions.length === 0) return;
            r.push({ kind: "header", title: "Actions" });
            for (const a of actions) r.push({ kind: "action", title: a.title, subtitle: a.subtitle || "", action: a });
        };
        if (quickKeyHit) addActions();      // a typed quick key puts its action on top
        if (calcValue !== null) {
            r.push({ kind: "header", title: "Calculator" });
            r.push({ kind: "calc", title: Search.formatNumber(calcValue), subtitle: query.trim() + " =" });
        }
        if (apps.length > 0) {
            r.push({ kind: "header", title: "Applications" });
            for (const a of apps) r.push({ kind: "app", title: a.name, entry: a, icon: a.icon });
        }
        if (!quickKeyHit) addActions();
        if (files.length > 0) {
            r.push({ kind: "header", title: "Files" });
            for (const f of files) r.push({ kind: "file", title: f.name, subtitle: f.dir, file: f });
        }
        return r;
    }
    function setMode(m) {
        SpotlightState.mode = m;
        pointerMoved = true;
        input.forceActiveFocus();
    }
    // query field keys without a dedicated handler: Super/Ctrl/Alt+1..4 pick a mode,
    // Left/Right on an empty field cycle the modes (macOS) or move in the Apps grid
    function handleKey(event) {
        const m = SL.modeForKey(event.key, event.modifiers & Qt.MetaModifier, event.modifiers & Qt.ControlModifier, event.modifiers & Qt.AltModifier);
        if (m !== "") { setMode(m === mode ? "" : m); event.accepted = true; return; }
        const dir = event.key === Qt.Key_Right ? 1 : event.key === Qt.Key_Left ? -1 : 0;
        if (dir === 0 || input.text !== "") return;
        if (mode === "apps") modeView.move(dir, 0);
        else setMode(SL.cycleMode(mode, dir));
        event.accepted = true;
    }
    function moveSel(dir) { if (mode !== "") modeView.move(0, dir); else step(dir); }
    function acceptSel() { if (mode !== "") modeView.accept(); else accept(); }
    // Esc in a mode clears the query, then leaves the mode; then closes Spotlight
    function escapeKey() {
        if (mode === "") Panels.close();
        else if (input.text !== "") input.text = "";
        else setMode("");
    }
    function selectable(i) { return rows[i] && rows[i].kind !== "header"; }
    // next selectable row in direction dir (wraps), skipping section headers
    function step(dir) {
        for (let i = 1; i <= rows.length; i++) {
            const j = (selected + dir * i + rows.length) % rows.length;
            if (selectable(j)) { selected = j; return; }
        }
    }

    // the window exists only while open (shell.qml LazyLoader); a query handed over
    // by IPC is taken on creation and whenever a new one arrives
    function takeQuery() {
        if (Panels.spotlightQuery === "") return;
        input.text = Panels.spotlightQuery;
        Panels.spotlightQuery = "";
    }
    Component.onCompleted: { takeQuery(); input.forceActiveFocus(); FileSearch.loadRecents(); }
    Connections {
        target: Panels
        function onSpotlightQueryChanged() { sp.takeQuery(); }
    }
    function selectFirst() { selected = 0; if (!selectable(0)) step(1); }
    onQueryChanged: selectFirst()
    // rows can fill in after the query changed (window creation, streamed files): keep a row selected
    onRowsChanged: if (!selectable(selected)) selectFirst()

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
        hoverEnabled: true
        onPressed: Panels.close()
        onPositionChanged: sp.pointerMoved = true
    }

    // `qs ipc call spotlight search "2+2"`: open with a query (scripted screenshots)
    readonly property real panelX: (width - Theme.spotlight.width) / 2
    readonly property real panelY: height * Theme.spotlight.top

    // one glass panel: search row on top, results below a hairline
    Item {
        id: panel
        x: sp.panelX
        y: sp.panelY
        width: Theme.spotlight.width
        readonly property bool expanded: sp.mode !== "" || sp.rows.length > 0
        height: Theme.spotlight.barHeight + (sp.mode !== "" ? modeView.height + Theme.spotlight.listInset * 2 + 1
                                            : sp.rows.length > 0 ? list.height + Theme.spotlight.listInset * 2 + 1 : 0)
        opacity: sp.appear
        scale: 0.97 + 0.03 * sp.appear

        Glass {
            anchors.fill: parent
            radius: panel.expanded ? Theme.spotlight.resultsRadius : Theme.spotlight.radius
            sx: panel.x
            sy: panel.y
            tint: Theme.glass.tintStrong
        }
        MouseArea { anchors.fill: parent; hoverEnabled: true; onPositionChanged: sp.pointerMoved = true }

        Item {
            id: bar
            width: parent.width
            height: Theme.spotlight.barHeight
            // the query sits in a capsule field (macOS 26/27 Spotlight)
            Rectangle {
                anchors.fill: parent
                anchors.margins: Theme.spotlight.fieldInset
                radius: height / 2
                color: Theme.spotlight.field
            }
            Symbol {
                id: mag
                x: Theme.spotlight.hPadding
                anchors.verticalCenter: parent.verticalCenter
                name: sp.modeInfo ? sp.modeInfo.symbol : "magnifyingglass"
                size: Theme.spotlight.iconSize
                color: Theme.color.secondaryLabel
            }
            TextInput {
                id: input
                anchors.left: mag.right
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: Theme.spotlight.hPadding
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.font.spotlightInput
                color: Theme.color.label
                selectionColor: Theme.color.accent
                clip: true
                onTextChanged: sp.query = text
                Keys.onEscapePressed: sp.escapeKey()
                Keys.onReturnPressed: sp.acceptSel()
                Keys.onEnterPressed: sp.acceptSel()
                Keys.onDownPressed: sp.moveSel(1)
                Keys.onUpPressed: sp.moveSel(-1)
                Keys.onTabPressed: sp.moveSel(1)
                Keys.onPressed: event => sp.handleKey(event)

                Text {
                    visible: input.text === ""
                    anchors.verticalCenter: parent.verticalCenter
                    text: sp.modeInfo ? sp.modeInfo.placeholder : "Spotlight Search"
                    font: input.font
                    color: Theme.color.tertiaryLabel
                }
            }
        }

        Rectangle {
            visible: panel.expanded
            y: bar.height
            x: Theme.spotlight.hPadding
            width: parent.width - Theme.spotlight.hPadding * 2
            height: 1
            color: Theme.color.separator
        }

        ModeView {
            id: modeView
            visible: sp.mode !== ""
            mode: sp.mode
            query: sp.query
            x: Theme.spotlight.listInset
            y: bar.height + 1 + Theme.spotlight.listInset
            width: parent.width - Theme.spotlight.listInset * 2
            onDone: Panels.close()
            onEditFinished: input.forceActiveFocus()
        }

        Column {
            id: list
            visible: sp.mode === "" && sp.rows.length > 0
            x: Theme.spotlight.listInset
            y: bar.height + 1 + Theme.spotlight.listInset
            width: parent.width - Theme.spotlight.listInset * 2

            Repeater {
                model: sp.rows
                delegate: Item {
                    id: r
                    required property var modelData
                    required property int index
                    readonly property bool header: modelData.kind === "header"
                    readonly property bool sel: index === sp.selected
                    // file and action rows are drawn by spotlight/ResultRow.qml
                    readonly property bool rich: modelData.kind === "file" || modelData.kind === "action"
                    width: list.width
                    height: header ? Theme.spotlight.headerHeight
                          : modelData.kind === "calc" ? Theme.spotlight.rowHeight * Theme.spotlight.calcRowScale : Theme.spotlight.rowHeight

                    Text {
                        visible: r.header
                        x: Theme.spotlight.rowInset
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Theme.spotlight.headerBaseline
                        text: r.modelData.title
                        font.family: Theme.fontText
                        font.pixelSize: Theme.font.spotlightHeader
                        font.weight: Theme.font.semibold
                        color: Theme.color.secondaryLabel
                    }

                    // neutral grey selection pill, inset like macOS
                    Rectangle {
                        visible: r.sel && !r.header
                        anchors.fill: parent
                        radius: Theme.spotlight.rowRadius
                        color: Theme.spotlight.selection
                    }
                    Item {
                        id: ic
                        visible: !r.header && !r.rich
                        x: Theme.spotlight.rowInset
                        width: Theme.spotlight.rowIcon
                        height: width
                        anchors.verticalCenter: parent.verticalCenter
                        AppIcon {
                            anchors.fill: parent
                            visible: r.modelData.kind === "app"
                            size: parent.width
                            icon: r.modelData.icon || ""
                            appId: r.modelData.entry ? r.modelData.entry.id : ""
                        }
                        Symbol {
                            anchors.centerIn: parent
                            visible: r.modelData.kind !== "app"
                            name: r.modelData.kind === "calc" ? "equal" : "folder"
                            size: parent.width * Theme.appIcon.inner
                            color: Theme.color.secondaryLabel
                        }
                    }
                    Column {
                        visible: !r.header && !r.rich
                        anchors.left: ic.right
                        anchors.leftMargin: Theme.spotlight.textGap
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spotlight.textGap
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            width: parent.width
                            text: r.modelData.title
                            elide: Text.ElideRight
                            font.family: r.modelData.kind === "calc" ? Theme.fontDisplay : Theme.fontText
                            font.pixelSize: r.modelData.kind === "calc" ? Theme.font.spotlightInput : Theme.font.spotlightRow
                            color: Theme.color.label
                        }
                        Text {
                            width: parent.width
                            visible: r.modelData.kind === "calc"
                            text: r.modelData.subtitle || ""
                            font.family: Theme.fontText
                            font.pixelSize: Theme.font.spotlightHeader
                            color: Theme.color.secondaryLabel
                        }
                    }
                    ResultRow {
                        anchors.fill: parent
                        visible: r.rich
                        readonly property var d: r.modelData.kind === "action" ? r.modelData.action : r.modelData.file
                        title: r.modelData.title
                        subtitle: r.modelData.subtitle || ""
                        symbol: r.rich && r.modelData.kind === "action" ? (d.symbol || "bolt") : "doc"
                        appIcon: r.modelData.kind === "action" ? (d.appIcon || "") : ""
                        appId: r.modelData.kind === "action" ? (d.appId || "") : ""
                        themeIcon: r.modelData.kind === "file" ? SL.fileIcon(d.path, d.isDir, d.mime) : ""
                        accessory: r.modelData.kind === "action" && SpotlightState.quickKeys[d.id] ? SpotlightState.quickKeys[d.id].toUpperCase() : ""
                        badge: accessory !== ""
                    }
                    MouseArea {
                        anchors.fill: parent
                        enabled: !r.header
                        hoverEnabled: true
                        onEntered: sp.selected = r.index
                        onClicked: { sp.selected = r.index; sp.accept(); }
                    }
                }
            }
        }
    }

    // mode buttons (Applications, Files, Actions, Clipboard) to the right of the bar
    ModeButtons {
        x: sp.panelX + Theme.spotlight.width + 12
        y: sp.panelY
        originX: x
        originY: y
        mode: sp.mode
        reveal: (sp.pointerMoved || sp.mode !== "") ? sp.appear : 0
        Behavior on reveal { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        onPicked: m => sp.setMode(m)
    }
}
