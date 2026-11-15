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

**Superseded by Round 4, R4.2**: measured on the windows themselves (mc-exit-4-windows.mov) the exit is the decoded
spring from rest; `exitKick` is now 0.

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

**Wrong, superseded by Round 4, R4.1**: the Mac recording puts every fan slot int(t/2) + y + 24 above the icon box
bottom (the 24 is up); `fanShift` is now +24.

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

# Round 4: Mac recordings (2026-11-14)

Measured on the PC from the Mac's round 2 clips (MAC-ANSWERS-2.md M1.4, M1.5): `screens/27.2.1/dock/stack-{fan,grid}-
{open,close}.mov`, `stack-{fan,grid}-open-dark.png`, `screens/27.2.1/live/mc-exit-4-windows.mov`. H.264, 60 fps time
base, variable frame rate: every frame was extracted with its pts (`ffmpeg -vsync passthrough -frame_pts 1`, file
name = pts in 1/60 s) and times are taken from the pts, never the frame index (a frame missing from a run means the
screen did not change, or one dropped frame: grid open has no frame at 0.450 s). 2 px per pt. Curves fitted by least
squares over the start time (`fit.py`: CA's named curves from QuartzCore's table, critically damped and under-damped
springs). Ours: the headless session (scale 2, 1280 x 832 pt), `mcap -k 2` (fan, 1 sample per pt) and `-k 4` (Mission
Control, full output), `long_intervals` 0 in every run, the same metrics as on the Mac clips. Scratch scripts and
frames: the session's scratch dir (`agent-m2`), not kept. Marks: **measured** (from the clip, numbers given),
**inferred** (reason given).

## R4.1 Downloads stack, fan and grid

Stage: Dock tile 31 pt, stack tile centre x 982, icon box bottom 921 pt (from the Pages icon's box next to it and the
chevron plate: 919.75-921), 13 files + 1 folder, Date Added. Fan: 9 items + "5 More in Finder".

| What | Mac (measured) | Ours before | Ours after | Mark |
|---|---|---|---|---|
| Fan slot heights | label pill centres of slots 0-6 at 83.7, 147.7, 211.9, 275.8, 339.8, 404.0, 468.2 pt above the icon box bottom: pitch **64.0**, slot 0 = int(t/2) + 47 + 24 - 2.2 (the 2.2 is within the box-bottom estimate). Every one of the 10 slots, its 64 box turned by the decoded angle, overlays the art (rotated boxes drawn on f00054) | `fanShift` -24: slot 0 at 38 pt, rms **46.9 pt** (peak 52) over the 10 slots, the first item over the tile | `fanShift` +24: rms **2.2 pt** over slots 0-6 (a constant offset, the box-bottom estimate); slots 7-9 not read (pills merged in the profile) | measured; settles R3.3 (the -24 is up on screen, not down) |
| Fan x offset | slot 0 centre x 983 (dx 1), the column leans right as decoded (3000 pt circle) | same formula | unchanged | measured |
| Fan open: position | item 0 (the folder) bottom 1794 -> 1661 px over 14 frames from 0.417 s: **ease-in-out 0.25 s, rms 0.012**, start 30 ms before the first moving frame (default 0.25: 0.031; spring 0.25: 0.039) | ease-in-out 0.25 | ours captured: item 0 rms **0.0047** to ease-in-out 0.25 (start 64 ms after the synthetic click) | measured; confirms R3.1 |
| Fan open: item size | **64 from the first frame**: folder art 117 px (58.5 pt) wide in every frame 0.417 -> 0.633 s; at the first frame item 0 is centred on the tile at full size | grew from the pile's side on "default" (at 47 ms into the open: about 39 pt) | 64 throughout (`fanChannels().size` = 1 while opening) | measured (the decoded implicit bounds animation does not show) |
| Fan open: stagger | none: item 0 and the top slot reach .5 / .95 in the same frames | none | none | measured; confirms R3.1 |
| Fan close: position | item 1 (Data.json) centre: **ease-in-out 0.25 s, rms 0.0025**, start about 50 ms after the last still frame | ease-in-out | unchanged | measured |
| Fan close: item size | item 1 page width 86 -> 78, 70, 61, 53, 47, 42 px: side = 64 - 43.5 x default(t / 0.25) with the same start (the ratio (64 - side) / default(t) is 43.7 43.3 43.6 44.0 43.3 43.2): **"default" 0.25 s**, to about **20.5 pt** (item 0 about 27) | "default" to the pile side (27 for item 1 at tile 31) | unchanged curve; end side not changed (see GAPS) | measured |
| Fan close: tile | the chevron plate goes at the close's first frame; the tile stays **empty** until the items land; the hover label shows at once (pointer on the tile) | the pile showed at once under the flying items | pile hidden while the popup lives (`Dock.qml` `!dock.stackLive`) | measured |
| Grid open | panel left and top edges: p from the left edge .135 .371 .509 .630 .728 .804 .862 .907 .941 .966 .984 .995 1, from the top edge the same within .01 (so scale and position share one curve and grow from the tile centre): **CA "default" 0.25 s, rms 0.0115** (ease-in-out 0.024) | "default" 0.25 from the tile centre | ours captured: top edge rms **0.0012** to "default" 0.25 (start 64 ms after the click) | measured; confirms R3.2 |
| Grid close | p .080 .199 .356 .497 .620 .719 .808 .860 .905, then gone (opacity): **"default" 0.25 s, rms 0.006** | same | same | measured |
| Grid place | panel left 644.5 pt (decoded x = 982 - 674/2 = 645), top 438 (decoded 890 - 11 - 438 = 441; the diff edge includes the glass rim) | decoded | unchanged | measured, within 3 pt |
| Tile while open | a dark plate **25 x 25 pt** (0.806 of the tile), corner about 5.6, centred on the icon box; over the Dock glass (10,16,88) it reads (47,50,87) at the top to (22,24,45) at the bottom = grey 86 at alpha .49 to grey 27 at alpha .70. A white chevron, ink **9.75 x 5.25 pt**, stroke about 1.1 pt, 0.4 pt below the plate centre. The same in the grid clip | an SF chevron.down 0.42 of the tile, semibold, no plate (guessed) | the plate and a drawn chevron (`Theme.dock.stack.chevron*`, `Dock.qml`) | measured (dark only) |
| The "N More in Finder" / "Open in Finder" slot | a 57 pt circle, 1 pt black rim, dark see-through fill (24,43,140) over (31,55,164), an arrowshape.turn.up.right.fill-like arrow about 31 x 24 pt, (148,166,255) | the Finder icon | unchanged (the symbol outline is not in `themes/icons/sf-symbols`) | measured; not built |
| Hover label at the press | gone at mouse-down (grid clip 0.35 s: tile pressed, no label) | stays until the popup opens, then fades | unchanged | measured; not built |

Ours after, on screen (headless, tile about 62 pt, light): the first item's box wholly above the Dock, the label pills
clear of it, the plate and chevron on the tile (`ours/fan3-open`, `ours/fan3-close`).

## R4.2 Mission Control exit, the back window clicked (4 windows)

Mac: 4 TextEdit windows 640 x 460 pt at +90,+70; Mission Control tiles Window 4 / 3 on top, 2 / 1 below. The pointer
clicks Window 1 (bottom right, the back window). Ours: 4 foot windows 700 x 500 pt at (80,70) +80,+50, Window 4 in
front; Mission Control from `qs ipc call panels toggle mission`, a vptr click on Window 1's tile, `mcap -k 4` of the
whole output.

| What | Mac (measured) | Ours before | Ours after | Mark |
|---|---|---|---|---|
| Window path | Window 4's top-left corner (x, 46 -> 616 px) and Window 1's bottom edge (1735 -> 1639 px) per frame from the first exit frame (2.983 s): W4 .070 .200 .351 .491 .618 .709 .786 .849 .881 .919 .940, W1 .062 .208 .354 .500 .625 .708 .792 .854 .896 .917 .938. The decoded (1.0, 0.25) spring from rest is .067 .205 .358 .499 .619 .715 .791 .848 .890 .921 .944: **rms .0079 (W4), .0049 (W1)**, start at the first exit frame. Same curve for both windows (no stagger, no distance term) | `exitKick` 10: .176 .349 .500 .624 .722 .796 ...: rms **.093 / .089** frame-aligned (peak .15) | `exitKick` 0; captured (Window 1's right edge, 629 -> 509.5 px): .067 .201 .360 .502 .619 .711 .787 .845 .887 .921 .946 .962, rms **.0081 / .0060** against the Mac's two series | measured; the R2 ".21 first frame" was the share-of-change metric, not the windows' way (the note "exitKick stays" is superseded) |
| Layer order | the clicked window is on top from the first exit frame and flies over the others; the others keep their order (4 over 3 over 2); after the exit Window 1 is in front | the same (R3.5) | the same | measured |
| Key look of the clicked window | coloured lights from the 2nd frame after the exit starts (3.017 s, 33 ms) | lights coloured at 105 ms (frame 8; Window 4 keeps its coloured lights until then) | Round 5, R5.2: 2 frames, Window 4 grey in the same frame | measured; fixed in Round 5 |
| Spaces bar ("Desktop" label, +) | region change .41 .74 .96 (label), .44 .58 .71 .81 .92 .98 (+): the bar slides up, so a fixed region saturates early; its own way is in R4.4 (about 0.2 s, opaque) | label region .18 .33 .43 .55 .65 .75 .81 .86 .90 .95 | see R4.4 | measured (corrected in R4.4) |
| Menu bar | fades in .04 .12 .20 .29 .37 .53 .63 .75 .83 .90 .94 .96 (about 0.2 s, slow start) | .21 .38 .50 .65 .75 .81 .86 .90 .92 .94 (with `e`) | unchanged | measured; ours starts faster |
| Desktop widgets (clock) | fade in with the exit .32 .40 .52 .62 .72 .79 .85 .89 .92 .94 | none built | - | measured |
| Wallpaper | no visible dimming change during the exit (the shield is the plain wallpaper) | - | - | measured by eye |

plugin-motion has no Mission Control path (the exit is `shell/modules/MissionControl.qml` alone); nothing there changed.

## Round 4 not found / left (GAPS)
1. Fan close end side: about 27 / 20.5 pt for items 0 / 1 at tile 31, against the decode's 29 / 27 (s = 1). s = 3 (25 /
   19) fits better, as if `getCollapsedLayoutFrames:` read the tile in pixels (62 at 2x). Not changed: one clip, one
   tile size.
2. The "More in Finder" slot art (R4.1): not built, its symbol outline is missing.
3. Hover label hidden at mouse-down on the stack tile (Mac) vs ours at the open.
4. Mission Control: the picked window's key look at 33 ms (Mac) vs 105 ms (ours); the menu bar's slower fade-in;
   desktop widgets. (The Spaces bar: R4.4.)
5. The open latency: ours starts 64 ms after the synthetic click (the popup window's first frame); the Mac's click
   time is not in the clip (synthetic click, no pointer press frame in the fan clip).

## R4.3 "More in Finder" slot and the fan close end (Mac round 4, R4.3)

`dock/stack-fan-more-dark.png`, `dock/stack-fan-more-close-dark.mov` (same stack, tile 31, 9 items + "5 More in Finder",
the close clicked on the chevron at about 0.4 s).

| What | Mac (measured) | Ours | Mark |
|---|---|---|---|
| Close: item 1 (Data.json) page width per frame | 86 px at rest; 81 75 66 58 51 45 40 37 ... 29 px at 0.60-0.68 s, then **33 px** at 0.70 s when the tile's own pile takes over (a one-frame jump) | - | measured |
| Close end side | page 29 px = **21.6 pt** box for item 1 (page / box 86 / 128 px); the round 4 clip's curve fit gave 20.5, item 0 about 27. The pile's own back item is 104/128 x 31 = 25.2 pt (page 33.9 px, measured 33) | decode: item i ends at tile - 2s(i+1), s = 1 at tile 31: 29 / 27 | measured; s = 2 (27 / 23) is the nearest of the decode's three steps; not changed (no reason found why tile 31 would take s = 2) |
| Hand-over to the pile | the fan's items land, then the pile (normal sizes) replaces them in one frame | the pile shows when the popup is gone (`!dock.stackLive`), the same one-frame swap | measured |
| "More in Finder" slot art | fan: a 57 pt circle, 1 pt black rim, a dark see-through fill, arrow (148,166,255); grid ("Open in Finder" cell): the same arrow and circle drawn as a light ring with no fill, arrow (190,204,255) over the glass bubble. So the art depends on what is under it (vibrant), not one fixed picture | the Finder icon | measured; not built (the vibrant recipe is not known, the arrow outline is not in `themes/icons/sf-symbols`) |

## R4.4 Mission Control exit by Esc (Mac round 4, R4.5)

`live/mc-exit-esc.mov`, 4 windows (Window 4 in front), Esc at about 0.43 s; `live/mc-4-windows-entered.png` (tiles at
about 20,110 / 552,110 / 372,498 / 904,498 pt, 520 pt wide, 0.5 s after entering). Ours: the same 4 foot windows, `qs
ipc call panels close` (the Esc key's handler is `Panels.close()`, MissionControl.qml line 406, the same path),
`mcap -k 4`.

| What | Mac (measured) | Ours before | Ours after | Mark |
|---|---|---|---|---|
| Window path | Window 4's top-left x .070 .204 .354 .501 .617 .702 .789 .849 .891 .919 .933; Window 1's bottom .083 .208 .354 .500 .625 .708 .792 .854 .896 .917 .938: the same (1.0, 0.25) spring from rest as the click exit (R4.2) | kick 10 (R4.2) | Window 1's right edge .067 .201 .360 .502 .619 .711 .787 .845 .887 .921 .946 (starts 36 ms after the ipc call) | measured |
| Order | Window 4 (the window in front before) stays in front through the exit; the others keep their order | same | same | measured |
| Spaces bar | the whole bar (69 pt) **slides up opaque**, the "Desktop" pill keeps its ink up to the top edge; bar bottom edge 136 -> 106 (twice: a repeated frame) 84 64 46 30 15 8 4 px: .22 .38 .53 .66 .78 .89 .94 .97, starting with the windows. The windows' spring (0.25) fits it at rms .043 (best: ease-out 0.20 s, .029); the decoded `SpacesBarExitSpringResponse` 0.125 at .103 | slid up and **faded** (`opacity: mc.bar`) on the 0.125 spring | slides opaque on the windows' exit spring (`MissionControl.qml` `barExit` 0.25, `opacity` 1 while it leaves); pill bottom per frame .09 .23 .41 .55 .67 .78 .87 of the bar height | measured |
| Menu bar | fades in .04 .12 .20 .29 .37 .53 .63 .75 .83 .91 .95 .97 (the same as the click exit) | with `e` | unchanged | measured; gap |
| Desktop widget (clock) | fades in .34 .43 .55 .64 .74 .81 .87 .91 .94 .96 | none | - | measured |

Seen on ours in both exits (click and Esc), not on the Mac: in the top 100 pt strip the real windows show at their
end place while their thumbnails still fly (a "ghost" of Window 4 at the top), because the strip (menu bar + top
dimming, `m.stripHeight`) fades with `e` and uncovers the real windows sooner than `coverEnd`. Fixed in Round 5, R5.1.

## Round 4 GAPS (added)
6. The ghost windows in the top strip during an exit (R4.4). **Fixed in Round 5, R5.1.**
7. The "More in Finder" / "Open in Finder" slot art: vibrant, two looks measured (R4.3).
8. The fan close end side: 21.6 pt measured for item 1 at tile 31 (decode s = 1 gives 27).

# Round 5 (2026-11-14): the exit ghost and the picked window's key look

Ours only, against the Round 4 Mac clips. Headless session, scale 2, light, 4 foot windows 700 x 500 at (80,70)
+80,+50 (Window 4 in front), `mcap -k 4` of the whole output; click exit = vptr click on Window 1's tile, Esc exit = `qs
ipc call panels close` (the Esc handler's `Panels.close()`).

## R5.1 Ghost windows in the top strip

| What | Value | Mark |
|---|---|---|
| Cause | `MissionControl.qml`: the wallpaper cover over the windows was two bands, the top `stripHeight` (100 pt) at opacity `e`, the rest at `cover` (opaque until e < `coverEnd` .06). The strip let the menu bar and the desktop's top dimming fade in, but real windows reach into 34..100 pt (Window 4's bar at y 70), so they showed through at their end place while their thumbnails still flew. Not plugin-motion (it has no Mission Control path) and not an early map: the real windows stay mapped under the layer the whole time | found (code + frames) |
| Fix | the band at opacity `e` is the menu bar's own height (`Theme.menuBar.height`, 34): no window can be there. Below it the cover is opaque as elsewhere, and the desktop's top dimming (Background.qml `topDim`, the same shader on the same cached wallpaper) is drawn over the cover at (1 - e) x cover (`stripDim`), so the band changes as when the desktop showed through, without the windows | changed |
| Check | top 160 pt of every frame of both exits: no window but the flying thumbnails (before: a second Window 4 at y 70 from the 2nd frame to the end). The band 34..100 pt right of the windows changes by 0.3-0.5 levels per frame in the tail as before, plus one step of 1.4 levels (mean; up to 7 at y 34) in the frame the cover goes (e < .06): `stripDim` is slightly darker than the desktop there (cause not found: the shader, image and text colour are the same) | measured |

## R5.2 The picked window's key look (click exit)

| What | Value | Mark |
|---|---|---|
| Mac (R4.2 clip, red close-light clusters per frame) | f179 first exit frame (hover ring gone, no motion); f180 Window 4 still coloured; **f181: Window 4 grey and Window 1 coloured in the same frame**, 2 frames after the first exit frame | measured |
| Ours before | Window 1 coloured at 105 ms (frame 6-7); Window 4 coloured through the whole flight. The chain: the focus waits 2 frame swaps (the layer must drop the keyboard first), then a 50 ms timer re-captures the window (`reshot`), then the bar is redrawn in the active look | measured + read |
| Fix | the bar (drawn from the plugin's description, not from the client) takes the active look for the picked window, and the inactive look for every other window, from the first frame swapped after the click (`mc.pickLook`, cell `barActive` / `barInactive`); the focus and the content re-capture are unchanged | changed |
| Ours after | Window 4's lights grey and Window 1's coloured **in the same frame, 2 frames after the first changed frame** (55.8 ms after the click; motion starts in our first changed frame, one frame earlier than the Mac's) | measured |

## Round 5 left
1. The 1.4-level step in the dim band when the cover goes (R5.1).
2. Apps without the plugin's bar (QML title bars): their key look still waits for the client's redraw and the re-capture.
   Round 6 R6.1: Settings matches the Mac, Finder 4 frames.

# Round 6 (2026-11-14): QML title bars' key look on a pick, the "More in Finder" slot, the fan close end

Headless session (scale 2, dark, 1280 x 832 pt), Finder (936 x 594 at 172,92) and System Settings (740 x 625 at
270,76), `mcap -k 4` of 1280 x 580 pt from the vptr click; per frame the red / green light clusters of every title bar
(R > 200, G 60..130 for the close light). Marks as before.

## R6.1 Mission Control click exit: apps that draw their own title bar

| What | Value | Mark |
|---|---|---|
| Cause | Finder and Settings draw their lights in the client; their thumbnail is a still. Before: the key look came from the focus (sent 2 swaps after the click, once the layer drops the keyboard) and the 50 ms `reshot`: about 105 ms (Round 5 left 2) | read + measured |
| Path | at the click Mission Control sends `custom>>hyprk-pick,<address>` on Hyprland's event socket (`hl.dsp.event`, `Actions::event`, ConfigActions.cpp 1320). Finder (`finder/src/hypr.cpp` `Hypr::picked`, `Main.qml` `Theme.active`) and Settings (`settings/shell.qml` `win.picked` -> `keepActive`) take the key look for that window at once, until another window is made active after it (the layer's release first refocuses the old key window: that first `activewindowv2` is ignored) or 1 s. The picked thumbnail is live from the click and the old key window's still is taken again at the click (`MissionControl.qml` `hintPick`, `picked`, `keyAtOpen`, `view.live`) | changed |
| Why at the click | the toplevel capture after the first frame is a copy without ignore_damage: a still asked for after the client's redraw waits for its next damage. Asked at the first or second swap (after Finder's redraw, 8 ms after the event in its render-loop log): +4 frames; asked at the click: in time | measured |
| Settings picked, Finder key before | Settings coloured and Finder grey **in the same frame, 2 frames after the first exit frame** (38.7 ms after the click); Mac f181: the same | measured |
| Finder picked, Settings key before | Finder coloured **4 frames** after the first exit frame (89 ms; before about 105 ms). Finder redraws 8 ms after the event, but its capture comes in late (cause not found: the request is in flight before the redraw as for Settings) | measured; gap |

## R6.2 The "N More in Finder" / "Open in Finder" slot art

| What | Mac (measured, stack-fan-more-dark.png, stack-grid-*) | Ours |
|---|---|---|
| Fan | disc 56 pt (0.875 of the 64 box), 1 pt black rim outside, white ring at alpha .15 inside, see-through blurred fill | same; ring (59,74,158) vs Mac (57,72,151); fill not blurred (no backdrop blur) |
| Grid | ring 64 pt (0.64 of the 100 pt icon box), stroke 2.33 pt, no fill, no rim | same; profile 220 223 223 223 182 vs 216 221 221 221 184 |
| Arrow | arrowshape.turn.up.right.fill, adds about +124 to what is under it: fan (148,166,255), grid (207,222,255) | traced from the grid PNG (the symbol is not on disk; overlap .991), drawn additive: (148,166,255), (207,221,255) |
| Files | | `shell/modules/StackArt.qml` (the `finder` slot), `shell/modules/DockStack.qml` 318; checked offscreen at scale 2 and in the session (grid "Open in Finder" cell) |

## R6.3 Fan close end size

`-[DOCKStack getCollapsedLayoutFrames:count:]` 0x100067df4 takes s from `DockBar.tileSize`, which is the `tilesize`
pref + 2 x tileInset (sub_100078598, fmadd 0x10007876c; tileInset 1 up to 47, 2 up to 127, 3 above, 0x1000785d4..
0x100078710), while W is the imageLayer = tile bounds - 2 x tileInset = the pref (0x10007fa38, set at 0x10008015c).
At tile 31 tileSize is 33, so s = 2: items 0 / 1 end at **27 / 23 pt** (before 29 / 27). Mac: about 27.4 / 20.5..21.6.
Built: `shell/lib/dockstack.js` `collapsedStep` (lines 66-79), used by `collapsedUp` and `fanSize`; tests in
`shell/tests/run.mjs` (collapsedUp(30, 1) = 17, tiles 29 / 31 / 46). Confirmed (code), item 1 still 1.4-2.5 pt over the
Mac (its page sits behind the folder at the end: the least sure reading).

## Round 6 left
1. Finder picked: key look 4 frames after the first exit frame (Mac 2); Settings matches.
2. The fan slot's fill is not blurred; the fan disc sits +5, +3 pt off the decoded slot centre; the close's 3rd-4th
   frames show a rounded-square outline on the Mac (not built).
3. Fan close item 1 end: 23 pt against about 21 on the Mac.

# Round J22 (2026-11-15): the Mission Control menu bar on exit, re-measured

Mac clips `live/mc-exit-4-windows.mov` (click) and `live/mc-exit-esc.mov` (Esc), real frame times, decoded at a quarter
size in grey. Alpha = least squares of (frame - the frame before the exit) on (last - before), over the pixels of the
menu titles (x 50..420 pt, y 4..22 pt) that change by more than 15 levels; status items (x 960..1400 pt) alike.

| What | Value | Mark |
|---|---|---|
| Mac menu titles, from the first exit frame | click .054 .174 .313 .450 .578 .670 .732 .801 .867 .902 .932 .957; Esc .052 .179 .313 .448 .576 .667 .733 .806 .865 .903 .931 .961; status items within .01 | measured |
| Fit | a critical spring of response **0.27** started with the windows' (first frame 16 ms in): rms .008 in both clips; the windows' 0.25: .036 (a frame ahead mid-way). The R4.2 / R4.4 rows' ".04 .12 .20 .29 .37 .53" took another region and do not hold | measured |
| How it shows | the titles show dimly **through the Spaces bar** while the bar still covers them (Esc clip, 33 ms in: crisp, dim titles inside the bar) | seen |
| Ours | the menu bar is not seen through our Spaces bar (opaque pre-blurred wallpaper): titles 0 for 5 frames, then .34 .62 .68 .73 .77 .79 as the bar slides off (mcap, 3 runs) | measured |
| Tried | a separate 0.27 spring for the wallpaper band over the menu bar: no change on screen (the bar covers the band until it has left) and a FrameClock TypeError (the spring outlived the window). Reverted | not changed |

Open (needs the Mac): what draws over what while the bar leaves (is the menu bar above the Spaces bar at alpha, or seen
through a translucent bar), and the bar's own alpha per frame over a flat wallpaper.


# Round K1 (2026-11-15): the HUD glyph's bounce, Mission Control exit after R10.1

## Volume / brightness HUD: what moves on a step (decoded)

User report: on the Mac a volume step is not only a bounce at full volume, every step moves the bar. Source: SystemBannerUI
from the 27.2.1 dyld cache, read on the PC (`ipsw dyld macho -w` for the Swift types, `ipsw dyld disass --cache <DSC>.a2s`
for the whole `__text` 0x2aed42dd8-0x2aed88fe8; excerpts in `decomp/SystemBannerUI-hud-symbol-effect.asm`). `ipsw dyld
extract` still fails on this cache, so REA's Ghidra provider had no image to open; every function below was short enough
to read as disassembly. No Mac clip shows two steps in one HUD or a step onto an end (volume-pop.mov and
volume-key-hud-timing.mov are one step each from 38 / 81 %), so nothing here is measured on the Mac.

| What | Value | Mark |
|---|---|---|
| Types | `SystemBannerContentController { _sliderCurrentValue: Double?; _symbolEffectState: SymbolEffectState }`, `SymbolEffectState { valueLabelSeed: UInt32; previousValue: Double? }`, `SliderBannerImageView { image; variant; isInflated: Bool }`, `TickedSliderTrack { width; showTicks; value }`, `TickedTrackMask { tickCount; tickWidth; tickProgress }` (Animatable, data = tickProgress) | decoded |
| Glyph view body 0x2aed644bc | `Image.symbolVariant(...)` `.symbolEffect(BounceSymbolEffect(), options: .default, value: valueLabelSeed)` (`_DiscreteSymbolEffectModifier<UInt32>`), font 26 pt (21 reduced; 0x2aed43ad0 / 0x2aed43ae0), `.scaleEffect(isInflated ? 1.1 : 1, anchor: .trailing)` (0x3ff199999999999a), white, `.animation(_, value: isInflated)` | decoded |
| The seed, 0x2aed4af5c | `update(value)`: nothing when value == previousValue; else previousValue = value and, when value is exactly 0 or 1, valueLabelSeed += 1. Called on every content set (0x2aed4adf0, after `sliderCurrentValue = nil`) and from the slider drag (0x2aed4ba6c, (v - min) / (max - min)) | decoded |
| So | the glyph **bounces once when the level arrives at 0 or at 1** from another level; a step that leaves it there (up at full) changes nothing; a HUD that is not on screen yet makes its glyph view with the new seed, so no bounce (inferred from the discrete effect's rule, not seen) | decoded / inferred |
| isInflated in the HUD | false: BannerSlider's HStack closure 0x2aed62950 stores 0 in the variant and isInflated fields (0x2aed62c3c, 0x2aed62c94). The 1.1 scale belongs to the other variants | decoded |
| Bar | fill = `UnevenRoundedRectangle` `.frame(width: max(value x width, 0), height: 4)`, trailing radius 2 only when value == 1 (0x2aed665fc-0x2aed666c8), masked by the ticks: 15 rects at width x i / 16, each `tickWidth x tickProgress` wide (0x2aed66984); tickProgress = showTicks && isEnabled ? 1 : 0 (0x2aed66314). It moves inside the content's `withAnimation(spring(response: 0.2, dampingFraction: 0.85))` (0x2aed4c4c0, as before): one continuous fill per step, no per-dash effect | decoded |
| Capsule | no pulse on a step: the content closure only sets the content (0x2aed4b564), then 0x2aed49f8c re-runs the appear spring to scale 1 / opacity 1 | decoded |
| Correction | MAC-ANSWERS.md "REA 27.2.1" section 1 and "SF Symbol effects" say SystemBannerUI has no symbol effect: wrong for the slider banners (the body above imports Symbols' BounceSymbolEffect) | |

Ours before (mcap 60 fps, IPC steps 13/16 -> 14/16 -> 15/16 -> 16/16 -> 16/16): the fill moves 13.4 pt per step over
about 115 ms on the 0.2 / 0.85 spring (the Mac's), the glyph never moves. After (`shell/modules/HudWindow.qml` Layer:
`HudLib.bouncesAt`, HyprK `SymbolBounce`, about the ink centre of the glyph at that end; `shell/lib/hud.js` inkCentre /
bouncesAt): the step onto 16/16 bounces the speaker, ink height x 1.00 -> 1.23 at +0.2 s -> 1.0 at +0.35 s (the wave that
fades in at the same time widens the ink, so the trough is not read here; the curve is INTERACTIVE-GLASS-REA.md 3's, its
peak / trough measured on the Control Center glyphs: speaker.wave.3.fill 1.21 / 0.87); the repeated step at 16/16 does
nothing; a fresh HUD does not bounce. The slash glyph (arrival at 0) takes speaker.fill's amplitude (not measured).

Needs the Mac: a clip of two or more volume steps in one HUD ending on full (and on 0), to check the bounce's start, its
per-layer delay and that nothing else moves per step.

## Mission Control exit (R10.1 applied)

| What | Mac (mc-exit-menubar-flat-grey.mov) | Ours before (Round J22) | Ours after (mcap, 3 runs) |
|---|---|---|---|
| Order | titles above the Spaces bar, the bar solid | menu bar under the bar | titles above the bar from the first exit frame |
| Bar's bottom edge / its height, per frame | .77 .61 .46 .35 .23 .16 .10 .06 .03 0 (53 42 32 24 16 11 7 4 2 0 of 69 pt) | the 0.25 critical spring: .93 .80 .64 .50 .38 .29 .21 .15 .11 .08 | .77 .61 .47 .34 .23 .16 .10 .06 .03 0 (57 45 34.5 25.5 17 12 7.5 4.5 2 0 of our 74 pt band) |
| Title alpha per frame | .23 .42 .58 .72 .80 .86 .90 .90 .93 .94 .97, .98, 1 at 250 ms | 0 x5, then .34 .62 .68 .73 .77 .79 | .26 .44 .60 .73 .80 .86 .90 .90 .93 .94 .97 .98 .98 .99 .99 1 (rms .010) |

How: `shell/lib/spring.js` `fromTrack` (a measured track played as it is; no spring from rest starts with its largest
step); `MissionControl.qml` `barExit` = that track, and the menu bar band's cover drops at once on the way out (the
desktop shows where the bar has left, R10.1); `MenuBar.qml` goes to the Overlay layer while Mission Control's window
leaves (`mcLeaving`: re-stacked above the older window) and its content plays the title track on a FrameSpring of its
own window (the J22 try put the spring in Mission Control's window, which is destroyed after the exit). No change in the
menu bar rows after the fade (the layer going back to Top shows no frame difference). Left: our band is 74 pt tall, the
Mac's edge reads 69 pt at 1440 x 932 (not changed: the 74 is Q-dock-31's); with "Show menu bar background" on, the
bar's background would be above the Spaces bar for those frames (the Mac's is under it; off by default).

## Round R11.4-R11.7 (MAC-ANSWERS-11.md, measured from the clips and stills; 2026-11-15)

### Volume HUD, single steps (R11.4, `panels/hud-volume-steps-{light,dark}.mov`)

Measured here per frame (not from the Mac's summary): fill = white coverage of the bar row; glyph = each connected layer's
box. 40 steps (both clips).

| What | Mac clip | Ours before | Ours after (mcap 60 fps, IPC steps) |
|---|---|---|---|
| Fill per step | slides one dash on spring 0.2 / 0.85: fit over 40 steps rms .014 of a step (0.16 / 1.0: .018; 0.18 / 0.85: .022); about 7 frames. The summary's "ease-out up, linear down" is the 1 pt dash gap, crossed first going up and last going down | the same spring, rms .009 | unchanged |
| Dashes, capsule | nothing moves | nothing | unchanged |
| Wave count | in ONE frame, 1-2 frames before the fill moves (3 -> 2 at 10/16, 2 -> 1 at 5/16, slash at 0) | fade on the 0.2 / 0.85 spring, 4-6 frames, slash cross-faded | one frame, in the frame the fill starts |
| Glyph at 0 | `speaker.slash.fill` (the summary's "speaker without waves" is wrong: frame 312 shows the slash) | slash | slash |
| Bounce at full | BY LAYER about the symbol's centre: speaker 45 -> 56 px (1.24) at +0.19 s, trough 40 (.89); wave 1, 2, 3 the same curve 0.04 / 0.10 / 0.16 s later (wave 3 49 -> 61 px at +0.35 s, trough 44, rest at +0.67 s) | all layers together, 1.21 / 0.87, done at +0.58 s | speaker 45 -> 56 at +0.22 s, wave 3 49 -> 61 at +0.35 s, trough 44-45, rest at +0.70 s |
| Bounce at 0 | slash 47 -> 59 px (1.255) at +0.18 s, trough 43; the speaker 30 -> 38 (1.27), trough 27, 0.05 s later; rest at +0.62-0.66 s | together, 48 -> 60, trough 42 | slash 48 -> 60, the speaker 0.05 s later (31 -> 38, trough 28) |
| Extra press at full / at 0 | no changed frame; the HUD stays, fades about 1.07 s after the last press | the same | unchanged |

Model fitted over 3 bounces (dark full, dark 0, light full): the INTERACTIVE-GLASS-REA.md 3 curve per layer, peak 1.25,
trough 0.90, 0.05 s per layer: rms .013-.016 of scale (all layers together at 1.21 / 0.87: .044-.063). The later layers
end a little early on the Mac (wave 3 at +0.67 s, the model +0.73). Code: `Hud.motion.bounceStagger` / `bounceAmp`,
HyprK `SymbolBounce` `layers` / `stagger` / `at(k)`, `HudWindow.qml` Glyph `scales` (per path, about the ink centre).
This corrects "Round K1": the decoded `.symbolEffect(.bounce)` is right, its by-layer playback was not known.
Left: the Mac's glyph swap leads the fill by 1-2 frames, ours by 0; the Control Center sliders' end glyphs still bounce
as one piece (measured there as a whole, 1.21 / 0.87: likely the same layered motion, not re-measured); the sun's bounce
is not recorded.

### Finder toolbar Search button (R11.5, `controls/finder-search-button-*`)

| What | Mac | Ours before | Ours after |
|---|---|---|---|
| Hover | one frame; light 253 -> 235-238, dark (87,88,96) = Q-finder-10's value | one frame; light 249 -> 233, dark +20 | unchanged |
| Held | one frame: disc 72-73 -> 78-79 px (37 -> 40 pt, stills; clips light 72 -> 78, dark 70 -> 74), light 255, dark neutral 58-59, glyph grows with it, dark glyph 255 | the hover pill, no growth | one frame: 88 -> 91 px on the visible side (+1.5 pt per side), light 255, dark #3A3A3A, glyph scaled, dark glyph white |
| Held, pointer dragged off | dark: a bright disc (73,83,144) against rest (50,57,90), fading to (62,70,115) in 0.4 s, still 74 px. The summary read this as the release | - | not drawn |
| Release | only the clips' last 3-4 frames: 78 -> 76 -> 74 px (1/3, 1/2, 2/3 of the way), end not recorded | at once | 150 ms ease-out: .30 .53 .70 .83 |

Code: `finder/qml/ToolButton.qml` `pressLook` / `held`, `Toolbar.qml` (the Search capsule's scale), `Theme.qml`
`searchPress*`. `ui/HyprK/ToolbarHighlight.qml` not changed: the Mac's Search press shows no bouncy lift (the full size is
there in the press frame) and no pointer glow while the pointer is inside. Ours measured in light only.

### Icon & widget style tiles (R11.6)

See reference/ASSETS.md and SETTINGS-UI-AUDIT.md. With Default selected the Clear
and Tinted tiles are the light ones in dark mode too (`Appearance.qml` darkTile). The stills are Display P3; read as
sRGB: default 11.7 (Apple's bitmap), dark 5.6, clear 10.6 / 11.3, tinted blue dark 4.7, tinted blue light 17.4 -> 12.1.

### Mission Control Spaces bar (R11.7)

Stills: bar rows 0..147 at 1710x1107 = **74 pt**, rows 0..135 at 1440x932 = **68 pt**, expanded edge after row 319 =
160 pt (1440x932). Ours: 74 pt (mcap: edge after row 147), the default mode's value, unchanged. R10.1's clip was taken
at 1440x932, its last still frame has the edge at 68.0 pt, so its track is a share of 68: .78 .62 .47 .35 .24 .16 .10
.06 .03 0 (was / 69: .77 .61 .46 .35 .23 .16 .10 .06 .03 0); `MissionControl.qml` `barExit` now divides by 68. The
"Left" note above (69 against 74) is closed: 68 and 74 are the two display modes. Not applied: the expanded bar
(Mac inset + 132 = 166, the Space's frame from inset + 10; ours about 142 from y 16), because our windows do not make
room and how the Mac's do was not captured.


# Round K2 (2026-11-15): the sliders' end glyphs bounce by layer

Re-measured per frame, sub-pixel (INTERACTIVE-GLASS-REA.md 8: R7.4 Control Center clips, the 23.09.23 recording for
Settings > Appearance). The Mac: nothing moves on the glyphs while the knob is dragged; a drag onto an end bounces that
end's glyph once, by layer about the symbol's ink centre, 1.25 / 0.90 (speaker.fill, one layer: 1.27 / 0.89), peak
+0.217 s, trough +0.433 s, each layer 0.05 s after the one before (sun: disc, rays; speaker: speaker, waves from the
inside out; capsule.on.rectangle: capsule, rectangle). A slam and a slow drag are the same. Appearance's two glyphs
bounce too (frames 2228-2262 and 2488-2527): "static" in Round K1 / section 6.3 was wrong.

| | Mac | ours before | ours after |
|---|---|---|---|
| CC Sound, speaker.wave.3.fill | by layer, outer wave 1.26 / 0.92, 0.11-0.16 s after the speaker | one piece 1.21 / 0.87 | by layer, 1.25 / 0.90, 0.05 s per layer |
| CC Sound, speaker.fill | 1.27 / 0.89 | 1.27 / 0.89 (27 -> 34 -> 24 px) | unchanged |
| CC Display, sun.max.fill | disc 1.24 / 0.907, rays 1.26 / 0.89 +0.05 s | one piece 1.23 / 0.86; no motion at all without a backlight (slider disabled) | disc 1.253 / 0.907, rays 1.264 / 0.893 +0.05 s (backlight stub) |
| CC Display, sun.min.fill | disc 1.247 / 0.91, rays 1.25 / 0.89 +0.05 s | as above | by layer (ink height 30 -> 38 -> 28 px) |
| Appearance, both capsule glyphs | capsule 1.23-1.26 / 0.90, rectangle the same 0.05 s later | none | capsule then rectangle, 1.23-1.25 / 0.85-0.88 read at 1 px = 0.07 |

The "Left" of Round R11.4 (the Control Center glyphs bounce as one piece; the sun not measured) is closed for the Control
Center. The HUD's sun still bounces as one piece (now 1.25 / 0.90): no HUD brightness clip holds an arrival at an end.

# Round J24 (2026-11-15): the picked window's key look, Finder (judge #24 "MC pick in Finder +4 frames")

`scripts/motion-capture/mc-pick.py` (headless, scale 2, dark; Finder 936 x 594 and System Settings 740 x 625; a vptr
click on the thumbnail after the pointer has rested on it 0.5 s; mcap of 1280 x 620 pt; the red close lights, each with
its yellow neighbour, given to the window whose flight path they lie on). Frames are counted from the first changed frame.

| What | Value | Mark |
|---|---|---|
| Mac, re-read (`mc-exit-4-windows.mov`, frames by pts) | 2.983 s: the hover ring gone (11,862 px changed at half size, rows 68..874), Window 4's light where it was, the top 68 rows unchanged; 3.000 s: the flight's first step (.07); 3.017 s: Window 4 grey and Window 1 coloured, flight .20. So the key look comes 2 frames after the first changed frame and in the flight's **second** frame | measured |
| Ours before | Finder picked: +4 +4 +5 (R6.1's gap), by click phase: first exit frame 6 ms after the click -> +4, 18-20 ms after -> +1..+3. Settings picked: +2 +2 +3. Motion in the first changed frame | measured |
| Cause | not a capture waiting for damage: `CToplevelExportFrame::shareFrame` copies at the next monitor frame with or without `ignore_damage` (Hyprland 0.57.2 ToplevelExport.cpp), so R6.1's "copy without ignore_damage waits" does not hold. Finder commits the look 5-11 ms after `hyprk-pick` (WAYLAND_DEBUG against the click's time; a second commit one frame callback later only recolours the sidebar icons), the copy lands at the compositor's next frame, the layer draws it one frame later. A click early in a refresh misses the first compositor frame: 4 frames. Four extra captures, one per swap, changed nothing (each takes a frame to come back and a frame to draw) | measured + read |
| Fix 1 | the look ahead of the click: `hyprk-pick` is sent when the pointer comes to rest on a thumbnail of an app that draws its own title bar (the window is under the cover; `hyprk-pick,0x0` takes it back when the pointer leaves or Mission Control closes without a pick), and 100 ms later a second capture context takes a still of the window in that look (`keyStill`). The live view starts only when that still shows | changed |
| Fix 2 | when it shows: `pickLook` is the flight past .13 of its way (between the (1.0, 0.25) spring's first two steps, .067 and .205), not a count of swaps. Counted in swaps the look came one frame early in a third of the runs (a swap of a frame begun before the click; two `afterAnimating` in the frame the layer gives up the keyboard) | changed |
| Fix 3 | a thumbnail click hides the ring and the title at once and starts the exit (windows and Spaces bar) one frame later, as the Mac's 2.983 s frame (`picking`, `pick()`, `leaveForPick()`; a 50 ms timer in case no frame is drawn) | changed |
| Ours after | Finder picked, Settings key: **+2 in 10 of 10** (33 ms). Settings picked, Finder key: **+2 in 10 of 10**. The old key window greys at +1 (Finder picked) or +1..+2 (Settings picked); Mac +2. First frame 10,899-13,176 px changed (the ring), the next 104,000-108,000 (the flight) | measured |
| Esc exit | unchanged: `mc-exit.py` bar rms .007, titles .002 | measured |

Left: a click sooner than 100 ms after the pointer reaches the thumbnail has no still and falls back to the live view
(the old 4-5 frames; not measured again). The still is as old as the hover (a window that changes under a resting
pointer shows the hover's picture until the live view's first frame, 2-3 frames into the flight). A press held on the
thumbnail: the Mac's ring may go at the press, not captured (OPEN-FIXES M2). The Spaces bar's expanded height (166):
not changed, OPEN-FIXES 29 / M1.

## Round 17: Cmd-Tab and the window sheet (MAC-ANSWERS-17.md R17.2 / R17.4, measured from the clips and stills; 2026-11-15)

### Cmd-Tab (`live/r17/cmdtab-*.mov`, `cmdtab-{7..10}apps-*.png`)

| | Mac (measured here) | ours before | ours now (`scripts/motion-capture/cmd-tab.py`) |
|---|---|---|---|
| appear | complete in one frame, 180 ms after Tab (step clip: Tab 1.137 s, panel 1.317 s) | one frame, **245 ms** (190 ms timer started after the window's load, then 4 frames) | one frame, **180-195 ms** (`Theme.switcher.showDelay` 180 from the key, `Panels.switcherAt`, less `showLag` 60) |
| step | plate and name on the next icon in one frame | one frame | one frame |
| Escape | gone in one frame (nothing at 3.600 s, Escape at 3.599 s; no frame in between) | **faded over 0.25 s** like a release | one frame (`Switcher.cancelled`) |
| release | share left per frame 97.8 92.7 86.3 78.4 68.0 56.9 45.4 33.8 23.8 14.7 8.5 3.4 1.0 0 (dark; light the same): ease-in-out over **0.246 / 0.242 s**, rms 0.3 / 0.5 % | ease-in-out 0.25 s | unchanged: fit 0.244-0.254 s, rms against the Mac's frames 0.5-1.8 % |
| quick tap | no changed frame | no panel | no panel (commit 60 ms after the key: 0 levels) |

The section's "fades out over about 200 ms, ease-in" is the visible part of the same curve: an ease-in fit of its 14
frames has rms 2.5-3.0 %, the ease-in-out over 0.246 s 0.3 %. Nothing changed there (decode: `-[ASAppSwitcher
exit:immediately:]`, default CATransaction 0.25 s).

Geometry, the same reading of `cmdtab-7apps-*.png` and of ours (px at 2x, ours / Mac): panel 980 x 176 pt at the screen
centre (the stills: 980, 1114, 1248 pt for 7, 8, 9 apps = 134 N + 42, and 1372 for 10 = the screen less 34 pt each
side, icons shrunk; so 444 for 3 and 846 for 6; the section's "133.5 N + 42, height 175, radius about 40, plate 119
r 28" are the same shapes read to +-1 pt), panel top / left edge 0 / 0, corner on the diagonal 33 / 33, plate left and
top 8 / 8 (120 pt on the 128 pt cell), plate corner 28 / 27, plate fill against the panel -57 / -57 light, +63 / +64
dark. **None of that changed.** The name did: SF 13 **semibold** (stems 3.6 px, the Mac's 3.7; bold was 1.04 x as wide), its ink
2.5 pt below the 128 pt cell (rows 310..328 px below the panel's top, the Mac's 309..328; it sat 5 px low), dark
white .95 (247, the Mac's 246; labelColor's .85 read 233), no shadow in either (the rows under the Mac's text are the
panel's). Left: the dark name's stems read 4.1 px against 3.7 (light text on dark, Qt's coverage).

### Window sheet (`live/r17/alert-{,dismiss-}{light,dark}.mov`)

The veil's level at a white point of the document, per frame (video levels, 255 -> 196): in, last unchanged frame
1.200 s, then 243 at 1.350 s and 3.6 levels a frame to 197 at 1.550 s: linear at 230 levels / s, **0.26 s for the
whole 59**; its first 50 ms are not on screen (the first drawn frame is at 20 %), which is the section's "about 220 ms".
Out: 196 at 1.083 s, 202 at 1.100 s, 251 at 1.317 s, 255 at 1.367 s: linear at 226 levels / s, **0.26 s**. Ours:
`Tokens.panel.sheetIn` 270, `sheetOut` 250, linear (LIVE-27.2.1.md had 0.27 / 0.25): within one frame, not changed. The
card is there from the first frame and fades with the veil; no scale. What the veil is: GLASS-HIG section 23.


# Round R18.1 (2026-11-15): Mission Control's Spaces bar expanding (MAC-ANSWERS-18.md)

`live/r18/mc-spaces-bar-expand-dark.mov` (60 fps, variable frame rate, 1440x932 mode, one Desktop, three windows) and
the two stills, measured again here (the bar's bottom edge at x = 110 pt; the top edge of the top-left window on the
same columns; the Space's ring, its name and the "+" on every frame).

| | Mac | ours before | ours after (`scripts/motion-capture/mc-bar.py`, 3 runs) |
|---|---|---|---|
| bar height | 68 -> 160 pt (+92; inset + 40 -> inset + 132) | 74, no change of the band (the content cross-faded in 250 ms, about 142 pt) | 74 -> 166 (+92) |
| curve | critically damped spring, response 0.3775 fitted free (ratio 1.02); the decoded (1.0, **0.38**) of `SingleSpaceTransitionModifier` fits at rms 0.22 pt | OutCubic 250 ms | (1.0, 0.38), rms 0.31 pt against the Mac's frames |
| start | spring from 2.101 s, pointer in at 2.03 s (71 ms); first moved frame 2.117 s (about 85 ms) | at once | first moved frame 81-82 ms after the pointer enters |
| after the pointer leaves | stays expanded until Mission Control closes | collapsed again | stays (edge the same 1.5 s later) |
| windows | the layout again under the taller bar: top row +92 pt at its size, 39.5 pt under the edge in every frame; the lower window stays (top 393.5 -> 393, bottom the same) | did not move | top row +92.0, 39.5 pt under the edge in every frame |

The file's table has the bar at 86.5 and 95.5 in the frames at 2.133 and 2.150 s and no frame at 2.167: the bar's edge
is one frame ahead of the windows in those two frames and repeats in the third (86.5 95.5 95.5 against the windows'
77.5 86 95.5). The window track is the clean one: 70.5 77.5 86 95.5 104.5 113 120.5 127.5 133 138 142 145.5 148 150.5
152.5 154 155 156 157 157.5 158 158.5 158.5 159 ... 160. Against the bar's own readings the same spring is rms 2.6 pt
(1.8 fitted free at response 0.41), all of it in those two frames.

The windows: `lib/expose.js` with the bar 92 pt taller (`usableArea` y = bar + 40: 108 -> 200) reproduces the two
stills from the windows' rest frames: the top row +92.3 at the same size and x, the lower window within 0.6 pt
(`shell/tests/run.mjs`). Each thumbnail goes from its frame in the one layout to its frame in the other by the bar's
growth (one behaviour for all, as the mode transitions).

In the bar (stills at 2x): the Space is the screen at 92 pt of height (141 x 92) inside a 3 pt ring in the accent
colour ((86,151,245) dark; outer 147 x 98, radius about 7.5) from y 38 = inset + 10, with the Desktop's windows in it;
its name 11 pt, centred on y 145.25; "+" centred on y 91.5 (34 at rest). Ring and name ride down 95.5 pt with the bar
(the ring's bottom 58.5 68.5 78.5 86.5 94.5 102.5 against the edge 86 95.5 104.5 113 120.5 127.5) and fade in with
the growth (ring blue 53 66 85 99 127 ... 165 of 165); the pill's fill is gone in the first frame after the pointer
enters, its 13 pt name rides down too and is gone by .8 of the way. On the way out the expanded bar slides up whole
(160 -> 132 -> 101 -> 57 in the clip's last frames).

Built: `shell/modules/MissionControl.qml` (`m.barExpand` 92, `m.barGrow`, `m.growDelay` 72 ms + one frame,
`framesExpanded`, the Space with small copies of the window thumbnails), `shell/lib/expose.js` `between()`. Ours keeps
the default mode's inset (74 -> 166; everything in the bar 6 pt lower than the 1440x932 stills). Removed with it: the
Space's 1.03 hover scale (not on the Mac's frames) and the 3 pt white border. Not captured: more than one Desktop
(spacing 18 pt kept from before, a guess), light mode, a full-screen Space; the light ring colour.

