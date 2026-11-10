import QtQuick
import Quickshell
import qs
import qs.components
import qs.services
import qs.HyprK
import "../lib/search.js" as Search
import "../lib/appcategories.js" as Cats

// "Applications" (macOS 27.2.1 Apps, MAC-ANSWERS.md R2): an ordinary window with traffic lights, the
// title and a search field in the toolbar, a category bar and an icon grid. Created on open and
// destroyed on close (shell.qml LazyLoader on AppsView.open); its open and close motion is the
// compositor's, as for any window. Esc closes it, typing searches, Return opens the first app.
// Layout numbers: AppsView.metrics (guessed until Q-dock-23..26 are answered).
FloatingWindow {
    id: win
    readonly property QtObject m: AppsView.metrics

    title: "Applications"
    implicitWidth: m.width
    implicitHeight: m.height
    minimumSize: Qt.size(m.minWidth, m.minHeight)
    color: Tokens.windowBackground

    property string query: ""
    property string category: ""        // "" = All
    readonly property var bar: [""].concat(Cats.present(Apps.sortedEntries))
    readonly property var apps: query !== "" ? Search.rank(Apps.visibleEntries, query, 200)
        : category === "" ? Apps.sortedEntries
        : Apps.sortedEntries.filter(e => Cats.groupOf(e.categories) === category)

    function launch(e) {
        Apps.launch(e, e.id);
        AppsView.close();
    }

    Item {
        id: root
        anchors.fill: parent
        focus: true
        Component.onCompleted: search.forceActiveFocus()
        Keys.onEscapePressed: AppsView.close()

        // ---- toolbar: lights, title, search; empty space drags the window ----
        Item {
            id: toolbar
            width: parent.width
            height: win.m.toolbarHeight
            DragHandler { target: null; onActiveChanged: if (active) win.startSystemMove() }
            TapHandler { onDoubleTapped: win.maximized = !win.maximized }

            TrafficLights {
                id: lights
                x: win.m.lightsX
                anchors.verticalCenter: parent.verticalCenter
                active: root.Window.active
                onCloseClicked: AppsView.close()
                onMinimizeClicked: win.minimized = true
                onZoomClicked: win.maximized = !win.maximized
            }
            Text {
                x: lights.x + lights.width + win.m.titleGap
                width: Math.max(0, field.x - x - 12)
                anchors.verticalCenter: parent.verticalCenter
                text: win.title
                elide: Text.ElideRight
                font.family: Theme.fontText
                font.pixelSize: win.m.titleSize
                font.weight: Font.DemiBold
                color: Tokens.label
            }
            ToolbarPlatter {
                id: field
                anchors.right: parent.right
                anchors.rightMargin: win.m.rightPad
                anchors.verticalCenter: parent.verticalCenter
                width: win.m.searchWidth
                height: win.m.searchHeight
                Symbol {
                    id: mag
                    x: 12
                    anchors.verticalCenter: parent.verticalCenter
                    name: "magnifyingglass"
                    size: 15
                    color: Tokens.secondaryLabel
                }
                TextInput {
                    id: search
                    MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton; cursorShape: Qt.IBeamCursor }   // TextInput sets no I-beam itself
                    anchors.left: mag.right
                    anchors.leftMargin: 6
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.fontText
                    font.pixelSize: Tokens.control.fontSize
                    color: Tokens.label
                    selectionColor: Qt.alpha(Tokens.accent, 0.35)
                    clip: true
                    onTextChanged: win.query = text
                    Keys.onEscapePressed: AppsView.close()
                    Keys.onReturnPressed: if (win.apps.length > 0) win.launch(win.apps[0])
                    Text {
                        visible: search.text === "" && !search.preeditText
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Search"
                        font: search.font
                        color: Tokens.secondaryLabel
                    }
                }
            }
        }

        // ---- category bar: centred, scrolls sideways when the window is too narrow for it ----
        Flickable {
            id: categories
            width: Math.min(pills.width, root.width - win.m.sidePad * 2)
            height: win.m.pillHeight
            anchors.horizontalCenter: parent.horizontalCenter
            y: toolbar.height + (win.m.barHeight - win.m.pillHeight) / 2
            contentWidth: pills.width
            interactive: pills.width > width
            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            opacity: win.query === "" ? 1 : 0.4      // a search looks in every category
            Row {
                id: pills
                spacing: win.m.pillSpacing
                Repeater {
                    model: win.bar
                    delegate: Rectangle {
                        id: pill
                        required property string modelData
                        readonly property bool selected: win.category === modelData
                        width: label.implicitWidth + win.m.pillPadding * 2
                        height: win.m.pillHeight
                        radius: height / 2
                        color: selected ? Tokens.control.fill : pm.containsMouse ? Tokens.toolbar.selection : "transparent"
                        Text {
                            id: label
                            anchors.centerIn: parent
                            text: pill.modelData === "" ? "All" : pill.modelData
                            font.family: Theme.fontText
                            font.pixelSize: win.m.pillText
                            font.weight: pill.selected ? Font.DemiBold : Font.Normal
                            color: pill.selected ? Tokens.label : Tokens.secondaryLabel
                        }
                        MouseArea {
                            id: pm
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: { win.category = pill.modelData; search.text = ""; grid.positionViewAtBeginning(); }
                        }
                    }
                }
            }
        }

        // ---- icon grid ----
        GridView {
            id: grid
            readonly property int columns: Math.max(1, Math.floor((root.width - win.m.sidePad * 2) / win.m.cellWidth))
            width: columns * win.m.cellWidth
            anchors.horizontalCenter: parent.horizontalCenter
            y: toolbar.height + win.m.barHeight + win.m.gridTop
            height: root.height - y
            cellWidth: win.m.cellWidth
            cellHeight: win.m.cellHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: win.apps
            delegate: Item {
                id: c
                required property var modelData
                width: win.m.cellWidth
                height: win.m.cellHeight
                AppIcon {
                    id: ic
                    y: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    size: win.m.iconSize
                    icon: c.modelData.icon
                    appId: c.modelData.id
                    opacity: cma.pressed ? 0.6 : 1
                }
                Text {
                    anchors.top: ic.bottom
                    anchors.topMargin: win.m.labelGap
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 8
                    horizontalAlignment: Text.AlignHCenter
                    text: c.modelData.name
                    elide: Text.ElideRight
                    font.family: Theme.fontText
                    font.pixelSize: win.m.labelSize
                    color: Tokens.label
                }
                MouseArea {
                    id: cma
                    anchors.fill: parent
                    onClicked: win.launch(c.modelData)
                }
            }
        }
        Text {
            visible: win.apps.length === 0
            anchors.centerIn: grid
            text: "No Results"
            font.family: Theme.fontText
            font.pixelSize: 15
            color: Tokens.secondaryLabel
        }
    }
}
