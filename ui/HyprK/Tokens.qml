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
    // controlAccentColor of the user's accent (Accent.qml; each app's Theme sets Accent.name)
    property color accent: Accent.color
    property string fontText: "Sans Serif"
    property string fontGlyph: "Material Icons"   // Settings' glyph font (popup chevron, checkmark, search)
    // a Spring with settlesGlass stepped: the shell re-measures that window's glass (ShellWindow)
    signal glassStepped(Item spring)

    // ---------- colours ----------
    // 27 system palette (accent-colors.json multicolor.catalogSystemColorNote), not the accent Blue #007AFF
    readonly property color systemBlue: Accent.systemBlue
    // AppKit label hierarchy (labelColor, secondaryLabelColor, tertiaryLabelColor).
    // Writable: Settings binds its reference-measured values (settings/Theme.qml).
    property color label: dark ? Qt.rgba(1, 1, 1, 0.85) : Qt.rgba(0, 0, 0, 0.85)
    property color secondaryLabel: dark ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.50)
    readonly property color tertiaryLabel: dark ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.26)
    readonly property color windowBackground: dark ? "#1E1E1E" : "#FFFFFF"   // Settings + Finder window, TODO verify
    readonly property color groupFill: dark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.03)   // grouped form card, Settings ref #F7F7F7 on white

    // accent colours per choice, light and dark: Accent.qml (measured on 27.2.1)

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
        // control fonts: whole fonts are Typography.control (13), controlSmall (11), controlMini (9); these two
        // sizes are for Texts that still set font.pixelSize
        readonly property real fontSize: Typography.controlSize.regular   // NSFont.systemFontSize 13
        readonly property real smallFontSize: Typography.controlSize.small // 11

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

        // Checkbox. No macOS 27 source for these yet (SPEC 10.8 lists the checkbox as not found): guessed,
        // from the classic AppKit regular-size checkbox.
        readonly property int checkboxSize: 14       // guessed
        readonly property real checkboxRadius: 4     // guessed
        readonly property real checkStroke: 2        // tick and dash line width, guessed
        readonly property int checkboxGap: 6         // box to label, guessed
        readonly property color checkboxOff: t.dark ? Qt.rgba(1, 1, 1, 0.12) : "#FFFFFF"   // guessed
        readonly property color checkboxOffPressed: t.dark ? Qt.rgba(1, 1, 1, 0.20) : "#E6E6E6" // guessed
        readonly property color checkboxBorder: t.increaseContrast ? (t.dark ? Qt.rgba(1, 1, 1, 0.6) : Qt.rgba(0, 0, 0, 0.6))
                                                                   : (t.dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.22))   // guessed
        readonly property color checkMark: "#FFFFFF" // tick on the accent fill (selectedMenuItemText, LIVE-27.2.1 metrics)

        // Segmented control
        readonly property int segmentedHeight: 24    // guessed (same as buttonHeight)
        readonly property real segmentInset: 2       // selection pill inset in the track, guessed
        readonly property int segmentPadding: 10     // label side padding, guessed
        readonly property color segmentTrack: fill   // track = control fill, guessed
        readonly property color segmentSelected: t.dark ? Qt.rgba(1, 1, 1, 0.24) : "#FFFFFF"   // guessed
        readonly property color separator: t.dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.10)   // separatorColor, LIVE-27.2.1 metrics-{light,dark}
        readonly property real focusRingOpacity: 0.5 // _NSAutomaticFocusRing maxOpacity, SPEC 10.6
        readonly property real focusRingWidth: 3     // guessed
    }

    // ---------- window toolbar platters (Finder, Settings; ToolbarPlatter) ----------
    // macOS 27.2.1 (reference/re/MAC-ANSWERS.md Q9.2): the toolbar strip has no fill and no glass. Each item
    // group sits on a capsule platter (NSToolbarPlatterView > NSGlassEffectView, regular, 36 pt, radius 18).
    // At 36 pt the glass recipe has almost no blur (blur opacities 0, 0, 0.5, 1), ring shadow 0.06 and a drop
    // shadow of 0.04 x fill black 0.3, radius 4, y 8, so it reads as a flat raised capsule; it is drawn so here.
    // Colours: pixels of reference/screens/27.2.1/{finder,settings}-toolbar-{light,dark}.png (2x) over the
    // window background (255 light, 31 dark).
    readonly property QtObject toolbar: QtObject {
        readonly property int platterHeight: 36
        readonly property int buttonSize: 36            // a lone button is a 36 x 36 circle
        readonly property int navWidth: 74               // back/forward share one 74 x 36 capsule
        readonly property int dividerHeight: 20          // 1 x 20 divider in the back/forward capsule
        readonly property color face: t.dark ? Qt.rgba(1, 1, 1, 0.13) : Qt.rgba(0, 0, 0, 0.025)   // 61 on 31 | 249 on 255
        readonly property color rim: t.increaseContrast ? (t.dark ? Qt.rgba(1, 1, 1, 0.4) : Qt.rgba(0, 0, 0, 0.4))
            : t.dark ? Qt.rgba(1, 1, 1, 0.03) : Qt.rgba(0, 0, 0, 0.06)   // light edge 229..240; dark sides ~ face
        readonly property color rimLit: t.dark ? Qt.rgba(1, 1, 1, 0.22) : "transparent"   // dark top and bottom edge 75..89
        readonly property color shadow: Qt.rgba(0, 0, 0, 0.04 * 0.3)   // recipe; 252..253 under the light capsule
        readonly property real shadowRadius: 4
        readonly property real shadowOffsetY: 8
        readonly property color selection: t.dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.07)   // selected segment 81 on 61 | 231 on 250
        readonly property color separator: t.dark ? Qt.rgba(1, 1, 1, 0.27) : Qt.rgba(0, 0, 0, 0.20)   // 113 on 61 | 200 on 252
    }

    // ---------- traffic lights (SPEC 13; the plugin title bar has the same numbers in
    // plugin/src/Titlebar.cpp, checked by shell/tests/run.mjs) ----------
    readonly property QtObject lights: QtObject {
        readonly property int size: 14               // NSThemeFrame sizeOfTitlebarButtons, Solarium regular
        readonly property int spacing: 9             // _windowTitlebarButtonSpacingWidth, Solarium
        readonly property real rimWidth: 0.75        // DesignLibrary StrokeStyle(lineWidth: 0.75)
        readonly property real glyphResponse: 0.3    // hover glyph reveal, spring(0.3, 1)
        // MAC-ANSWERS.md Q-windows-10: glyph strokes about 1.9 pt (x 7 x 7, minus 7.5 wide, + 8 x 8, full screen 6 x 6)
        readonly property real glyphStroke: 1.9
        // Q-windows-08: a pressed disc grows to 16..17 pt (32 px of 28 at 2x) and gets brighter
        readonly property real pressedScale: 1.15
        // gradient top, bottom (WindowControlColors), pressed (27.2.1 fill beside the glyph, Q-windows-08 and
        // lights-press-*.png; dark zoom did not change in its crop, so it keeps the CoreUI #56F66E), glyph (Q-windows-10)
        readonly property var closeSet: t.dark ? ["#FA6A61", "#EF6962", "#FF7C68", "#850000"]
                                               : ["#FF6D63", Qt.rgba(0.961, 0.447, 0.412, 0.80), "#FFAC9E", "#9E0000"]
        readonly property var minimizeSet: t.dark ? ["#FAB51A", "#FECF34", "#FFFF58", "#AA3600"]
                                                  : [Qt.rgba(0.984, 0.702, 0.086, 0.92), Qt.rgba(1, 0.820, 0.204, 0.92), "#FFFF70", "#BE4900"]
        readonly property var zoomSet: t.dark ? ["#56C83A", "#52C43D", "#56F66E", "#005500"]
                                              : ["#5ACF1F", Qt.rgba(0.475, 0.827, 0.298, 0.73), "#C6FF8F", "#097900"]
        readonly property var inactive: t.dark ? [Qt.rgba(0.980, 0.980, 0.980, 0.20), Qt.rgba(0.937, 0.937, 0.937, 0.16)]
                                               : [Qt.rgba(0.894, 0.894, 0.937, 0.30), Qt.rgba(0.878, 0.878, 0.922, 0.30)]
        readonly property color rim: Qt.rgba(0, 0, 0, t.dark ? 0.12 : 0.2)
        readonly property color inactiveRim: t.dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.14)
    }

    // ---------- window frame (MAC-ANSWERS.md Q-windows-02, -03) ----------
    // Clients that draw their own frame (Finder, Settings) round it to a 16 pt circle, which stays inside the
    // compositor's corner (config/hypr/hyprland.lua decoration.rounding). The compositor draws the outer black rim;
    // the client draws the inner 1 pt white rim: alpha .10, .08 in an inactive dark window.
    readonly property QtObject frame: QtObject {
        readonly property int radius: 16
        readonly property real rimWidth: 1
        function rim(active) { return Qt.rgba(1, 1, 1, t.dark && !active ? 0.08 : 0.10); }
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
        // Segmented selection slide: SPEC 10.8 found no literal spring in DesignLibrary's segment code and
        // reads it as SwiftUI's default Animation, which SPEC 9.9.4 gives as FluidSpring(0.5, 1.0).
        readonly property real segmentResponse: 0.5
        readonly property real segmentDamping: 1.0
        // Checkbox tick reveal and fill change: no source (SPEC 10.8, checkbox motion not found), guessed.
        readonly property real checkResponse: 0.2
        readonly property real checkDamping: 1.0
    }
}
