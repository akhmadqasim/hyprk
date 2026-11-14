# Round 3: stack fan item size, emoji category glyphs, stock key repeat (2026-11-14)

macOS 27.2.1 (26B131). Static reading only, nothing was run on a Mac. Tools: REA 6.8.0 CLI with Ghidra 12.1.4
(`rea decompile-all ... --provider ghidra`), llvm-objdump 21, `ipsw dyld str / macho --strings / disass --symbol / a2s`
with `dyld_shared_cache_arm64e.a2s`, apfs-fuse (read-only) on the system volume `141-12228-174.dmg` at
`~/Downloads/macos/re-work/round3/mnt`. Work files under `~/Downloads/macos/re-work/round3`.
Observed = read in code or bytes. Inferred = reasoning on top of that. GUESS = no source.

REA Evidence:
- Dock (existing export, `re-work/gaps-dock/rea/dock-all`): `ev_5599a397b84ddf92807651f4d4156f588fd24bd03d148b3574f024043133b5e5`.
- KeyboardSettings.appex (arm64e slice, `round3/kbd/all`): `ev_1eb2959235e6cc248e1e2af4f5b5afe23630d9d6289b86d9e70ae17f00b73cf6`.
- IOHIDKeyboardFilter.plugin (arm64e slice, `round3/kf/all`): `ev_fc7bbbbfdf7ed0625e6a6e2fb4b2d01eb52f1108c8533e439d6671dd6d962e84`.
- UIKitCore and CharacterPicker were read from the dyld cache with ipsw (REA cannot import cache images; the Ghidra
  extract of CharacterPicker ran out of heap), so no Evidence IDs for section 2.

## 1. Dock stack fan item size (JUDGE-95-13 next-10 item 6)

Observed:
- `DOCKStackExpandedLayer._itemSize` has exactly three users in the Dock export: written by
  `-[DOCKStackFanLayer initWithStack:usingLayerSource:]` 0x100071acc (`_itemSize` = `_itemImageSize` = 64.0 x 64.0,
  0x4050000000000000), written by the grid's `_sizeForStage:` 0x10001b4d4 (grid only), read by
  `-[DOCKStackFanLayer layout]` 0x100072030 (every item `setBounds:(0, 0, size, size)`, asm 0x100072318..0x10007232c,
  d8 = `_itemSize.height` from 0x1000721b8). `-[DOCKStackExpandedLayer setPreferredItemSize:]` only stores
  `_preferredItemSize`. So at rest every fan item is 64 x 64, whatever its index or the item count.
- Hover: `-mouseEnteredItemLayer:fromDrag:` 0x10007279c calls `setSelectedIndex:` only when fromDrag or
  `mouseOverHiliteInStack` (defaults key `mouse-over-hilite-stack`) is true. `-setSelectedIndex:` 0x1000723d0 puts an
  ECMaterialLayer (material 5 in a dark Dock, 2 otherwise, radius 6.0, edge antialiasing) under the item with the
  item's transform and bounds + 4 on each side total (68 x 68), CATransaction duration 0.15 (0x3fc3333333333333). The
  item's own bounds do not change. The key's stock value was not traced (GUESS: off).
- Open: `-[DOCKStackFanAnimator expand:]` 0x100063c2c disables actions (FUN_1000071f8), sets each item's and image
  layer's bounds to its collapsed frame's size (pseudocode line 356..358; frames from
  `getCollapsedLayoutFrames:count:` 0x100067df4, items past the frame count reuse the last), flushes, re-enables actions
  (line 409), then sets bounds to `itemSize` (line 517) next to the explicit position / opacity / transform animations.
  Close: `-collapse:` 0x100064d90 sets the collapsed size back with actions enabled (line 342 after 257).
- Inferred: the bounds change is an implicit animation in the same transaction, so the item grows from
  tile - 2s(j+1) (s = 1 / 2 / 3 for tile < 32 / < 48 / larger, j <= 2) to 64 on open and shrinks back on close. Its
  timing curve is CA's implicit default, not read; we drive it with the same p as the position.
- The Mac's measured "65.5 -> 78.3 pt bottom to top, step 64.6" (Q-dock-12, AX) is the axis-aligned box of a turned
  64 square: 64 (cos a + sin a) with a = atan(y / (3000 - dx)). Ours at tile 33, 12 slots: 65.0 and 78.0; box tops step
  64.59. So the Mac numbers confirm a constant item size; the 0.3..0.5 left is the unknown reference layer size / AX
  rounding (not settled).

Fan shift (-24), re-read from asm 0x100071f68..0x100071f9c of `expandedFrameForStage:relativeToLayer:withEdge:`
0x100071ec0: size = the reference layer's own bounds (w, h); origin x = int(frame.midX - w/2),
y = trunc(frame.midY - h/2) - 24, where frame = the reference layer's frame converted with
`convertRect:toLayer:nil`; the result is then converted into the fan's superlayer. The reference layer is the tile's
`imageLayer` (`expandUsingHandler:` 0x100019dc4 fetches it right before the call). `numberOfViewableItems` =
stage height / 64 (0x3f90000000000000). In `layout` the first arc height is int(64/2 + int(bounds.midY)) and the
position is (int(midX + dx), int(midX + y)) (asm 0x100072204..0x10007230c: both use the int of bounds.midX for the
base; the frame is square so this equals midY). In a y-up layer tree -24 is down; the only `setGeometryFlipped:` in
the Dock (0x1000eaa84) is on a DesignLibrary view, not the stack layers, but the root's flip and the stack window's
origin were not traced. Read as down, the first item's bottom is 24 pt inside the tile, which a test session showed
overlapping the Dock. Not settled: `fanShift = +24` stays GUESS (comment updated in `shell/lib/dockstack.js`).

