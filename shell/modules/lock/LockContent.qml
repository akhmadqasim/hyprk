import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import qs
import qs.HyprK
import qs.services
import "lock.js" as L
import "../../lib/clock.js" as Clock

// What one screen of the lock shows. Used by the session lock surface (static, interactive) and by
// the lock-in / unlock overlays (animated through `backdrop`, `ui` and `leave`).
//   primary: this screen has the user, the field, status items and the notification column;
//            the other screens show wallpaper, date and clock only.
Item {
    id: c
    property bool primary: true
    property bool interactive: false
    property real backdrop: 1      // blurred wallpaper + dim
    property real ui: 1            // clock, date, user, field, items
    property real leave: 0         // 0..1 unlock: clock rises, user group drops, both fade and grow

    readonly property var clockStyle: Clock.styleFor(Quickshell.env("LC_ALL") || Quickshell.env("LC_TIME") || Quickshell.env("LANG"))
    SystemClock { id: clock; precision: SystemClock.Minutes }   // fires once a minute, on the minute

    // ---------- backdrop ----------
    Item {
        anchors.fill: parent
        opacity: c.backdrop
        visible: opacity > 0
        Rectangle { anchors.fill: parent; color: LockTheme.fallbackFill }
        // blurred: a small cached copy (lock-wallpaper.sh), scaled up smoothly
        Image {
            anchors.fill: parent
            visible: !LockTheme.solid && Lock.blurred !== ""
            source: visible ? "file://" + Lock.blurred : ""
            fillMode: Image.PreserveAspectCrop
            smooth: true
            cache: true            // shared by every screen and the overlays; 1/16 of a screen
            asynchronous: false    // tiny: decoded before the first frame, so no flash of the fill
        }
        // Reduce Transparency, or no blurred copy yet: the sharp wallpaper under a solid dim
        Image {
            anchors.fill: parent
            visible: (LockTheme.solid || Lock.blurred === "") && Wallpaper.wallpaper !== ""
            source: visible ? Wallpaper.url : ""
            sourceSize: Qt.size(width, height)
            fillMode: Image.PreserveAspectCrop
            cache: false
            asynchronous: false
        }
        Rectangle {
            anchors.fill: parent
            color: LockTheme.solid || Lock.blurred === "" ? LockTheme.dimSolid : LockTheme.dim
        }
    }

    // ---------- date and clock ----------
    Item {
        anchors.fill: parent
        opacity: c.ui * (1 - c.leave)
        visible: opacity > 0
        transform: [
            Translate { y: -c.leave * LockTheme.unlockClockRise },
            Scale { origin.x: c.width / 2; origin.y: LockTheme.clockTop; xScale: 1 + c.leave * LockTheme.unlockScale; yScale: xScale }
        ]
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: LockTheme.dateTop
            text: L.date(clock.date, c.clockStyle.monthFirst)
            font: Typography.font(LockTheme.dateSize, Typography.medium)
            color: LockTheme.dateColor
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: LockTheme.clockTop
            text: L.time(clock.date, c.clockStyle.use24h)
            font.family: LockTheme.clockFont
            font.pixelSize: LockTheme.clockSize
            font.weight: LockTheme.clockWeight
            color: LockTheme.clockColor
        }
    }

    // ---------- status items and notifications (primary screen) ----------
    Loader {
        active: c.primary
        anchors.fill: parent
        opacity: c.ui * (1 - c.leave)
        visible: opacity > 0
        sourceComponent: Item {
            LockStatus {
                interactive: c.interactive
                anchors.right: parent.right
                anchors.rightMargin: LockTheme.statusRight
                y: LockTheme.statusTop
            }
            LockFeed {
                interactive: c.interactive
                anchors.right: parent.right
                anchors.rightMargin: LockTheme.notifRight
                y: LockTheme.notifTop
            }
        }
    }

    // ---------- user, field, hint (primary screen) ----------
    Loader {
        active: c.primary
        anchors.fill: parent
        opacity: c.ui * (1 - c.leave)
        visible: opacity > 0
        sourceComponent: Item {
            id: user
            transform: [
                Translate { y: c.leave * LockTheme.unlockUserDrop },
                Scale { origin.x: c.width / 2; origin.y: c.height - LockTheme.fieldBottom; xScale: 1 + c.leave * LockTheme.unlockScale; yScale: xScale }
            ]

            // avatar: ~/.face, the AccountsService icon, else initials on a grey disc
            Item {
                id: avatar
                width: LockTheme.avatarSize
                height: LockTheme.avatarSize
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height - LockTheme.avatarBottom - height
                RectangularShadow {
                    anchors.fill: parent
                    radius: width / 2
                    blur: LockTheme.avatarShadowBlur
                    color: LockTheme.avatarShadow
                }
                ClippingRectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    Rectangle {
                        anchors.fill: parent
                        visible: photo.status !== Image.Ready
                        gradient: Gradient {
                            GradientStop { position: 0; color: LockTheme.avatarTop }
                            GradientStop { position: 1; color: LockTheme.avatarBottomColor }
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: photo.status !== Image.Ready
                        text: L.initials(Lock.userName)
                        font: Typography.font(Math.max(1, avatar.width * 0.4), Typography.semibold)
                        color: "white"
                    }
                    Image {
                        id: photo
                        anchors.fill: parent
                        source: Lock.avatar !== "" ? "file://" + Lock.avatar : ""
                        sourceSize: Qt.size(width * 2, height * 2)
                        fillMode: Image.PreserveAspectCrop
                        cache: false
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height - LockTheme.nameBottom - height
                text: Lock.userName
                font: Typography.font(LockTheme.nameSize)
                color: LockTheme.nameColor
            }

            PasswordField {
                id: field
                interactive: c.interactive
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height - LockTheme.fieldBottom - height
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: field.y + field.height + LockTheme.hintGap
                visible: text !== ""
                text: Lock.message
                font: Typography.font(LockTheme.hintSize)
                color: LockTheme.hintColor
            }
        }
    }
}
