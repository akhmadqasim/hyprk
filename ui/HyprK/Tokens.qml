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
    // Settings > Appearance > Liquid Glass (NSGlassTintAmount, 0 clear .. 1 tinted, 0.5 = unchanged recipe). Apps
    // that read appearance.json `glass` bind it; glass-faced controls (ToolbarPlatter) follow it
    property real glassTint: 0.5
    // controlAccentColor of the user's accent (Accent.qml; each app's Theme sets Accent.name)
    property color accent: Accent.color
    property string fontText: "Sans Serif"
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
        readonly property int popupHeight: 24        // the pop-up button's frame (Q-19; the menu row lies over it)
        readonly property int popupChevron: 20       // Settings: the double chevron's circle, 40 px on appearance-,
                                                     // sound- and displays-light.png, 3.5 pt from the frame's right edge
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
        // pressed knob lens (LensGlass), fitted to switch-press-strip-light.png (peak frame, 50 x 31 lens over the
        // 54 x 24 track): the track reads 17.5 pt tall inside and its end 16 pt from the centre (18 real) ->
        // refraction band = half the lens height, offset at the rim 0.34 x the lens height; a 0.5 pt rim line
        // (249 -> 164 on white, 96 -> 35 on the track: black about a.4)
        readonly property real lensBand: 0.5
        readonly property real lensAmount: 0.34
        readonly property real lensOutline: 0.4
        // what the lens shows outside the track: the Settings card (Q-settings-11: #F7F7F7 / #25262B)
        readonly property color lensBackdrop: t.dark ? "#25262B" : "#F7F7F7"
        // the pressed knob's lens (Knob; Slider, Switch and Control Center share it). Refraction: the glassBackground
        // filter of the pressed knob (live/controls/controls-press-light.json pressedKnobGlassFilter, a 50 x 31 lens:
        // inputInnerRefractionHeight 3.1 = 0.1 D, inputInnerRefractionAmount -4.65 = -0.15 D, D = the lens height):
        // the content is magnified next to the rim (Mac recording 2026-11-11 23.09.23, Settings > Appearance, dark,
        // knob held still, frames 2678-2693: the fill reads 20 px tall 1.5 pt inside the round end against 14 px
        // outside, the tick under the track is stretched to 3 pt at the bottom rim).
        // Light, fitted on the same frames over the card (32), the grey track (49.5) and the fill (45,124,255) as
        // sample x gain, then white mixed in: gain .85; the face reads 50 2-4 pt under the top, 57 on the track at the
        // middle, 40-46 1-4 pt over the bottom and 47 just over the bottom key light -> white .05 everywhere, .06 at the
        // top edge fading out 12 pt down, .04 at the bottom edge fading out 4 pt up. Key light just inside the rim
        // line peaking +21 at the top (71 over 50) and +13 at the bottom, +3 on the round ends, falling off over about
        // 0.9 pt (on the round ends the top / bottom light falls with the cube of the normal's vertical part: +5 there).
        // Rim: 1 pt outside the face reading 15-22 over 32 and 52 over the fill (116): the plain sample x .55.
        // Light: not in the recording; the 0.5 pt black .4 line of switch-press-strip-light.png and the same light terms.
        readonly property real knobLensBand: 0.1
        readonly property real knobLensAmount: -0.15
        readonly property real knobLensGain: 0.85
        readonly property real knobLensHaze: 0.05
        readonly property real knobLensDiffuseTop: 0.06
        readonly property real knobLensDiffuseTopDepth: 12
        readonly property real knobLensDiffuseBottom: 0.04
        readonly property real knobLensDiffuseBottomDepth: 4
        readonly property real knobLensKeyTop: 0.135
        readonly property real knobLensKeyBottom: 0.083
        readonly property real knobLensKeyEnds: 0.02
        readonly property real knobLensKeyFalloff: 0.9
        readonly property real knobLensOutline: t.dark ? 0.45 : 0.4
        readonly property real knobLensOutlineWidth: t.dark ? 1 : 0.5
        // under the lens: the lens shape 8 pt down, 1 pt wider (filter inputRingShadowOffset 8, StrokeWidth 4: 2 pt
        // outside the shape, half of it at full strength), blurred 2 pt (filter BlurRadius 3; the recording fades over
        // about 11 px), opacity .1 in light (filter); dark, the recording: the card 32 -> 26 from the bottom rim for
        // 13 px, back to 31 by 24 px (black .19)
        readonly property color knobLensShadow: t.dark ? Qt.rgba(0, 0, 0, 0.19) : Qt.rgba(0, 0, 0, 0.10)
        readonly property real knobLensShadowY: 8
        readonly property real knobLensShadowSpread: 1
        readonly property real knobLensShadowBlur: 2
        // the slider fill while its knob is held: light black .098 (controls-press-light.json: a black layer over the
        // fill whose alpha follows the lens, .0859 at .916), dark white about .098 (the recording: the fill (16,112,255)
        // -> (45,125,255) with the lens)
        readonly property color sliderPressOverlay: t.dark ? Qt.rgba(1, 1, 1, 0.098) : Qt.rgba(0, 0, 0, 0.098)
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
        readonly property real minLength: 26       // NSScrollerImp overlay knobMinLength (MAC-ANSWERS "Scroller knob during overscroll")
        readonly property color knob: t.dark ? Qt.rgba(1, 1, 1, 0.5) : Qt.rgba(0, 0, 0, 0.5)
        readonly property int hold: 600            // stays after the last scroll event
        // Edges: every scroll view is StopAtBounds (a mouse wheel stops hard, as on the Mac) with a RubberBand
        // (AppKit's trackpad stretch, return and momentum; constants in rubberband.js)
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
        // ToolbarPlatter.relief: the platter's own shading, measured on the Settings back/forward and the Finder toolbar
        // capsules (settings/appearance-{light,dark}.png, finder/icons-{light,dark}.png, 2x). Light: the shape is 37 pt
        // tall, its edge rows (235 top, 231 bottom, 191 on the sides) outside a 36 pt face (rows 16..87 px); the face
        // down the middle: 255 255 (the lit row), 253, 249 from 0.19 to 0.37 of the height, 253 from 0.535, 255 255;
        // at the round ends the lower half stays darker (reliefEnd: [pt from the end, level], rows 58-70 px of five
        // capsules: 248-249 at 0.5-3.5 pt, 249-250 at 4.5-6.5, 250-251 at 8.5, 251-252 at 10.5, 252 at 12.5, 253 from
        // 14.5-16.5). Dark: 36 pt, sides 11, top and bottom 110 then 89 over the 60..61 face
        readonly property real reliefHeight: t.dark ? platterHeight : platterHeight + 1
        readonly property color reliefTop: "#FDFDFD"
        readonly property color reliefMid: "#F9F9F9"
        readonly property var reliefEnd: [[0, 248], [4, 249], [7.5, 250], [9.5, 251], [11.5, 252], [15, 253]]
        // light: the edge lies on the window (255) since the face is inside it: 235 = black .08, the sides' 190 = .19 more
        readonly property color reliefEdge: t.dark ? Qt.rgba(1, 1, 1, 0.27) : Qt.rgba(0, 0, 0, 0.08)
        readonly property color reliefSide: t.dark ? Qt.rgba(0, 0, 0, 0.9) : Qt.rgba(0, 0, 0, 0.19)   // over the edge
        // the side darkening around the middle of the round ends: full within reliefSideFlat pt of the middle, then a
        // Gaussian fall-off. Edge pixel down the left end: light (appearance-light.png) 191 at the middle, 199-206 at
        // 1-2 pt, 214-232 at 3 pt, the 237 edge from 4 pt; dark (appearance-dark.png) 11-25 from 12.75 pt above to
        // 12.75 pt below the middle, 46 at 13.75, the lit 54-60 from 14.75 pt
        // dark, inside the lit edge (settings-toolbar-dark.png, face 60). The second px follows the capsule: 88 along
        // the straight top and bottom, 86-71 around the ends down to 11 pt from the middle, 63 at 6 pt, 60 at the
        // middle (reliefInner, full from reliefInnerTo pt from the middle, none within reliefInnerFrom). Below it a glow
        // that depends on the row only: 70 68 66 65 64 63 62 62 down the next 4 pt, the same up from the bottom
        // (reliefGlow: white alpha at 1, 1.5, 2, 2.5, 3, 3.5, 4, 5, 6 pt from the edge)
        readonly property color reliefInner: t.dark ? Qt.rgba(1, 1, 1, 0.14) : "transparent"
        readonly property real reliefInnerFrom: 5
        readonly property real reliefInnerTo: 17
        readonly property var reliefGlow: t.dark ? [0.05, 0.036, 0.027, 0.022, 0.018, 0.013, 0.009, 0.005, 0] : []
        readonly property real reliefSideFlat: t.dark ? 11.5 : 0
        readonly property real reliefSideSigma: t.dark ? 1.5 : 3
        // dark face with the Liquid Glass slider (MAC-ANSWERS Appearance 2: #3C3E40 at 0, #4B4E52 at 1, 60..61 at
        // 0.5 on the 31 window): unchanged below 0.5, white .13 -> .21 above (Regular face, knee at 0.5)
        readonly property real reliefDarkFaceAlpha: 0.13 + 0.08 * Math.max(0, Math.min(1, 2 * t.glassTint - 1))
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
        readonly property color destructiveFill: t.dark ? "#6B3D42" : "#FFCFCF"     // shot (101,63,67) | (249,209,208), Display P3
        readonly property color destructiveText: t.dark ? "#F01D14" : "#FF393C"     // shot (220,57,41) | (235,76,70), Display P3
        // the default button: the shots read (52,120,246) under Multicolour/Blue in both appearances, which is Display
        // P3 for sRGB #007AFF (reference/ours/COLOUR-P3-AUDIT.md); else the accent
        readonly property color defaultFill: Accent.name === "multicolor" || Accent.name === "blue" ? "#007AFF" : t.accent
        readonly property int sheetRadius: 16                                       // continuous r 16 (fit 17.9)
        readonly property color sheetFill: t.dark ? "#22232F" : "#FFFFFF"           // windowBackground (34,35,47) | 255
        readonly property color sheetDim: Qt.rgba(0, 0, 0, 0.2)                    // whole parent ~20 % darker
        readonly property int popoverRadius: 20
        readonly property color popoverFill: t.control.menuFill                     // glass live; flat like the menus
        readonly property color popoverStroke: t.control.menuStroke
        // glass rim (MAC-ANSWERS.md PC #67 B): the dark specular line darkens white 255 -> 192 (black a .25) on the
        // sides; the key highlight lifts the first px at the top (m up to 1.53 with offset +0.147: about white a .45
        // over the light fill, .25 dark) and an 8 pt diffuse band at amount 0.075
        readonly property color popoverRim: Qt.rgba(0, 0, 0, t.dark ? 0.5 : 0.25)
        readonly property color popoverKey: Qt.rgba(1, 1, 1, t.dark ? 0.25 : 0.45)
        readonly property color popoverDiffuse: Qt.rgba(1, 1, 1, 0.075)
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
        // MAC-ANSWERS.md Q-windows-08 and lights-*.png (27.2.1, 2x): the rim is one device px (0.5 pt) at 2x
        readonly property real rimWidth: 0.5
        // Q-windows-10 (60 fps): glyphs appear 0.07 s after the pointer enters the group, then fade in
        // .30 .64 .81 .90 .95 .96 .97 1 per frame (= OutCubic over 8 frames, 0.133 s); fade out
        // .22 .52 .77 .89 .96 .97 .99 with no delay (about OutQuad over 7 frames, 0.117 s)
        readonly property int glyphDelay: 70
        readonly property int glyphIn: 133
        readonly property int glyphOut: 117
        // Q-windows-10: glyph strokes about 1.9 pt (x 7 x 7, minus 7.5 wide, + 8 x 8, full screen 6 x 6)
        readonly property real glyphStroke: 1.9
        // Q-windows-08: a pressed disc grows to 16 pt (32 px of 28 at 2x) and gets brighter, with a glow
        readonly property real pressedScale: 1.15
        // The Mac shots hold Display P3 numbers: every value below is the sampled one converted to sRGB (p3_to_srgb of
        // reference/ours/COLOUR-P3-AUDIT.md; before, the raw numbers were shown as sRGB, close red 232,112,97 for 250,103,90).
        // Per button, sampled on lights-{rest,hover,press-*}-{light,dark}.png: fill top / centre / bottom (Q-windows-08),
        // ring = the outer 0.5 pt as a vertical gradient (stops 0, .2, .5, .8, 1): light discs have a dark coloured rim on
        // the sides that fades into the fill at top and bottom; dark discs a light specular arc at top and bottom and
        // plain (slightly darker) sides. glow = the 1 pt halo just outside the disc (light: 252,239,237 at rest, 241,206,203 pressed over
        // white). Glyph ink: Q-windows-10 (hover centre light close 159,0,0); pressed glyphs from the press crops.
        // Dark zoom did not change in its press crop, so its pressed fill keeps CoreUI's #56F66E.
        readonly property var close: t.dark
            ? { fill: ["#FA675A", "#F25D54", "#EE675E"], ring: ["#FFC4BA", "#FFC4BA", "#EA574F", "#FEC2B8", "#FEC2B8"], glyph: "#920000", glow: "transparent",
                press: { fill: ["#FF8C7B", "#FF8C7B", "#FF8D80"], ring: ["#FFFBEB", "#FFFBEB", "#FF7167", "#FEF7EC", "#FEF7EC"], glyph: "#C70000", glow: Qt.rgba(1, 0.843, 0.791, 0.07) } }
            : { fill: ["#FE6F65", "#FA7E77", "#F68C86"], ring: ["#FE6F65", "#C50000", "#C50000", "#C50000", "#F68C86"], glyph: "#AD0000", glow: Qt.rgba(0.777, 0, 0, 0.065),
                press: { fill: ["#FF9486", "#FFA394", "#FFB2A4"], ring: ["#FF9486", "#FF0000", "#FF0000", "#FF0000", "#FFB2A4"], glyph: "#E80000", glow: Qt.rgba(1, 0, 0, 0.22) } }
        readonly property var minimize: t.dark
            ? { fill: ["#FCB500", "#FCC000", "#FECD28"], ring: ["#F6F56C", "#F6F56C", "#F3B800", "#F5F57C", "#F5F57C"], glyph: "#B92800", glow: "transparent",
                press: { fill: ["#FFFF7B", "#FFFF26", "#FFFF5F"], ring: ["#FBFB89", "#FBFB89", "#FFD400", "#FBFB9A", "#FBFB9A"], glyph: "#FB3E00", glow: Qt.rgba(1, 1, 0.539, 0.07) } }
            : { fill: ["#FCBA31", "#FDC93C", "#FFD347"], ring: ["#FCBA31", "#9E0D00", "#9E0D00", "#9E0D00", "#FFD347"], glyph: "#CE3E00", glow: Qt.rgba(0.622, 0.051, 0, 0.05),
                press: { fill: ["#FFF64C", "#FFFB49", "#FFFF65"], ring: ["#FFF64C", "#E22E00", "#E22E00", "#E22E00", "#FFFF65"], glyph: "#FF5600", glow: Qt.rgba(0.891, 0.176, 0.004, 0.2) } }
        readonly property var zoom: t.dark
            ? { fill: ["#4AC61D", "#35C000", "#4AC333"], ring: ["#AFF88E", "#AFF88E", "#23B900", "#A6F88B", "#A6F88B"], glyph: "#005700", glow: "transparent",
                press: { fill: ["#56F66E", "#56F66E", "#56F66E"], ring: ["#AFF88E", "#AFF88E", "#23B900", "#A6F88B", "#A6F88B"], glyph: "#005700", glow: "transparent" } }
            : { fill: ["#5FD02A", "#86D660", "#9BDC7B"], ring: ["#5FD02A", "#005700", "#005700", "#005700", "#9BDC7B"], glyph: "#007B00", glow: Qt.rgba(0, 0.336, 0, 0.05),
                press: { fill: ["#7DFF3A", "#A4FF71", "#C6FF9C"], ring: ["#7DFF3A", "#008100", "#008100", "#008100", "#C6FF9C"], glyph: "#00AE00", glow: Qt.rgba(0, 0.508, 0, 0.22) } }
        // Q-windows-09, non-key window (lights-inactive-*.png): dark #4C4C52 -> #47484D, light grey arcs at the top
        // (#B4B4B4) and bottom (#ADADAD); light #EFEFF3 -> #F6F7F8, ring #EAEAEE at the top, #ABABAE on the sides
        readonly property var inactive: t.dark
            ? { fill: ["#4C4C52", "#4C4C52", "#47484D"], ring: ["#B4B4B4", "#B4B4B4", "#4A4B50", "#ADADAD", "#ADADAD"], glyph: "transparent", glow: "transparent" }
            : { fill: ["#EFEFF3", "#F2F3F5", "#F6F7F8"], ring: ["#EAEAEE", "#ABABAE", "#ABABAE", "#ABABAE", "#E7E7EA"], glyph: "transparent", glow: "transparent" }
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
        // slider knob: 20 x 16 -> 25 x 20 (x1.25). Lens share (SDFLayer opacity) per 60 Hz frame from the first frame
        // that moves, press and release alike (controls-press-light.json, press-hold and drag; the release starts at
        // .088 instead of .061, a phase): .061 .219 .405 .579 .725 .837 .916 .968 .998 1 = cubic bezier
        // (0.275, 0.240, 0.437, 0.912) over 144 ms (rms .0003). The first change comes 35 ms after mouse-down and
        // after mouse-up alike, so it is the probe's input latency, not a delay of the press. The knob's frame grows on
        // the same curve (24.6 x 19.7 at .916). The Mac recording 23.09.23 (dark) gives the same series by eye.
        readonly property real sliderLift: 1.25
        readonly property int sliderLiftDelay: 0
        readonly property int sliderLiftDuration: 144
        readonly property int sliderLiftRelease: 144
        readonly property var sliderLiftCurve: [0.275, 0.240, 0.437, 0.912, 1, 1]
        // track click: the knob runs to the click point, ease-out, no overshoot: 50 % at 0.07 s, 90 % at 0.18 s
        // after it starts (a critically damped spring of 0.27 s; the 0.066 s start delay is not drawn)
        readonly property real sliderJumpResponse: 0.27
        readonly property real reducedResponse: 0.2   // Reduce Motion: easeInOut(0.2)-like, no growth (lens stays)
        readonly property int dragThreshold: 3        // px before a switch press becomes a drag
        readonly property real switchDragShare: 0.4   // of the track width: NSSwitch, a drag begun on the empty half (double at 0x18b7ed840)
        // Liquid Glass (SwiftUICore 27.2, liquid-glass-re notes/round3; SPEC 9.9.4/9.9.5/10.3)
        readonly property real materializeResponse: 0.5   // GlassContainer TransitionSettings.default = Spring(duration 0.5, bounce 0.3)
        readonly property real materializeDamping: 0.7
        readonly property real crossfade: 0.15            // Reduce motion: FadeIn/FadeOut 0.15 s (SPEC 9.9.5)
        readonly property real pressResponse: 0.25        // FlexInteraction press lift (SPEC 10.3)
        readonly property real pressSquish: 0.06          // drag past a slider end stretches x, squeezes y (by eye)
    }
}
