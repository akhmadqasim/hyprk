import QtQuick
import QtQuick.Controls.Basic
import "lib/files.js" as Files

// Gallery view: large preview of the focused item over a thumbnail strip.
Item {
    id: root

    required property var browser
    signal contextMenu(var entry, point pos)
    readonly property int columns: 1

    function ensureVisible(i) { strip.positionViewAtIndex(i, ListView.Contain); }

    readonly property var focused: {
        const i = browser.cursor >= 0 ? browser.cursor : 0;
        return browser.entries.length > i ? browser.entries[i] : null;
    }

    Item {
        id: stage
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: caption.top
        anchors.margins: 20

        Image {
            anchors.fill: parent
            visible: root.focused !== null && Files.isImage(root.focused)
            source: visible ? Files.fileUrl(root.focused.path) : ""
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            sourceSize: Qt.size(width * 2, height * 2)
        }
        FileIcon {
            visible: root.focused !== null && !Files.isImage(root.focused)
            anchors.centerIn: parent
            entry: root.focused || ({ name: "", isDir: false, mime: "" })
            size: Math.min(parent.width, parent.height, 256)
        }
        EntryMouseArea {
            anchors.fill: parent
            browser: root.browser
            entry: root.focused
            index: Math.max(0, root.browser.cursor)
            onContextMenu: (e, pos) => root.contextMenu(e, pos)
        }
    }

    TextLabel {
        id: caption
        anchors.bottom: strip.top
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 40
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideMiddle
        text: root.focused ? root.focused.name : ""
        color: Theme.color.label
        font.pixelSize: 15
        weight: Font.DemiBold
    }

    ListView {
        id: strip
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 20, count * 70)
        height: 70
        orientation: ListView.Horizontal
        clip: true
        spacing: 4
        model: root.browser.entries
        boundsBehavior: Flickable.StopAtBounds
        currentIndex: root.browser.cursor
        highlightFollowsCurrentItem: false
        onCurrentIndexChanged: if (currentIndex >= 0) positionViewAtIndex(currentIndex, ListView.Contain)

        delegate: Rectangle {
            id: thumb
            required property var modelData
            required property int index
            readonly property bool selected: root.browser.isSelected(modelData.path)
            width: 66
            height: 66
            radius: 8
            color: selected ? Theme.color.iconSelection : "transparent"
            border.width: selected ? 2 : 0
            border.color: Theme.color.accent
            FileIcon {
                anchors.centerIn: parent
                entry: thumb.modelData
                size: 52
            }
            EntryMouseArea {
                anchors.fill: parent
                browser: root.browser
                entry: thumb.modelData
                index: thumb.index
                onContextMenu: (e, pos) => root.contextMenu(e, pos)
            }
        }
    }
}
