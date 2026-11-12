# Stage Manager 27.2.1 (build 26B131): what the code says

Sources: the restore image's system DMG `141-12228-174.dmg`, single files extracted with 7z:
`WindowManager.app/Contents/MacOS/WindowManager` (13.9 MB, arm64e slice via llvm-lipo) and its control extension
`WindowManager.app/Contents/PlugIns/WindowManagerControlsExtension.appex` (244 KB); CoreGlyphs `Assets.car`
(`SFSymbols.framework/Versions/A/Resources/CoreGlyphs.bundle`). Disassembly: llvm-objdump; Swift field names:
`reference/re/tools/fields.py`. Mission Control's layout from the same app: commit fd20e46 (`shell/lib/expose.js`).
Marks: **decoded** (address / file), **measured**, **inferred**, **unknown**.

## 1. The Control Center button

The Control Center module is not ControlCenter.app's own: WindowManager ships it as a WidgetKit control,
`StageManagerToggleControl` (kind `com.apple.windowmanager.stagemanager`) with `StageManagerToggleIntent`.

| What | Value | Mark |
|---|---|---|
| title | "Stage Manager" (Swift small string built at 0x100003714) | decoded |
| description | "Enable Stage Manager" (0x10000a090, used at 0x1000037a8 and 0x100004020) | decoded |
| value text | "Stage Manager is enabled" (0x10000a070, 0x100003c48) | decoded |
| **symbol** | **`squares.leading.rectangle`**: the only `Image(systemName:)` of the control, sub at 0x100003d1c (string 0x10000a0e0, length 0x19). No on / off variant: one glyph, tinted by Control Center | decoded |
| on look | white disc, glyph in the accent blue (the user's Mac photo 2026-11-11; Control Center's toggle-on style, as Wi-Fi / Bluetooth) | measured (photo, layout only) |
| glyph size | ink 28 x 19 in the 64 pt button: about 24 pt | measured (MAC-ANSWERS Q-panels-07) |

The same extension holds the other window controls (decoded, cstrings 0x10000df40..0x10000e2e0):
Mission Control `com.apple.windowmanager.mission_control` "Enter Mission Control" = `rectangle.3.group`;
App Exposé `com.apple.windowmanager.app_expose` "Show Application Windows" = `rectangle.grid.2x2`;
Show Desktop `com.apple.windowmanager.show_desktop` = `menubar.dock.rectangle` (the "unidentified button" of
MAC-ANSWERS R3b-2); tiling buttons `tileTwoUpButton` "Tile Windows Left & Right" =
`inset.filled.lefthalf.righthalf.rectangle`, `tileThreeUpButton` "Tile Windows Left & Corners" =
`inset.filled.lefthalf.topright.bottomright.rectangle`, `tileCornersButton` "Tile Windows to Corners" =
`inset.filled.topleft.topright.bottomleft.bottomright.rectangle`.

