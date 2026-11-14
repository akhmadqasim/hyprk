# Dock gaps REA, macOS 27.2.1 (26B131)

Questions: the items GAPS-dock-lock-sound.md left open (Dock menu shape, hover label width, the Trash drop sound) and,
from "Not compared", the Downloads stack fan and grid. Static analysis only, nothing was run.
Pseudocode and asm readings: `decomp/Dock-gaps.c`.

## Method (PC, Linux)
- Dock and DockHelper.xpc copied from the system volume another agent had mounted read-only
  (`re-work/gaps-panels/mnt`), thinned with `llvm-lipo -thin arm64e`. Dock arm64e sha256 05afb171..., DockHelper
  arm64e sha256 7edeba80.... Scratch: `~/Downloads/macos/re-work/gaps-dock`.
- REA CLI with Ghidra 12.1.4: `rea decompile-all` on DockHelper (Evidence
  `ev_9a0fbb7ebfe65a66c38a31e9a71905acae4c813669b430af14f8db78cd1216a1`), `rea decompile` of Dock FUN_100186bdc
  (Evidence `ev_e4dbe2676da50722b45856cc9dc299b19dc1d395359c8e59d16bd0cc24e42b5c`), `rea decompile-all` on Dock
  (Evidence `ev_5599a397...`, see "REA export"). Before the REA switch, a private Ghidra 12.2 project
  (`re-work/gh-dock-gaps`, heap 6 GB) gave the same functions; those pseudocode excerpts are marked "Ghidra" in the .c.
- Dock objc stubs resolved through their selrefs (read from the binary, e.g. 0x100315080 = `setContentLayer:`).
  The existing annotated disassembly `re-work/r2/Dock.ann` was used for asm.
- AppKit and CoreUI: `ipsw dyld disass --vaddr ... --cache <DSC>.a2s` (it names objc stubs by selector),
  `ipsw dyld symaddr`, `ipsw dyld dump` for constants; `llvm-nm` on the already extracted `re-work/ex/AppKit.fixed`
  for AppKit symbol addresses. No REA Evidence for these (REA cannot open dyld cache images here).
- Where Ghidra's pseudocode disagreed with the asm (register reuse in `_updateLabelImage:`, `fcvtps` shown as `(int)`),
  the asm reading is the one written down.

## 1. Dock menu (right click on a Dock icon)
Who draws it: DockHelper.xpc, with AppKit. Not Dock's own layer code.
- Confirmed. DockHelper FUN_10000aa2c (REA ev_9a0fbb7e...): makes a window at the tile rect, then
  `[menu _popUpMenuRelativeToRect:(0, 0, w, h) inView:contentView preferredEdge:DAT_100010528[direction]
  flags:(fromKeyboard ? 0x100 : 0) options:nil]`. Edge table {0, 2, 1, 1}.
- Confirmed. AppKit makes every popup menu window with style mask 0x8000 (`-[NSPopupMenuWindow
  initWithContextMenuImpl:]`, `mov w2, #0x8000` at 0x18aa88d3c), and `+[NSPopupMenuWindow frameViewClassForStyleMask:]`
  0x18aa8e2b8 maps 0x8000 to `_NSPopupMenuWindowPopoverFrame`.
- Confirmed. `-[_NSPopupMenuWindowPopoverFrame _copyFrameMaskPathInRect:]` 0x18aa8858c: no shape when the anchor
  size is zero; else `CUICreateMenuPath(rect, 1,1,1,1, edgeCode, 1.0, arrowPos)` with edgeCode =
  {1, 4, 3, 2}[anchorEdge] (0x18b7ef0b0) or 1000 = no arrow. arrowPos = anchorPoint.x minus the body's x offset for
  a top/bottom edge.
- Inferred: a menu opened with `_popUpMenuRelativeToRect:` gets an anchor edge and so a tail, a plain context menu
  does not. From the 1000 = no-arrow branch and Q-dock-10 (only the Dock menu shows a tail). The setter of
  anchorEdge / anchorSize on this path was not traced.

Shape, CoreUI `__CUICreateMenuPath` 0x18f272ce4 and `__pathForRoundedRectWithAnchor` 0x18f2fcfbc (scale s = 1.0):

| what | value | source |
|---|---|---|
| body corner radius | 12, continuous; capped at floor(min(w, h) / 2) - 1 | fmov #12 at 0x18f272dd0; cap 0x18f2fd0cc..0x18f2fd0ec. Confirmed |
| tail base width W | 23.5 | double at 0x18f3287a8 (0x4037800000000000). Confirmed |
| tail height h (out of the body) | 13 | fmov #13 at 0x18f272dd8. Confirmed |
| tip rounding | arc radius 0.42 h = 5.46 | 0x3fdae147ae147ae1 at 0x18f2fd3d4. Confirmed |
| base fillets | arc radius 0.60 h = 7.8, tangent points at +-(W/2 - 0.08 h) = +-10.71 | 0x3fe3..., 0x3fb4... at 0x18f2fd3c4, 0x18f2fd3f0. Confirmed |
| tail line ends | +-(W/2 + 1) = +-12.75 along the body edge (overlaps the body by 1) | 0x18f2fd410..0x18f2fd428. Confirmed |
| tail position | the anchor point, clamped to [W/2, edge length - W/2], centred if the edge is shorter than W | `__CUICreateNewPopoverPathWithArrowPosition` 0x18f272e24. Confirmed |
| construction | CGPath: move + 3 `addArc(tangent1End:tangent2End:radius:)`, rotated by edge x 90 deg, spliced into the body outline | 0x18f2fd42c..0x18f2fd4d0. Confirmed |

