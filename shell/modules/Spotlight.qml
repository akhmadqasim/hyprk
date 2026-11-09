import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.services
import "../lib/search.js" as Search

// Spotlight (Super+Space): capsule search bar, results below in a second
// glass panel. Apps from .desktop entries, inline calculator, files placeholder.
ShellWindow {
    id: sp

    required property var modelData
    screen: modelData

    readonly property bool shown: Panels.open === "spotlight"
    visible: shown
    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-spotlight"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property string query: ""
    property int selected: 0
    readonly property var calcValue: Search.calc(query)
    readonly property var apps: shown && query.trim() !== "" ? Search.rank(Apps.visibleEntries, query, Theme.spotlight.maxApps) : []
    // rows: {kind: "calc"|"app"|"files", ...}
    // macOS 26/27 layout: section headers, few tall rows, no per-row type column
    readonly property var rows: {
        if (query.trim() === "") return [];
        const r = [];
        if (calcValue !== null) {
            r.push({ kind: "header", title: "Calculator" });
            r.push({ kind: "calc", title: Search.formatNumber(calcValue), subtitle: query.trim() + " =" });
        }
        if (apps.length > 0) {
            r.push({ kind: "header", title: "Applications" });
            for (const a of apps) r.push({ kind: "app", title: a.name, entry: a, icon: a.icon });
        }
        r.push({ kind: "header", title: "Files" });
        r.push({ kind: "files", title: "Search Files for “" + query.trim() + "”" });
        return r;
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
    Component.onCompleted: { takeQuery(); input.forceActiveFocus(); }
    Connections {
        target: Panels
        function onSpotlightQueryChanged() { sp.takeQuery(); }
    }
    onQueryChanged: { selected = 0; if (!selectable(0)) step(1); }

    function accept() {
        const row = rows[selected];
        if (!row) return;
        if (row.kind === "app") Apps.launch(row.entry, row.entry.id);
        else if (row.kind === "calc") Quickshell.clipboardText = row.title;
        Panels.close();
    }

    MouseArea { anchors.fill: parent; onPressed: Panels.close() }

    // `qs ipc call spotlight search "2+2"`: open with a query (scripted screenshots)
    readonly property real panelX: (width - Theme.spotlight.width) / 2
    readonly property real panelY: height * Theme.spotlight.top

    // one glass panel: search row on top, results below a hairline
    Item {
        id: panel
        x: sp.panelX
        y: sp.panelY
        width: Theme.spotlight.width
        height: Theme.spotlight.barHeight + (sp.rows.length > 0 ? list.height + Theme.spotlight.listInset * 2 + 1 : 0)
        scale: sp.shown ? 1 : 0.97
        Behavior on scale { NumberAnimation { duration: Theme.anim.fast; easing.type: Theme.anim.easing } }

        Glass {
            anchors.fill: parent
            radius: sp.rows.length > 0 ? Theme.spotlight.resultsRadius : Theme.spotlight.radius
            sx: panel.x
            sy: panel.y
            tint: Theme.glass.tintStrong
        }
        MouseArea { anchors.fill: parent }

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
                name: "magnifyingglass"
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
                Keys.onEscapePressed: Panels.close()
                Keys.onReturnPressed: sp.accept()
                Keys.onEnterPressed: sp.accept()
                Keys.onDownPressed: sp.step(1)
                Keys.onUpPressed: sp.step(-1)
                Keys.onTabPressed: sp.step(1)

                Text {
                    visible: input.text === ""
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Spotlight Search"
                    font: input.font
                    color: Theme.color.tertiaryLabel
                }
            }
        }

        Rectangle {
            visible: sp.rows.length > 0
            y: bar.height
            x: Theme.spotlight.hPadding
            width: parent.width - Theme.spotlight.hPadding * 2
            height: 1
            color: Theme.color.separator
        }

        Column {
            id: list
            visible: sp.rows.length > 0
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
                        visible: !r.header
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
                        visible: !r.header
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
}
