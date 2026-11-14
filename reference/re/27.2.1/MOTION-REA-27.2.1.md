# Motion REA, macOS 27.2.1 (26B131): Mission Control exit, Stage Manager in Mission Control, Dock stacks

Static reverse engineering on the Linux PC. No Mac, nothing run. Marks: **confirmed** (read from code or data at the
address given), **inferred** (reasoned from code that was read, the reason is given), **not found** (what was tried).
Pseudocode excerpts: `decomp/motion-gaps.c`.

## Method (PC, Linux)
- Binaries from the system volume `141-12228-174.dmg`, read through the apfs-fuse mount another agent had open
  (`~/Downloads/macos/re-work/gaps-panels/mnt/root`, read only):
  `System/Library/CoreServices/WindowManager.app/Contents/MacOS/WindowManager` and
  `System/Library/CoreServices/Dock.app/Contents/MacOS/Dock`. Both thinned with `llvm-lipo -thin arm64e` into
  `~/Downloads/macos/re-work/gaps-motion/`.
- WindowManager (WindowManagerAgent, Swift): `rea decompile-all` with Ghidra 12.1.4 (REA CLI, one process), 37 576
  functions written, 1 failed. Evidence `ev_c51505b387340984dd73907b123db2f8d1f1e916337baa30040e6bc09ca59046`,
  target sha256 `7930cac571a45ffc22327a95de5d9dbe508cee363231a2ea7042cb73ae999cc8`. Output
  `gaps-motion/rea-wm/out/functions/<address>.c`. Swift type and field names from `__swift5_fieldmd`
  (`reference/re/tools/fields.py`); protocol witness tables from `__swift5_proto` (`gaps-motion/tools/conf.py`,
  `tools/wt.py`). `ipsw macho disass` where Ghidra dropped a register.
- Dock (ObjC): method addresses from `ipsw macho info --objc -V`; `ipsw macho disass --vaddr` names every
  objc_msgSend selector; Ghidra 12.2 headless (project `gh-motion-gaps`, heap 4 GB) for pseudocode. Constants read
  from the file (`gaps-motion/tools/rd.py`). REA `decompile-all` (Ghidra 12.1.4) of the Dock range 0x100019000..0x100072400 (2 183 functions, 0 failed;
  covers every Dock address in sections 3.1, 3.3, 3.4 except the pile block 0x10000dea8 and 0x10000c3b4, which are
  Ghidra 12.2 + ipsw only): Evidence `ev_731b85061d02cd9faaa87e77ae983788b938162faed9f8bf9f70aadc2d15ba70`, target
  sha256 `05afb17136251d5377b14a24c4edf861c67f4c3eab646315b073a972a3e55e8a`, output `gaps-motion/rea-dock/out`.
- The Dock's menu and hover label were left to the other agent.

## 1. Mission Control exit with several windows

