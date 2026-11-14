# Notification Centre, its widgets and the menu bar's right side: static RE of the open items (macOS 27.2.1, 26B131)

Settles GAPS-panels.md open items 3, 4 and 5 from the Mac's own code. Pseudocode excerpts with addresses:
`decomp/panels-gaps.c`. Every value says where it was read and whether it is **confirmed** (read from code or data) or
**inferred** (and from what).

## Method (PC, Linux)
- NotificationCenter.app: the arm64e slice already on disk (`re-work/r2/NotificationCenter`), imported into an own
  Ghidra 12.2 project (`re-work/gh-panels-gaps`, heap 6 GB), decompiled by range (`tools/DumpRange.java`) and by
  address (`gaps-panels/scripts/DumpAt.java`). `re-work/r2/NC.ann` (llvm-objdump) for exact instruction addresses.
- Type names: `types-NC.json` (Swift reflection). Mangled type refs in `__swift_instantiateConcreteTypeFromMangledName`
  calls were decoded by hand (`gaps-panels/scripts/mangled.py`) and their GOT slots named with
  `ipsw macho info --fixups`.
- Frameworks from the dyld cache (ControlCenter, CalendarUIKit, CalendarWidget): `ipsw dyld extract` still fails
  (`failed to remap symbol _objc_msgSend$...`). What worked: Ghidra's own `dyldcachev1` file system, called from a
  headless script (`gaps-panels/scripts/ExtractDsc.java`: `FileSystemService.getByteProvider` on
  `file://<DSC>|dyldcachev1://<image path>`). The output keeps cache addresses. Import it with `-loader MachoLoader`
  (Ghidra otherwise picks "Extracted DYLD Component", which needs the cache FSRL). For llvm-objdump run
  `re-work/scripts2/fixsymtab.py` first. `ipsw dyld disass --vaddr A --cache <DSC>.a2s` names the stub calls.
- System volume (`141-12228-174.dmg`) mounted read-only with apfs-fuse at `re-work/gaps-panels/mnt` (through the
  `sys.dmg` symlink) for the Calendar widget appex.
- REA: the MCP server had no usable provider (Ghidra 12.2 rejected). The REA CLI with Ghidra 12.1.4 ran, but its
  import of the extracted ControlCenter framework failed both times: "The program's FSRL protocol is 'file' but
  'dyldcachev1' is required" (REA cannot pass `-loader`). Clearing `MH_DYLIB_IN_CACHE` did not change Ghidra's
  choice. So no REA Evidence IDs exist for this round. All results below come from Ghidra 12.2 headless, llvm-objdump
  and ipsw.

## 1. NC section "Clear All" circle (GAPS-panels item 4)
**Answer: the visible circle is 20 pt. The hit area (and AX frame) is 28. The 24 is a different button.**

