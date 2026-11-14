# hyprk independent judge #16, HEAD 7c25576 + working tree (2026-11-14, 13:04-13:16 WITA, measured live)

Delta judgement against judge #15 (`JUDGE-95-15.md`, 92.17). Method and weights from `JUDGE-95-7.md`: 12 dimensions,
13 surfaces + lock screen 5, Stage Manager as an extra surface at weight 2. Row tags: **[16 live]** measured on screen
here; **[16 static]** checked in the code only; **[15]** carried from judge #15.

## What was judged

- Working tree (all uncommitted) since judge #15: the controls' lens rework (`ui/HyprK/shaders/glasslens4.frag`,
  `LensGlass`, `Tokens`, `Knob`, `Slider`, `settings/panes/Appearance.qml`; `GLASS-HIG.md` sections 1-6 incl. Round 2,
  `GLASS-INTERACTION.md` section 19), judge #15's two defects (stale shell text menu, blank undecodable image in the Dock
  stack) and the Downloads tile flicker under Dock magnification.
- One session, `HYPRK_HEADLESS=1 HYPRK_KEEP=1 HYPRK_STATUS_STUB=1 scripts/smoke.sh` (2560 x 1664, scale 2; dark, light,
  dark; scale 1.6 spot check with `hyprctl eval hl.monitor`), state in `$XDG_RUNTIME_DIR/hk-j` with `dock.json`
  (`magnification: true`, size 64, magnified 96) and `appearance.json` (dark) written before start, scratch HOME /
  XDG_CACHE_HOME / TMPDIR, the script's private bus. `Downloads` held 13 throwaway files (docx, xlsx, pptx, csv, html,
  json, md, txt, mp3 and mp4 of random bytes, zip, `broken.png` of random bytes, `good.png` 64 x 48 orange);
  `Documents` a copy of five. Settings and Finder ran with the scratch HOME. Cursor hidden with `cursor:invisible` for
  the lens shots. Tools: `vptr`, `mcap` (6 runs, `long_intervals` 0 in all), `grim`, ImageMagick, numpy. Stopped with
  `smoke.sh --stop`, bus killed, state dir removed.
