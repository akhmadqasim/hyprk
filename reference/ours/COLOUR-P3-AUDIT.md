# Colour audit: the Mac shots are Display P3

Read-only audit, 2026-11-11. No code was changed by it. Sections: 1 facts, 2 the conversion, 3 inventory of colour
constants, 4 measurement claims, 5 ranking and per-owner list, 6 not covered.

Short version: every `screencapture` shot of the Mac holds Display P3 numbers (most of them even carry the profile),
the fits read the raw numbers, and hyprk shows those numbers as sRGB. Greys are not affected. Saturated constants
taken from shots are off by ΔE00 1.5 to 4.5 (reds up to 28 levels on one channel). 164 constants need converting,
most of them the traffic lights; the accent system (`Accent.qml`), the icon styles and the glass recipes are fine.
Already handled by their owners: Settings slider fill (7ee8a39, nothing to change), icon styles (`check-styles.py`
converts before fitting), the plugin's traffic-light table (d104e6d, refitted in sRGB).

## 1. Facts

### 1.1 What the reference images carry

Checked with PIL on every PNG under `reference/screens/27.2.1/**`, `reference/re/27.2.1/live/**` and
`reference/judge-95*/` (chunks before IDAT: iCCP, cICP, sRGB, gAMA, eXIf).

| Source | Files | Tag | Pixel values are |
|---|---|---|---|
| `screencapture` output kept as it came (most of `windows/`, `panels/`, `nc/`, `glass53/`, `verify/**`, `dock/`, `live/finder/crops`, `live/finder/icons-live`) | 299 | iCCP "Display" (one identical 4,076 byte profile, md5 7a198c0b…) | **Display P3** |
| the same with the Screenshot metadata (`hud-*.png`, `controls/controls-*.png`, `menubar/bar-*.png`, `dock/apps-*.png`, `finder/alert-*.png` …) | 37 of the 299 | iCCP "Display" + cICP (12, 13, 0, 1) + eXIf | **Display P3** (cICP 12 = P3 D65 primaries, 13 = sRGB transfer, full range) |
| crops, strips and montages re-saved by our tools (`lock/field-*.png`, `lock/full-*`, all of `finder/*.png`, 32 of `settings/*.png`, `controls/focus-rings-*`, `controls/switch-*-strip`, `menubar/status-pills-open-blue.png`, `nc/*-strip*.png`, `verify/B/knob-*`, `verify/C2/ramp-*`, `verify/C3/blur-edge-*`, `settings/appearance/appearance-full-*`, `liquidglass-0-mid-1-*`, `windows/textedit-edited-title-states-dark.png`, `glass53/dock-dark-white-iconstyles-*`) | about 75 | none | **Display P3, untagged** (the profile was dropped on re-save, the numbers were not converted: `menubar/status-pills-open-blue.png` still reads the bar as 69,83,206, the device value of that wallpaper) |
| `reference/judge-95*/*.png` (39 judge montages, Mac next to ours) | 39 | none | **mixed**: the Mac half is raw P3, our half is sRGB |
| rendered off screen by a probe into an sRGB bitmap (`multicolor-swatch.png`, `multicolor-highlight-swatch.png`, `text-sample-*.png`, `live/finder/icons-rendered/*` 84, `live/windows/cursors*/*` 39) | 127 | sRGB chunk + eXIf | **sRGB** |
| layer dumps and colour dumps (`reference/re/27.2.1/live/**/*.json`: 3,927 colours `kCGColorSpaceExtendedSRGB`, 193 `kCGColorSpaceSRGB`; `accent-colors.json` "converted to sRGB 0..255") | json | n/a | **sRGB** |
| screen recordings (R2 motion, `.mov` analysed per frame on the Mac; no video file is in the repo) | 0 | n/a | unknown, and only used for timing and alpha, not for colour |
| old 27.2 web pictures in `reference/screens/*.png|jpg|webp` (Adobe ImageReady, sRGB IEC61966-2.1) | 7 | sRGB or none | sRGB (press pictures, not our Mac) |

The embedded profile "Display" (Apple, v2.1, mntr RGB): rXYZ 0.5151 0.2412 −0.0011, gXYZ 0.2920 0.6922 0.0419,
bXYZ 0.1571 0.0666 0.7841 (the D50-adapted Display P3 primaries, exactly), TRC = the sRGB curve
(`aarg` para type 3: 2.4, 0.94786, 0.05214, 0.07739, 0.04045). So the earlier statement "P3 values without an
embedded profile" is half right: the values are P3, and four shots in five DO carry the profile; nobody applied it.
PIL, `magick` without `-profile`, and every fitting script in the repo read the raw numbers.

### 1.2 How the shots were made

`/usr/sbin/screencapture -x -R x,y,w,h` (verify A/B/B2 scripts, probes `glass3`, `cham`, `controls`, `thick`,
`toolbar`, `windows`), or `screencapture -o -l <window>` (Q-finder, Q-windows). screencapture writes the display's
own pixel values and tags them with the display profile; it never converts to sRGB. The MacBook Air panel is P3.

Backdrops of the probes come in two kinds, and this matters for every "glass over colour" number:

- **device values** (`CGColor(colorSpace: NSScreen.screens[0].colorSpace…)`: `glass3.swift:137,272`, `thick.swift:96,212,285`,
  `cham.swift:33`, `glassfit.swift:227-230`, `lensprobe.swift:194-195`, and the solid test wallpapers): the shot reads
  back the number that was asked for. `verify/C3/sidebar-*-over-69_83_206.png` reads 69,83,206, `…over-0_255_0.png`
  reads 0,255,0, `…over-230_140_40.png` 230,140,40. These numbers are P3 on both ends.
- **sRGB values** (`NSColor(srgbRed:)`: `ncbg.swift:30`, `ccglass.swift:18`, `menus.swift:163,175`,
  glass tints in `glassfit.swift:244`): the shot reads the P3 form. `nc/overview-redacted-dark-blue.png` was asked
  for sRGB 69,83,206 and reads **72,83,199**.

### 1.3 Calibration: known sRGB colours read back from the shots

| Colour (sRGB, source) | Predicted P3 reading | Read in shot | Shot converted back |
|---|---|---|---|
| menu highlight, layer dump `backgroundColor sRGB (0, 0.478, 1)` = #007AFF (MAC-ANSWERS verify-B2 4a) | 52.2, 120.1, 246.4 | 52,120,246 (`verify/B2/menu-item-highlight-*`, `controls/controls-*.png`) | 0,122,255 |
| systemGreen light #34C759, switch on (`controls/controls-light.png`) | 100.8, 196.2, 102.0 | 101,196,102 | 53,199,89 |
| systemGreen dark #30D158 (`controls/controls-dark.png`) | 103.7, 206.0, 103.0 | 104,206,103 | 49,209,88 |
| NC probe backdrop `NSColor(srgbRed: 69,83,206)` (`nc/overview-redacted-dark-blue.png`) | 71.7, 82.6, 198.7 | 72,83,199 | 69,83,206 |
| slider fill light (`controls/controls-light.png`, 27,188 px) | n/a | 51,117,240 | 2,119,248 |

All four known colours land within 0.5 level of the theoretical sRGB → Display P3 transform, on every channel. A
free 3x3 fit in linear light on these points gives the theoretical matrix within the rounding of four 8-bit points;
there is no extra gain, gamma or white-point term. MAC-ANSWERS says the same in two places that were overlooked:
verify-B2 4a "fill (52, 120, 246) … = #007AFF converted to the display space (52.1, 120.1, 246.4)" and
Q-menubar-04 "over Electric Blue 89,104,228 vs 69,83,206 (sRGB 85,105,237 vs 65,84,214)".

**Verdict: the shots are Display P3 encoded. Every saturated number read off them is a P3 number.**

Not every number in MAC-ANSWERS is raw: Q-menubar-12/13 say "sRGB" and "display→sRGB via ICC", Q-menubar-11 says
"display RGB", the NC section says "blue sRGB (69,83,206) … reads as (72,83,199) in display RGB", LOCKSCREEN-27.2.1.md
quotes its screenshot values as "P3". Two labels are wrong: Q-finder ("Colours are sRGB from 2x window captures",
MAC-ANSWERS:2089 and `finder-measurements.json` `_about`) and Q-windows ("Colours are sRGB from 2x screenshots",
MAC-ANSWERS:821). Their crops are tagged Display and the quoted numbers equal the raw pixels: the column selection
"(41,98,217)" is the raw pixel of `live/finder/crops/columns-light-active.png` and converts to 0,100,225 = #0064E1,
the catalog selectedContentBackground of R5 (MAC-ANSWERS:474). Provenance is settled per constant below.

Two more cross-checks from Apple's own data, both independent of any shot:

- R5 catalog (sRGB): selectedContentBackground #0064E1 / #0059D1, systemBlue #0088FF / #0091FF, link #0068DA / #419CFF.
  Shots converted: Finder selection 0,100,225 / 0,89,209; `controls-*.png` 59,134,247 → 0,136,255 and 63,143,247 →
  0,145,255; Finder "Show More" link 46,104,211 → 8,106,218 and 89,152,245 → 64,154,252.
