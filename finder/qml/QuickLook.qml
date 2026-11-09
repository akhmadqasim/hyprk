import QtQuick
import QtQuick.Controls.Basic
import Finder.Native
import "lib/files.js" as Files

// Quick Look panel: images and text inline, everything else as a large icon with info.
Rectangle {
    id: root

    property var entry: null
    readonly property bool open: entry !== null
    readonly property bool isImage: open && Files.isImage(entry)
    readonly property bool isText: open && !isImage && Files.isText(entry)
    readonly property string text: isText ? FileOps.readText(entry.path, 65536) : ""
    signal closeRequested()

    visible: open
    radius: 16
    color: Theme.color.previewPanel
    border.width: 1
    border.color: Theme.dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.14)

    // swallow clicks so they don't reach the views below
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; onWheel: wheel => wheel.accepted = true }

    Item {
        id: bar
        width: parent.width
        height: 44
        Rectangle {
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 26; height: 26; radius: 13
            color: closeTap.pressed ? Theme.color.capsuleSelected : "transparent"
            Symbol { anchors.centerIn: parent; name: "xmark"; size: 14; color: Theme.color.toolbarIcon }
            TapHandler { id: closeTap; onTapped: root.closeRequested() }
        }
        Text {
            anchors.centerIn: parent
            width: parent.width - 200
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideMiddle
            text: root.open ? root.entry.name : ""
            color: Theme.color.label
            font.family: Theme.fontText
            font.pixelSize: Theme.font.preview
            font.weight: Font.DemiBold
            font.variableAxes: ({ "wght": Font.DemiBold, "opsz": 17 })  // SF variable font: weight + text optical size
        }
        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            width: openLabel.implicitWidth + 24; height: 26; radius: 13
            color: openTap.pressed ? Theme.color.capsuleSelected : Theme.color.capsule
            border.width: 1
            border.color: Theme.color.capsuleBorder
            Text {
                id: openLabel
                anchors.centerIn: parent
                text: "Open"
                color: Theme.color.label
                font.family: Theme.fontText
                font.pixelSize: Theme.font.preview
            }
            TapHandler { id: openTap; onTapped: if (root.open) FileOps.open(root.entry.path) }
        }
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: bar.height
        anchors.margins: 12
        clip: true

        Image {
            anchors.fill: parent
            visible: root.isImage
            source: root.isImage ? "file://" + root.entry.path : ""
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            sourceSize: Qt.size(width * 2, height * 2)
        }

        ScrollView {
            anchors.fill: parent
            visible: root.isText
            TextArea {
                readOnly: true
                text: root.text
                wrapMode: TextEdit.Wrap
                color: Theme.color.label
                font.family: Theme.fontMono
                font.pixelSize: 12
                background: Rectangle { color: Theme.color.window; radius: 8 }
                padding: 12
            }
        }

        Column {
            visible: root.open && !root.isImage && !root.isText
            anchors.centerIn: parent
            spacing: 10
            FileIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                entry: root.entry || ({ name: "", isDir: false, mime: "" })
                size: 160
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.open ? root.entry.name : ""
                color: Theme.color.label
                font.family: Theme.fontText
                font.pixelSize: 17
                font.weight: Font.DemiBold
                font.variableAxes: ({ "wght": Font.DemiBold, "opsz": 17 })  // SF variable font: weight + text optical size
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.open ? root.entry.kind + " – " + Files.formatSize(root.entry.size, root.entry.isDir) : ""
                color: Theme.color.secondaryLabel
                font.family: Theme.fontText
                font.pixelSize: Theme.font.preview
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.open ? "Modified " + Files.formatDate(root.entry.modified) : ""
                color: Theme.color.secondaryLabel
                font.family: Theme.fontText
                font.pixelSize: Theme.font.preview
            }
        }
    }
}
