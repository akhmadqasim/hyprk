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
        readonly property int width: 745              // ref
        readonly property int height: 630             // ref (1260 px at 2x)
        readonly property int minWidth: 680          // TODO verify
        readonly property int minHeight: 420         // TODO verify
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
        readonly property int width: 232             // ref (flush with the window's left edge)
        // Appearance > Sidebar icon size. SPEC.md 7 (_NSSidebarMetrics_Solarium):
        // row 24/32/40, font 11/13/15; icon measured 21 at medium (ref), others scaled.
        property string size: "medium"
        readonly property int _i: Math.max(0, ["small", "medium", "large"].indexOf(size))
        readonly property int rowHeight: [24, 32, 40][_i]
        readonly property int fontSize: [11, 13, 15][_i]
        readonly property int rowRadius: 10          // ref selection pill
        readonly property int rowMargin: 10          // ref pill inset from sidebar edges
        readonly property int iconLeft: 8            // ref icon inset inside the pill
        readonly property int iconSize: [16, 21, 26][_i]   // medium = ref, S/L TODO verify
        readonly property int iconLabelGap: 7        // ref
        readonly property int groupGap: 13          // ref
        readonly property int searchTop: 61          // ref
        readonly property int accountAvatar: 40      // TODO verify
        // 27.2.1 System Settings sidebar over a plain desktop: (37,38,38) dark, (237,237,237) light
        // (reference/screens/27.2.1/settings-toolbar-{dark,light}.png; Finder's reads 38 / 237). Over compositor
        // blur it is 88 % opaque so the desktop only softly shows through; otherwise (no blur, Reduce
        // transparency) it is flat.
        readonly property color fill: theme.translucent
            ? (theme.dark ? Qt.rgba(37 / 255, 38 / 255, 38 / 255, 0.88) : Qt.rgba(237 / 255, 237 / 255, 237 / 255, 0.88))
            : (theme.dark ? "#252626" : "#EDEDED")
        readonly property color stroke: theme.increaseContrast ? (theme.dark ? Qt.rgba(1, 1, 1, 0.4) : Qt.rgba(0, 0, 0, 0.4))
            : theme.dark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.05)
        readonly property color selection: theme.accent
        readonly property color selectionText: "#FFFFFF"
    }

    // ---------- content (grouped inset form) ----------
    readonly property QtObject content: QtObject {
        readonly property int padding: 21            // ref
        readonly property int maxWidth: 520           // ref card width is 466 at 745 window
        readonly property int sectionGap: 12          // ref card to card
        readonly property int headerGap: 8            // ref header to card
        readonly property int headerTop: 18           // ref extra space above a section header
        readonly property int cardRadius: 12          // ref ~11-12
        readonly property int rowHeight: 37           // ref
        readonly property int rowPadding: 10          // ref
        readonly property int separatorInset: 10      // ref
        readonly property int heroIcon: 56           // pane header icon, TODO verify
    }

    // controls and their motion: Tokens.control, Tokens.motion (HyprK Switch, Slider, Popup, Button)

    // ---------- colors ----------
    readonly property color windowBg: Tokens.windowBackground
    readonly property color cardFill: Tokens.groupFill
    readonly property color cardStroke: theme.increaseContrast ? (theme.dark ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(0, 0, 0, 0.45))
        : theme.dark ? Qt.rgba(1, 1, 1, 0.04) : Qt.rgba(0, 0, 0, 0.0) // ref: no visible stroke
    readonly property color separator: theme.increaseContrast ? (theme.dark ? Qt.rgba(1, 1, 1, 0.35) : Qt.rgba(0, 0, 0, 0.3))
        : theme.dark ? Qt.rgba(1, 1, 1, 0.09) : Qt.rgba(0, 0, 0, 0.055) // ref #EBEBEB on card
    readonly property color label: theme.dark ? Qt.rgba(1, 1, 1, 0.88) : Qt.rgba(0, 0, 0, 0.85)
    readonly property color secondaryLabel: theme.increaseContrast ? (theme.dark ? Qt.rgba(1, 1, 1, 0.75) : Qt.rgba(0, 0, 0, 0.7))
        : theme.dark ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.51) // ref #7D7C7B
    readonly property color tertiaryLabel: Tokens.tertiaryLabel
    readonly property color controlFill: Tokens.control.fill
    readonly property color previewStrip: theme.dark ? "#2C2C2E" : "#ECEAE7"        // Liquid Glass preview title, ref
    readonly property color shadow: Qt.rgba(0, 0, 0, theme.dark ? 0.55 : 0.28)

    // Pane icon tile colors (System Settings palette), TODO verify all
    readonly property var tile: ({
        blue: "#0A84FF", indigo: "#5E5CE6", purple: "#AF52DE", pink: "#FF2D55",
        red: "#FF3B30", orange: "#FF9500", yellow: "#FFCC00", green: "#34C759",
        teal: "#30B0C7", gray: "#8E8E93", graphite: "#636366", black: "#1C1C1E"
    })
}
