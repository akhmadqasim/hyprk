import QtQuick
import HyprK
import "lib/symbols.js" as Symbols

// Unified toolbar over the content area: back/forward, title, view switcher, group,
// actions (share, tag, more) and search. Empty space drags the window.
Item {
    id: root

    required property var browser
    required property var window
    property string view: "icons"
    property bool searching: false
    signal viewRequested(string view)
    signal moreRequested(Item anchor)
    signal groupRequested(Item anchor)
    signal tagRequested(Item anchor)

    height: Theme.toolbar.height

    // window drag / double-click zoom on empty toolbar space
    TapHandler {
        onDoubleTapped: root.window.visibility === Window.Maximized ? root.window.showNormal() : root.window.showMaximized()
    }
    DragHandler {
        target: null
        onActiveChanged: if (active) root.window.startSystemMove()
    }

    Capsule {
        id: nav
        x: Theme.toolbar.leftPad
        y: Theme.toolbar.capsuleY
        ToolButton {
            icon: "chevron.left"
            enabled: root.browser.canGoBack
            onClicked: root.browser.back()
        }
        Rectangle { width: 1; height: 24; anchors.verticalCenter: parent.verticalCenter; color: Theme.color.separator }
        ToolButton {
            icon: "chevron.right"
            enabled: root.browser.canGoForward
            onClicked: root.browser.forward()
        }
    }

    TextLabel {
        x: nav.x + nav.width + Theme.toolbar.titleGap
        width: Math.max(0, views.x - x - 12)
        anchors.verticalCenter: nav.verticalCenter
        text: root.browser.title
        elide: Text.ElideRight
        color: Theme.color.title
        font.pixelSize: Theme.font.title
        weight: Font.DemiBold
    }

    Capsule {
        id: views
        anchors.right: group.left
        anchors.rightMargin: Theme.toolbar.gap
        y: Theme.toolbar.capsuleY
        visible: root.width > 640
        SegmentedControl {
            id: viewSwitcher
            readonly property var modes: ["icons", "list", "columns", "gallery"]
            readonly property string iconHex: Qt.rgba(Theme.color.toolbarIcon.r, Theme.color.toolbarIcon.g, Theme.color.toolbarIcon.b, 1).toString()
            segmentWidth: Theme.toolbar.segment
            width: implicitWidth                   // as before: four 46px buttons and two 1px separators
            height: Theme.toolbar.capsuleHeight
            iconSize: Theme.toolbar.iconSize
            iconOpacity: Theme.color.toolbarIcon.a
            separatorBoundaries: [2, 3]            // before columns and before gallery
            separatorColor: Theme.color.separator
            separatorSpacing: 1
            separatorFade: false
            selectionInset: 4
            trackColor: "transparent"
            selectionColor: Theme.color.capsuleSelected
            model: modes.map(m => ({ icon: Symbols.url("view." + m, iconHex, "white") }))
            currentIndex: modes.indexOf(root.view)
            onActivated: i => root.viewRequested(modes[i])
            Accessible.name: "View"
        }
    }

    Capsule {
        id: group
        anchors.right: actions.left
        anchors.rightMargin: Theme.toolbar.gap
        y: Theme.toolbar.capsuleY
        padding: 4
        visible: root.width > 760
        ToolButton {
            id: groupButton
            implicitWidth: 34
            icon: "group"
            onClicked: root.groupRequested(groupButton)
        }
        Symbol {
            anchors.verticalCenter: parent.verticalCenter
            name: "chevron.down"
            size: 14
            color: Theme.color.toolbarIcon
        }
        Item { width: 6; height: 1 }
    }

    Capsule {
        id: actions
        anchors.right: search.left
        anchors.rightMargin: Theme.toolbar.gap
        y: Theme.toolbar.capsuleY
        visible: root.width > 560
        ToolButton {
            icon: "share"
            enabled: root.browser.selectedCount > 0
            onClicked: root.browser.openSelection()
        }
        ToolButton {
            id: tagButton
            icon: "tag"
            enabled: root.browser.selectedCount > 0 && root.browser.userFiles
            onClicked: root.tagRequested(tagButton)
        }
        ToolButton {
            id: more
            icon: "ellipsis"
            onClicked: root.moreRequested(more)
        }
    }

    Capsule {
        id: search
        anchors.right: parent.right
        anchors.rightMargin: Theme.toolbar.rightPad
        y: Theme.toolbar.capsuleY
        width: root.searching ? Theme.toolbar.searchWidth : Theme.toolbar.capsuleHeight
        Behavior on width { NumberAnimation { duration: Theme.anim.fast; easing.type: Theme.anim.easing } }

        ToolButton {
            icon: "magnifyingglass"
            onClicked: {
                root.searching = true;
                field.forceActiveFocus();
            }
        }
        Item {
            visible: root.searching
            width: search.width - Theme.toolbar.buttonWidth - 8
            height: Theme.toolbar.capsuleHeight
            TextInput {
                id: field
                MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton; cursorShape: Qt.IBeamCursor }   // TextInput sets no I-beam itself
                anchors.fill: parent
                verticalAlignment: TextInput.AlignVCenter
                clip: true
                color: Theme.color.label
                selectionColor: Theme.color.accent
                font.family: Theme.fontText
                font.pixelSize: Theme.font.list + 1
                text: root.browser.query
                onTextEdited: root.browser.query = text
                // Return/arrows must not reach the window's key handler (rename, cursor moves)
                Keys.onReturnPressed: root.window.focusContent()
                Keys.onEnterPressed: root.window.focusContent()
                Keys.onUpPressed: {}
                Keys.onDownPressed: {}
                Keys.onEscapePressed: {
                    root.browser.query = "";
                    root.searching = false;
                }
                Text {
                    visible: !field.text
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Search"
                    color: Theme.color.tertiaryLabel
                    font: field.font
                }
            }
        }
    }

    function focusSearch() {
        searching = true;
        field.forceActiveFocus();
    }
}