The heading row is `ExpandedHistoryHeaderView` (fields `_controller`, `__confirmsClearAll`; descriptor 0x10030a454).
- Body FUN_10003b0c8: `HStack(.center) { title; Spacer(); button }`, then `.padding(.top, 10)` (fmov #10 @0x10003b1c4),
  `.padding(.bottom, 8)` (@0x10003b1fc), `.padding(.horizontal, 16)` (@0x10003b224). Confirmed.
- Title (FUN_10003b288): `Text("Notification Center")` + `PrimaryShadowTextModifier`, `.padding(.leading, 1)`
  (@0x10003b544), `.frame(height: 20)` (@0x10003b5b8), `.accessibilityAddTraits(.isHeader)`. Confirmed.
- Title font: `Font.system(size: 18, weight: .semibold)` (FUN_100190e98, fmov #18 @0x100190ea0, through
  FUN_100190eb8 = `.system(size:weight: .semibold)`). Confirmed. (Q-panels-32 guessed "SF 17 bold".)
- The button is **`NotificationsConfirmCloseButton`** (descriptor 0x10030d194; the tuple type at 0x1002ce7f0 names it),
  not the widget-edit "Clear All circle". Confirmed. Its label is
  `ZStack { confirms ? Text("Clear All") : Image(systemName: "xmark") }` (FUN_100147b20 / FUN_100147bcc); the xmark is
  `.font(.system(size: 10, weight: .semibold))` (FUN_100190e48, fmov #10 @0x100190e50) `.frame(width: 20)`
  (@0x1001484e4). Confirmed.
- Its style (FUN_100147278): `NotificationButtonStyle(height: 20 (@0x100147710), width: nil, cornerRadius: 10
  (@0x100147718), padding: flag ? 10 : 0 (@0x100147728), glass: .regular)`. Confirmed. Which state gets the padding:
  the flag is a byte the init (FUN_10014831c) writes as the negated binding value; reading it as "text state gets
  10" is **inferred** from the Mac's 56 x 28 "Clear" capsule (36 text + 2 x 10).
- `NotificationButtonStyle.makeBody` (FUN_10006ba4c): label `.font(.subheadline)` `.foregroundStyle(.secondary)`
  `.lineLimit(1)` `.padding(.horizontal, padding)` `.frame(width:height:)` `.clipShape(Rectangle())`
  `.contentShape(RoundedRectangle(r, .continuous).inset(by: -4))` (mov x8, #0xc010.. = -4.0 @0x10006bf14)
  `.background(RoundedRectangle(r).fill(pressed ? .quaternary : .clear))` `._glassEffect(glass, in: RoundedRectangle(r))`.
  Confirmed from the modifier types (ModifiedContent chain at 0x1002dc1e0 .. 0x1002d0198).

The three numbers:
- **20**: the glass shape is the 20 pt frame (circle when padding 0: 20 x 20, r 10). Matches the 1 px/pt shot. Confirmed.
- **28**: the content shape is the frame inset by -4 on every side, 20 + 8 = 28. That the AX frame follows the content
  shape is **inferred**: every 20 pt button in Q-panels reads 28 in AX (card close 28 x 28, "Show less" 80.5 x 28,
  "Clear" 56 x 28), which only fits this.
- **24**: `(24, 24, 12, 0, .regular)` at 0x10017cbd8 is in FUN_10017c490, the widget-edit container (strings
  "widget-editor-button", "Clear All Notifications", "Clear Banners Only"). It is not the heading row. Confirmed that
  the heading row does not use it.

hyprk changes (not made):
- `shell/modules/NotificationCenter.qml` heading Pill `implicitHeight: 24` -> 20 (Theme.nc.pillSmall). The hit area
  should be 4 pt larger on each side (28), the glass 20.
- Same file, heading `Typography.font(17, Typography.bold)` -> 18 semibold.
- Heading row margins: Mac padding top 10, bottom 8, title frame height 20 (ours not checked against this).
- The Pill's label font: Mac `.subheadline` in `.secondary`, xmark 10 semibold (ours not checked).

## 2. NC Calendar widget month grid (GAPS-panels item 3)
**Answer: the grid is computed from the widget's size. Fixed constants: digit font 10, minimum row height 14, today
circle 18. Column and row pitch come from the space left.** The widget UI is not in the appex: the 73 KB
`Calendar.app/Contents/PlugIns/CalendarWidgetExtension.appex` only lists the widgets. The views are in
`CalendarWidget.framework` (CWF) and the grid in `CalendarUIKit.framework` (CUK) `CUIKMonthView`.

- `CUIKMonthView.Styling` fields (Swift reflection): fullColor, gridFontSize, gridRowHeight, todayCircleSize,
  dateLabelFont, dateLabelPadding, allowKashida, showHeader, showOutOfMonthDays, dividerPadding, dividerHeight,
  altCalendarUnderlineWidth, altCalendarID, altCalendarFont, hideAltCalendarLabel, monthNameFormat, dimmingMode,
  colours. Confirmed.
- Values, the same at both call sites (small/medium Month widget FUN_247078628, CalendarMonthWidget.swift, call
  0x247078cfc; medium List widget FUN_2470eeedc, MediumListContentView.swift, call 0x2470efb80; callee named by
  ipsw as `CUIKMonthView.Styling.init(...)`): gridFontSize **10**, gridRowHeight **14**, todayCircleSize **18**,
  dateLabelPadding **5**, dividerPadding **4**, dividerHeight **10**, altCalendarUnderlineWidth 14, showHeader true,
  showOutOfMonthDays **false**, month name format "MMMM". Confirmed (fmov d0..d6 just before the call).
  The Month widget body has this one Styling call site, with no family branch around the constants. Whether other
  families reach a different path, and the family list itself, were not read.
- Row pitch (CUK FUN_1d148f418, fed with the GeometryReader height by FUN_1d1491594): with n = weeks in the shown
  month and h = the measured month-name header height when showHeader,
  `extra = max(0, H - (n * 14 + h)) / n`, so **row pitch = 14 + extra = (H - h) / n** when the space allows.
  Confirmed for the formula. h is a measured State value, not a constant (not read).
- Columns: each day cell in a week row gets `frame(maxWidth: .infinity)` (CUK FUN_1d148c63c). So **column pitch =
  content width / 7**. Inferred (argument order of the SwiftUI frame call, the callee is an unnamed stub).
- Content inset: the Month widget pads the grid by `viewMetrics.widgetMargins + viewMetrics.horizontalMonthViewMarginDelta`
  (CWF FUN_247078628 adds ViewMetrics +0x10 and +0x28; getter 0x2470ec004 does the same add). Confirmed for the sum.
  The values: **not found** (ViewMetrics is an environment object, its init 0x2470ebe80 has no direct caller in CWF).
- Check against the Mac small widget (164 x 164): column pitch 19.6 -> content width 137 -> inset about 13.5 per side;
  row pitch 19.2 with heading to first row 19.5. That fits `(H - h) / n` with h about 19.5. Inferred, the margins are
  not read.
- Medium widget content size in NC: not found in NC (the size is the widget family's, from ChronoKit, not traced).

hyprk changes (not made):
- `shell/Theme.qml` `nc.monthCell: 17`, `nc.monthGap: 2` (fixed 19 x 18 pitch): the Mac has no fixed cell. Columns
  should be content width / 7 and rows (height - header) / weeks, with rows never below 14.
- `shell/Theme.qml` `font.widgetMonth: 10`: matches gridFontSize 10. The today circle should be 18.
- `shell/modules/NotificationCenter.qml` month grid: out-of-month days hidden on the Mac (showOutOfMonthDays false).
  Ours not checked.

## 3. Menu bar: Spotlight status item by default (GAPS-panels item 5)
**Answer: a clean account shows the Spotlight item. Hiding it is a per-user, per-host setting.**
- Owner: `ControlCenter.framework` class `SpotlightPreferences`. Its init (0x20a52ede8) opens the preferences domain
  **`com.apple.Spotlight`** with `kCFPreferencesCurrentUser` and **`kCFPreferencesCurrentHost`** (a ByHost file).
  Confirmed (ipsw names the two CF globals at 0x20a52ee0c / 0x20a52ee18).
- Key **`MenuItemHidden`** (Bool). `statusItemEnabled` getter (export 0x20a52f25c -> 0x20a52efa0) returns
  `!MenuItemHidden`. The read (0x20a52ef64 -> helper 0x20a588c80) returns Optional<Bool>.none (2) when the key is absent,
  then `& 1` gives false. So **absent key = not hidden = item shown**. Confirmed.
- The setter (0x20a52efc4) writes `!value` to `MenuItemHidden` and logs "Setting SpotlightPreferences.statusItemEnabled
  to %d". A second key `MenuItemOrder` exists (0x20a52f0cc). Confirmed.
- No seed of `MenuItemHidden` was found in Spotlight.app, ControlCenter.app, Setup Assistant.app, MenuBarAgent.app or
  PreferencePanes (byte search of the system volume). Bounded search, so "nothing seeds it" is inferred.
- So the Mac's own bar (Battery / Wi-Fi / Control Centre / Clock) has the item hidden by that user. Inferred.
- ControlCenter.app reads it next to Siri and Time Machine (0x100064f44 Siri, 0x100064fb4 Spotlight, 0x100065030
  TimeMachine, each `statusItemEnabled` into an enum case 2 entry). The order of the default-visible items: not found.
- `SystemItemMenuBarPreferences.showSpotlight` (0x20a53b884) is a plain stored Bool (Settings model), not a defaults key.

hyprk: keep the Spotlight item (it is the default). To match the reference Mac account, hide it as a user setting,
not by removing it. No constant to change.

## 4. From "Not compared"
Taken: NC hover state for buttons. `NotificationButtonStyle` has no hover fill. Only pressed shows `.quaternary`
(confirmed, FUN_10006ba4c). `NotificationsConfirmCloseButton` adds `.onHover` with an easeInOut animation
(FUN_100147d34) and leaves the confirm state on its own `spring(response 0.5, dampingFraction 0.85)` (FUN_1001479a0).
What the hover changes was not traced. "Edit Widgets" stays `(24, nil, 12, 10, .regular)` with the same -4 content
shape, so its hit area is 32 tall (inferred as above).

## Not found
- ViewMetrics values (widgetMargins, horizontalMonthViewMarginDelta) for the Calendar widgets: tried CWF fields,
  the init 0x2470ebe80 and its allocating wrappers (no direct callers), d7 argument patterns. Next step: find who
  sets the `ViewMetricsKey` environment value (probably per family, in CWF or the appex).
- The measured header height h of CUIKMonthView (a State read in FUN_1d148f418): needs the month-name label's
  dateLabelFont, which is built at runtime (func 0x248122ad0 in FUN_247078628).
- NC medium widget content size.
- Default order of the menu bar's status items.
- REA Evidence IDs: none (see Method).
