import QtQuick
import Quickshell
import qs
import qs.HyprK
import qs.components

// One Spotlight list row, macOS 27.2.1 (MAC-ANSWERS.md Q-panels-19, -25): 62 tall, the width of the selection pill
// (panel x 12 .. width - 13). Icon 36 at x 13 (25 from the panel edge), title SF 17 regular white at x 68 (80),
// second line SF 15 regular grey. Selected: a white ~6 % pill, r 22. Hovering selects nothing (the Mac shows no
// hover fill). Actions carry a trailing quick key badge (Actions shot: grey capsule, white text).
Item {
    id: row

    property string title
    property string subtitle
    property string accessory
    property bool badge: false           // accessory drawn as a capsule (quick keys), clickable
    property bool selected: false
    property string image
    property string appIcon
    property string appId
    property string themeIcon
    property string symbol: "doc"
    signal clicked()
    signal accessoryClicked()

    height: Theme.spotlight.rowH

    Rectangle {
        visible: row.selected
        anchors.fill: parent
        radius: Theme.spotlight.pillRadius
        color: Theme.spotlight.pill
    }

    Item {
        id: ic
        x: Theme.spotlight.rowIconX
        width: Theme.spotlight.rowIconSize
        height: width
        anchors.verticalCenter: parent.verticalCenter

        readonly property string themed: row.themeIcon ? Quickshell.iconPath(row.themeIcon, true) : ""
        Image {
            anchors.fill: parent
            visible: row.image !== "" || ic.themed !== ""
            source: row.image ? "file://" + row.image : ic.themed
            sourceSize: Qt.size(width * 2, height * 2)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
        }
        // the 36 is the app icon's art (36.5 measured); its tile is larger by Theme.appIcon.body
        AppIcon {
            anchors.centerIn: parent
            width: parent.width / Theme.appIcon.body
            height: width
            visible: row.appIcon !== "" && row.image === ""
            size: width
            icon: row.appIcon
            appId: row.appId
        }
        Symbol {
            anchors.centerIn: parent
            visible: row.image === "" && row.appIcon === "" && ic.themed === ""
            name: row.symbol
            size: parent.width * 0.7
            color: Theme.spotlight.secondary
        }
    }

    Column {
        x: Theme.spotlight.rowTextX
        width: acc.x - 12 - x
        anchors.verticalCenter: parent.verticalCenter
        Text {
            width: parent.width
            text: row.title
            elide: Text.ElideRight
            maximumLineCount: 1
            font: Typography.font(Theme.spotlight.rowTitle)
            color: Theme.spotlight.text
        }
        Text {
            width: parent.width
            visible: row.subtitle !== ""
            text: row.subtitle
            elide: Text.ElideMiddle
            maximumLineCount: 1
            font: Typography.font(Theme.spotlight.rowSub)
            color: Theme.spotlight.secondary
        }
    }

    Item {
        id: acc
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: accText.text ? accText.implicitWidth + (row.badge ? 16 : 0) : 0
        height: row.badge ? 18 : accText.implicitHeight
        z: 1
        Rectangle {
            visible: row.badge && accText.text !== ""
            anchors.fill: parent
            radius: 5
            color: Theme.spotlight.tokenFill
        }
        Text {
            id: accText
            anchors.centerIn: parent
            text: row.accessory
            font: Typography.font(row.badge ? 12 : Theme.spotlight.headerSize, row.badge ? Typography.medium : Typography.regular)
            color: row.badge ? Theme.spotlight.text : Theme.spotlight.secondary
        }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            enabled: row.badge
            onClicked: row.accessoryClicked()
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: row.clicked()
    }
}
