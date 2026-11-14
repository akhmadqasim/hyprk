# Requests for the Mac session, round 2 (macOS 27.2.1)

From the PC session, 2026-11-14. Judge #16 (reference/JUDGE-95-16.md) scores 92.28; what is left of the 95 goal in
glass refraction and motion cannot be settled from the binaries alone. Each item names what it settles. Put the
files under `reference/screens/27.2.1/<folder>/` with an INDEX.md line each, commit as `re: ...`.

Captures: 2x (Retina, no scaling), PNG for stills, 60 fps (120 if possible) screen recording for motion, default
wallpaper unless a backdrop is named. "Stripes" = a full-screen image of 4 pt black / white vertical stripes
(any image viewer, window behind the control).

## G1 Glass refraction (the user's first priority)
1. Settings > Appearance, the Liquid Glass preview, dark and light, with the window over a flat mid-grey
   (127) desktop picture: still, and a crop of the share / search capsules at 2x. Settles the preview buttons'
   round ends (ours dark 86 vs your shot's 105, light 170 vs 139: the backdrop in the old shot is not known).
   -> `settings/appearance/liquidglass-flat-grey-{dark,light}.png`
2. A switch held down (Settings, any switch), over stripes, light and dark: one still while held, and a 60 fps clip
   of press, 1 s hold, release. Settles the dark rim and the colour fringe width (only light has a reference).
   -> `controls/switch-held-stripes-{dark,light}.png`, `.mov`
3. A slider knob held, light: a Settings slider and the Control Center Sound slider, over stripes where possible.
   -> `controls/slider-held-{settings,cc}-light.png`

## M1 Motion
4. Dock Downloads stack: fan open / close and grid open / close at 60 fps, plus one still of each open (dark).
   Settles the fan's 24 pt shift (decoded, sign inferred), item anchor, the chevron under the fan.
   -> `dock/stack-{fan,grid}-{open,close}.mov`, `dock/stack-{fan,grid}-open-dark.png`
5. Mission Control with 4 overlapping windows of one app: enter, then exit by clicking a back window, 60 fps.
   Settles the layer order and the moment the picked window comes to the front.
   -> `live/mc-exit-4-windows.mov`
6. A close button held 1 s, dragged 50 pt out, released outside, 120 fps. Checks the decoded bounce
   (14 -> 16 pt, response 0.355 s, damping 0.4) and the 2 s idle end.
   -> `windows/close-button-hold-drag.mov`

## M2 Modules with no picture at all
7. Menu bar Wi-Fi, Battery and Focus modules open, dark and light (the layout was decoded from code only).
   -> `panels/module-{wifi,battery,focus}-{dark,light}.png`
