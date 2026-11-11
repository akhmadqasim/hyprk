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
    // the app's window is key; false greys the accent controls (MAC-ANSWERS.md Q-settings-06). Single-window apps bind it.
    property bool windowActive: true
    // size of a Switch that sets none: Settings uses mini switches (36 x 16, Q-settings-16)
    property string switchSize: "regular"
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

    // ---------- controls (Switch, Slider, Checkbox, SegmentedControl, Button, Popup, SearchField) ----------
    // macOS 27.2.1 control gallery probe + System Settings (reference/re/MAC-ANSWERS.md Q-settings-06, -15..-24,
    // re/27.2.1/live/controls/*.json). Geometry per control size (regular, small, mini, large): controls.js.
    // None of these is glass at rest. Accent layers are a stack: accent, black (light) or white (dark) a.098,
    // accent a.75, flattened by onFill().
    function onFill(c) {
        const k = 0.75 + 0.25 * 0.902, w = t.dark ? 0.25 * 0.098 : 0;
        return Qt.rgba(c.r * k + w, c.g * k + w, c.b * k + w, 1);
    }
    readonly property QtObject control: QtObject {
        readonly property int menuItemHeight: 24     // pop-up menu row (Q-20)
        readonly property int menuPadding: 5         // menu padding and highlight inset (Q-20)
        readonly property int menuRadius: 12         // Q-20 (live: regular glass r12; drawn flat here)
        readonly property real menuHighlightRadius: 6
        readonly property int popupChevron: 24       // Settings: the double chevron sits in a 24 pt circle (Q-19)
        readonly property real disabledOpacity: 0.5  // disabled: the background layers at opacity 0.5 (Q-06)
        // control fonts: whole fonts are Typography.control (13), controlSmall (11), controlMini (9); these two
        // sizes are for Texts that still set font.pixelSize
        readonly property real fontSize: Typography.controlSize.regular   // NSFont.systemFontSize 13
        readonly property real smallFontSize: Typography.controlSize.small // 11

        // push button, pop-up, segmented track: two layers a.047 + a.03 (#ECECEC on white, #303137 on #202127)
        readonly property color pushFill: t.dark ? Qt.rgba(1, 1, 1, 0.0756) : Qt.rgba(0, 0, 0, 0.0756)
        // switch off, slider track, checkbox and radio off: black / white a.098 (#E4E4E4 / #36373C)
        readonly property color trackOff: t.dark ? Qt.rgba(1, 1, 1, 0.098) : Qt.rgba(0, 0, 0, 0.098)
        // the extra layer while pressed (push, pop-up, checkbox, segment): black a.098, no animation
        readonly property color pressOverlay: Qt.rgba(0, 0, 0, 0.098)
        // label of a disabled control (disabledControlTextColor), disabled tick and slider ticks: black a.26 / white a.25
        readonly property color disabledText: t.dark ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.26)
        // the accent stack; the window not key: grey (Q-06; switch from Settings, the others from the probe)
        readonly property color accentOn: t.onFill(t.accent)
        readonly property color switchOn: t.windowActive ? accentOn : (t.dark ? "#414244" : "#D3D3D3")
        readonly property color sliderFill: t.windowActive ? accentOn : (t.dark ? "#535357" : "#C5C5C5")
        readonly property color segmentSelected: t.windowActive ? accentOn : (t.dark ? "#4A4B50" : "#CFCFCF")
        readonly property color checkboxOn: t.windowActive ? accentOn : (t.dark ? "#535456" : "#C1C1C1")
        readonly property color sliderDisabled: t.dark ? "#404146" : "#DBDBDB"   // track and fill, flat (Q-06)
        readonly property color segmentSeparator: trackOff   // 1 x 14 between unselected segments (Q-22)
        readonly property color knob: "#FFFFFF"
        // knob shadows: black a.10 radius 12 y 3, black a.10 radius 2 y 1 (Q-16)
        readonly property color knobShadow: Qt.rgba(0, 0, 0, 0.10)
        // Applications window selection (shell); not a control fill
        readonly property color fill: t.dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.08)
        readonly property color menuFill: t.dark ? "#2C2C2E" : "#F6F6F6"   // TODO verify (the live menu is glass)
        readonly property color menuStroke: t.dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.10)
        // Settings sidebar search capsule (desktop-dock-{light,dark}.png): a faint fill and a 0.5 pt dark rim
        readonly property color searchFill: t.dark ? Qt.rgba(1, 1, 1, 0.21) : Qt.rgba(0, 0, 0, 0.017)
        readonly property color searchStroke: t.dark ? Qt.rgba(0, 0, 0, 0.65) : Qt.rgba(0, 0, 0, 0.27)
        readonly property int searchHeight: 28       // Q-10: 212 x 28 capsule
        readonly property int searchRadius: 14
        readonly property int checkboxGap: 6         // box to label (text at x 22, Q-21)
        readonly property real focusRingWidth: 3     // Q-24: 3 pt, gap 0, radius + 3, Accent.focusRing, no animation
    }

    // ---------- overlay scroll bar (OverlayScrollbar; MAC-ANSWERS.md PC #60 section 5) ----------
    // knob 6 pt, r 3, 3 pt from the window's right edge; light #808080 (black a.5), dark #8F9192 (white a.5 on #1E1F24)
    readonly property QtObject scroller: QtObject {
        readonly property real width: 6
        readonly property real inset: 3            // from the right edge, below the toolbar and above the bottom
        readonly property real minLength: 18       // TODO verify (not measured; AppKit keeps the knob grabbable)
        readonly property color knob: t.dark ? Qt.rgba(1, 1, 1, 0.5) : Qt.rgba(0, 0, 0, 0.5)
        readonly property int hold: 600            // stays after the last scroll event
        readonly property int fade: 150            // then fades out (9 frames)
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

    // ---------- alerts, sheets, popovers (AlertPanel, Sheet, Popover; geometry in panels.js) ----------
    // macOS 27.2.1, MAC-ANSWERS.md Q-panels-33/34 and LIVE-27.2.1.md; colours from reference/screens/27.2.1/finder/
    // alert-*.png, sheet-*.png (2x). The live alert and popover are regular glass; drawn flat here with the
    // measured body colour.
    readonly property QtObject panel: QtObject {
        readonly property int alertRadius: 26
        readonly property color alertFill: t.dark ? "#38383F" : "#FEFEFD"           // (56,56,63) | 254
        readonly property color alertButton: t.dark ? "#47474E" : "#EBEBEB"         // (71,71,78) | 235
        // pressed: dark 71 -> 89 (+18 = white a.098); light not measured, the push-button press layer
        readonly property color alertButtonPressed: t.dark ? Qt.rgba(1, 1, 1, 0.098) : t.control.pressOverlay
        readonly property color destructiveFill: t.dark ? "#653F43" : "#F9D1D0"     // (101,63,67) | (249,209,208)
        readonly property color destructiveText: t.dark ? "#DC3929" : "#EB4C46"     // (220,57,41) | (235,76,70)
        // the default button: (52,120,246) under Multicolour/Blue in both appearances, else the accent
        readonly property color defaultFill: Accent.name === "multicolor" || Accent.name === "blue" ? "#3478F6" : t.accent
        readonly property int sheetRadius: 16                                       // continuous r 16 (fit 17.9)
        readonly property color sheetFill: t.dark ? "#22232F" : "#FFFFFF"           // windowBackground (34,35,47) | 255
        readonly property color sheetDim: Qt.rgba(0, 0, 0, 0.2)                    // whole parent ~20 % darker
        readonly property int popoverRadius: 20
        readonly property color popoverFill: t.control.menuFill                     // glass live; flat like the menus
        readonly property color popoverStroke: t.control.menuStroke
        // motion (LIVE-27.2.1.md): alert grows from 4 % to a 1.15 peak at 0.2 s (in-quad), settles by 0.37 s
        // (out-quad), dismiss = 0.1 s fade; sheet in 0.27 s, out 0.25 s, near-linear, size constant; popover a
        // spring from 12.5 % (response 0.25, damping 0.9) from the arrow, close = fade 0.15..0.2 s
        readonly property real alertPopFrom: 0.04
        readonly property real alertPopPeak: 1.15
        readonly property int alertPopRise: 200
        readonly property int alertPopSettle: 170
        readonly property int alertFadeOut: 100
        readonly property int sheetIn: 270
        readonly property int sheetOut: 250
        readonly property real popoverFrom: 0.125
        readonly property real popoverResponse: 0.25
        readonly property real popoverDamping: 0.9
        readonly property int popoverFadeOut: 180
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
        // Controls (MAC-ANSWERS.md Q-settings-17, 120 Hz layer samples in controls-press-light.json)
        // switch knob travel (MAC-ANSWERS.md PC #67 A3, verify/A/switch-fit.json): DesignLibrary's switch body runs
        // SwiftUI .spring(response: 0.47, dampingFraction: 0.7), integrated at 1/300 s. motion.js springStep is the
        // same integrator (4 ms substeps = 1/300 s at 60 Hz), so the code values go in as written: RMS 0.0003 pt
        // against the 240 Hz knob series (the analytic equivalent is response 0.4624, ratio 0.7113). Overshoot
        // 4.16 % (+0.75 pt regular), regular and mini alike, both directions.
        readonly property real switchTravelResponse: 0.47
        readonly property real switchTravelDamping: 0.7
        // the animation is cut after 27 frames (about 0.46 s): the knob jumps from 1.0176 to 1.0 on the next frame
        readonly property int switchTravelCut: 460
        // press: the knob grows x1.56 into the lens from the mouse-down frame, easeInEaseOut (0.42, 0, 0.58, 1) 0.20 s,
        // no delay (rms 0.0002); release: it shrinks with the travel spring above (width tracks x in the series)
        readonly property int switchLensIn: 200
        readonly property var switchLensCurve: [0.42, 0, 0.58, 1, 1, 1]
        // track colour cross-fade from release: about 0.25 s on to off, 0.23 s off to on, ease-out
        readonly property int switchTrackFade: 240
        // pressed knob: grows x1.56 (32 x 20 -> 50 x 31, mini 21 x 13 -> 33 x 20) into a clear lens
        readonly property real switchLift: 1.56
        // slider knob: 20 x 16 -> 25 x 20 (x1.25), glass in 0.17 s (0.02 s delay + 0.15 s), back in 0.15 s
        readonly property real sliderLift: 1.25
        readonly property int sliderLiftDelay: 20
        readonly property int sliderLiftDuration: 150
        readonly property int sliderLiftRelease: 150
        // track click: the knob runs to the click point, ease-out, no overshoot: 50 % at 0.07 s, 90 % at 0.18 s
        // after it starts (a critically damped spring of 0.27 s; the 0.066 s start delay is not drawn)
        readonly property real sliderJumpResponse: 0.27
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