- The Mac's "body inset 13" (Q-dock-10) is the tail height 13: the frame keeps 13 pt on the anchor edge for the tail.
  Inferred (equal numbers, `contentRectForFrameRect:` of the popover frame 0x18aa886b8 not decoded in full).
- With window x = icon centre - 40 and the body 13 in, the anchor (icon centre) is 27 from the body's left edge,
  inside the clamp (11.75 ..). So the tip sits on the icon centre. Inferred from the AX numbers plus the clamp.
- "Radius about 14 (visual)" in Q-dock-10: the code says 12.
- Not the label's shape code. The label is DesignLibrary glass (Dock `ECCartoucheGlassLayerController`, a 45 deg
  rotated square unioned by an SDF, see 2); the menu is a CoreUI CGPath with arcs in AppKit. Confirmed.
- Glass variant of the menu: not traced (`-[NSContextMenuImpl glassView]` 0x18a960770 not decoded). Whether the
  glass follows the mask path: inferred yes (it is the window shape), not traced.

hyprk: `shell/Theme.qml` `Theme.menu.radius` 12 already matches. The tail (23.5 x 13, tip r 5.46, fillets 7.8) has no
constant yet: `Theme.dock.menuInset` 13 is the space it needs. `Theme.dock.labelPointer` (16 x 7) is the label's and
should not be reused for the menu.

## 2. Hover label
Width rule. Confirmed: label width = ceil(text width) + 26, at least 41.
- `-[ECCartoucheGlassLayerController setContentLayer:]` body FUN_100186bdc (REA ev_e4dbe267...), asm:
  r = radiusFor: = 13 (FUN_10018767c); pad = max(r, 13) = 13 (0x100186d58); (minW, tailH) = FUN_100186e18 = (15, 8)
  (0x100186e6c, not (15, 0) as Ghidra prints); layer bounds = (text w + 2 pad, max(text h, 26) + tailH) = (w + 26, 34)
  (0x100186da0); text layer frame = (13, 8, w, h) (0x100186ddc).
- `-[DOCKLabelLayer _updateLabelImage:orientation:]` 0x10003f44c sets the text layer, then reads the backdrop layer's
  bounds back and uses its width (0x10003f61c..0x10003f704). Ghidra's pseudocode shows the image width there; wrong.
- Layout FUN_100186fc0: body width = max(layer width, 15 + 2 x 13 = 41), body height = layer height - 8 = 26.
- Text width = ceil(CTLineGetTypographicBounds) (`fcvtpu` at 0x1000149ec), middle-truncated above 600.
- Font: `CTFontCreateUIFontForLanguage(kCTFontUIFontSystem, 14)` (0x10003ee14), attribute dictionaries hold only font
  and foreground colour (0x10003eef4..0x10003f010): SF, 14 pt, regular, no extra tracking (CoreText's own default
  tracking for the system font applies, not visible in Dock). Second style 11 pt, monospaced digits.
- Height: body 26 (26 = min, `fmov #26` at 0x100186d0c and 0x10003f638). Confirmed.
- Tail: square side 16 (cartoucheRectSideLengthFor:, selref 0x100312a68), corner 2.5 (cartoucheRadiusFor:),
  rotated pi/4 (0x100264058), smooth union 25; square centre 4 pt inside the body's bottom edge
  (cartoucheVerticalOffsetFor: 4, sqY = H - 12 at 0x100187258). Tip depth below the body before the union:
  8 x sqrt 2 - 2.5 (sqrt 2 - 1) - 4 = 6.27 (Mac measured about 6.5). Values confirmed; the vertical orientation of
  the layer's coordinate frame is inferred (from that depth matching the measure), not traced.
- Why ours is 70..71 for "Finder" and the Mac's 67.5: `shell/lib/dock.js` `labelWidth()` returns
  `max(41, min(600, textWidth) + 28)`; the Mac adds 26 (2 x 13, not 2 x 14). That is 2 pt. The rest (up to 1 pt)
  is our unrounded Qt text width against the Mac's ceil'd CoreText width and the edge threshold. Inferred split; the
  rule part is confirmed.

hyprk: `shell/lib/dock.js` `labelWidth()`: `+ 28` -> `+ 26` (Mac: ceil(text) + 26, min 41). Comment in
`shell/modules/Dock.qml` line 706 ("text + 2 x 14") follows. Font `Theme.font.dockLabel` 14 matches. Height 26,
`Theme.dock.labelPointer` (16 x 7) unchanged.

