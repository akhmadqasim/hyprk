import QtQuick
import "controls"
import "HyprK"
import "Panes.js" as Panes

// The whole System Settings UI. Hosts (main.qml for `qml`, shell.qml for
// Quickshell) give it a window and handle the window signals.
Item {
    // wallpaper mean for the sidebar chameleon tint (computed once per wallpaper)
    WallpaperTint {
        path: AppState.wallpaperImage || Backend.root + "/themes/wallpapers/png/DefaultAerial.png"
        onTintChanged: Theme.chameleon = tint
    }
    id: app
    // the account row, the Family row and the group break after them (27.2.1: the first pane row's top at y 188,
    // 90 below the list top; *-light.png have both rows blanked flat, so the Family row's look is not measured)
    readonly property int accountHeight: Theme.sidebar.accountHeight + Theme.sidebar.rowHeight + Theme.sidebar.groupGap
    property bool windowActive: Window.active   // forced on for snapshots
    Binding { target: Theme; property: "windowActive"; value: app.windowActive }
    Binding { target: Tokens; property: "windowActive"; value: app.windowActive }
    onSnapshotPathChanged: if (snapshotPath !== "") windowActive = true
    onWindowActiveChanged: if (windowActive) AppState.autoSync()   // Appearance > Auto after a sleep
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
            boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
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
            Item { // Family: a row like a pane row (people glyph in a grey circle, label); no pane behind it here
                y: Theme.sidebar.accountHeight
                width: parent.width; height: Theme.sidebar.rowHeight
                Rectangle {
                    width: Theme.sidebar.iconSize; height: width; radius: width / 2
                    x: Theme.sidebar.iconCenter - width / 2; anchors.verticalCenter: parent.verticalCenter
                    color: Theme.tile.gray
                    Text { anchors.centerIn: parent; text: "group"; font.family: Theme.fontGlyph; font.pixelSize: parent.width * 0.7; color: "white" }
                }
                MacText {
                    x: Theme.sidebar.labelLeft; anchors.verticalCenter: parent.verticalCenter
                    text: "Family"
                    size: Theme.sidebar.fontSize
                    color: app.windowActive ? Theme.label : Theme.sidebar.labelInactive
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
                Text {
                    text: "Local Account"
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
        contentHeight: pane.y + pane.height + Theme.content.padding   // bottom margin 20
        boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
        RubberBand { flickable: flick }
        Loader {
            id: pane
            x: Math.max(Theme.content.padding, (flick.width - width) / 2)
            y: Theme.window.toolbarHeight + Theme.content.top
            width: Math.min(Theme.content.maxWidth, flick.width - 2 * Theme.content.padding)
            source: "panes/" + app.current.file + ".qml"
            onSourceChanged: { scroller._silent = true; flick.contentY = 0; scroller._silent = false; scroller.hide(); }
        }
    }
    Rectangle { // the toolbar strip over scrolled content (scroll edge effect; no blur, see Theme.scrollEdgeFade*)
        visible: flick.contentY > 0
        x: flick.x; width: flick.width; height: Theme.window.toolbarHeight
        topRightRadius: Theme.window.radius
        gradient: Gradient {
            GradientStop { position: 0; color: Qt.alpha(Theme.windowBg, Theme.scrollEdgeFadeTop) }
            GradientStop { position: 1; color: Qt.alpha(Theme.windowBg, Theme.scrollEdgeFadeBottom) }
        }
    }
    OverlayScrollbar {
        id: scroller
        objectName: "paneScroller"
        flickable: flick
        x: parent.width - Tokens.scroller.inset - width
        y: Theme.window.toolbarHeight + Tokens.scroller.inset
        height: parent.height - y - Tokens.scroller.inset
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
            relief: true   // the platter's own shading and edge (Tokens.toolbar.relief*, settings/appearance-*.png)
            x: 7.5; anchors.verticalCenter: parent.verticalCenter   // settings-toolbar-dark.png: sidebar line px 463, capsule 479..626
            width: Tokens.toolbar.navWidth; height: Tokens.toolbar.platterHeight
            Rectangle { anchors.centerIn: parent; width: 1; height: Tokens.toolbar.dividerHeight; color: Tokens.toolbar.separator }
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
        MacText {
            anchors.left: nav.right; anchors.leftMargin: 13; anchors.verticalCenter: parent.verticalCenter
            text: app.current.title
            font: Typography.toolbarTitle   // 15 Semibold, measured on 27.2.1 (was 16 Bold)
            color: Theme.toolbarTitle
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