- Traffic-light gradient colours decoded from DesignLibrary (reference/ours/windows/LIGHTS.md): dark close
  (250,106,97), minimise (250,181,26), zoom (86,200,58). Shot fills converted: #E87061 → 250,103,90, #F1B835 →
  252,181,0, #6EC341 → 74,198,29. The raw shot values (232,112,97 / 241,184,53 / 110,195,65) are 18 to 30 levels away.

## 2. The conversion

Display P3 (D65, sRGB transfer) → linear → 3x3 to sRGB primaries (both spaces are D65, so no chromatic adaptation,
no Bradford) → sRGB transfer → clip to 0..255. Colours outside sRGB clip (pure P3 red 255,0,0 stays 255,0,0).

```
linear sRGB = M · linear P3        M =  1.2249401763  -0.2249401763   0.0000000000
                                       -0.0420569547   1.0420569547   0.0000000000
                                       -0.0196375546  -0.0786360456   1.0982736001
linear P3 = M⁻¹ · linear sRGB    M⁻¹ =  0.8224621209   0.1775378791   0.0000000000
                                        0.0331941989   0.9668058011   0.0000000000
                                        0.0170826307   0.0723974407   0.9105199286
```

```python
M = ((1.2249401763, -0.2249401763, 0.0), (-0.0420569547, 1.0420569547, 0.0), (-0.0196375546, -0.0786360456, 1.0982736001))
def p3_to_srgb(rgb):                     # rgb: 0..255 as read from a Mac shot; returns sRGB 0..255
    lin = [c / 255 for c in rgb]
    lin = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in lin]
    out = [sum(M[i][j] * lin[j] for j in range(3)) for i in range(3)]
    out = [min(1.0, max(0.0, c)) for c in out]
    out = [12.92 * c if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055 for c in out]
    return tuple(round(255 * c) for c in out)
# p3_to_srgb((52, 120, 246)) == (0, 122, 255); p3_to_srgb((101, 196, 102)) == (53, 199, 89); greys are unchanged
```

Rules for applying it:

- A colour with alpha: convert the RGB, keep the alpha. A colour that was un-premultiplied from a shot over a known
  backdrop: convert the composite and the backdrop first, then solve for the layer colour (the transform is not
  linear in encoded values, so converting the solved colour is only approximately the same).
- A model fitted to shot numbers (matrices, gains, ramps): convert the shot numbers and refit; do not push the fitted
  coefficients through the function.
- With PIL the same thing is `ImageCms.profileToProfile(im, <embedded profile>, sRGB, renderingIntent=1)` for tagged
  shots; untagged crops need the function above (or attach the "Display" profile of any tagged shot first).
- ΔE in this document = CIEDE2000 between the current constant and the converted one, both shown as sRGB: that is
  the error on the user's sRGB screen today. Typical size: system blue 2.1, traffic-light red 2.6 to 4, green 3 to 6,
  orange/yellow 1.5 to 2.5, tinted darks under 0.6.

## 3. Inventory of colour constants

Method: every colour literal in the tracked sources of `ui/ shell/ settings/ finder/ plugin/ plugin-motion/ config/
themes/ lockscreen/ scripts/` (hex, `Qt.rgba`, `rgb()`, `vec3`, byte and float triples; 2,907 literals) was run
through the conversion. A literal is "neutral" when no channel moves by more than 1 level; the other 987 hits were
read with their comments and sorted by where the number came from. Counts are distinct (file, line, colour).

| Verdict | Count | Where |
|---|---|---|
| **convert** (taken from raw P3 shot values, saturated) | 164 | `ui/` 80, `plugin/` 51 (legacy table; only its 12 glyph colours are still drawn), `finder/` 16, `themes/` 12, `settings/` 5 |
| **refit** (a model fitted to raw shot values) | 3 open + 1 done | open: `ui/HyprK/TrafficLights.qml:30-37`, `finder/src/sysicons.cpp:12,34-35`; done: plugin lights table (d104e6d) |
| **already sRGB** | 128 | `ui/HyprK/Accent.qml` 78, icon tints 16, documented system colours 34 |
| **not from shots** (hand-picked or derived, nothing to convert) | 56 | fallbacks, Qt theme derivations, free cursors, a11y tints |
| **generated** (rebuild after the source changes) | 336 | `themes/gtk/**/*.css` 310, `themes/qt/colors`, `kvantum` 26 |
| **neutral: no change** | about 1,920 + 13 lock lifts | everything grey or tinted by ≤ 1 level after conversion |
| **unclear** | 6 items | see 3.6 |
| not a colour (bezier points, luma weights, sizes, comments) | 88 | |

`shell/` and `config/hypr/` have **no** constant to convert: the shell takes its saturated colours from `Accent.qml`
and documented system colours, its glass and Dock numbers are greys, `hyprland.lua` only has black with alpha.

### 3.1 Convert

Columns: current value, saturation (max − min channel), the value to write instead, the change per channel, ΔE
(CIEDE2000 and ΔE76 in Lab, old vs new as sRGB). Alpha stays as it is. Source files are under
`reference/screens/27.2.1/` unless they start with MAC-ANSWERS.

**Owner `ui/`**

