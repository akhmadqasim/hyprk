import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs
import qs.components
import qs.services
import "../lib/search.js" as Search

// "Apps" view (macOS 27 replacement for Launchpad): centered glass panel with
// a search header and a paged icon grid. Type to filter, Esc or click outside closes.
PanelWindow {
    id: lp

    required property var modelData
    screen: modelData

    readonly property bool shown: Panels.open === "launchpad"
    visible: shown
    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.namespace: "hyprk-launchpad"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property string query: ""
    readonly property var apps: query === ""
        ? Apps.entries.filter(e => !e.noDisplay).slice().sort((a, b) => a.name.localeCompare(b.name))
        : Search.rank(Apps.entries, query, 200)
    readonly property int rows: Math.max(1, Math.floor((panel.height - Theme.launchpad.headerHeight - 14 - 28) / Theme.launchpad.cellHeight))
    readonly property int perPage: Theme.launchpad.columns * rows
    readonly property int pages: Math.max(1, Math.ceil(apps.length / perPage))
    property int page: 0

    onShownChanged: {
        search.text = "";
        page = 0;
        if (shown) search.forceActiveFocus();
    }
    onQueryChanged: page = 0

    function launch(e) {
        Apps.launch(e, e.id);
        Panels.close();
    }

    MouseArea { anchors.fill: parent; onPressed: Panels.close() }

    Item {
        id: panel
        width: Math.round(lp.width * Theme.launchpad.widthFraction)
        height: Math.round(lp.height * Theme.launchpad.heightFraction)
        x: (lp.width - width) / 2
        y: (lp.height - height) / 2 - Theme.menuBar.height
        scale: lp.shown ? 1 : 0.96
        Behavior on scale { NumberAnimation { duration: Theme.anim.normal; easing.type: Theme.anim.easing } }

        Glass {
            anchors.fill: parent
            radius: Theme.launchpad.radius
            sx: panel.x
            sy: panel.y
            tint: Theme.glass.tint
        }
        MouseArea {
            anchors.fill: parent
            onWheel: w => lp.page = Math.max(0, Math.min(lp.pages - 1, lp.page + (w.angleDelta.y < 0 || w.angleDelta.x < 0 ? 1 : -1)))
        }

        // header: App Store-like glyph + search field
        Item {
            id: header
            width: parent.width
            height: Theme.launchpad.headerHeight
            Symbol {
                id: mg
                x: Theme.launchpad.padding
                anchors.verticalCenter: parent.verticalCenter
                name: "magnifyingglass"
                size: 18
                color: Theme.color.secondaryLabel
            }
            TextInput {
                id: search
                anchors.left: mg.right
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: Theme.launchpad.padding
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.font.launchpadSearch
                color: Theme.color.label
                selectionColor: Theme.color.accent
                clip: true
                onTextChanged: lp.query = text
                Keys.onEscapePressed: Panels.close()
                Keys.onReturnPressed: if (lp.apps.length > 0) lp.launch(lp.apps[0])
                Keys.onRightPressed: lp.page = Math.min(lp.pages - 1, lp.page + 1)
                Keys.onLeftPressed: lp.page = Math.max(0, lp.page - 1)
                Text {
                    visible: search.text === ""
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Search Apps"
                    font: search.font
                    color: Theme.color.tertiaryLabel
                }
            }
            Rectangle {
                anchors.bottom: parent.bottom
                x: Theme.launchpad.padding
                width: parent.width - Theme.launchpad.padding * 2
                height: 1
                color: Theme.color.separator
            }
        }

        Grid {
            id: grid
            x: Theme.launchpad.padding
            y: header.height + 14
            columns: Theme.launchpad.columns
            readonly property real cellWidth: (panel.width - Theme.launchpad.padding * 2) / Theme.launchpad.columns
            Repeater {
                model: lp.apps.slice(lp.page * lp.perPage, (lp.page + 1) * lp.perPage)
                delegate: Item {
                    id: c
                    required property var modelData
                    width: grid.cellWidth
                    height: Theme.launchpad.cellHeight
                    IconImage {
                        id: ic
                        anchors.horizontalCenter: parent.horizontalCenter
                        implicitSize: Theme.launchpad.iconSize
                        source: Apps.iconUrl(c.modelData.icon, c.modelData.id)
                        asynchronous: true
                        mipmap: true
                        opacity: cma.pressed ? 0.6 : 1
                    }
                    Text {
                        anchors.top: ic.bottom
                        anchors.topMargin: 4
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width - 8
                        horizontalAlignment: Text.AlignHCenter
                        text: c.modelData.name
                        elide: Text.ElideRight
                        font.family: Theme.fontText
                        font.pixelSize: Theme.font.launchpadLabel
                        color: Theme.color.label
                    }
                    MouseArea {
                        id: cma
                        anchors.fill: parent
                        onClicked: lp.launch(c.modelData)
                    }
                }
            }
        }

        // page dots
        Row {
            visible: lp.pages > 1
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12
            spacing: 8
            Repeater {
                model: lp.pages
                Rectangle {
                    required property int index
                    width: 7; height: 7; radius: 3.5
                    color: index === lp.page ? Theme.color.label : Theme.color.tertiaryLabel
                    MouseArea { anchors.fill: parent; anchors.margins: -4; onClicked: lp.page = parent.index }
                }
            }
        }
    }
}
