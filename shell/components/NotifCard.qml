import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs
import qs.services
import "../lib/clock.js" as Clock

// One notification (banner and Notification Center), macOS 27 layout: app icon
// (or the sender's picture with a small app badge), bold title + relative time,
// body. Hover shows a round close button on the top-left corner; a drag to the
// right swipes it away. `stacked` draws the edges of the cards behind a collapsed
// group as plain QML strips: the compositor glass merges touching shapes into
// one box, so real glass cards behind would just make this card taller.
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
    property int stacked: 0             // >0: edges of stacked cards below (collapsed group), max 2 drawn
    property bool glass: true           // false while the card sits behind another (its region would merge)
    property real contentOpacity: 1
    property bool swipeable: true
    readonly property bool hovered: hoverH.hovered || closeMa.containsMouse
    readonly property real swipeX: slide.x

    signal clicked()
    signal closed()                     // close button
    signal swiped()                     // dragged off to the right

    implicitWidth: Theme.notif.width
    implicitHeight: Math.max(Theme.notif.iconSize, textCol.implicitHeight) + Theme.notif.padding * 2

    // plugin glass only follows moving items while the window re-measures
    function settle() { const w = QsWindow.window; if (w && w.settleGlass) w.settleGlass(); }

    Item {
        id: face
        width: card.width
        height: card.height
        transform: Translate { id: slide; x: 0; onXChanged: card.settle() }
        opacity: Math.max(0, 1 - Math.max(0, slide.x) / (card.width * 1.2))

        // edges of the cards behind a collapsed stack, each narrower and fainter
        Repeater {
            model: Math.min(card.stacked, 2)
            Item {
                required property int index
                readonly property int depth: index + 1
                y: card.height + index * Theme.notif.stackPeek
                width: card.width
                height: Theme.notif.stackPeek
                clip: true
                Rectangle {
                    x: parent.depth * Theme.notif.stackInset
                    width: card.width - x * 2
                    height: Theme.notif.radius * 2
                    y: parent.height - height
                    radius: Theme.notif.radius
                    color: Theme.dark ? Qt.rgba(0.20, 0.20, 0.21, 0.78 - 0.18 * parent.index)
                                      : Qt.rgba(0.97, 0.97, 0.98, 0.62 - 0.16 * parent.index)
                    border.width: 1
                    border.color: Theme.glass.hairline
                }
            }
        }

        Glass {
            anchors.fill: parent
            visible: card.glass
            radius: Theme.notif.radius
            sx: card.sx + slide.x
            sy: card.sy
            shadow: card.shadow
        }

        Item {
            anchors.fill: parent
            opacity: card.contentOpacity
            visible: opacity > 0.01

            // icon: sender picture with a small app badge (Messages, Mail), else the app icon
            Item {
                id: iconBox
                x: Theme.notif.padding
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.notif.iconSize
                height: Theme.notif.iconSize
                readonly property string appUrl: {
                    const entry = Apps.entryFor(card.appName) || Apps.entryFor(card.appIcon);
                    if (card.appIcon && card.appIcon.startsWith("/")) return "file://" + card.appIcon;
                    if (card.appIcon && card.appIcon.startsWith("file://")) return card.appIcon;
                    return Apps.iconUrl(entry ? entry.icon : card.appIcon, entry ? entry.id : card.appName);
                }
                readonly property string imageUrl: !card.image ? "" : card.image.startsWith("/") ? "file://" + card.image : card.image
                ClippingRectangle {
                    anchors.fill: parent
                    visible: iconBox.imageUrl !== ""
                    radius: width / 2
                    color: "transparent"
                    Image {
                        anchors.fill: parent
                        source: iconBox.imageUrl
                        sourceSize: Qt.size(width * 2, height * 2)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                }
                IconImage {
                    readonly property bool badge: iconBox.imageUrl !== ""
                    implicitSize: badge ? Math.round(Theme.notif.iconSize * 0.47) : Theme.notif.iconSize
                    x: badge ? iconBox.width - implicitSize + 3 : 0
                    y: badge ? iconBox.height - implicitSize + 3 : 0
                    source: iconBox.appUrl
                }
            }

            ColumnLayout {
                id: textCol
                anchors.left: iconBox.right
                anchors.leftMargin: Theme.notif.iconGap
                anchors.right: parent.right
                anchors.rightMargin: Theme.notif.padding
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
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
        }

        MouseArea {
            anchors.fill: parent
            onClicked: card.clicked()
        }
        HoverHandler { id: hoverH }

        // close button: round, on the top-left corner, fades in on hover (macOS)
        Item {
            id: closeBtn
            x: -7
            y: -7
            width: 20
            height: 20
            opacity: card.hovered && card.contentOpacity > 0.5 && !drag.active ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: Theme.anim.fast } }
            RectangularShadow {
                anchors.fill: parent
                radius: width / 2
                blur: 6
                offset.y: 1
                color: Qt.rgba(0, 0, 0, Theme.dark ? 0.45 : 0.18)
            }
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: closeMa.pressed ? (Theme.dark ? "#55555A" : "#DCDCDE")
                     : Theme.dark ? Qt.rgba(0.27, 0.27, 0.29, 0.97) : Qt.rgba(0.99, 0.99, 0.99, 0.97)
                border.width: 1
                border.color: Theme.glass.hairline
            }
            Symbol { anchors.centerIn: parent; name: "xmark"; size: 11; color: Theme.color.secondaryLabel }
            MouseArea { id: closeMa; anchors.fill: parent; anchors.margins: -2; hoverEnabled: true; onClicked: card.closed() }
        }
    }

    // swipe right to dismiss; left only rubber-bands
    DragHandler {
        id: drag
        enabled: card.swipeable
        target: null
        xAxis.enabled: true
        yAxis.enabled: false
        onTranslationChanged: if (active) slide.x = translation.x > 0 ? translation.x : translation.x * 0.2
        onActiveChanged: {
            if (active) { back.stop(); away.stop(); return; }
            if (slide.x > card.width * 0.3 || (slide.x > 20 && centroid.velocity.x > 500)) away.start();
            else back.start();
        }
    }
    NumberAnimation {
        id: away
        target: slide; property: "x"; to: card.width + 60
        duration: Theme.anim.close; easing.type: Easing.OutCubic
        onFinished: card.swiped()
    }
    NumberAnimation {
        id: back
        target: slide; property: "x"; to: 0
        duration: 450; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.spring
    }
}
