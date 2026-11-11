pragma Singleton

import QtQuick
import Quickshell
import qs
import qs.HyprK

// Every lock screen value in one place (logical px = macOS pt, ms). Measured on macOS 27.2.1:
// reference/re/LOCKSCREEN-27.2.1.md (section letters below), crops in reference/screens/27.2.1/lock/.
// The Mac's screen was 1710 x 1107 pt; the layout is centred horizontally, the clock and date keep their
// distance from the top and the avatar, field and text line theirs from the bottom, sizes stay in pt.
// "lift" colours are added to the backdrop (plus-lighter, lockplus.frag): measured locked = backdrop + lift.
Singleton {
    id: t

    readonly property bool dark: Theme.dark
    readonly property bool reduceMotion: Theme.reduceMotion
    // Reduce Transparency / Increase Contrast: the notification cards drop their glass (the lock itself has none)
    readonly property bool solid: Theme.reduceTransparency || Theme.increaseContrast

    // ---------- wallpaper (A1): the sharp desktop wallpaper, no blur, no zoom, slightly dimmed ----------
    readonly property color dim: Qt.rgba(0, 0, 0, dark ? 0.05 : 0.10)   // locked = 0.95 x / 0.90 x desktop
    readonly property color fallbackFill: dark ? "#1C1C1E" : "#3A4A63"  // no wallpaper file at all (not measured)

    // ---------- date (A2) ----------
    readonly property real dateSize: 32.5               // SF Pro Semibold, cap height 23
    readonly property int dateWght: 590
    readonly property real dateTracking: -0.6           // pt per character on top of SF's own tracking
    readonly property real dateBaseline: 130            // from the screen top (cap top 107)
    readonly property vector3d dateLift: dark ? Qt.vector3d(0.50, 0.50, 0.50) : Qt.vector3d(0.30, 0.31, 0.31)
    readonly property font dateFont: Qt.font({ family: Typography.family, pixelSize: dateSize,
        weight: Typography.qtWeight(dateWght), letterSpacing: Typography.letterSpacing(dateSize) + dateTracking,
        variableAxes: Typography.isSF ? { "wght": dateWght, "opsz": Typography.opsz(dateSize), "GRAD": Typography.grade(dateSize) } : {} })

    // ---------- clock (A3) ----------
    // `.SF Soft Numeric`: face 2 of ADTNumeric.ttc (themes/fonts), variable wdth / wght / SOFT / GRAD. Best fit
    // 156 pt, Weight 600-650, Width 95, SOFT default 70. Without it: SF Pro Semibold (A3 "fallback").
    readonly property bool clockSoft: Theme.pickFont([".SF Soft Numeric", ""]) !== ""
    readonly property real clockSize: 156
    readonly property real clockWght: 625
    readonly property real clockWdth: 95
    readonly property real clockBaseline: 263           // flat digits y 153 to 263, round 152 to 265
    readonly property font clockFont: clockSoft
        ? Qt.font({ family: ".SF Soft Numeric", pixelSize: clockSize, weight: Font.DemiBold,
                    variableAxes: { "wdth": clockWdth, "wght": clockWght, "SOFT": 70 } })
        : Qt.font({ family: Typography.family, pixelSize: clockSize, weight: Font.DemiBold,
                    variableAxes: Typography.isSF ? { "wght": 590, "opsz": 96 } : {} })
    readonly property vector3d clockLift: Qt.vector3d(0.35, 0.31, 0.35)   // + (89, 80, 88) / 255, both themes
    readonly property real clockEdge: 1.0               // white top line ...
    readonly property real clockEdgePx: 2.0             // ... fading into the fill (device px)
    readonly property real clockRim: 0.06               // 1 px outer rim, backdrop - 15 / 255
    readonly property int minuteChange: Theme.ms(650)   // B8: only the changed digit, gradient-mask reveal
    readonly property real minuteSoft: 0.6              // mask gradient height / glyph box height
    readonly property int minuteRecentre: Theme.ms(300) // the string re-centres, most of it in the first 150 ms

    // ---------- avatar (A4): 55 pt disc, no ring, no shadow, no name ----------
    readonly property real avatarSize: 55
    readonly property real avatarBottom: 126.5          // disc bottom edge above the screen bottom
    // initials avatar: macOS grey gradient disc (lockscreen/scripts/initials-avatar.py colours)
    readonly property color avatarTop: "#A5A5AA"
    readonly property color avatarBottomColor: "#6E6E73"

    // ---------- password field (A5) ----------
    readonly property real fieldWidth: 161
    readonly property real fieldHeight: 28.5            // radius 14.25: a capsule
    readonly property real fieldBottom: 86              // capsule bottom edge above the screen bottom
    readonly property real fieldNudge: 0.5              // capsule centre x is 0.5 right of the screen centre
    readonly property vector3d fieldLift: dark ? Qt.vector3d(0.32, 0.28, 0.33) : Qt.vector3d(0.07, 0.01, 0.01)
    readonly property string placeholder: "Enter Password"
    readonly property real placeholderSize: 13
    readonly property real placeholderX: 17.5
    readonly property vector3d placeholderLift: Qt.vector3d(0.18, 0.19, 0.23)
    // dots, caret and the Caps Lock glyph: + (111, 115, 96+) dark, + (93, 100, 116) light over the capsule
    readonly property vector3d inkLift: dark ? Qt.vector3d(0.44, 0.45, 0.45) : Qt.vector3d(0.36, 0.39, 0.45)
    readonly property real dotSize: 5                   // pitch 8.25 and offsets in lock.js (dotX, caretX)
    readonly property real caretWidth: 2
    readonly property real caretHeight: 16
    readonly property int caretOn: 600                  // idle blink 0.6 s on / 0.4 s off, solid while typing
    readonly property int caretOff: 400
    readonly property real busyDim: 0.6                 // dots, arrow and "?" while PAM checks (level 155 -> 103)
    readonly property vector3d selectLift: Qt.vector3d(0.20, 0.20, 0.32)   // wrong password: the dots shown selected
    readonly property real arrowSize: 22                // ring, 2 pt stroke, arrow inside; centre 15 from the right end
    readonly property real arrowRight: 4
    readonly property real ringStroke: 2
    readonly property vector3d ringLift: dark ? Qt.vector3d(0.22, 0.22, 0.23) : Qt.vector3d(0.17, 0.18, 0.22)
    readonly property real capsSize: 12.5               // filled up-arrow, centre 137.25 from the left edge
    readonly property real capsX: 131
    // "?" hint button: 29 pt disc 5 pt right of the capsule, 22 pt ring and "?" inside
    readonly property real hintDisc: 29
    readonly property real hintGap: 5
    readonly property vector3d hintDiscLift: dark ? Qt.vector3d(0.07, 0.035, 0.03) : Qt.vector3d(0.07, 0.01, 0.01)
    readonly property vector3d hintInkLift: Qt.vector3d(0.45, 0.45, 0.44)
    readonly property real hintGlyphSize: 15

    // ---------- line under the field (A6) ----------
    // The Mac reads "Touch ID or Enter Password"; hyprk has no Touch ID, so only the password half.
    readonly property string lineText: "Enter Password"
    readonly property real lineSize: 12.5
    readonly property int lineWght: 510
    readonly property real lineCapTop: 10.75            // field bottom to the cap top
    readonly property vector3d lineLift: dark ? Qt.vector3d(0.54, 0.58, 0.66) : Qt.vector3d(0.53, 0.62, 0.66)
    readonly property real spinnerSize: 15
    readonly property int spinnerAfter: 970             // B2: the spinner replaces the line ~1 s after Return
    readonly property string hintFallback: "Check Caps Lock and the keyboard layout"
    readonly property string lockoutText: "Too many attempts"          // PAM gave up (MaxTries), not seen on the Mac

    // ---------- status items, top right (A7) ----------
    readonly property real statusTop: 8                 // items y 8 to 25 (centre 16.5)
    readonly property real statusRowHeight: 17
    readonly property real statusRight: 19
    readonly property real statusGap: 12
    readonly property real wifiWidth: 26
    readonly property real batteryWidth: 28
    readonly property real inputWidth: 54               // "ABC" + keyboard glyph
    readonly property real statusGlyph: 16
    readonly property real inputTextSize: 13
    readonly property color statusColor: "white"

    // ---------- notifications and Now Playing (none on the Mac's recordings: ours, kept simple) ----------
    readonly property real notifTop: statusTop + statusRowHeight + 14
    readonly property real notifRight: 14
    readonly property real notifGap: 8
    readonly property int notifMax: 3
    readonly property real notifRadius: 24              // banner radius (Theme.notif.radius)
    readonly property color cardFace: dark ? Qt.rgba(0.16, 0.16, 0.17, 0.55) : Qt.rgba(1, 1, 1, 0.55)
    readonly property color cardSolid: dark ? "#2C2C2E" : "#ECECEE"
    readonly property color cardRimTop: Qt.rgba(1, 1, 1, dark ? 0.30 : 0.50)
    readonly property color cardRim: Qt.rgba(1, 1, 1, dark ? 0.10 : 0.18)
    readonly property color cardShadow: Qt.rgba(0, 0, 0, 0.04)
    readonly property real cardShadowBlur: 4
    readonly property real cardShadowY: 8
    readonly property real playerHeight: 76
    readonly property real playerArt: 48

    // ---------- motion (B1, B2, B3) ----------
    // lock-in (t = 0 at the first changed frame): the menu bar goes ease-in-out 100 ms, the Dock (and so the
    // whole wallpaper layer here) CSS ease 190 ms, the dim ~230 ms; the lock UI fades in ease-out quad 250 ms
    // from +7 ms. Opacity only.
    readonly property int inBar: Theme.ms(100)
    readonly property int inWall: Theme.ms(190)
    readonly property var cssEase: [0.25, 0.1, 0.25, 1.0, 1, 1]
    readonly property int inDim: Theme.ms(230)
    readonly property int inUiDelay: Theme.ms(7)
    readonly property int inUi: Theme.ms(250)
    readonly property int lockIn: inUiDelay + inUi      // the session lock engages after this
    // unlock: avatar, line and status items go in one frame; clock, date, field and "?" fade ease-in quad
    // 310 ms that started 87 ms before the first visible change, i.e. the last 223 ms of it (a quadratic, so
    // exactly the bezier below); the Dock (wallpaper layer) back ease-in quad 135 ms from +89, the menu bar
    // ease-in-out quad 165 ms from +111, the dim ~330 ms mostly in the first 200.
    readonly property real outUiFrom: 0.921             // 1 - (87 / 310)^2
    readonly property int outUi: Theme.ms(223)
    readonly property var outUiCurve: [0.333, 0.146, 0.667, 0.479, 1, 1]
    readonly property int outWallDelay: Theme.ms(89)
    readonly property int outWall: Theme.ms(135)
    readonly property int outBarDelay: Theme.ms(111)
    readonly property int outBar: Theme.ms(165)
    readonly property int outDim: Theme.ms(330)
    readonly property int unlockOut: Math.max(outBarDelay + outBar, outDim)   // the overlay goes after this
    // wrong password: keyframes from lock.js shakeKeys() (400 ms, 7.5 Hz, 14 / 8.25 / 6.75 pt)
}
