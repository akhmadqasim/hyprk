import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs
import qs.components
import qs.services
import "../lib/search.js" as Search

// Spotlight (Super+Space): capsule search bar, results below in a second
// glass panel. Apps from .desktop entries, inline calculator, files placeholder.
PanelWindow {
    id: sp

    required property var modelData
    screen: modelData

    readonly property bool shown: Panels.open === "spotlight"
    visible: shown
    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.namespace: "hyprk-spotlight"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property string query: ""
    property int selected: 0
    readonly property var calcValue: Search.calc(query)
    readonly property var apps: Search.rank(Apps.entries, query, Theme.spotlight.maxRows)
    // rows: {kind: "calc"|"app"|"files", ...}
    readonly property var rows: {
        if (query.trim() === "") return [];
        const r = [];
        if (calcValue !== null) r.push({ kind: "calc", title: Search.formatNumber(calcValue), subtitle: query.trim() + " =" });
        for (const a of apps) r.push({ kind: "app", title: a.name, subtitle: "Application", entry: a, icon: a.icon });
        r.push({ kind: "files", title: "Search Files for “" + query.trim() + "”", subtitle: "Files (coming soon)" });
        return r;
    }

    onShownChanged: {
        query = "";
        input.text = "";
        selected = 0;
        if (shown) input.forceActiveFocus();
    }
    onQueryChanged: selected = 0

    function accept() {
        const row = rows[selected];
        if (!row) return;
        if (row.kind === "app") Apps.launch(row.entry, row.entry.id);
        else if (row.kind === "calc") Quickshell.execDetached(["wl-copy", row.title]);
        Panels.close();
    }

    MouseArea { anchors.fill: parent; onPressed: Panels.close() }

    // `qs ipc call spotlight search "2+2"`: open with a query (scripted screenshots)
    IpcHandler {
        target: "spotlight"
        function search(q: string): void {
            Panels.open = "spotlight";
            input.text = q;
        }
    }

    readonly property real panelX: (width - Theme.spotlight.width) / 2
    readonly property real panelY: height / Theme.spotlight.topFraction - Theme.spotlight.barHeight / 2

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
                Keys.onDownPressed: sp.selected = Math.min(sp.rows.length - 1, sp.selected + 1)
                Keys.onUpPressed: sp.selected = Math.max(0, sp.selected - 1)
                Keys.onTabPressed: sp.selected = (sp.selected + 1) % Math.max(1, sp.rows.length)

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
                    readonly property bool sel: index === sp.selected
                    width: list.width
                    height: modelData.kind === "calc" ? Theme.spotlight.rowHeight * 1.5 : Theme.spotlight.rowHeight

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.spotlight.rowRadius
                        color: Theme.color.switcherSelection
                        visible: r.sel
                    }
                    Item {
                        id: ic
                        x: 8
                        width: Theme.spotlight.rowIcon
                        height: width
                        anchors.verticalCenter: parent.verticalCenter
                        IconImage {
                            anchors.fill: parent
                            visible: r.modelData.kind === "app"
                            source: r.modelData.kind === "app" ? Apps.iconUrl(r.modelData.icon, r.modelData.entry.id) : ""
                            asynchronous: true
                            mipmap: true
                        }
                        Symbol {
                            anchors.centerIn: parent
                            visible: r.modelData.kind !== "app"
                            name: r.modelData.kind === "calc" ? "equal" : "folder"
                            size: parent.width * 0.7
                            color: Theme.color.secondaryLabel
                        }
                    }
                    Column {
                        anchors.left: ic.right
                        anchors.leftMargin: 12
                        anchors.right: parent.right
                        anchors.rightMargin: 12
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
                            text: r.modelData.subtitle
                            font.family: Theme.fontText
                            font.pixelSize: Theme.font.spotlightHeader
                            color: Theme.color.secondaryLabel
                        }
                    }
                    Text {
                        visible: r.modelData.kind !== "calc"
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: r.modelData.subtitle
                        font.family: Theme.fontText
                        font.pixelSize: Theme.font.spotlightHeader
                        color: Theme.color.tertiaryLabel
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: sp.selected = r.index
                        onClicked: { sp.selected = r.index; sp.accept(); }
                    }
                }
            }
        }
    }
}
