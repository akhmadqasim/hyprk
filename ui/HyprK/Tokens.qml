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
    // the compositor draws the menu glass behind this app's popup windows (liquidglass plugin, its class in
    // popup_classes: plugin/README.md "Client popups"); set by the app (Finder: Hypr.option, Settings: HYPRK_GLASS).
    // Then a menu in its own popup window (TextMenu) draws no fill, as Finder's PopupMenu
    property bool popupGlass: false
    // the app window's real device pixel ratio (Settings: its FloatingWindow, Finder: windowInfo.dpr); 0 = unknown, use
    // Screen.devicePixelRatio, which says 2 on a 1.6 output (pixel.js ratio)
    property real dpr: 0
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
        // Regular glass refraction (the Appearance preview's glass buttons, LensGlass), D = the shorter side in pt: inner
        // height min(0.25 D, 20), amount max(-0.5 D, -60) (sample further inside: the rim magnifies), outer height
        // max(0.2 D, 16), amount max(0.25 D, 16) at opacity 0.6 over the outermost 1 pt (MAC-ANSWERS Verify B 2: the
        // RegularBase recipe, ramp-measured median error 0.43 px over 11 shapes). Replaced 2026-11-14 the switch strip's
        // fitted band 0.5 D / +0.34 D, which had the opposite sign (it shrank the content toward the rim; GLASS-HIG.md)
        function regularInnerBand(d) { return Math.min(0.25 * d, 20); }
        function regularInnerAmount(d) { return Math.max(-0.5 * d, -60); }
        function regularOuterBand(d) { return Math.max(0.2 * d, 16); }
        function regularOuterAmount(d) { return Math.max(0.25 * d, 16); }
        readonly property real regularOuterOpacity: 0.6
        // its frost (MAC-ANSWERS verify C, Regular <= 64 pt, a = the Liquid Glass slider 0..1, u = clamp(2a),
        // t = clamp(2a - 1)): no centre blur of its own; a blur fill of radius 8 (sigma 2.0 x radius = 16 pt:
        // QuartzCore-glass-blur-pyramid.c, measured 1.93..2.04), normal opacity 0.5 u below 0.5, 0.5 + 0.5 t above;
        // darken (dark) / lighten (light) 0.9 (0.75 + 0.25 u) below 0.5, 0.9 above (LensGlass fillSigma / fillNormal /
        // fillDarken / fillLighten). Replaced 2026-11-14 a 17-tap ring blur of (1 + 4a) 16 / 3 pt (GLASS-HIG.md round 2)
        readonly property real regularFillSigma: 16
        function regularFillNormal(a) { return a < 0.5 ? Math.max(0, a) : Math.min(1, 0.5 + 0.5 * (2 * a - 1)); }
        function regularFillMix(a) { return 0.9 * (a < 0.5 ? 0.75 + 0.25 * Math.max(0, 2 * a) : 1); }
        // its rim and light (MAC-ANSWERS Verify B 1, decoded, pixel-checked there): the dark specular on the rim line,
        // bias -0.25, spread 106 deg light / 75 deg dark on SDR (LensGlass rimBias / rimSpread), and the key / fill
        // highlight (LensGlass fillLight 1: the B2 model, key at the top, fill at the bottom, 80 deg up to D 96).
        // Mac check (liquidglass-0-mid-1-light.png, share capsule, 2x): rim 202 at the top over 223 (model 201), 117 on
        // the left end over 184 (model 112), then 255 just inside the top; the flat black .4 line read 113 / 118
        readonly property real regularRimBias: -0.25
        readonly property real regularRimSpread: t.dark ? 75 : 106
        // the key / fill highlight in both modes (round 5; dark had it off since the Mac's dark top reads only +10 over
        // the face in the first 2 px against the model's +36): that +10 is the highlight less the Settings card the outer
        // sample sees 16 pt above (rimStroke + fillBackdropOutside); dark top 172 178 173 over 165, Mac 174 175 168 over
        // 164 (GLASS-HIG.md round 5)
        readonly property real regularFillLight: 1
        // the rim in dark: the Mac's dark round end (liquidglass-0-mid-1-dark.png, share capsule, row through its centre)
        // reads 202 -> 101; the tone curve over the plain sample gives 130 (we drew 141), over the decoded dark Regular
        // face of it (verify C: 202 -> 170; the filter darkens the rim after the face, verify C2 order) 99. Light keeps the
        // plain sample: there the face first would give 160 against the Mac's 135 (plain: 130). GLASS-HIG.md round 2.
        // Round 4: with the decoded light face (regularFace*) the face first draws the light top rim 214 / 217 (Mac
        // 211 / 210; plain 191 / 197), as the decode orders it; the light round end then reads 170 (Mac 139, not settled)
        // Round 5: the decoded stroke mode (regularRimStroke, LensGlass rimStroke): the line is the pixel outside the
        // glass and tones the plain backdrop there: light top 211 (Mac 211), end 136 (139), dark top line pixel 232 =
        // the backdrop (Mac 232: no lobe at 75 deg). The dark round end still needs the dark face, mixed in by the lobe
        // (fitted: 102 against the Mac's 105, plain 136; round 11: at 0.75 of the lobe, glasslens4.frag); light keeps the
        // plain backdrop (with the face: 162)
        readonly property bool regularRimFace: t.dark
        readonly property bool regularRimStroke: true
        // its face (LensGlass face*, MAC-ANSWERS verify C formulas, C2 1-2 shoulder): black, white, saturation, maxLuma
        // (dark 0.6 at D <= 64; light maxLumaSDR 0.94) and the fill colour by the slider a (u = clamp(2a), t =
        // clamp(2a - 1)): light white at 0.2 u below 0.5, 0.2 + 0.3 t above; dark none below 0.5, grey 0.125 t at 0.5 t
        // above. Replaced 2026-11-14 the fitted gain (light 1.14, dark 0.79) and white / #1E1E1E mixes, which clipped the
        // light sky to white (face 251 where the Mac reads 236-241: GLASS-HIG.md round 3)
        readonly property real regularFaceBlack: t.dark ? 0.125 : 0.4
        readonly property real regularFaceWhite: t.dark ? 1.125 : 1.03
        readonly property real regularFaceSat: t.dark ? 1.3 : 1.2
        readonly property real regularFaceMaxLuma: t.dark ? 0.6 : 0.94
        function regularFaceFill(a) {
            const u = Math.max(0, Math.min(1, 2 * a)), v = Math.max(0, Math.min(1, 2 * a - 1));
            return t.dark ? Qt.rgba(0.125 * v, 0.125 * v, 0.125 * v, 0.5 * v)
                          : Qt.rgba(1, 1, 1, a < 0.5 ? 0.2 * u : 0.2 + 0.3 * v);
        }
        // a 0.5 pt rim line (switch-press-strip-light.png: 249 -> 164 on white, 96 -> 35 on the track: black about a.4)
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
        // Light mode: the Mac's own model of the held slider knob (live/verify/B2 slider_fit.py over gradient captures,
        // rms 0.56 levels; filter inputs of controls-press-light.json): face 0.1 + 0.9 x sample (gain 1, haze .1), the
        // ring shadow (filter inputRingShadowOffset 8, StrokeWidth 4, BlurRadius 3; opacity .4 by the fit, the filter
        // says .1 before its own scaling) and the key / fill highlight (bright at the bottom once the ring darkens the
        // middle); none of the dark terms. Dark keeps the recording's fit above (the ring and fill model is not
        // measured in dark: the recording's lens bottom rises 44 -> 60 over 4 px, frames 2684-2686, which the
        // bottom key light already draws)
        // Dark refit 2026-11-12, fitted to the recording (frame 2685): a vertical profile through the lens 6 pt right of
        // its centre (rows 446-478), levels over the background beside the lens, against this shader's terms over the
        // recording's own background column (32 card, 50 track), drawn at 2 px/pt and resampled to the recording's
        // 1.92 px/pt (native pixel box x a linear resample kernel; the lens position fitted too): gain .85 -> .702,
        // haze .05 -> .091, top diffuse .06 -> .043 (rms 3.48 -> 2.14 levels with the top key light at .128); the top
        // key light then set from our own capture (resampled to 1.92 px/pt the same way) to the recording's +33 peak:
        // .135 -> .092 (.128 drew +39, .08 +31); model rms 2.37, capture against recording 3.02 -> 2.12 levels (0-14 pt,
        // the lens position aligned). Gain and haze trade off (two background levels only: .658 / .099 fits within .1
        // level). The rim line stays .45: our capture resampled reads x0.71 of the background, the recording x0.72 (the
        // x0.54 of GLASS-INTERACTION section 12 was our 2 px/pt capture against the resampled video); .24-.31 read
        // x0.82-0.87. Not refitted: bottom key light, round ends.
        // Bottom diffuse refitted 2026-11-14 (GLASS-INTERACTION section 17): the recording's column 6 pt right of the
        // lens centre (x 694) shows the lens bottom clear of the pointer; under the track the face rises +13.5 -> +18.2
        // over 4 pt where ours stayed flat at +10: .04 over 4 pt -> .03 over 9 pt (rms 2.17 -> 1.71 levels, backdrop-
        // corrected; .025 over 11 pt reaches the track: 1.80)
        // The switch's lens (D = the lens height, 31): the inner term above plus the backdrop's displacementMap +0.25 D
        // over a height of D (MAC-ANSWERS Verify B 5: the dumped stack, field measured on ramps as
        // 7.75 m(depth, 31) - 4.65 m(depth, 3.1), rms 0.26 pt): the rim samples 4 pt OUTWARD and the middle shows the
        // backdrop at about 0.79 x (wide angle). The slider's lens (25 x 20) has its own inner term, 3.6 / -6 = 0.18 D /
        // -0.3 D, and a zero displacement map (Verify B 5 / B2 item 1). Until 2026-11-14 both used the switch's inner
        // term only (GLASS-HIG.md: the switch then magnified its rim where the Mac shrinks it; the slider's fill read
        // 18.2 px tall 1.5 pt inside the round end, the 23.09.23 recording 20, the decoded slider term 20.2)
        readonly property real knobLensBand: 0.1
        readonly property real knobLensAmount: -0.15
        readonly property real knobLensDisp: 0.25
        readonly property real knobLensDispBand: 1
        // the held switch's rim fringes: glassForeground aberration 1.632 pt (Verify B 5; the slider's is 0), the
        // decoded per-normal offset (LensGlass aberration; GLASS-HIG.md rounds 2 and 3)
        readonly property real knobLensAberration: 1.632
        // its edge opacity: 1 at the knob layer's edge, 0 this far in (pt). The dump's EdgeStart -6.2 read as 0 at the edge
        // and 1 from 6.2 pt in (round 6) drew fringes across the track's end inside the lens, which
        // switch-held-stripes-light.png shows clean, its fringes only in the outer 2-2.5 pt: 2 fits their extent and strength (GLASS-HIG.md round 7)
        readonly property real knobLensAberrationEdge: 2
        // the held switch's own glassBackground (live/verify/B/dumps/switch-knob-held.json, a light probe), where it
        // differs from the slider's (slider-knob-held.json) whose B2 light model the knobLens* light terms are: face
        // black 0 (slider 0.1: knobLensHaze), ring shadow 0.1 (slider 0.4), the KeyFillHighlight's dark specular on
        // the rim (bias -0.3, spread SDR 120 deg; MAC-ANSWERS Verify B 1 law, glasslens4.frag rimSpec) instead of the
        // flat black .4 line, and no lens shadow (inputShadowOpacity 0.001). Until 2026-11-14 the switch took the
        // slider's terms: its interior read the track 31 levels darker in blue, shaded (B std 13 vs the Mac's 4.8), the
        // rim 170 / 163 against 201 / 195 (GLASS-HIG.md round 3). Dark (switch-held-stripes-dark.png, round 7): the same
        // dump fits; the lens keeps the card at 42 -> 45-48 (face black 0, not the recording's fitted gain .702 / haze
        // .091), the track 125 -> 120 at the middle (ring 0.1), the rim 20 at the top and 9 at the ends (bias -0.3: 21 / 8)
        readonly property real switchLensHaze: 0
        readonly property real switchLensRingOpacity: 0.1
        readonly property real switchLensRimBias: -0.3
        readonly property real switchLensRimSpread: 120
        // the dark specular's height 1 (inputKeyFillHighlightHeight 1, EffectOffset -1; the slider's Regular-like 0.5):
        // a 1 pt rim line outside the face, 2 px in the strip (196 / 195 at the top); the lens then reads 1.36 x the
        // track's height (Mac 1.35, the 0.5 pt line 1.27)
        readonly property real switchLensOutlineWidth: 1
        // under the light lens the strip's last frame reads 252 -> 247 at the rim, 238 from 3.5 to 7 pt below, back to
        // 247 by 12 pt; switch-held-stripes-light.png 247 -> 234 from 4 to 5 pt below, dark 42 -> 40: the decoded ring
        // shadow (0.1, 4-8 pt under the lens, Knob ringshadow.frag) with the rest shadows faded to 0.3 as on the slider.
        // Rounds 3-6 kept the large rest shadow whole instead (darkest right under the rim, GLASS-HIG.md round 7)
        readonly property real switchRestShadowHeld: 0.3
        // the held slider knob's rim (live/verify/B/dumps/slider-knob-held.json, the same KeyFillHighlight as the switch:
        // height 1, EffectOffset -1 = stroke mode, ColorBias -0.3, SpreadSDR 120 deg, Amount 0.5): a 1 pt line outside the
        // 25 x 20 face, the tone curve over the backdrop. Measured on slider-held-settings-{light,dark}.png (2x, Desktop &
        // Dock > Size held): top 195 over the card 247 (model 194), dark 20 over 42 (model 21), round ends 135 over the
        // track 222, 10-15 over 42 (GLASS-HIG.md round 7). Until round 7 a flat black .4 line of 0.5 pt (light, 163) and
        // .45 of 1 pt (dark)
        readonly property real sliderLensRimBias: -0.3
        readonly property real sliderLensRimSpread: 120
        readonly property real sliderLensOutlineWidth: 1
        // the decoded stack's ring shadow opacity, by the colour scheme: DesignLibrary ControlSliderRecipe.SliderSpecModifier
        // (decomp/DesignLibrary-recipes.c FUN_195f04360, cache 0x195f03360) writes Spec 0x4b8 = environment.colorScheme
        // == .dark ? 0.4 : 0.15 (GLASS-HIG.md section 19). Dark: the dump's 0.4 (the track 62 -> 66 under the face 81 at
        // the lens's middle, x0.81 = 1 - 0.4 x 0.495; the card under the lens 42 -> 34). Light: the earlier fit to the
        // same shot was 0.14 (track 210 under the face 225, card 247 -> 229); 0.15 gives 208 and 229 (computed, not
        // re-shot). MAC-ANSWERS-8.md R8.2 dumped 0.4 / 0.15 on the held SwiftUI slider; over pure white our lens's centre
        // column is the Mac's within rms 0.93 dark (205 at the middle) and 1.0 light (GLASS-HIG.md 20)
        readonly property real sliderLensRingOpacity: t.dark ? 0.4 : 0.15
        readonly property real sliderLensBand: 0.18
        readonly property real sliderLensAmount: -0.3
        readonly property real knobLensGain: t.dark ? 0.702 : 1
        readonly property real knobLensHaze: t.dark ? 0.091 : 0.1
        readonly property real knobLensDiffuseTop: t.dark ? 0.043 : 0
        readonly property real knobLensDiffuseTopDepth: 12
        readonly property real knobLensDiffuseBottom: t.dark ? 0.03 : 0
        readonly property real knobLensDiffuseBottomDepth: 9
        readonly property real knobLensKeyTop: t.dark ? 0.092 : 0
        readonly property real knobLensKeyBottom: t.dark ? 0.083 : 0
        readonly property real knobLensKeyEnds: t.dark ? 0.02 : 0
        readonly property real knobLensKeyFalloff: 0.9
        readonly property real knobLensRingOffset: 8
        readonly property real knobLensRingWidth: 4
        readonly property real knobLensRingBlur: 3
        readonly property real knobLensRingOpacity: t.dark ? 0 : 0.4
        readonly property real knobLensFillLight: t.dark ? 0 : 1
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
        // Hover on a glass button of a capsule (ToolbarHighlight), read off the 23.09.23 recording (Settings > Appearance,
        // dark, 60 fps, the preview's share button: rest frame 0, hover frames 8-63; the capsule 37 pt = 71 px): a disc
        // round the button, in one frame, +19.5 levels added (rest 134,148,158 -> 153,168,178), flat to 28 px from the
        // centre, gone at 32 (radius 15.9 pt, edge 1.6 pt). Light: no recording. The press light is SwiftUI's code
        // (motion.js glow*, Tokens.motion.pressGlow*); the earlier fit to the press frames (a gain 0.35 flat over the disc,
        // linear to 0 at 66 pt, with per-frame rise / fall tables) is in GLASS-INTERACTION.md 4
        readonly property real hoverDiscRadius: 15.9
        readonly property real hoverDiscEdge: 1.6
        readonly property real hoverLift: t.dark ? 19.5 / 255 : 0
        // A SwiftUI glass button's interaction fill (the Appearance preview's MacGlassButton capsules): DesignLibrary
        // MacButtonGlassInteractionFill, a ShapeStyle filled in the button's border shape under its label; resolve(in:)
        // 0x195e04f60 (witness 0x195e04fe8) gives Color.clear for InteractionState idle / disabled, .quinary for
        // rollover and .quaternary for pressed / deeplyPressed (decoded). The level's colour on this glass is measured on
        // preview-hold-shine-share-{light,dark}.mov (R7.1b, hover frames 25-38 against frame 10, the disc 8-14 pt from
        // the share glyph): light -21 / -22 / -24 on (217, 231, 246), black .097 over it on every channel; dark +20 /
        // +18 / +16 on (140, 156, 170), the +19.5 above (23.09.23 recording). Held, the disc shows no step beyond the
        // rollover's under the press light in either clip (dark 9-13 pt +75..80 against ours +77 with +19.5 kept), so
        // the same value is kept while pressed. > 0: added; < 0: black at that alpha over the glass
        readonly property real glassButtonFill: t.dark ? 19.5 / 255 : -0.097
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
        // the parent under a sheet fades towards a grey, it is not darkened by 20 % black: out = 0.396 in + 103 (light),
        // 0.39 in + 12.3 (dark), a veil of #AAAAAA at 60.4 % / #141414 at 61 %. System Settings (R12.3 / R13) and
        // TextEdit's save sheet alike (R17.4 alert-{light,dark}.png: white 255 -> 204, the title 88 -> 138, the
        // document's black text -> 102; dark bar 39 -> 27, white text -> 112). Nothing is blurred
        // The dark veil is not neutral: per channel the offsets are 12.3 / 13.4 / 15.0 (Settings pane (30,31,36) ->
        // (24,26,29), card (53,54,59) -> (33,34,38); TextEdit R17.4 bar (39,39,44) -> (27,28,32), document 30 ->
        // (24,25,26)), a veil of (20,22,24.5). It was #141414: blue 3 low (toolbar 27 against 32 with the tint lost).
        // Light is neutral (255 -> 204, (236,237,238) -> (197,197,198))
        readonly property color sheetDim: t.dark ? Qt.rgba(20 / 255, 22 / 255, 24.5 / 255, 0.61) : Qt.rgba(170 / 255, 170 / 255, 170 / 255, 0.604)
        // the card's shadow over the veil: a Gaussian of sigma 19.6 pt, 23.6 pt down (drawn 21.5), black at 21.9 % light /
        // 45 % dark (settings-r13 dest-controlCenter--clock-options-*.png; R17.4's card reads the same: 180 at the right
        // edge of 204 light, 20 of 25 dark)
        readonly property real sheetShadowSigma: 19.6
        readonly property real sheetShadowOffsetY: 21.5
        readonly property real sheetShadowDensity: t.dark ? 0.45 : 0.219
        readonly property int popoverRadius: 20
        readonly property color popoverFill: t.control.menuFill                     // glass live; flat like the menus
        readonly property color popoverStroke: t.control.menuStroke
        // glass rim (MAC-ANSWERS.md PC #67 B): the dark specular line darkens white 255 -> 192 (black a .25) on the
        // sides; the key highlight lifts the first px at the top (m up to 1.53 with offset +0.147: about white a .45
        // over the light fill, .25 dark) and an 8 pt diffuse band at amount 0.075
        readonly property color popoverRim: Qt.rgba(0, 0, 0, t.dark ? 0.5 : 0.25)
        readonly property color popoverKey: Qt.rgba(1, 1, 1, t.dark ? 0.25 : 0.45)
        readonly property color popoverDiffuse: Qt.rgba(1, 1, 1, 0.075)
        // motion (LIVE-27.2.1.md; per-frame fits to re/27.2.1/live/video-motion-{1,2}.json in
        // re/27.2.1/MOTION-AUDIT.md): alert = AppKit's PopIn and ScaleDownAndOut (AppKit 27.2.1, MOTION-AUDIT.md
        // "Alert, Round R3.1"; curves in panels.js alertPopScale / alertCancelProgress): appear 0.4 s linear, alpha = v,
        // scale amount 0.2; Cancel = spring 0.1812 s, bounce 0, initial velocity 13, scale to 0.98, alpha 1 - p, run for
        // 0.25 s; other buttons hide at once (was in-quad / out-quad 214 / 180 ms to 1.17 at alpha 1 and a 154 ms
        // out-cubic fade for every button); sheet in 0.27 s, out 0.25 s, linear, size constant;
        // popover a spring from 12.5 % (response 0.25, damping 0.9) from the arrow, close = fade on CoreAnimation's
        // "default" curve (0.25, 0.1, 0.25, 1) over 128 ms (remaining .853 .593 .348 .176 .076 .036 .021 .010 .004 0:
        // rms .009; the out-quad 180 ms before it .090, measured on screen .085-.092)
        readonly property int alertPopIn: 400                 // PopIn NSAnimation 0.4 s
        readonly property real alertPopAmount: 0.2           // _scaleAmount for PopIn
        readonly property int alertCancelOut: 250            // ScaleDownAndOut NSAnimation 0.25 s (Solarium)
        readonly property real alertCancelDuration: 0.1812   // initWithPerceptualDuration: 0.1812 bounce: 0
        readonly property real alertCancelVelocity: 13       // setInitialVelocity: 13
        readonly property real alertCancelScale: 0.98        // _scaleAmount 0.98: 1 -> 0.98
        readonly property var popoverFadeCurve: [0.25, 0.1, 0.25, 1, 1, 1]
        // R17.4 alert-{,dismiss-}light.mov, the veil's level per frame: linear at 230 levels / s in (0.26 s for the 59;
        // its first 50 ms are not on screen, the first drawn frame is already at 20 %) and 226 / s out (0.26 s)
        readonly property int sheetIn: 270
        readonly property int sheetOut: 250
        readonly property real popoverFrom: 0.125
        readonly property real popoverResponse: 0.25
        readonly property real popoverDamping: 0.9
        readonly property int popoverFadeOut: 128
        // a menu (pop-up button, NSMenu) closes on the same curve over 236 ms: the Mac menu probe's alpha fits it at
        // rms .0004 (MOTION-AUDIT.md item 2; the shell's Theme menuFadeOut and Hyprland's fadePopupsOut use the same)
        readonly property int menuFadeOut: 236
        // pop-up button menu (R3.5, controls/popup-menu-open-close-{light,dark}.mov, 60 fps; ui/HyprK/Popup.qml): the
        // pressed look shows 3 (dark) / 4 (light) frames before the menu; a chosen item's highlight is off 4 frames and
        // on 3 (the menu bar's blink, shell Theme.menu.blinkOff / blinkOn), then the fade, CA default 232 / 234 ms (rms
        // .002). Pauses counted in frames (FrameAnim): 58 ms ends with the 4th frame, 42 ms with the 3rd
        readonly property int menuOpenDelay: 42
        readonly property int menuBlinkOff: 58
        readonly property int menuBlinkOn: 42
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
        // The press (reference/re/27.2.1/LIGHTS-REA-27.2.1.md): SwiftUI FlexInteraction, variant windowControl
        // (DesignLibrary MacWindowControlElement.body sub_195e39790; preset FlexInteraction.Settings.windowControl
        // 0x1908b1bb4). From mouse-down to mouse-up the light (disc and glyph) lifts by liftPoints on its longer side
        // (16 pt from 14, Q-windows-08 saw 16-17 pt) and stretches toward a dragged pointer (k per axis from
        // stretchDistance), all on one spring, press and release alike: decoded response 0.355 s, damping fraction 0.4
        // (to 1.18 at 0.19 s, back to 0.96 after the release; the values below are the measured ones). The gesture ends after idleTimeout ms without pointer
        // events (GestureComponent.idleTimeout 2 s; what it does is inferred). plugin/src/LightPress.hpp has the same.
        // Measured on three Mac 60 fps recordings (LIGHTS-REA sections 8 and 9: windows/close-button-hold-drag.mov,
        // close-button-hold-still-{dark,light}.mov; disc width and height per frame): one spring for the press, the
        // release and the idle end, as decoded, but response 0.31 s / damping 0.5 (12 series, rms 0.096 pt; the decoded
        // 0.355 / 0.4 gives 0.126 and starts late): 16.33 pt at 0.18 s on the press, 13.67 on the way back.
        // idleTimeout: a still hold ends 2.10 s (dark) / 2.12 s (light) after the press, first moving frame to first
        // moving frame (the decoded constant is 2 s); the size springs back, the pressed colour stays while the pointer
        // is on the button.
        readonly property real liftPoints: 2
        readonly property real liftResponse: 0.31
        readonly property real liftDamping: 0.5
        readonly property real stretchDistance: 3825.649
        readonly property int idleTimeout: 2100
        // leaving the button while it is held: the pressed colour (disc and glyph) fades back to the rest colour as a
        // critically damped spring of this response, starting 84-102 ms after the drag starts (close-button-hold-still-
        // {dark,light}.mov: rms 0.009 of the way; CA default 0.5 s gives 0.012). Taking the pressed colour (mouse-down,
        // coming back onto the button) is one frame
        readonly property real leaveFade: 0.5
        // ... and it starts this long after the pointer is off the disc: the cursor drawn in the clips leaves the 7 pt
        // disc at 3.283 s (dark) / about 3.53 s (light), the fitted fade starts at 3.369 / 3.601 s: 86 / 70 ms
        readonly property int leaveFadeDelay: 80
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
        // (The discs are drawn from TrafficLights.glass; in dark the inactive one is a white veil, alpha .17, R16.4.)
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
        // the lift's way back after the release: measured on the 23.09.23 recording (preview share capsule, frames 252-275
        // and 361-399, passthrough index): no overshoot, a critically damped fit of response 0.21 s (rms .033; the press
        // spring 0.25 / 0.629 gives .079). The code (updateEffect 0x190c220d4) animates the release on the same
        // scaleSpringResponse / Damping as the press (the tracking pair only with the pulse gate): the measured settle
        // is kept, the difference is not explained by SwiftUI's code (GLASS-INTERACTION.md 3)
        readonly property real pressReleaseResponse: 0.21
        readonly property real pressReleaseDamping: 1
        // the press light (FlexCoreInteractionModifier.Value.updateGlow 0x190c24650, every spring damping 1): its centre
        // follows the pointer on 0.15 s; the opacities rise on 0.1 s; beyond the dissipation distance (motion.js
        // glowPreset) and after the release the little glow and the glow scale move on 0.5 s, the big glow fades on 0.5 s.
        // The 23.09.23 recording agrees: the capsule's brightness rises like a 0.1 s and falls like a 0.5 s critically
        // damped spring (rms .019 / .017)
        readonly property real pressGlowFollow: 0.15
        readonly property real pressGlowRise: 0.1
        readonly property real pressGlowFarResponse: 0.5
    }
}