| What | Value | Mark |
|---|---|---|
| Who runs it | WindowManagerAgent `SingleSpaceTransitionModifier` (fields inputModel, source, transitionMode, fromMode, toMode, trigger, stageManagerToggleModifier, missionControlToggleModifier). Its transitionMode is `standard(SingleSpaceStandardTrackableTransitionInternalModifier)` or `reducedMotion(...)` | confirmed (field descriptors) |
| One spring or one per window | One. `SingleSpaceStandardTrackableTransitionInternalModifier` holds a single `springBehavior` field for the whole transition (fields: inputModel, psnToWindowID, psnToWindowIDByDisplay, springBehavior, crossSpaceWindowIDs, displayFrame, appIconAlphaTransitionScaleFactor). No delay, stagger, index or distance field | confirmed (fields) |
| How each window moves | Every animated value (frame, alpha, ...) is its own `SpringAnimation` {behavior, targetValue, displacement, velocity, epsilon, stability}, stepped by a closed-form damped spring: 0x10003e8a8 (4 lanes, CGRect), 0x10003ea9c (3 lanes); critically damped branch `x(t) = (x0 + (v0 + w x0) t) e^(-w t)` when dampingRatio == 1.0, cosh/sinh above, sincos below | confirmed (REA ev_c515..., 0x10003e8a8, 0x10003ea9c) |
| Consequence | All windows share one behaviour and start together, so each window covers the same share of its own distance at the same time. Distance changes the pixels, not the curve | inferred (from the two rows above; no per-window term found in 0x1003a733c) |
| Spring chosen | `SingleSpaceTransitionModifier` 0x1003aadb4: reduced motion (byte +0x44 of the input == 1) -> the reducedMotion mode; else if `fromMode` and `toMode` both pass the test "ExposeMode tag byte (+0x10) >= 0xfe" (0x1003ad130, `cmp w8, #0xfe`) -> spring global 0x1005fdb08 = (dampingRatio 1.0, response **0.38**) (built by 0x1001343cc, `0x3fd851eb851eb852`); else -> ExposeSpring (1.0, **0.25**) (0x1005fdb30 / 0x1005fdb38, read at 0x1003aaf04) | confirmed (0x1003aadb4 asm 0x1003aae48..0x1003aaf30) |
| Which modes take 0.38 | `ExposeMode` cases in declaration order (agent's `ExposeMode.CodingKeys`): off, missionControl(MissionControlStyle), appExpose(AppExposeTarget), showDesktop. Which of them have tag byte >= 0xfe was not decoded | not found (see below) |
| Trackpad | 0x1003a72ac calls 0x1001345e4 first: response x 0.6 when abs(velocity) > 5.0 (ExposeTrackpadSpringResponseScale, ExposeTrackpadVelocityThreshold) | confirmed |
| Phases | `TrackableTransitionModifier` phase = prepare / tracking(percent) / animate(cancelled, velocity); the hotkey path is `ExposeModeComponent.State.Progress.animated(velocity)` | confirmed (field descriptors); the velocity a hotkey exit passes was not traced |
| Tracking | 0x1003a733c clamps the percent to 0..1 and lays every window out from that one value (one progress for all windows while a gesture tracks) | confirmed (0x1003a733c lines 476-483 of the REA file) |
| App icons under the thumbnails | `appIconAlphaTransitionScaleFactor` = 2.0 (0x1003a5410 stores `0x4000000000000000` at +0x398); alpha = min(1, 2 p) at 0x1003a733c (REA line 734), a second form max(0, 2 p - (2 + x)) at line 974 | confirmed value; which form is enter / exit not traced |
| Other static springs in the same table | (1.0, 0.2) 0x1005fdb18, (1.0, 0.1) 0x1005fdb28, (1.0, 0.3) 0x1005fdae8, (0.86, 0.15) 0x1005fdaf8 (0x1001343b0..0x100134408) | confirmed values, users not traced |

Why a 4-window exit could start slower (.21 at the first frame) than a 1-window exit (.34): **not in the code that was
read**. Nothing in the modifier scales the spring, its start or a delay with the window count. Inferred: the
difference comes from the start state (a velocity carried over from the enter spring if it had not settled, or the
hotkey velocity) or from the share-of-pixels metric over overlapping windows. Two candidates that would change the
curve for every window count alike: the response is 0.38 instead of 0.25 if off and missionControl both pass the 0xfe
test (the enter fit in MAC-ANSWERS was 0.41), and the start velocity.

Z order while flying, raise before / after, cross-fade: **not found**. Searched the field descriptors (only
`VisualPropertiesSnapshot.systemLevel`, `WindowTag`, `ComponentCommonAction.makeKeyWindow`), strings ("order", "raise",
"front"), and the standard modifier's REA pseudocode; no ordering call was tied to the exit.
Key (active) look relative to the flight: **not found**. `ComponentCommonAction` has `makeKeyWindow`,
`exitExpose(animated, exitIntent, isCancelExit)` and `ShadowProperties {activeStyle, inactiveStyle}` (the shadow is
WindowManager's, the title bar is the app's), but the order of these actions on a selection exit was not traced.

hyprk: `shell/modules/MissionControl.qml` `m.expose` = `SpringLib.fromResponse(0.33, 1)`, `m.exposeExit` =
`fromResponse(0.25, 1)`, `m.exitKick` = 10. The Mac's code has one shared critically damped spring for all windows,
as hyprk; the response is 0.25 or 0.38 (tag test not decoded) and no kick constant exists in the code (a velocity comes
from `animated(velocity)`). No change is proposed until the tag test is decoded.

## 2. Stage Manager + Mission Control

| What | Value | Mark |
|---|---|---|
| Space container | `SpaceContainerComponent.childComponentMode` = freeform / stageManager / missionControl / appExpose / showDesktop: Mission Control replaces the Stage Manager child of the space with a `MissionControlSpaceComponent` | confirmed (field descriptors) |
| Mission Control's windows | `MissionControlSpaceComponent.State` {windows, windowsByDisplayID, space, ...} feeds `MissionControlLayoutComponent.InputModel.windows`; no stage, strip or window-set field in either | confirmed (fields) |
| Stage Manager's own filter | `StageManagerSpaceComponent` keeps `unfilteredInputModel` and `ComponentState.filteredInputModel`: the stage / strip split is inside the Stage Manager child, which Mission Control replaces | confirmed (fields) |
| Answer | Mission Control lays out every window of the space, the strip apps' windows included (they are windows of the same space, not of another space) | **inferred** (from the three rows above; the code that builds `State.windows` was not read) |
| Separate path | Stage Manager has its own inline App Exposé (`StageManagerSpaceComponent.Mode.expose`, `StageManagerInlineAppExposeTransitionModifier`, `exposeStripAssignmentComponent`): App Exposé while Stage Manager is on stays in the strip | confirmed (fields) |

hyprk: `shell/services/StageManager.qml` parks other apps' windows on `special:stage`, so
`shell/modules/MissionControl.qml` shows only the stage's windows. Mac (inferred): all windows of the desktop. Change
when confirmed on a Mac still.

## 3. Dock stacks (Downloads)

### 3.1 Automatic, Fan or Grid (confirmed, `-[DOCKStack expandUsingHandler:...]` 0x100019dc4)
- Stage: the screen without the menu bar, minus the Dock (`fLastBarRect` height for a bottom Dock, width for a side
  Dock); stage = {x + int(0.1 W), y, int(0.8 W), int(0.8 H)} (0.1 at 0x1002581f8, 0.8 at 0x100258438), asm
  0x10001a098..0x10001a0e8.
- Automatic (`_viewAs` 0): bottom Dock: **Fan when items <= stageH / 64**, else Grid (0x10001a16c, 1/64 =
  0x3f90000000000000). Side Dock: Grid. Fan chosen on a side Dock: Grid (0x10001a144). List: a menu
  (`showStackAsMenu:`).

### 3.2 The tile's pile (confirmed)
- At most 3 items (`_maxNumberOfCollapsedItems` = 3, 0x10000c3b4), newest in front.
- Drawn in a 128 x 128 pt canvas, CG y up (block 0x10000dea8, asm 0x10000dfe8..0x10000e0e0). Front item
  116 x 116 at (6, 0). Each item behind is 12 pt smaller (6 each side) and its bottom 18 pt higher, centred in x:
  2 items: back (12, 18, 104); 3 items: back (18, 36, 92), middle (12, 18, 104), front (6, 0, 116).
  Top edges at 116, 122, 128. **No rotation, no x offset**.
- In tile units: front = 0.906 of the tile, bottom-aligned; the next item 0.8125 of the tile with its bottom 0.14 of the
  tile higher; the third 0.719, bottom 0.28 higher.
- The fan starts from and returns to `getCollapsedLayoutFrames:count:` 0x100067df4: s = 1 / 2 / 3 for tile < 32 /
  < 48 / larger; frame i = {s(i+1), 3 s i, W - 2 s(i+1), H - 2 s(i+1)}.

hyprk: `shell/modules/Dock.qml` `stackIcon` = 0.92 (both items centred, same size), `stackPhoto` = 24/33. Mac: front
116/128 = 0.906 bottom-aligned; second 104/128 = 0.8125 with its bottom 18/128 above the front's; a third at 92/128,
36/128 up. The newest 3, not 2.

### 3.3 Fan (confirmed unless marked)
- Item box 64 x 64 pt, icon 64 (`_itemSize`, `_itemImageSize`, 0x100071acc). Pitch 64 pt.
- Max items = floor(stageH / 64) (0x100071fa0). When there are more, the last slot reads "N More in Finder" (N = items
  left, including that slot); when all fit, one more slot "Open in Finder" (DOCKFolder 0x10001df18, strings
  `%@ MORE_IN_FINDER`, `SHOW_IN_FINDER`).
- Arc (`-[DOCKStackFanLayer layout]` 0x100072030): a circle of radius **3000 pt**. Item centre i at height
  y_i = 32 + 64 i above the fan origin; x offset dx_i = 3000 - int(sqrt(3000^2 - y_i^2)) (to the right);
  rotation -atan(y_i / (3000 - dx_i)) (= -asin(y_i / 3000)) about z. Ints are truncated at each step.
  Example: item 10 (y 672): dx 77, rotation -13.0 deg. The x-centre term is added to both x and y in the code
  (`position = (x0 + dx, x0 + y)`).
- Fan frame: the tile's frame moved 24 pt down (0x100071f98, -24), so with a square tile of side t the first centre is
  t + 32 - 24 = t + 8 above the tile bottom (inferred from the frame and layout code; the item anchor was not read).
- Label: Liquid Glass pill (radius 13, group "dock-fan-background"; non-glass radius 4), anchor at its right-centre,
  5 pt left of the icon, centred on the icon in y (RTL: mirrored), SF 13 pt, width <= 500 pt
  (0x100042d78, 0x100042474, 0x10001f894, 500.0 at 0x100258068).
- Open (`-[DOCKStackFanAnimator expand:]` 0x100063c2c): items start at the pile frames, then in one CATransaction
  each flies along the 3000-pt arc (CAKeyframeAnimation on position along CGPathAddArc), its rotation set to the
  layout angle; the label goes opacity -> 1 and scale 1e-5 -> 1. Curve kCAMediaTimingFunctionEaseInEaseOut, duration
  = `[CATransaction animationDuration]` (Shift slow motion 5 s). **No per-item delay** (no setBeginTime: in the
  function). The duration value itself: no setter on this path, so the CATransaction default 0.25 s applies
  (**inferred**).
- Close (0x100064d90): the same arc back into the pile frames, label scale -> 1e-5, ease-in-out, same duration. The
  first 3 items stay opaque (they become the pile); the others fade at the end: opacity -> 0 from D - 0.05 for 0.1 s
  (-0.05 at 0x100258430, 0.1 at 0x1002581f8). Display as Folder instead: all fade from D/3 over 2D/3.

### 3.4 Grid (confirmed unless marked)
- Cell (`_sizeForStage:` 0x10001b4d4): base = 16 x preferredItemSize + 80 = **128** at the default size 3
  (0x100095e78), clamped 80..512; pitch for fitting = base + 28. n = min(items, floor(stageW/pitch x stageH/pitch));
  columns = floor(sqrt n) (+1 when the remainder is less than the rows), rows = n / columns; cell =
  min(stageW / columns, stageH / rows, base). Icon = cell - 28 (100 pt at 128).
- Cell inside (`-[DOCKStackGridItemLayer layoutSublayers]` 0x10001f44c): icon at (14, 22) in the cell (14 pt each
  side, 22 pt below for the name, 6 pt above), name layer {1, 0, cell width, 22}, centred text.
- Panel: W = columns x cell + 34 (+8 with an always-on scrollbar and scrolling), H = rows x cell + 44 (+10 with the
  title, so 54), +12 W on a side Dock.
- Inside (`layout` 0x10001bfb8, bottom Dock): glass background = bounds with 12 pt kept at the bottom for the tail; grid
  rect {17, 24, W - 34, H - 44} (minus 10 for the title); title on top, width <= 0.75 W; 1 pt divider lines above and
  below the grid.
- Glass: `ECCartoucheGlassLayerController` size 2 (0x10001a794): radius **26**, tail = square 24 pt rotated 45 deg
  with corner 5, offset 5, size table (34, 10) for a bottom Dock (0x10018767c, 0x10018772c, 0x1001877dc, 0x10018788c,
  0x100186e18; size 1, the hover label, is 13 / 16 / 2.5 / 4 / (15, 8)). Non-glass: radius 5. The tail points at the
  tile centre (`setCenter:`).
- Place (0x10001bc58, asm 0x10001bd9c): x = tile centre - W/2, kept 30 pt inside the screen; y = edge + 11
  (magnification on: + 5).
- Open (`-[DOCKStackGridAnimator expand:]` 0x10001f9c0): the panel starts at the tile's centre, scale 1e-5, opacity 0;
  in one CATransaction it goes to scale 1 (CATransform3DIdentity, 0x10001fc34), opacity 1 and its own position
  together. No duration and no timing function set: CATransaction defaults (0.25 s, **inferred**). No per-item
  motion. Close (0x10002165c): the reverse into the tile.
- Reduce Motion (both views): shown / hidden at once.

hyprk: none of this exists. `shell/lib/dock.js` (Display as: Fan / Grid / List / Automatic disabled) and
`shell/modules/Dock.qml` line 645 (`Apps.openFolder` on a click) open a folder window. New code would take the numbers
above: Automatic = Fan while items <= floor(0.8 x (screenH - menu bar - Dock) / 64), fan pitch 64 on a 3000 pt circle,
grid cell 128 / icon 100 / radius 26, 0.25 s ease-in-out (fan) and CA-default zoom from the tile (grid).

## 4. Apps panel
Not done: time went to 1 to 3. The repo's measured metrics (`shell/lib/appsgrid.js`) and the Spotlight window springs
(SPOTLIGHT-27.2.1.md section 1) stand.

## Not found
1. Which `ExposeMode` cases pass the `tag byte (+0x10) >= 0xfe` test in 0x1003ad130, so whether Mission Control
   enter / exit use (1.0, 0.38) or (1.0, 0.25). Tried: the agent's field descriptors (the enum is declared in
   WindowManager.framework; only its CodingKeys are in the agent), the value-witness functions with `cmp #0xfe`. Next:
   the enum's field descriptor and value witnesses in WindowManager.framework (dyld cache), or a store of `.off` /
   `.missionControl` into a known field.
