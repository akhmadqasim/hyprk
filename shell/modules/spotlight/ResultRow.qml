import QtQuick
import Quickshell
import qs
import qs.HyprK
import qs.components

// One Spotlight result row for the browse modes: icon, title, optional subtitle,
// optional right accessory (quick key badge, time). Icon sources, first set wins:
// image (file path, clipboard images), appIcon (+ appId), themeIcon (freedesktop name,
// falls back to `symbol`), symbol (symbols.js glyph).
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
    signal hovered()
    signal accessoryClicked()

    height: Theme.spotlight.rowHeight

    Rectangle {
        visible: row.selected
        anchors.fill: parent
        radius: Theme.spotlight.rowRadius
        color: Theme.spotlight.selection
    }

    Item {
        id: ic
        x: Theme.spotlight.rowInset
        width: Theme.spotlight.rowIcon
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
        AppIcon {
            anchors.fill: parent
            visible: row.appIcon !== "" && row.image === ""
            size: parent.width
            icon: row.appIcon
            appId: row.appId
        }
        // glyph in a soft tile, like macOS action rows
        Rectangle {
            anchors.fill: parent
            visible: row.image === "" && row.appIcon === "" && ic.themed === ""
            radius: width * 0.26
            color: Theme.spotlight.field
            Symbol {
                anchors.centerIn: parent
                name: row.symbol
                size: parent.width * 0.56
                color: Theme.color.secondaryLabel
            }
        }
    }

    Column {
        anchors.left: ic.right
        anchors.leftMargin: Theme.spotlight.textGap
        anchors.right: acc.left
        anchors.rightMargin: Theme.spotlight.textGap
        anchors.verticalCenter: parent.verticalCenter
        Text {
            width: parent.width
            text: row.title
            elide: Text.ElideRight
            maximumLineCount: 1
            font: Typography.font(Theme.font.spotlightRow)
            color: Theme.color.label
        }
        Text {
            width: parent.width
            visible: row.subtitle !== ""
            text: row.subtitle
            elide: Text.ElideMiddle
            font: Typography.font(Theme.font.spotlightHeader)
            color: Theme.color.secondaryLabel
        }
    }

    Item {
        id: acc
        anchors.right: parent.right
        anchors.rightMargin: Theme.spotlight.rowInset + 4
        anchors.verticalCenter: parent.verticalCenter
        width: accText.text ? accText.implicitWidth + (row.badge ? 16 : 0) : 0
        height: accText.implicitHeight + (row.badge ? 6 : 0)
        z: 1
        Rectangle {
            visible: row.badge && accText.text !== ""
            anchors.fill: parent
            radius: height / 2
            color: "transparent"
            border.width: 1
            border.color: Theme.color.separator
        }
        Text {
            id: accText
            anchors.centerIn: parent
            text: row.accessory
            font: Typography.font(Theme.font.spotlightHeader, row.badge ? Typography.medium : Typography.regular)
            color: Theme.color.secondaryLabel
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
        hoverEnabled: true
        onEntered: row.hovered()
        onClicked: row.clicked()
    }
}