`sidebar.squares.leading` (hyprk's old placeholder, "found by visual match only" in MAC-ANSWERS) is wrong.

## 2. Stage Manager itself (WindowManager.app)

What the Swift metadata gives (decoded field names, `fields.py`; values are NOT in the metadata):

- Defaults keys: `StageManagerEnabled` (`GloballyEnabled` via `setStageManagerGloballyEnabled`), `StripAutohideEnabled`,
  `HideDesktopEnabled`, `WindowGroupingBehavior`; properties `showStageManagerDesktopItems`, `showWidgetsInStageManager`, `appWindowGroupingBehavior`.
- Stage: `Stage {frame, safeArea, style}`, `Stage.Style` = freeform | center | inset.
  `StageCalculatorComponent.InputModel {display, preferences, screenContentFrame, preferredItemScaleFactor,
  stripIsAutoHidden, stripAlignment, appWindowGroupingBehavior, hasAlwaysFlattenedAppearance}`.
- Strip: `StageManagerStripComponent.InputModel {stripWindows, spaceWindowIDs, preferences, space, display,
  stageRepresentedProcessSerialNumbers, assignmentModel, rowCountModel, maximumVisibleColumns, perspectiveStyle
  (perspective | flat), stageManagerAvailableFrame, stripAlignment, stripVisibilityMode, pilePerspectiveDistance,
  appIconVisualProperties, shouldDisplayPileLabels}`; `ClientLayoutState.StripProperties {alignment,
  visibleContentFrame, maximumVisibleRowCount, piles [{frame, appIconFrames}]}`.
- Piles: `StageManagerPileComponent {preferredScaleFactor, windowVisualProperties, appIconVisualProperties
  {frameScale, shouldCenterAlign}, shouldDisplayPileLabels}`; window layout `stacked | expose`
  (`StageManagerPileStackedWindowLayoutComponent`, `...ExposeWindowLayoutComponent`); app icons
  `StageManagerPileAppIconLayoutComponent.InputModel {appIconIDs, iconBodySize, iconFrameScale,
  interItemHorizontalSpacing, twoIconHorizontalSpacing, threeIconHorizontalSpacing}`.
- Auto-hide: `StageManagerAutoHideComponent.InputModel {maximumStripContentFrame, pileFrames,
  userPreferredHiddenMode (prefersHidden | prefersHiddenWhenOccluded | prefersVisible), hidesWhenOccludedParameters
  {overlapThreshold}, stageMode (empty {iconUnionedFrame, isFinderFrontmostProcess} | standard),
  prolongedMouseEdgeEnterDelayInterval, stripRevealAutoHideDelay}`; `StripVisibilityMode` = visible | hidden |
  emptyStagePeek, revealProgress / dismissProgress.
- Motion: `StageManagerStripStageTransitionModifier.TransitionMode` = standard | reducedMotion,
  `StageManagerStripStageStandardTransitionInternalModifier`, `StageManagerToggleTransitionModifier`,
  `StageManagerShowDesktopTransitionModifier`, `StageManagerStripPeekTransitionInternalModifier`,
  `StageManagerMiniaturizeWindowTransitionModifier`, `StageManagerInlineAppExposeTransitionModifier`.
- Clicks: `StageManagerPileClickCycleSessionComponent` (active | inactive: a second click on a pile cycles its
  windows, inferred from the name), `PileClickInfo`, `AddToStageInfo` (accessibility actions), desktop:
  `StageManagerDesktopModeComponent` (`OverrideDesktopMode`, `EmptyStageOverride`, `DesktopContentVisibleChange`).

## 3. The numbers (decode of 2026-11-12)

Method as fd20e46: WindowManager.framework from the dyld cache (`ipsw dyld disass` by address; strings and
cross-references found by scanning ADRP/ADD pairs over its __text), WindowManager.app's arm64e slice with
llvm-objdump (import stubs named from the indirect symbol table) and Ghidra 12.2 headless for a few functions.
Every `WindowManager.Preferences` getter the agent calls is an import, so each layout function is found by the
getters it calls.

### 3.1 com.apple.WindowManager defaults (decoded)

`WindowManagerPreferencesController` init, WindowManager.framework 0x1d2a7a2c0..0x1d2a7cc90: one entry per key,
`stp count, string` then the default at +0x10 (Swift small strings for keys of 15 bytes or less). Address = the
store of the default.

| key | default | address | what it does |
|---|---|---|---|
| GloballyEnabled (enableStageManagerGlobally) / GloballyEnabledEver | false / false | 0x1d2a7a5ec | Stage Manager on |
| AutoHide | false | 0x1d2a7a608 | strip always hidden (userPreferredHiddenMode prefersHidden) |
| AutoHideWhenOccluded | true | 0x1d2a7b168 | strip hides while a window covers it (prefersHiddenWhenOccluded) |
| AutoHideDelay | 0.15 s | 0x1d2a7b18c | = prolongedMouseEdgeEnterDelayInterval (0x1002e0944 builds the auto-hide input) |
| AutoHideOverlapThreshold | no entry: AppIconSize + LeftStripAppIconLeftOffset = 30 pt | getter 0x1d2a880bc..0x1d2a88394 | how far a window may reach into the strip |
| HideDesktop | true | 0x1d2a7a62c | desktop items hidden in Stage Manager ("Show items: In Stage Manager" off) |
| StandardHideDesktopIcons / StageManagerHideWidgets / StandardHideWidgets | false / false / false | 0x1d2a7a648..0x1d2a7a67c | |
| AppWindowGroupingBehavior | 1 = allWindows ("All at Once"; cases singleWindow, allWindows, singleWindowWithPromotion) | 0x1d2a7a698 | |
| StageManagerMinimizationBehavior | 0 = strip (strip, stripBottom, dock) | 0x1d2a7afbc | |
| LeftStripReplacementOrder | 0 = leastRecentUsed (leastRecentUsed, top) | 0x1d2a7b110 | which pile drops off |
| ShouldPersistLeftStripOrdering | true | 0x1d2a7b440 | |
| EnableStageManagerClickToEmptyStage | true | 0x1d2a7b53c | a desktop click empties the stage |
| EnableStandardClickToShowDesktop | true | 0x1d2a7b560 | |
| EnableStageManagerExposeWindowCycling | false | 0x1d2a7b5bc | |
| StripClickSessionTimeout | 1.25 s | 0x1d2a7b4ec | second click on a pile within it cycles its windows |
| PreferredMinimumItemHeight / AbsoluteMinimumItemHeight / MaximumItemHeight | 96 / 20 / 160 | 0x1d2a7aa78 / aaa0 / aac8 | pile height |
| ItemWidth / ItemHeight | 170 / 170 | 0x1d2a7b0b8 / 0x1d2a7b0ec | not called by the strip code |
| LeftStripMinimumRowCount / MaximumRowCount | 4 / 6 | 0x1d2a7aaf0 / 0x1d2a7ab18 | |
| LeftStripPileVerticalSpacing | 30 | 0x1d2a7aa28 | |
| LeftStripEdgeHorizontalInset | 16 | 0x1d2a7a9dc | |
| LeftStripPileInterItemHorizontalSpacing | 16 | 0x1d2a7aa04 | |
| LeftStripPileMaximumWindowCount | 3 | 0x1d2a7aa50 | windows drawn per pile |
| HorizontalInsetFromStrip / VerticalInset / StageFrameMinimumHorizontalInset | 16 / 0 / 4 | 0x1d2a7b02c / b060 / b084 | stage frame |
| InterItemVerticalSpacing / InterItemHorizontalSpacing | 32 / 32 | 0x1d2a7afe0 / b008 | |
| PilePerspectiveDistance / Override | -1750 / false | 0x1d2a7a964 / a994 | |
| PileRotation | 75 (degrees: x 0.0174533 at 0x10030b130, negated for a right strip) | 0x1d2a7b464 | used by 0x10030abfc, a transition with the Chameleon values; resting tilt not traced |
| LeftStripTiltLeft/Right BaseAlpha, StepValue | 0, 0 / 0.1, 0 | 0x1d2a7a7b4..0x1d2a7a820 | meaning not traced |
| LeftChameleonLeft/Right BaseAlpha, StepValue | 0.1, 0.1 / 0.3, 0.1 | 0x1d2a7a6e4..0x1d2a7a768 | |
| LeftStripStackDepthStepValue | 0.1 | 0x1d2a7a790 | per window behind the front one (0x1002bc880: min(0.1 x depth, 1)) |
| StripCornerRadius | 8 (x the hover / press scale) | 0x1d2a7a848 | |
| StripHoverScaleDistance / StripClickDownScaleDistance / AppIconHoverScaleDistance | 16 / 16 / 5 | 0x1d2a7a870 / a898 / ab40 | pile scale (H +- 16) / H, icon (40 + 5) / 40 (0x1002bc7e0, 0x1002bbbe8) |
| AppIconSize | 40 | 0x1d2a7b140 | |
| LeftStripAppIconBottomOffset / LeftOffset | 10 / -10 | 0x1d2a7a8bc / a8e4 | |
| LeftStripAppIconTwo / ThreeIconHorizontalSpacing | -4 / -22 | 0x1d2a7a910 / a93c | icons of a set overlap |
| PileShouldIgnoreHDR | true | 0x1d2a7a9b8 | |
| HiddenStripPeekWidth | 0 | 0x1d2a7b514 | |
| EnableStrip3DTransform / StripCornerRadius / SourceAtopBlending / MostlyOccludedFlag / Shadows | true each | 0x1d2a7b2f0..0x1d2a7b388 | |
| StripWindowShadowDensityMultiplier | 1.0 | 0x1d2a7b41c | |
| EnableInlineAppExpose, InlineAppExpose IconSize / MaximumColumnCount / StageMinimumHorizontalDistance / StripEdgeHorizontalInset / StripPile Vertical, Horizontal Spacing / MaximumItemHeight | true, 24 / 3 / 80 / 48 / 32, 48 / 107 | 0x1d2a7b1b8..0x1d2a7b2c4 | the strip's inline App Exposé |
| AnimationSpeed / SlowAnimationsWhileShiftHeld | 1.0 / false | 0x1d2a7b4a4 / b4c8 | |

SystemGesturePreferencesController (trackpad strip gesture, returns these on non-internal builds):
StageManagerStripRevealAutoHideDelay 4.0 s (0x1d2b080ac), ShowHysteresis 10 (0x1d2b05a90), HideHysteresis 5
(0x1d2b05c1c), HideStartTimeout 250 (0x1d2b2b3f0), ReferenceScale 1.0, HideRegionPadding 30 (0x1d2b07d54),
DisableBackProjection false.

### 3.2 Layout (WindowManager.app, decoded)

- **Rows and pile height**, StageManagerRowCountComponent 0x1002c5ec0 (input built at 0x1002da808): H = height of the
  Stage Manager available frame, s = 30; rows = round((H - s) / (160 + s)) clamped to 4..6; item height =
  clamp((H - s) / rows - s, 96, 160); itemScaleFactor = item height / display height. (1470 x 956 with a 24 pt
  menu bar: 5 rows of 150.4 pt.)
- **A window in a pile**, StageManagerPileStackedWindowLayoutComponent 0x1002c21f0: its height x itemScaleFactor
  clamped to 96..160 sets its scale; the width may not pass 160 / display height x display width (the widest pile).
  Every window of a pile keeps its own size; they share the pile's origin (offsets = the union frame's margins x
  scale), no stagger.