2. The velocity a hotkey exit passes to `animated(velocity)`.
3. Z order of the picked window during the exit flight, and when it becomes key. Tried: field descriptors, strings,
   the standard trackable modifier's pseudocode.
4. The code that fills `MissionControlSpaceComponent.State.windows` (so section 2 stays inferred).
5. The CATransaction default duration on the Dock's stack paths is the CA default by absence of a setter; an outer
   transaction set by a caller was not searched beyond `expandUsingHandler:`.
6. The fan item layer's anchor point (where the first icon sits above the tile, to the point).
7. Apps panel (section 4).

# Round 2 (2026-11-14)

Same binaries, same REA decompile-all output (`gaps-motion/rea-wm/out`, Evidence
`ev_c51505b387340984dd73907b123db2f8d1f1e916337baa30040e6bc09ca59046`) and the same objdump listing
(`gaps-motion/wm.dis`). No new Ghidra import. New work dir `~/Downloads/macos/re-work/gaps-motion2`:
`f2.py` (fields.py that prints the GOT slot of an indirect type reference instead of guessing a dyld-cache address),
`ctx.py` (context descriptor name at an address), `fixups.txt` (`ipsw macho info --fixups` of the agent: every GOT
slot of a type reference is an auth-rebase to a descriptor inside the agent, so the `{?}` names of round 1 resolve),
`fields-all.txt` (all field descriptors with GOT slots), `sui-swift.txt` (`ipsw dyld macho ... SpotlightUIInternal
--swift`). Pseudocode excerpts: `decomp/motion-gaps.c` part F.

