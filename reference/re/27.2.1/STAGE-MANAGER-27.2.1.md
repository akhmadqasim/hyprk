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

## 3. What is missing for a real implementation

None of these numbers sit in the metadata; each needs the function that computes it read like fd20e46 read
MissionControlLayout (Ghidra on the arm64e slice), or a capture on the Mac:

1. strip width / left inset and the pile frames (StageCalculatorComponent, StripProperties.visibleContentFrame);
2. `maximumVisibleRowCount` / `maximumVisibleColumns` (how many recent apps per screen size; RowCountComponent);
3. `preferredScaleFactor` / `preferredItemScaleFactor` (thumbnail scale) and `pilePerspectiveDistance` (the 3D tilt);
4. the stacked-window offsets inside a pile and the app-icon spacing values (inter / two / three icon);
5. centre-stage placement for `Stage.Style` center / inset (window size and position on stage);
6. the transition springs (standard and reduced motion), strip reveal / hide delays (`stripRevealAutoHideDelay`,
   `prolongedMouseEdgeEnterDelayInterval`) and the occlusion threshold;
7. what a desktop click does with Stage Manager on (`StageManagerDesktopModeComponent`).

Needs the Mac (exact captures): Stage Manager on with 1, 3 and 6 apps at the default "Looks like" 1470 x 956 and at
1710 x 1107: a still of the strip (pile frames, tilt, icon badge), 60 fps video of switching apps from the strip, of
turning Stage Manager on and off from Control Center, and of the strip hiding when a window is dragged over it.

## 4. hyprk (2026-11-12)

The Control Center button now draws `squares.leading.rectangle` (decoded into themes/icons/sf-symbols with
`tools/add-sf.py` from the 27.2.1 CoreGlyphs `Assets.car`; +10 KB). It stays disabled: hyprk has no Stage Manager yet,
and a toggle that does nothing would lie. Its on look (white disc, accent glyph) is Control Center's `Round` on-state.
