import QtQuick
import HyprK
import "lib/symbols.js" as Symbols

// Unified toolbar over the content area: back/forward, title, view switcher, group,
// actions (share, tag, more) and search. Empty space drags the window. The strip itself has no fill and
// no glass; only the capsules are drawn (macOS 27.2.1, MAC-ANSWERS.md Q9.2).
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
            implicitWidth: (Theme.toolbar.navWidth - 1) / 2
            icon: "chevron.left"
            enabled: root.browser.canGoBack
            onClicked: root.browser.back()
        }
        Rectangle { width: 1; height: Theme.toolbar.dividerHeight; anchors.verticalCenter: parent.verticalCenter; color: Theme.color.toolbarSeparator }
        ToolButton {
            implicitWidth: (Theme.toolbar.navWidth - 1) / 2
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
        color: root.window.active ? Theme.color.title : Theme.color.titleInactive
        font: Typography.toolbarTitle   // 15 Semibold (27.2.1)
    }

    Capsule {
        id: views
        anchors.right: group.left
        anchors.rightMargin: Theme.toolbar.gap
        y: Theme.toolbar.capsuleY
        visible: root.width > 524
        SegmentedControl {
            id: viewSwitcher
            readonly property var modes: ["icons", "list", "columns", "gallery"]
            readonly property string iconHex: Qt.rgba(Theme.color.toolbarIcon.r, Theme.color.toolbarIcon.g, Theme.color.toolbarIcon.b, 1).toString()
            segmentWidth: Theme.toolbar.viewsWidth / 4
            width: implicitWidth
            height: Theme.toolbar.capsuleHeight
            iconSize: Theme.toolbar.iconSize
            iconOpacity: Theme.color.toolbarIcon.a
            // a separator at every boundary, hidden next to the selected segment: with Columns selected
            // the 27.2.1 Finder shows only the one between Icons and List
            separatorColor: Theme.color.toolbarSeparator
            separatorHeight: Theme.toolbar.segmentSeparator
            selectionInset: Theme.toolbar.segmentInsetY
            selectionInsetX: Theme.toolbar.segmentInsetX
            trackRadius: height / 2                       // the glass capsule and its inner pill (Q-finder-11)
            selectionRadius: height / 2 - Theme.toolbar.segmentInsetY
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
        // 27.2.1: 46 pt capsule, group glyph centred at 17, chevron at 36.5
        padding: 3
        visible: root.width > 622
        ToolButton {
            id: groupButton
            implicitWidth: 28
            icon: "group"
            onClicked: root.groupRequested(groupButton)
        }
        Symbol {
            anchors.verticalCenter: parent.verticalCenter
            name: "chevron.down"
            weight: "semibold"
            size: 11
            color: Theme.color.toolbarIcon
        }
        Item { width: Theme.toolbar.groupWidth - 6 - 28 - 11; height: 1 }
    }

    Capsule {
        id: actions
        anchors.right: search.left
        anchors.rightMargin: Theme.toolbar.gap
        y: Theme.toolbar.capsuleY
        visible: root.width > 458
        ToolButton {
            implicitWidth: Theme.toolbar.actionsWidth / 3
            icon: "share"
            enabled: root.browser.selectedCount > 0
            onClicked: root.browser.openSelection()
        }
        ToolButton {
            id: tagButton
            implicitWidth: Theme.toolbar.actionsWidth / 3
            icon: "tag"
            enabled: root.browser.selectedCount > 0 && root.browser.userFiles
            onClicked: root.tagRequested(tagButton)
        }
        ToolButton {
            id: more
            implicitWidth: Theme.toolbar.actionsWidth / 3
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
            iconWeight: "medium"       // 13 pt, .large, medium (names.json finder.toolbarGlyph, likely)
            iconScale: "large"
            iconPointSize: 13
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
                selectionColor: Theme.color.textSelection
                selectedTextColor: Theme.color.label
                font: Typography.body
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