| file:line | token | current | sat | converted (new value) | Δ R,G,B | ΔE00 | ΔE76 | source (P3 raw) |
|---|---|---|---|---|---|---|---|---|
| `ui/HyprK/Tokens.qml:180` | panel.destructiveFill | #653F43 101,63,67 | 38 | #6B3D42 107,61,66 | +6,-2,-1 | 2.3 | 3.8 | finder/alert-*.png (tagged Display), Q-panels-33 |
|  |  | #F9D1D0 249,209,208 | 41 | #FFCFCF 255,207,207 | +6,-2,-1 | 2.2 | 3.1 |  |
| `ui/HyprK/Tokens.qml:181` | panel.destructiveText | #DC3929 220,57,41 | 179 | #F01D14 240,29,20 | +20,-28,-21 | 3.8 | 17.0 | finder/alert-*.png, MAC-ANSWERS:2719 |
|  |  | #EB4C46 235,76,70 | 165 | #FF393C 255,57,60 | +20,-19,-10 | 3.3 | 14.3 |  |
| `ui/HyprK/Tokens.qml:183` | panel.defaultFill | #3478F6 52,120,246 | 194 | #007AFF 0,122,255 | -52,+2,+9 | 2.1 | 4.5 | MAC-ANSWERS:2715 "(52,120,246)", alert shots |
| `ui/HyprK/Tokens.qml:236` | lights.close dark rest | #E87061 232,112,97 | 135 | #FA675A 250,103,90 | +18,-9,-7 | 3.3 | 11.7 | windows/lights-rest-dark.png, Q-windows-08/10 |
|  |  | #E1675B 225,103,91 | 134 | #F25D54 242,93,84 | +17,-10,-7 | 3.2 | 11.5 |  |
|  |  | #DE6F64 222,111,100 | 122 | #EE675E 238,103,94 | +16,-8,-6 | 3.1 | 10.4 |  |
|  |  | #F6C6BC 246,198,188 | 58 | #FFC4BA 255,196,186 | +9,-2,-2 | 2.6 | 4.4 |  |
|  |  | #D96156 217,97,86 | 131 | #EA574F 234,87,79 | +17,-10,-7 | 3.2 | 11.5 |  |
|  |  | #F5C4BA 245,196,186 | 59 | #FEC2B8 254,194,184 | +9,-2,-2 | 2.6 | 4.4 |  |
|  |  | #850000 133,0,0 | 133 | #920000 146,0,0 | +13,+0,+0 | 2.6 | 5.9 |  |
| `ui/HyprK/Tokens.qml:237` | lights.close dark press | #FF9381 255,147,129 | 126 | #FF8C7B 255,140,123 | +0,-7,-6 | 1.6 | 3.6 | windows/lights-press-close-dark.png |
|  |  | #FF9485 255,148,133 | 122 | #FF8D80 255,141,128 | +0,-7,-5 | 1.7 | 3.5 |  |
|  |  | #FEFBED 254,251,237 | 17 | #FFFBEB 255,251,235 | +1,+0,-2 | 0.8 | 1.1 |  |
|  |  | #FD7B6E 253,123,110 | 143 | #FF7167 255,113,103 | +2,-10,-7 | 2.0 | 5.5 |  |
|  |  | #B60000 182,0,0 | 182 | #C70000 199,0,0 | +17,+0,+0 | 3.4 | 6.7 |  |
|  |  | #FFD9CC 255,217,204 a0.07 | 51 | #FFD7CA 255,215,202 | +0,-2,-2 | 0.7 | 1.0 |  |
| `ui/HyprK/Tokens.qml:238` | lights.close light rest | #ED786B 237,120,107 | 130 | #FE6F65 254,111,101 | +17,-9,-6 | 3.2 | 11.0 | windows/lights-rest-light.png, lights-hover-light.png |
|  |  | #EA857B 234,133,123 | 111 | #FA7E77 250,126,119 | +16,-7,-4 | 3.2 | 9.7 |  |
|  |  | #E89189 232,145,137 | 95 | #F68C86 246,140,134 | +14,-5,-3 | 3.0 | 8.0 |  |
|  |  | #B40A0A 180,10,10 | 170 | #C50000 197,0,0 | +17,-10,-10 | 3.6 | 9.6 |  |
|  |  | #9E0000 158,0,0 | 158 | #AD0000 173,0,0 | +15,+0,+0 | 3.0 | 6.3 |  |
|  |  | #B50A0A 181,10,10 a0.065 | 171 | #C60000 198,0,0 | +17,-10,-10 | 3.6 | 9.6 |  |
| `ui/HyprK/Tokens.qml:239` | lights.close light press | #FF9A8B 255,154,139 | 116 | #FF9486 255,148,134 | +0,-6,-5 | 1.4 | 3.1 | windows/lights-press-close-light.png |
|  |  | #FFA898 255,168,152 | 103 | #FFA394 255,163,148 | +0,-5,-4 | 1.3 | 2.5 |  |
|  |  | #FFB6A8 255,182,168 | 87 | #FFB2A4 255,178,164 | +0,-4,-4 | 1.0 | 2.0 |  |
|  |  | #F42319 244,35,25 | 219 | #FF0000 255,0,0 | +11,-35,-25 | 2.5 | 10.9 |  |
|  |  | #D40000 212,0,0 | 212 | #E80000 232,0,0 | +20,+0,+0 | 4.3 | 7.7 |  |
|  |  | #F5241A 245,36,26 a0.22 | 219 | #FF0000 255,0,0 | +10,-36,-26 | 2.5 | 10.9 |  |
| `ui/HyprK/Tokens.qml:241` | lights.minimise dark rest | #F1B835 241,184,53 | 188 | #FCB500 252,181,0 | +11,-3,-53 | 3.5 | 12.7 | windows/lights-rest-dark.png |
|  |  | #F3C22D 243,194,45 | 198 | #FCC000 252,192,0 | +9,-2,-45 | 2.8 | 9.4 |  |
|  |  | #F6CF50 246,207,80 | 166 | #FECD28 254,205,40 | +8,-2,-40 | 3.6 | 14.0 |  |
|  |  | #F6F581 246,245,129 | 117 | #F6F56C 246,245,108 | +0,+0,-21 | 2.5 | 9.3 |  |
|  |  | #EABA19 234,186,25 | 209 | #F3B800 243,184,0 | +9,-2,-25 | 2.7 | 6.1 |  |
|  |  | #F5F58D 245,245,141 | 104 | #F5F57C 245,245,124 | +0,+0,-17 | 2.3 | 7.9 |  |
|  |  | #AA3600 170,54,0 | 170 | #B92800 185,40,0 | +15,-14,+0 | 4.0 | 10.3 |  |
| `ui/HyprK/Tokens.qml:242` | lights.minimise dark press | #FFFF8E 255,255,142 | 113 | #FFFF7B 255,255,123 | +0,+0,-19 | 2.4 | 8.6 | windows/lights-press-min-dark.png |
|  |  | #FFFF5C 255,255,92 | 163 | #FFFF26 255,255,38 | +0,+0,-54 | 3.3 | 15.7 |  |
|  |  | #FFFF7A 255,255,122 | 133 | #FFFF5F 255,255,95 | +0,+0,-27 | 2.7 | 11.2 |  |
|  |  | #FBFB98 251,251,152 | 99 | #FBFB89 251,251,137 | +0,+0,-15 | 2.1 | 7.1 |  |
|  |  | #F9D623 249,214,35 | 214 | #FFD400 255,212,0 | +6,-2,-35 | 2.1 | 5.7 |  |
|  |  | #FBFBA6 251,251,166 | 85 | #FBFB9A 251,251,154 | +0,+0,-12 | 1.9 | 5.8 |  |
|  |  | #E74F00 231,79,0 | 231 | #FB3E00 251,62,0 | +20,-17,+0 | 4.5 | 12.7 |  |
|  |  | #FFFF99 255,255,153 a0.07 | 102 | #FFFF89 255,255,137 | +0,+0,-16 | 2.2 | 7.5 |  |
| `ui/HyprK/Tokens.qml:243` | lights.minimise light rest | #F2BD50 242,189,80 | 162 | #FCBA31 252,186,49 | +10,-3,-31 | 3.5 | 13.0 | windows/lights-rest-light.png |
|  |  | #F5CB59 245,203,89 | 156 | #FDC93C 253,201,60 | +8,-2,-29 | 3.3 | 12.1 |  |
|  |  | #F8D562 248,213,98 | 150 | #FFD347 255,211,71 | +7,-2,-27 | 3.2 | 11.5 |  |
|  |  | #91210A 145,33,10 | 135 | #9E0D00 158,13,0 | +13,-20,-10 | 2.9 | 10.7 |  |
|  |  | #BE4900 190,73,0 | 190 | #CE3E00 206,62,0 | +16,-11,+0 | 4.3 | 10.5 |  |
| `ui/HyprK/Tokens.qml:244` | lights.minimise light press | #FFF66C 255,246,108 | 147 | #FFF64C 255,246,76 | +0,+0,-32 | 2.9 | 12.4 | windows/lights-press-min-light.png |
|  |  | #FFFB6B 255,251,107 | 148 | #FFFB49 255,251,73 | +0,+0,-34 | 2.9 | 12.8 |  |
|  |  | #FFFF7E 255,255,126 | 129 | #FFFF65 255,255,101 | +0,+0,-25 | 2.6 | 10.6 |  |
|  |  | #D04020 208,64,32 | 176 | #E22E00 226,46,0 | +18,-18,-32 | 3.9 | 16.9 |  |
|  |  | #FF6500 255,101,0 | 255 | #FF5600 255,86,0 | +0,-15,+0 | 3.6 | 6.7 |  |
|  |  | #D14021 209,64,33 a0.2 | 176 | #E32D00 227,45,0 | +18,-19,-33 | 4.0 | 17.3 |  |
| `ui/HyprK/Tokens.qml:246` | lights.zoom dark rest | #6EC341 110,195,65 | 130 | #4AC61D 74,198,29 | -36,+3,-36 | 3.8 | 17.0 | windows/lights-rest-dark.png |
|  |  | #62BD2D 98,189,45 | 144 | #35C000 53,192,0 | -45,+3,-45 | 3.6 | 15.7 |  |
|  |  | #6DC04B 109,192,75 | 117 | #4AC333 74,195,51 | -35,+3,-24 | 3.7 | 15.5 |  |
|  |  | #BFF69A 191,246,154 | 92 | #AFF88E 175,248,142 | -16,+2,-12 | 2.9 | 9.4 |  |
|  |  | #59B61C 89,182,28 | 154 | #23B900 35,185,0 | -54,+3,-28 | 3.6 | 13.6 |  |
|  |  | #B8F697 184,246,151 | 95 | #A6F88B 166,248,139 | -18,+2,-12 | 2.9 | 9.8 |  |
|  |  | #005500 0,85,0 | 85 | #005700 0,87,0 | +0,+2,+0 | 0.6 | 1.1 |  |
| `ui/HyprK/Tokens.qml:247` | lights.zoom dark press | #56F66E 86,246,110 | 160 | #00FA58 0,250,88 (CoreUI value, see unclear) | -86,+4,-22 | 2.9 | 15.1 | rest crop + CoreUI #56F66E |
|  |  | #BFF69A 191,246,154 | 92 | #AFF88E 175,248,142 | -16,+2,-12 | 2.9 | 9.4 |  |
|  |  | #59B61C 89,182,28 | 154 | #23B900 35,185,0 | -54,+3,-28 | 3.6 | 13.6 |  |
|  |  | #B8F697 184,246,151 | 95 | #A6F88B 166,248,139 | -18,+2,-12 | 2.9 | 9.8 |  |
|  |  | #005500 0,85,0 | 85 | #005700 0,87,0 | +0,+2,+0 | 0.6 | 1.1 |  |
| `ui/HyprK/Tokens.qml:248` | lights.zoom light rest | #7DCD4A 125,205,74 | 131 | #5FD02A 95,208,42 | -30,+3,-32 | 3.6 | 16.3 | windows/lights-rest-light.png |
|  |  | #98D46F 152,212,111 | 101 | #86D660 134,214,96 | -18,+2,-15 | 3.0 | 10.7 |  |
|  |  | #A9DA86 169,218,134 | 84 | #9BDC7B 155,220,123 | -14,+2,-11 | 2.8 | 8.7 |  |
|  |  | #0A550A 10,85,10 | 75 | #005700 0,87,0 | -10,+2,-10 | 1.5 | 4.7 |  |
|  |  | #097900 9,121,0 | 121 | #007B00 0,123,0 | -9,+2,+0 | 0.7 | 1.6 |  |
|  |  | #0A540A 10,84,10 a0.05 | 74 | #005600 0,86,0 | -10,+2,-10 | 1.5 | 4.8 |  |
| `ui/HyprK/Tokens.qml:249` | lights.zoom light press | #A0FF60 160,255,96 | 159 | #7DFF3A 125,255,58 | -35,+0,-38 | 3.6 | 17.3 | windows/lights-press-zoom-light.png |
|  |  | #B9FF84 185,255,132 | 123 | #A4FF71 164,255,113 | -21,+0,-19 | 2.9 | 11.4 |  |
|  |  | #D2FFA7 210,255,167 | 88 | #C6FF9C 198,255,156 | -12,+0,-11 | 2.3 | 7.0 |  |
|  |  | #347F20 52,127,32 | 95 | #008100 0,129,0 | -52,+2,-32 | 3.4 | 13.2 |  |
|  |  | #15A400 21,164,0 | 164 | #00A700 0,167,0 | -21,+3,+0 | 1.0 | 2.4 |  |
|  |  | #338021 51,128,33 a0.22 | 95 | #008200 0,130,0 | -51,+2,-33 | 3.4 | 13.2 |  |

