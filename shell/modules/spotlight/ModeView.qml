import QtQuick
import Quickshell
import qs
import qs.HyprK
import qs.components
import qs.services
import "../../lib/spotlight.js" as SL

// Spotlight list modes in their 520 x 490 glass panel (macOS 27.2.1, MAC-ANSWERS.md Q-panels-25): Files (recents,
// then search), Actions (with quick keys), Clipboard (history, only after the user turned it on). A header at
// x 20 (Actions "Suggestions"), a 1 pt separator at y 43.5, rows of 62 from y 44.5. Files is the 844 grid of
// FilesPanel.qml since judge #25 (the files branch here is no longer reached); Applications is AppsPanel.qml.
// The host (Spotlight.qml) forwards keys: move(dy), accept(). It also feeds FileSearch.query.
Item {
    id: view

    required property string mode
    property string query: ""
    signal done()                           // an item was opened: close Spotlight
    signal editFinished()                   // quick key editor closed: host gives the query field its focus back
    signal back()                           // "Not Now" on the Clipboard question: back to the plain bar

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
    // Clipboard: delete the selected item (host: Cmd-Delete)
    function deleteSelected() {
        const it = items[selected];
        if (mode === "clipboard" && it) Clipboard.remove(it);
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
    // 1 pt, exact at a fractional scale: the item is one device pixel larger on every side there (`pad`,
    // shaders/plusfill.frag) so the antialiasing ramp of an edge inside a pixel is drawn; 0 at 1x / 2x (as the Dock
    // separator, SCALING-AUDIT.md R3.3)
    ShaderEffect {
        visible: view.heading !== ""
        readonly property real lineW: parent.width - 2 * Theme.spotlight.headerX
        property real dpr: (QsWindow.window ? QsWindow.window.devicePixelRatio : Screen.devicePixelRatio)
        property real pad: Pixel.soft(dpr) ? 1 / dpr : 0
        x: Theme.spotlight.headerX - pad
        y: Theme.spotlight.headerSepY - 0.5 - pad
        width: lineW + 2 * pad
        height: Pixel.stroke(1, dpr) + 2 * pad
        property vector4d fill: Qt.vector4d(Theme.spotlight.separatorLift, Theme.spotlight.separatorLift, Theme.spotlight.separatorLift, 0)
        property size sizePt: Qt.size(lineW, Pixel.stroke(1, dpr))
        property real radius: 0
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
            // "No Items" / "No Results": SpotlightUIShared 27.2.1 Localizable
            text: view.mode === "clipboard" ? (Clipboard.available ? (view.query.trim() ? "No Results" : "No Items") : "Clipboard history needs wl-clipboard")
                : view.mode === "files" && !view.query.trim() ? "No Recent Files"
                : view.mode === "files" && FileSearch.searching ? "Searching…" : "No Results"
            font: Typography.font(Theme.spotlight.rowTitle)
            color: Theme.spotlight.secondary
        }

        // Clipboard off: macOS asks before it keeps anything. Texts from SpotlightUIInternal 27.2.1's
        // PasteboardFTEViewController and Localizable.loctable (en): the title, the message (its "Spotlight Settings"
        // link is plain text here), "Allow" and "Not Now". Allow keeps 8 hours, the Mac's default timeout. Layout: not
        // seen on the Mac (this account had history on)
        Column {
            anchors.centerIn: parent
            visible: view.clipboardOff
            spacing: 8
            width: parent.width - 80
            Symbol { anchors.horizontalCenter: parent.horizontalCenter; name: "clipboard"; size: 34; color: Theme.spotlight.secondary }
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "Allow search results from Clipboard"
                font: Typography.font(Theme.spotlight.rowTitle, Typography.semibold)
                color: Theme.spotlight.text
            }
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: Clipboard.available
                    ? "Spotlight can search and display items you’ve copied to your clipboard. Personal and sensitive information may appear in search results. You can manage Clipboard Search at any time in Spotlight Settings."
                    : "Clipboard history needs wl-clipboard (wl-paste and wl-copy)."
                font: Typography.font(13)
                color: Theme.spotlight.secondary
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: Clipboard.available
                spacing: 8
                Repeater {
                    model: [{ t: "Not Now", allow: false }, { t: "Allow", allow: true }]
                    Rectangle {
                        required property var modelData
                        width: label.implicitWidth + 28
                        height: 28
                        radius: height / 2
                        color: modelData.allow ? Theme.color.accent : Theme.spotlight.tokenFill
                        Text {
                            id: label
                            anchors.centerIn: parent
                            text: parent.modelData.t
                            font: Typography.font(13, Typography.medium)
                            color: parent.modelData.allow ? Theme.color.textOnAccent : Theme.spotlight.text
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: parent.modelData.allow ? SpotlightState.setClipboardHistory("8h") : view.back()
                        }
                    }
                }
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
                subtitle: (view.mode === "files" ? d.dir : view.mode === "actions" ? d.subtitle
                    : view.mode === "clipboard" && d.mime ? SL.clipSubtitle(d, Date.now()) : "") || ""
                image: view.mode === "clipboard" && isImage && d.file ? d.file : ""
                symbol: view.mode === "clipboard" ? (isImage ? "photo" : "doc") : view.mode === "actions" ? (d.symbol || "bolt") : "doc"
                themeIcon: view.mode === "files" && d.path ? SL.fileIcon(d.path, d.isDir, d.mime) : ""
                appIcon: view.mode === "actions" ? (d.appIcon || "") : ""
                appId: view.mode === "actions" ? (d.appId || "") : ""
                badge: view.mode === "actions"
                accessory: view.mode === "actions" ? SL.quickKeyLabel(SpotlightState.quickKeys, d.id, rr.selected) : ""
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
