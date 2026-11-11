# Colour audit: the Mac shots are Display P3 (work in progress)

Status: sections 1 and 2 are final. The inventory (3), the affected measurement claims (4) and the ranking (5)
are being filled in; each update is its own commit of this file. Read-only audit: no code was changed.

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
"display RGB", Q-finder says "Colours are sRGB from 2x window captures" (checked in section 3: its crops are tagged
Display and the quoted numbers equal the raw pixels, so that label is wrong). Provenance is settled per constant below.

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