## R2.1 Which transitions take (1.0, 0.38) and which (1.0, 0.25)

| What | Value | Mark |
|---|---|---|
| Type of `fromMode` / `toMode` | `SpaceWindowingMode`, not `ExposeMode`. Field descriptor of `SingleSpaceTransitionModifier`: both point at GOT 0x1005d3120, a rebase to 0x10052a208, the enum descriptor named `SpaceWindowingMode` | confirmed (fixups + descriptor name) |
| Its cases | single-payload enum (field descriptor kind 2): `appExpose(AppExposeTarget)`, then the empty cases in order `freeform`, `stageManager`, `missionControl`, `showDesktop` | confirmed (field descriptor at the GOT 0x1005d3120 entry of `fields-all.txt`) |
| Payload layout | `AppExposeTarget` = multi-payload `process(CanonicalProcessSerialNumber {hi, lo: UInt32})`, `bundle(BundleIdentifier)` (BundleIdentifier.Symbol = other(String) / finder / dock / notificationCenterUI). 16 bytes of payload and a tag byte at +0x10 (0 process, 1 bundle) | confirmed: the test 0x1003ad130 loads the 16 bytes with `ldp x0, x1, [x9]` and the tag with `ldrb w2, [x9, #0x10]` (0x1003ad140) |
| Empty cases | stored as tag-byte values 0xfc..0xff. The modifier's init (0x1003acd70..0x1003ad0a8) switches on exactly these four (`sub w16, w8, #0xfc; cmp #3`, jump table 0x1003ad0d4) | confirmed |
| Which value is which | freeform 0xff, stageManager 0xfe, missionControl 0xfd, showDesktop 0xfc | **inferred** from the Swift ABI rule for extra inhabitants of a tag byte (counted down from all ones, empty case n = 0xff - n), checked against the init: a 0xfe <-> 0xff change creates `stageManagerToggleModifier` (0x1003acfcc), a {0xfc, 0xfd} <-> 0xff change creates `missionControlToggleModifier` (0x1003ad030), a {0xfc, 0xfd} <-> 0xfe change creates `stageManagerToggleModifier` (0x1003acf74, 0x1003acec8). That is what freeform = 0xff, stageManager = 0xfe gives. 0xfc vs 0xfd (which is Show Desktop) rests on the ABI rule only |
| The selector | 0x1003aadb4: `b.lo` (tag < 0xfe) on either mode -> ExposeSpring (1.0, 0.25); both >= 0xfe -> (1.0, 0.38) | confirmed (asm 0x1003aaea0..0x1003aaf30) |
| Answer | (1.0, **0.38**): only freeform <-> stageManager, that is turning Stage Manager on or off. (1.0, **0.25**): every Mission Control enter and exit (from the desktop or from Stage Manager, hotkey, gesture end, click on a window, click on the background), App Expose in and out, Show Desktop in and out | confirmed for the split at 0xfe; the case names inferred as above |
| Trigger and exit intent | not read by the selector: a hotkey exit and a window-pick exit take the same spring | confirmed (only +0x44 reduce motion and the two tag bytes are read before the spring is built) |

The Spring type. `SpringBehavior.init(dampingRatio, response)` 0x100073a14 (REA ev_c515..., asm 0x100073a30..0x100073a60):
- k = (2 pi / response)^2 (`0x1004a1ce8` = 6.283185307179586), stored as `tension` (+0x20).
- c = dampingRatio x 2 sqrt(k), stored as `friction` (+0x28).
- mass 1. `settlingDuration` (+0x30) = `CASpringAnimation(mass 1, stiffness k, damping c).settlingDuration`
  (0x10007394c).