## 3. Drop onto the Dock Trash
Confirmed: `-[DOCKTrashTile dragDrop:]` 0x1000716a0.
- Drag classifier FUN_100023800 looks at the first pasteboard item: flavor `local-volume-url` -> 0x8000,
  `owensdock` -> 0x10, `stackitem` -> 0x2000, `local-file-url` -> 0x4000.
- Neither 0x4000 nor 0x8000: the Dock only sets the standard drop location 'trsh' (`CoreDragSetStandardDropLocation`)
  and drop action 0x20, and plays nothing. The drag source (e.g. Finder) does the move; its sound was not traced.
- 0x4000 (local file URL): a block on a global queue (0x1000718fc) calls FUN_1000518f4:
  `NSFileManager trashItemAtURL:resultingItemURL:error:`, and only if it returns YES,
  `AudioServicesPlaySystemSound(16)` (0x100051950). So ID 16 plays right after the move succeeds, at the drop,
  not at the end of an animation. One URL (pasteboard item 1).
- 0x8000 (a volume): FUN_100051980 unmounts (`DADiskUnmount`, queue "eject-queue"). No sound on this path.
- ID 16 -> `dock/drag to trash.aif`: from MAC-ANSWERS "Sounds per event" (systemsoundserverd table), not re-traced.
  Other Dock sound calls: ID 15 at 0x1001122a4 and 0x10022cdd0 (poof, inferred from the same table),
  alert sound 0x1000 at 0x10003ec54.
- Which apps put `local-file-url` on a drag: unknown.

hyprk: the shell's Dock takes no file drops (GAPS item 4). When it does: play `dock/drag to trash.aif` once the move
to Trash has succeeded, at drop time. No constant to change now.

## 4. Downloads stack (partial)
Grid, `-[DOCKStackGridLayer _sizeForStage:]` 0x10001b4d4. Confirmed:
- cell = 128 (default); with a preferred item size p: 16 p + 80, clamped to 80..512.
- items that fit = int((stageW / (cell + 28)) x (stageH / (cell + 28))), at most the item count n.
- columns = ceil(sqrt(n)), rows = ceil(n / columns) (`fcvtps` at 0x10001b5d4, 0x10001b5e4); if the last row's
  remainder is non-zero and smaller than rows, columns + 1 and rows recomputed.
- cell shrinks to fit: min(cell, stageW / columns, stageH / rows). Icon image = cell - 28 (100 at 128).
- popup width = columns x cell + 34 (+42 instead of +34 when scrollbarVisibility is 2 and the content scrolls; mode 2's meaning not traced),
  height = rows x cell + 44, or + 54 with a title; + 12 on width for a side Dock.
- Check against Q-dock-12 (11 items): 4 columns, 3 rows, 4 x 128 + 34 = 546, 3 x 128 + 54 = 438. The Mac shot is
  546 x 438. Matches.
- Corner radius of the grid bubble: not traced.

Fan, `-[DOCKStackFanLayer layout]` 0x100072030. Confirmed:
- items stacked upward, pitch = item size (each y = previous y + item size), all on a circle of radius 3000
  (0x100258428): x offset = 3000 - sqrt(3000^2 - y^2), tilt = -atan(y / (3000 - x)) = -asin(y / 3000).
- `expandedFrameForStage:` 0x100071ec0: viewable items = floor(stage height / 64); the fan's frame is 24 pt below
  the tile centre line (`- 24.0`). Inferred reading of the y term; not cross-checked.
- Item size for the fan: not found (setter of `_itemSize` for the fan not traced). Mac measured step 64.6.

hyprk: there is no stack popup in the shell (`shell/lib/dock.js` line 137 says so), so nothing to change yet.

## Not found
- Dock menu row metrics (24 / 11): drawn by AppKit's NSContextMenuImpl, not traced. `Theme.menu.itemHeight` 24 and
  `separatorHeight` 11 stay on the SPEC and Q-menubar sources.
- Dock menu glass variant and whether the menu's glass uses the popover mask path: not traced
  (`-[NSContextMenuImpl glassView]` 0x18a960770 left).
- Who sets the popover frame's anchorEdge / anchorSize for `_popUpMenuRelativeToRect:` (the link from DockHelper's
  preferredEdge to the tail): `-[NSCocoaMenuImpl _popUpMenuRelativeToRect:...]` 0x18abc77b4 and
  `-[NSPopupMenuWindow _popUpWithCalloutFrame:menuSize:]` 0x18aa8e510 not decoded.
- Fan item size, grid bubble radius, Finder's own sound on a standard Trash drop.

## REA export
`rea decompile-all` of the whole Dock (Ghidra 12.1.4, 22418 function files under
`~/Downloads/macos/re-work/gaps-dock/rea/dock-all/functions`): Evidence
`ev_5599a397b84ddf92807651f4d4156f588fd24bd03d148b3574f024043133b5e5`. It holds every Dock address cited above
(0x1000716a0, 0x1000518f4, 0x10001b4d4, 0x100072030, 0x100186bdc, 0x100186fc0, ...).
