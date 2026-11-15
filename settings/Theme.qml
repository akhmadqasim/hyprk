pragma Singleton

import QtQuick
import "HyprK"
import "HyprK/chameleon.js" as Ch

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
    // Icon & widget style (appearance.json iconStyle / iconStyleVariant, set by AppState) with the mode: what
    // Backend.appIconUrl needs to pick an app icon's rendition (RegularLight / RegularDark / RegularAutomatic ...)
    property string iconStyle: "default"
    property string iconStyleVariant: "auto"
    readonly property var iconLook: ({ style: iconStyle, variant: iconStyleVariant, dark: dark })
    property bool reduceTransparency: false
    // Accessibility > Display > Increase contrast: darker borders and separators,
    // stronger secondary text, and no transparency (macOS turns that on with it)
    property bool increaseContrast: false
    property bool compositorBlur: false        // set by AppState from Backend
    // the window's real device pixel ratio (shell.qml, Quickshell); 0 = unknown: Screen.devicePixelRatio, which is the
    // next whole number on a fractional output (2 at scale 1.6)
    property real dpr: 0
    property bool reduceMotion: false          // set by AppState (Accessibility > Motion)
    property real glassTint: 0.5               // set by AppState (Appearance > Liquid Glass), for HyprK Tokens
    readonly property bool translucent: compositorBlur && !reduceTransparency && !increaseContrast
    // Appearance > Theme > Color (state/appearance.json "accent"), set by AppState. Colours: HyprK Accent
    // (measured on 27.2.1). Under Multicolor each app uses its own accent; System Settings has none
    // (accent-colors.json multicolor.appsWithoutAccentKey), so it is Blue #007AFF.
    property string accentName: "multicolor"
    // chameleon tint (MAC-ANSWERS.md C3.1) of the sidebar and the dark window background: the mean colour of the
    // wallpaper under the window (SettingsApp's WallpaperTint), on while Appearance > "Tint window background with
    // wallpaper color" is on (AppState)
    property var chameleon: null
    property bool tintWindow: true
    readonly property color accent: Accent.color

    Component.onCompleted: {
        Tokens.dark = Qt.binding(() => theme.dark);
        Tokens.reduceMotion = Qt.binding(() => theme.reduceMotion);
        Tokens.glassTint = Qt.binding(() => theme.glassTint);
        Tokens.reduceTransparency = Qt.binding(() => theme.reduceTransparency);
        Tokens.increaseContrast = Qt.binding(() => theme.increaseContrast);
        Accent.name = Qt.binding(() => theme.accentName);
        Tokens.fontText = Qt.binding(() => theme.fontText);
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
        readonly property color close: Tokens.lights.close.fill[0]   // swatches (Appearance pane)
        readonly property color minimize: Tokens.lights.minimize.fill[0]
        readonly property color zoom: Tokens.lights.zoom.fill[0]
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
        // (reference/screens/27.2.1/settings-toolbar-{dark,light}.png; Finder's reads 38 / 237)
        // 27.2.1 sampled over Tahoe: #ECEDEE light, #232634 dark (Q-settings-01); window not key: flat #F2F2F2 / #24262B
        readonly property color _rgb: !theme.windowActive ? (theme.dark ? "#24262B" : "#F2F2F2") : (theme.dark ? "#232634" : "#EDEDED")
        // key window: + the chameleon layer, a colour blend of the mean c of the desktop under the window (chameleon.js)
        // at 0.05 light / 0.10 dark, over (OPEN-FIXES 12, R6.1):
        // - light: a neutral #EDEDED. Mac 237 over flat grey 127 (appearance/liquidglass-flat-grey-light.png), (236,237,238)
        //   over TahoeLight (panes/*-light.png); ours 237.0 / (236.5,237.1,237.9). #ECEDEE, the Tahoe reading, counted
        //   Tahoe's tint twice under the blend: (236.0,237.0,237.9) / (235.5,237.1,238.8).
        // - dark: 35.20 + 0.04253 c per channel, the base follows the desktop too (fit on flat red, green, navy, grey 127:
        //   window-dark-flat-*.png, liquidglass-flat-grey-dark.png, rms 1.06; TahoeDark (35.0,36.7,51.2), Mac (35,37,52)).
        //   #232634 (the TahoeDark reading) while the mean is unknown or the tint is off.
        // The inactive sidebar is flat (measured over Tahoe only).
        // Opaque also over compositor blur: the Mac's fill is uniform from x 6 to 200 (Q-settings-01), while 88 %
        // over the blurred TahoeDark read (34..39, 38..40, 68..77) here, light 222..234 (appearance-*.png vs ours)
        readonly property var _ch: theme.windowActive && theme._chOn
            ? Ch.apply(theme.dark ? theme._follow(theme.chameleon, 35.20, 10.85) : _rgb, theme.chameleon, theme.dark) : null
        readonly property color fill: _ch ? Qt.rgba(_ch.r, _ch.g, _ch.b, 1) : _rgb
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
        readonly property real switchRowHeight: 37.5  // a row whose only control is a switch (desktop-dock-light.png: 75 px pitch)
        readonly property int rowPadding: 10
        readonly property int separatorInset: 10
        readonly property int heroIcon: 50           // pane header tile: 50 pt (general-00-light.png, R3.8b: ink 922..1021 px)
    }

    // controls and their motion: Tokens.control, Tokens.motion (HyprK Switch, Slider, Popup, Button)

    // ---------- colors ----------
    // the window is key (SettingsApp sets it; snapshots force it on)
    property bool windowActive: true
    // the chameleon colour is known and "Tint window background with wallpaper color" is on
    readonly property bool _chOn: theme.tintWindow && !!theme.chameleon
    // base + k x c per channel (c: the chameleon colour, 0..1; base, k in 0..255 levels) as {r, g, b} in 0..1
    function _follow(c, base, k) { return { r: (base + k * c.r) / 255, g: (base + k * c.g) / 255, b: (base + k * c.b) / 255 }; }
    // window background: #FFFFFF light, also over grey 127 and not key (liquidglass-flat-grey-light.png,
    // desktop-dock-inactive-light-*.png: 255, cards 247), so no tint in light. Dark key window: 28.24 + 0.0525 c per
    // channel, a 5.25 % blend of the desktop's mean under the window over grey 29.8 (OPEN-FIXES 12, R6.1: flat red,
    // green, navy, grey 127, rms 0.23; TahoeDark (30.4,31.0,36.5), Mac (30.5,31,36.5)); #1E1F24 (the TahoeDark
    // reading, Q-settings-11) while the mean is unknown or the tint is off. Dark, not key: flat #1D1E20, measured over
    // TahoeDark only (desktop-dock-inactive-dark-iconDark.png (29,30,32), its cards (36,37,39) = this + cardFill)
    readonly property var _win: theme._chOn ? theme._follow(theme.chameleon, 28.24, 13.39) : null
    readonly property color windowBg: !theme.dark ? "#FFFFFF" : !theme.windowActive ? "#1D1E20"
        : _win ? Qt.rgba(_win.r, _win.g, _win.b, 1) : "#1E1F24"
    // cards: the content's primary colour at 3 %, no stroke, no shadow. 27.2.1: a grouped Form section is DesignLibrary
    // MacGroupBox (body 0x195de9758), filled with SeximalShapeStyle = Color.primary at opacity 0.03 (resolve
    // 0x195f89be4, the double 0x3f9eb851eb851eb8; reference/re/27.2.1/GAPS-REA-windows.md 1d). Over the window
    // background that is the measured #F7F7F7 / #25262B (255 x .97 = 247; (30,31,36) + 3 % white = (37,38,43)); they
    // were written as those opaque colours, which is the same pixel here and wrong over any other background
    readonly property color cardFill: theme.dark ? Qt.rgba(1, 1, 1, 0.03) : Qt.rgba(0, 0, 0, 0.03)
    readonly property color cardStroke: theme.increaseContrast ? (theme.dark ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(0, 0, 0, 0.45))
        : "transparent"
    // row separator: #EBEBEB on #F7F7F7, #2F3035 on #25262B (2 px at 2x in desktop-dock-*.png)
    readonly property color separator: theme.increaseContrast ? (theme.dark ? Qt.rgba(1, 1, 1, 0.35) : Qt.rgba(0, 0, 0, 0.3))
        : theme.dark ? Qt.rgba(1, 1, 1, 0.046) : Qt.rgba(0, 0, 0, 0.05)
    // toolbar title #4C4C4C / #E8E8E9 (Q-settings-13); scroll-edge hairline at y 52, 0.5 pt, #E5E5E5 on white /
    // #2E2F33 on #1E1F24 (PC #60 section 5, appearance-scroll-010-*.png; was #DEDEDE / #34353A from Q-settings-04)
    // window not key: #BDBDBD / #5C5D5E (Q-settings-06, desktop-dock-inactive-*.png read 189 / 91..93)
    readonly property color toolbarTitle: !theme.windowActive ? (theme.dark ? "#5C5D5E" : "#BDBDBD")
        : theme.dark ? "#E8E8E9" : "#4C4C4C"
    // an alpha line, not a solid colour: black .10 / white .07 (TOOLBAR-REA §1 separator, as Finder's) fits both readings,
    // #E5E5E5 over white and 222 over the #F7F7F7 card; #2E2F33 over #1E1F24 and (52,53,58) over the #25262B card
    // (settings/scroll-edge-keyboard-*.png row 104)
    readonly property color scrollEdge: theme.dark ? Qt.rgba(1, 1, 1, theme.increaseContrast ? 0.65 : 0.07)
        : Qt.rgba(0, 0, 0, theme.increaseContrast ? 0.65 : 0.10)
    // dark: the whole toolbar strip, capsule included, lightens while the pointer is in it
    // (settings/toolbar-backforward-rest-hover-press-dark.png: strip 31 -> 39, capsule 61 -> 68, white at 8 / 224 =
    // 7 / 194 = .036 over both; Finder the same, MAC-ANSWERS Q-finder-10 "Dark only"). Light: none (Q-finder-10)
    readonly property color toolbarHoverWash: theme.dark ? Qt.rgba(1, 1, 1, 0.036) : "transparent"
    // content under the 52 pt toolbar strip: HyprK ScrollEdge (AppKit's scroll pocket, blurred and veiled)
    readonly property color label: theme.dark ? Qt.rgba(1, 1, 1, 0.85) : Qt.rgba(0, 0, 0, 0.85)
    readonly property color secondaryLabel: theme.increaseContrast ? (theme.dark ? Qt.rgba(1, 1, 1, 0.75) : Qt.rgba(0, 0, 0, 0.7))
        : theme.dark ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.51) // ref #7D7C7B
    readonly property color tertiaryLabel: Tokens.tertiaryLabel
    readonly property color controlFill: Tokens.control.pushFill
    readonly property color previewCard: theme.dark ? "#131210" : "#E8E5E0"         // Liquid Glass preview text card (appearance-*.png)
    readonly property color shadow: Qt.rgba(0, 0, 0, theme.dark ? 0.55 : 0.28)

    // Pane icon tile colors (System Settings palette), TODO verify all
    readonly property var tile: ({
        blue: "#0A84FF", indigo: "#5E5CE6", purple: "#AF52DE", pink: "#FF2D55",
        red: "#FF3B30", orange: "#FF9500", yellow: "#FFCC00", green: "#34C759",
        teal: "#30B0C7", gray: "#8E8E93", graphite: "#636366", black: "#1C1C1E"
    })
}