- So the two numbers are (damping ratio, response): mass / stiffness / damping 1 / 631.65 / 50.27 for (1.0, 0.25)
  and 1 / 273.40 / 33.07 for (1.0, 0.38). Not duration and bounce. Confirmed.

The step, 0x10003e8a8 (4 lanes) and 0x10003ea9c (3 lanes), exact closed form over the frame's dt, per lane
(x = displacement from the target, v = velocity, b = c / 2 = dampingRatio x 2 pi / response, w0^2 = k):
- dampingRatio == 1: x' = (x + (v + b x) dt) e^(-b dt); v' = ((v + b x) - b (x + (v + b x) dt)) e^(-b dt).
- dampingRatio > 1: with s = sqrt(b^2 - k): x' = (x cosh(s dt) + (v + b x) sinh(s dt) / s) e^(-b dt); v' from the same
  terms (cosh / sinh branch).
- dampingRatio < 1: the same with s = sqrt(k - b^2), cos / sin.
- A third output per lane is x'^2 + (v' x 2 b / k)^2 (a settle measure, compared with `epsilon` elsewhere: inferred from the field name).
Confirmed (REA ev_c515..., 0x10003e8a8). Because it is exact, the curve does not depend on the frame rate.

For Mission Control (1.0, 0.25), from rest: p(t) = 1 - (1 + 8 pi t) e^(-8 pi t) (b = 25.133 / s).

## R2.2 Start velocity, and how the progress maps to the windows

| What | Value | Mark |
|---|---|---|
| The `animate(cancelled, velocity)` handler | 0x1003a9840 (witness) -> 0x1003a72ac. The velocity (d0) goes only to 0x1001345e4, which swaps the spring for one with response x 0.6 when abs(velocity) > 5.0. Then d0 is overwritten with the target (`fcsel d0, 0, 1` on `cancelled`, 0x1003a72ec) and 0x1003a733c lays every window out for that target with the chosen spring | confirmed (asm 0x1003a72ac..0x1003a7338) |
| Start velocity of the windows | not taken from the gesture or hotkey. Each value is a `SpringAnimation {behavior, targetValue, displacement, velocity, ...}`; a new target changes the displacement, the value's own velocity carries on. From a settled Mission Control it is 0 | confirmed that the trigger velocity is not passed on; "own velocity carries on" inferred from the struct (the retarget code is in generic specializations 0x10003ef50..0x10003fd58, not read to the end) |
| Hotkey or click velocity | not traced (the value passed in `Progress.animated(velocity)`). It can only matter through the 0.6 swap. The R2 recording (below) fits the unswapped 0.25 | inferred |
| Map from the spring to the window | none. The window's frame is one `SpringAnimation` over a CGRect (x, y, w, h) with one behaviour, so every lane follows the same p(t): frame = from + (to - from) p(t). Size and position move linearly with p, together | confirmed (4-lane CGRect step 0x10003e8a8, one `springBehavior` per transition, round 1) |

Per-frame values at 60 Hz, p(k / 60) from rest, (1.0, 0.25):

| frame k | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| p | .067 | .205 | .358 | .499 | .619 | .715 | .791 | .848 |

Then .890, .921, .944, .961 (k = 9..12), .990 at k = 16. Confirmed as arithmetic from the decoded closed form; where
frame 1 falls against the key press is not in the code.

Against the judge (JUDGE-95-7 line 85, ".34 first frame vs R2 .21"): the Mac's .21 is the k = 2 value from rest
(.205). Ours with `exitKick` 10 (start velocity 10 distance/s, same spring) gives .176 at k = 1 and .349 at k = 2,
which is our .34. So the gap is our kick, not the window count. Inferred (the judge's frame alignment is assumed to
be the same on both sides, it is not stated).

hyprk: `shell/modules/MissionControl.qml` `m.exitKick` = 10 against the Mac's 0 (no start velocity in the code).
`m.exposeExit` = fromResponse(0.25, 1) matches. `m.expose` (enter) = fromResponse(0.33, 1) against the code's 0.25
(enter is freeform -> missionControl, tag 0xff -> 0xfd: ExposeSpring); 0.33 was fitted to the R2 enter series, so
the difference is in how that series was measured, not in the Mac's spring.
Stage Manager on / off (freeform <-> stageManager) is (1.0, 0.38) on the Mac. hyprk has no spring for that toggle
(`shell/modules/StageStrip.qml` `flightSpring` 0.25 is for stage switches, a different modifier).

## R2.3 Z order and key state on exit

Not found. Tried: the `ComponentCommonAction` cases (`orderWindow` index 1, `makeKeyWindow` 11, `resignKeyWindow`
12, `exitExpose` 17, of 72; an indirect enum, so the case is in pointer bits and the emit sites could not be found by
a constant search); the order-front log strings (0x1004efda0..0x1004efe80, used by the order-front resolver at
0x1004212f4..0x1004233d0, not tied to the Expose exit); `VisualPropertiesSnapshot.systemLevel` (a per-window level
the transition could raise, its writer in 0x1003a733c not identified); the round 1 search. No answer is given.

## R2.4 Stage Manager on: Mission Control's window list

