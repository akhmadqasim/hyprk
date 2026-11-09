# hyprk-cursors mapping

Source: `themes/cursors/` (macOS HIServices + AccessibilityFoundation resources). Build: `python3 build.py`
(needs pdftocairo, xcursorgen, hyprcursor-util, Pillow). Output `hyprk-cursors/` holds both formats:
`cursors/` (Xcursor), `hyprcursors/` + `manifest.hl` (hyprcursor), `index.theme`.

## How it is built

- Sizes 24, 32, 48, 64, 96. Scale is 1 macOS point = 1 px at size 24 (arrow 17x23 px at 24, 4x that at 96).
- PDFs are rendered at 10 px/pt with transparency, then a drop shadow is added (info.plist: blur 2, offset 1 down, alpha 0.45),
  then downscaled with Lanczos. All images are square (hyprcursor requires 1:1); the hyprcursor `nominal_size` keeps the same scale.
- Hotspots come from `info.plist` (`hotx/hoty`, in points). Arrow hotspot = tip of the black fill. I-beam hotspot = centre.
- Animations: `progress` (15 frames, 33 ms) and `wait` (same frames, spinner only).
- Hyprcursor load was checked with libhyprcursor (shape lookup by alias, sizes, hotspots, frames). Not run inside Hyprland itself.

## Mapping (primary name -> macOS cursor)

| Primary | macOS source | Notes |
|---|---|---|
| default | `accessibility/default-pointer-3.png` (10x arrow, shadow baked in) | arrow at normal size is not in HIServices |
| pointer | `hiservices/macos27/pointinghand` | |
| text | `accessibility/default-iBeam-3.png` (10x I-beam) | HIServices `ibeamvertical` is a stretched variant, not used |
| vertical-text | `hiservices/ibeamhorizontal` | macOS names are swapped: this is the beam for vertical text |
| wait | spinner cut out of `hiservices/busybutclickable` | closest: macOS has no beach ball in these assets; hotspot = spinner centre |
| progress | `hiservices/busybutclickable` | arrow + spinner |
| crosshair | `hiservices/cross` | |
| cell | `hiservices/cell` | |
| move | `hiservices/move` | also all-scroll (closest) |
| grab | `hiservices/macos27/openhand` | |
| grabbing | `hiservices/macos27/closedhand` | |
| not-allowed | `hiservices/notallowed` | also no-drop |
| help | `hiservices/help` | |
| context-menu | `hiservices/contextualmenu` | |
| copy | `hiservices/copy` | |
| alias | `hiservices/makealias` | |
| zoom-in / zoom-out | `hiservices/zoomin` / `zoomout` | |
| col-resize | `hiservices/resizeleftright` | arrows with centre bar |
| row-resize | `hiservices/resizeupdown` | arrows with centre bar |
| ew-resize | `hiservices/resizeeastwest` | |
| ns-resize | `hiservices/resizenorthsouth` | |
| nesw-resize | `hiservices/resizenortheastsouthwest` | |
| nwse-resize | `hiservices/resizenorthwestsoutheast` | |
| n/s/e/w-resize | `hiservices/resizenorth` / `south` / `east` / `west` | one active arrow, other greyed |
| ne/nw/se/sw-resize | `hiservices/resizenortheast` / `northwest` / `southeast` / `southwest` | |

## Legacy aliases (symlinks in `cursors/`, `define_override` in hyprcursor)

- default: left_ptr, arrow, top_left_arrow, dnd-move
- pointer: hand2, hand, pointing_hand, 9d800788..., e29285e6...
- text: xterm, ibeam
- wait: watch
- progress: left_ptr_watch, half-busy, 08e8e1c9..., 3ecb610c..., 00000000000000020006000e7e9ffc3f
- crosshair: cross, tcross, cross_reverse, diamond_cross, color-picker, X_cursor (closest)
- cell: plus, dotbox
- move: all-scroll, fleur, size_all, 4498f0e0..., 9081237..., fcf21c00...
- grab: hand1, openhand. grabbing: closedhand, dnd-none
- not-allowed: no-drop, dnd-no-drop, forbidden, crossed_circle, circle, 03b6e0fc...
- help: question_arrow, whats_this, left_ptr_help, 5c6cd98b..., d9ce0ab6...
- context-menu: dnd-ask, context_menu
- copy: dnd-copy, 1081e372..., 6407b0e9...
- alias: link, dnd-link, 3085a0e2..., 640fb0e7..., a2a266d0...
- zoom-in: zoom_in. zoom-out: zoom_out
- col-resize: split_h. row-resize: split_v
- ew-resize: sb_h_double_arrow, h_double_arrow, size_hor, size-hor, 14fef782..., 028006030...
- ns-resize: sb_v_double_arrow, v_double_arrow, double_arrow, size_ver, size-ver, 2870a090..., 00008160...
- nesw-resize: fd_double_arrow, size_bdiag, size-bdiag, fcf1c3c7... ; nwse-resize: bd_double_arrow, size_fdiag, size-fdiag, c7088f0f...
- n: top_side. s: bottom_side. e: right_side. w: left_side
- ne: top_right_corner, ur_angle. nw: top_left_corner, ul_angle. se: bottom_right_corner, lr_angle. sw: bottom_left_corner, ll_angle

Hash names are the GTK/Qt/Chromium legacy ids, copied from the Yaru and DMZ themes installed on this machine.

## Not mapped

- Unused macOS cursors: poof, screenshotselection, screenshotwindow, counting*hand, resizeleft/right/up/down (limit variants), all `rotate*` and `objectResize*` accessibility layers.
- Not provided (fall back to the default theme): pencil/draft, right_ptr, sb_*_arrow, *_tee, pirate, target, and similar rare X11 names.
- No beach ball: it is not in the extracted assets, `wait` uses the blue busy spinner instead.