**Owner `plugin/`**

| file:line | token | current | sat | converted (new value) | Δ R,G,B | ΔE00 | ΔE76 | source (P3 raw) |
|---|---|---|---|---|---|---|---|---|
| `plugin/src/Titlebar.cpp:79` | legacy lights table (fill / ring / glyph / glow) | #ED786B 237,120,107 | 130 | #FE6F65 254,111,101 | +17,-9,-6 | 3.2 | 11.0 | windows/lights-*.png (same numbers as Tokens.lights) |
|  |  | #EA857B 234,133,123 | 111 | #FA7E77 250,126,119 | +16,-7,-4 | 3.2 | 9.7 |  |
|  |  | #E89189 232,145,137 | 95 | #F68C86 246,140,134 | +14,-5,-3 | 3.0 | 8.0 |  |
|  |  | #B40A0A 180,10,10 | 170 | #C50000 197,0,0 | +17,-10,-10 | 3.6 | 9.6 |  |
|  |  | #9E0000 158,0,0 | 158 | #AD0000 173,0,0 | +15,+0,+0 | 3.0 | 6.3 |  |
| `plugin/src/Titlebar.cpp:80` | legacy lights table (fill / ring / glyph / glow) | #F2BD50 242,189,80 | 162 | #FCBA31 252,186,49 | +10,-3,-31 | 3.5 | 13.0 | windows/lights-*.png (same numbers as Tokens.lights) |
|  |  | #F5CB59 245,203,89 | 156 | #FDC93C 253,201,60 | +8,-2,-29 | 3.3 | 12.1 |  |
|  |  | #F8D562 248,213,98 | 150 | #FFD347 255,211,71 | +7,-2,-27 | 3.2 | 11.5 |  |
|  |  | #91210A 145,33,10 | 135 | #9E0D00 158,13,0 | +13,-20,-10 | 2.9 | 10.7 |  |
|  |  | #BE4900 190,73,0 | 190 | #CE3E00 206,62,0 | +16,-11,+0 | 4.3 | 10.5 |  |
| `plugin/src/Titlebar.cpp:81` | legacy lights table (fill / ring / glyph / glow) | #7DCD4A 125,205,74 | 131 | #5FD02A 95,208,42 | -30,+3,-32 | 3.6 | 16.3 | windows/lights-*.png (same numbers as Tokens.lights) |
|  |  | #98D46F 152,212,111 | 101 | #86D660 134,214,96 | -18,+2,-15 | 3.0 | 10.7 |  |
|  |  | #A9DA86 169,218,134 | 84 | #9BDC7B 155,220,123 | -14,+2,-11 | 2.8 | 8.7 |  |
|  |  | #0A550A 10,85,10 | 75 | #005700 0,87,0 | -10,+2,-10 | 1.5 | 4.7 |  |
|  |  | #097900 9,121,0 | 121 | #007B00 0,123,0 | -9,+2,+0 | 0.7 | 1.6 |  |
| `plugin/src/Titlebar.cpp:82` | legacy lights table (fill / ring / glyph / glow) | #FF9A8B 255,154,139 | 116 | #FF9486 255,148,134 | +0,-6,-5 | 1.4 | 3.1 | windows/lights-*.png (same numbers as Tokens.lights) |
|  |  | #FFA898 255,168,152 | 103 | #FFA394 255,163,148 | +0,-5,-4 | 1.3 | 2.5 |  |
|  |  | #FFB6A8 255,182,168 | 87 | #FFB2A4 255,178,164 | +0,-4,-4 | 1.0 | 2.0 |  |
|  |  | #F42319 244,35,25 | 219 | #FF0000 255,0,0 | +11,-35,-25 | 2.5 | 10.9 |  |
|  |  | #D40000 212,0,0 | 212 | #E80000 232,0,0 | +20,+0,+0 | 4.3 | 7.7 |  |
| `plugin/src/Titlebar.cpp:83` | legacy lights table (fill / ring / glyph / glow) | #FFF66C 255,246,108 | 147 | #FFF64C 255,246,76 | +0,+0,-32 | 2.9 | 12.4 | windows/lights-*.png (same numbers as Tokens.lights) |
|  |  | #FFFB6B 255,251,107 | 148 | #FFFB49 255,251,73 | +0,+0,-34 | 2.9 | 12.8 |  |
|  |  | #FFFF7E 255,255,126 | 129 | #FFFF65 255,255,101 | +0,+0,-25 | 2.6 | 10.6 |  |
|  |  | #D04020 208,64,32 | 176 | #E22E00 226,46,0 | +18,-18,-32 | 3.9 | 16.9 |  |
|  |  | #FF6500 255,101,0 | 255 | #FF5600 255,86,0 | +0,-15,+0 | 3.6 | 6.7 |  |
| `plugin/src/Titlebar.cpp:84` | legacy lights table (fill / ring / glyph / glow) | #A0FF60 160,255,96 | 159 | #7DFF3A 125,255,58 | -35,+0,-38 | 3.6 | 17.3 | windows/lights-*.png (same numbers as Tokens.lights) |
|  |  | #B9FF84 185,255,132 | 123 | #A4FF71 164,255,113 | -21,+0,-19 | 2.9 | 11.4 |  |
|  |  | #D2FFA7 210,255,167 | 88 | #C6FF9C 198,255,156 | -12,+0,-11 | 2.3 | 7.0 |  |
|  |  | #347F20 52,127,32 | 95 | #008100 0,129,0 | -52,+2,-32 | 3.4 | 13.2 |  |
|  |  | #15A400 21,164,0 | 164 | #00A700 0,167,0 | -21,+3,+0 | 1.0 | 2.4 |  |
| `plugin/src/Titlebar.cpp:85` | legacy lights table (fill / ring / glyph / glow) | #E87061 232,112,97 | 135 | #FA675A 250,103,90 | +18,-9,-7 | 3.3 | 11.7 | windows/lights-*.png (same numbers as Tokens.lights) |
|  |  | #E1675B 225,103,91 | 134 | #F25D54 242,93,84 | +17,-10,-7 | 3.2 | 11.5 |  |
|  |  | #DE6F64 222,111,100 | 122 | #EE675E 238,103,94 | +16,-8,-6 | 3.1 | 10.4 |  |
|  |  | #F6C6BC 246,198,188 | 58 | #FFC4BA 255,196,186 | +9,-2,-2 | 2.6 | 4.4 |  |
|  |  | #D96156 217,97,86 | 131 | #EA574F 234,87,79 | +17,-10,-7 | 3.2 | 11.5 |  |
|  |  | #F5C4BA 245,196,186 | 59 | #FEC2B8 254,194,184 | +9,-2,-2 | 2.6 | 4.4 |  |
|  |  | #850000 133,0,0 | 133 | #920000 146,0,0 | +13,+0,+0 | 2.6 | 5.9 |  |
| `plugin/src/Titlebar.cpp:86` | legacy lights table (fill / ring / glyph / glow) | #F1B835 241,184,53 | 188 | #FCB500 252,181,0 | +11,-3,-53 | 3.5 | 12.7 | windows/lights-*.png (same numbers as Tokens.lights) |
|  |  | #F3C22D 243,194,45 | 198 | #FCC000 252,192,0 | +9,-2,-45 | 2.8 | 9.4 |  |
|  |  | #F6CF50 246,207,80 | 166 | #FECD28 254,205,40 | +8,-2,-40 | 3.6 | 14.0 |  |
|  |  | #F6F581 246,245,129 | 117 | #F6F56C 246,245,108 | +0,+0,-21 | 2.5 | 9.3 |  |
|  |  | #EABA19 234,186,25 | 209 | #F3B800 243,184,0 | +9,-2,-25 | 2.7 | 6.1 |  |
|  |  | #F5F58D 245,245,141 | 104 | #F5F57C 245,245,124 | +0,+0,-17 | 2.3 | 7.9 |  |
|  |  | #AA3600 170,54,0 | 170 | #B92800 185,40,0 | +15,-14,+0 | 4.0 | 10.3 |  |
| `plugin/src/Titlebar.cpp:87` | legacy lights table (fill / ring / glyph / glow) | #6EC341 110,195,65 | 130 | #4AC61D 74,198,29 | -36,+3,-36 | 3.8 | 17.0 | windows/lights-*.png (same numbers as Tokens.lights) |
|  |  | #62BD2D 98,189,45 | 144 | #35C000 53,192,0 | -45,+3,-45 | 3.6 | 15.7 |  |
|  |  | #6DC04B 109,192,75 | 117 | #4AC333 74,195,51 | -35,+3,-24 | 3.7 | 15.5 |  |
|  |  | #BFF69A 191,246,154 | 92 | #AFF88E 175,248,142 | -16,+2,-12 | 2.9 | 9.4 |  |
|  |  | #59B61C 89,182,28 | 154 | #23B900 35,185,0 | -54,+3,-28 | 3.6 | 13.6 |  |
|  |  | #B8F697 184,246,151 | 95 | #A6F88B 166,248,139 | -18,+2,-12 | 2.9 | 9.8 |  |
|  |  | #005500 0,85,0 | 85 | #005700 0,87,0 | +0,+2,+0 | 0.6 | 1.1 |  |