| What | Value | Mark |
|---|---|---|
| `MissionControlSpaceComponent.State.windows` | type `SingleSpaceComponentWindowModel` {orderedSpaceWindowIDs, windowIDToWindow, persistentWindowIDToWindowIDs}: the space's whole ordered window list, the same type as `SingleSpaceComponentInputModel.windows` (the space's input) | confirmed (types resolved through GOT 0x1005d2918, 0x1005d28f8) |
| Where Stage Manager filters | only inside `StageManagerSpaceComponent`: `unfilteredInputModel` and `ComponentState.filteredInputModel` (both `SingleSpaceComponentInputModel`) | confirmed (fields) |
| Who builds the state | the MC component's update 0x1002281c0 assigns `state` (field offset global 0x100606dd8, setter fragment 0x1002300c8) from 0x10022a2a4(state, input); 0x10022a2a4 walks the input's dictionaries, no stage or strip type in it | confirmed addresses; what 0x10022a2a4 drops was not read to the end |
| Answer | Mission Control with Stage Manager on lays out every window of the space, the strip's included | **inferred** (from the types: no stage-filtered model reaches the MC component, and the SpaceContainer replaces the Stage Manager child by the MC child). The forwarding code was not read to the end |

hyprk: unchanged from round 1 (`shell/services/StageManager.qml` parks strip windows on `special:stage`, so
Mission Control shows the stage only).

## R2.5 The Apps panel

| What | Value | Mark |
|---|---|---|
| What it is | not a panel of its own: `SpotlightXPCServerMessage.launchAppsBrowsing` opens the Spotlight window with `RootStackCoordinator.RootDestination.appsBrowsing` (`lazy appsBrowsingStackItem`, `SearchNavigationDestination.appsBrowsing(AppsBrowsingConfiguration {viewController: SearchResultsViewController})`) | confirmed (SpotlightUIInternal Swift metadata, `sui-swift.txt` lines 1334, 1366, 4010, 4231, 4281) |
| Open / close motion | the Spotlight window's: open content scale 1.12 -> 1 on Spring(0.28, 0.32), window alpha 0 -> 1 Spring(0.28, 0.41), blur 25 -> 0; close scale to 1.12 / 0.95 Spring(0.45, 0.05), alpha Spring(0.28, 0.41), blur 0 -> 25 Spring(0.51, 0.05) (SPOTLIGHT-27.2.1.md section 1). It grows from the window's own centre, not from the Dock tile | inferred: the same window and root coordinator; the launchAppsBrowsing path was not traced to the animator, so a different invocation state for it is not ruled out |
| Size change capsule -> 844 x 617 | `WindowAnimatedHeightModifier` / `WindowAnimatedWidthModifier` {value, alignment, windowAnimation: WindowAnimationCoordinator, windowSize}: animated, spring not mapped | not found (time box) |
| Grid metrics | `shell/lib/appsgrid.js` matches `live/dock/apps-window.json` in every number (panel 844 x 520 at y 97, chips 117 - 97 = 20, suggestion icons 167 - 97 = 70, separator 265 - 97 = 168, A-Z 284 - 97 = 187, columns 7, pitch 115, first centre 77, icon 60, row 102, label cap 11.5, ring 69 / 3.5, plate 68). The one unmeasured value: the grid top while a search is typed (appsgrid.js uses 20, as a category) | measured (no code value for these found) |

## Round 2 not found
1. Z order of the picked window during the exit and when it turns key (R2.3).
2. The velocity in `Progress.animated(velocity)` for a hotkey and a click; it only matters if above 5.0.
3. Whether 0xfc is Show Desktop and 0xfd Mission Control, from code (it does not change any spring).
4. The window list forwarding into `MissionControlSpaceComponent` read to the end (R2.4 stays inferred).
5. The Apps view's size-change spring and its open path (R2.5).

## Note from the PC session (2026-11-14): `exitKick` stays

