# Spotlight 27.2.1 (build 26B131): what the code says

Sources: the 27.2.1 dyld cache (`~/Downloads/macos/dyld-27.2.1`, SpotlightUIInternal, SpotlightUIServices,
SpotlightUIShared, SearchUI; disassembled with `ipsw dyld disass --demangle`, Swift types with `ipsw dyld macho
--swift`), the restore image's system DMG `141-12228-174.dmg` (single files with 7z: Spotlight.app, the frameworks'
`Localizable.loctable` / `FirstTimeExperience.loctable`). Spotlight.app (0.27 MB) holds no UI: it links
SpotlightUIInternal. Earlier decodes of the window springs and glass: MAC-ANSWERS.md "REA 27.2.1" section 4 and
`decomp/SpotlightUIInternal-open-springs.asm`; pixels of the live Mac: MAC-ANSWERS.md Q-panels-14..-26.

Marks: **decoded** (address / file), **measured** (Mac pixels or our session), **inferred** (reading of decoded
code, not traced to the end), **unknown**.

## 1. Open, close, resize

| What | Value | Mark |
|---|---|---|
| open, content layer | `transform.scale.x` and `.y` 1.12 -> 1 on CASpringAnimation(perceptualDuration 0.28, bounce 0.32) (flag branch: x bounce 0.41, y 0.95 -> 1), `translation.y` -> 0 | decoded (FUN_2adea2ff0, caller 0x2ADE99894) and measured (MAC-ANSWERS #67 A4) |
| open, window | alpha 0 -> 1 Spring(0.28, 0.41); invocation state {xScale 1.12, yScale 0.95, opacity 0, blurRadius 25} | decoded (FUN_2ade9ef14, FUN_2ade9a5ec) |
| close | scale.x 1 -> 1.12, scale.y 1 -> 0.95 Spring(0.45, 0.05); alpha Spring(0.28, 0.41); contentBlurRadius 0 -> 25 Spring(0.51, 0.05) | decoded (FUN_2adea36c8) |
| resize / morph / jump-to-app | statics at 0x2ade84974..0x2ade84f50: (0.41, 0.12) (data_2e1b7ebc0) and (0.2, 0.05) (data_2e1b7ebc8), read in sub_2ade899d0 (BrowseButtonController); the others are the browse-button springs (section 2a) | decoded values; (0.41, 0.12) / (0.2, 0.05) not mapped to a state |
| window size per content | `WindowSizingCoordinator` / `ScopedWindowSize` / `WindowAnimatedHeightModifier` / `WindowAnimatedWidthModifier`: the height and width animate on their own modifiers | decoded types (Swift metadata), springs not mapped |
| mode list unfold | 0.17 s ease-in-out, 11 frames | measured (Q-panels-26) |

## 2. Modes and their buttons

- Types: `BrowseButtonController` {currentBrowseMode, selectedButton, highlightedButton, isSearchHorizontallyExpanded,
  buttonStates [BrowseButton.AnimationState {browseMode, index, isTranslated, isScaled, isVisible}],
  expandButtonsOnCollapse, onShowBrowseButtons, allowsBrowseButtons, mouseMonitor,
  **cachedShouldShowPasteboardBrowseButton**, horizontalBrowseButtonAnimation}; `MitosisButtonStack` (a ForEach over
  the reversed button states with an `_OffsetEffect`: the buttons split out of the bar); `BrowseButton` {state,
  windowWidth, collapsedWindowHeight, isSelected, action, onHover}. Decoded (Swift field metadata). The live 27.2.1 Mac
  shows these as the 4-row list under the bar on hover (Q-panels-22), so the horizontal "mitosis" layout is the other
  branch of `isSearchHorizontallyExpanded` (inferred). The Clipboard button only exists while
  `cachedShouldShowPasteboardBrowseButton` (history allowed; inferred from the name).
- Names (FirstTimeExperience.loctable, en): "Browse More Locations"; "for Applications", "for Files", "for Actions",
  "for Clipboard" (SHORTCUT_LABEL_APPS/FILES/ACTIONS/CLIPBOARD), "for search history", "to filter your search".
  Mode titles (Localizable): Apps, Files, Actions; "Pasteboard" in SpotlightUIShared. Decoded.
- Keys: `KeyboardHandlingBackdropView.KeyboardShortcut` (sub_2adf2fdbc), only when the device-independent modifier
  flags are exactly Command (`and 0xfffe0000; cmp 0x100000`). Decoded:

  | key | case |
  |---|---|
  | Cmd-1..4 (key codes 18-21) | setTopLevelBrowsingFilter(index 0..3) (table 0x2adffb6e8) |
  | Cmd-0 (key code 29) | clearTopLevelBrowsingFilter |
  | Cmd-Return, Cmd-"\n", Cmd-R | revealSelectedItem (Return goes through an SUIUtilities check first) |
  | Cmd-I | getInfoForSelectedItem |
  | Cmd-B | performWebSearch |
  | Cmd-D, Cmd-L | selectDictionaryResult |
  | Cmd-Y | quickLookPreviewItems |
  | Cmd-K | openWikipediaResult |
  | Cmd-, | openSpotlightPreferences |
  | Cmd-H | openSpotlightHelp |
  | Cmd-J | archiveInjection (internal builds only) |

  Space for Quick Look and Cmd-C on a row are not in this table (SearchUI's command handler, not traced: unknown).

## 2a. The browse-button branch ("Mitosis"), round 2 (2026-11-12)

`BrowseButtonController` method sub_2ade88f6c (vtable, ptrauth b72e; reached from sub_2ade881dc, which walks
`BrowseModeUtilities.topLevelBrowseModes`) shows the buttons. Decoded (SpotlightUIInternal 27.2.1, objc stubs resolved
from the cache's stub island):

| step | value | address |
|---|---|---|
| gate | `+[SUIUtilities isBrowseButtonAnimationEnabled]` = NOT the `SUIDisableBrowseButtonAnimation` default AND NOT a second SUIUtilities test (0x2300e6620, not resolved) | SearchUI 0x22f0b2738, call 0x2ade89138 |
| smoothness | `WindowAnimationCoordinator._mitosisSmoothness` set to 100 at once, then to 0 inside `withAnimation(Spring(duration 0.71, bounce 0.01))` | 0x2ade89184 (`#0x4059000000000000`), closure sub_2ade8ba3c, spring data_2e1b7eba0 (init sub_2ade84a94) |
| window part | Spring(0.39, 0.39) when the gate is on, else `.linear(0)` | data_2e1b7eba8 (sub_2ade84ac8), 0x2ade892e8 |
| per button i: translate | `buttonStates[i].isTranslated = true` (byte +0x10 of the 0x18-byte AnimationState) in Spring A[i] = (0.35, 0.43) (0.45, 0.39) (0.55, 0.35) (0.6, 0.31); past the table (0.45 + 0.1 i, max(0, 0.39 - 0.04 i)) | closure sub_2ade8bac8, table data_2e1b7ebb0 (sub_2ade84aec), fallback 0x2ade894d8 |
| per button i: scale | `isScaled = true` (+0x11) in Spring B[i] = (0.41, 0.394) (0.55, 0.35) (0.65, 0.32); past the table (0.41 + 0.1 i, max(0, 0.394 - 0.04 i)) | closure sub_2ade8bba8, table data_2e1b7ebb8 (sub_2ade84d14), fallback 0x2ade89590 |
| per button i: visible | `isVisible = true` (+0x12) in Spring(0.49, 0.15).delay(0.17) | closure sub_2ade8bc88, data_2e1b7eb98 (sub_2ade84974) |
| initial | `horizontalBrowseButtonAnimation = .linear(duration: 0)`; `cachedShouldShowPasteboardBrowseButton` = `SPUISPasteboardHistoryDefaultsManager.shared.shouldShowFilter` | init sub_2ade87ed0 |

`BrowseButton.body` (Swift metadata): a `Circle` with a foreground colour, `SelectionMaterialView` background with an
opacity, `_ScaleEffect`, a `Button` with an `Image` (font, `_BlurEffect`), padding, hover region and `_PositionLayout`:
round, glyph-only buttons, no label. `MitosisButtonStack` places them with an `_OffsetEffect` each. **Not built**: the
live 27.2.1 Mac shows the labelled 4-row list (Q-panels-22, "no round mode buttons"), which is not this view (it has
labels and Cmd-digit hints); the branch that picks the circles over the list, the offsets, the circle size and the
`mitosisSmoothness` consumer are not traced. A build needs that branch, or a Mac capture of the circles.

## 2b. Tab, Space, Quick Look, Cmd-C (round 2)

- The field is `DeleteHandlingTextView` (NSTextView). Its `insertTab:` / `insertBacktab:` (thunks 0x2adee60bc /
  0x2adee61ac, body sub_2adee60c8) send the selector up the chain first (`[nextResponder tryToPerform:with:]`) and
  only fall back to `super` when nobody takes it. Decoded.
- `SearchViewController.insertTab(_:)` (0x2adf76080): asks its vtable +0x448 for a responder and forwards `insertTab:`
  when it responds to it; otherwise a weakly held coordinator (+0x1c8) performs it through +0xa8. The receivers are
  not traced, so what Tab does on the top hit is not decoded. Measured on the Mac: the top hit carries "Search <App>"
  with a "tab" badge (Q-panels-19/-20) and Tab in Actions completes the first suggestion (Q-panels-24). hyprk keeps Tab
  = next row (not Mac data; nothing better is decoded).
- A forwarding target (sub_2adf3ba18, `forwardingTargetForSelector:`) hands exactly `insertNewline:`, `insertTab:`,
  `quickLookPreviewItems:` and `copy:` from the field to the search controller (sub_2adf38f00): Cmd-Y (AppKit's
  `quickLookPreviewItems:`) and Cmd-C reach the results from the field. Decoded.
- **Space**: no key-code-49 test in SpotlightUIInternal's key paths (the two `mov w, #0x31` are the Cmd-Space hot key
  registration, 0x2ade556cc / 0x2ade55ab4) and Space is not among the forwarded selectors: Space types a space; Quick
  Look is Cmd-Y only. Not built (nothing to build).
- The other `keyDown:` overrides: key code 0x30 (Tab) moves to the next parameter of an Actions parameter summary
  (`ParameterSummaryViewModel.beginTypingInNext`, 0x2adf41ff0); key code 0x24 (Return) sends `insertNewline:`
  (0x2adec2e20).

## 5a. Result category order (round 2)

Not in the Spotlight UI code: `SPUISSectionBuilder` (SpotlightUIServices) loops over the sections handed to it in their
order ("SectionBuilder input", 0x213227c18), builds each, drops empty ones ("DROPPED empty section", 0x213228218) and
outputs them in the same order (0x2132282c4); no sort was seen. The order comes with the query results
(`com.apple.spotlight.tophits` first); it is set by the search service, which is not in these images. Unknown.

## 3. "Hold"

1. **Holding Command shows the shortcuts.** `SearchViewController` has `commandKeyMonitor` and `commandKeyHintTimer`
   (fields, decoded). The timer is scheduled at **0.35 s** (`0x3fd6666666666666`, 0x2adf7cf18) on one branch, and
   at max(0, t + 0.3) (`0x3fd3333333333333`, 0x2adf7cff0; t from `siriHintTimer`'s date) on the other; its block
   is sub_2adf7deb0. What it shows: `BrowseButtonShortcutIndicatorOverlay` + `KeyboardShortcutIndicator`
   {keyboardShortcut, commandModifier, keyCode, keyboardSourceChangeID: the key label follows the keyboard layout}
   and `KeyboardShortcutIndicatorController` {backShortcutIndicatorShouldBeVisible, viewOptionsMenuIsVisible}.
   Decoded types and constants; that the hint is the browse modes with their Cmd-digits is inferred.
2. **Press-and-hold on the menu bar icon** (`-[SPUISpotlightMenuItem _installGestureRecognizersOnButton:]`, an
   NSPressGestureRecognizer, 0x2ade56ad4). `_handleStatusItemPress:` (0x2ade56b60): on press **began** it remembers
   whether Spotlight was showing (ivar +9), opens it at once if it was not (`_toggleFromStatusItemForceShow:NO`),
   and starts a **1.0 s** NSTimer (`fmov d0, #1.0`, 0x2ade56bcc). On **ended**, if it was already showing, the long
   press did not fire and it still shows, it closes. `_statusItemLongPressTimerFired:` sets the long-press flag
   (+0xa) and calls `_toggleFromStatusItemForceShow:YES`. So: a click opens on mouse-down; a click on the icon
   while open closes on mouse-up; holding the icon 1 s keeps it open. Decoded.
3. The query survives a close for **8 minutes**: `SearchViewController.startClearTimer(secondsToClear:)`, log
   "clearing for 8 min timer" (0x2adf66460), `clearOnInvoke`. Decoded string; the 480 s constant itself is not
   traced. MAC-ANSWERS R2 saw "Reopening soon keeps the last query".

## 4. Clipboard history

| What | Value | Mark |
|---|---|---|
| defaults domain keys | PasteboardHistoryEnabled, PasteboardHistoryTimeout, PasteboardHistoryVersion, PasteboardHistoryNeedsWipe, PasteboardContinuityEnabled, SPPasteboardFTEEngaged, allowPasteboardHistoryManagedPref (MDM) | decoded (SpotlightUIServices cstrings) |
| enabled | plain `boolForKey:` (sub_21324ef8c / sub_21324f03c): **off** unless the user allowed it | decoded |
| timeout | `integerForKey:` (sub_21324e31c): 1800 (0x708), 604800 (0x93a80) taken as is, **anything else 28800** (0x7080): 30 min, 8 h (default), 7 days | decoded |
| first use | `PasteboardFTEViewController`: "Allow search results from Clipboard"; "Spotlight can search and display items you’ve copied to your clipboard. Personal and sensitive information may appear in search results. You can manage Clipboard Search at any time in [Spotlight Settings](%@)."; buttons "Allow", "Not Now" | decoded (SpotlightUIInternal Localizable.loctable en) |
| empty | "No Items"; filtered: "No Results" | decoded (SpotlightUIShared Localizable) |
| per item | delete one item (`com.apple.spotlight.delete.pasteboard.item`), clear all (`com.apple.spotlight.clear.pasteboard.history`), expiry (`...delete.pasteboard.expired`), superseded items replaced (`...replace.pasteboard.superseded`), continuity (`...pasteboard.continuity`) | decoded names; their keys unknown |
| secret copies | the only images of the dyld cache that know `org.nspasteboard.ConcealedType` / `org.nspasteboard.TransientType` are CoreFoundation's (0x184b431e4, 0x184b43203): the pasteboard layer drops concealed / transient items before Spotlight sees them | decoded strings, path inferred |
| row | 62 tall, text 17 regular, "Text · Copied yesterday" 15 regular grey, a round copy-type badge at the right | measured (Q-panels-25) |
| how many items | unknown (no count constant found in SpotlightUIServices / SpotlightUIShared) | unknown |
| Return on an item | `SSPasteboardHistoryCommandDetail` / `SPUISPasteboardHistoryCommandDetail` command; copy vs. paste into the front app not traced | unknown |

## 5. Results, Tab, calculations

Measured on the Mac and already built (MAC-ANSWERS.md Q-panels-16..-21, -24): no section headers, top hit with
"Search <App>" + a tab badge, rows of 62, calculator answer inline with a result card and "Show Results"; Tab in
Actions completes the first suggestion. Quick keys: "Add quick keys" (QUICK_KEYS_BUTTON_TITLE, decoded),
`KeyboardAliasTextField` / `KeyboardAliasTextFieldFormatter` (decoded types). Not decoded: result category order,
conversions engine, drag-out, Cmd-C.

## 6. hyprk against this (2026-11-12, round 2)

| Feature | before | now |
|---|---|---|
| open / close springs | built | unchanged (dist config headless: open 0.04 -> 0.93 in 9 frames + tail, close 8 frames, at 2x and 1.6x). Round 2: dist/try-nested.sh itself run inside a headless Hyprland (Wayland backend, frames paced by a host compositor, scale 2, first open after start, light and dark): open alpha .05 .18 .34 .52 .67 .81 .91 .94 in the nested output and the same series in the host's copy of the window, close 7 frames. The user's "no animation" is not reproduced; the one part not reproducible here is GNOME as the host |
| Cmd-1..4 | Super / Ctrl / Alt + 1..4 in the field | same; **Ctrl+1..4 never arrive** (Hyprland's Ctrl+N Spaces binds), Super+1..4 are GNOME's in the nested window: only Alt+1..4 work there |
| Cmd-0 | none | back to all results |
| Cmd-R / Cmd-Return | none | the selected file's folder in the Finder (all results and Files) |
| Cmd-, | none | System Settings > Spotlight |
| holding Command | none | 0.35 s held (Command or Ctrl alone, empty field) shows the mode list with its shortcuts while held |
| query on reopen | always cleared | kept and selected when reopened within 8 minutes |
| clipboard secret copies | CLIPBOARD_STATE=sensitive only | + x-kde-passwordManagerHint = secret, org.nspasteboard.ConcealedType / TransientType; cliphist behind the same gate |
| clipboard first use | own texts, "Turn On" | the Mac's title, message, "Not Now" / "Allow" (8 h) |
| clipboard row | relative time at the right | "Text · Copied yesterday" second line |
| delete one clipboard item | none | Cmd-Delete on an empty field (key inferred) |
| Cmd-B, Cmd-K, Cmd-Y | none | built (039b734): Google / Wikipedia URL to the default browser, Quick Look in our Finder |
| Cmd-I | none | our Finder on the file's folder with its Get Info popover (`hyprk-finder --info`) |
| Cmd-D/L, Cmd-H | none | not built (no hyprk counterpart) |
| menu bar icon press-and-hold | click toggles | not built (MenuBar.qml is shared; see the hand-off in the report) |
