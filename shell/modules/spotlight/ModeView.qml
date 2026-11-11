import QtQuick
import Quickshell
import qs
import qs.HyprK
import qs.components
import qs.services
import "../../lib/spotlight.js" as SL

// Spotlight list modes in their 520 x 490 glass panel (macOS 27.2.1, MAC-ANSWERS.md Q-panels-25): Files (recents,
// then search), Actions (with quick keys), Clipboard (history, only after the user turned it on). A header at
// x 20 (Actions "Suggestions", Files "Recents"), a 1 pt separator at y 43.5, rows of 62 from y 44.5. The Mac's
// Files view is the 844 grid of the Apps panel; here it stays a list. Applications is AppsPanel.qml.
// The host (Spotlight.qml) forwards keys: move(dy), accept(). It also feeds FileSearch.query.
Item {
    id: view

    required property string mode
    property string query: ""
    signal done()                           // an item was opened: close Spotlight
    signal editFinished()                   // quick key editor closed: host gives the query field its focus back

    property int selected: 0
    property string editingKey: ""          // action id whose quick key is being edited

    readonly property var items: {
        const q = query.trim();
        if (mode === "files") return q ? FileSearch.results : FileSearch.recents;
        if (mode === "actions") return SpotlightActions.rank(q);
        if (mode === "clipboard") return Clipboard.enabled ? SL.filterClips(Clipboard.items, q) : [];
        return [];
    }
    readonly property bool clipboardOff: mode === "clipboard" && !Clipboard.enabled
    readonly property string heading: {
        if (mode === "files") return query.trim() ? (FileSearch.searching ? "Searching…" : "Files") : "Recents";
        if (mode === "clipboard") return Clipboard.enabled ? "Clipboard · kept " + SL.retentionLabel(Clipboard.retention).toLowerCase() : "";
        if (mode === "actions") return query.trim() ? "Actions" : "Suggestions";
        return "";
    }

    onModeChanged: { selected = 0; editingKey = ""; prepare(); }
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
    function move(dy) {
        if (items.length === 0) return;
        selected = Math.max(0, Math.min(items.length - 1, selected + dy));
    }
    function accept() {
        const it = items[selected];
        if (!it) return;
        if (mode === "files") { FileSearch.open(it); done(); }
        else if (mode === "actions") SpotlightActions.run(it);   // closes Spotlight itself
        else if (mode === "clipboard") { Clipboard.copy(it); done(); }
    }

    // ---------- header (section title + Clipboard "Clear History") ----------
    Text {
        x: Theme.spotlight.headerX
        anchors.verticalCenter: parent.top
        anchors.verticalCenterOffset: Theme.spotlight.headerCY
        visible: view.heading !== ""
        text: view.heading
        font: Typography.font(Theme.spotlight.headerSize, Typography.semibold)
        color: Theme.spotlight.text
    }
    Text {
        visible: view.mode === "clipboard" && Clipboard.items.length > 0
        anchors.right: parent.right
        anchors.rightMargin: Theme.spotlight.headerX
        anchors.verticalCenter: parent.top
        anchors.verticalCenterOffset: Theme.spotlight.headerCY
        text: "Clear History"
        font: Typography.font(Theme.spotlight.headerSize)
        color: Theme.color.accent
        MouseArea { anchors.fill: parent; anchors.margins: -4; onClicked: Clipboard.clear() }
    }
    ShaderEffect {
        visible: view.heading !== ""
        x: Theme.spotlight.headerX
        y: Theme.spotlight.headerSepY - 0.5
        width: parent.width - 2 * Theme.spotlight.headerX
        height: 1
        property vector4d fill: Qt.vector4d(Theme.spotlight.separatorLift, Theme.spotlight.separatorLift, Theme.spotlight.separatorLift, 0)
        property size sizePt: Qt.size(width, height)
        property real radius: 0
        property real dpr: Screen.devicePixelRatio
        fragmentShader: Qt.resolvedUrl("../../shaders/plusfill.frag.qsb")
    }

    // ---------- body ----------
    Item {
        id: body
        y: Theme.spotlight.listTop
        width: parent.width
        height: parent.height - y

        // nothing found (or nothing yet)
        Text {
            anchors.centerIn: parent
            visible: !view.clipboardOff && view.items.length === 0
            text: view.mode === "clipboard" ? (Clipboard.available ? "Nothing copied yet" : "Clipboard history needs wl-clipboard")
                : view.mode === "files" && !view.query.trim() ? "No Recent Files"
                : view.mode === "files" && FileSearch.searching ? "Searching…" : "No Results"
            font: Typography.font(Theme.spotlight.rowTitle)
            color: Theme.spotlight.secondary
        }

        // Clipboard off: macOS asks once before keeping anything (texts not seen on the Mac)
        Column {
            anchors.centerIn: parent
            visible: view.clipboardOff
            spacing: 8
            width: parent.width - 80
            Symbol { anchors.horizontalCenter: parent.horizontalCenter; name: "clipboard"; size: 34; color: Theme.spotlight.secondary }
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "Clipboard History"
                font: Typography.font(Theme.spotlight.rowTitle, Typography.semibold)
                color: Theme.spotlight.text
            }
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: Clipboard.available
                    ? "Spotlight can keep the text and images you copy, so you can find them again. Items are stored on this computer and deleted after 8 hours."
                    : "Clipboard history needs wl-clipboard (wl-paste and wl-copy)."
                font: Typography.font(13)
                color: Theme.spotlight.secondary
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
                    font: Typography.font(13, Typography.medium)
                    color: Theme.color.textOnAccent
                }
                MouseArea { anchors.fill: parent; onClicked: SpotlightState.setClipboardHistory("8h") }
            }
        }

        ListView {
            id: list
            x: Theme.spotlight.pillInset
            width: parent.width - Theme.spotlight.pillInset - Theme.spotlight.pillRightInset
            height: parent.height
            visible: view.items.length > 0
            clip: true
            cacheBuffer: Theme.spotlight.rowH
            model: view.items
            currentIndex: view.selected
            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
            boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
            RubberBand { flickable: list }
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
                onClicked: { view.selected = index; view.accept(); }
                onAccessoryClicked: { view.selected = index; view.editingKey = d.id; }

                // quick key editor: type a short key, Return saves, Esc cancels, empty clears
                Rectangle {
                    visible: view.editingKey === rr.d.id
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    width: 120
                    height: 26
                    radius: height / 2
                    color: Theme.spotlight.tokenFill
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
                        font: Typography.font(12)
                        color: Theme.spotlight.text
                        maximumLength: 6
                        validator: RegularExpressionValidator { regularExpression: /[A-Za-z0-9]*/ }
                        Text {
                            visible: keyInput.text === ""
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Quick key"
                            font: keyInput.font
                            color: Theme.spotlight.placeholder
                        }
                        onVisibleChanged: if (visible) { text = SpotlightState.quickKeys[rr.d.id] || ""; forceActiveFocus(); selectAll(); }
                        Keys.onReturnPressed: view.finishEdit(rr.d.id, text)
                        Keys.onEnterPressed: view.finishEdit(rr.d.id, text)
                        Keys.onEscapePressed: view.finishEdit("", "")
                        Keys.onPressed: e => KeyBindings.handle(e, keyInput)   // AppKit's text keys
                    }
                }
            }
        }
    }
}
