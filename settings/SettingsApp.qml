import QtQuick
import "controls"
import "Panes.js" as Panes

// The whole System Settings UI. Hosts (main.qml for `qml`, shell.qml for
// Quickshell) give it a window and handle the window signals.
Item {
    id: app
    property bool windowActive: true
    property string currentId: "appearance"
    // Non-empty: render once, save a PNG here and quit (reference comparisons).
    property string snapshotPath: ""
    signal closeRequested()
    signal minimizeRequested()
    signal zoomRequested()
    signal moveRequested()

    readonly property var visiblePanes: Panes.visible(AppState.hasBattery, search.text)
    readonly property var current: Panes.panes.find(p => p.id === currentId) || Panes.panes[0]
    property var history: []
    property int historyPos: -1

    function open(id) {
        if (id === currentId) return;
        history = history.slice(0, historyPos + 1).concat([id]);
        historyPos = history.length - 1;
        currentId = id;
    }
    function go(delta) {
        const n = historyPos + delta;
        if (n < 0 || n >= history.length) return;
        historyPos = n;
        currentId = history[n];
    }
    Component.onCompleted: { history = [currentId]; historyPos = 0; }
    Timer {
        running: app.snapshotPath !== ""; interval: 4000
        onTriggered: app.grabToImage(r => { r.saveToFile(app.snapshotPath); Qt.quit(); })
    }

    // Battery and Energy swap: keep selection valid when hasBattery resolves.
    Connections {
        target: AppState
        function onHasBatteryChanged() {
            if (app.currentId === "energy" && AppState.hasBattery) app.currentId = "battery";
            else if (app.currentId === "battery" && !AppState.hasBattery) app.currentId = "energy";
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.window.radius
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
        Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: Theme.sidebar.stroke }

        MouseArea { // dragging the empty top of the sidebar moves the window
            width: parent.width; height: Theme.window.toolbarHeight
            onPressed: app.moveRequested()
        }
        TrafficLights {
            x: Theme.lights.left
            y: (Theme.window.toolbarHeight - Theme.lights.size) / 2
            active: app.windowActive
            onCloseClicked: app.closeRequested()
            onMinimizeClicked: app.minimizeRequested()
            onZoomClicked: app.zoomRequested()
        }
        SearchField {
            id: search
            x: Theme.sidebar.rowMargin; width: parent.width - 2 * Theme.sidebar.rowMargin
            y: Theme.sidebar.searchTop
        }
        ListView {
            id: list
            anchors.top: search.bottom; anchors.topMargin: 4
            anchors.bottom: parent.bottom; anchors.bottomMargin: 8
            x: Theme.sidebar.rowMargin; width: parent.width - 2 * Theme.sidebar.rowMargin
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: app.visiblePanes
            header: search.text === "" ? accountCard : null
            delegate: Item {
                id: d
                required property var modelData
                required property int index
                readonly property bool newGroup: index > 0 && app.visiblePanes[index - 1].group !== modelData.group
                readonly property bool selected: app.currentId === modelData.id
                width: list.width
                height: Theme.sidebar.rowHeight + (newGroup ? Theme.sidebar.groupGap : 0)
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width; height: Theme.sidebar.rowHeight
                    radius: Theme.sidebar.rowRadius
                    color: d.selected ? Theme.sidebar.selection
                         : (rowMa.containsMouse ? Theme.controlFill : "transparent")
                    PaneIcon {
                        id: ic
                        x: Theme.sidebar.iconLeft; anchors.verticalCenter: parent.verticalCenter
                        glyph: d.modelData.glyph; iconId: d.modelData.id
                        tint: Theme.tile[d.modelData.tint]
                    }
                    MacText {
                        anchors.left: ic.right; anchors.leftMargin: Theme.sidebar.iconLabelGap
                        anchors.right: parent.right; anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                        text: d.modelData.title
                        font.family: Theme.fontText; font.pixelSize: Theme.font.body
                        weight: d.selected ? Font.DemiBold : Font.Normal
                        color: d.selected ? Theme.sidebar.selectionText : Theme.label
                    }
                    MouseArea { id: rowMa; anchors.fill: parent; hoverEnabled: true; onClicked: app.open(d.modelData.id) }
                }
            }
        }
    }

    Component {
        id: accountCard
        Item {
            width: list.width; height: Theme.sidebar.accountAvatar + 18
            Rectangle {
                id: avatar
                x: 4; anchors.verticalCenter: parent.verticalCenter
                width: Theme.sidebar.accountAvatar; height: width; radius: width / 2
                gradient: Gradient {
                    GradientStop { position: 0; color: "#A8A8AE" }
                    GradientStop { position: 1; color: "#7C7C82" }
                }
                Text {
                    anchors.centerIn: parent
                    text: "person"; font.family: Theme.fontGlyph; font.pixelSize: parent.width * 0.7
                    color: "white"
                }
            }
            Column {
                anchors.left: avatar.right; anchors.leftMargin: 9; anchors.verticalCenter: parent.verticalCenter
                spacing: 1
                MacText {
                    text: AppState.userName
                    font.family: Theme.fontText; font.pixelSize: Theme.font.body; weight: Font.DemiBold
                    color: Theme.label
                }
                Text {
                    text: "Linux Account"
                    font.family: Theme.fontText; font.pixelSize: Theme.font.small
                    color: Theme.secondaryLabel
                }
            }
        }
    }

    // ---------- toolbar ----------
    Item {
        id: toolbar
        anchors.left: sidebar.right; anchors.right: parent.right
        height: Theme.window.toolbarHeight
        MouseArea { anchors.fill: parent; onPressed: app.moveRequested(); onDoubleClicked: app.zoomRequested() }
        Rectangle { // glass capsule with back / forward
            id: nav
            x: 8; anchors.verticalCenter: parent.verticalCenter
            width: 72; height: 36; radius: 18
            color: Theme.dark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.03)
            border.color: Theme.dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.07)
            Rectangle { anchors.centerIn: parent; width: 1; height: 20; color: Theme.separator }
            Row {
                anchors.fill: parent
                Repeater {
                    model: [{ g: "chevron_left", d: -1 }, { g: "chevron_right", d: 1 }]
                    Item {
                        required property var modelData
                        readonly property bool can: modelData.d < 0 ? app.historyPos > 0 : app.historyPos < app.history.length - 1
                        width: 36; height: 36
                        Text {
                            anchors.centerIn: parent
                            text: modelData.g; font.family: Theme.fontGlyph; font.pixelSize: 26
                            color: parent.can ? Theme.label : Theme.tertiaryLabel
                        }
                        MouseArea { anchors.fill: parent; onClicked: app.go(modelData.d) }
                    }
                }
            }
        }
        MacText {
            anchors.left: nav.right; anchors.leftMargin: 13; anchors.verticalCenter: parent.verticalCenter
            text: app.current.title
            font.family: Theme.fontDisplay; font.pixelSize: Theme.font.title; weight: Font.Bold
            color: Theme.label
        }
    }

    // ---------- content ----------
    Flickable {
        id: flick
        anchors.left: sidebar.right; anchors.right: parent.right
        anchors.top: toolbar.bottom; anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        clip: true
        contentHeight: pane.height + 2 * Theme.content.padding
        boundsBehavior: Flickable.StopAtBounds
        Loader {
            id: pane
            x: Math.max(Theme.content.padding, (flick.width - width) / 2)
            y: 4
            width: Math.min(Theme.content.maxWidth, flick.width - 2 * Theme.content.padding)
            source: "panes/" + app.current.file + ".qml"
            onSourceChanged: flick.contentY = 0
        }
    }
}
