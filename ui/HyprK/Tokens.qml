pragma Singleton

import QtQuick

// Design tokens shared by the shell, Settings and Finder (module HyprK, ui/HyprK).
// Each app's Theme binds the inputs below from its own state (appearance.json, the
// Accessibility settings) and reads the rest back; the HyprK controls read only this.
// Units are logical px (1 pt on macOS). Sources are named per value; SPEC = /mnt/code/liquid-glass-re/SPEC.md.
QtObject {
    id: t

    // ---------- inputs (set by the app's Theme) ----------
    property bool dark: false
    property bool reduceMotion: false
    property bool reduceTransparency: false
    property bool increaseContrast: false
    property color accent: systemBlue
    property string fontText: "Sans Serif"
    property string fontGlyph: "Material Icons"   // Settings' glyph font (popup chevron, checkmark, search)
    // a Spring with settlesGlass stepped: the shell re-measures that window's glass (ShellWindow)
    signal glassStepped(Item spring)

    // ---------- colours ----------
    readonly property color systemBlue: dark ? "#0A84FF" : "#007AFF"
    // AppKit label hierarchy (labelColor, secondaryLabelColor, tertiaryLabelColor).
    // Writable: Settings binds its reference-measured values (settings/Theme.qml).
    property color label: dark ? Qt.rgba(1, 1, 1, 0.85) : Qt.rgba(0, 0, 0, 0.85)
    property color secondaryLabel: dark ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.50)
    readonly property color tertiaryLabel: dark ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.26)
    readonly property color windowBackground: dark ? "#1E1E1E" : "#FFFFFF"   // Settings + Finder window, TODO verify
    readonly property color groupFill: dark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.03)   // grouped form card, Settings ref #F7F7F7 on white

    // SPEC 15: controlAccent<Name>Color from SystemAppearance Aqua.car / DarkAqua.car (macOS 27.2)
    readonly property var accentSwatches: dark
        ? ({ blue: "#007AFF", purple: "#A550A7", pink: "#F74F9E", red: "#FF5257", orange: "#F7821B", yellow: "#FFC600", green: "#62BA46", graphite: "#8C8C8C" })
        : ({ blue: "#007AFF", purple: "#953D96", pink: "#F74F9E", red: "#E0383E", orange: "#F7821B", yellow: "#FFC726", green: "#62BA46", graphite: "#989898" })

    // ---------- controls (Switch, Slider, Popup, Button, SearchField) ----------
    readonly property QtObject control: QtObject {
        readonly property int switchWidth: 38        // TODO verify
        readonly property int switchHeight: 22       // TODO verify
        readonly property int popupHeight: 22        // Settings ref
        readonly property int popupChevron: 20       // Settings ref round chevron button
        readonly property int menuItemHeight: 24     // pop-up menu row
        readonly property int menuRadius: 10         // pop-up menu, TODO verify
        readonly property int sliderTrack: 4         // TODO verify
        readonly property int sliderKnobW: 24        // macOS 26 capsule knob, TODO verify
        readonly property int sliderKnobH: 16        // TODO verify
        readonly property int buttonHeight: 24       // TODO verify
        readonly property int buttonRadius: 12       // capsule push button (macOS 26), TODO verify
        readonly property real disabledOpacity: 0.4
        readonly property real fontSize: 13          // NSFont.systemFontSize
        readonly property real smallFontSize: 11

        readonly property color fill: t.dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.08)   // Settings ref popup circle #E4E4E5
        readonly property color fillPressed: t.dark ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(0, 0, 0, 0.12)
        readonly property color switchOff: t.dark ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(0, 0, 0, 0.09)
        readonly property color knob: "#FFFFFF"
        readonly property color menuFill: t.dark ? "#2C2C2E" : "#F6F6F6"   // TODO verify
        readonly property color menuStroke: t.dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.10)
        readonly property color searchFill: t.dark ? Qt.rgba(1, 1, 1, 0.07) : Qt.rgba(0, 0, 0, 0.04)    // Settings ref #EAE9E7 over the sidebar
        readonly property color searchStroke: t.dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(1, 1, 1, 0.85) // Settings ref light rim
        readonly property int searchHeight: 28       // Settings ref
        readonly property int searchRadius: 14       // Settings ref capsule
    }

    // ---------- traffic lights (SPEC 13; the plugin title bar has the same numbers in
    // plugin/src/Titlebar.cpp, checked by shell/tests/run.mjs) ----------
    readonly property QtObject lights: QtObject {
        readonly property int size: 14               // NSThemeFrame sizeOfTitlebarButtons, Solarium regular
        readonly property int spacing: 9             // _windowTitlebarButtonSpacingWidth, Solarium
        readonly property real rimWidth: 0.75        // DesignLibrary StrokeStyle(lineWidth: 0.75)
        readonly property real glyphResponse: 0.3    // hover glyph reveal, spring(0.3, 1)
        // gradient top, bottom (WindowControlColors), pressed (CoreUI art), glyph (CoreUI hover art)
        readonly property var closeSet: t.dark ? ["#FA6A61", "#EF6962", "#FF8D85", "#730100"]
                                               : ["#FF6D63", Qt.rgba(0.961, 0.447, 0.412, 0.80), "#C04741", "#730000"]
        readonly property var minimizeSet: t.dark ? ["#FAB51A", "#FECF34", "#FFEA5C", "#985600"]
                                                  : [Qt.rgba(0.984, 0.702, 0.086, 0.92), Qt.rgba(1, 0.820, 0.204, 0.92), "#BF8E22", "#985600"]
        readonly property var zoomSet: t.dark ? ["#56C83A", "#52C43D", "#56F66E", "#006200"]
                                              : ["#5ACF1F", Qt.rgba(0.475, 0.827, 0.298, 0.73), "#1E9730", "#006200"]
        readonly property var inactive: t.dark ? [Qt.rgba(0.980, 0.980, 0.980, 0.20), Qt.rgba(0.937, 0.937, 0.937, 0.16)]
                                               : [Qt.rgba(0.894, 0.894, 0.937, 0.30), Qt.rgba(0.878, 0.878, 0.922, 0.30)]
        readonly property color rim: Qt.rgba(0, 0, 0, t.dark ? 0.12 : 0.2)
        readonly property color inactiveRim: t.dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.14)
    }

    // ---------- motion (springs: response s, dampingFraction) ----------
    readonly property QtObject motion: QtObject {
        // SPEC 10 "Controls motion"
        readonly property real switchResponse: 0.47   // knob slide, DesignLibrary switch spring(0.47, 0.7)
        readonly property real switchDamping: 0.7
        readonly property real switchLift: 1.55       // knob w and h x1.55 while pressed (lens)
        readonly property real lensResponse: 0.444    // liquidLens scale spring (small knob)
        readonly property real lensDamping: 0.56
        readonly property real sliderLift: 1.25       // slider knob x1.25 while pressed
        readonly property real sliderLiftResponse: 0.25 // spring(0.25, 0.75)
        readonly property real sliderLiftDamping: 0.75
        readonly property real sliderJumpResponse: 0.25 // track click: NSSliderCell 0.25 s ease-in-out value animation
        readonly property real reducedResponse: 0.2   // Reduce Motion: easeInOut(0.2)-like, no growth (lens stays)
        readonly property int dragThreshold: 3        // px before a switch press becomes a drag
        // Liquid Glass (SwiftUICore 27.2, liquid-glass-re notes/round3; SPEC 9.9.4/9.9.5/10.3)
        readonly property real materializeResponse: 0.5   // GlassContainer TransitionSettings.default = Spring(duration 0.5, bounce 0.3)
        readonly property real materializeDamping: 0.7
        readonly property real crossfade: 0.15            // Reduce motion: FadeIn/FadeOut 0.15 s (SPEC 9.9.5)
        readonly property real pressResponse: 0.25        // FlexInteraction press lift (SPEC 10.3)
        readonly property real pressSquish: 0.06          // drag past a slider end stretches x, squeezes y (by eye)
    }
}
