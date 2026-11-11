import QtQuick
import HyprK
import QtQuick.Controls.Basic
import Finder.Native
import "lib/files.js" as Files

// Quick Look panel: images and text inline, everything else as a large icon with info.
Rectangle {
    id: root

    property var entry: null
    // Q-finder-26: opens at 0.79 scale, centred, growing to 1 in 0.25 s ease-out (per frame .79 .85 .90 .93 .95 .97
    // .98 .98 .99 1 = OutQuint), no fade; closes by shrinking into the file's icon in about 0.18 s (curve not
    // measured: InOutQuad). closeTo: the icon's centre in the parent (Main passes the last press on an item).
    property point closeTo: Qt.point(x + width / 2, y + height / 2)
    property var cur: null   // the entry shown, kept while the close animation runs
    readonly property bool open: cur !== null
    readonly property bool isImage: open && Files.isImage(cur)
    readonly property bool isText: open && !isImage && Files.isText(cur)
    readonly property string text: isText ? FileOps.readText(cur.path, 65536) : ""
    signal closeRequested()

    onEntryChanged: {
        if (entry) {
            closeAnim.stop();
            cur = entry;
            zoom.xScale = zoom.yScale = 1; shift.x = shift.y = 0;
            if (!Tokens.reduceMotion) openAnim.restart();
        } else if (cur) {
            if (Tokens.reduceMotion) cur = null; else closeAnim.restart();
        }
    }
    transform: [
        Scale { id: zoom; origin.x: root.width / 2; origin.y: root.height / 2 },
        Translate { id: shift }
    ]
    NumberAnimation { id: openAnim; target: zoom; properties: "xScale,yScale"; from: 0.79; to: 1; duration: 250; easing.type: Easing.OutQuint }
    ParallelAnimation {
        id: closeAnim
        NumberAnimation { target: zoom; properties: "xScale,yScale"; to: 64 / Math.max(64, root.width); duration: 180; easing.type: Easing.InOutQuad }
        NumberAnimation { target: shift; property: "x"; to: root.closeTo.x - (root.x + root.width / 2); duration: 180; easing.type: Easing.InOutQuad }
        NumberAnimation { target: shift; property: "y"; to: root.closeTo.y - (root.y + root.height / 2); duration: 180; easing.type: Easing.InOutQuad }
        onFinished: root.cur = null
    }

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
        TextLabel {
            anchors.centerIn: parent
            width: parent.width - 200
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideMiddle
            text: root.open ? root.cur.name : ""
            color: Theme.color.label
            size: Theme.font.preview
            weight: Typography.semibold
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
                font: Typography.font(Theme.font.preview)
            }
            TapHandler { id: openTap; onTapped: if (root.open) FileOps.open(root.cur.path) }
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
            source: root.isImage ? Files.fileUrl(root.cur.path) : ""
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
                entry: root.cur || ({ name: "", isDir: false, mime: "" })
                size: 160
            }
            TextLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.open ? root.cur.name : ""
                color: Theme.color.label
                size: 17
                weight: Typography.semibold
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.open ? root.cur.kind + " – " + Files.formatSize(root.cur.size, root.cur.isDir) : ""
                color: Theme.color.secondaryLabel
                font: Typography.font(Theme.font.preview)
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.open ? "Modified " + Files.formatDate(root.cur.modified) : ""
                color: Theme.color.secondaryLabel
                font: Typography.font(Theme.font.preview)
            }
        }
    }
}
