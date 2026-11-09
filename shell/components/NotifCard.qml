import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs
import qs.services
import "../lib/clock.js" as Clock

// One notification (banner and Notification Center): app icon, bold title,
// body, relative time, close button on hover.
Item {
    id: card

    property int nid: -1
    property string appName
    property string appIcon
    property string image
    property string summary
    property string body
    property double time: Date.now()
    property real sx: 0
    property real sy: 0
    property bool shadow: true
    property int stacked: 0             // >0: draw stacked cards behind (collapsed group)

    signal clicked()
    signal closed()

    implicitWidth: Theme.notif.width
    implicitHeight: Math.max(Theme.notif.iconSize, textCol.implicitHeight) + Theme.notif.padding * 2

    // cards peeking below a collapsed group
    Repeater {
        model: Math.min(card.stacked, 2)
        Rectangle {
            required property int index
            x: (index + 1) * 8
            width: card.width - (index + 1) * 16
            y: card.height - Theme.notif.radius + (index + 1) * Theme.notif.stackPeek
            height: Theme.notif.radius
            radius: Theme.notif.radius
            color: Theme.solidMaterial ? Theme.glass.solid : Theme.glass.tint
            opacity: 0.85 - index * 0.25
        }
    }

    Glass {
        anchors.fill: parent
        radius: Theme.notif.radius
        sx: card.sx
        sy: card.sy
        shadow: card.shadow
    }

    // icon: desktop icon, else notification image, else generic
    IconImage {
        id: icon
        x: Theme.notif.padding
        anchors.verticalCenter: parent.verticalCenter
        implicitSize: Theme.notif.iconSize
        source: {
            const entry = Apps.entryFor(card.appName) || Apps.entryFor(card.appIcon);
            if (card.appIcon && card.appIcon.startsWith("/")) return "file://" + card.appIcon;
            if (card.appIcon && card.appIcon.startsWith("file://")) return card.appIcon;
            return Apps.iconUrl(entry ? entry.icon : card.appIcon, entry ? entry.id : card.appName);
        }
    }

    ColumnLayout {
        id: textCol
        anchors.left: icon.right
        anchors.leftMargin: Theme.notif.iconGap
        anchors.right: parent.right
        anchors.rightMargin: Theme.notif.padding
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1

        RowLayout {
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: card.summary || card.appName
                elide: Text.ElideRight
                font.family: Theme.fontText
                font.pixelSize: Theme.font.notifTitle
                font.weight: Theme.font.semibold
                color: Theme.color.label
            }
            Text {
                text: Clock.relative(card.time, Notifs.now)
                font.family: Theme.fontText
                font.pixelSize: Theme.font.notifTime
                color: Theme.color.secondaryLabel
            }
        }
        Text {
            Layout.fillWidth: true
            visible: text !== ""
            text: card.body
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            maximumLineCount: Theme.notif.maxBodyLines
            elide: Text.ElideRight
            font.family: Theme.fontText
            font.pixelSize: Theme.font.notifBody
            color: Theme.color.label
        }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        onClicked: card.clicked()
    }

    // close button (top-left corner, macOS style)
    Rectangle {
        visible: hover.containsMouse || closeMa.containsMouse
        x: -6
        y: -6
        width: Theme.notif.closeSize
        height: width
        radius: width / 2
        color: Theme.solidMaterial ? Theme.glass.solid : Theme.glass.tintStrong
        border.width: 1
        border.color: Theme.glass.hairline
        Symbol { anchors.centerIn: parent; name: "xmark"; size: 10; color: Theme.color.secondaryLabel }
        MouseArea { id: closeMa; anchors.fill: parent; hoverEnabled: true; onClicked: card.closed() }
    }
}
