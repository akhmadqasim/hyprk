import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs
import qs.services
import qs.HyprK
import "../lib/clock.js" as Clock
import "../lib/nc.js" as NcLib

// One notification (banner and Notification Center), macOS 27 layout (Theme.notif, PC #62): app icon
// (or the sender's picture with a small app badge), bold title + relative time,
// body. Hover shows a round close button on the top-left corner at once and, on a stack, a "Show" capsule that
// crossfades with the time; a drag to the right swipes it away. `stacked` draws the plates of the cards behind a
// collapsed group as plain QML strips: the compositor glass merges touching shapes into one box, so real glass
// cards behind would just make this card taller.
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
    // glass starts this far down (local px): a card unfolding from under another keeps its glass
    // 1 px below that card, so the plugin blends the two (smooth union) instead of merging the boxes
    property real glassTop: 0
    property real contentOpacity: 1
    // Liquid Glass materialize of this card's glass (banners: follows the slide), times the window's
    property real materialize: 1
    property bool swipeable: true
    readonly property bool hovered: hoverH.hovered || closeMa.containsMouse
    readonly property real swipeX: slide.x
    // 0 time label .. 1 "Show" capsule (hover over a collapsed stack), one spring both ways
    property real showMix: 0
    SpringCurve { id: showAnim; target: card; property: "showMix"; spring: NcLib.hoverSpring }
    readonly property bool showWanted: hovered && stacked > 0 && !drag.active && buttonHost !== null
    // window that carries the buttons' regular glass (Notification Center); null: no "Show" capsule
    property var buttonHost: null
    onShowWantedChanged: showAnim.go(showWanted ? 1 : 0)

    signal clicked()
    signal closed()                     // close button
    signal swiped()                     // dragged off to the right

    implicitWidth: Theme.notif.width
    implicitHeight: Math.max(Theme.notif.iconSize, textCol.implicitHeight) + Theme.notif.padY * 2

    // plugin glass only follows moving items while the window re-measures
    function settle() { const w = QsWindow.window; if (w && w.settleGlass) w.settleGlass(); }
    // slide off to the right, then `swiped` (close button in Notification Center)
    function swipeAway() { back.stop(); away.start(); }

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
                    x: Theme.notif.plateInset[parent.index]
                    width: card.width - x * 2
                    height: Theme.notif.radius * 2
                    y: parent.height - height
                    radius: Theme.notif.radius
                    color: Theme.notif.plateFill[parent.index]
                }
                Rectangle {
                    x: Theme.notif.plateInset[parent.index] + Theme.notif.radius / 2
                    width: card.width - x * 2
                    height: 1
                    color: Theme.notif.plateLine
                }
            }
        }

        Glass {
            y: card.glassTop
            width: parent.width
            height: parent.height - card.glassTop
            visible: card.glass && height >= 4
            radius: Math.min(Theme.notif.radius, height / 2)
            sx: card.sx + slide.x
            sy: card.sy + card.glassTop
            shadow: card.shadow
            materialize: card.materialize * (registeredWith ? registeredWith.glassMaterialize : 1)
        }

        Item {
            anchors.fill: parent
            opacity: card.contentOpacity
            visible: opacity > 0.01

            // icon: sender picture with a small app badge (Messages, Mail), else the app icon
            Item {
                id: iconBox
                x: Theme.notif.padX
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

            // explicit widths (not a ColumnLayout): the wrapped body knows its height at creation,
            // so lists animate to the right place instead of correcting one frame later
            Column {
                id: textCol
                x: iconBox.x + iconBox.width + Theme.notif.iconGap
                width: card.width - x - Theme.notif.padRight
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                RowLayout {
                    width: parent.width
                    spacing: 6
                    Text {
                        Layout.fillWidth: true
                        text: card.summary || card.appName
                        elide: Text.ElideRight
                        font: Typography.font(13, Typography.semibold)   // TODO verify (not measured)
                        color: Theme.color.label
                    }
                    Text {
                        text: Clock.relative(card.time, Notifs.now)
                        font: Typography.subheadline   // 11 ("2m ago" is 38 pt wide on the Mac)
                        color: Theme.color.secondaryLabel
                        opacity: 1 - card.showMix
                    }
                }
                Text {
                    width: parent.width
                    visible: text !== ""
                    text: card.body
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    maximumLineCount: Theme.notif.maxBodyLines
                    elide: Text.ElideRight
                    font: Typography.body
                    color: Theme.color.label
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: card.clicked()
        }
        HoverHandler { id: hoverH }

        // "Show" on a collapsed stack (hover): bottom-right, crossfading with the time label (PC #62 3f)
        // regular glass on the Notification Center's button layer (buttonHost); none on banners
        Item {
            x: card.width - width - Theme.notif.showInset.x
            y: card.height - height - Theme.notif.showInset.y
            width: Theme.notif.showSize.width
            height: Theme.notif.showSize.height
            visible: card.buttonHost !== null && card.showMix > 0.01
            Glass {
                anchors.fill: parent
                host: card.buttonHost
                radius: height / 2
                shadow: false
                materialize: card.showMix
            }
            Text {
                opacity: card.showMix
                anchors.centerIn: parent
                text: "Show"
                font: Typography.font(12, Typography.medium)
                color: Theme.color.label
            }
        }

        // close button: round, on the top-left corner, shows and hides at once on hover (PC #62 3f)
        Item {
            id: closeBtn
            x: Theme.notif.closeAt.x
            y: Theme.notif.closeAt.y
            width: Theme.notif.closeSize
            height: Theme.notif.closeSize
            visible: card.hovered && card.contentOpacity > 0.5 && !drag.active
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
            Symbol { anchors.centerIn: parent; name: "xmark"; surface: "nc"; size: 11; color: Theme.color.secondaryLabel }
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