- Mac data: `screens/27.2.1/controls/switch-press-strip-light.png` (last frame, #324), `settings/appearance/
  liquidglass-0-mid-1-{dark,light}.png` (middle panel), `settings/toolbar-backforward-rest-hover-press-dark.png`, the
  23.09.23 recording frame 2685 (extracted with ffmpeg to scratch, read only).
- **Not measured: the Control Center slider held** (claim 1, last part). The CC Sound / Display sliders drive the real
  PipeWire sink and backlight of this machine (`shell/services/Audio.qml` 22, no stub); a press on the knob sets the
  value. Left unmeasured rather than touch the user's audio. Also not re-measured: scroll pocket, shadow, colour, Cmd-Tab,
  HUD, Apps, Stage Manager, lock screen, sounds. Crops in `reference/judge-95-16/` (01-13).

## Overall: **92.3** (13 surfaces 92.28, with the lock screen 92.25, with Stage Manager folded in at weight 2: 92.14)

Judge #15: 92.17. The gain is refraction on controls, the user's priority: the held switch now shows the track at the
Mac's 0.75 x (0.76) and the held slider's fill inside the lens matches the recording within one pixel row, the preview
buttons fold the sky (not the trees) at the rim with dark top / end levels within 2 of the Mac's. Both judge #15 defects
are fixed and the Downloads tile keeps its art in all 542 frames of a magnification sweep. What holds it: the held
switch's interior is shaded and 31 levels darker than its track where the Mac's is flat and equal, its fringe runs the
whole top edge where the Mac's sits only near the ends, its rim and shadow are about twice as strong; the light preview
rim is 16-22 levels too dark; no motion item moved.

## The developer's claims

| # | claim | measured here | verdict |
|---|---|---|---|
| 1a | held switch: backdrop about 0.75 x in the middle, outward rim displacement | Desktop & Dock, "Animate opening applications" held 1 s, light `06`: blue track 33 px tall outside the lens, **25 px inside** (0.76 x); Mac strip #324: 48 / 36 (**0.75 x**). Lens / outside track: ours 42 / 33 = 1.27, Mac 65 / 48 = 1.35. Rim samples outward (track edge pushed in from the rim) as on the Mac | **confirmed** (0.01 x; lens 6 % flatter than the Mac's) |
| 1b | cyan / yellow fringes inside the top / bottom rim | light `06`, R - B per row inside the rim: **top** ours -32..-43 over 4 px in **47 of 50** lens columns; Mac -21..-27 in **8 of 60** columns (near the ends only; the middle is neutral, 201 / 195 / 251). **Bottom** ours +32..+39 in 47 / 50 columns, 3-4 px; Mac +31..+34 in 48 / 60, 2 px | **partly**: bottom matches; top fringe about 1.5 x stronger and spread over the whole edge where the Mac has none in the middle |
| 1c | (not claimed, measured with 1a) | rim pixel ours top 170, bottom 163; Mac 201 / 195 (ours 30 levels darker). Track inside the lens: ours (23, 116, 217) with a vertical shading (B std 13.2), outside (0, 119, 248); Mac inside (10, 94, 207) = outside (10, 95, 210), flat (B std 4.8). Shadow under the lens: ours 247 -> 217 (-30), Mac 255 -> 238 (-17). Dark held switch `07`: black outline, faint yellow bottom (no Mac dark strip) | defects, see "next changes" |
| 1d | held slider knob: fill 20 px tall inside its end (recording 20) | Appearance > Liquid Glass knob held, dark, scale 2 `11`; blue height per column from the lens's left rim (B - R > 30): outside 12, inside **14 18 22 18 14 14** then 12. Recording frame 2685 `13`, same threshold: outside 14, inside **20 20 16 16** then 14; at B - R > 60 both read 12 -> 18 18 14 14 exactly. Scale 1.6 `12`: 10 -> 15 17 13 11 (same in points) | **confirmed** (within 2 px; the recording's peak 20, ours 22 for one column) |
| 1e | preview buttons refract the sky above, no trees from below | `05` light and dark: the share capsule's lower rim shows sky in both, the Search capsule folds the building's stripes vertical at its right end, as the Mac shots | **confirmed** |
| 1f | rim levels: light top 190 (Mac 207), light end 138 (Mac 135), dark top 174 (Mac 173), dark end 105 (Mac 101) | share capsule, mean RGB, 2x crop `grim -g "715,238 265x50"` vs the Mac's middle panel, same offset from the capsule's left / top edge. **Dark**: top rim pixel / next at 60 and 70 px from the end: ours 171 / 173, 173 / 174; Mac 173 / 175, 174 / 175. End (centre row): ours **107**, 169, 170; Mac **105**, 127, 145, 151. Face 8 px under the top: ours 182, Mac 163-164. **Light**: top rim ours **189 / 195**, Mac **211 / 210**; next 254 / 255 both; end ours **141**, 235; Mac **139**, 237; face 8 px under the top ours 251, Mac 240-241 | dark top and both ends **confirmed** (within 2); light top **16-22 too dark** (claim said 17); dark end's inner ramp too short (ours jumps to 169 in 1 px, Mac ramps 127 -> 151 over 4 px) and the dark face 18-19 too light |
| 1g | blur fill without ripples (dips per row dark 3.6 vs Mac 4.0) | my count (band-pass 1 px minus 6 px Gaussian, local minima below -1.5, Search capsule x 150-245 px from its left rim, rows 18-82): dark ours **2.08**, Mac **1.91**, correlation 0.75; light ours **1.95**, Mac **1.22**, correlation 0.82. My count is not the developer's (absolute values differ) | dark **confirmed** (9 % over the Mac); light still 1.6 x the Mac's ripples |
| 1h | CC slider held in dark: fill inside the lens 223 (Mac 222) | not measured (real audio sink, see above) | **not verified** |
| 2a | Spotlight's field menu closes with Spotlight | right-click in the field, then `panels toggle spotlight` (1x) and `panels close` (2x): layers 7 -> 4 each time, menu gone `02`; emoji search: right-click, `panels toggle emoji`: 7 -> 4 | **confirmed** (4 of 4) |
| 2b | undecodable image shows the PNG page in the Dock stack | grid `03`: broken.png = page with photo symbol and "PNG" (log still prints the decode error once per open); Finder too | **confirmed** (grid; the fan's items above did not reach it) |
| 2c | (judge #15) tile chevron visible below the first fan item | fan `04`: first item (good.png) 722.5-766 pt, the tile's chevron 779.5-798 pt, **13.5 pt below the item, fully visible** | **unchanged** (still visible) |
| 3 | Downloads tile does not flicker while the Dock magnifies | pointer swept 300 <-> 980 pt along y 795, 3 round trips, `mcap` 542 frames at 60 fps (`long_intervals` 0) `01`: the stack's orange art present in **542 of 542** frames, never below its rest size (2028 px, max 4549 magnified), bbox fill 0.988-1.0 in every frame; the largest frame-to-frame step is the Dock's own growth on entry (2596 -> 3468 px) | **confirmed** |

## Regression sweep

| surface | checked | result |
|---|---|---|
| Dock magnification | the sweep above | every tile magnifies and recovers, no missing art |
| window button lift | Finder red, held 0.9 s, 60 fps, drag out, release `08` | 13.75 -> **16.25 pt at 114-213 ms**, held 15.75 (j15 13.65 -> 16.06, 15.7); not closed after the drag-out release |
| toolbar press | Finder back / forward, forward held, dark `09` | capsule 64 -> **82** (+18), disc at the pressed button **100** (+36), the divider stays. Mac Settings (`toolbar-backforward-...-dark.png`): 62 -> **85-88** (+23..26), disc **109-111** (+47..49), the divider hidden on hover and press. As before (not new work) |
| Spotlight reopen | 2 reopens after `close`, `mcap -k 2` | first frame 68-84 ms after the call, scale at the field's right edge 1.069 1.054 1.046 1.035 1.027 1.015 1.012 1.008, the 2 runs identical (my edge is the right end, not judge #10's left row, so not compared with 1.088 ...) |
| menus | Finder File menu, dark `10` | glass, rows and shortcuts as before |
| Control Center, NC | dark, IPC `10` | rendered. NC's photo widget picked `Documents/broken.png` and shows an empty dark card (log: `NotificationCenter.qml` 568 decode error); a throwaway-file effect, counted as a minor defect |
| Mission Control (2 windows) | `mcap -k 8` full output | enter moves 120 -> 639 ms, exit 36 -> 355 ms, `long_intervals` 0 (j15 120 -> 640, 20 -> 350) |
| Finder | icon view of Documents, dark, 2x and 1.6 | broken.png page, txt / md / csv content thumbnails, fine |
| Settings | Appearance, Desktop & Dock, dark and light, 1.6 | fine |
| shell log | whole session | `QFont::setPixelSize: Pixel size <= 0` **x8** on the fan's open (j15 x7, not claimed fixed), StackArt / NC decode errors for broken.png, portal, text-input, qt.svg x5. No binding loop, no TypeError |

## Per dimension

| dimension | j15 | j16 | change | reason |
|---|---|---|---|---|
| animation | 91 | 91 | 0 | [16 live] button lift, MC, Spotlight unchanged; no new Mac motion |
| transition | 90 | 90 | 0 | MC enter / exit as j15 |
| visual | 93.5 | 93.5 | 0 | preview buttons closer (sky, dark levels) offset by the held switch's shaded interior; toolbar divider as before |
| behaviour | 93 | **93.5** | +0.5 | the stale text menu is gone (4 of 4 paths) |
| shape | 92 | 92 | 0 | lens / track 1.27 vs 1.35 (switch); slider fill shape matches |
| colour | 95 | 95 | 0 | [15] |
| shadow | 94 | 94 | 0 | held switch shadow -30 vs Mac -17 (old, now measured); otherwise [15] |
| refraction | 92 | **93** | +1 | [16 live] switch 0.76 x vs 0.75 x, slider fill 12 -> 18 -> 14 identical to the recording at one threshold, preview sky fold, dark top / end within 2, dark ripples within 9 %; minus top fringe over the whole edge, interior darkened 31 and shaded, light top rim -16..-22, light ripples 1.6 x |
| icon | 93 | **93.5** | +0.5 | undecodable image shows the PNG page in the stack |
| font | 95 | 95 | 0 | [15] |
| rendering | 90 | 90 | 0 | stack art kept under magnification (+), pixel size 0 x8 and an empty NC photo card (-) |
| sound | 90 | 90 | 0 | [15] |

Plain mean of the 12: 92.54 (j15 92.38).

## Per surface

| surface | weight | j15 | j16 | reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 94 | 94 | carried; menus fine |
| Dock | 14 | 93.75 | **94** | PNG page fallback, no flicker under magnification in 542 frames; chevron still visible under the fan |
| Window chrome | 14 | 91.75 | 91.75 | lift as j15; toolbar press +18 / +36 vs the Mac's +25 / +48 with the divider kept (as before) |
| Finder | 13 | 91.75 | 91.75 | carried, fine |
| System Settings | 10 | 93.75 | **94.25** | held switch 0.76 x, slider fill as the recording, preview sky fold and dark levels; minus the switch interior / fringe / rim |
| Control Center | 6 | 93 | 93 | the held CC slider not measured |
| NC + banners | 6 | 91.5 | 91.5 | rendered; empty photo card with an undecodable image |
| Spotlight | 6 | 89 | **89.5** | the field menu closes with Spotlight |
| Mission Control | 4 | 90.5 | 90.5 | as j15 |
| Sounds | 4 | 90 | 90 | carried |
| HUD | 3 | 90.5 | 90.5 | carried |
| Cmd-Tab | 3 | 91 | 91 | carried |
| Apps | 2 | 86 | 86 | carried |
| Lock screen | 5 | 91.5 | 91.5 | carried |
| *Stage Manager (extra)* | *2* | *85* | *85* | carried |

Weighted: 13 surfaces 9228.25 / 100 = 92.28. With the lock screen 9685.75 / 105 = 92.25. With Stage Manager
9398.25 / 102 = 92.14.

## Regressions

None found in the sweep. Defects still open (counted above):

- Held switch (light): interior darkened (B 248 -> 217, R 0 -> 23) and shaded (B std 13.2) where the Mac's interior equals
  its track (B std 4.8); cyan along the whole top edge (47 / 50 columns; Mac 8 / 60, ends only); rim 30 levels darker;
  shadow under the lens 1.8 x the Mac's.
- Fan: the tile's chevron stays visible 13.5 pt below the first item; label font from pixel size 0 (x8 per open).
- NC photo widget shows an empty card when it picks an undecodable image.

## The next 10 changes, by gain

Repo only (refraction first):

1. Held switch interior: keep the refracted track's colour equal to the track outside and drop the vertical shading
   (ours -31 in B and std 13; Mac 0 and std 4.8 in `switch-press-strip-light.png` #324) (+0.05).
2. Held switch fringe and rim: top cyan only near the round ends (Mac 8 of 60 columns), rim pixel 170 / 163 -> about
   200 / 195; lens shadow -30 -> -17 (+0.04).
3. Preview buttons, light: top rim pixel 189-195 -> 210, face under the top 251 -> 241; light blur ripples 1.95 -> 1.2
   dips per row (+0.03).
4. Preview buttons, dark: the round end's inner ramp (ours 107 -> 169 in 1 px, Mac 105 127 145 151 over 4 px) and the
   face 182 -> 163 (+0.03).
5. Toolbar capsule press: hide the divider on hover / press; capsule +18 -> +24, disc +36 -> +48 (Mac Settings) (+0.02).
6. Fan: cover or move the tile's chevron under the first item; clamp the label font; NC photo widget: skip undecodable
   files (+0.02).
7. A stub audio sink for headless sessions (`HYPRK_STATUS_STUB` covers the status modules only), so the CC slider lens
   can be judged without touching real audio (+0.01, unblocks 1h).

Needs the Mac:

8. The held switch over 4 pt black / white stripes and in dark, 2x (the dark rim and fringes have no reference) (+0.05).
9. Downloads stack fan and grid at 60 fps open / close; Mission Control exit with 4 windows (+0.1).
10. A light held knob on a Settings slider and on the CC Sound slider (+0.03).

## Reachable ceiling

About 92.45 with the repo's data (items 1-7). About 92.8-93 with the Mac captures (8-10 and the area items below). 95
is not reachable on this stack: judge #7's reasons (no glass or AppKit controls in third-party windows, unreachable app
menus, Hyprland's presentation and focus model, motions with no Mac data) still hold about 3 points.

## The twelve areas of the 95 goal

| area | scored as | now | what holds it under 95 | evidence needed |
|---|---|---|---|---|
| animation | animation | 91 | MC 4-window exit; stack fan / grid never filmed on the Mac; button spring decoded | Mac 60-120 fps captures (MC 4 windows, stack, held close button) |
| liquid glass | refraction + visual | 93.25 | held switch interior shaded and darkened; light preview rim too dark; no glass in third-party windows | repo items 1-4; Mac stills of the stack views and status modules |
| glass refraction | refraction | 93 | switch 0.76 x and slider fill now match; switch fringe over the whole top edge; light rim -16..-22; CC lens unverified | repo 1-4; Mac held switch in dark over stripes |
| shadows | shadow | 94 | held switch shadow 1.8 x the Mac's; banner, tail and module shadows never compared | repo 2; Mac stills (banner over grey 127, Dock menu, Wi-Fi module) |
| depth | shadow + rendering (layer order) | 93.5 | the stale text menu is gone; MC multi-window order assumed | Mac recording of MC exit |
| opacity | colour | 95 | at target | none |
| blur | refraction + visual | 93 | preview ripples dark at the Mac's, light 1.6 x; pocket 2-3 levels dark, 3-12 light (j14) | Mac Finder scrolled under the toolbar |
| sound | sound | 90 | output latency; no drag-to-Trash sound in the Dock | Mac audio + screen capture |
| icon | icon | 93.5 | image fallback now in the stack; rtf / generic / app documents not built | Mac renders of docx / xlsx / pptx / audio / video pages |
| emoji | (direct) | 94.5 | emoji in text never compared | a Mac shot of emoji in a notification and a menu |
| font | font | 95 | at target | none |
| scaling | (direct) | 90 | held slider lens lays out the same at 1.6 (fill 10 -> 17 px = 6.25 -> 10.6 pt); Mac scaled modes never compared | Mac capture of a scaled mode of the Dock, a menu and NC |

## Crops (`reference/judge-95-16/`)

`01-dock-magnify-stack-art-every-frame-dark-ours.png` (frames 0, 393, 395, 397, peak),
`02-spotlight-text-menu-then-close-dark-ours.png`, `03-stack-grid-broken-png-page-dark-ours.png`,
`04-stack-fan-chevron-below-first-item-dark-ours.png`, `05-preview-buttons-dark-mac-top-ours-bottom.png`,
`05-preview-buttons-light-mac-top-ours-bottom.png`, `06-held-switch-light-mac-strip-top-ours-bottom.png`,
`07-held-switch-dark-ours.png` (rest above, held below), `08-close-button-held-lift-dark-ours.png`,
`09-finder-back-forward-held-dark-ours.png` (rest above, held below), `10-file-menu-and-nc-dark-ours.png`,
`11-held-slider-dark-scale2-ours.png`, `12-held-slider-dark-scale1.6-ours.png`,
`13-held-slider-dark-mac-recording-f2685.png`.
