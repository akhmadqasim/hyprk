import QtQuick
import "controls"
import "HyprK"
import "Panes.js" as Panes

// The whole System Settings UI. Hosts (main.qml for `qml`, shell.qml for
// Quickshell) give it a window and handle the window signals.
Item {
    id: app
    // the account row plus the group break after it (Family, the second row of that group, is not drawn)
    readonly property int accountHeight: Theme.sidebar.accountHeight + Theme.sidebar.groupGap
    property bool windowActive: Window.active   // forced on for snapshots
    Binding { target: Theme; property: "windowActive"; value: app.windowActive }
    Binding { target: Tokens; property: "windowActive"; value: app.windowActive }
    onSnapshotPathChanged: if (snapshotPath !== "") windowActive = true
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
            const from = AppState.hasBattery ? "energy" : "battery";
            const to = AppState.hasBattery ? "battery" : "energy";
            app.history = app.history.map(id => id === from ? to : id);
            if (app.currentId === from) app.currentId = to;
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

        MouseArea { // dragging the empty top of the sidebar moves the window
            width: parent.width; height: Theme.window.toolbarHeight
            onPressed: app.moveRequested()
        }
        TrafficLights {
            x: Theme.lights.left
            y: (Theme.window.toolbarHeight - Tokens.lights.size) / 2
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
            anchors.top: parent.top; anchors.topMargin: Theme.sidebar.listTop
            anchors.bottom: parent.bottom; anchors.bottomMargin: 8
            x: Theme.sidebar.rowMargin; width: parent.width - 2 * Theme.sidebar.rowMargin
            clip: true
            boundsBehavior: Flickable.StopAtBounds
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
                if (y - Theme.sidebar.rowHeight < contentY || y > contentY + height) positionViewAtIndex(i, ListView.Contain);
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
                readonly property bool emphasized: app.windowActive && !search.inputFocus
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
                        glyph: d.modelData.glyph; iconId: d.modelData.id
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
                             : app.windowActive ? Theme.label : Theme.sidebar.labelInactive
                    }
                    MouseArea { anchors.fill: parent; onClicked: app.open(d.modelData.id) }
                }
            }
        }
    }

    Component {
        id: accountCard
        Item {
            width: list.width; height: app.accountHeight
            Rectangle {
                id: avatar
                x: 6; y: (Theme.sidebar.accountHeight - height) / 2   // the account button starts at window x 16
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
                anchors.left: avatar.right; anchors.leftMargin: 9; anchors.verticalCenter: avatar.verticalCenter
                spacing: 1
                MacText {
                    text: AppState.userName
                    weight: Typography.semibold
                    color: Theme.label
                }
                Text {
                    text: "Local Account"
                    font: Typography.subheadline
                    color: Theme.secondaryLabel
                }
            }
        }
    }

    // ---------- toolbar ----------
    // no fill and no glass: only the back/forward capsule is drawn (macOS 27.2.1, MAC-ANSWERS.md Q9.2)
    Item {
        id: toolbar
        anchors.left: sidebar.right; anchors.right: parent.right
        height: Theme.window.toolbarHeight
        MouseArea { anchors.fill: parent; onPressed: app.moveRequested(); onDoubleClicked: app.zoomRequested() }
        ToolbarPlatter { // back / forward share one 74 x 36 capsule with a 1 x 20 divider (27.2.1)
            id: nav
            x: 8; anchors.verticalCenter: parent.verticalCenter   // 8 pt after the sidebar (27.2.1 Settings shot)
            width: Tokens.toolbar.navWidth; height: Tokens.toolbar.platterHeight
            Rectangle { anchors.centerIn: parent; width: 1; height: Tokens.toolbar.dividerHeight; color: Tokens.toolbar.separator }
            Row {
                anchors.fill: parent
                Repeater {
                    model: [{ g: "chevron_left", d: -1 }, { g: "chevron_right", d: 1 }]
                    Item {
                        required property var modelData
                        readonly property bool can: modelData.d < 0 ? app.historyPos > 0 : app.historyPos < app.history.length - 1
                        width: nav.width / 2; height: nav.height
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
            font: Typography.toolbarTitle   // 15 Semibold, measured on 27.2.1 (was 16 Bold)
            color: Theme.toolbarTitle
        }
    }

    // ---------- content ----------
    Flickable {
        id: flick
        anchors.left: sidebar.right; anchors.right: parent.right
        anchors.top: toolbar.bottom; anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        clip: true
        contentHeight: pane.y + pane.height + Theme.content.padding
        boundsBehavior: Flickable.StopAtBounds
        Loader {
            id: pane
            x: Math.max(Theme.content.padding, (flick.width - width) / 2)
            y: Theme.content.top
            width: Math.min(Theme.content.maxWidth, flick.width - 2 * Theme.content.padding)
            source: "panes/" + app.current.file + ".qml"
            onSourceChanged: flick.contentY = 0
        }
    }

    Rectangle { // scroll edge: a 0.5 pt hairline at y 52 from the first scrolled frame, no fade-in (Q-settings-04)
        visible: flick.contentY > 0
        x: flick.x; width: flick.width; y: toolbar.height
        height: 0.5
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
