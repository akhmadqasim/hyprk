import QtQuick
import Quickshell
import Quickshell.Widgets
import qs
import qs.HyprK
import qs.services
import "lock.js" as L
import "../../lib/clock.js" as Clock

// What one screen of the lock shows (LOCKSCREEN-27.2.1.md A): the sharp wallpaper slightly dimmed, the date
// and the clock; on the primary screen also the status items, the avatar, the field with its "?" button and the
// line under it. Used by the session lock surface (static, interactive) and by the lock-in / unlock overlays,
// which animate the opacities below (LockOverlay.qml):
//   wall  the wallpaper below the menu bar (it covers the desktop, the Dock and the windows)
//   bar   the wallpaper's top strip over the menu bar (the menu bar has its own track)
//   dim   the dimming over all of it
//   ui    the clock
//   date  the date
//   field the field and "?"
//   user  avatar, the line under the field, the status items and the notifications (they go in one frame on unlock)
//   caret the field's caret (the lock-in overlay draws it so the locked field does not add it in one frame)
Item {
    id: c
    property bool primary: true
    property var output: null      // the ShellScreen: its own wallpaper cut, as the desktop under it (Background.qml)
    property bool interactive: false
    property real wall: 1
    property real bar: 1
    property real dim: 1
    property real ui: 1
    property real date: 1
    property real field: 1
    property real user: 1
    property bool caret: interactive

    readonly property string locale: Quickshell.env("LC_ALL") || Quickshell.env("LC_TIME") || Quickshell.env("LANG") || ""
    readonly property var clockStyle: Clock.styleFor(locale)
    readonly property string timeSep: L.timeSep(locale)
    SystemClock { id: clock; precision: SystemClock.Minutes }   // fires once a minute, on the minute

    // ---------- backdrop: the desktop wallpaper exactly as the desktop draws it (Background.qml) ----------
    component Wall: Image {
        source: Wallpaper.urlFor(c.output)
        sourceSize: Wallpaper.pixelSizeOf(c.output)
        fillMode: Image.PreserveAspectCrop
        cache: true               // the same pixmap as the desktop's and every lock surface's
        asynchronous: false
    }
    // the wallpaper (or a plain fill without one), whole-screen sized, shown through the two strips below
    component Backdrop: Item {
        width: c.width
        height: c.height
        Rectangle { anchors.fill: parent; visible: Wallpaper.wallpaper === ""; color: LockTheme.fallbackFill }
        Wall { width: c.width; height: c.height; visible: Wallpaper.wallpaper !== "" }
    }
    // below the menu bar (it covers the desktop, the Dock and the windows) and over the menu bar: two strips so
    // each region on screen follows only its own track (one layer over the other would multiply them). The bar
    // strip carries its own dim: on the Mac the menu bar region does not un-dim before the bar comes back (B3: 0
    // from +33 to +117 while the wallpaper is at 0.19 to 0.41); under the shared dim it went to -0.10 first (mcap)
    Item {
        y: Theme.menuBar.height
        width: c.width
        height: c.height - y
        clip: true
        visible: opacity > 0
        opacity: c.wall
        Backdrop { y: -parent.y }
    }
    Item {
        width: c.width
        height: Theme.menuBar.height
        clip: true
        visible: opacity > 0
        opacity: c.bar
        Backdrop {}
        Rectangle { anchors.fill: parent; color: LockTheme.dim }
    }
    Rectangle {
        y: Theme.menuBar.height
        width: c.width
        height: c.height - y
        visible: opacity > 0
        opacity: c.dim
        color: LockTheme.dim
    }

    // ---------- date and clock ----------
    LockPlus {
        id: date
        anchors.horizontalCenter: parent.horizontalCenter
        y: LockTheme.dateBaseline - dateFm.ascent
        width: dateText.implicitWidth
        height: dateText.implicitHeight
        lift: LockTheme.dateLift
        visible: opacity > 0
        opacity: c.date
        FontMetrics { id: dateFm; font: LockTheme.dateFont }
        Text {
            id: dateText
            text: L.date(clock.date, c.clockStyle.monthFirst)
            font: LockTheme.dateFont
            color: "white"
        }
    }
    LockClock {
        anchors.horizontalCenter: parent.horizontalCenter
        y: LockTheme.clockBaseline - baselineOffset
        text: L.time(clock.date, c.clockStyle.use24h, c.timeSep)
        animate: c.interactive
        visible: opacity > 0
        opacity: c.ui
    }

    // ---------- primary screen: status items, notifications, avatar, field, line ----------
    Loader {
        active: c.primary
        anchors.fill: parent
        sourceComponent: Item {
            id: prim
            LockStatus {
                interactive: c.interactive
                anchors.right: parent.right
                anchors.rightMargin: LockTheme.statusRight
                y: LockTheme.statusTop
                visible: opacity > 0
                opacity: c.user
            }
            LockFeed {
                interactive: c.interactive
                anchors.right: parent.right
                anchors.rightMargin: LockTheme.notifRight
                y: LockTheme.notifTop
                visible: opacity > 0
                opacity: c.user
            }

            // avatar: ~/.face, the AccountsService icon, else initials on a grey disc
            ClippingRectangle {
                id: avatar
                width: LockTheme.avatarSize
                height: LockTheme.avatarSize
                radius: width / 2
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height - LockTheme.avatarBottom - height
                color: "transparent"
                visible: opacity > 0
                opacity: c.user
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

            PasswordField {
                id: field
                interactive: c.interactive
                caret: c.caret
                // the capsule's centre is 0.5 right of the screen centre; the "?" hangs off its right end
                x: Math.round((parent.width - LockTheme.fieldWidth) / 2 + LockTheme.fieldNudge)
                y: parent.height - LockTheme.fieldBottom - height
                visible: opacity > 0
                opacity: c.field
            }

            // line under the field; ~1 s after Return a spinner takes its place until PAM answers
            property bool spin: false
            Timer {
                running: Lock.busy
                interval: LockTheme.spinnerAfter
                onTriggered: prim.spin = true
            }
            Connections {
                target: Lock
                function onBusyChanged() { if (!Lock.busy) prim.spin = false; }
            }
            LockPlus {
                id: line
                visible: !prim.spin && opacity > 0
                anchors.horizontalCenter: parent.horizontalCenter
                // SF Pro's cap height is 1443 / 2048 em (OS/2 sCapHeight)
                y: field.y + field.height + LockTheme.lineCapTop - (lineFm.ascent - LockTheme.lineSize * 1443 / 2048)
                width: lineText.implicitWidth
                height: lineText.implicitHeight
                lift: LockTheme.lineLift
                opacity: c.user
                FontMetrics { id: lineFm; font: lineText.font }
                Text {
                    id: lineText
                    text: Lock.line
                    font: Typography.font(LockTheme.lineSize, LockTheme.lineWght)
                    color: "white"
                }
            }
            Item {
                visible: prim.spin
                anchors.horizontalCenter: parent.horizontalCenter
                y: line.y + line.height / 2 - height / 2
                width: LockTheme.spinnerSize
                height: LockTheme.spinnerSize
                opacity: c.user
                LockPlus {
                    id: spinner
                    anchors.fill: parent
                    lift: LockTheme.lineLift
                    Repeater {
                        model: 8
                        Rectangle {
                            required property int index
                            x: spinner.width / 2 - width / 2
                            width: 1.8
                            height: spinner.height * 0.28
                            radius: width / 2
                            color: "white"
                            opacity: 1 - index / 9
                            transform: Rotation { origin.x: 0.9; origin.y: spinner.height / 2; angle: -index * 45 }
                        }
                    }
                    RotationAnimator on rotation {
                        running: prim.spin
                        from: 0; to: 360; duration: 1000; loops: Animation.Infinite
                    }
                }
            }
        }
    }
}
