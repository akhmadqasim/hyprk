pragma Singleton

import QtQuick

// The macOS 27.2.1 system text styles, as Qt fonts. Use one per Text:  font: Typography.body
// (a whole font, so no other font.* on that Text), or Typography.font(pt, weight) for a size that is
// not a style. Units are logical px = pt.
//
// Measured on 27.2.1 in-process with AppKit/CoreText (reference/re/MAC-ANSWERS.md R4,
// reference/re/27.2.1/live/text-styles.json). All styles are SFNS.ttf (themes/fonts, byte-identical) with:
//  - opsz = point size clamped to 17..96. Qt never sets it, and the font's default is 28 (the Display cut),
//    which made 13 pt text 7.7 % narrower than macOS.
//  - tracking from the font's trak table ("Normal" track), by point size. HarfBuzz applies that table too,
//    but at Qt's point size (pixelSize x 72 / 96 = 9.75 for 13 px), so letterSpacing corrects it to the
//    CoreText value: 13 pt -0.0762 pt, 17 pt -0.4316 pt, 28 pt +0.3828 pt.
//  - weight on the wght axis with Qt's weight at most DemiBold: Qt 6.10 fakes bold on top of SF Pro's
//    variable Bold whenever the weight is Bold or more (f480c1e).
//  - GRAD: macOS draws text a little heavier than FreeType (stem dilation, gamma). SF's grade axis
//    thickens stems without changing advances; the values match the ink of
//    reference/screens/27.2.1/text-sample-{light,dark}.png at 2x within 2 % (see grade()).
// Fonts other than SF Pro get the size and the Qt weight only.
QtObject {
    id: ty

    // ---------- inputs ----------
    property string family: Tokens.fontText
    property bool dark: Tokens.dark
    // Qt's font DPI: QFont turns a pixel size into the point size HarfBuzz tracks by with it. It is the primary
    // screen's logical DPI, 96 on Wayland (any output scale) and offscreen.
    property real qtDpi: Qt.application.screens.length ? Math.round(Qt.application.screens[0].logicalPixelDensity * 25.4) : 96

    readonly property bool isSF: /^(SF Pro|System Font|\.SF NS|\.AppleSystemUIFont)/.test(family)

    // ---------- the font's numbers ----------
    // SFNS trak table, track "Normal", in 1/2048 em (text-styles.json findings.trakTableNormal)
    readonly property var trakSizes: [6, 9, 10, 11, 12, 13, 14, 15, 16, 17, 20, 22, 24, 28, 32, 36, 50, 64, 80, 100, 138]
    readonly property var trakUnits: [82, 38, 24, 12, 0, -12, -22, -32, -40, -52, -46, -24, 6, 28, 26, 21, 14, 7, 0, 0, 0]
    function trak(pt) {
        const s = trakSizes, u = trakUnits;
        if (pt <= s[0]) return u[0];
        for (let i = 1; i < s.length; i++)
            if (pt <= s[i]) return u[i - 1] + (u[i] - u[i - 1]) * (pt - s[i - 1]) / (s[i] - s[i - 1]);
        return u[u.length - 1];
    }
    // CoreText tracking in pt: interpolated units truncated (25 pt: 11.5 -> 11), x pt / 2048
    function tracking(pt) { return Math.trunc(trak(pt)) * pt / 2048; }
    // letterSpacing for Qt: the CoreText tracking minus what HarfBuzz already adds at Qt's point size
    function letterSpacing(pt) { return isSF ? tracking(pt) - trak(pt * 72 / qtDpi) * pt / 2048 : 0; }
    function opsz(pt) { return Math.max(17, Math.min(96, pt)); }
    // Grade that gives the macOS ink at 2x: light 490 at every size; dark more at small sizes
    // (ink matched: 11 pt ~595, 13 pt ~580, 17 pt ~540, 26 pt ~490). The axis default is 400.
    function grade(pt) { return dark ? Math.max(490, Math.min(600, 490 + 7 * (26 - pt))) : 490; }
    // Qt weight: at most DemiBold on SF (the wght axis carries the real weight), the plain weight elsewhere
    function qtWeight(w) { return !isSF ? w : w > 550 ? Font.DemiBold : w > 450 ? Font.Medium : Font.Normal; }

    // SF Pro at `pt` with wght `w` (400 Regular, 510 Medium, 590 Semibold, 700 Bold)
    // `grad`: the grade, when the text is not the dark sample's (the Cmd-Tab name: shell/modules/Switcher.qml)
    function font(pt, w, grad) {
        const wght = w || 400;
        const f = { family: family, pixelSize: pt, weight: qtWeight(wght), letterSpacing: letterSpacing(pt) };
        if (isSF) f.variableAxes = { "wght": wght, "opsz": opsz(pt), "GRAD": grad !== undefined ? grad : grade(pt) };
        return Qt.font(f);
    }

    // ---------- weights (wght axis of the .SFNS-* instances) ----------
    readonly property int regular: 400
    readonly property int medium: 510
    readonly property int semibold: 590
    readonly property int bold: 700

    // ---------- text styles (NSFont.preferredFont(forTextStyle:), text-styles.json textStylesCompact) ----------
    // size pt, line height pt (NSLayoutManager default line height), wght. For multi-line text set
    // lineHeight: Typography.styles.body.lineHeight; lineHeightMode: Text.FixedHeight.
    readonly property var styles: ({
        largeTitle:  { size: 26, lineHeight: 32, weight: 400 },
        title1:      { size: 22, lineHeight: 26, weight: 400 },
        title2:      { size: 17, lineHeight: 22, weight: 400 },
        title3:      { size: 15, lineHeight: 20, weight: 400 },
        headline:    { size: 13, lineHeight: 16, weight: 700 },
        subheadline: { size: 11, lineHeight: 14, weight: 400 },
        body:        { size: 13, lineHeight: 16, weight: 400 },
        callout:     { size: 12, lineHeight: 15, weight: 400 },
        footnote:    { size: 10, lineHeight: 13, weight: 400 },
        caption1:    { size: 10, lineHeight: 13, weight: 400 },
        caption2:    { size: 10, lineHeight: 13, weight: 510 }
    })
    readonly property font largeTitle: font(26, 400)
    readonly property font title1: font(22, 400)
    readonly property font title2: font(17, 400)
    readonly property font title3: font(15, 400)
    readonly property font headline: font(13, 700)
    readonly property font subheadline: font(11, 400)
    readonly property font body: font(13, 400)
    readonly property font callout: font(12, 400)
    readonly property font footnote: font(10, 400)
    readonly property font caption1: font(10, 400)
    readonly property font caption2: font(10, 510)

    // ---------- named system fonts (text-styles.json namedFonts) ----------
    readonly property font system: body                 // systemFont(0): 13
    readonly property font systemBold: font(13, 700)    // boldSystemFont(0), titleBarFont: 13 Bold
    readonly property font menu: body                   // menuFont: 13
    readonly property font menuBar: body                // menuBarFont: 13
    readonly property font message: body                // messageFont (alert text): 13
    readonly property font toolTip: font(11, 400)       // toolTipsFont: 11
    readonly property font palette: font(11, 400)       // paletteFont: 11
    readonly property font controlContent: font(12, 400) // controlContentFont: 12
    readonly property font label: font(10, 400)         // labelFont: 10
    // window toolbar title (Finder "Applications", Settings "Appearance"): 15 pt Semibold. Both words match
    // 15/590 within 1 px at 2x in reference/screens/27.2.1/{finder,settings}-toolbar-light.png (15 Bold is
    // 6 px wider, 14 Semibold 10 px narrower).
    readonly property font toolbarTitle: font(15, 590)

    // ---------- control sizes (NSFont.systemFontSize(for:)) ----------
    readonly property var controlSize: ({ mini: 9, small: 11, regular: 13, large: 13, extraLarge: 13 })
    readonly property font controlMini: font(9, 400)
    readonly property font controlSmall: font(11, 400)
    readonly property font control: body
}
