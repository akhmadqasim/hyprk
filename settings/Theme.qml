pragma Singleton

import QtQuick
import "HyprK"

// Every metric and color of the Settings app lives here, as a layer over the shared HyprK Tokens
// (ui/HyprK): it feeds Tokens this app's appearance and keeps only what is Settings' own.
// Units are logical pixels (1 pt on macOS == 1 px here).
// Sources, in order: /mnt/code/liquid-glass-re/SPEC.md "Layout metrics" (empty so far),
// "ref" = measured from reference/screens/macos27-system-settings-appearance.webp (2x),
// otherwise macOS 26/27 best guesses marked "TODO verify".
QtObject {
    id: theme

    // ---------- appearance (driven by AppState from state/appearance.json) ----------
    property bool dark: false
    property bool reduceTransparency: false
    // Accessibility > Display > Increase contrast: darker borders and separators,
    // stronger secondary text, and no transparency (macOS turns that on with it)
    property bool increaseContrast: false
    property bool compositorBlur: false        // set by AppState from Backend
    property bool reduceMotion: false          // set by AppState (Accessibility > Motion)
    readonly property bool translucent: compositorBlur && !reduceTransparency && !increaseContrast
    // Appearance > Theme > Color (state/appearance.json "accent"), set by AppState. Colours: HyprK Accent
    // (measured on 27.2.1). Under Multicolor each app uses its own accent; System Settings has none
    // (accent-colors.json multicolor.appsWithoutAccentKey), so it is Blue #007AFF.
    property string accentName: "multicolor"
    readonly property color accent: Accent.color

    Component.onCompleted: {
        Tokens.dark = Qt.binding(() => theme.dark);
        Tokens.reduceMotion = Qt.binding(() => theme.reduceMotion);
        Tokens.reduceTransparency = Qt.binding(() => theme.reduceTransparency);
        Tokens.increaseContrast = Qt.binding(() => theme.increaseContrast);
        Accent.name = Qt.binding(() => theme.accentName);
        Tokens.fontText = Qt.binding(() => theme.fontText);
        Tokens.fontGlyph = Qt.binding(() => theme.fontGlyph);
        // measured on the reference Settings window (below), so the controls match the panes
        Tokens.label = Qt.binding(() => theme.label);
        Tokens.switchSize = "mini";   // Settings' form rows use mini switches, 36 x 16 (MAC-ANSWERS.md Q-settings-16)
        Tokens.secondaryLabel = Qt.binding(() => theme.secondaryLabel);
    }

    // ---------- fonts (SF Pro if installed, else Inter, Cantarell, Noto Sans) ----------
    readonly property var _families: Qt.fontFamilies()
    function pickFont(list) {
        for (const f of list)
            if (_families.indexOf(f) !== -1)
                return f;
        return list[list.length - 1];
    }
    // SFNS.ttf (variable "System Font") from themes/fonts, loaded directly so no font install is needed.
    property FontLoader _sf: FontLoader { source: "file://" + Backend.root + "/themes/fonts/SFNS.ttf" }
    readonly property string _sfName: _sf.status === FontLoader.Ready ? _sf.name : ""
    // One family for text and display: SFNS has optical sizes built in.
    readonly property string fontText: _sfName || pickFont(["SF Pro", "Inter", "Cantarell", "Noto Sans", "Sans Serif"])
    readonly property string fontDisplay: fontText
    // Text: MacText (size + wght) or a whole style, font: Typography.body (HyprK Typography: the 27.2.1 text
    // styles with optical size, tracking and real weights on SF's axes)

    // Generic glyph font for pane icons when themes/icons/settings/<id>.svg is missing.
    readonly property string fontGlyph: "Material Icons"

    readonly property QtObject font: QtObject {
        readonly property real body: Typography.styles.body.size          // 13: form labels measured on 27.2.1
        readonly property real small: Typography.styles.subheadline.size  // 11: footnotes, account subtitle
        readonly property real title: 15        // toolbar title: Typography.toolbarTitle, 15 Semibold (27.2.1)
        readonly property real sectionHeader: Typography.styles.headline.size  // 13 Bold group header
    }

    // ---------- window ----------
    readonly property QtObject window: QtObject {
        // MAC-ANSWERS.md Q-settings-03: 740 x 625; the width is fixed (it follows the sidebar), only the height
        // resizes, min 470
        readonly property int width: 508 + sidebar.width
        readonly property int height: 625
        readonly property int minWidth: width
        readonly property int minHeight: 470
        // 27.2.1: same corner as Finder (identical alpha profile in settings-toolbar-light.png and
        // finder-toolbar-light.png), 16 pt (MAC-ANSWERS.md Q-windows-02, Tokens.frame)
        readonly property int radius: Tokens.frame.radius
        readonly property int toolbarHeight: 52      // ref: lights/nav centered at 26
    }

    // ---------- traffic lights (SPEC 13, Tokens.lights) ----------
    readonly property QtObject lights: QtObject {
        readonly property int left: 19               // ref: 2x System Settings shot, 18.75 pt from the window edge (top 19 = centred in the 52 pt toolbar)
        readonly property color close: Tokens.lights.closeSet[0]   // swatches (Appearance pane)
        readonly property color minimize: Tokens.lights.minimizeSet[0]
        readonly property color zoom: Tokens.lights.zoomSet[0]
    }

    // ---------- sidebar ----------
    readonly property QtObject sidebar: QtObject {
        // Appearance > Sidebar icon size (MAC-ANSWERS.md Q-settings-01, -05, -07; AX of the 27.2.1 window)
        property string size: "medium"
        readonly property int _i: Math.max(0, ["small", "medium", "large"].indexOf(size))
        readonly property int width: [228, 232, 246][_i]   // flush with the window's left edge, no radius of its own
        readonly property int rowHeight: [24, 32, 40][_i]
        readonly property int fontSize: [11, 13, 15][_i]
        readonly property real rowRadius: 8.5        // selection pill
        readonly property int rowMargin: 10          // pill (cell) x 10 .. width - 10
        readonly property real iconSize: [14, 20, 26][_i]   // tile; small "about 13-14"
        readonly property real iconCenter: 19        // tile centre in the cell (medium tile at window x 19..39)
        readonly property real labelLeft: [32.5, 36, 38.5][_i]   // label x in the cell (window 42.5 / 46 / 48.5)
        readonly property int groupGap: 13           // 0-height spacer rows
        readonly property int searchTop: 61          // search field 212 x 28 at (10, 61)
        readonly property int listTop: 98            // the list starts at y 98
        readonly property int accountHeight: 46      // Apple Account row (the button 141.5 x 38 at x 16)
        readonly property int accountAvatar: 38
        // 27.2.1 System Settings sidebar over a plain desktop: (37,38,38) dark, (237,237,237) light
        // (reference/screens/27.2.1/settings-toolbar-{dark,light}.png; Finder's reads 38 / 237). Over compositor
        // blur it is 88 % opaque so the desktop only softly shows through; otherwise (no blur, Reduce
        // transparency) it is flat.
        // 27.2.1 sampled over Tahoe: #ECEDEE light, #232634 dark (Q-settings-01); window not key: flat #F2F2F2 / #24262B
        readonly property color _rgb: !theme.windowActive ? (theme.dark ? "#24262B" : "#F2F2F2") : (theme.dark ? "#232634" : "#ECEDEE")
        readonly property color fill: theme.translucent && theme.windowActive ? Qt.alpha(_rgb, 0.88) : _rgb
        // 0.5 pt divider on the right: #D3D4D5 / #3F424D
        readonly property real strokeWidth: 0.5
        readonly property color stroke: theme.increaseContrast ? (theme.dark ? Qt.rgba(1, 1, 1, 0.4) : Qt.rgba(0, 0, 0, 0.4))
            : theme.dark ? "#3F424D" : "#D3D4D5"
        // selected row: the flat accent pill with white Semibold text; grey with label text while the window is not
        // key or the list is not first responder (Q-settings-05). No hover fill.
        readonly property color selection: Tokens.control.accentOn
        readonly property color selectionInactive: theme.dark ? "#323439" : "#E7E7E7"
        readonly property color selectionText: "#FFFFFF"
        readonly property color labelInactive: theme.dark ? "#717378" : "#8C8C8C"   // labels of a window that is not key
    }

    // ---------- content (grouped inset form) ----------
    readonly property QtObject content: QtObject {
        // MAC-ANSWERS.md Q-settings-11, -12: cards 468 wide at x 252 (20 pt margins in the 508 pt content area)
        readonly property int padding: 20
        readonly property int maxWidth: 468
        readonly property int top: 12                 // first heading (or card) 12 below the toolbar
        readonly property int sectionGap: 10          // card to card
        readonly property int headerGap: 10           // heading (16 tall) to card
        readonly property int headerTop: 20           // card to the next heading 30 = sectionGap + headerTop
        readonly property int cardRadius: 13          // about 13, continuous
        readonly property int rowHeight: 38           // 1-line row with a pop-up 38, with a switch 37.5
        readonly property int rowPadding: 10
        readonly property int separatorInset: 10
        readonly property int heroIcon: 56           // pane header icon, TODO verify
    }

    // controls and their motion: Tokens.control, Tokens.motion (HyprK Switch, Slider, Popup, Button)

    // ---------- colors ----------
    // the window is key (SettingsApp sets it; snapshots force it on)
    property bool windowActive: true
    // window background: #FFFFFF / #1E1F24 (dark is wallpaper-tinted on the Mac; #202127 in the probe) (Q-settings-11)
    readonly property color windowBg: theme.dark ? "#1E1F24" : "#FFFFFF"
    // cards: solid, no stroke, no shadow: #F7F7F7 / #25262B
    readonly property color cardFill: theme.dark ? "#25262B" : "#F7F7F7"
    readonly property color cardStroke: theme.increaseContrast ? (theme.dark ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(0, 0, 0, 0.45))
        : "transparent"
    // row separator: #EBEBEB on #F7F7F7, #2F3035 on #25262B (2 px at 2x in desktop-dock-*.png)
    readonly property color separator: theme.increaseContrast ? (theme.dark ? Qt.rgba(1, 1, 1, 0.35) : Qt.rgba(0, 0, 0, 0.3))
        : theme.dark ? Qt.rgba(1, 1, 1, 0.046) : Qt.rgba(0, 0, 0, 0.05)
    // toolbar title #4C4C4C / #E8E8E9 (Q-settings-13); scroll-edge hairline at y 52, 0.5 pt, #E5E5E5 on white /
    // #2E2F33 on #1E1F24 (PC #60 section 5, appearance-scroll-010-*.png; was #DEDEDE / #34353A from Q-settings-04)
    readonly property color toolbarTitle: theme.dark ? "#E8E8E9" : "#4C4C4C"
    readonly property color scrollEdge: theme.dark ? "#2E2F33" : "#E5E5E5"
    // content under the 52 pt toolbar strip fades into the window background (scroll edge effect). The Mac also
    // blurs it; drawn here as a window-background veil, a.9 at the top to a.75 at the hairline. The Mac's strip lets
    // more through (appearance-scroll-250-*.png: photo colours lightened, light ~#B5B9AF, dark ~#3B3F3C), but its blur
    // keeps text under the title unreadable; without a blur a thinner veil lets rows clash with the title.
    readonly property real scrollEdgeFadeTop: 0.9
    readonly property real scrollEdgeFadeBottom: 0.75
    readonly property color label: theme.dark ? Qt.rgba(1, 1, 1, 0.85) : Qt.rgba(0, 0, 0, 0.85)
    readonly property color secondaryLabel: theme.increaseContrast ? (theme.dark ? Qt.rgba(1, 1, 1, 0.75) : Qt.rgba(0, 0, 0, 0.7))
        : theme.dark ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.51) // ref #7D7C7B
    readonly property color tertiaryLabel: Tokens.tertiaryLabel
    readonly property color controlFill: Tokens.control.pushFill
    readonly property color previewStrip: theme.dark ? "#2C2C2E" : "#ECEAE7"        // Liquid Glass preview title, ref
    readonly property color shadow: Qt.rgba(0, 0, 0, theme.dark ? 0.55 : 0.28)

    // Pane icon tile colors (System Settings palette), TODO verify all
    readonly property var tile: ({
        blue: "#0A84FF", indigo: "#5E5CE6", purple: "#AF52DE", pink: "#FF2D55",
        red: "#FF3B30", orange: "#FF9500", yellow: "#FFCC00", green: "#34C759",
        teal: "#30B0C7", gray: "#8E8E93", graphite: "#636366", black: "#1C1C1E"
    })
}
