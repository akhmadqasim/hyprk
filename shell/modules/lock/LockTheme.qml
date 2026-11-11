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
    // dark-sc3 / light-sc3 (lossless): over (20, 14, 135) + (139.5, 138.4, B clipped); over (141, 169, 199)
    // + (83.8, G and B clipped, so >= 85.7 / 55.9); the clipped channels take the others' value
    readonly property vector3d dateLift: dark ? Qt.vector3d(0.547, 0.543, 0.545) : Qt.vector3d(0.329, 0.336, 0.336)
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
    // The Mac's per-frame tracks, [ms, progress] with ms from the first changed frame (light.mp4 lock-in, dark.mp4
    // unlock; LOCKSCREEN-27.2.1.md B1 / B3 tables, verbatim). The overlays run one linear clock from -17 ms (the
    // last unchanged frame) and read every layer from these (lock.js track()): the named fits (ease-in-out 100 ms,
    // ease-out quad 250 ms from +7...) put the clock a frame early mid-curve and miss its 2-frame lead-in.
    // Opacity only, nothing moves.
    readonly property real trackStart: -17
    // lock-in, progress towards the lock: menu bar (the bar strip with its dim), Dock (the wallpaper layer below the
    // bar), wallpaper dim, clock, date, field (with "?"), avatar (avatar, line, status items)
    readonly property var inBar: [[-17, 0], [0, 0.10], [17, 0.26], [33, 0.57], [50, 0.84], [67, 0.96], [83, 0.97],
        [100, 0.97], [117, 0.98], [133, 1]]
    readonly property var inWall: [[-17, 0], [0, 0.10], [17, 0.21], [33, 0.36], [50, 0.59], [67, 0.74], [83, 0.81],
        [100, 0.89], [117, 0.96], [133, 0.96], [150, 0.97], [167, 1]]
    readonly property var inDim: [[-17, 0], [0, 0.11], [17, 0.17], [33, 0.23], [50, 0.29], [67, 0.38], [83, 0.43],
        [100, 0.49], [117, 0.58], [133, 0.63], [150, 0.70], [167, 0.75], [183, 0.85], [200, 0.89], [217, 0.94], [233, 1]]
    readonly property var inUi: [[17, 0], [33, 0.28], [50, 0.35], [67, 0.43], [83, 0.51], [100, 0.59], [117, 0.66],
        [133, 0.73], [150, 0.80], [167, 0.87], [183, 0.92], [200, 0.96], [217, 0.99], [233, 1]]
    readonly property var inDate: [[17, 0], [33, 0.26], [50, 0.33], [67, 0.40], [83, 0.47], [100, 0.54], [117, 0.60],
        [133, 0.67], [150, 0.73], [167, 0.80], [183, 0.86], [200, 0.92], [217, 0.98], [233, 0.99]]
    readonly property var inField: [[17, 0], [33, 0.21], [50, 0.26], [67, 0.35], [83, 0.42], [100, 0.52], [117, 0.56],
        [133, 0.63], [150, 0.70], [167, 0.78], [183, 0.85], [200, 0.90], [217, 0.96], [233, 0.99]]
    readonly property var inUser: [[17, 0], [33, 0.24], [50, 0.30], [67, 0.36], [83, 0.42], [100, 0.49], [117, 0.55],
        [133, 0.62], [150, 0.69], [167, 0.76], [183, 0.82], [200, 0.89], [217, 0.97], [233, 1]]
    readonly property int inEnd: 233
    readonly property real warmOpacity: 0.002           // < 0.5 / 255 of any change; above Qt's 0.001 cull
    readonly property int lockIn: Theme.ms(inEnd - trackStart)   // the session lock engages after this
    // unlock, progress back to the desktop (the overlay shows 1 - it). Its clock starts at +0: the first frame after
    // the start shows the start value, and at +0 the avatar, line and status items are already gone (one frame). The menu bar's lone 0.07 at +0 (0 again from +33) is left out. The dim's last sample is 0.97 at +333,
    // when the overlay goes.
    readonly property var outUi: [[-17, 0], [0, 0.06], [33, 0.16], [50, 0.20], [67, 0.25], [83, 0.30], [100, 0.36],
        [117, 0.43], [133, 0.52], [150, 0.60], [167, 0.69], [200, 0.85], [217, 0.94], [233, 1]]
    // date and field fade faster than the clock (B3: remaining 0.25 / 0.24 vs 0.31 at +167)
    readonly property var outDate: [[-17, 0], [0, 0.07], [33, 0.18], [50, 0.24], [67, 0.31], [83, 0.39], [100, 0.46],
        [117, 0.53], [133, 0.60], [150, 0.68], [167, 0.75], [200, 0.89], [217, 0.95], [233, 1]]
    readonly property var outField: [[-17, 0], [0, 0.09], [33, 0.24], [50, 0.31], [67, 0.37], [83, 0.44], [100, 0.51],
        [117, 0.57], [133, 0.64], [150, 0.70], [167, 0.76], [200, 0.89], [217, 0.96], [233, 1]]
    readonly property var outBar: [[117, 0], [133, 0.03], [150, 0.12], [167, 0.23], [200, 0.59], [217, 0.74],
        [233, 0.90], [267, 1]]
    readonly property var outWall: [[67, 0], [83, 0.02], [100, 0.02], [117, 0.04], [133, 0.09], [150, 0.21],
        [167, 0.35], [200, 0.72], [217, 0.88], [233, 1]]
    readonly property var outDim: [[-17, 0], [0, 0.04], [33, 0.19], [50, 0.22], [67, 0.26], [83, 0.30], [100, 0.33],
        [117, 0.41], [133, 0.47], [150, 0.58], [167, 0.65], [200, 0.84], [217, 0.90], [233, 0.92], [267, 0.94],
        [333, 0.97]]
    readonly property int outEnd: 333
    readonly property int unlockOut: Theme.ms(outEnd)   // the overlay goes after this
    // the overlays read the wall clock when Qt builds a frame; it is shown about this much later (mcap, 10 clean
    // unlocks each: wall clock 7-9 ms behind the animation driver's frame time, which matched the Mac's tracks)
    readonly property int frameLead: 8
    // wrong password: lock.js shake() on a linear 400 ms clock (7.5 Hz, 14 / 8.25 / 6.75 pt)
    readonly property int shakeMs: 400
}
