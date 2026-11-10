pragma Singleton

import QtQuick
import Quickshell
import qs

// Every lock screen value in one place (logical px = macOS pt, ms). No macOS 27 lock screen has been
// measured yet: values carried over from lockscreen/hyprlock.conf or guessed name the question in
// reference/re/questions/lockscreen.md that will replace them.
Singleton {
    id: t

    readonly property bool dark: Theme.dark
    readonly property bool reduceMotion: Theme.reduceMotion
    // Reduce Transparency and Increase Contrast drop the glass, like the rest of the shell (Theme.solidMaterial
    // also covers a missing blurred wallpaper)
    readonly property bool solid: Theme.reduceTransparency || Theme.increaseContrast

    // ---------- wallpaper ----------
    readonly property real blurSigma: 24                // guessed (hyprlock blur 2x6), waiting for Q-lockscreen-01
    // the blurred copy is cached at this fraction of the screen size; a blur this wide looks the same
    // upscaled, and it is 1/16 of the memory (not a look value)
    readonly property real blurScale: 0.25
    readonly property real saturation: 1.15             // guessed (hyprlock vibrancy 0.25), waiting for Q-lockscreen-01
    readonly property color dim: Qt.rgba(0, 0, 0, 0.16) // guessed (hyprlock brightness 0.84), waiting for Q-lockscreen-01
    // Reduce Transparency: the sharp wallpaper under a solid dim, no blur. Guessed, waiting for Q-lockscreen-27
    readonly property color dimSolid: Qt.rgba(0, 0, 0, 0.32)
    readonly property color fallbackFill: dark ? "#1C1C1E" : "#3A4A63"   // no wallpaper file at all, guessed

    // ---------- clock and date ----------
    readonly property string clockFont: Theme.pickFont(["SF Pro Rounded", Theme.fontDisplay])   // hyprlock.conf, waiting for Q-lockscreen-02
    readonly property real clockSize: 124               // hyprlock.conf, waiting for Q-lockscreen-02
    readonly property int clockWeight: Font.Bold        // hyprlock.conf (700), waiting for Q-lockscreen-02
    readonly property color clockColor: Qt.rgba(1, 1, 1, 0.95)   // hyprlock.conf, waiting for Q-lockscreen-02 / -31
    readonly property real clockTop: 118                // top of the clock text box, hyprlock.conf, waiting for Q-lockscreen-03
    readonly property real dateSize: 24                 // hyprlock.conf, waiting for Q-lockscreen-05
    readonly property int dateWeight: Font.Medium       // hyprlock.conf (500), waiting for Q-lockscreen-05
    readonly property color dateColor: Qt.rgba(1, 1, 1, 0.92)    // hyprlock.conf, waiting for Q-lockscreen-05
    readonly property real dateTop: 92                  // hyprlock.conf, waiting for Q-lockscreen-05

    // ---------- user ----------
    readonly property real avatarSize: 96               // hyprlock.conf, waiting for Q-lockscreen-06
    readonly property real avatarBottom: 132            // avatar bottom edge above the screen bottom, waiting for Q-lockscreen-06
    readonly property color avatarShadow: Qt.rgba(0, 0, 0, 0.30)  // hyprlock.conf, waiting for Q-lockscreen-06
    readonly property real avatarShadowBlur: 16         // guessed, waiting for Q-lockscreen-06
    // initials avatar: macOS grey gradient disc (lockscreen/scripts/initials-avatar.py colours), waiting for Q-lockscreen-06
    readonly property color avatarTop: "#A5A5AA"
    readonly property color avatarBottomColor: "#6E6E73"
    readonly property real nameSize: 17                 // hyprlock.conf, waiting for Q-lockscreen-07
    readonly property color nameColor: Qt.rgba(1, 1, 1, 0.95)    // hyprlock.conf, waiting for Q-lockscreen-07
    readonly property real nameBottom: 96               // name text bottom above the screen bottom, waiting for Q-lockscreen-07

    // ---------- password field ----------
    readonly property real fieldWidth: 210              // hyprlock.conf, waiting for Q-lockscreen-08
    readonly property real fieldHeight: 36              // hyprlock.conf, waiting for Q-lockscreen-08
    readonly property real fieldBottom: 40              // hyprlock.conf, waiting for Q-lockscreen-08
    readonly property real fieldPadding: 14             // text inset, guessed, waiting for Q-lockscreen-10
    // Glass: the lockscreenControls variant resolves to plain regular glass on 27.2.1 (no difference in
    // reference/re/27.2.1/live/glass-table-light.txt:1063), so the face is the measured regular face
    // (LIVE-27.2.1.md: light fill white a 0.2; dark no fill, white 1.125 = about a 0.10 white lift here).
    // That loginwindow uses this variant for the field is waiting for Q-lockscreen-09.
    readonly property color fieldFace: dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(1, 1, 1, 0.20)
    readonly property color fieldRimTop: Qt.rgba(1, 1, 1, dark ? 0.30 : 0.50)      // specular edge, guessed, Q-lockscreen-09
    readonly property color fieldRim: Qt.rgba(1, 1, 1, dark ? 0.10 : 0.18)         // guessed, Q-lockscreen-09
    // drop shadow of regular glass at D = 36 (LIVE-27.2.1.md: opacity 0.04 below D 64, radius 4, y 8)
    readonly property color fieldShadow: Qt.rgba(0, 0, 0, 0.04)
    readonly property real fieldShadowBlur: 4
    readonly property real fieldShadowY: 8
    // Reduce Transparency: an opaque capsule, guessed, waiting for Q-lockscreen-27
    readonly property color fieldSolid: dark ? "#3A3A3C" : "#8E8E93"
    readonly property color fieldFail: Qt.rgba(1, 0.27, 0.23, 0.35)   // hyprlock.conf fail colour (lighter), Q-lockscreen-12
    readonly property string placeholder: "Enter Password"              // hyprlock.conf, waiting for Q-lockscreen-10
    readonly property real placeholderSize: 14          // hyprlock.conf, waiting for Q-lockscreen-10
    readonly property color placeholderColor: Qt.rgba(1, 1, 1, 0.70)   // guessed, waiting for Q-lockscreen-10
    readonly property real dotSize: 7                   // hyprlock 26 % of 36 = 9.4, guessed smaller, Q-lockscreen-11
    readonly property real dotSpacing: 4                // guessed, waiting for Q-lockscreen-11
    readonly property color dotColor: Qt.rgba(1, 1, 1, 0.95)
    readonly property real caretWidth: 2                // guessed, waiting for Q-lockscreen-11
    readonly property real caretHeight: 17              // guessed, waiting for Q-lockscreen-11
    readonly property int caretBlink: 530               // NSTextInsertionIndicator half period, guessed, Q-lockscreen-11
    // the caret only blinks this long after the last key or show, then stays on: an idle lock redraws nothing
    readonly property int caretBlinkFor: 10000
    readonly property real arrowSize: 22                // return arrow disc, guessed, waiting for Q-lockscreen-10
    readonly property color arrowFill: Qt.rgba(1, 1, 1, 0.85)
    readonly property real capsSize: 15                 // caps lock glyph, guessed (hyprlock: orange outline), Q-lockscreen-11

    // ---------- hint line ----------
    readonly property real hintSize: 12                 // guessed, waiting for Q-lockscreen-13 / -14
    readonly property color hintColor: Qt.rgba(1, 1, 1, 0.80)
    readonly property real hintGap: 10                  // field bottom to hint top, guessed, Q-lockscreen-14
    readonly property int hintAfterFailures: 3          // guessed (Users & Groups "Show password hints"), Q-lockscreen-13
    readonly property string hintFallback: "Check Caps Lock and the keyboard layout"   // no hint set, guessed, Q-lockscreen-13
    readonly property string wrongText: "Incorrect password"           // hyprlock.conf fail_text, Q-lockscreen-12
    readonly property string lockoutText: "Too many attempts"          // PAM gave up (MaxTries), guessed, Q-lockscreen-13

    // ---------- status items, top right ----------
    readonly property real statusTop: 11                // hyprlock.conf, waiting for Q-lockscreen-16
    readonly property real statusRight: 20              // hyprlock.conf, waiting for Q-lockscreen-16
    readonly property real statusBox: 28                // hyprlock.conf, waiting for Q-lockscreen-16
    readonly property real statusGap: 10                // hyprlock.conf (58 - 20 - 28), waiting for Q-lockscreen-16
    readonly property real statusGlyph: 16              // menu bar glyph size, waiting for Q-lockscreen-16
    readonly property color statusColor: Qt.rgba(1, 1, 1, 0.95)
    readonly property real layoutTextSize: 11           // input source label, guessed, waiting for Q-lockscreen-17

    // ---------- notifications and Now Playing ----------
    readonly property real notifTop: statusTop + statusBox + 10   // below the status items, guessed, Q-lockscreen-20
    readonly property real notifRight: 14               // guessed, waiting for Q-lockscreen-20
    readonly property real notifGap: 8                  // guessed, waiting for Q-lockscreen-20
    readonly property int notifMax: 3                   // guessed, waiting for Q-lockscreen-20
    readonly property real notifRadius: 24              // banner radius (Theme.notif.radius), waiting for Q-lockscreen-20
    // lockscreenNotifications also resolves to regular glass (glass-table-light.txt:1036): same face as the field
    readonly property color cardFace: dark ? Qt.rgba(0.16, 0.16, 0.17, 0.55) : Qt.rgba(1, 1, 1, 0.55)   // guessed, Q-lockscreen-20
    readonly property color cardSolid: dark ? "#2C2C2E" : "#ECECEE"
    readonly property real playerHeight: 76             // guessed, waiting for Q-lockscreen-21
    readonly property real playerArt: 48                // guessed, waiting for Q-lockscreen-21

    // ---------- motion ----------
    // CSS "ease", the hyprlock.conf curve; waiting for Q-lockscreen-18 / -19
    readonly property var ease: [0.25, 0.1, 0.25, 1.0, 1, 1]
    readonly property int lockIn: Theme.ms(400)         // desktop -> lock fade, hyprlock.conf, waiting for Q-lockscreen-18
    readonly property int unlockOut: Theme.ms(350)      // lock -> desktop, guessed (hyprlock 300), waiting for Q-lockscreen-19
    readonly property real unlockClockRise: Theme.travel(48)    // clock and date move up while fading, guessed, Q-lockscreen-19
    readonly property real unlockUserDrop: Theme.travel(48)     // avatar, name and field move down, guessed, Q-lockscreen-19
    readonly property real unlockScale: Theme.travel(0.04)      // the UI grows 4 % as it goes, guessed, Q-lockscreen-19
    readonly property int shakeDuration: 450            // guessed (0.4 to 0.5 s), waiting for Q-lockscreen-12
    readonly property real shakeAmplitude: 14           // pt, guessed, waiting for Q-lockscreen-12
    readonly property real shakeCycles: 3               // guessed, waiting for Q-lockscreen-12
    readonly property real shakeDecay: 1.6              // guessed, waiting for Q-lockscreen-12
    readonly property int failFade: Theme.ms(150)       // Reduce Motion: the dots fade instead of the shake, Q-lockscreen-28
}
