# Apple HIG / Liquid Glass pictures (measured from)

Downloaded 2026-11-14 from Apple's public developer pages (the JSON behind them lists each asset; assets are served
under `https://developer.apple.com/tutorials` + the listed path). Only the pictures measured in
`reference/re/27.2.1/GLASS-HIG.md` are kept here; the full videos stayed in the scratch dir.

All are **iOS** renders or illustrations: weaker evidence than the 27.2.1 Mac data for macOS sizes and constants,
valid for the optical behaviour (which way the rim bends, where the light sits).

| file | source | what it shows | platform |
|---|---|---|---|
| ios-slider-held-lens-t0.4s.png | frame at 0.4 s of `/videos/com.apple.TechnologyOverviews/adoption-guide-slider.mp4` (1080x318, 30 fps; page: documentation/technologyoverviews/adopting-liquid-glass), crop 300x150 at (440,70) | a held slider knob as a clear lens over a grey track and blue fill: the fill flares toward the lens's rim (magnified at the rim), cyan / magenta fringes on the rim, interior 1:1. Lens rims in the crop: left 73.5, right 247.5, top 26.5, bottom 140.5 px (D 114 px); track outside rows 74-97 | iOS |
| ios-segmented-drag-lens-t2.4s.png | frame at 2.4 s of `/videos/com.apple.TechnologyOverviews/adoption-guide-segmented-control.mp4` (1080x334), crop 560x200 at (100,60) | a segmented control's selection dragged as a lens: the label inside is the selected (black) label at 1.16 x (47 vs 40.5 px cap height), a glyph cut off at the rim is squeezed into a thin sliver | iOS |
| ios-glass-regular-over-dark@2x.png | `/images/com.apple.HIG/materials-ios-liquid-glass-over-dark@2x.png` (HIG Materials, Liquid Glass) | a 157 pt Regular glass disc over a star field: rim brightest at the top (+103 over the face) and bottom (+78), weakest at left / right (+44) | iOS |

Not kept (looked at, nothing measurable for refraction): `materials-ios-liquid-glass-clear@2x.png` (bricks through
Clear glass, too blurred to trace a displacement; rim line 1.5 px), `-over-light@2x.png`, the tab bar and toolbar
"after" pictures of the adoption guide (flat illustrations: grey fill and a white rim, no backdrop through them),
`liquid-glass.png`, the visionOS / watchOS pictures. The HIG Buttons, Sliders, Toggles and Segmented controls pages
carry only illustrations without glass.
