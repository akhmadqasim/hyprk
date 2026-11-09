pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "lib/state.js" as State

// Single source of truth for every visual metric of the hyprk shell.
// Units are logical pixels (1pt on macOS == 1 logical px here).
// Values marked "TODO verify" are macOS 27 best guesses and must be checked
// against /mnt/code/liquid-glass-re/SPEC.md ("Layout metrics") once available.
Singleton {
    id: theme

    // ---------- appearance ----------
    // Both are read from state/appearance.json ({"dark": bool, "reduceTransparency": bool})
    // and can be flipped at runtime via `qs ipc call theme ...`.
    property bool dark: false
    // macOS "Reduce transparency": solid tinted material instead of blurred glass.
    // Also forced on when the blurred wallpaper could not be produced (no magick).
    property bool reduceTransparency: false
    property bool blurAvailable: true
    readonly property bool solidMaterial: reduceTransparency || !blurAvailable
    readonly property string hyprkRoot: Quickshell.shellDir + "/.."

    // ---------- fonts ----------
    // SF Pro is extracted by the assets agent into themes/fonts; fall back to Inter/Cantarell.
    readonly property var _families: Qt.fontFamilies()
    function pickFont(list) {
        for (const f of list)
            if (_families.indexOf(f) !== -1)
                return f;
        return list[list.length - 1];
    }
    readonly property string fontText: pickFont(["SF Pro Text", "SF Pro", "System Font", ".SF NS", "Inter", "Cantarell", "Sans Serif"])
    readonly property string fontDisplay: pickFont(["SF Pro Display", "SF Pro", "System Font", ".SF NS", "Inter Display", "Inter", "Cantarell", "Sans Serif"])

    FileView {
        path: theme.hyprkRoot + "/state/appearance.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            const o = State.parse(text(), { dark: theme.dark, reduceTransparency: theme.reduceTransparency });
            theme.dark = o.dark;
            theme.reduceTransparency = o.reduceTransparency;
        }
    }

    IpcHandler {
        target: "theme"
        function toggle(): void { theme.dark = !theme.dark; }
        function setDark(on: bool): void { theme.dark = on; }
        function toggleTransparency(): void { theme.reduceTransparency = !theme.reduceTransparency; }
        function fonts(): string { return theme.fontText + " / " + theme.fontDisplay; }
    }

    readonly property QtObject font: QtObject {
        readonly property real menuBar: 13          // TODO verify
        readonly property real menu: 13             // TODO verify
        readonly property real clock: 13            // TODO verify
        readonly property real notifTitle: 13       // TODO verify
        readonly property real notifBody: 13        // TODO verify
        readonly property real notifTime: 11        // TODO verify
        readonly property real notifApp: 11         // TODO verify
        readonly property real ccTitle: 13          // measured ~2x reference
        readonly property real ccSub: 11            // TODO verify
        readonly property real spotlightInput: 22   // TODO verify
        readonly property real spotlightRow: 14     // TODO verify
        readonly property real spotlightHeader: 11  // TODO verify
        readonly property real switcherLabel: 13    // TODO verify
        readonly property real launchpadLabel: 11   // TODO verify
        readonly property real launchpadSearch: 20  // header text, TODO verify
        readonly property real dockTooltip: 13      // TODO verify
        readonly property real widgetBig: 34        // TODO verify
        readonly property real widgetSmall: 11      // TODO verify

        readonly property int regular: Font.Normal
        readonly property int medium: Font.Medium
        readonly property int semibold: Font.DemiBold
        readonly property int bold: Font.Bold
    }

    // ---------- colors ----------
    // Label colors follow the AppKit label hierarchy (labelColor, secondaryLabelColor, ...).
    readonly property QtObject color: QtObject {
        readonly property color label: theme.dark ? Qt.rgba(1, 1, 1, 0.85) : Qt.rgba(0, 0, 0, 0.85)
        readonly property color secondaryLabel: theme.dark ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.50)
        readonly property color tertiaryLabel: theme.dark ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.26)
        readonly property color separator: theme.dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.10)
        readonly property color accent: theme.dark ? "#0A84FF" : "#007AFF"           // systemBlue
        readonly property color red: theme.dark ? "#FF453A" : "#FF3B30"
        readonly property color indigo: theme.dark ? "#5E5CE6" : "#5856D6"

        // Menu bar is transparent in macOS 26+; text is white over the wallpaper.
        readonly property color menuBarText: "#FFFFFF"                               // TODO verify (adapts to wallpaper luma)
        readonly property color menuBarHighlight: Qt.rgba(1, 1, 1, 0.22)              // pressed title pill, TODO verify
        readonly property color menuBarBackground: Qt.rgba(0, 0, 0, 0.0)              // "Show menu bar background" off

        // menu highlight
        readonly property color menuSelection: accent
        readonly property color menuSelectionText: "#FFFFFF"


        readonly property color dockDot: theme.dark ? Qt.rgba(1, 1, 1, 0.65) : Qt.rgba(0, 0, 0, 0.55)
        readonly property color tooltipBg: theme.dark ? Qt.rgba(0.16, 0.16, 0.17, 0.92) : Qt.rgba(0.95, 0.95, 0.96, 0.92)
        readonly property color switcherSelection: theme.dark ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(0, 0, 0, 0.12)
        readonly property real disabledOpacity: 0.4      // unavailable CC tiles, TODO verify
    }

    // ---------- glass material ----------
    // QML stand-in for Liquid Glass until the compositor plugin lands.
    readonly property QtObject glass: QtObject {
        readonly property real blurRadius: 40                 // px, magick gaussian sigma ~ radius/2, TODO verify
        // tint over the blurred wallpaper
        readonly property color tint: theme.dark ? Qt.rgba(0.11, 0.11, 0.12, 0.55) : Qt.rgba(0.98, 0.98, 0.99, 0.55)   // TODO verify
        readonly property color tintStrong: theme.dark ? Qt.rgba(0.12, 0.12, 0.13, 0.72) : Qt.rgba(0.97, 0.97, 0.98, 0.74) // menus / spotlight
        // Reduce-transparency solid materials (opaque grey-white / dark grey)
        readonly property color solid: theme.dark ? "#2A2A2C" : "#ECECEE"          // TODO verify
        readonly property color solidDock: theme.dark ? "#303032" : "#E4E4E7"      // TODO verify
        readonly property color tintClear: theme.dark ? Qt.rgba(0.16, 0.16, 0.17, 0.30) : Qt.rgba(1, 1, 1, 0.26)         // Dock: light near-neutral clear glass, TODO glass-defaults.json
        // 1px inner highlight stroke (top-lit rim)
        readonly property color rimTop: theme.dark ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(1, 1, 1, 0.55)                  // specular hairline, top-lit, TODO verify
        readonly property color rimBottom: theme.dark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(1, 1, 1, 0.12)                // TODO verify
        // 0.5px outer hairline that separates glass from light backgrounds
        readonly property color hairline: theme.dark ? Qt.rgba(0, 0, 0, 0.35) : Qt.rgba(0, 0, 0, 0.07)                // TODO verify
        readonly property real rimWidth: 1
        // drop shadow
        readonly property color shadow: Qt.rgba(0, 0, 0, theme.dark ? 0.45 : 0.22)   // TODO verify
        readonly property real shadowRadius: 24         // px of blurMax, TODO verify
        readonly property real shadowYOffset: 8         // TODO verify
    }

    // ---------- menu bar ----------
    readonly property QtObject menuBar: QtObject {
        readonly property int height: 30                 // SPEC.md 7: Solarium menu bar 30 pt (legacy 24)
        readonly property int sidePadding: 14            // left edge to Apple logo / right edge to clock, TODO verify
        readonly property int appleLogoSize: 14          // TODO verify
        readonly property int titleHPadding: 9           // inner padding of a menu title pill, TODO verify
        readonly property int titleSpacing: 2            // gap between pills, TODO verify
        readonly property int titleRadius: 6             // pressed pill radius (macOS 26 rounded), TODO verify
        readonly property int titleHeight: 24            // pressed pill height, TODO verify
        readonly property int statusIconSize: 16         // TODO verify
        readonly property int statusSpacing: 4           // ~20pt icon pitch in reference, TODO verify
        readonly property int statusHPadding: 8          // TODO verify
    }

    // ---------- pull-down menus ----------
    readonly property QtObject menu: QtObject {
        readonly property int radius: 12                 // macOS 26 menus, TODO verify
        readonly property int padding: 5                 // SPEC.md 7: menu top/bottom padding 5
        readonly property int itemHeight: 24             // SPEC.md 7: glass menu line height 24
        readonly property int itemHPadding: 12           // text inset inside highlight, TODO verify
        readonly property int itemInset: 5               // highlight inset from menu edge, TODO verify
        readonly property int itemRadius: 6              // highlight radius, TODO verify
        readonly property int separatorHeight: 11        // incl. spacing, TODO verify
        readonly property int minWidth: 220              // TODO verify
        readonly property int offsetY: 3                 // gap below menu bar, TODO verify
    }

    // ---------- dock ----------
    readonly property QtObject dock: QtObject {
        // iconSize is the icon cell; macOS icon art leaves ~10% transparent margin inside it.
        // SPEC.md 7 (Dock binary): tilesize 64 if the display is > 800 pt tall, else 52
        readonly property int iconSize: 64
        readonly property int iconSizeShort: 52          // displays up to 800 pt tall
        readonly property int magnifiedSize: 128         // SPEC.md 7: largesize default 128
        readonly property real magnifyRange: 1.5         // SPEC.md 7: magnification width 3 x tilesize (1.5 each side)
        readonly property int iconSpacing: 2             // SPEC.md 7: tile inset 1 (each side)
        readonly property int padding: 6                 // SPEC.md 7: distance top 6 (symmetric bottom assumed)
        readonly property int sidePadding: 8             // SPEC.md 7: distance sides 8
        readonly property int radius: 26                 // ~0.34 x dock height, measured from reference (no SPEC value)
        readonly property int bottomMargin: 4            // SPEC.md 7: icons 10 pt above the edge minus padding 6
        readonly property int dotSize: 4                 // running indicator, TODO verify
        readonly property int dotOffset: 1               // dot distance below icon, TODO verify
        readonly property int separatorWidth: 1          // TODO verify
        readonly property int separatorHPad: 6           // TODO verify
        readonly property int separatorInset: 10         // vertical inset of separator, TODO verify
        readonly property int bounceHeight: 28           // launch bounce, TODO verify
        readonly property int tooltipGap: 6
        readonly property int tooltipRadius: 8
        readonly property int tooltipHPad: 10
        readonly property int tooltipHeight: 24
    }

    // ---------- notifications ----------
    readonly property QtObject notif: QtObject {
        readonly property int width: 344                 // TODO verify
        readonly property int radius: 24                 // macOS 26 banner, TODO verify
        readonly property int padding: 14                // TODO verify
        readonly property int iconSize: 34               // TODO verify
        readonly property int iconGap: 10                // icon to text, TODO verify
        readonly property int marginTop: 8               // below menu bar, TODO verify
        readonly property int marginRight: 10            // TODO verify
        readonly property int spacing: 8                 // between stacked banners, TODO verify
        readonly property int timeout: 5000              // ms banner visible
        readonly property int closeSize: 18
        readonly property int maxBodyLines: 4
        readonly property int stackPeek: 8               // visible edge of grouped cards below, TODO verify
    }

    readonly property QtObject nc: QtObject {          // Notification Center (reference ~2x, measured)
        readonly property int width: 328
        readonly property int marginTop: 10
        readonly property int marginRight: 14            // TODO verify
        readonly property int spacing: 16                // between widgets
        readonly property int widgetRadius: 22
        readonly property int widgetSmall: (width - spacing) / 2
        readonly property int widgetPadding: 16
        readonly property color calendarBg: theme.dark ? Qt.rgba(0.17, 0.17, 0.18, 0.92) : Qt.rgba(1, 1, 1, 0.94)
        readonly property color clockBg: "#1C1C1E"
        readonly property color clockFace: "#F5F5F5"
        readonly property color clockHand: "#1C1C1E"
        readonly property color clockSecond: "#FF9500"
    }

    // ---------- control center ----------
    readonly property QtObject cc: QtObject {
        // macOS 26/27 Control Center has no panel background: separate glass
        // modules float over the desktop (reference/screens/macos27-control-center.png, ~2x).
        readonly property int columnWidth: 135           // one module column, measured
        readonly property int gap: 12                    // between modules, measured
        readonly property int width: columnWidth * 2 + gap
        readonly property int tileHeight: 60             // capsule module height, measured
        readonly property int tileRadius: tileHeight / 2 // capsule
        readonly property int tilePadding: 12            // TODO verify
        readonly property int toggleSize: 35             // white circle inside a capsule, measured
        readonly property int sliderTrack: 4             // thin track, measured
        readonly property int sliderInset: 16            // TODO verify
        readonly property int artSize: 38                // Now Playing art placeholder, TODO verify
        readonly property int artRadius: 8
        readonly property int marginTop: 10              // below menu bar, measured
        readonly property int marginRight: 12            // TODO verify
        readonly property color tileTint: Qt.rgba(1, 1, 1, theme.dark ? 0.10 : 0.16)       // clear glass, TODO verify
        readonly property color tileSolid: theme.dark ? "#3A3A3C" : "#8E8E93"
        readonly property color text: "#FFFFFF"
        readonly property color subtext: Qt.rgba(1, 1, 1, 0.78)
        readonly property color toggleOnBg: "#FFFFFF"
        readonly property color toggleOnIcon: theme.dark ? "#0A84FF" : "#007AFF"   // systemBlue (= color.accent)
        readonly property color toggleOffBg: Qt.rgba(1, 1, 1, 0.18)
        readonly property color toggleOffIcon: "#FFFFFF"
        readonly property color sliderTrackColor: Qt.rgba(1, 1, 1, 0.28)
        readonly property color sliderFillColor: "#FFFFFF"
    }

    // ---------- spotlight ----------
    readonly property QtObject spotlight: QtObject {
        // one glass panel: search row, hairline, results (reference/screens/macos27-spotlight.png)
        readonly property int width: 640                 // SPEC.md 7: standardWindowWidth 640
        readonly property int barHeight: 56              // SPEC.md 7: heightCollapsed 56
        readonly property int radius: 28                 // SPEC.md 7: windowCornerRadius 28
        readonly property int resultsRadius: 28          // same window radius when expanded
        readonly property int topFraction: 4             // panel top = screen height / topFraction, TODO verify
        readonly property int iconSize: 20               // magnifier, TODO verify
        readonly property int rowHeight: 38              // TODO verify
        readonly property int rowIcon: 30                // TODO verify
        readonly property int rowRadius: 12              // TODO verify
        readonly property int hPadding: 20               // SPEC.md 7: content inset 20
        readonly property int listInset: 8               // rows inset from panel edge, TODO verify
        readonly property int maxRows: 8
    }

    // ---------- app switcher ----------
    readonly property QtObject switcher: QtObject {
        readonly property int iconSize: 96               // TODO verify
        readonly property int cellPadding: 12            // TODO verify
        readonly property int padding: 18                // TODO verify
        readonly property int radius: 28                 // TODO verify
        readonly property int selectionRadius: 16        // TODO verify
        readonly property int labelHeight: 22            // selected app name row, TODO verify
    }

    // ---------- launchpad / apps ----------
    readonly property QtObject launchpad: QtObject {
        // macOS 27 "Apps" is a centered glass panel (reference/screens/macos27-apps-view.png)
        readonly property real widthFraction: 0.56       // of screen width, measured
        readonly property real heightFraction: 0.50      // of screen height, measured
        readonly property int radius: 26                 // TODO verify
        readonly property int iconSize: 56               // TODO verify
        readonly property int columns: 7
        readonly property int cellHeight: 86             // rows per page = what fits the panel, TODO verify
        readonly property int headerHeight: 52           // TODO verify
        readonly property int padding: 20                // TODO verify
    }

    // ---------- alert dialog ----------
    readonly property QtObject alert: QtObject {
        readonly property int width: 260                 // TODO verify
        readonly property int radius: 26                 // SPEC.md 7: alert window corner radius 26
        readonly property int padding: 20                // TODO verify
        readonly property int iconSize: 64               // TODO verify
        readonly property int spacing: 10                // TODO verify
        readonly property int buttonHeight: 28           // capsule buttons, TODO verify
        readonly property int buttonGap: 8               // TODO verify
        readonly property real titleSize: 13
        readonly property real messageSize: 11
        readonly property color buttonBg: theme.dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.06)
    }

    // ---------- mission control ----------
    readonly property QtObject mission: QtObject {
        readonly property real dim: 0.35                 // backdrop darkening, TODO verify
        readonly property int spacesHeight: 64           // Spaces bar at the top, TODO verify
        readonly property int spaceThumbWidth: 160       // TODO verify
        readonly property int spaceRadius: 8
        readonly property int margin: 60                 // around the window grid, TODO verify
        readonly property int gap: 40                    // between window thumbnails, TODO verify
        readonly property int thumbRadius: 10            // TODO verify
        readonly property real maxScale: 0.8             // windows only shrink in Mission Control, TODO verify
        readonly property real labelSize: 13
    }

    // ---------- animation ----------
    readonly property QtObject anim: QtObject {
        readonly property int fast: 120                  // hover / press
        readonly property int normal: 220                // panels open
        readonly property int bannerIn: 380              // TODO verify
        readonly property int bounce: 340                // one dock bounce up+down, TODO verify
        readonly property int magnify: 90                // dock magnification follow, TODO verify
        readonly property int easing: Easing.OutCubic
    }
}
