# Open fixes proposed but not applied (2026-11-14, quick round 19:49-20:01)

Read-only agents, 10 minutes each, no session or build: each item is a proposal from code and Mac pixels, not yet
rendered or measured on screen. Apply one at a time and verify in a headless session before keeping it.

## Glass

1. **CC Sound held lens, rim over the white fill** (judge #19 claim 3; GLASS-HIG.md Round 7 "What remains": ours
   187 / 179, Mac 227 / 170). No alpha-over term darkens it (over the fill ca = 1, so emptyLevel, eLine, eRing vanish).
   - Line px: the tone curve tops out at 1 + (-0.3)(3 - 2) = 0.70 = 178.5 (ours 179); the Mac's 170 = 0.667 x 254 needs
     rimBias -0.333. Proposal: a CC-only `Theme.cc.lensRimBias` -0.333 used at `ui/HyprK/Slider.qml:251` (keep
     `Tokens.qml:234` -0.3: the Settings slider fits it).
   - Outer px 187 is item-edge AA (cover ~0.89); the Mac's 227 = cover ~0.32: our lens edge sits ~0.28 pt further out
     over the fill. Proposal: `glasslens4.frag:338` `cover = clamp(0.5 - (d + 0.28 * ca * line * float(rimSpec.z > 2.5))
     / px, 0.0, 1.0)` (and the same at lensImg ~310); `ca` keeps the module side unchanged.
   **Applied 2026-11-14, re-derived (GLASS-HIG.md round 11), neither proposal**: the stroke line had no ring term over an
   opaque source; now line x (1 - ring) after its tone (`glasslens4.frag` rimc). Line pixel per fill row, Mac 175 173 172
   168 165 162 160, before 179 flat, after 175 173 171 170 168 167 165 (mean 169.2 / 178.7 / 170.7). Settings slider and
   switch: bottom rims and ends 1-2 closer in light (dark slider bottom rim 18 -> 17, Mac 19-20); CC light left end 184
   -> 176 (Mac 178). Bias -0.333 not applied (flat, darkens the top rim over the module); the edge shift not applied (the
   line's darkening across the crossing now equals the Mac's; the outer pixel is the knob's sub-pixel phase).
2. **Liquid Glass preview, dark round ends** (judge #19: right end 99, Mac 110). Stroke mode, z 4 (dark only): the line
   px is mix(backdrop, face(backdrop), hs) then the tone curve; hs = 1 at the round end. Proposal: `glasslens4.frag:277`
   `clamp(hs, 0.0, 1.0)` -> `clamp(0.75 * hs, 0.0, 1.0)`: right end ~108 (Mac 110), left ~105 (Mac 102 flat grey / 105
   over the photo); light unchanged (z 4 is dark only); top line stays 232. The 1 px late ramp is separate (outer
   sample, frag:213-224).
   **Applied 2026-11-14 (round 11)**: the five round ends' middle 107 103 102 103 103 -> 115 109 108 109 108 (Mac 109 111
   111 111 111; the share capsule's left end is 4 further off); along the arcs mean |ours - Mac| 10.1 -> 6.4; light
   unchanged.
3. **Held switch** (GLASS-HIG.md §13 "Still different"; judge #19 "switch outer rim +9"), most visible first:
   - soft white edge inside the lens: `glasslens4.frag:95` `cv = clamp(0.5 - dd * 2.0, 0.0, 1.0)` ->
     `clamp(0.5 - dd / 1.75, 0.0, 1.0)` (try 1.75-2.5 pt against the Mac row 143 -> 177);
   - outer rim +9 (held 205 vs 196): the lens top at full lift sits 0.2 px off the grid; round x / y to device px in
     `Knob.qml:72-73` (a guess: measure);
   - light top highlight mid-growth 255 vs 226: `frag:258, 260` `fxs * fillLight` -> `fxs * fxs * fillLight` (fit only;
     check dark 57 vs 69 does not worsen);
   - early light rim 5-13 lighter: `Switch.qml:76` fades the press overlay in with `_lift`; full alpha while `_held`
     (whether the Mac's darkening is instant is not checked).
   **Round 11 (GLASS-HIG.md 16)**: soft white edge **applied** as a 1.75 pt ramp centred on the edge plus the stroke line
   reading the backdrop without the white (`tapBack`; the ramp alone lightened the rim 4-6 mid-growth): 10-90 % rise dark
   1.1-2.4 -> 2.1-3.4 px (Mac 2.1-3.2), light 1.0-1.2 -> 2.0-2.5 (Mac 1.7-4.7). Outer rim **rejected**: y on the device
   grid moves the split pixel to the bottom (light top 206 -> 220, bottom 202 -> 192; the lens is 40.6 px tall).
   Highlight `fxs * fxs` **rejected**: the light 255 stays (it is the white refracted up), dark top rms 18.4 -> 23.6.
   Instant press layer **rejected**: the light rim rms 14.1 -> 8.8, but the Mac's track outside the lens darkens with
   the growth (248 -> 225 over 8 frames, ours already within 1) and the instant layer drew 223 from the first frame.
4. **Regular glass, dark side rim** (GLASS-HIG.md §14: alert 53 vs Mac 46, menus 53 vs 47). Only the dark specular tone
   lights the dark side px (`liquidglass.frag:330-336, 463-466`; at spread 75 deg its lobes are 0 at top / bottom).
   Ruled out: key / diffuse band, edge AA / fractionEdge, a second lobe, ring / drop shadow. Fit (not decoded): REGULAR
   `.dark.darkBias = -0.278f` (`plugin/src/Material.cpp:22`): alert 112 -> 45.9, menus 113 -> 46.6. MENU and NC inherit
   it (NC side line not checked); Spotlight and Control Center keep their own.
   **Applied 2026-11-14 (round 11)**: alert 53 / 53 -> 46 / 46 (Mac 47 / 47 on rows 420..580), Apple menu 53 -> 46 (Mac
   47), NC card 67 -> 63 (Mac 54), banner 82 -> 78 (Mac 67); desktop with the Dock, Control Center and Spotlight
   pixel-identical; light untouched. `check_model.py` lists it as a deviation from the dump. plugin/build needs a rebuild.

## Text and vibrancy

5. **Light status modules, plus-darker text** (VIBRANCY-REA.md: secondary -104, lines -20 in light). `fill_layers`
   draws rounded rects of a layer's background-effect region at one amount per namespace (`main.cpp` 95-177,
   `GlassElement.cpp` drawFills ~1100): fits the lines (`hyprk-status-lines:darker:20`), not glyphs. For glyphs:
   (a) the existing `icon_masks` path (G channel = max(c - G, 0), exact plus-darker; acts on the glass under the QML,
   shared `hyprk-overlay` namespace); or (b, recommended) a new `fill_textures = "hyprk-status-ink:darker"` sampling
   the layer texture (the `sdf_layers` path) under REVERSE_SUBTRACT. Both need a second ShellWindow in
   `StatusModuleWindow.qml` (same anchors, overlay layer, exclusionMode Ignore, empty input region, mapped only in
   light with the plugin), the secondary items at opacity 0 in the main one. Risk: two surfaces may commit a frame apart
   while the panel animates.
6. **Emoji drawn at half size at exactly 31, 40 or 74 px text** (EMOJI-TEXT.md). CBLC line heights 25-(-6) = 31,
   33-(-7) = 40, 61-(-13) = 74; FreeType's available_sizes.height = ascender - descender (whole px); Qt picks the
   smallest strike with height >= pixel size, scale = pixelSize / height; at scale exactly 1 it treats the strike as
   device-sized and drops the DPR (the old font failed at 21, 27, 33, 41, 53, 97). Not fixable in the font (any whole
   line height is a size someone can set); fix in Qt or the app (e.g. pixelSize + 0.01). Qt source line not checked.
   Verify: text at 30 / 31 / 32 px at DPR 2.
7. **Spotlight mode list glyphs** (SPOTLIGHT-27.2.1.md R4.4): ⌘ spacing fixed (ModeList.qml:51, U+2005). Left: the
   Mac's ⌘ is 12.5 pt wide (ours ~10); Actions looks like `square.2.layers.3d` (reading of the still, not decoded; no
   such SVG under themes/icons/sf-symbols/, so it stays `bolt`); Clipboard is all outline on the Mac (our
   `document.on.clipboard` has a filled back board). Names at `shell/lib/spotlight.js:14-15`.
   **Round 17 (2026-11-15)**: the shortcut is SF 17 with the digit in a monospaced slot (⌘ 12.5 x 13 from x 459, as
   `live/r17/spotlight-modelist-*`), the Applications glyph 22.5 x 20, the bar's mic the outline `microphone`. Left:
   Actions and Clipboard glyphs (the Mac's are layered squares and two outline documents: a Mac dump of
   `square.2.layers.3d` and `document.on.document` is needed).

Mac round 6 data for these, not analysed yet (reference/re/MAC-ANSWERS-6.md): R6.1 dark Settings over flat red /
green / navy (window tint follows the desktop: sidebar 53,34,32 / 35,43,32 / 35,35,53, content 46,38,37 / 39,43,38 /
35,35,42), R6.2 HUD appear over grey light and blue dark, R6.5 emoji in secondary text (finder/emoji-secondary-*).

## Motion

8. **Mission Control pick, Finder +4 frames** (MOTION-REA-27.2.1.md Round 6; Settings is +2 like the Mac). Ranked:
   (1) the `hyprk-pick` hint not taking effect in Finder (pid / title match or the blocking `j/clients` call in
   `finder/src/hypr.cpp` 36-51), so Finder colours from the focus 2 frames later: confirm with
   `hyprctl dispatch 'hl.dsp.event("hyprk-pick,0x<finder>")'` outside MC; fix: match the address only; (2) Finder's
   commit waits on the previous wl_callback (basic render loop, `main.cpp` 79-80): try `QSG_RENDER_LOOP=threaded`;
   (3) a capture timing race (Hyprland copies at the next monitor commit, Quickshell re-asks only after `ready`).
9. **Segmented control drag** (Mac R6.3, controls/segmented-drag-{light,dark}.mov, Finder's view switcher): no lens on
   macOS; the pressed pill stays, jumps to the next segment when the pointer is over it, commits on release. Check
   `ui/HyprK/SegmentedControl.qml` (it may follow the iOS lens drag from reference/hig/).
11. **Window buttons, disabled and inactive** (Mac R6.4, windows/lights-{zoom-disabled,inactive}-press-dark.mov):
    a disabled zoom (Calculator) is a grey disc, no glyph on hover, no press change; on an inactive window the grey
    lights turn coloured with glyphs on hover, close darkens on press and closes on release without activating the
    app. Check TrafficLights.qml and the plugin's Titlebar / LightPress against it.
10. **Finder toolbar Group and collapsed View buttons** reopen their menu on a second click (the ⋯ menu was fixed:
    finder/qml PopupMenu `closing`, Toolbar `menuUp` / `inMenu`); same fix pending.
    **Applied 2026-11-15** (judge #21): `groupButton` and `viewPopupButton` take the ⋯ button's `inMenu` (decided on
    the press from `menuUp`). On screen (headless Finder, dark): Group x4, collapsed View x4 (search open), Group with
    search open x4 and ⋯ x4 each open / close / open / close.

## Mac round 6 analysis (2026-11-14 20:00-20:40, read-only agent, nothing applied)

Data: reference/re/MAC-ANSWERS-6.md and the INDEX rows of each folder. Pixels are raw values (the PNGs are tagged
"Display", P3 primaries; the repo quotes raw values). The flat desktops were sRGB pictures, so on the display red
255,0,0 = (234,51,35), green 0,160,0 = (71,158,44), navy 0,0,128 = (0,0,123) (lcms, relative colorimetric); fits on
the sRGB values are inconsistent across the three colours, on these they are not. Clips: pts from `ffprobe
-show_frames`. Scripts in the agent's scratch only. Items 9 and 11 above and the "Mac round 6 data" note under 7 are
answered here.

12. **Dark Settings window follows the desktop (R6.1)**. Window px, raw: window background (1300,800), card
    (900,1150), sidebar (240,700). MAC-ANSWERS-6's "content (1200,1200)" is a card, its "toolbar strip (1200,60)" is the
    window background.

    | desktop (display values) | window | card | sidebar |
    |---|---|---|---|
    | red (234,51,35) | 40.5,31,30.5 | 46,38,37 | 53,34,32 |
    | green (71,158,44) | 32,36,30.5 | 39,43,38 | 35,43,32 |
    | navy (0,0,123) | 28,28,35 | 35,35,42 | 35,35,53 |
    | grey 127 (appearance/liquidglass-flat-grey-dark.png) | 35 | 42 | 40 |
    | TahoeDark (panes/appearance-00-dark.png) | 30.5,31,36.5 | 37,38,43 | 35,37,52 |

    Model, per channel, c = the chameleon colour (6-bit mean of the wallpaper under the window, MAC-ANSWERS C3.1), 0..255:
    - window = **28.24 + 0.0525 c** (a 5.25 % blend of c over grey 29.8): rms 0.23 on the 4 flat desktops. Held out,
      TahoeDark (mean under the 740 x 625 window at 350,150, aspect fill: (40.6,54.9,157.1), q6 (40.5,52.6,157.9)):
      (30.4,31.0,36.5), Mac (30.5,31,36.5).
    - card = window + white 3 % (`Theme.cardFill`, unchanged): TahoeDark (37.1,37.7,43.1), Mac (37,38,43). A free fit
      (35.48 + 0.0486 c) is the same within 0.5.
    - sidebar = **`Ch.apply(35.20 + 0.04253 c, c, true)`** (the decoded colour blend at 0.10 on top): rms 1.06 on the
      flats, TahoeDark (35.0,36.7,51.2), Mac (35,37,52). With the opacity free: base 36.22 + 0.02986 c, blend 0.1306,
      rms 0.40, TahoeDark (34.9,36.8,53.3).
    - Ruled out: the sidebar as glass over the desktop (C3 glass_model sb17 / sb18 over grey 127: 134 / 76 against 40);
      a plain linear sidebar fit (rms 4.0).

    How: QML, not the plugin. The Mac's window is a uniform fill of the mean (R3.8b, uniform from x 6 to 200), not a blur:
    plugin window glass (`window_classes`) would show the blurred desktop and blur the whole window every frame. The
    tint is one 16 x 16 average per wallpaper change, and WallpaperTint -> Theme.chameleon already exists. Change:
    - `settings/Theme.qml:162` `theme.dark ? "#1E1F24" : "#FFFFFF"` -> `!theme.dark ? "#FFFFFF" : _chOn ?
      Qt.rgba((28.24 + 13.39 * c.r) / 255, (28.24 + 13.39 * c.g) / 255, (28.24 + 13.39 * c.b) / 255, 1) : "#1E1F24"`
      (c = theme.chameleon, `_chOn: theme.tintWindow && !!theme.chameleon`; 13.39 = 0.0525 x 255).
    - `settings/Theme.qml:125-126` (sidebar), dark key window with `_chOn`: `Ch.apply({ r: (35.20 + 10.85 * c.r) / 255,
      g: ..., b: ... }, c, true)` (10.85 = 0.04253 x 255). Light unchanged; the inactive sidebar stays flat #24262B (not
      measured over other desktops). Comment 121-122 ("Dark takes the measured colour as it is") goes.
    - `ui/HyprK/WallpaperTint.qml:25`: average the picture under the window, not all of it. Settings opens centred
      (settings/hyprland-rules.lua `center`): map the 740 x 625 rect centred on the output through the aspect fill
      (s = min(iw / Sw, ih / Sh), offsets (iw - Sw s) / 2, (ih - Sh s) / 2) and `g.drawImage(url, sx, sy, sw, sh, 0, 0,
      16, 16)`. The whole TahoeDark (q6 (28.3,36.4,117.4)) gives window (29.7,30.2,34.4), 2 low in blue. The Mac's colour
      follows a moved window at once (C3.1); a centred rect covers the default place.
    Expect: TahoeDark window (30,31,36) = today's #1E1F24, sidebar (35,37,51) (today #232634). Flat red: window (41,31,30),
    card (47,38,37), sidebar (52,34,33). Verify: headless dark Settings at scale 2 over flat wallpapers holding the
    display values above (Qt reads raw values), sample the three points; within 2 levels of the table.
    Not measured: light windows over colours, inactive dark windows, Finder (its window background is likely the same).
    **Applied 2026-11-14** (window and sidebar as above). On screen (headless Settings, dark, scale 2, Appearance pane,
    2880 x 1864 flat pictures in display values, the three window px points), ours / Mac (window, card, sidebar):
    red (41,31,30) (48,38,37) (52,34,33) / (40,31,30) (46,38,37) (53,34,32); green (32,37,31) (39,44,38) (36,44,33) /
    (32,36,31) (39,43,38) (35,43,32); navy (28,28,35) (35,35,42) (34,34,51) / (28,28,35) (35,35,42) (35,35,53); grey 127
    (35) (42) (41) / (35) (42) (40); TahoeDark (30,31,36) (37,38,43) (35,37,51) / (30,31,36) (37,38,43) (35,37,52). Within
    2 everywhere (red card r and navy sidebar b at 2); before, every desktop gave (30,31,36) (37,38,43) (35,38,52), which
    the tint switched off still gives. Changes beyond the plan, each from a shot:
    - WallpaperTint read the canvas back with getImageData, which at a device pixel ratio of 2 returns only the top-left
      quarter (TahoeDark centre (64.8,52.6,182.1) for (36.4,52.6,157.9); the light sidebar had the same fault). It now
      loads a 64 px copy (`loadImage(url, 64 x 64)`, smooth scaled) and averages its pixels from `createImageData(url)`,
      area-weighted, once per path or size; a copy already in Qt's pixmap cache gets a paint request (no imageLoaded).
      `screenSize` / `windowSize` (SettingsApp: `Screen` and 740 x 625); Finder keeps the whole picture.
    - Light (answers "light windows"): the window stays white, 255 with cards 247 over grey 127 and TahoeLight
      (appearance/liquidglass-flat-grey-light.png, panes/*-light.png), so no window tint. The sidebar reads 237 over grey,
      (236,237,238) over TahoeLight: the base is now a neutral #EDEDED under the 0.05 blend (ours 237 / (237,237,238));
      #ECEDEE, itself the Tahoe reading, gave (236,237,238) / (236,237,239).
    - Dark, not key: flat #1D1E20, from desktop-dock-inactive-dark-iconDark.png (window (29,30,32), cards (36,37,39) =
      it + white .03); was #1E1F24. Its toolbar strip (37,38,39) is lighter than the window there; not built.
    Hyprland's `center` put the window at 270,76, 27.5 pt above the output's centre that the mean uses: TahoeDark's
    mean there differs by one 6-bit step in green (window 30.79 for 31.00), TahoeLight's by one or two (light: sidebar
    blend only). The Mac's mean follows a moved window; ours does not.

13. **HUD over grey light and blue dark (R6.2)**. Method: per frame, least squares of (frame - first frame) on
    (rest - first frame) split into interior glass, rim and content, warped by a scale about the capsule centre
    (632.5, 85.5 px); o = (s - 0.9) / 0.1, spring starts fitted on frames with o .3-.97. Control: the same method on the
    R3.4 clip gives t0 .581, hide 1.581, hold 1.000 (R3.4 .582 / 1.582 / 1.000). This metric's absolute curves differ
    from R3.4's, so the new clips are compared with the R3.4 clip at the same spring time:

    | clip | appear t0 | hide t0 | hold | first frame | last change | content rms vs R3.4 (appear / hide) | glass | rim |
    |---|---|---|---|---|---|---|---|---|
    | grey light | .448 | 1.4675 | 1.020 | t0 + .035 | hide + .499 | .006 / .003 | .007 / .010 | .009 / .014 |
    | blue dark | .480 | 1.5015 | 1.022 | t0 + .018 | hide + .465 | .013 / .010 | .122 / .160 | .060 / .037 |
    | grey dark (R3.4) | .581 | 1.581 | 1.000 | t0 + .018 | hide + .502 | - | - | - |

    Holds, no change: the springs (scale rms .006-.008, control .007); content `o x clamp((o - .25) / .51)` in light and
    over colour; glass `o^2 x .925` while o < .99 over grey in light too (step at t0 + .552, o .988, R3.4 .551; first
    hide frame .891, model .892); the empty dash is plus-lighter +28 (grey light: 133-134 over glass 104-105, +29; blue
    dark (86,99,253) over (60,73,228), +26 on every channel in video levels; white a.16 would give +31 / +29 / +4).
    Differs: (1) hold 1.020 / 1.022 s on the new clips (one 60 Hz frame); the three Mac clips average 1.014, ours .985-1.019:
    keep `hideAfter` 1050 / `showDelay` 26. (2) Over blue the glass comes in earlier and leaves later (+.08 appearing, +.13
    hiding, of its rest value; best power about o^1.5 against o^2.5 on grey with this metric), its step comes at o ~.975
    (t0 + .468) and the first hide frame does not drop. One `glassAlpha` cannot fit both: the saturation part (most of
    the signal over blue) seems to follow o, the darkening (over grey) o^2. Not decoded; leave the QML as is (a fix is a
    plugin split of saturation and tint alphas).

14. **Segmented control drag, Finder view switcher (R6.3)** (answers 9). Pill top band y 44..48 px, Icons x 62..70, List
    x 142..150, face x 226..234; light (dark):
    - rest, selected 224 (72.5) on the face 242-245 (57); pointer over the selected segment, in one frame: 211.6 (88.1);
      mouse-down, one frame: 201.5 (dark 104.7 -> 106, the dark toolbar wash already in, face 64).
    - drag: the selected stays pressed until the pointer is over List, then in one frame (light 2.267 s, dark 2.317 s)
      Icons goes back to plain selected 223.5 (83.2) and List gets a pill **in the selected colour, not darker**, 224.0
      (84.1); the List | Columns separator hides in the same frame.
    - release (light 4.083, dark 4.033), one frame: Icons has no pill, List is selected + hovered 210-213 (100-102); the
      pointer leaving: 222 (80).
    - the capsule **lifts** on mouse-down: width 318.2 -> 322.7 px settled (+2.25 pt = `motion.js pressScale(161, 37)`
      1.014 exactly), peak 323.1 at ~0.1 s (~9 % over), +0.5 px top and bottom (uniform scale); on release back in one
      frame (322.4 -> 317.9). No glow, no lens, the face does not change.
    Ours (ui/HyprK/SegmentedControl.qml, finder/qml/Toolbar.qml 75-109): no lens, one-frame jump and commit on release
    match. Changes:
    - a) dragged-to segment: `SegmentedControl.qml:111` draws `pushFill` + black .098 (light ~203, dark ~71; Mac 224 /
      84) -> `color: sc.pressedIndex === sc.currentIndex ? "transparent" : sc.selectionColor`, and the overlay at 112
      only when `sc.pressedIndex === sc.currentIndex`.
    - b) pressed selected segment: light black .10 (224 -> 201.5, = `pressOverlay` .098), dark **white .134** (83 -> 106).
      New `property color pressOverlay: Tokens.control.pressOverlay` used at 112; Finder: `pressOverlay: Theme.dark ?
      Qt.rgba(1, 1, 1, 0.134) : Qt.rgba(0, 0, 0, 0.098)`.
    - c) hover on the selected segment (ours has none): light black .056, dark white .085 (72.5 -> 88.1, before the
      wash). New `property color hoverOverlay: "transparent"`, `hoverEnabled: true` on `ma` (182-191), `readonly property
      int hoveredIndex: ma.containsMouse && !ma.pressed ? ma.indexAt(ma.mouseX) : -1`, a Rectangle like the pressed one
      while `hoveredIndex === currentIndex`. Hover on an unselected segment is not in the clip.
    - d) separators: `SegmentedControl.qml:119` `touches` also `|| (sc.pressedIndex >= 0 && (sc.pressedIndex === b - 1 ||
      sc.pressedIndex === b))`.
    - e) lift: on the `views` Capsule (Toolbar.qml:75) `PressSpring { id: viewsLift; pressed: viewSwitcher.held; w:
      views.width; h: views.height; instant: !pressed }` (release in one frame) and `transform: Scale { origin.x:
      views.width / 2; origin.y: views.height / 2; xScale: viewsLift.scale; yScale: viewsLift.scale }`, with `readonly
      property bool held: ma.pressed` added to SegmentedControl. PressSpring's damping for 161 x 37 is .375 (28 % over);
      the Mac's ~9 % fits ~.6 (motion.js ultra .629): one clip, sub-pixel, so try .6 and compare. ToolbarHighlight's
      "a platter neither glows nor lifts" holds for back / forward, not for this control.
    Verify: headless Finder at scale 2, press-drag-release over the switcher (vptr), mcap per frame: the levels above
    within 3, capsule +4.5 px wide while held, one-frame jumps; ui qml tests for the pressed colour and separators.
    **Applied 2026-11-14** (a-e, with measured values; LIGHTS-REA is not involved). Re-measured on the clips, green,
    pill interior left of the glyph (clip px 62..70 x 56..68, clear of the cursor drawn in the clip): light rest 223.4,
    hover 212.2 (black .050), pressed 202.8 (.092), dragged: Icons 225.8 / List 226.8, separator 220 -> 250, release List
    214.5, pointer gone 225.5; dark rest 70.0 / face 51.8, hover 87.8 in one frame, then the toolbar wash fades in over
    about 150 ms (strip 26 -> 33, 0.53-0.68 s; ours is instant, not changed), hover + wash 93.9, pressed 99.1 (over the
    plain selected + wash 77.1: white .094 / .124), dragged Icons 77.1 / List 78.3. Lift: right edge +2.07 px light,
    +2.08 dark (width 322.0 -> 326.2 = **2.1 pt**, not motion.js's 2.25), 42-44 % in the first frame, 82-91 % in the
    second, settled by ~50 ms; the 4-11 % "overshoot" of the half-crossing is the rim blurring while it scales (the rim
    minimum moves under 0.1 px): spring 0.065 s / 0.96 (rms 1.7 % of the lift; PressSpring's 0.25 / 0.375 7.7 % and a
    28 % bounce), so not PressSpring. Built: `SegmentedControl.qml` `pressOverlay`, `hoverOverlay` (default none),
    `hoveredIndex`, `held`, the dragged-to segment in `selectionColor` with the selected label colour (`lookSelected`),
    its separators hidden; Finder `Toolbar.qml` hover / press overlays light black .049 / .091, dark white .090 / .123, a
    `Spring { response: 0.065; damping: 0.96 }` lift of `Theme.toolbar.viewsLift` 2.1 pt, released in one frame, none
    under Reduce Motion (finder/FALLBACKS.md). Settings' Sound Output / Input picker (a SwiftUI segmented Picker, an
    NSSegmentedControl) tracks the same way (inferred, not captured); it gets no hover layer and no lift. On screen
    (headless Finder, scale 2, same regions): light rest 229.3, hover 218.1 (.049), pressed 208.5 (.091), dragged
    Icons 229.6 / List 230.7, separator 226 -> 251.5, release List 219.7, away 230.7; dark rest 82.0, hover + wash 103.9,
    pressed 107.9, dragged 88.0 / 88.0 (white .095 / .119 over 88), separator hidden; right edge +1.99 px light / +2.08
    dark, 47-63 % in the first frame, 94 % in the second, back in one frame. Our absolute pill / face levels (light
    229 on 251, dark 82 on 62) differ from this clip's (223 on 249, 70 on 52) as before (Theme.color.capsuleSelected,
    other captures): not changed.

15. **Window buttons, disabled zoom and inactive window (R6.4)** (answers 11). Dark, lights at clip px x 52 / 97 / 143,
    y 62; radius from the top edge (half max).
    - Disabled zoom (Calculator, key): the grey disc (60,61,66) never changes colour and never shows a glyph. Red and
      yellow glyphs fade in .28 .71 .84 .93 1.0 over 5 frames from ~50 ms after the pointer reaches the group (the
      `glyphIn` shape). Press (0.933 s): the grey disc **lifts in one frame**, radius 14.2 -> 16.1 px (x1.135, the 2 pt
      lift), held 1.55 s unchanged; release (2.483): back to 14.1 by 2.567 (5 frames, ~85 ms), under by <= 0.1 px, 14.18 at
      2.767; the release does nothing. MAC-ANSWERS-6's "no visible change" holds for the colour, not the size.
    - Inactive window (TextEdit behind the key Calculator), grey (69,68,75): pointer onto close at 0.383, the next frame
      (0.400) shows all three in colour **with full glyphs** (yellow glyph centre (175,47,7), settled (180,46,0)): no
      70 ms wait, no fade. Press (1.050): close lifts in one frame, radius 14.4 -> 16.0-16.5 px, colour **lighter**, top
      inner (248,77,65) -> (253,103,89), the active pressed ring (255,102,86, LIGHTS-REA 9); not darker. Held 0.83 s
      unchanged; release 1.883: the window fades 1.933 -> 2.033 (6 frames), the app is not activated (MAC-ANSWERS-6).
    Ours (ui/HyprK/TrafficLights.qml) changes:
    - a) the disabled zoom keeps still (`MouseArea.enabled: light.enabled_`, line 214): -> `enabled: true`; line 102
      `down: ma.pressed && ma.containsMouse && enabled_` (no pressed colour); `onClicked` (229) starts with `if
      (!light.enabled_) return;`.
    - b) one-frame lift for a disabled light or an inactive window (ours: spring .31 / .5, ~0.2 s): `property bool
      snapLift`, set in `onPressed` (215-220) `light.snapLift = !tl.active || !light.enabled_;`, and on the four Springs
      119-122 `instant: Tokens.reduceMotion || (light.flex && light.snapLift)`. The disabled release (~85 ms, no visible
      overshoot) fits the decoded tracking spring .1 / 1.0 (LIGHTS-REA table, scaleSpringTrackingResponse / Damping; 96.6 %
      at 83 ms): `response: light.enabled_ ? Tokens.lights.liftResponse : 0.1`, `damping: light.enabled_ ?
      Tokens.lights.liftDamping : 1`.
    - c) glyphs on an inactive window at once: line 53 `interval: Tokens.reduceMotion || !tl.active ? 0 :
      Tokens.lights.glyphDelay`; line 176 `enabled: !Tokens.reduceMotion && (tl.active || !tl._glyphs)` (fade-out
      unchanged, not measured inactive).
    - d) the pressed colour of an inactive window (line 73, the active `press` look while lit): already right.
    - e) no activation: `plugin/src/Titlebar.cpp:715` focuses the window at mouse-down even on a light -> `if (hit < 0 &&
      !Desktop::focusState()->isWindowActive(window))` (`hit` is known at 712). Not checked: whether Hyprland refocuses
      before the decoration hook. Qt windows (Finder, Settings): Hyprland focuses on the press (follow_mouse 2,
      InputManager::processMouseDownNormal) before Qt sees it; avoiding it needs the light rects in the compositor. Left.
      **Applied 2026-11-15** (judge #21): the apps send their lights' rect (`hyprctl liquidglass lights <class> x y w
      h`) and the plugin hooks processMouseDownNormal (plugin/src/ClientLights.cpp): Finder and Settings stay inactive
      while a light is held and close on release with the key window unchanged (LIGHTS-REA section 11).
    - f) plugin, as b / c: `glyphAlpha()` (Titlebar.cpp:324-328) returns 1 at once when the hover began on an inactive
      window (a new `m_glyphInstant` set beside `m_hover` at 663-666); `CLightPress::press` (LightPress.hpp:52) gets a
      snap flag, passed at Titlebar.cpp:734 from the key state read before the focus call at 715.
    Verify: ui qml test with `zoomEnabled: false`: press -> `pressScaleX` 1.1429 on the next frame, colour unchanged, no
    click; `active: false`: glyph opacity 1 on the hover frame. Headless Finder behind another window, mcap per frame.
    **Applied 2026-11-14** (a, b, c, e, f; LIGHTS-REA section 10 has the tables). Two corrections from the clips: the
    disabled zoom's release is not the tracking spring 0.1 / 1.0 (rms 0.173 of the lift): it dips 31 % under rest at
    0.18 s (rim centroid 15.41 -> 13.14 -> 13.68 at 0.30 s; the "back by 2.567 s" frame is where it passes rest), fitted
    0.335 / 0.41, ours 0.31 / 0.5 rms 0.057, so b's response / damping change was dropped and only the lift snaps. The
    QML light also snaps when the hover began on an inactive window (`_enteredInactive`), since Hyprland activates the
    Finder on the press before the light sees it. On screen (dark, scale 2): disabled zoom 13.70 -> 15.50 in one frame,
    colour constant, no glyph, no action, back with a 16 % dip; inactive Finder and plugin foot: colour and full glyphs
    on the first hovered frame, close 13.68 -> 15.20 / 13.67 -> 15.19 in one frame, lighter; the plugin no longer
    focuses a window pressed on a light (foot closed, the key window stayed active; active window unchanged during a
    hold). The plugin needs a rebuild (plugin/build was not touched).

16. **Emoji in secondary text (R6.5)**. The Finder list name "Trip 😀👍🏽🇮🇩.txt" is labelColor (ink 38 in light =
    black .85 over 255; 221 in dark = white .85 over 31), yet the emoji's inner pixels are **identical in light and dark**
    (670 px; only the antialiased edge differs). A .85 fade would move them by 0.15 x (255 - 31) = 34 levels. CoreText
    draws colour emoji at full alpha whatever the text colour's alpha; the highlighted menu row (white text) agrees
    (difference 0.0). The secondary columns hold no emoji in these shots; the same rule is inferred for them. Ours: Qt
    multiplies colour emoji by the text alpha (EMOJI-TEXT.md "Left over"): 85 % in a label, 50 % in secondary text.
    Change (not tried): a helper `ui/HyprK/emojitext.js` `opaque(s)`: null without emoji, else StyledText with the text
    HTML-escaped (& < >) and each emoji run wrapped in `<font color="#000000">...</font>` (alpha 1; colour glyphs ignore
    the RGB). Runs without `\p{}` (QV4 support not checked) and without bare BMP symbols, so a ✓ in text keeps its alpha:
    `/(?:[\uD83C-\uD83E][\uDC00-\uDFFF]|[☀-➿⬀-⯿]️)(?:[️‍⃣]|[\uD83C-\uD83E][\uDC00-\uDFFF]|[☀-➿]️?)*/g`.
    First at `finder/qml/FileList.qml:173-175` (`text`, plus `textFormat: Text.StyledText` only when it has emoji), then
    the other file-name, menu and banner Texts. Verify: ElideMiddle with StyledText (not checked; a long emoji name in
    finder/tests); headless Finder list, light and dark: the emoji's inner pixels equal in both, name ink still 38 / 221.
    **Applied 2026-11-15.** `ui/HyprK/emojitext.js` (`EmojiText` in qmldir): `has(s)`, `opaque(s, c)` (plain text ->
    StyledText with each emoji run in `<font color>` = the text colour's RGB at alpha 1), `wrap(styled, c)` (runs only,
    for markup that is already StyledText). StyledText collapses whitespace ("a  b" 38.4 -> 28.3 px at 13 px) and joins
    lines, so `opaque` writes spaces / tabs as `&#32;` / `&#9;` and newlines as `<br>`: implicit width and line count
    equal the PlainText string for 8 names (double, leading and trailing spaces, tab, newline, `<b> &`, ZWJ family,
    keycap), ElideMiddle elides to the same pixels (ui/tests/tst_emojitext.qml). Runs also start at the BMP
    Emoji_Presentation=Yes characters (✅ ⭐ ⚡ ✨ ❌ ⌚, emoji-data.txt; here only Apple Color Emoji has them) and keep tag
    characters (🏴󠁧󠁢󠁥󠁮󠁧󠁿) and ZWJ members whole; a bare ✓ / ★ and a keycap's digit stay out. Plain strings keep
    `Text.PlainText` (was the default AutoText) and the same string. Used by every translucent Text that shows a file
    name or user text: Finder list name `FileList.qml:218`, column name `ColumnView.qml:121`, icon label
    `IconView.qml:166` (tagged names through `wrap`), path bar `PathBar.qml:62`, menu items `PopupMenu.qml:158` (the
    context menu's "Compress “name”"; ours has no title path menu), gallery name `GalleryView.qml:128`, Get Info name and
    "Where:" `InfoPopover.qml:33, 45`, tag popover title `TagPopover.qml:38`, rename example `RenameSheet.qml:91`,
    Spotlight row subtitle (.42 white) `shell/modules/spotlight/ResultRow.qml:87`, notification summary and body
    `shell/components/NotifCard.qml:171, 188`. Not changed: the Date / Size / Kind columns (dates, sizes and MIME
    descriptions, no user text), the sidebar and the toolbar title (opaque colours), the drag image (the whole item is at
    .62, as the drag image is).
    On screen (headless, scale 2, ~/hyprk-emoji2 with "Trip 😀👍🏽🇮🇩.txt" and "😀👍🏽🇮🇩 test.txt", `--view list`,
    unselected rows; inner emoji pixels = ink in both shots, 2 px inside the ink):
    | inner emoji pixels, light vs dark | Mac | ours before | ours after |
    |---|---|---|---|
    | list name (label .85) | 795 px, mean 0.05, max 1 | 819 px, mean 33.7 (= 0.15 x 224) | 844 px, 0.0 |
    | menu item (label .85; Mac: the highlighted title-menu row) | 1169 px, 0.0 | 775 px, mean 29.0 | 812 px, 0.0 |
    | banner summary / body (after only) | | | 682 / 1115 px, 0.0 |
    Before / after in the same theme: the emoji were drawn at alpha 0.850 (median of (before - bg) / (after - bg), 10-90 %
    0.845-0.854, list and menu). Plain text unchanged: Notes / Budget rows, the Trip row's "Trip" and ".txt", the header
    and the Date / Size / Kind columns differ by at most 1 level, the same as two runs of one build (57 px at 1); the
    menu outside the emoji at most 2 (its glass); icon and column views differ only inside the two emoji names.
    Software scene graph (offscreen qmltestrunner) draws colour emoji at full alpha either way, so the pixels need the
    GPU session. Not measured on screen: Spotlight subtitles, the gallery / Get Info / tag / rename labels (same
    helper and binding).

## After judge #20 (22:10)

17. **Spotlight dark list, top row over white** got worse with the shared-shadow fix (SPOTLIGHT-27.2.1.md "Judge #20",
    GLASS-HIG §17): 119 -> 136 against the Mac's 95; the highlight is no longer clamped there. Gap and bottom rim now
    match (gap over white 96 -> 105 vs Mac 95 -> 104). Needs a plugin-side fix for the top row.
    **Applied 2026-11-15** (judge #21, plugin): the key (top) lobe goes on the face before the clamp and the fill, the
    fill (bottom) lobe after them. Top rows over white 136 129 -> 119 119 (Mac 100 119), over grey 89 79 -> 83 76 (Mac
    85 83), light over white 136 -> 119; bottom rim and gap unchanged (SPOTLIGHT-27.2.1.md "Judge #21"). Left: the
    Mac's first row is a dark line over white (100 centre / 88 ends), not traced. plugin/build needs a rebuild.
    **Traced in part 2026-11-15** (SPOTLIGHT-27.2.1.md "Round J21"): the Mac's first rows peak at the centre on both
    backdrops (+8 at row 1), as the bar's bottom rim does (a highlight whose normal is not the straight edge's, ours is
    flat along x); the Siri dark specular (a tone curve: white 119 -> 100 would take grey 83 -> 62, Mac 85) and the outer
    refraction as decoded (its .75 / .25 ramp is the rows' split, but its sample lands in the bar's dark top) are ruled
    out. Not changed: row 1 white 119 / Mac 100, grey 83 / 85.
    **R8.1 applied 2026-11-15, still open** (GLASS-HIG.md 20): the x shape is the key/fill highlight's ovalized normal
    (gradientOvalization 0.5 over 64 pt, MAC-ANSWERS-8.md), now in the plugin. Over grey row 1 peaks at the middle, 83 /
    78 at 200 pt out (Mac 85 / 73), row 2 76 / 73 (Mac 83 / 78); the bar's bottom rim falls 112 -> 105 (Mac 118 -> 103).
    Over white row 1 stays 119 flat (Mac 100 / 89): the key lobe goes on the face before the clamp, where white leaves it
    no room. The Mac's dark first row (a .3 x interior + 55-65 line on both backdrops) is still not traced. plugin/build
    needs a rebuild.
    **Closed 2026-11-15 (round 17, MAC-ANSWERS-17.md R17.5; GLASS-HIG.md 22, SPOTLIGHT-27.2.1.md "Round 17").** The row
    is the decoded outer refraction, whose sample sees the bar above the list (mode list, D 214: the bar's dark top;
    results, D 410: past the bar) and leaves along the ovalized normal, under a light line that lies over the veil
    (.93 x + 53 / 31 / 9). Plugin `outerSeesPrior` / `keyTop`, shell `shaders/spotrim.frag`. Mode list over white row 1
    119 / 119 -> 100 / 88 (Mac 100 / 90), results 119 -> 164 (165), grey 83 / 78 -> 84 / 71 (85 / 73); the bar's bottom
    rim 156 / 152 -> 167 / 159 (167 / 158). plugin/build needs a rebuild.

## After judge #21 (2026-11-15)

18. **Light hold shine, the darker disc**: decoded `MacButtonGlassInteractionFill.resolve` (clear / .quinary rollover /
    .quaternary pressed, INTERACTIVE-GLASS-REA.md 7); the Appearance preview's buttons take a measured light disc,
    black .097 over (hover −22 / −23 / −24, Mac −21 / −22 / −24; held 9-13 pt +18 / 13 / 3 -> −4 / −2 / 0, Mac clip
    −11..−4 / −9..0 / −7..+3). Dark unchanged.
    R8 (2026-11-15): not touched; the shine is QML (LensGlass), status as above.
19. **Control Center dark lens fill** (judge #21: 219.4 against 224.0): not changed this round. Read on the judge's crop
    (`judge-95-21/10-*`, my box method: Mac 222.9, ours 218.6): the gap is in the fill's top two rows (Mac 194 247,
    ours 175 209: the Mac's fill edge sits higher or sharper inside the lens) and 3-5 levels on the rows under them;
    the fill rows are the same (12-23 of the 40 px box). The CC knob's filter is not dumped; no decoded term moves
    those rows alone (lensDy already fits the fill's place).
    **Decoded 2026-11-15** (GLASS-HIG.md section 19): the lens is ControlSliderRecipe; its ring blur 3 / stroke 4 /
    offset 8 are constants in ControlClearSpec and its opacity is `colorScheme == .dark ? 0.4 : 0.15`
    (SliderSpecModifier), so the CC knob takes the Settings slider's band. Re-measured: fill mean 216.9 (Mac 224.0); both
    follow the decoded band's slope, and over it the Mac's fill inside the lens is 4-14 levels lighter, most at the top
    (white about 1.08 before the ring, ours 1.04), which no decoded term gives. Not changed. Applied from the same decode: the
    Settings slider's light ring 0.14 (fit) -> 0.15 (`Tokens.control.sliderLensRingOpacity`, not re-shot).
    **R8.2 checked 2026-11-15, still open** (GLASS-HIG.md 20): the stock SwiftUI slider knob held over white
    (MAC-ANSWERS-8.md: face 0.1 + 0.9 c, ring 0.4 dark / 0.15 light, 8 down, stroke 4, blur 3) is our stack as it is: centre
    column rms 0.93 dark (205 at the middle, Mac 205), 1.0 light. So nothing to change in Knob / LensGlass, and the CC
    lens's lighter fill is a Control Center term: re-measured (my box) Mac 222.9, ours 217.1 before, 217.8-218.6 after
    (four holds; the plugin change does not reach the QML lens). Needs the real Control Center slider's knob dump.
    **Closed for the static hold, 2026-11-15 (after judge #24)**: R9.6's screenshot of the real Control Center Sound
    knob, pressed and not moved (`live/glass-r9/cc-sound-held-dark.png`), was never compared. Per column of the fill's
    rows inside the lens: Mac 238 236 233 230 228 225 222 221 219 217 216 215 214 214 213 213 212 212, ours 239 236
    233 230 228 225 222 220 218 217 216 214 214 213 212 212 212 211: mean 220.0-220.6 against 221.0, rms 0.6-1.1,
    three holds (`scripts/motion-capture/cc-lens-fill.py`). The judges' 223-224 is frame 3 of `panels/cc-sound-slider-
    rest-hover-drag-overdrag-dark-grey127.png`, a 60 fps **video** frame of the knob being **dragged**: 247 245 242 239
    ... 216, 5.9 levels over the Mac's own static hold. On `controls/slider-fast-drag-cc-dark.mov` the same reading
    (inner rows, first six columns / all) is 245 / 231 while first held, 240-244 / 227-230 in the swings and 236 / 224
    once at rest again: the Mac's level moves with the state by as much as the gap. Nothing changed in LensGlass /
    Knob / the shaders. **Capture that decides the drag** (G1 below).
    **Closed, 2026-11-15 (Mac round 18, R18.3)**: lossless stills of the knob held and during a 15 pt/s drag, four
    backdrops. The Mac's fill is the same held and dragged: dark 221.0 held, 220.5 / 220.7 / 220.2 dragged; over blue
    220.5, 220.8 / 220.4 / 220.1; light over white 220.5, 220.3 / 220.5 / 220.2. The 223-224 was the video frame. Ours
    218.0-221.0 by the part of a pixel the lens falls on (the Mac's own 220.1-221.4), within 1.5 at the best shift
    within a pixel (`cc-lens-fill.py`, round 18 cases). Nothing changed in LensGlass / the shaders; what the same
    stills did change is under "Mac round 18" below.
20. **HUD first frame** (judge #21 item 2): **traced 2026-11-15, nothing to change** (MOTION-AUDIT.md "Round J21"). The
    decoded appear stores only scale 0.9, opacity 0, top margin 10 (no blur); content = o, glass ~ o^2. With t0 fitted per
    clip, the Mac's first frame is at 14.7 ms (grey dark, glyph / bar .029 / .036), 20.2 (blue dark, .020 / .021) and
    31.8 (grey light: no earlier frame recorded); ours 16.6-17.9 ms, .023 / .028 (3 runs). The judge's .031 is the grey
    clip's phase plus codec noise (half its first-frame L1 is under 2 levels).
    R8 (2026-11-15): not touched (the HUD is the controlcenter recipe, which keeps the plain rim normal); status as above.

## After judge #22 (2026-11-15)

21. **HUD at full and at zero volume** (sound / behaviour; SOUND-REA section 2 decode, section 7): **fixed**. A volume key
    step that leaves the level as it was now shows the HUD (`volume-key.sh` `hud-step` -> `services/Hud.qml`). Up at
    full: HUD first frame 99-116 ms after the key (before: none); mid-level steps unchanged (97-116).
22. **Mission Control menu bar on exit** (animation): re-measured (MOTION-REA "Round J22"): the Mac's titles fade in on a
    0.27 critical spring and show through the Spaces bar; ours stay hidden under the opaque bar, then show at .34-.79 as
    it slides off. Not changed: the layer order while the bar leaves needs the Mac.
    **Fixed 2026-11-15 after R10.1** (MOTION-REA "Round K1"): the menu bar sits above Mission Control's window while it
    leaves and plays the Mac's title alpha track (rms .010, 3 runs); the Spaces bar plays the Mac's edge track
    (.77 .61 .47 .34 .23 .16 .10 .06 .03 0 against .77 .61 .46 .35 .23 .16 .10 .06 .03 0).
23. **DockStack scroll lines at a fractional scale** (scaling, SCALING-AUDIT R3.3 left 2): `Pixel.stroke` + `soft`, as
    the other 1 pt lines. Not shot at 1.5.


## User report 2026-11-15 (nested preview)

24. **HUD glyph bounce at the ends** (animation): **fixed**, decoded (MOTION-REA "Round K1": SystemBannerUI
    `SymbolEffectState`, `.symbolEffect(.bounce, value: seed)`): the glyph bounces when a step brings the level onto 0
    or 1; the bar already moved per step on the Mac's 0.2 / 0.85 spring. Open: no Mac clip of a step onto an end.
    **R11.4 measured 2026-11-15** (MOTION-REA "Round R11.4-R11.7"): the fill matches (Mac rms .014 against the spring,
    ours .009); the bounce now plays by layer (0.05 s apart, 1.25 / 0.90: rms .013-.016, before .044-.063) and the wave
    count changes in one frame. Open: the swap leads the fill by 1-2 frames on the Mac, 0 here; the Control Center
    sliders' end glyphs still bounce as one piece; the real key path (PipeWire) was not run, only the stub and IPC.
25. **Liquid Glass preview, Search capsule press light** (glass): **fixed** (INTERACTIVE-GLASS-REA.md 8): held - rest
    dark +35 / +40 / +43 (Mac +35 / +40 / +43), light +14 / +16 / +9 (Mac +17 / +19 / +14); before 0. Open: the far end
    falls off less than the Mac's; the Finder toolbar's Search button has no Mac press clip.
    **R11.5 applied**: held Search disc 37 -> 40 pt in the press frame, light 255 / dark 58, release 150 ms. Open: the
    bright disc while the held pointer is dragged off, the 1-2 px follow, the release's end (not recorded); ours was
    captured in light only.
26. **Icon & widget style tiles** (assets): **fixed** (SETTINGS-UI-AUDIT.md "Icon & widget style tiles"): the Weather
    icon in each style, as the Mac draws them, following the radios and the chosen colour. Open: Default selected in
    dark mode (which Clear / Tinted the Mac shows).
    **R11.6 applied**: Default selected shows the light Clear and Tinted; tinted blue light 17.4 -> 12.1 (sRGB). Open:
    the other accents' light tiles (not captured; the same wide-gamut plate is likely); 11.7 is Apple's own bitmap
    against the still, so about the floor.
27. **Dock menu removal sound** (sound, R10.2 c): **fixed**, the poof plays with Options > Remove from Dock.
28. **Screenshot sound 222-247 ms after the key** (sound, R10.2 a): not changed (SOUND-REA section 8): the Mac's time is
    process launch, ours plays at the bind; ours not measured.
29. **Mission Control expanded Spaces bar** (layout, R11.7): the Mac's is inset + 132 (166 pt at the default mode) with
    the Space's frame from inset + 10; ours about 142 from y 16. Not changed: our windows do not make room for it, and
    the Mac's window motion on expand is not captured. The collapsed bar (74) matches; the exit track is now a share
    of 68 (the clip's mode).
    Still not changed after judge #24: capture M1 below decides it.
    **Fixed, 2026-11-15 (Mac round 18, R18.1)**: see "Mac round 18" below.
30. **Slider end glyphs "do not animate"** (animation; the six of Settings > Appearance's Liquid Glass slider and
    Control Center Display / Sound): **fixed** (INTERACTIVE-GLASS-REA.md 8, MOTION-REA "Round K2"). Appearance had no
    bounce (the 23.09.23 recording shows one at each end); Control Center bounced as one piece where the Mac bounces by
    layer (disc then rays, speaker then waves, capsule then rectangle; 1.25 / 0.90, 0.05 s per layer). Now by layer on
    all six, slow drag and slam alike (`scripts/motion-capture/slider-glyphs.py`). **Still open**: on a machine without
    a backlight device the Display slider is disabled, so its suns cannot bounce there (what the Mac's Display module
    does on a display without brightness control is not captured); the HUD's sun bounces as one piece (no clip); the
    real PipeWire path was not driven (stub only, to leave the volume alone); Reduce Motion not recorded.

## After judge #23 (2026-11-15): sound, scaling, depth re-measured

Live checks added (headless session, see `scripts/motion-capture/livecheck.py`): `sound-timing.py`,
`player-latency.py`, `scale-lines.py`, `sheet-depth.py`, `dock-plate-sync.py`.

31. **Output latency** (sound): **measured**, SOUND-REA section 10. `pw-play` exec to the sink's input: median 12 ms on a
    private PipeWire. Pill -> pop out 51 (Mac 48.7), pop out -> HUD 26-29 (Mac 18), key -> HUD first frame 103-107 (Mac
    about 90-105), 50 % at 269-274 and 90 % at 419-424 (Mac 277-293 / 440-445 filmed). Nothing changed.
32. **Poof on Remove from Dock** (sound): **measured**: the sound is out 4-6 ms after the removal's first frame (Mac
    +15, the same frame), no cloud. **Fixed with it**: the Dock closed the gap in 150 ms, the Mac's clip shows 250 ms on
    the cosine ease in-out; now 233 ms to the last moving frame (`lib/dock.js slotDuration`, `Apps.menuRemoved`).
    Open: the menu's fade-out 250 ms against about 183 in the clip; our blink before the removal (the clip is an AX
    press).
33. **Screenshot sound** (sound, item 28): **fixed**: 38 ms -> 232-240 ms after the key (Mac 222 / 247),
    `hyprland.lua shutterDelay`.
34. **Scaling at 1.5 and 1.25** (scaling, item 23): **measured**, SCALING-AUDIT "After judge #23". Dock separator, menu
    separators, Finder header line: the Mac's resample patterns at both scales. **Fixed**: Settings (and Finder at 1.25)
    sat on a half device pixel and were resampled as a whole (card separators [.92, .67] / [.08, 1, .42] -> [1, .46] /
    [.46, 1]); they now take the nearest whole-pixel size. Open: other windows at odd sizes, a compositor-side snap.
35. **Settings sheet shadow, light** (depth; judge #23 Settings defect 1): **already fixed, now measured**
    (`sheet-depth.py` against `settings-r13/dest-controlCenter--clock-options-{light,dark}.png`): right of the sheet
    179 183 186 190 192 195 197 198 (Mac 178 182 185 189 192 194 196 198; judge #23: 126 136 147 ...), under it
    161 ... 188 (Mac 161 ... 190; was 100), above 198-204 (Mac 196-203; was 145). Dark within 0-3.
36. **Window lights under a sheet** (depth; defect 2): **already fixed, now measured**: close (226,227,229) light /
    (75,76,82) dark (Mac (229,230,234) / (72,74,86)), minimise and zoom in colour (judge #23: all three grey). Open, not
    the sheet's: in this still the dark minimise and zoom read (243,193,31) (92,188,30), ours (245,186,8) (31,184,12);
    the still equals the Mac's own no-sheet still, so it is the dark lights' fit (LIGHTS-REA, fitted to
    `windows/lights-*.png`) against a second capture.
37. **Dock plate off its icons while the separator is dragged** (depth / rendering; judge #23 claim 2, one frame about
    94 pt apart): **measured** per frame over a 26 pt drag (`dock-plate-sync.py`, 125-134 frames, 5 runs): the plate's
    top stays 6-14 pt above the icons' (10 at rest), worst 3-4 pt off. The 94 pt frame does not occur. **Open**: the
    plate (compositor) trails the icons (shell) by 1-2 frames during the drag; needs the resize to reach both in one
    frame.
    **Closed 2026-11-15 (after judge #24): the trail was the check's.** It read the plate's top 6 pt from its left end,
    inside the corner, whose radius grows with the tile; and its 680 pt region lost the Dock above tile 82. Read clear
    of the corners against lib/dock.js (icons' top = plate's top + 10 + T x 100 / 1024): 16.2..18.8 pt wanted, 17..19
    read, never more than 1.0 pt off (the frames' 1 pt grid) in 130 frames, 6 runs; the plugin's trace has the plate's
    box 1 pt per frame with the pointer, as the Mac's hand drag (MAC-ANSWERS-16.md: whole-point steps, no easing or
    lag). Changed: the exclusive zone keeps the saved size during the drag (Dock.qml `zoneM`).

## After judge #24 (2026-11-15): Mission Control pick, Notification Center side line, Control Center lens fill

Live checks added: `mc-pick.py`, `nc-side-line.py`, `cc-lens-fill.py`.

33. **Mission Control: the picked Finder window's key look 4 frames late** (animation): **fixed** (MOTION-REA "Round
    J24"). Re-measured 4-5 frames when the click fell early in a refresh and 1-2 when late (Settings 1-3). Cause: not a
    lost capture. Finder commits the look 5-11 ms after `hyprk-pick`, the capture is copied at the compositor's next
    frame and drawn by the layer one frame after that, so the look cannot be on screen 2 frames after the click. Now
    the look is asked for while the pointer rests on the thumbnail (a still of it 100 ms later), shown when the flight
    is past its first step, and the flight starts one frame after the click as the Mac's (ring gone at 2.983 s, .07 at
    3.000, lights at 3.017). 20 of 20 clicks: +2 frames (Mac +2), both directions; the old key window greys at +1 or
    +2 (Mac +2). **Left**: a click sooner than 100 ms after the pointer reaches the thumbnail falls back to the live
    capture (4-5 frames, not measured again); the still is as old as the hover.
34. **Notification Center card and banner: dark side line** (refraction): **fixed in the plugin, `plugin/build` needs a
    rebuild** (GLASS-HIG.md 21). The "63 against 54" of round 11 was read on a two-line card, which has no straight
    side (the line splits over two pixels); on a three-line card ours was 40 left / 36 right against the Mac's 44.5 /
    44.5 over grey 127, and **126 / 111 against 70.4 over white**. Two causes: the decoded per-channel tone does not
    describe the Mac's line (new measured luma tone for the two notification recipes, dark only), and the column's
    dim ran 50 pt past the screen edge (the pixels right of a card 6 darker than left). Now card 46 / 45 over grey,
    70 / 69 over white, 0 over black, banner 49 (Mac 50) and 72 (71.5); outside 102 / 102 (Mac 99.5 / 99.5).
    **Left**: over blue (69,83,206) the line is (24,31,93), the Mac's (20,24,86) (before (16,21,88): the luma tone
    takes the greys and gives up 4-7 levels there); the alert and the menus keep the decoded tone, their Mac line is
    known over grey 127 only (capture N1).
    **Refitted, 2026-11-15 (Mac round 18, R18.2)**: see "Mac round 18" below (the blue line is now (20,25,95); the 95
    is the pixel outside it, 166 against the Mac's 156).
35. **Control Center dark lens fill** (item 19): **closed for the static hold, nothing changed**; see item 19.

Capture requests for the Mac (all on the flat grey 127 PNG, dark, 1440 x 932 unless said):
- **G1 Control Center Sound knob, drag against hold, as stills** (**answered**: MAC-ANSWERS-18.md R18.3, on flat dark,
  blue and white instead of grey 127): over the flat grey 127 PNG, dark, Sound at 38 %,
  `screencapture -R` PNGs (not a screen recording) of the Sound module (the R9.6 rect): (a) 0.1 s after the press, (b)
  1 s into a hold without moving, (c) while the knob is dragged at a steady 100 pt/s (three stills), (d) 0.5 s after it
  stops, still held. Wanted: the white fill inside the lens per column in each (does it lighten in a drag, and by how
  much against the hold in the same session).
- **N1 dark alert and menu over white and blue** (**answered in part**: MAC-ANSWERS-18.md R18.2 holds the banner and
  the Notification Center card, dark and light, over white and pure blue; the alert and the menu were not taken, they
  keep the fitted -0.278): the R5.2 alert (`alert-shown-grey-dark.png`) and the Apple menu
  (`menu-probe-popup-over-grey-dark.png`) again over the flat white and the flat sRGB (69,83,206) backdrops, dark.
  Wanted: the side line's pixel against the pixel outside it on straight rows (the banner over white reads 233.5 ->
  71.5; the decoded tone the alert still uses would draw about 158).
- **M1 Mission Control, the Spaces bar expanding** (**answered**: MAC-ANSWERS-18.md R18.1, at 1440 x 932 with three
  windows): 60 fps clip at the default mode (1710 x 1107), 4 windows with the
  top row's tops within 120 pt of the menu bar, the pointer moved to the top edge and held 1 s, then away. Wanted: the
  bar's height per frame, and each window thumbnail's frame before / after (do the thumbnails move down or shrink to
  make room for the 166 pt bar).
- **M2 Mission Control pick with a held button**: the R4.2 set-up, the button held 0.3 s on the thumbnail before the
  release. Wanted: does the hover ring go at the press or at the release, and which frame after the release moves
  first (R4.2's synthetic click has both in one frame).
- **S1 Empty Trash with sound**: Trash holding one dummy file only (move the user's items out by exact path first, put
  them back after), Finder > Empty Trash confirmed, `screc` full display with audio, the click's time on the clip's clock
  (pointer marker). Wanted: sound start against the confirm click and against the Dock's Trash icon changing.
- **S2 Remove from Dock by a real click** (**answered, round 16: applied, SOUND-REA section 11**): the R10.2 c set-up, but the menu item clicked with a HID-level CGEvent mouse
  down / up (pointer visible), 60 fps, audio. Wanted: the row's blink frames, click -> first fading frame, the fade's
  length, the sound.
- **S3 a hardware volume key** (one press of F12 by hand) on the recording clock with feedback on: key -> pill -> pop ->
  HUD in one clip (an LED or the on-screen keyboard viewer as the key's marker).
- **S4 drag-off poof with a real pointer** (**answered, round 16: ours already matches, SOUND-REA section 11**) (trackpad by hand): a dummy tile dragged 255 pt up, held 1.2 s, released;
  audio on. Wanted: the cloud (if any), the sound start against the release.
- **C1 the panel's own pixels in More Space** (**answered, round 16: SCALING-AUDIT "Round 16"; the scaler is softer
  than the box, ink kept; Larger Text gives no second ratio**): a photograph is not needed; `screencapture` returns the backing. Wanted
  instead: the same four stills as R3.3 (Dock, File menu, Settings Appearance, Finder list view) taken with
  `CGDisplayStream` / ScreenCaptureKit at the **display's native 2880 x 1864 output size** (`SCStreamConfiguration`
  width / height = the panel's pixels, `scalesToFit` off), if that returns the scaled frame; and say which API returned
  what size. Also the same four at **"Larger Text" (1280 x 832 looks-like, if offered)** for a second ratio.
- **C2 System Settings window frame in More Space** (**answered, round 16: the size stays in points; ours 626 -> 625**): AX frame of the window (position, size in points) and of two card
  separators, to see whether AppKit keeps 625 pt there.
- **D1 dark lights, one more still** (**answered, round 16: LIGHTS-REA section 12; active colours unchanged, the
  dark inactive disc is now a white veil, alpha .17**): a dark Finder and a dark System Settings window side by side, active, pointer
  away, PNG with the display profile embedded and the same shot converted to sRGB (`sips -m`), to settle minimise /
  zoom (243,193,31) (92,188,30) against the earlier crops.
- **D2 Dock resize in motion**: 60 fps clip of the separator dragged 26 pt up and back over 1 s (by hand), to see whether
  the Mac's plate and icons move in the same frame and the tile size per frame.

## Mac round 17 (2026-11-15): Spotlight and Apps (SPOTLIGHT-27.2.1.md "Round 17")

39. **Spotlight list top edge** (glass): **fixed**, item 17 above.
40. **Spotlight stills** (layout): **fixed**: mic, mode list shortcut and glyph sizes, text and icon positions, the top
    hit's inline completion ("ulator — Open"). **Open**: "Search <App>" + `tab` hint (no such function here), the results
    scroll bar, the caret's halo, Actions / Clipboard glyphs (item 7), **Files as the Mac's 844 x 520 grid with filter
    chips** (ours is a 520 x 490 list).
41. **Apps** (layout / animation): the grid was already the Mac's to the point (re-measured on `apps-rest-*`). **Fixed**:
    Cmd-1 from the bar grows the panel (level .40 .51 .70 .76 .81 .89 .96 .98 per frame, Mac .28 .47 .62 .75 .84 .89 .92 .98), Escape collapses it (100 ms, Mac
    six frames), " — Open" in the field while typing. **Open, not in the Mac's captures**: hover and press
    (`apps-hover-press-*.mov` hold no panel), scroll (`apps-scroll-*.mov` show a filtered grid that does not scroll),
    opening from a Dock tile, the grow's start scale and per-frame width (the grid area is blurred in the clips).
    Capture requests: A1 the hover / press clip again with the panel in the region; A2 a scroll clip of the unfiltered
    grid (wheel and trackpad); A3 open / close unblurred on a test account (Apple apps only), 60 fps, light and dark.

## Mac round 17 (2026-11-15): Cmd-Tab and window chrome (R17.2, R17.4)

42. **Cmd-Tab** (animation / layout): **fixed**: the panel is on screen 180-195 ms after the key (Mac 180; was 245),
    Escape removes it in one frame (was the release's 0.25 s fade), the name is SF 13 semibold 2.5 pt higher (ink rows
    310..328, Mac 309..328; was bold, 5 px low) and white .95 in dark (247, Mac 246; was 233). Already the Mac's, measured
    again: panel size, corner, plate, plate fill, step, quick tap, the release fade (ease-in-out 0.246 s; the section's
    "200 ms ease-in" is the same curve). Check: `scripts/motion-capture/cmd-tab.py` (12 lines, light and dark).
    The dark name's stems were 4.1 px against 3.7: the dark text grade (GRAD 581 at 13 pt, fitted to the text sample)
    where the Mac's name has the same stems in both modes; the name now takes the light grade, 3.6 (light 3.6).
43. **Window under a sheet** (dim): **fixed**: HyprK `Sheet` veils its window as the Mac does (out = 0.396 in + 103 /
    0.39 in + 12.3; was 20 % black: black text read 0-30, the Mac's 102-138), with the round 13 shadow and the lights left
    out of the veil; no blur anywhere on a sheet. GLASS-HIG section 23. Timings unchanged (0.27 / 0.25 s linear; Mac 0.26
    / 0.26). **Closed after it** (LIGHTS-REA section 14, GLASS-HIG section 23): the disabled close is a layer over the
    bar as it was (light 230 / Mac 229, dark (72,74,86) / Mac (72,74,86); was 241 and (75,75,75)); the window under a
    sheet is drawn not key instead of without saturation (Settings' sidebar, Finder's sidebar icons 153 / Mac 151.5);
    the dark toolbar strip of a window that is not key is 8 levels lighter (`sheet-depth.py` dark "shadow above" 26-27
    / Mac 27-29; was 23). **Left**: the dark veil's blue; the app-modal AlertPanel's Cancel blur stays (R3.1, not a
    sheet).
44. **Inactive title, light, compositor bars**: **fixed in the plugin, `plugin/build` needs a rebuild**: 191 -> 183 (Mac
    183). Dark title and both inactive discs were the Mac's. Conflict left open: light active title 88 (R17.4) against 76
    (Q-windows-11). LIGHTS-REA section 13.
45. **Qt windows activated by a light press** (judge #24's list): not reproduced, the fix of LIGHTS-REA section 11 works
    with the current plugin build.
46. **`SettingsRound15::test_about_buttons`**: the test was wrong, not About: it clicked Storage Settings… before the
    Displays rows it had just set were laid out (the button moved from y 662 to 761, out of the 625 pt window). A 60 ms
    wait as in `test_about_layout`; 12 of 12 pass.

## Mac round 18 (2026-11-15): Spaces bar, notification side line, Control Center Sound slider (MAC-ANSWERS-18.md)

Requests M1, N1 and G1 above. Measured from the clip and the stills; MOTION-REA-27.2.1.md "Round R18.1", GLASS-HIG.md
section 24. Live checks: `scripts/motion-capture/mc-bar.py` (new), `nc-side-line.py` and `cc-lens-fill.py` (round 18
cases added).

40. **Mission Control: the Spaces bar expands** (item 29): **fixed.** Mac 68 -> 160 pt on the decoded critically
    damped (1.0, 0.38) spring (rms 0.22 pt against the window track; the bar's own edge is a frame ahead in two
    frames), from 71 ms after the pointer enters, and stays expanded; the windows are laid out again under the taller
    bar (top row +92 pt at its size, 39.5 pt under the edge in every frame). Ours before: the band stayed 74 pt and
    the windows did not move. After: 74 -> 166, rms 0.31 pt against the Mac's frames, first moved frame 81-82 ms
    after the pointer, top row +92.0 and 39.5 pt under the edge in every frame, still expanded 1.5 s after the
    pointer left (3 runs). The Space is the screen at 92 pt in a 3 pt accent ring with the Desktop's windows in it.
    **Left**: more than one Desktop, light mode and a full-screen Space were not captured (the 18 pt between Spaces
    is the old guess); the Space's windows are our thumbnails, not a second capture; the 1.03 hover scale of a Space
    was removed (not on the Mac's frames).
41. **Notification banner and card: the dark side line** (item 34): **refitted in the plugin, `plugin/build` needs a
    rebuild.** The stills show the decoded tone with the dump's -0.25 in light, in dark over blue and over grey; only a
    light backdrop is darker in dark. The luma curve of item 34 is replaced by that tone and a limiter of its luma
    (0.278, knee 4). Middle row of the Mac's two-line card, Mac / before / after: banner over white 79 / 83 / 81, over
    blue 159 / 143 / 158; card 78 / 81 / 78 and 126 / 121 / 130; light unchanged and right (176 / 177, 166 / 166, 142
    / 143, 134 / 135). Straight sides as before: 44 / 70 (Mac 44.5 / 70.4), banner 50 / 70 (50 / 71.5).
    **Left**: the blue straight case's blue channel (95 against 86) is the pixel outside the line (166 against 156,
    the panel's dim over that backdrop). The Mac's top line is about 1.4 x ours on these stills (dark over white 161
    143 against 149 136) with a soft band under it: seen, not changed. Alert and menu over white / blue: not captured.
42. **Control Center Sound slider: hover and hold** (items 19, 35): the fill under the lens is settled (item 19).
    **Fixed**: the module is 7 levels lighter while hovered and about 3.5 % more while held (Mac 50 -> 57 -> 59, track
    70 -> 77 -> 78; ours was 50 / 70 in all three states, now 57 / 77 and 59 / 79; over blue 31 / 51 and 32 / 52 as
    the Mac; light over white 193 / 213 and 200 / 220, Mac 193 / 213 and 200 / 216); the hover knob's shadow x 0.75
    (under the knob Mac -15 -12 -10 -9, ours -20 -17 -13 -11, now -15 -12 -9 -9); the lens 22.5 x 17.5 pt (rim 48 px
    wide, rows 62 .. 99 as the Mac's; was 47, rows to 100); the lens's module level follows the wallpaper (over white
    the rim line 111 -> 142, Mac 146).
    **Left**: the held light is flat, the Mac's is round the pointer (over white up to +10, the lens's inside 3-11
    under the Mac's there); over a saturated wallpaper the lens's rim line is too dark (blue 52 against 77).

## After judge #25 (2026-11-15): Spotlight and Apps (SPOTLIGHT-27.2.1.md "Judge #25")

47. **Spotlight Files mode** (layout): **fixed**: the 844 x 520 grid with five equal chips, 7 columns, rows at 100 / 270 /
    395, "Recents" header, grey scroll knob (`spotlight-modes.py`, 5 cases). **Needs a Mac (not available)**: which
    chips the Mac picks (it mixes apps and kinds, ours are the kinds of the recent files); which files the first row
    holds (ours: the seven newest); the selection in the grid and how a long name is cut (tiles are blurred: ours
    reuses the Apps plate / ring and two lines cut at the end); the panel's motion on Cmd-2 and with a query (no clip:
    one frame here); the "..." menu (View as Grid / List).
48. **Spotlight typed row, glyphs, caret** (layout / icon): **fixed**: "Search <App>" + `tab` cap, results scroll knob,
    Actions = `app.2.stack.3d`, Clipboard = `document.on.document` (decoded, no Mac dump), caret halo. **Needs a Mac
    (not available)**: what Tab does on the top hit (search inside the app: only the hint is drawn, Tab still moves the
    selection); when the scroll knobs hide (they are in the typed and Files stills and not in `apps-rest-*`: ours
    stay in results and Files, none in Apps); whether the halo follows the caret's blink; the top hit's icon is
    lighter than the Mac's only because that Mac ran the Dark icon style.
49. **Apps grow / collapse** (animation): **fixed**, fitted to the clip with one measure for both sides; `apps-view.py`
    retakes a capture with a dropped frame and judges by time. **Needs a Mac (not available)**: the 133 ms the empty
    panel stays after Escape (5.083 .. 5.217 s: load or design?), hover, press, scroll and the Dock open (A1-A3 of item
    41), recents count. Seen while measuring, not fixed (shared `HyprK/FrameClock`, outside this round): about one
    capture in three skips one spring state without a late frame (level .40 .65 .80 instead of .40 .65 .73 .80).

## After judge #25 (2026-11-15): from the repo data only, the Mac is not available

Live checks: `scripts/motion-capture/sound-timing.py` (poof window changed, own empty desktop), `dock-drag-off.py`
(new), `sheet-depth.py` (veil colour case, own wallpaper), `finder-live.py` (new), `cc-lens-fill.py` (own stub volume,
wallpaper and mode). `livecheck.py run <program>` starts an app with the session shell's environment (fonts, emoji).

47. **Remove from Dock, the poof's start** (judge defect 3): **fixed.** `poof item off dock.aif` cross-correlated with
    `dock-remove-menu-real-click.mov` (r .999) starts at 4.920 s, **20 ms after** the Dock's first moving frame (4.900;
    over 1 % of its peak from 4.926, the "4.929" of MAC-ANSWERS-16). The earlier "first sample 4.895-4.91" was the
    AAC's pre-echo. Ours -10..-13 ms, now **+19..+29** (7 runs; `Apps.qml poofAfterMove`, 30 ms after the removal),
    click -> sound 389-422 ms (Mac 440 after the logged up, its 22 ms capture path included).
48. **Drag off the Dock** (judge: no live check): **fixed, it was broken.** The icon and "Remove" vanished in the
    drop's frame: the removal destroyed the tile's cell, which the dragged icon read. Now they fade in place, gone
    250 ms after the first fading frame (Mac 250; rms .030 against its 16 frames, 260 ms line), poof +28..+31 ms
    after that frame (Mac +28 by the same cross-correlation, 6.128 against 6.100 s). **Open**: the "Remove" bubble's
    glass keeps its blur of a window behind it until the fade ends (a step over text; the Mac's clip has the
    wallpaper there): needs a Mac (not available).
49. **Dark close under a sheet, (78,78,78) against (72,74,86)** (judge defect 5): **not a defect of the lights.**
    The judge's session had a flat grey 127 wallpaper: the window takes its tint from the wallpaper, so the bar
    under the disc is neutral there and (78,78,78) is right for it. Over the Mac's wallpaper ours reads (72,74,86)
    in Settings and (74,76,90) in Finder (Mac (72,74,86) / (74,75,88)). `sheet-depth.py` now sets the session's
    wallpaper.json aside for its run. Compositor-drawn bars have no HyprK sheet.
50. **The dark veil's blue** (item 43's "left"): **fixed.** Two causes. (a) Settings drew the pane under the veil with
    saturation -1, which also took the window's wallpaper tint: now `ui/HyprK/shaders/sheetbehind.frag` (chroma
    under 14 levels stays, over 40 goes). (b) the veil is not neutral: offsets 12.3 / 13.4 / 15.0 on Settings and on
    TextEdit's sheet (R17.4), a veil of (20,22,24.5) at .61 (`Tokens.panel.sheetDim`). Mac / before / after:
    Settings toolbar (27,27,32) / (27,27,27) / (27,28,32), pane (24,26,29) / (24,24,24) / (24,25,29), card
    (33,34,38) / (33,33,33) / (33,34,38). Finder (`sheet-dark.png`): content (25,26,29) / (24,25,29), sidebar
    (26,27,35) / (26,28,36), strip (27,28,32) / (24,25,29) before / (27,28,32) now (the strip of a window under a
    sheet takes the hover wash, `finder/qml/Toolbar.qml`). Light was neutral and right.
51. **"finder/build/hyprk-finder is older than four QML files"** (judge): **no defect, no build needed.** The binary
    holds no QML; it loads `$HYPRK_ROOT/finder/qml/Main.qml` (or the checkout's, `FINDER_QML_DIR`) from disk at start.
    `finder-live.py disk` shows it: a changed copy of Main.qml given as HYPRK_ROOT changes the same binary's window.
    Checked in the running binary: Gallery view (preview box, plate and 8 thumbnails within 0.5 pt of
    `gallery-1000x700-first-jpg-dark.png`), `--wheel-test` exit 0, Search disc 36 -> 39 pt, Group menu four clicks,
    the sheet (item 50). **The light inspector "+6" of judges #23-#25 is closed**: (237,237,238) against the Mac's
    (236,237,238), dark (36,37,53) / (35,37,52).
52. **`cc-lens-fill.py` first-run failures** (judge): **fixed in the check.** It now writes the stub sink's level
    (0.5) itself and puts the old one back; the static hold case sets dark over grey 127 itself and reads the fill
    at the best shift within a pixel, as the round 18 cases do (one lens read 218.3 or 221.0 by where the knob had
    stood); a combination whose shot shows no lens is taken once more.
53. **`sound-timing.py` "needs an empty desktop"**: it moves the open windows to workspace 9 for the run and puts
    them back (`livecheck.Desk`).

Measured from the repo data, **not built** (the round was stopped):

- **Control Center, the held light round the pointer**: `live/r18/cc-sound-light-white-{hover,held}.png`, every plain
  module pixel by its distance r from the pointer: +4.28 % at 25 pt, 3.88, 3.35, 2.72, 2.11, 1.62, 1.25, .93, .66 at
  105 pt: gain 4.8 % x exp(-(r / 74.5 pt)^2) of the module's level (dark agrees: 3.9 % at the pointer, 2.8 % at
  50 pt, 1.05 % at 90 pt). Ours is flat 3.5 % (`ControlCenter.qml`, `Theme.cc.sliderHeldGain`). This also gives the
  light held track 216 where ours has 220.
- **Notification card, the top line "1.4 x"**: the Mac has the mask's diffuse lobe on. Top edge inward per px
  (`live/r18`): banner dark over white 161 143 128 126 125 124 123 122 121 120 .. 118 (body), over blue 71 51 33 31
  29 28 27 .. 24, light over blue 165 150 136 134 133 132 130 .. 127: about +10 levels falling to 0 over 8 pt under
  the 1 pt line. Ours 149 136 121 122 121 (`Material.cpp NOTIFICATIONCENTER diffuseAmount 0`, from round 11's three
  pixels over black). The amount was not fitted: a try with Regular's 0.075 was built into a scratch dir, never
  loaded, and taken out again. `plugin/build` needs no rebuild for this round.
- **Dock gap "233 against 250 ms"**: both Mac clips show the removal's first changed frame and then 15 moving
  frames (last 250 ms after the first); ours has 15 changed frames in all (233). Starting the slot's animation a
  frame later only delayed everything by a frame, so the Mac's first frame is something ours does not draw (the
  tile going before the Dock moves?). Not decided from the clips at hand.

Needs a Mac (not available): the light active title 88 against 76; the lens's rim line over a saturated wallpaper
(52 against 77) and the NC card's blue straight side (95 against 86: the panel's dim over that backdrop), which the
r18 stills show but do not explain; the HUD's key -> first frame (ours 85-97 ms, the hand take 84 with a key log good
to +-20 ms, the filmed take 90-105) and its 90 % level (431 against 418 / 418-423); the inactive veil's bottom .141
against .150; Mission Control with two Desktops, light, a full-screen Space; alert and menu rims over white and blue;
the Finder header line on the panel at 1.5 and Settings' origin at 337.5 device px at 1.25; Cmd-Tab badges; lock
screen and Stage Manager.

Check notes for the next judge: `sound-timing.py key` ("HUD hold") and `menu-blink.py` ("desktop: the fade") pass
over a flat grey 127 wallpaper (hold 961-987, mean 978; 11 of 11) and fail over the default picture (hold mean 961,
fade rms .046-.053): their thresholds read a backdrop, not the shell. They were not changed this round.