**Owner `finder/`**

| file:line | token | current | sat | converted (new value) | Δ R,G,B | ΔE00 | ΔE76 | source (P3 raw) |
|---|---|---|---|---|---|---|---|---|
| `finder/qml/Theme.qml:104` | textSelection (rename field) | #BAD6FB 186,214,251 | 65 | #B3D7FF 179,215,255 | -7,+1,+4 | 2.1 | 2.7 | Q-finder-27 (186,214,251), finder crops (raw) |
| `finder/qml/Theme.qml:119` | sidebarDrop | #2F6EED 47,110,237 | 190 | #0070F5 0,112,245 | -47,+2,+8 | 1.9 | 3.9 | Q-finder-09 (47,110,237) |
| `finder/qml/Theme.qml:124` | sidebarIconAccent dark / light | #1E98FF 30,152,255 | 225 | #009BFF 0,155,255 | -30,+3,+0 | 1.6 | 3.0 | Q-finder-08 (30,152,255) / (0,107,239) |
|  |  | #006BEF 0,107,239 | 239 | #006DF8 0,109,248 | +0,+2,+9 | 1.3 | 4.0 |  |
| `finder/qml/Theme.qml:164` | labelSelection dark / light | #2558C9 37,88,201 | 164 | #0259D0 2,89,208 | -35,+1,+7 | 1.5 | 3.8 | Q-finder-13 (37,88,201) / (42,99,217) |
|  |  | #2A63D9 42,99,217 | 175 | #0165E1 1,101,225 | -41,+2,+8 | 1.8 | 3.9 |  |
| `finder/qml/Theme.qml:166` | listSelection dark / light | #2457C9 36,87,201 | 165 | #0158D0 1,88,208 | -35,+1,+7 | 1.5 | 3.7 | Q-finder-16/19 (36,87,201) / (42,98,217) |
|  |  | #2A62D9 42,98,217 | 175 | #0364E1 3,100,225 | -39,+2,+8 | 1.8 | 3.8 |  |
| `finder/qml/Theme.qml:169` | selectedSecondaryText | #BFD0F4 191,208,244 | 53 | #BBD1F7 187,209,247 | -4,+1,+3 | 1.7 | 1.8 | Q-finder-16 (191,208,244) |
| `finder/qml/Theme.qml:185` | folderBack / Front / Top | #5FA9DA 95,169,218 | 123 | #40ABDF 64,171,223 | -31,+2,+5 | 3.2 | 5.7 | "ref" = live folder crops (icons-live, tagged Display) |
| `finder/qml/Theme.qml:186` | folderBack / Front / Top | #71B9E4 113,185,228 | 115 | #56BBE8 86,187,232 | -27,+2,+4 | 3.2 | 5.9 | "ref" = live folder crops (icons-live, tagged Display) |
| `finder/qml/Theme.qml:187` | folderBack / Front / Top | #81C6EE 129,198,238 | 109 | #69C8F2 105,200,242 | -24,+2,+4 | 3.1 | 5.8 | "ref" = live folder crops (icons-live, tagged Display) |
| `finder/qml/Theme.qml:192` | focusEdge | #729EF4 114,158,244 | 130 | #65A0FB 101,160,251 | -13,+2,+7 | 2.4 | 3.8 | Q-finder-27 (114,158,244) |

**Owner `settings/`**

| file:line | token | current | sat | converted (new value) | Δ R,G,B | ΔE00 | ΔE76 | source (P3 raw) |
|---|---|---|---|---|---|---|---|---|
| `settings/panes/Appearance.qml:421` | icon style tiles Default / Tinted | #3C88F5 60,136,245 | 185 | #008AFD 0,138,253 | -60,+2,+8 | 2.7 | 4.7 | settings/appearance-*.png (untagged crop, raw), MAC-ANSWERS:2077,2081 |
|  |  | #3478F1 52,120,241 | 189 | #007AF9 0,122,249 | -52,+2,+8 | 2.2 | 4.2 |  |
| `settings/panes/Appearance.qml:440` | icon style tile sun | #F9C416 249,196,22 | 227 | #FFC100 255,193,0 | +6,-3,-22 | 2.2 | 4.7 | "sampled" on settings/appearance-light.png (untagged, raw) |
|  |  | #EDB609 237,182,9 | 228 | #F7B300 247,179,0 | +10,-3,-9 | 3.3 | 6.0 |  |
|  |  | #96DEFF 150,222,255 | 105 | #7EE0FF 126,224,255 | -24,+2,+0 | 3.7 | 6.6 |  |

**Owner `themes/`**

| file:line | token | current | sat | converted (new value) | Δ R,G,B | ΔE00 | ΔE76 | source (P3 raw) |
|---|---|---|---|---|---|---|---|---|
| `themes/gtk/build.py:35` | CHROME light tl_*_down, glyph_* | #FFAC9E 255,172,158 | 97 | #FFA79A 255,167,154 | +0,-5,-4 | 1.3 | 2.5 | Q-windows-08/10, windows/lights-press-*-light.png |
|  |  | #FFFF70 255,255,112 | 143 | #FFFF50 255,255,80 | +0,+0,-32 | 2.9 | 12.4 |  |
|  |  | #C6FF8F 198,255,143 | 112 | #B6FF7F 182,255,127 | -16,+0,-16 | 2.6 | 9.5 |  |
| `themes/gtk/build.py:36` | CHROME light tl_*_down, glyph_* | #9E0000 158,0,0 | 158 | #AD0000 173,0,0 | +15,+0,+0 | 3.0 | 6.3 | Q-windows-08/10, windows/lights-press-*-light.png |
|  |  | #BE4900 190,73,0 | 190 | #CE3E00 206,62,0 | +16,-11,+0 | 4.3 | 10.5 |  |
|  |  | #097900 9,121,0 | 121 | #007B00 0,123,0 | -9,+2,+0 | 0.7 | 1.6 |  |
| `themes/gtk/build.py:39` | CHROME dark tl_*_down, glyph_* | #FF7C68 255,124,104 | 151 | #FF7260 255,114,96 | +0,-10,-8 | 2.1 | 5.0 | Q-windows-08/10, windows/lights-press-*-dark.png |
|  |  | #FFFF58 255,255,88 | 167 | #FFFF18 255,255,24 | +0,+0,-64 | 3.4 | 16.4 |  |
|  |  | #56F66E 86,246,110 | 160 | #00FA58 0,250,88 (CoreUI value, see unclear) | -86,+4,-22 | 2.9 | 15.1 |  |
| `themes/gtk/build.py:40` | CHROME dark tl_*_down, glyph_* | #850000 133,0,0 | 133 | #920000 146,0,0 | +13,+0,+0 | 2.6 | 5.9 | Q-windows-08/10, windows/lights-press-*-dark.png |
|  |  | #AA3600 170,54,0 | 170 | #B92800 185,40,0 | +15,-14,+0 | 4.0 | 10.3 |  |
|  |  | #005500 0,85,0 | 85 | #005700 0,87,0 | +0,+2,+0 | 0.6 | 1.1 |  |

Notes on these tables:

- `ui/HyprK/Tokens.qml:236-249` and `plugin/src/Titlebar.cpp:79-87` are the same legacy numbers. The discs
  themselves are drawn from the glass model (3.2); from these tables the **glyph** colours are still drawn
  (`Titlebar.cpp:243`, `TrafficLights.qml:114-115`) and `fill[0]` feeds the Appearance pane swatches
  (`settings/Theme.qml:95-97`). `plugin/src/Titlebar.cpp` rows were scanned before d104e6d; that commit changed the
  glass table only, lines 79-87 still hold the raw values.
