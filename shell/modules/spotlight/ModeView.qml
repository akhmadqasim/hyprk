import QtQuick
import Quickshell
import qs
import qs.components
import qs.services
import "../../lib/search.js" as Search
import "../../lib/spotlight.js" as SL

// Spotlight browse modes (macOS 26/27): Applications (grid with category chips),
// Files (recents first, then search), Actions (with quick keys), Clipboard (history,
// only after the user turned it on). The host (Spotlight.qml) forwards keys:
// move(dx, dy), accept(), and reads `height`. The host also feeds FileSearch.query.
Item {
    id: view

    required property string mode
    property string query: ""
    signal done()                           // an item was opened: close Spotlight
    signal editFinished()                   // quick key editor closed: host gives the query field its focus back

    // layout (macOS 26/27 Spotlight browse views; no reference shot of these, TODO verify)
    readonly property int gridColumns: 6
    readonly property int gridCell: Math.floor(width / gridColumns)
    readonly property int gridIcon: 56
    readonly property int gridRows: 3
    readonly property int listRows: 7
    readonly property int chipHeight: 26

    property int selected: 0
    property string category: ""            // apps chip filter ("" = All)
    property string editingKey: ""          // action id whose quick key is being edited

    readonly property bool isGrid: mode === "apps"
    readonly property var items: {
        const q = query.trim();
        if (mode === "apps") {
            const list = q ? Search.rank(Apps.visibleEntries, q, 200) : Apps.sortedEntries;
            return category && !q ? list.filter(e => SL.appCategory(e.categories) === category) : list;
        }
        if (mode === "files") return q ? FileSearch.results : FileSearch.recents;
        if (mode === "actions") return SpotlightActions.rank(q);
        if (mode === "clipboard") return Clipboard.enabled ? SL.filterClips(Clipboard.items, q) : [];
        return [];
    }
    readonly property var chips: mode === "apps" ? [""].concat(SL.appCategoryChips(Apps.visibleEntries)) : []
    readonly property bool clipboardOff: mode === "clipboard" && !Clipboard.enabled
    readonly property string heading: {
        if (mode === "files") return query.trim() ? (FileSearch.searching ? "Searching…" : "Files") : "Recents";
        if (mode === "clipboard") return Clipboard.enabled ? "Clipboard · kept " + SL.retentionLabel(Clipboard.retention).toLowerCase() : "";
        if (mode === "actions") return "Actions";
        return "";
    }

    onModeChanged: { selected = 0; category = ""; editingKey = ""; prepare(); }
    onQueryChanged: selected = 0
    onItemsChanged: if (selected >= items.length) selected = Math.max(0, items.length - 1)
    Component.onCompleted: prepare()
    function prepare() {
        if (mode === "files") FileSearch.loadRecents();
        if (mode === "clipboard") Clipboard.reload();
    }

    // id "" = cancel
    function finishEdit(id, key) {
        if (id) SpotlightState.setQuickKey(id, key);
        editingKey = "";
        editFinished();
    }
    function move(dx, dy) {
        if (items.length === 0) return;
        const step = isGrid ? dx + dy * gridColumns : dy;
        selected = Math.max(0, Math.min(items.length - 1, selected + step));
    }
    function accept() {
        const it = items[selected];
        if (!it) return;
        if (mode === "apps") { Apps.launch(it, it.id); done(); }
        else if (mode === "files") { FileSearch.open(it); done(); }
        else if (mode === "actions") SpotlightActions.run(it);   // closes Spotlight itself
        else if (mode === "clipboard") { Clipboard.copy(it); done(); }
    }

    readonly property int headerH: heading !== "" ? Theme.spotlight.headerHeight + 4 : 0
    readonly property int chipsH: chips.length > 1 ? chipHeight + 12 : 0
    readonly property int bodyH: {
        if (clipboardOff) return 168;
        if (items.length === 0) return 64;
        if (isGrid) return Math.min(Math.ceil(items.length / gridColumns), gridRows) * (gridCell + 4);
        return Math.min(items.length, listRows) * Theme.spotlight.rowHeight;
    }
    height: headerH + chipsH + bodyH

    // ---------- header (section title + Clipboard "Clear History") ----------
    Item {
        id: header
        width: parent.width
        height: view.headerH
        visible: height > 0
        Text {
            x: Theme.spotlight.rowInset
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.spotlight.headerBaseline + 2
            text: view.heading
            font.family: Theme.fontText
            font.pixelSize: Theme.font.spotlightHeader
            font.weight: Theme.font.semibold
            color: Theme.color.secondaryLabel
        }
        Text {
            visible: view.mode === "clipboard" && Clipboard.items.length > 0
            anchors.right: parent.right
            anchors.rightMargin: Theme.spotlight.rowInset
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.spotlight.headerBaseline + 2
            text: "Clear History"
            font.family: Theme.fontText
            font.pixelSize: Theme.font.spotlightHeader
            color: Theme.color.accent
            MouseArea { anchors.fill: parent; anchors.margins: -4; onClicked: Clipboard.clear() }
        }
    }

    // ---------- Apps: category chips ----------
    Row {
        y: view.headerH + 4
        x: Theme.spotlight.rowInset
        spacing: 6
        visible: view.chipsH > 0
        Repeater {
            model: view.chips
            delegate: Rectangle {
                required property string modelData
                readonly property bool on: view.category === modelData
                height: view.chipHeight
                width: chipText.implicitWidth + 20
                radius: height / 2
                color: on ? Theme.color.accent : Theme.spotlight.field
                Text {
                    id: chipText
                    anchors.centerIn: parent
                    text: parent.modelData || "All"
                    font.family: Theme.fontText
                    font.pixelSize: Theme.font.spotlightHeader + 1
                    font.weight: Theme.font.medium
                    color: parent.on ? Theme.color.textOnAccent : Theme.color.label
                }
                MouseArea { anchors.fill: parent; onClicked: { view.category = parent.modelData; view.selected = 0; } }
            }
        }
    }

    // ---------- body ----------
    Item {
        id: body
        y: view.headerH + view.chipsH
        width: parent.width
        height: view.bodyH

        // nothing found (or nothing yet)
        Text {
            anchors.centerIn: parent
            visible: !view.clipboardOff && view.items.length === 0
            text: view.mode === "clipboard" ? (Clipboard.available ? "Nothing copied yet" : "Clipboard history needs wl-clipboard")
                : view.mode === "files" && !view.query.trim() ? "No Recent Files"
                : view.mode === "files" && FileSearch.searching ? "Searching…" : "No Results"
            font.family: Theme.fontText
            font.pixelSize: Theme.font.spotlightRow
            color: Theme.color.secondaryLabel
        }

        // Clipboard off: macOS asks once before keeping anything
        Column {
            anchors.centerIn: parent
            visible: view.clipboardOff
            spacing: 8
            width: parent.width - 80
            Symbol { anchors.horizontalCenter: parent.horizontalCenter; name: "clipboard"; size: 34; color: Theme.color.secondaryLabel }
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "Clipboard History"
                font.family: Theme.fontText
                font.pixelSize: Theme.font.spotlightRow
                font.weight: Theme.font.semibold
                color: Theme.color.label
            }
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: Clipboard.available
                    ? "Spotlight can keep the text and images you copy, so you can find them again. Items are stored on this computer and deleted after 8 hours."
                    : "Clipboard history needs wl-clipboard (wl-paste and wl-copy)."
                font.family: Theme.fontText
                font.pixelSize: Theme.font.spotlightHeader + 1
                color: Theme.color.secondaryLabel
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: Clipboard.available
                width: turnOn.implicitWidth + 28
                height: 28
                radius: height / 2
                color: Theme.color.accent
                Text {
                    id: turnOn
                    anchors.centerIn: parent
                    text: "Turn On"
                    font.family: Theme.fontText
                    font.pixelSize: Theme.font.spotlightHeader + 2
                    font.weight: Theme.font.medium
                    color: Theme.color.textOnAccent
                }
                MouseArea { anchors.fill: parent; onClicked: SpotlightState.setClipboardHistory("8h") }
            }
        }

        // Apps grid
        GridView {
            id: grid
            anchors.fill: parent
            visible: view.isGrid && view.items.length > 0
            clip: true
            cellWidth: view.gridCell
            cellHeight: view.gridCell + 4
            model: view.isGrid ? view.items : []
            currentIndex: view.selected
            onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)
            boundsBehavior: Flickable.StopAtBounds
            delegate: Item {
                id: cell
                required property var modelData
                required property int index
                width: grid.cellWidth
                height: grid.cellHeight
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 3
                    visible: cell.index === view.selected
                    radius: Theme.spotlight.rowRadius
                    color: Theme.spotlight.selection
                }
                AppIcon {
                    id: gicon
                    y: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: view.gridIcon
                    height: width
                    size: width
                    icon: cell.modelData.icon || ""
                    appId: cell.modelData.id
                }
                Text {
                    anchors.top: gicon.bottom
                    anchors.topMargin: 4
                    x: 6
                    width: parent.width - 12
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    text: cell.modelData.name
                    font.family: Theme.fontText
                    font.pixelSize: Theme.font.launchpadLabel
                    color: Theme.color.label
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: view.selected = cell.index
                    onClicked: { view.selected = cell.index; view.accept(); }
                }
            }
        }

        // Files / Actions / Clipboard list
        ListView {
            id: list
            anchors.fill: parent
            visible: !view.isGrid && view.items.length > 0
            clip: true
            model: !view.isGrid ? view.items : []
            currentIndex: view.selected
            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
            boundsBehavior: Flickable.StopAtBounds
            delegate: ResultRow {
                id: rr
                required property var modelData
                required property int index
                width: list.width
                selected: index === view.selected
                readonly property var d: modelData
                readonly property bool isImage: String(d.mime || "").startsWith("image/")
                title: (view.mode === "files" ? d.name : view.mode === "clipboard" && d.mime ? SL.clipTitle(d) : d.title) || ""
                subtitle: (view.mode === "files" ? d.dir : view.mode === "actions" ? d.subtitle : "") || ""
                image: view.mode === "clipboard" && isImage && d.file ? d.file : ""
                symbol: view.mode === "clipboard" ? (isImage ? "photo" : "doc") : view.mode === "actions" ? (d.symbol || "bolt") : "doc"
                themeIcon: view.mode === "files" && d.path ? SL.fileIcon(d.path, d.isDir, d.mime) : ""
                appIcon: view.mode === "actions" ? (d.appIcon || "") : ""
                appId: view.mode === "actions" ? (d.appId || "") : ""
                badge: view.mode === "actions"
                accessory: view.mode === "clipboard" ? SL.relTime(d.ts, Date.now())
                    : view.mode === "actions" ? SL.quickKeyLabel(SpotlightState.quickKeys, d.id, rr.selected) : ""
                onHovered: view.selected = index
                onClicked: { view.selected = index; view.accept(); }
                onAccessoryClicked: { view.selected = index; view.editingKey = d.id; }

                // quick key editor: type a short key, Return saves, Esc cancels, empty clears
                Rectangle {
                    visible: view.editingKey === rr.d.id
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spotlight.rowInset
                    anchors.verticalCenter: parent.verticalCenter
                    width: 120
                    height: 26
                    radius: height / 2
                    color: Theme.spotlight.field
                    border.width: 1
                    border.color: Theme.color.accent
                    z: 2
                    TextInput {
                        id: keyInput
                        MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton; cursorShape: Qt.IBeamCursor }   // TextInput sets no I-beam itself
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        verticalAlignment: TextInput.AlignVCenter
                        font.family: Theme.fontText
                        font.pixelSize: Theme.font.spotlightHeader + 1
                        color: Theme.color.label
                        maximumLength: 6
                        validator: RegularExpressionValidator { regularExpression: /[A-Za-z0-9]*/ }
                        Text {
                            visible: keyInput.text === ""
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Quick key"
                            font: keyInput.font
                            color: Theme.color.tertiaryLabel
                        }
                        onVisibleChanged: if (visible) { text = SpotlightState.quickKeys[rr.d.id] || ""; forceActiveFocus(); selectAll(); }
                        Keys.onReturnPressed: view.finishEdit(rr.d.id, text)
                        Keys.onEnterPressed: view.finishEdit(rr.d.id, text)
                        Keys.onEscapePressed: view.finishEdit("", "")
                    }
                }
            }
        }
    }
}
