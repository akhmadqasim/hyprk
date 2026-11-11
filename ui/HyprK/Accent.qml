pragma Singleton

import QtQuick

// The accent palette of macOS 27.2.1 (Appearance > Theme > Color), for the shell, Settings and Finder.
// Measured per accent in light and dark (reference/re/MAC-ANSWERS.md R5, reference/re/27.2.1/live/accent-colors.json).
// Each app's Theme sets `name` from state/appearance.json "accent"; Tokens.accent follows `color`.
QtObject {
    id: a

    // ---------- inputs ----------
    property bool dark: Tokens.dark
    // multicolor (AppleAccentColor absent), graphite (-1), red 0, orange 1, yellow 2, green 3, blue 4, purple 5, pink 6
    property string name: "multicolor"
    // Multicolor only: the app's own accent (Info.plist NSAccentColorName), transparent = none. Apps without
    // one get Blue #007AFF. System Settings, Finder, Music, Photos, Safari, ... have none (accent-colors.json
    // multicolor.appsWithoutAccentKey), and neither have the shell's surfaces, so this stays unset in hyprk.
    property color appAccent: "transparent"
    // Text highlight colour: "" = Automatic (follows the accent; AppleHighlightColor absent), else an accent name
    property string highlight: ""

    // the 9 choices in the pane's order (NSColorEnumerateUserAccentColors -2, 4, 5, 6, 0, 1, 2, 3, -1)
    readonly property var names: ["multicolor", "blue", "purple", "pink", "red", "orange", "yellow", "green", "graphite"]

    // per accent, [light, dark]: controlAccent, selectedContentBackground, selectedTextBackground (= selectedControl),
    // keyboardFocusIndicator (alpha 0.5 unless noted). Multicolor without an app accent = Blue.
    readonly property var table: ({
        blue:     { accent: ["#007AFF", "#007AFF"], content: ["#0064E1", "#0059D1"], text: ["#B3D7FF", "#3F638B"], focus: ["#800067F4", "#801AA9FF"] },
        purple:   { accent: ["#953D96", "#A550A7"], content: ["#7D2A7E", "#803482"], text: ["#DFC5E0", "#705771"], focus: ["#80842685", "#80DC78DE"] },
        pink:     { accent: ["#F74F9E", "#F74F9E"], content: ["#D93B86", "#C93379"], text: ["#FDCBE2", "#89576E"], focus: ["#80EC398D", "#80FF77D4"] },
        red:      { accent: ["#E0383E", "#FF5257"], content: ["#C4262B", "#D13539"], text: ["#F6C4C5", "#8B5759"], focus: ["#80D32127", "#80FF7A80"] },
        orange:   { accent: ["#F7821B", "#F7821B"], content: ["#D96B0A", "#C96003"], text: ["#FDDABB", "#896647"], focus: ["#80EC7002", "#80FFB33A"] },
        yellow:   { accent: ["#FFC726", "#FFC600"], content: ["#E1AC15", "#D19E00"], text: ["#FFEEBE", "#8B7A3F"], focus: ["#80F4B90E", "#80FFFF1A"] },
        green:    { accent: ["#62BA46", "#62BA46"], content: ["#4DA033", "#43932A"], text: ["#D0EAC8", "#5C7654"], focus: ["#804EAB30", "#808DF56C"] },
        graphite: { accent: ["#989898", "#8C8C8C"], content: ["#808080", "#696969"], text: ["#E0E0E0", "#696969"], focus: ["#99999E", "#80C3C3C3"] }
    })
    readonly property int _i: dark ? 1 : 0
    readonly property bool _app: name === "multicolor" && appAccent.a > 0
    readonly property var _row: table[name] ?? table.blue   // multicolor and unknown names = Blue

    // ---------- outputs ----------
    // controlAccentColor: switches, checkboxes, sliders, default buttons, menu selection
    readonly property color color: _app ? appAccent : _row.accent[_i]
    // selectedContentBackgroundColor: selected rows in a focused table or outline (Finder list, sidebar)
    readonly property color selectedContent: _app ? Qt.darker(appAccent, 1.14) : _row.content[_i]   // app accent: guessed
    // selectedTextBackgroundColor (= selectedControlColor): text selection. An app accent's highlight is 30 % of
    // it over white (light) or over #5A5A5A (dark): fits Notes #FCB827 -> #FEEABF / #8A764B and Blue's row.
    // The Graphite highlight chosen by hand is white a.247 in dark; under the Graphite accent with Automatic it is
    // the table's #696969 (accent-colors.json highlightColor.graphiteHighlightDark).
    readonly property color selectedText: highlight === "graphite" && dark ? Qt.rgba(1, 1, 1, 0.247)
        : highlight !== "" && table[highlight] ? table[highlight].text[_i]
        : _app ? Qt.tint(dark ? "#5A5A5A" : "#FFFFFF", Qt.rgba(appAccent.r, appAccent.g, appAccent.b, 0.3))
        : _row.text[_i]
    readonly property color focusRing: _app ? Qt.rgba(color.r, color.g, color.b, 0.5) : _row.focus[_i]
    // the same for every accent
    readonly property color unemphasizedSelectedContent: dark ? "#464646" : "#DCDCDC"
    readonly property color link: dark ? "#419CFF" : "#0068DA"
    readonly property color selectedMenuItemText: "#FFFFFF"
    readonly property color alternateSelectedControlText: "#FFFFFF"
    readonly property color findHighlight: "#FFFF00"
    // 27 system palette: systemBlue is #0088FF / #0091FF (apps whose catalog accent names systemBlue: Mail,
    // Contacts, TV), not the accent Blue #007AFF
    readonly property color systemBlue: dark ? "#0091FF" : "#0088FF"

    // ---------- swatches (Appearance pane) ----------
    // fill of each choice's circle (swatchCenter in accent-colors.json = controlAccent)
    function swatch(n) { return (table[n] ?? table.blue).accent[_i]; }
    // NSMulticolorAccent (AppKit Assets.car, reference/screens/27.2.1/multicolor-swatch.png): a saturated conic
    // wheel, the same in light and dark. Sampled at radius 12 of 16 px every 30 deg counter-clockwise from 3 o'clock.
    readonly property var multicolorStops: ["#FD193D", "#FF358F", "#CB33BB", "#9E36DA", "#6D49E1", "#4061E6",
                                            "#2487E2", "#01B8D7", "#44B982", "#9BB717", "#FCB004", "#FD7207"]
    // NSMulticolorHighlight (multicolor-highlight-swatch.png, "Automatic" highlight): left to right
    readonly property var multicolorHighlightStops: ["#9F99DF", "#FF9A99", "#FFEE99"]
    // the same image as a round swatch draws it: at its own size (24 x 12 pt) from the dot's left edge, so a 16 pt dot
    // shows its left two thirds (Popup `dots` stops). Across the pop-up's dot on appearance-dark.png, converted from
    // Display P3: (161,154,220) (180,154,208) (229,153,174) (254,159,153) (255,171,154); these stops give
    // (165,153,219) (185,153,204) (225,154,175) (255,161,153) (255,172,153).
    readonly property var multicolorHighlightDot: [[0, multicolorHighlightStops[0]], [0.75, multicolorHighlightStops[1]], [1, "#FFB099"]]
}