- `#56F66E` (dark zoom pressed) is quoted as "CoreUI's" value, not a shot reading: see 3.6.
- `Tokens.qml:183` becomes exactly #007AFF, which is `t.accent` under Multicolour and Blue: the special case can go.
- `finder/qml/Theme.qml:164,166` become #0165E1 / #0259D0 and #0364E1 / #0158D0, i.e. `Accent.selectedContent`
  (#0064E1 / #0059D1) within 3 levels: the Blue special case can go too. `:104` becomes #B3D7FF = `Accent.selectedText`.

Convert items the scan did not list (written as `n / 255` or as a derived rule):

| file:line | token | current | converted | ΔE00 | source |
|---|---|---|---|---|---|
| `finder/qml/GalleryView.qml:211` | "Add Tag" link | 53,120,246 | 4,122,255 (= accent #007AFF) | 2.1 | Q-finder gallery crop |
| `finder/qml/InfoRows.qml:34` | "Show More" link dark / light | 89,152,245 / 46,104,211 | 64,154,252 / 8,106,218 (catalog link #419CFF / #0068DA, MAC-ANSWERS:487) | 2.9 / 2.1 | Q-finder info crop |
| `finder/src/sysicons.cpp:34-35` | `tintFolder` gains (ref colour / PNG colour 122,211,251) | top 1.06, 0.94, 0.95; bottom 0.86, 0.84, 0.89 | top 0.86, 0.95, 0.96; bottom 0.62, 0.85, 0.91 (ref top 129,198,238 → 105,200,242; bottom 105,178,224 → 76,180,229) | 3.2 | live folder crops (`live/finder/icons-live`, tagged Display); assumes the PNG folder is sRGB |
| `finder/src/sysicons.cpp:12,16` | `tagFolder` rule from the orange folder 236,151,80 | saturation 0.66, value 0.93, hue − 7° | orange is 250,146,61: saturation 0.76, value 0.98, hue 27° (was 27.3°, so − 8°) | 3.4 | MAC-ANSWERS Q-finder-14/31 |

### 3.2 Refit (models)

| file:line | what | state |
|---|---|---|
| `plugin/tools/lights_model.py` TABLE, `plugin/src/Titlebar.cpp` GLASS (line 108 on) | traffic-light glass model, fitted on `windows/lights-*.png` | **done** in d104e6d: the tool now converts each crop through its profile before the fit. On screen, dark rest, vs the converted crop: rms 12.7 / 19.3 / 38.0 → 3.0 / 4.0 / 8.9 levels (close / minimise / zoom). That is the size of the error everywhere else in this list. |
| `ui/HyprK/TrafficLights.qml:30-37` | the same table for QML title bars (Settings, Finder) | **open**: still the raw-P3 fit (dark close T 234,121,110; new 252,113,105). Paste `lights_model.py emit`. |
| `finder/src/sysicons.cpp:12,34-35` | folder tint gains and tag rule | open, numbers in the table above |

### 3.3 Already sRGB (no change)

| Where | What | Why it is sRGB |
|---|---|---|
| `ui/HyprK/Accent.qml` (78 colours) | accent, selection, highlight, focus ring per accent; systemBlue #0088FF / #0091FF; swatches | `live/accent-colors.json`: "resolved … and converted to sRGB 0..255"; `multicolor-*-swatch.png` carry the sRGB chunk. Confirmed by the shots (section 1.3) |
| `ui/HyprK/Tokens.qml:48-70` control fills | switch, slider, checkbox, default button | composed from `Accent.color` plus black / white overlays; shot 51,117,240 → 2,119,248 against ours 0,119,249 (7ee8a39) |
| `ui/HyprK/shaders/iconart.frag:117-121`, `ui/HyprK/AppIconTile.qml:24,107`, `themes/icons/tools/build-styles.py:43-64`, `build-trash.py:34` | tint #007AFF, tinted tile 0,109,195, 0,122,249, white point 24,131,246, ramps | fitted with `themes/icons/tools/check-styles.py:31-37`, which converts the Dock shots through the profile first. Checked: the tile reads 0,107,189 raw in `glass53/dock-dark-white-iconstyles-*.png` and 0,109,195 converted |
| `shell/Theme.qml:191-192,416`, `settings/Theme.qml:192-194`, `finder/qml/Theme.qml:196-198`, `themes/gtk/build.py:65,76`, `lockscreen/assets/gen-status-icons.py:42` | systemRed / Orange / Yellow / Green / Indigo …, Finder tags, pane tile palette | documented system colour values, not read from our shots. Not checked against the 27 palette (R5 says 27 moved systemBlue to #0088FF and red to #FF383C; that is a separate question from P3) |
| `shell/components/BatteryIcon.qml:23` #FF383C | low battery fill | from Apple's bitmap; equals the 27 catalog red (MAC-ANSWERS:508) |
| `themes/palette.py:5,11` accent #007AFF | GTK / Qt accent | accent-colors.json |
| `plugin/src/Material.cpp`, `plugin/shaders/liquidglass.frag`, `shell/shaders/menupill.frag` | glass recipes, colour matrices, luma weights | decoded from Apple's code, or fitted on grey backdrops; see 4.1 for the one caveat |

### 3.4 Not from shots, generated

- Hand-picked, no Mac source: `lockscreen/hyprlock.conf:85-91`, `shell/modules/Background.qml:17`,
  `shell/modules/MissionControl.qml:93`, `shell/scripts/wallpaper.sh:37`, `shell/modules/lock/LockTheme.qml:23`,
  `settings/panes/Displays.qml:163`, `settings/panes/accessibility/*` tints, `themes/cursors/theme/free_cursors.py`,
  `themes/qt/build.py:15-29` (hover / press / selection derived from #007AFF by hand), `config/hypr/shaders/a11y-filter.frag:22`.
- `themes/palette.py:7,13` `tl_close #FF5F57`, `tl_min #FEBC2E`, `tl_max #28C840`: the long-known values, not from our
  shots, so nothing to convert. For the record they sit closer to the converted 27.2.1 discs (light close centre
  251,112,103, minimise 253,193,44, zoom 112,209,68) than the raw fits did.
- Generated, rebuild after their source changes: `themes/gtk/**/gtk*.css` (from `themes/gtk/build.py`),
  `themes/qt/colors/*.conf`, `themes/qt/kvantum/**` (from `themes/qt/build.py`).

### 3.5 Neutral: no change

About 1,920 literals are grey or move by at most 1 level. Examples that look tinted but are safe: Finder sidebar
`#242637` (36,38,55 → 36,38,56), dark window `(31,31,37)`, alert fill `#38383F`, title bar inks.

Lock screen (`shell/modules/lock/LockTheme.qml:32-103`, 13 `*Lift` vectors): additive lifts read from the P3
screenshots (LOCKSCREEN-27.2.1.md says so). Recomputed with backdrop and result both converted:

| Lift | P3 backdrop → result | lift in P3 | lift in sRGB |
|---|---|---|---|
| clock, dark | 39,27,167 → 128,107,255 | +89, +80, +88 (clipped) | +91, +80, +81 (clipped) |
| clock, light | 169,178,192 → 250,255,255 | +81, +77, +63 (clipped) | +82, +77, +62 (clipped) |
| date, dark | 20,5,124 → 147,131,250 | +127, +126, +126 | +128, +126, +126 |
| date, light | 135,174,207 → 212,254,253 | +77, +80, +46 | +77, +80, +43 |

The lifts are the same within 2 levels, so the constants stay. Label inks: 147,165,250 → 143,166,255 and
146,182,255 → 136,183,255 are results over the wallpaper, not constants. What does change on the lock screen is the
wallpaper under them (3.6).

### 3.6 Unclear

| Item | Question | What settles it |
|---|---|---|
| Wallpapers: `themes/wallpapers/png/*.png` (9 tagged "Display P3", 1 QuickTime nclc, 8 untagged), `heic/*` | `shell/scripts/wallpaper.sh:46` resizes with `magick` and keeps the profile; Qt Quick and Hyprland do not apply embedded profiles, so the P3 numbers are most likely shown as sRGB (less saturated than the Mac). This is the largest coloured area on screen. Not run here. | Read one pixel of the cached wallpaper and of a screenshot of the desktop: if both equal the file's raw value, add `-profile sRGB.icc` (or `-colorspace sRGB` after reading the profile) to the import. Then every "ours over Tahoe vs Mac over Tahoe" comparison must convert the Mac shot too. |
| `ui/HyprK/Tokens.qml:234,247`, `themes/gtk/build.py:39` `#56F66E` | "CoreUI's" pressed zoom colour: which colour space does CoreUI state it in? | the CoreUI colour record (COLR colour-space id, as `themes/icons/tools/iconstack.py:25` reads it) |
| `finder/qml/DragSession.qml:143` `#FF3B30` | documented systemRed; the Mac badge measured 231,74,64 raw = 251,55,53 sRGB (MAC-ANSWERS:2283), nearer to 27's #FF383C | pick the measured value or the catalog red |
| `settings/panes/Appearance.qml:60-69` thumbnail gradient `#8DB6F2 → #3D6BD8`, bars `#2E57D6` / `#3F7BF0` | placeholder art without a stated source; if it was eyeballed from `settings/appearance-light.png` it is raw P3 | the author; low impact (seen only until the wallpaper thumbnail loads) |
| `themes/icons/apps/*.png` (591, untagged) | built from Icon Composer layers by `iconstack.py`, which converts Display P3 fills with its own matrix (line 61) and has a mode that uses sRGB-tagged components as P3 (lines 66-70); files are being rebuilt in the working tree now | the icon owner's `check-styles.py` rms after the rebuild (it compares in sRGB) |
| Folder PNGs tinted by `sysicons.cpp` | the new gains assume the bundled folder PNG (122,211,251) is sRGB | the PNG's origin (27.2 IPSW asset: check its profile at extraction) |

## 4. Measurement claims that compared our sRGB with raw P3

### 4.1 Device-value backdrops: the match holds

The Mac backdrop was given in the screen's own space and reads back unchanged (1.2), ours was the same numbers in
sRGB, and the glass result was compared number for number. Same numbers in, same numbers out on both sides: these
claims stand as statements about the transfer function, and no constant was tuned to a wrong target.

| Claim | Where | After converting both Mac values |
|---|---|---|
| CC tile over blue 69,83,206: ours 64,80,212, Mac 64,80,212 | `reference/ours/glass/REFRACTION.md:38,96` | Mac is really 65,84,214 → 60,81,220: the same shift (−5, −3, +6). Holds |
| HUD over blue: 68,85,232, Mac 68,85,232 | `REFRACTION.md:39,156`, `plugin/src/Material.cpp:73`, `shell/services/Hud.qml:36` | 65,84,214 → 63,86,241 (−2, +2, +27 against −1, +2, +26). Holds |
| glass gap over blue 62,75,185 | `REFRACTION.md:97` | → 59,75,192. Holds |
| menu bar pill: blue → 90,105,231, Mac 90,105,230 | `shell/shaders/menupill.frag:6`, `reference/re/MENUBAR-REA-27.2.1.md:69`, MAC-ANSWERS:30,1670,1677 | MAC-ANSWERS:1670 already gives the sRGB pair (85,105,237 vs 65,84,214). Holds |
| Dock over red / green / blue: 248,38,20 / 59,197,16 / 59,75,216; Cmd-Tab the same | MAC-ANSWERS:1493-1494,1570 | holds as numbers. Device red and green (255,0,0 / 0,255,0 in P3) are outside sRGB, so ours over sRGB red is a different stimulus: only the numeric match can be claimed |
| sidebar glass over 69,83,206 / 0,255,0 / 230,140,40 | `verify/C3/sidebar-*`, MAC-ANSWERS verify C3 | same |
| judge backdrops "blue 69,83,206" | `reference/JUDGE-95.md:8`, `-2.md:15`, `-3.md:15` | same |
| Mission Control band tint, rms 4.4-5.6 over Tahoe | `shell/modules/MissionControl.qml:74` | holds as numbers if our wallpaper is shown unconverted (3.6); scalar contrast / brightness / saturation, so it survives a converted wallpaper within the stated rms |
| lock clock +90/+79/+90 (Mac +89/+80/+88), date +133 (Mac +127) over grey 114 | `reference/JUDGE-95-3.md:45`, `-4.md:49` | grey backdrop, lifts unchanged within 2 levels (3.5). Holds |

Caveat for all of them: the recipes' saturation terms use luma weights on the stored channels, which are P3
primaries on the Mac and sRGB primaries here. At the saturation of 69,83,206 the difference is under 1 to 2 levels
(the table above); it was never measured on strongly saturated content.

### 4.2 Backdrop given in sRGB on the Mac, read in P3 from the shot

Here both the backdrop and the result must be converted before a comparison (or ours must be fed the raw backdrop
72,83,199 and compared raw).

| Mac numbers | Where | Note |
|---|---|---|
| NC cards over "blue": 71,80,184; 161,169,255; 55,63,152; 20,27,103; 85,97,226; 157,167,255; 79,89,200; 151,158,244; 52,59,142 | MAC-ANSWERS:2952-3036, `nc/INDEX.md:12`, probe `ncbg.swift:30` | the section says so itself ("blue sRGB (69,83,206) … reads as (72,83,199) in display RGB"). In sRGB the card 71,80,184 is 69,80,191 over 69,83,206 |
| menu probe colour bars (sRGB 0.85, 0.25, 0.2), glass tints of `glassfit.swift:244` | `verify/B2/menu-item-highlight-*colour-backdrop*`, verify C `tint-*` shots | same rule |

No document or test of ours quotes an "ours vs Mac" number over that blue (searched `reference/ours/**`, `plugin/`,
`shell/`, judge docs); the NC recipe checks in `plugin/tools/check_model.py:160-171` are grey. So nothing is known to
be mistuned here; the rule matters for the next measurement.

### 4.3 Tuned to the wrong thing

| Claim | Where | What is true |
|---|---|---|
| "Close light hover disc 234,133,123 vs 233,127,117, glyph 158,0,0 vs 160,0,0" | `reference/JUDGE-95-2.md:41` | the Mac values are raw P3: really 249,120,112 and 175,0,0. Ours is off by −15, +13, +11 and −17 on the glyph red |
| "Traffic lights within 16 levels", "close hover centre Mac (160,0,0)" | `reference/JUDGE-95.md:32,72` | measured against raw crops; against converted crops the plugin read rms 12.7 / 19.3 / 38.0 before its refit |
| fit residuals of the lights model, and the hex lists Q-windows-08/10 | `reference/ours/windows/LIGHTS.md` (first part), `plugin/tools/lights_model.py:71-`, MAC-ANSWERS:862-880, `plugin/README.md:343` | raw-P3 targets; LIGHTS.md has the sRGB refit appended by d104e6d. The Q-windows hexes stay valid as P3 readings but are labelled sRGB (MAC-ANSWERS:821) |
| Finder folder "(114,187,229) vs ref (113,185,227)", "(112,185,229) vs ref (113,185,228)" | `reference/JUDGE-r2.md:17`, `reference/JUDGE.md:19,62`, `PROGRESS.md:36,69` | the ref is raw P3: really 86,187,231. Our folder red channel is about 27 levels too high (too pale, less blue-saturated) |
| Finder selection, sidebar accent, rename selection, drop pill, focus edge "match Q-finder" | `finder/qml/Theme.qml:104-192` against MAC-ANSWERS:2138-2285 | Q-finder numbers are raw P3 with an sRGB label; the constants copy them (3.1) |
| alert default button (52,120,246), destructive text (220,57,41) | `ui/HyprK/Tokens.qml:180-183` against MAC-ANSWERS:2715-2719 | raw P3 of #007AFF and of 240,29,20 |
| icon style tiles #3C88F5 / #3478F1 | `settings/panes/Appearance.qml:421` against MAC-ANSWERS:2077-2081 | raw P3 of 0,138,253 (systemBlue #0088FF within 2) and 0,122,249 (the tinted tile the icon tools already use) |

### 4.4 False gaps (ours was right, the Mac number was raw)

- Slider fill "(0,119,249) vs the shot's (51,117,240)" (judge #4): 51,117,240 is 2,119,248. Settled in 7ee8a39.
- Switch on "#3374EF / #397AF6" (MAC-ANSWERS:1941,2893-2896): 4,118,247 / 19,124,255; ours is composed from #007AFF
  the same way AppKit does. No gap.
- Accent glyphs, menu highlight, Add-Tag link "(52,120,246)" (MAC-ANSWERS:1725,1974,2349,2842): #007AFF. No gap where
  the code uses `Accent.color`.
- Dock badge red 228,84,69 (MAC-ANSWERS:1555) is 247,69,59: supports `shell/Theme.qml:191` #FF453A.

### 4.5 Judge montages

`reference/judge-95*/*.png` (39 files, untagged) paste raw-P3 Mac crops next to our sRGB captures. Greys, geometry
and alpha read correctly. Any by-eye verdict on hue or saturation from them is biased: the Mac half looks less
saturated than the Mac is (accent blue, traffic lights, folders, tinted icons, wallpaper). Scores in the "colour"
rows of `reference/JUDGE-95*.md` that rest on saturated colours should be re-read from converted crops.

Not affected: motion (`reference/ours/motion/*`: timing and alpha from luminance ratios), shadows
(`reference/ours/windows/SHADOW.md`: black with alpha), refraction geometry, rim rows over grey / white / black, icon
style rms (`check-styles.py` converts first), all lock and video timing. Video colours (`lock/field-*.png`,
`lock/full-*-1x.png`, strips) are H.264 limited-range frames decoded without a colour tag: approximate, as
LOCKSCREEN-27.2.1.md:14 says, and unknown in space; nothing saturated was fitted to them.

## 5. Ranking and per-owner list

Impact = ΔE00 × how much of the time the colour is on screen (5 always, 4 in every window of an app, 1.5 on a
state, under 1 rare). ΔE76 is given too because reds and oranges move far more there (11 to 17).

| # | Impact | Owner | file:line | Token | Old → new | ΔE00 / ΔE76 |
|---|---|---|---|---|---|---|
| 0 | check first | shell | `shell/scripts/wallpaper.sh:46` | wallpaper import (P3-tagged files) | unconverted → convert to sRGB at import (3.6) | whole desktop |
| 1 | 21 | ui | `ui/HyprK/TrafficLights.qml:30-37` | lights glass table (QML title bars) | raw-P3 fit → `lights_model.py emit` of d104e6d (dark close T 234,121,110 → 252,113,105; light zoom M 136,207,90 → 112,209,68) | 3.3-4.3 / 11-15; rms 13-38 levels |
| 2 | 21 | ui | `ui/HyprK/Tokens.qml:243` | lights.minimise light fill | #F2BD50 #F5CB59 #F8D562 → #FCBA31 #FDC93C #FFD347 | 3.5 / 13 |
| 3 | 20 | ui | `ui/HyprK/Tokens.qml:241` | lights.minimise dark fill | #F1B835 #F3C22D #F6CF50 → #FCB500 #FCC000 #FECD28 | 3.5 / 15 |
| 4 | 19 | ui | `ui/HyprK/Tokens.qml:246` | lights.zoom dark fill | #6EC341 #62BD2D #6DC04B → #4AC61D #35C000 #4AC333 | 3.8 / 14 |
| 5 | 18 | ui | `ui/HyprK/Tokens.qml:238` | lights.close light fill | #ED786B #EA857B #E89189 → #FE6F65 #FA7E77 #F68C86 | 3.2 / 11 |
| 6 | 18 | ui | `ui/HyprK/Tokens.qml:248` | lights.zoom light fill | #7DCD4A #98D46F #A9DA86 → #5FD02A #86D660 #9BDC7B | 3.6 / 13 |
| 7 | 17 | ui | `ui/HyprK/Tokens.qml:236` | lights.close dark fill | #E87061 #E1675B #DE6F64 → #FA675A #F25D54 #EE675E | 3.3 / 12 |
| 8 | 16 | plugin, ui, themes | `plugin/src/Titlebar.cpp:79-87` (glyph field), `ui/HyprK/Tokens.qml:236-249` glyph, `themes/gtk/build.py:36,40` | hover glyphs close / minimise / zoom | light #9E0000 #BE4900 #097900 → #AD0000 #CE3E00 #007B00; dark #850000 #AA3600 #005500 → #920000 #B92800 #005700; pressed light #D40000 #FF6500 #15A400 → #E80000 #FF5600 #00A700; pressed dark #B60000 #E74F00 → #C70000 #FB3E00 | 3.0-4.5 / 9-17 |
| 9 | 13 | finder | `finder/src/sysicons.cpp:34-35` | folder tint gains | top 1.06, 0.94, 0.95 → 0.86, 0.95, 0.96; bottom 0.86, 0.84, 0.89 → 0.62, 0.85, 0.91 | 3.2 / 5.7 |
| 10 | 9.6 | finder | `finder/qml/Theme.qml:185-187` | folderBack / Front / Top | #5FA9DA #71B9E4 #81C6EE → #40ABDF #56BBE8 #69C8F2 | 3.2 / 5.7 |
| 11 | 8.4 | ui | `ui/HyprK/Tokens.qml:183` | panel.defaultFill | #3478F6 → #007AFF (= `t.accent`) | 2.1 / 4.5 |
| 12 | 7.2 | finder | `finder/qml/Theme.qml:164,166` | labelSelection, listSelection | light #2A63D9 / #2A62D9 → #0064E1; dark #2558C9 / #2457C9 → #0059D1 (= `Accent.selectedContent`) | 1.8, 1.5 / 3.6 |
| 13 | 6.4 | finder | `finder/qml/Theme.qml:124` | sidebarIconAccent | dark #1E98FF → #009BFF; light #006BEF → #006DF8 | 1.6, 1.3 / 3.5 |
| 14 | 6.4 | themes | `themes/gtk/build.py:35,39` | tl_*_down (GTK pressed discs) | light #FFAC9E #FFFF70 #C6FF8F → #FFA79A #FFFF50 #B6FF7F; dark #FF7C68 #FFFF58 → #FF7260 #FFFF18 | 1.3-3.4 / 4-17 |
| 15 | 5.7 | ui | `ui/HyprK/Tokens.qml:181` | panel.destructiveText | dark #DC3929 → #F01D14; light #EB4C46 → #FF393C | 3.8, 3.3 / 17, 14 |
| 16 | 5-7 | ui | `ui/HyprK/Tokens.qml:237,239,242,244,249` | lights pressed fills, rings, glows | see 3.1 (e.g. #FF9A8B → #FF9486, #FFF66C → #FFF64C, #A0FF60 → #7DFF3A, ring #F42319 → #FF0000, #D04020 → #E22E00, #347F20 → #008100) | 1.0-4.0 |
| 17 | 4.1 | settings | `settings/panes/Appearance.qml:421` | icon style tiles Default / Tinted | #3C88F5 → #008AFD; #3478F1 → #007AF9 | 2.7, 2.2 / 4.6 |
| 18 | 3.7 | settings | `settings/panes/Appearance.qml:440` | icon style tile sun | #F9C416 → #FFC100; #EDB609 → #F7B300; #96DEFF → #7EE0FF | 2.2-3.7 / 6-9 |
| 19 | 3.4 | ui | `ui/HyprK/Tokens.qml:180` | panel.destructiveFill | dark #653F43 → #6B3D42; light #F9D1D0 → #FFCFCF | 2.3, 2.2 / 3.8 |
| 20 | 3.2 | finder | `finder/qml/Theme.qml:104` | textSelection (rename) | #BAD6FB → #B3D7FF (= `Accent.selectedText`) | 2.1 / 3.5 |
| 21 | 2-3 | finder | `finder/qml/InfoRows.qml:34`, `Theme.qml:169,119,192`, `GalleryView.qml:211`, `sysicons.cpp:12,16` | link, selectedSecondaryText, sidebarDrop, focusEdge, Add Tag, tag folder rule | 89,152,245 → 64,154,252 and 46,104,211 → 8,106,218; #BFD0F4 → #BBD1F7; #2F6EED → #0070F5; #729EF4 → #65A0FB; 53,120,246 → accent; s 0.66 v 0.93 → s 0.76 v 0.98 | 1.7-3.4 |

Per owner:

- **`ui/`**: `TrafficLights.qml:30-37` (paste the emitted table); `Tokens.qml:236-249` all fills, rings, glyphs and
  glows (3.1 has every value; `#56F66E` pending 3.6); `Tokens.qml:180,181,183`. Nothing in `Accent.qml`, the control
  fills, `iconart.frag` or `AppIconTile.qml`.
- **`plugin/`**: glass table done (d104e6d). Left: the `glyph` field (and the unused fill / ring / glow) of
  `Titlebar.cpp:79-87`; the `rest`/`press` residual notes in `lights_model.py`; README:343 hexes are history.
- **`finder/`**: `Theme.qml:104,119,124,164,166,169,185-187,192`; `InfoRows.qml:34`; `GalleryView.qml:211`;
  `src/sysicons.cpp:12,16,34-35` (refit) and the comments in `sysicons.h:9-10`; decide `DragSession.qml:143`.
- **`settings/`**: `panes/Appearance.qml:421,440`; say where `:60-69` came from. `Theme.qml:95-97` follows `Tokens.lights`.
- **`themes/`**: `gtk/build.py:35-36,39-40`, then rebuild the GTK CSS. Icon tools: nothing (already sRGB).
  `palette.py` tl_* and `qt/build.py`: nothing.
- **`shell/`**: no constant. Check the wallpaper import (3.6). Lock lifts stay.
- **`config/hypr/`**: nothing.
- **reference / judges**: read Mac shots through one helper that converts (section 2) and say "sRGB" or "P3 raw"
  next to every quoted colour; fix the labels at MAC-ANSWERS:821 and :2089.

## 6. Not covered

- Nothing was rendered: no "after" screenshots, no ΔE measured on screen. The new values are the conversion of the
  stored constants, not a re-read of the crops; where a constant was an average or an un-premultiplied value, a
  re-read of the converted crop can differ by 1 to 2 levels.
- Whether the user's display is exactly sRGB was taken as given.
- Whether Apple's glass filters run on P3-encoded or extended-sRGB values in the WindowServer was not determined;
  4.1 treats the measured device-value transfer as the target, which is what the recipes were verified against.
- The 27 system palette against the documented colours in `shell/Theme.qml`, `settings/Theme.qml:192-194` and
  `finder/qml/Theme.qml:196-198` (R5 hints that 27 changed several) is a different question and was not audited.
- Colour numbers inside commit messages were not listed.
