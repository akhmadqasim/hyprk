pragma Singleton

import QtQuick

// Every metric and color of the Settings app lives here.
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
    readonly property bool translucent: compositorBlur && !reduceTransparency && !increaseContrast
    // "transparent" = multicolor/blue default (systemBlue)
    property color accentOverride: "transparent"
    readonly property color accent: accentOverride.a > 0 ? accentOverride : (dark ? "#0A84FF" : "#0071F5") // ref (light)

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
    // Weights: SFNS is a variable font, and Qt fakes bold unless the wght axis is set.
    // Use both on every weighted Text:  font.weight: Theme.fw(W); font.variableAxes: Theme.axes(W)
    function fw(w) { return _sfName ? Font.Normal : w; }
    function axes(w) { return _sfName ? { "wght": w } : {}; }

    // Generic glyph font for pane icons when themes/icons/settings/<id>.svg is missing.
    readonly property string fontGlyph: "Material Icons"

    readonly property QtObject font: QtObject {
        readonly property real body: 13         // NSFont.systemFontSize, TODO verify
        readonly property real small: 11        // footnotes, account subtitle, TODO verify
        readonly property real title: 16        // ref toolbar title (bold)
        readonly property real sectionHeader: 13 // bold group header above a card, TODO verify
    }

    // ---------- window ----------
    readonly property QtObject window: QtObject {
        readonly property int width: 745              // ref
        readonly property int height: 630             // ref (1260 px at 2x)
        readonly property int minWidth: 680          // TODO verify
        readonly property int minHeight: 420         // TODO verify
        readonly property int radius: 26             // macOS 26 toolbar window corner, TODO verify
        readonly property int toolbarHeight: 52      // ref: lights/nav centered at 26
    }

    // ---------- traffic lights ----------
    readonly property QtObject lights: QtObject {
        readonly property int size: 14               // ref
        readonly property int spacing: 9             // gap between buttons, TODO verify
        readonly property int left: 19               // ref: first button edge
        readonly property color close: "#FF5F57"
        readonly property color minimize: "#FEBC2E"
        readonly property color zoom: "#28C840"
        readonly property color inactive: theme.dark ? "#4D4D50" : "#D6D6D8"
        readonly property color border: Qt.rgba(0, 0, 0, 0.12)
        readonly property color glyph: Qt.rgba(0, 0, 0, 0.55)
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
        readonly property int searchHeight: 28       // ref
        readonly property int searchRadius: 14       // ref capsule
        readonly property int accountAvatar: 40      // TODO verify
        // ref (238,236,234). Over compositor blur it is 88 % opaque so the desktop only
        // softly shows through; otherwise (no blur, Reduce transparency) it is flat.
        readonly property color fill: theme.translucent
            ? (theme.dark ? Qt.rgba(0.165, 0.165, 0.173, 0.88) : Qt.rgba(0.933, 0.925, 0.918, 0.88))
            : (theme.dark ? "#2A2A2C" : "#EEECEA")
        readonly property color stroke: theme.increaseContrast ? (theme.dark ? Qt.rgba(1, 1, 1, 0.4) : Qt.rgba(0, 0, 0, 0.4))
            : theme.dark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.05)
        readonly property color selection: theme.accent
        readonly property color selectionText: "#FFFFFF"
        readonly property color searchFill: theme.dark ? Qt.rgba(1, 1, 1, 0.07) : Qt.rgba(0, 0, 0, 0.04)    // ref #EAE9E7 over sidebar
        readonly property color searchStroke: theme.dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(1, 1, 1, 0.85) // ref light rim
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

    // ---------- controls ----------
    readonly property QtObject control: QtObject {
        readonly property int switchWidth: 38        // TODO verify
        readonly property int switchHeight: 22       // TODO verify
        readonly property int popupHeight: 22         // ref
        readonly property int popupChevron: 20        // ref round chevron button
        readonly property int sliderTrack: 4         // TODO verify
        readonly property int sliderKnobW: 24        // macOS 26 capsule knob, TODO verify
        readonly property int sliderKnobH: 16        // TODO verify
        readonly property int buttonHeight: 24       // TODO verify
        readonly property int buttonRadius: 12       // capsule push button (macOS 26), TODO verify
        readonly property int animMs: 180            // TODO verify
    }

    // ---------- colors ----------
    readonly property color windowBg: theme.dark ? "#1E1E1E" : "#FFFFFF"          // TODO verify
    readonly property color cardFill: theme.dark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.03) // ref #F7F7F7 on white
    readonly property color cardStroke: theme.increaseContrast ? (theme.dark ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(0, 0, 0, 0.45))
        : theme.dark ? Qt.rgba(1, 1, 1, 0.04) : Qt.rgba(0, 0, 0, 0.0) // ref: no visible stroke
    readonly property color separator: theme.increaseContrast ? (theme.dark ? Qt.rgba(1, 1, 1, 0.35) : Qt.rgba(0, 0, 0, 0.3))
        : theme.dark ? Qt.rgba(1, 1, 1, 0.09) : Qt.rgba(0, 0, 0, 0.055) // ref #EBEBEB on card
    readonly property color label: theme.dark ? Qt.rgba(1, 1, 1, 0.88) : Qt.rgba(0, 0, 0, 0.85)
    readonly property color secondaryLabel: theme.increaseContrast ? (theme.dark ? Qt.rgba(1, 1, 1, 0.75) : Qt.rgba(0, 0, 0, 0.7))
        : theme.dark ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.51) // ref #7D7C7B
    readonly property color tertiaryLabel: theme.dark ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.26)
    readonly property color controlFill: theme.dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.08) // ref popup circle #E4E4E5
    readonly property color controlFillPressed: theme.dark ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(0, 0, 0, 0.12)
    readonly property color switchOff: theme.dark ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(0, 0, 0, 0.09)
    readonly property color knob: "#FFFFFF"
    readonly property color menuFill: theme.dark ? "#2C2C2E" : "#F6F6F6"            // popup menu, TODO verify
    readonly property color previewStrip: theme.dark ? "#2C2C2E" : "#ECEAE7"        // Liquid Glass preview title, ref
    readonly property color shadow: Qt.rgba(0, 0, 0, theme.dark ? 0.55 : 0.28)

    // Pane icon tile colors (System Settings palette), TODO verify all
    readonly property var tile: ({
        blue: "#0A84FF", indigo: "#5E5CE6", purple: "#AF52DE", pink: "#FF2D55",
        red: "#FF3B30", orange: "#FF9500", yellow: "#FFCC00", green: "#34C759",
        teal: "#30B0C7", gray: "#8E8E93", graphite: "#636366", black: "#1C1C1E"
    })
}
