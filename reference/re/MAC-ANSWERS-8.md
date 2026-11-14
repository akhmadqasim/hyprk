# Mac REA round 8: macOS 27.2.1 (26B131), MacBook Air M2

Probe: `reference/re/tools/probe/glassr8.swift`. It opens a SwiftUI and AppKit window in its own process and makes no system changes. It shows a wide capsule and a wide rounded rect (SwiftUI `.glassEffect` and `NSGlassEffectView`), a SwiftUI `Slider` on a white fill and one on grey. It dumps every layer with all ObjC properties of the private CA classes and every CAFilter input. It captures the window (`screencapture -l`) and then changes `gradientOvalization` live (0, then 1) to test the cause. The knob is held with an in-process synthetic mouse-down (`NSWindow.sendEvent`). Dark and light, backdrop grey 128.

## R8.1 Rim highlight brighter at the centre of the top / bottom rim: done

**Cause: `CASDFElementLayer.gradientOvalization`.** It is not a CAFilter input, a texture or a normal map. It is a property of the SDF element layer under `CABackdropLayer "@0" > CASDFLayer "@0"`. That layer is the shape that `glassBackground` and the key/fill highlight layer (`CASDFLayer "@2"`, through an `SDFPortalLayer`) both read. With ovalization > 0, the SDF gradient (the edge normal) is bent toward a radial direction from the shape centre. On a flat top or bottom edge the normal then tilts sideways toward the ends. The key/fill highlight lobe `lobe(dot(n, keyDir), spread)` falls off with that tilt, so the rim is brightest at x = centre and fades smoothly toward the ends.

- **Shader** (QuartzCore `default.metallib`, uber shader `fixed_frag_lpf_cpf`, `CA::OGL::Metal::ShaderUtils_<float>::supercircle_sdf_image<true>`):
  ```
  r = normalize(p.x, p.y * a/b)              // p from the shape centre, a/b = arg.x/arg.y = W/H
  n = normalize(mix(sdf_gradient, r, arg.w)) // arg.w = gradientOvalization
  n = tr * n                                 // 2x2 layer transform
  ```
  The result goes to `sdf_key_fill_highlight` / `sdf_diffuse_kf_highlight` (key/fill mask, see MAC-ANSWERS verify B) and to `glassBackground` (same SDF source "@0"). IR excerpt: `27.2.1/decomp/QuartzCore-metallib-supercircle-sdf-ovalization.ll`.
- **Which shapes get it** (SwiftUI and AppKit glass alike, dark = light):
  - **0.5 when min(W, H) > 64 pt.**
  - **0 when min(W, H) ≤ 64 pt.**
  - Measured: 300×64 → 0, 300×65 → 0.5, 64×64 → 0, 65×65 → 0.5, 64×300 → 0. Also 0.5 for 520×87 r22, 500×90 r24, 300×100 at r 0 / 12 / 50, 640×260 r24 and 600×260 r24. Capsules 640×56 / 600×56, circle 56, `.clear` 300×56 and `.interactive()` 300×56 all get 0.
  - The Spotlight bar (≈87 pt tall) and the results panel are above 64 pt, so they get 0.5. Small controls and the ≤ 64 pt capsules have a flat rim.
  - Data: `log-dark-sweep.json`, `log-*.json`.
- **Highlight inputs at runtime** (`CASDFKeyFillHighlightEffect`, the full dump is in `tree-*.json`):
  - keyAngle 0 (top), fillAngle π (bottom). keyAmount = fillAmount 0.5. keyHeight = fillHeight 1. curvature 0.75.
  - diffuseHeightScale 8, diffuseSpreadScale 0.65, diffuseAmountScale 0.15.
  - Spread: **80° (1.396) for the ≤ 64 pt shapes, 90° (π/2) for the large ones**.
  - All `*Scale` = 1, all `*Offset` = 0, global false.
  - Layer filter: `vibrantColorMatrix`. Dark: rows (1.1202 −0.1894 −0.019 | 0.1471)…
- **Causal test** (dark, grey 128, 640×260 r24 SwiftUI, first pixel row of the top rim, x = 40 pt from the ends):

  | ovalization | centre | ends |
  |---|---|---|
  | 0.5 (stock) | 157 | 144 |
  | 0 | 157 | 157 (flat) |
  | 1 | 157 | 132 |

  - Bottom rim (fill): 155 / 142 at 0.5, flat 155 at 0.
  - Capsule 640×56: stock (0) flat 172. Forced to 1: 172 at the centre → 149 at the ends.