Changed: `shell/lib/dockstack.js` `fanSize(tile, i, p)`, `fanBox(side, angle)`; `shell/modules/DockStack.qml` fan item
`scale` = fanSize / 64 and the label's reach from the item's half size; tests in `shell/tests/run.mjs`
("stack fan item size").

## 2. Emoji & Symbols category bar glyphs (JUDGE-95-13 item 5, glyph part)

Observed:
- CharacterPicker (`ipsw dyld macho ... CharacterPicker --strings`, 1452 strings): CPKCategoryData's symbol names are
  clock, emoji.face.grinning, emoji.dog.face, emoji.apple, emoji.soccer.ball, emoji.automobile, lightbulb, emoji.heart,
  flag (cstrings 0x22a6ac634.., 0x26bd54a68..). No ".inverse" string, and no ".inverse" / "inverse" ASCII immediate
  (`movk #0x692e`) in its 200k-line disassembly. The framework's `EmojiCategory*.tiff` / `EmojiIMCategory*.pdf`
  resources are older art (a bear / hamster, not the dog in the shot).
- UIKitCore `+[UIKeyboardEmojiGraphics emojiCategoryImageName:forRenderConfig:]` 0x1ac1b58a4 (ipsw disass): x20 =
  category type, jump table 0x1ab8644b4 (12 cases); w19 = `[renderConfig lightKeyboard]` (stub 0x1b00dd6a0, selector
  resolved by the disassembler). Cases return "clock", "emoji.apple", "emoji.automobile", "lightbulb", "emoji.heart",
  "flag"; for three cases x8 = the `.inverse` name, x9 = the plain one, then 0x1ac1b5984 `cmp w19, #0` /
  `csel x8, x9, x8, ne`: light keyboard -> emoji.face.grinning / emoji.dog.face / emoji.soccer.ball, otherwise
  emoji.face.grinning.inverse / emoji.dog.face.inverse / emoji.soccer.ball.inverse. Selection does not change the name.
- `reference/screens/27.2.1/panels/emoji-picker-dark.png`: the face (selected), the dog and the ball (not selected)
  are the `.inverse` shapes (the ball's stem at the bottom, the dog's white face with the dark eye ring); the other six
  are the plain names. That is exactly UIKitCore's dark rule.
- Weight: thresholded ink pixel counts on `judge-95-13/02` Mac vs ours (regular): apple 665 / 674, heart 591 / 594,
  flag 548 / 550. Regular matches; the "heavier" look is not supported.
- Inferred: the Mac popover's bar follows UIKitCore's rule (dark -> inverse). Which framework actually draws it on the
  Mac is not traced (CharacterPicker names only plain ones). Light mode outlines: inferred from the same function, no
  Mac light shot.
- No new symbols were needed: emoji.dog.face.inverse and emoji.soccer.ball.inverse were already decoded in
  `themes/icons/sf-symbols` (all three weights).

Changed: `shell/lib/emoji.js` `tabs(dark)`; `shell/modules/EmojiPicker.qml` line 45 `EM.tabs(Theme.dark)`; tests in
`shell/tests/run.mjs` and `themes/icons/tests/sf.test.mjs`. Seen in a headless session (dark): face, dog and ball
filled, the rest outlined, as on the Mac shot.

## 3. Stock key repeat (JUDGE-95-13 item 9)

Observed:
- `IOHIDKeyboardFilter::IOHIDKeyboardFilter` (constructor body 0x1380, IOHIDKeyboardFilter.plugin):
  this+0x178 = 500 (`_keyRepeatInitialDelayMS`, the serialize at 0x3b80 writes it as HIDInitialKeyRepeat) and
  this+0x180 = 0x53 = 83 (`_keyRepeatDelayMS`, HIDKeyRepeat). `IOHIDKeyboardFilter::open` 0x1d3c and
  `setPropertyForClient` replace them only when a HIDInitialKeyRepeat / HIDKeyRepeat property arrives (ns / 1e6;
  values in 125,000..15,125,000 ns become 16 ms).
- KeyboardSettings.appex: `FUN_100045288` reads the live HID values (`NXKeyRepeatThreshold`, `NXKeyRepeatInterval`,
  seconds) and turns them into slider ticks with x 1000 / 16.666666666666668, i.e. 1 tick = 1/60 s; `FUN_1000453e0`
  writes KeyRepeat / InitialKeyRepeat (ticks) and calls `NXSetKeyRepeatInterval(ticks / 1000 x 16.667)` /
  `NXSetKeyRepeatThreshold` only when the user moves a slider. So 83 ms = 4.98 ticks, 500 ms = 30 ticks.
- `ipsw dyld str "InitialKeyRepeat"`: the only cache image with that exact cstring is MachineSettings; on the system
  volume Dock and WindowManager hold "HIDInitialKeyRepeat" (Dock 0x10003dddc reads it back from the event system).
- Inferred (bounded search): nothing sets other values on a fresh account, so it repeats every 83 ms (12.05 / s) after
  500 ms, the same as the kernel's IOHIDSystem defaults already cited. "KeyRepeat" (9 bytes, a Swift immediate) was not
  searched across the cache, so a reader of that key alone cannot be excluded.

Our 12 / s and 500 ms stand; only the comments changed (`shell/lib/state.js` luaInput, `settings/Parsers.js`
inputDefaults, `shell/services/Prefs.qml`). Hyprland takes whole repeats per second: 12 = 83.3 ms against 83.

## Still unknown
- The fan's -24 direction (root layer flip / window origin), the hover plate's stock default, the implicit bounds
  curve during the fan open.
- Which Mac framework draws the emoji popover's category bar; light-mode glyphs on the Mac.
- Whether any process reads a KeyRepeat key that is absent and pushes a non-default value.