- **Strip column**, 0x1002ed640..0x1002ed788: piles 30 pt apart, the column centred: y0 = minY + (H - total) / 2;
  x = the available frame's minX + 16.
- **Stage frame**, StageCalculatorComponent 0x1002938a8 (safe area 0x100293a7c, style 0x100293b38): with the strip
  shown, inset = floor(strip maximum width x 0.66) + 16 + 16; hidden, 4. All at once: only the strip side is inset
  (x += inset, w -= inset) and Stage.Style = inset; other grouping: both sides, style center. The strip maximum
  width is 0x1003e400c's (StageManagerStripMaximumFrameComponent); its closure was not traced.
- **Auto-hide input**, 0x1002dfa28 / 0x1002e0848: AutoHide -> prefersHidden, else AutoHideWhenOccluded ->
  prefersHiddenWhenOccluded, else prefersVisible; overlapThreshold 30, prolonged edge delay 0.15 s, reveal 4 s.
- **Pile hover / press**: scale (H + 16) / H and (H - 16) / H; corner radius 8 x that scale (0x1002bc7e0..8bc).
- **App icon**: 40 pt; non-centred branch 0x1002bba0c adds the left (-10) and bottom (+10) offsets.

### 3.3 Not decoded (so marked in the code, not invented)

1. The resting perspective of the piles (PilePerspectiveDistance -1750 and PileRotation 75 deg are inputs; the angle
   at rest is in transition code not traced). hyprk draws the code's flat style.