Round 2 proposes `MissionControl.qml` `m.exitKick` 10 -> 0 because the code starts the windows at velocity 0. Not
applied. The Mac's own recording (R2 exit, MOTION-MEASURED.md lines 93 and 416) reads .21 .36 .47 .57 .64 .71 .76 .80
(our series with the kick, which fits it at rms .0105). The decoded spring from rest, response 0.25, taken from its
second frame so that it also starts at .21, gives .205 .358 .499 .619 .715 .791 .848 .892: rms .06 against the
recording, and it ends too early. The same gap exists on enter (code 0.25, recording fits 0.33). So something between
the spring and the screen is still not decoded (as with the NC panel spring, MAC-ANSWERS "why code 1.25 runs as
critically damped"). Until it is, the recording decides. The judge's .34 for four windows is the share-of-change
metric with small thumbnails (MOTION-MEASURED.md session 7), not this constant.

# Round 3 (2026-11-14): stack fan / grid motion, the fan's -24, the hover default, Mission Control exit order

Static reading only, nothing run on a Mac. Dock: the thinned arm64e `gaps-motion/Dock` (sha256 05afb171..., REA Evidence
`ev_731b85061d02cd9faaa87e77ae983788b938162faed9f8bf9f70aadc2d15ba70` for the pseudocode of 0x100019000..0x100072400).
New this round: a full selector-annotated listing of the Dock's `__TEXT.__text`, `ipsw macho disass -x __TEXT.__text
--cache gaps-motion/Dock.a2s` -> `re-work/motion3/dock-full.s` (631 428 lines), so every `objc_msgSend` site of a
selector in the whole binary could be listed (the REA Ghidra provider was not used again: the question was which
selectors are sent where, which the listing answers directly). QuartzCore from the dyld cache (`ipsw dyld disass
--vaddr`, `ipsw dyld dump`) and the extracted `re-work/ex/QuartzCore.macho`. Marks as before: confirmed / inferred /
not found.

## R3.1 Fan open and close (`-[DOCKStackFanAnimator expand:]` 0x100063c2c, `collapse:` 0x100064d90)

| What | Value | Mark |
|---|---|---|
| Duration | `+[CATransaction animationDuration]` read at 0x1000642ec (open) / 0x100064e88 (close). QuartzCore `+[CATransaction animationDuration]` 0x18dd0a978 walks the transaction stack for attribute 0x28 and returns `fmov d8, #0.25` when none set it (0x18dd0a9b8). The Dock has 36 `setAnimationDuration:` sites (listed in `dock-full.s`); on the stack paths only the slow-motion ones, and none in `expandUsingHandler:fromKeyboard:ignoringMouseDraggedEvents:` 0x100019dc4 or its 8 call sites (0x100019d10, 0x100087f90, 0x100088060, 0x100088150, 0x1000a30b0, 0x1000aa58c, 0x1000aa7d8, 0x1000aaa5c), nor in `-[DOCKStack collapse]` before `collapse:` (0x100021090). So **0.25 s** | confirmed (absence bounded to those functions; an outer transaction opened by AppKit around the event was not searched) |
| Slow motion | `slowMotionAllowed` and `+[ECModalEventController shiftKeyDown]` -> `setAnimationDuration: 5.0` (0x1000642e0, 0x100064768, 0x100064ef0; grid 0x10001fbb8, 0x100021790; `-[DOCKStack collapse]` 0x1000210d0 also skips it under Reduce Motion) | confirmed |
| Stagger | none: one transaction, every item in one loop, no `setBeginTime:` on the open; the close's only `setBeginTime:` is the fade below | confirmed |
| Position | one `CAKeyframeAnimation` "position" (0x100064324), `kCAMediaTimingFunctionEaseInEaseOut` (0x100064300, 0x100064334), reused for every item with its own path: `CGPathAddArc(centre = first item + (3000, 0), radius 3000 (0x100258428), start pi (0x100258108), end atan2(...), clockwise)` (0x100064984), duration from the transaction (none set) | confirmed |
| Rotation | `setTransform:(CATransform3DMakeRotation(-atan(y / (3000 - dx)), 0, 0, 1))` on the item (0x1000648ec, 0x100064918) with actions on: an **implicit** animation | confirmed |
| Item size | `setBounds:(0, 0, 64, 64)` (0x1000649e8), implicit; before the flush the bounds were set to the pile frame's size with actions off (0x100064584, 0x10006459c) | confirmed |
| Implicit curve | QuartzCore `_CALayerCreateImplicitAnimation` 0x18dd3e2d0 caches `+[CAMediaTimingFunction functionWithName:]` of cfstring 0x1e2d10710 = "default" (bytes at 0x18e1201e1) and sets it on the action (the transaction's own timing function was not set on these paths: the Dock has no `setAnimationTimingFunction:` on them). QuartzCore's table at 0x18e119380 (file 0x42b380): default (0.25, 0.1, 0.25, 1), linear (0, 0, 1, 1), easeIn (0.42, 0, 1, 1), easeOut (0, 0, 0.58, 1), easeInEaseOut (0.42, 0, 0.58, 1). So rotation and size run on **(0.25, 0.1, 0.25, 1)**, not the position's ease-in-out | confirmed values; table row names inferred from their order matching Apple's documented points |
| Item shadow | `shadowLayer` opacity 0 before (0x100064680), 0.4 (0x1002580d0) in the transaction (0x100064a80), implicit | confirmed; ours draws no item shadow (not built) |
| Label (textBackgroundLayer) | opacity 0 before (0x100064694); a `CABasicAnimation` "opacity" from the presentation value (0x100064aa4..0x100064af8, no timing function: **linear**) to the model 1 (0x100064bb0); a "transform" animation scale 1e-5 -> identity, ease-in-out, `setDuration:` the transaction's (0x100064380, 0x10006438c, 0x100064b0c) | confirmed (an explicit animation with duration 0 takes the transaction's on `addAnimation:`: inferred from CA's documented behaviour) |
| Close | the same arc back (0x10006547c), ease-in-out (0x100065054); rotation / bounds back implicit (0x1000655ac, 0x1000654cc); label scale identity -> 1e-5 ease-in-out, opacity presentation -> 0 linear (0x100065384..0x1000653e8); items past the pile fade from `CACurrentMediaTime() + d - 0.05` over 0.1 s (0x10006518c..0x1000651c8); Display as Folder from d/3 over 2d/3 (0x1000651d8..0x10006520c) | confirmed |
| Open in Finder / More slot | an item like the others (no special motion found in the loops) | inferred |

Built: `shell/lib/dockstack.js` `caTiming(name, t)` (the table above), `fanChannels(ms, d, closing)` (pos ease-in-out,
turn and size "default", label scale ease-in-out, label opacity linear), `fanAt(tile, i, p, q)` (rotation on its own
progress); `shell/modules/DockStack.qml` uses them (the whole label now fades, not only its text). Tests "stack fan
curves" (shell/tests/run.mjs, 397).

Measured (headless, scale 2, dark, tile 50, 7 items + "2 More in Finder", `mcap -k 2` of 300 x 732 pt, top edge of the
top slot): open against the decoded model rms 1.5 pt (12 frames, best start 54 ms after the click), close rms 0.6 pt
(13 frames). The top edge alone barely tells the two curves apart (all ease-in-out: rms 1.3 / 0.8), so the curves rest
on the code, not on the capture.

One inconsistency left: `expand:` computes its own end point from the first item's pile position (y0 + int(32 + y0))
while `layout` 0x100072030 uses int(midX) + int(midY + 32 + 64 i). They agree only if the pile's first centre is at the
frame's middle; with the -24 (R3.3) they differ by 48 - 2s pt, so either a final snap exists on the Mac or a layer in
the conversion (`convertPoint:toLayer:` 0x100064558 between [x19+0x110] and the fan layer) was misidentified. Not
settled; ours lands on `layout`.

## R3.2 Grid open and close (`-[DOCKStackGridAnimator expand:]` 0x10001f9c0, `collapse:` 0x10002165c)

| What | Value | Mark |
|---|---|---|
| Start state (actions off) | hidden NO, opacity 0, transform scale (1e-5, 1e-5, 1), position = the tile layer's bounds midpoint (0x10001fae4..0x10001fb70; the grid layer is a sublayer of the tile's layer, `addSublayer:` 0x10001a254) | confirmed |
| Animated | in one explicit `begin` / `commit` (0x10001fb94 / 0x10001fc78): opacity 1, transform identity, position = its place. All implicit: CA "default" (0.25, 0.1, 0.25, 1), 0.25 s (5 s Shift) | confirmed |
| Scale origin | the layer's anchor point, default (0.5, 0.5): the Dock's only `setAnchorPoint:` calls are the grid cell (0x10001f638) and the fan label (0x100042668) | confirmed |
| Close | the reverse in one transaction (0x10002176c..0x100021894) | confirmed |
| Place | for a bottom Dock y = int(edge) + 11 (+5 magnified), no height subtracted (0x10001bdec..0x10001bee8); `expandUsingHandler:` passes edge = the imageLayer's frame y + height (0x10001a2bc) | confirmed |

Fixed: `lib/dockstack.js gridPlace` takes the icon box top (`DockStack.qml` passes `tileBottom - tile`), not the Dock
background's top. Mac check: Q-dock-12 grid AX group 895,613 546 x 438, bottom 1051; tile 33 bg top 1055 + (47 - 33) / 2
= icon top 1062; 1062 - 11 = 1051 (test "stack grid place"). Ours was 7 pt too high at tile 33.
Measured (same session, `mcap -k 2`, top edge of the panel, p = linear in it): open rms about 0.03 against the
"default" curve (ease-in-out: much worse, its early frames are near 0), close rms 0.010 (ease-in-out 0.042).

## R3.3 The fan's -24 is down

The Dock's stack layers are y up: (1) the grid's place adds 11 to the edge for a bottom Dock without subtracting the
panel height, but subtracts the width for a right Dock (x = edge - W - 11, 0x10001be8c), so the frame origin is the
minimum corner with y growing up; (2) the edge passed is imageLayer y + height, its top in y up; (3) the Mac's AX grid
bottom matches (R3.2); (4) the fan's rotation is -atan(...) for items that go up and to the right, clockwise on screen
only in y up. The only `setGeometryFlipped:` in the Dock (0x1000eacd8) is in a DesignLibrary helper. So in
`expandedFrameForStage:` y - 24 is 24 pt down. With `layout`'s y = int(midX) + int(midY) + 32 + 64 i (0x100072204..
0x10007230c, bounds read at 0x1000720a4: d9 x, d11 y, d10 w, d12 h) the first centre is t + 8 above the icon box bottom,
the item's bottom 24 pt below the icon top: over the tile, which shows a chevron while the stack is open. Changed:
`fanShift` = -24 (was +24, GUESS). Seen on screen: the first item over the tile, its label across the Dock's top edge.
A Mac still of an open fan would confirm the look (and the anchor, inferred as the centre).

