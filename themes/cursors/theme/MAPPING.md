# hyprk-cursors

macOS 27.2 cursor theme for hyprk, as hyprcursor (SVG where the source is vector) and Xcursor in one directory.
Evidence for every number below: /mnt/code/liquid-glass-re/SPEC.md, section "Cursors".

## Build

```
python3 extract_cursorasset.py <macOS root>/System/Library/PrivateFrameworks/SkyLight.framework/Versions/A/Resources/CursorAsset
python3 build.py            # hyprk-cursors/ (Apple sources where present, free lookalikes otherwise)
python3 build.py --free     # free lookalikes only, no Apple artwork
./install.sh                # optional copy to ~/.local/share/icons
```

Needs rsvg-convert, pdftocairo, xcursorgen, hyprcursor-util, Pillow. The session finds the theme through
`config/icons/hyprk-cursors` (symlink) and `XCURSOR_PATH`; apply live with `hyprctl setcursor hyprk-cursors 24`.

Apple files stay local (`.gitignore`): `cursorasset/` (extracted rasters), `hiservices/`, `accessibility/`, `png/`
and the built `hyprk-cursors/`. Without them every shape comes from `free_cursors.py` (own SVG drawings).

## Size and scale

- 1 macOS point = 1 px at cursor size 24. Keep `HYPRCURSOR_SIZE`/`XCURSOR_SIZE` at 24: Hyprland multiplies it by the
  monitor scale (`CCursorManager::prepareHyprcursor`, size * scale), so the cursor keeps its point size like macOS.
- Xcursor sizes 24, 30, 36, 48, 60, 72, 96 (scale 1 to 4). CursorAsset rasters use Apple's 1x/2x pixels unchanged
  at 24/48 and are downscaled from the next larger Apple rep otherwise (5x, 10x).
- Every image is square (hyprcursor rule) and trimmed to the drawn pixels plus shadow, so most shapes fit a 64 px
  hardware cursor at 2x. Exceptions at 2x: copy, not-allowed, poof, progress (70 px), context-menu (64 px).
- HIServices vector cursors get WindowServer's shadow (info.plist: blur 2, 1 pt down, black 45 %) as an SVG filter.

## Mapping (primary name -> source)

| Primary | Apple source | Also answers to |
|---|---|---|
| default | CursorAsset id 100 (macOS 27 arrow, 28x40 pt canvas, hot 5,5) | left_ptr, arrow, top_left_arrow, dnd-move, dnd-none, right_ptr, draft, pencil |
| text | CursorAsset id 101 (macOS 27 I-beam, hot 12,11) | xterm, ibeam |
| wait | CursorAsset id 7: beach ball, 30 frames, 1/60 s each | watch |
| progress | HIServices busybutclickable: arrow + blue spinner, 15 frames, 33 ms | left_ptr_watch, half-busy, hashes |
| pointer | HIServices macos27/pointinghand | hand2, hand, pointing_hand, hashes |
| grab / grabbing | HIServices macos27/openhand / closedhand | hand1, openhand / closedhand |
| copy | HIServices copy (`+[NSCursor dragCopyCursor]`) | dnd-copy, hashes |
| alias | HIServices makealias (`dragLinkCursor`) | link, dnd-link, hashes |
| not-allowed | HIServices notallowed (`operationNotAllowedCursor`) | no-drop, dnd-no-drop, forbidden, crossed_circle, circle, pirate |
| context-menu | HIServices contextualmenu | dnd-ask, context_menu |
| poof | HIServices poof (`disappearingItemCursor`) | disappearing-item |
| help, cell, crosshair, move | help, cell, cross, move | question_arrow ..., plus, cross ..., all-scroll, all-resize, fleur |
| vertical-text | HIServices ibeamhorizontal (Apple's names are swapped) | |
| zoom-in / zoom-out | zoomin / zoomout | zoom_in / zoom_out |
| col-resize / row-resize | resizeleftright / resizeupdown | split_h / split_v |
| ew-resize | resizeeastwest | e-resize, w-resize, left_side, right_side, sb_h_double_arrow, ... |
| ns-resize | resizenorthsouth | n-resize, s-resize, top_side, bottom_side, sb_v_double_arrow, ... |
| nesw-resize | resizenortheastsouthwest | ne-resize, sw-resize, corners, fd_double_arrow, ... |
| nwse-resize | resizenorthwestsoutheast | nw-resize, se-resize, corners, bd_double_arrow, ... |

Window edges: macOS shows the two-headed frame cursors (`+[NSCursor frameResizeCursorFromPosition:inDirections:]`);
the one-headed HIServices variants only appear when a window is at its size limit, which Wayland cannot express.
So the one-sided wayland names (Hyprland's border drag asks for n-resize, se-resize, ...) map to two heads.

Hash names are the GTK/Qt/Chromium legacy ids. `index.theme` inherits Adwaita for rare X11 names not listed here.

Not used: CursorAsset ids 0/1 (pre-27 arrow and I-beam), 2-6/8 (8x8 and 4x4 stubs); HIServices counting*hand,
screenshot*, the one-headed resize cursors, accessibility/ (large-size layers).

## Free fallback

`free_cursors.py` draws every primary shape as SVG (arrow, I-beam, hands, pinwheel beach ball with 30 frames at
17 ms, arrow + spinner, badges, resize arrows, magnifiers). Same names, sizes, hotspots and frame rates.