2. The strip / stage transition springs: StageManagerStripStageStandardTransitionInternalModifier stores no spring in
   its fields. hyprk flies on WindowManager's ExposeSpring (1.0, 0.25), the nearest decoded window-flight spring.
3. The strip maximum frame's closure (0x1003e400c) and how the occlusion is measured against the threshold.
4. Where windows go on stage (Stage.Style inset) beyond the safe area.
5. What the stage shows after its app's last window closes or the app hides.
6. The hover / reveal motions (a 0.12 s ease in hyprk, ours).

## 4. What still needs the Mac (exact captures)

1. Stage Manager on with 1, 3 and 6 apps at 1470 x 956 and 1710 x 1107: a still of the strip (pile frames, tilt,
   icon badge) - settles item 1 and 3.
2. 60 fps video of a pile click (2 apps, then 6), of Control Center on / off, of a window dragged over the strip and of
   the pointer resting at the left edge - settles item 2 and 6.
3. Close the last window of the stage app; hide the stage app (Cmd-H): what comes to the stage - item 5.
4. A window placed at x = 20 when Stage Manager is turned on: where it goes - item 4.

## 5. hyprk (2026-11-12)

Built (shell/lib/stage.js, services/StageManager.qml, modules/StageStrip.qml; Settings > Desktop & Dock switch):
on / off from Control Center (white disc, accent glyph) and Settings; the strip of recent apps (one pile per row,
least recently used drop off), a still of each window, a click brings the app to the stage with the windows flying
(the outgoing jump off the top under their pictures; one frame of it shows under the menu bar), new windows take the
stage, a desktop click empties it, the Dock / Cmd-Tab / Mission Control bring a parked app (Apps.focusWindow), Hide and
show again, full screen hides the strip, the strip hides when a stage window reaches 30 pt into it and comes back on a
0.15 s rest at the left edge. Off: nothing loaded, nothing listening. Limits: a window moved by dragging is only seen
at the next window event (Hyprland sends none for a floating move); title bars of the plugin are not in the pictures
(as in Mission Control).

Checked 2026-11-12 (round 2, headless, foot with 3 app ids): the strip, edge and flight layers have their own
namespaces (hyprk-stage-strip / -edge / -flight, all in hyprland.lua's hyprk-no-anim rule): the strip maps in one frame,
the flight shows no layer fade and no empty stage frame (8 of 8 clicks at scale 2 dark, 3 of 3 at 1.6 dark; a flight
used to remake its layer at launch and showed the stage empty for 1-2 frames in about 1 click of 6). Mission Control
with Stage Manager on enters and exits; the strip hides under it and comes back. Mission Control shows only the stage's
windows (the parked ones live on special:stage): whether the Mac's Mission Control shows the strip apps' windows too is
not decoded, so nothing was changed. Needs the Mac: Mission Control opened with Stage Manager on and 3 apps (a still).