Checked on screen (2026-11-14, judge-95-16, headless, scale 2, tile 64): first item box 713..777 pt over the icon box
753..817, its bottom 24 below the icon top as decoded; the tile's chevron ink 779.5..799 stays visible below it. A 64
box on this decode cannot cover a symbol centred on the tile, so the fan was left as is; the chevron is the guessed
part. The Mac draws a Dock.app image there (`s-pileArrow`, `s-pileLeftArrow`, `s-pileRightArrow`, `...2`: cfstrings
0x1002e5988..0x1002e5a48), not an SF Symbol; its frame was not found (no direct adrp / add reference) and the PNGs are
not extracted (the OS dmg needs apfs-fuse).

## R3.4 `mouse-over-hilite-stack` stock value: off

`-[DockGlobals mouseOverHiliteInStack]` 0x1001a4a18 returns a stored byte; DockGlobals' init reads the key through
0x100205fdc (`CFPreferencesCopyValue` at 0x100206018, no registered-defaults lookup), casts with `swift_dynamicCast` to
Bool and stores `cast succeeded AND value` (0x1001a5f0c..0x1001a5f20). Absent key -> false. Confirmed. The plate
(`-[DOCKStackFanLayer setSelectedIndex:]` 0x1000723d0: ECMaterialLayer, bounds + 4, radius 6, 0.15 s at 0x100072600) is
drawn only for drag or keyboard selection; ours has none of either (not built).

## R3.5 Mission Control exit with several windows

Nothing new decoded about the layer order. New facts: `ExposeShieldDisplayItem` / `...Controller` carry
`frontToBackWindowDisplayItemIDs: [DisplayItemID]` (fields, GOT 0x1005d07d0), a front-to-back list kept by the shield
(the wallpaper backdrop); `AppIconDisplayItem.labelAlpha` and the Spaces previews' `selectionAlpha` are
`SpringAnimationValue<Double>` (descriptor 0x100519170). Inferred: the shield's list is for hit testing (hover, drag,
pinch targets in the same controller); whether the exit reorders windows is still not found (Round 2 R2.3 stands).
Decoded earlier and unchanged: one critically damped spring (1.0, 0.25) for every window, no stagger, Spaces bar on its
own 0.125.

Measured on ours (headless, scale 2, dark, 4 overlapping foot windows, `mcap -k 8`, share-of-change metric):
enter .18 .27 .50 .62 .71 .78 .83 .88 .90 .93 from 239 ms; exit by picking the back window term2 .31 .53 .65 .74 .82
.86 .91 .93 .95; hotkey exit .31 .53 .65 .74 .86 .90 .93 .95. The picked window flies on top of the others from the
first exit frame, the others keep their stacking order (term4 over term3). This order is ours, not decoded.
Needs: a Mac 60 fps recording of a 4-window exit by picking a back window (which window is on top in the first frames,
and when it turns key).

## Round 3 not found
1. Mission Control exit layer order and key timing (R3.5).
2. Why `expand:`'s end point and `layout` differ by 48 - 2s (R3.1 last paragraph).
3. The fan item anchor (centre, inferred) and the AppKit transaction around the click (could hold a duration; none
   seen in the Dock's own code).