- **Model fit** (`rim_fit.py`): highlight mask × `vibrantColorMatrix`, with dst for each row solved from the oval-0 capture. Three rows per edge, the flat part of the edge, every 2 pt:
  - Dark: **rms 0.25–0.76, max 1.7 levels**.
  - Light: rms 0.24–0.98 at stock 0.5. The forced oval-1 light top row has max 12, because the light matrix clamps near white.
  - The size of the effect depends on dst and the matrix. Over grey 128 it is about 13 levels (dark) / 10 levels (light) between the centre and 282 pt out on a 640 pt panel, which matches the ~8 levels the PC saw on Spotlight's narrower shapes.
- For hyprk: when min(W, H) > 64 pt, use `n = normalize(mix(n_sdf, normalize(x, y·W/H), 0.5))` (x, y from the shape centre) in the key/fill lobe. The highlight formulas stay as they are.
- Side effect: the left and right rims also change slightly (the normals there tilt up or down near the corners, by up to 6 levels). The interior over a uniform backdrop is unchanged (column at the centre: 0 difference).

## R8.2 Slider knob lens over a white fill (held): done

The SwiftUI `Slider` knob while held: `LiftLayer` 20×16 → `SwiftUI.SDFLayer` 25×20, element r 10, ovalization 0. Sublayers:
- `@0` `CABackdropLayer` (scale 1, margin 5), filter `displacementMap` inputAmount 5, source `CASDFGlassDisplacementEffect` {height 0, curvature 1, angle 0, maskOffset 0} → a zero map, so no displacement.
- `@1` `CABackdropLayer` (scale 1, margin 1), `glassBackground` (DLCAFilter). Inputs that are not zero:
  - FaceColorMatrixBlack **0.1**, White 1, Saturation 1, MaxLuma 1.
  - InnerRefraction −6 / height 3.6.
  - **RingShadow opacity 0.4 (dark) / 0.15 (light)**, offset 8, stroke 4, blur 3, mask 0.
  - KeyFillHighlight amount 0.5, angle π/2, bias −0.3, offset −1, height 1, spread 90° / SDR 120°.
  - Shadow amount 5, offset (0, 7), radius 8, opacity 0.0018, fill (0.3375, 0.4451, 0.5625).
  - BlurDistance0 −10. Everything else is 0. CASDFOutputEffect max 11.05.
- `@2` `SDFPortalLayer`, `displacementMap` amount 0.
- `@3` `CABackdropLayer`, `glassForeground`: all amounts 0. EdgeStart −4, EdgeEnd 0, EdgeOpacity 1 → 0 (fades the source at the edge only).
- `@4` `CASDFLayer` key/fill highlight: the same values as R8.1 with spread 80°, plus `vibrantColorMatrix`.

The inputs match what verify B2 found. What is new: light mode uses ring opacity 0.15. The column through the lens over white is now measured directly.

**Why the fill is lighter near the top:** two `glassBackground` terms.
- **Face lift:** `c' = 0.1 + 0.9·c` lifts every fill that is not pure white by 0.1·(1 − c). That is +14 levels at c = 120 and +4 at c = 215; pure white stays white.
- **Ring shadow:** a 4 pt inner stroke of the knob shape moved 8 pt **down**, blurred σ 3. It darkens a band centred 10 pt below the lens top: `c·(1 − op·sat(g(s/3) − g((s+4)/3)))`, `s = sdf(p − (0, 8))`. The top 2–4 pt sit above that band and keep the lifted value.

Centre column over pure white:
- Dark: 254 253 251 248 243 234 225 215 208 205 (middle) 208 215 224 233 242 248 252.
- Light: 255 254 253 251 249 245 243 (middle) 245 249 253 254.
- Model `knob_fit.py`: dark rms 1.2 (max 4.6, at the bottom-rim fill highlight), light rms 0.5 (max 2.1).
- Over grey 128 (dark): the top of the lens is 148–169, the middle about 122.

## Not done or open
- I did not find the code site that sets 0.5 versus 0. The > 64 pt rule comes from the live sweep only (it is the same 64 pt split as the size classes found before).
- `glassBackground` reads the ovalized gradient too, but on uniform backdrops only the rim pixels differ, so its refraction direction change was not measured separately.
- The real Control Center slider was not dumped (it runs in another process). The lens here is the stock SwiftUI / AppKit `Slider` knob.

## Files
- Probe: `reference/re/tools/probe/glassr8.swift` (`glassr8 <outdir> dark|light [grey] [sweep]`)
- Data: `reference/re/27.2.1/live/glass-r8/`
  - `tree-{dark,light}.json`, `tree-*-held-{white,grey}.json`: full layer trees with all CA properties and filter inputs.
  - `cap-*.png`: probe window only. Stock, oval0, oval1 and restored, plus held over white and over grey.
  - `log-*.json`, `log-dark-sweep.json`: gradientOvalization for each shape.
  - `rim_fit.py` with `rim-fit-*.json`, and `knob_fit.py` with `knob-fit-*.json`.
- Shader excerpt: `reference/re/27.2.1/decomp/QuartzCore-metallib-supercircle-sdf-ovalization.ll`
