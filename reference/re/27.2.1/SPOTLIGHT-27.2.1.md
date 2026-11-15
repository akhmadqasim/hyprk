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
| mode list unfold | 0.17 s ease-in-out, 11 frames (Q-panels-26). Superseded by Round R3.2: it grows out of a point, it does not unfold | measured |

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
| holding Command | none | 0.35 s held (Command or Ctrl alone, empty field) shows the mode list with its shortcuts while held. **Removed in Round R3.2** (what the timer shows is not traced; no capture shows the list on a hold) |
| query on reopen | always cleared | kept and selected when reopened within 8 minutes |
| clipboard secret copies | CLIPBOARD_STATE=sensitive only | + x-kde-passwordManagerHint = secret, org.nspasteboard.ConcealedType / TransientType; cliphist behind the same gate |
| clipboard first use | own texts, "Turn On" | the Mac's title, message, "Not Now" / "Allow" (8 h) |
| clipboard row | relative time at the right | "Text · Copied yesterday" second line |
| delete one clipboard item | none | Cmd-Delete on an empty field (key inferred) |
| Cmd-B, Cmd-K, Cmd-Y | none | built (039b734): Google / Wikipedia URL to the default browser, Quick Look in our Finder |
| Cmd-I | none | our Finder on the file's folder with its Get Info popover (`hyprk-finder --info`) |
| Cmd-D/L, Cmd-H | none | not built (no hyprk counterpart) |
| menu bar icon press-and-hold | click toggles | not built (MenuBar.qml is shared; see the hand-off in the report) |

## Round R3.2 (2026-11-14): only the pill while the field is empty; light over white; open / close

User report: "spotlight bar itu cuma pill jika tidak ketik apapun" (with nothing typed, only the pill), and no extra
motion or extra information anywhere. Mac evidence: `screens/27.2.1/panels/spotlight-light-white-{empty,results}.png`,
`spotlight-light-white-open-close.mov`, `spotlight-pill-{idle,hover,clear}-{light,dark}.mov`,
`spotlight-pill-idle-{light,dark}.png` (MAC-ANSWERS-3.md R3.2, R3.2b), `scaled/more-space-spotlight-close.mov`. Clips are
VFR on a 60 fps base: times below are pts. Ours: headless MBA output (1280 x 832 pt, scale 2), light over a flat white
wallpaper and dark over a flat 26 grey, `mcap` (present times, `long_intervals` 0 in every run), the same 840 x 600 pt
window around the bar as the Mac clips (bar at local 160, 105 in both). Measure: `live/spotlight-r32/scripts/panel.py`
(darkness against the frame before; extent at half the frame's own peak on the row and column through the centroid,
"level" = mean darkness in the central half against the settled frame, about the alpha); fits `fit.py`, comparisons
`cmp.py` (best time shift, RMS). Series in `live/spotlight-r32/*.txt`, crops `*-sbs.png` (Mac left, ours right, same
scale).

### What showed besides the pill, and what the Mac does

| ours before | Mac | now |
|---|---|---|
| mode list once the pointer moved over the bar (PointerGate), stays after it leaves | the list appears when the pointer **starts to move anywhere** (far from the bar too), stays after it leaves; never without a move, also right after open with a resting pointer (R3.2b a, b; measured) | trigger = any real move over the whole Spotlight layer (`noteMotion`, the full-screen MouseArea + bar + panel), PointerGate kept (a layer mapped under a resting pointer gets an enter and a motion at that point), reset on reopen |
| mode list while Command / Ctrl is held 0.35 s (commandKeyHintTimer) | no capture shows it; the decoded timer shows shortcut indicators whose target is not traced (section 3.1) | **removed** (and `SL.HINT_HOLD_MS`, `SL.isHintKey`, its test) |
| list unfolds downward (clip 0 -> 214, 0.18 s ease-in-out) | grows out of a point 20 pt below the panel top: scale, fade and blur (R3.2b hover clip) | the Mac's curve, below |
| emptied results panel gone in one frame | the rows go, then the empty panel shrinks, fades and blurs into the same point (R3.2b clear clip) | the Mac's curve, below |
| app rows "Text Editor / Application" | the name alone (results still, clear clips) | **"Application" line removed** |
| query kept 8 min, reopened selected with its results | decoded (section 3.3) and R2 "Reopening soon keeps the last query" | kept (Mac behaviour; the one way the panel shows without typing in this session) |

The decoded `BrowseButtonController` springs (section 2a) do not fit the list's motion (RMS 2.6-10 % against 0.2 % for
the fit below); `_mitosisSmoothness` and the "Mitosis" names match what is seen (the panel splits out of the bar), the
consumer is still not traced.

### Mode list appear (spotlight-pill-hover-light.mov, light over white)

Width / height against the settled 519.5 x 230.5 pt, "level" (alpha): 0.783 s .26 (faint), .817 .438 / .351 / .422,
.833 .548 / .471 / .556, .850 .649 / .590 / .659, .867 .738 / .696 / .731, .883 .813 / .787 / .792, .900 .875 / .857 /
.849, .917 .919 / .911 / .894, .933 .956 / .950 / .940, .967 .996 / .996 / 1.0, overshoot 1.015 / 1.017 at 1.02-1.05 s,
settled 1.20 s. Centre x fixed; top 214.5 -> 202 pt: the scale's anchor is 20 pt below the panel's top (222 pt local,
from the top and the scale at .817 / .867 / .933: 221.3 / 223.4 / 222).
Fits: x scale 0.16 -> 1 and y 0.03 -> 1 on Spring(0.33, bounce 0.21) from t0 0.76 s (RMS 0.16 % / 0.23 %); alpha
critically damped Spring(0.25) from the same t0 (RMS 0.018; linear 0.054). Blur: the left edge is 71-75 px wide at
.817-.833 against 57 settled, 59 at .867, 55-57 from .933 (about 9 pt sigma on screen early, gone by 0.93 s); hyprk
uses the window's contentBlurRadius 25 (decoded for the window) on the scale spring: estimated, not fitted.
Ours (`Theme.spotlight.listSpring` etc., plugin materialize = alpha): RMS width 0.12-0.30 %, height 0.8-2.5 %, level
1.2-1.6 % at the best shift. Dark (spotlight-pill-hover-dark.mov) has too little contrast over its 26 grey window for
this measure; the first change is at 0.73 s, full at about 0.93 s (MAC-ANSWERS-3), the same length.

### Clear to the pill (spotlight-pill-clear-light.mov)

Field empty at 3.55 s; the stale "t" rows stay to 3.78 s (the search's own latency: 0.6 s in the dark clip, so not a
constant: not copied); 3.80 s the empty panel at full size; then width .938 .832 .715 (3.867, repeated at 3.883)
.505 .427 .366 .317 .255, level .873 .808 .737 .562 .478 .363 .245 .065, gone at 4.00 s. Fits: x 1 -> 0.2 on
Spring(0.28, bounce 0.08) from 3.8125 (RMS 0.28 %), y 1 -> 0.045 (RMS 2.2 %), alpha linear 1 -> 0 in 0.185 s (RMS
0.022; a critical spring 0.055). Ours: RMS width 0.45 %, height 3.2 %, level 2.3 % (the Mac's repeated frame left out),
gone in the same frame. The blur's layer is switched on before the first frame (switched on by the first blur value it
drew one empty frame: mcap, run c1).

### Open and close (spotlight-light-white-open-close.mov; idle clips; More Space close)

| frame | Mac width / level / edge | ours before | ours now |
|---|---|---|---|
| open 1 | 1.096 / .375 / 13.0 | 1.100 / .246 / 23 | 1.091 / .387 / 15 |
| open 2 | 1.075 / .568 / 12.5 | 1.077 / .425 / 43 | 1.069 / .573 / 14 |
| open 3 | 1.054 / .736 / 13.0 | 1.054 / .606 / 38 | 1.050 / .739 / 15 |
| open 4 | 1.037 / .865 / 12.5 | 1.035 / .764 / 32 | 1.033 / .872 / 15 |
| open 5 | 1.021 / .963 / 12.5 | 1.021 / .899 / 28 | 1.017 / .977 / 15 |
| open 6 | 1.010 / .998 / 12.0 | 1.008 / .990 / 25 | 1.008 / .999 / 14 |
| close 1 | 1.006 / .325 / 20 | 1.002 / .940 | 1.008 / .315 / 30 |
| close 2 | 1.025 / .051 / 36.5 | 1.012 / .799 ... 7 frames to .02 | 1.019 / .050 / 22 |
| close 3 | gone | | gone |

- The open has **no blur**: the edge (10-90 %, pt; settled 12-13 Mac, 14-15 ours) stays put from the first frame,
  in this clip and in spotlight-pill-idle-light.mov. The decoded contentBlurRadius 25 -> 0 is not drawn: removed
  (`openBlur`, its texture and effect).
- The open's alpha leads its scale: the Mac's levels are the decoded Spring(0.28, 0.41) at 50.0 / 49.9 / 50.1 ms + k
  frames, the scale's first frame stays at 38.7 ms. `animAlpha.firstAt` 0.050 on open.
- The close shows two frames, alpha .325 then .051 (More Space: one, .30). The decoded alpha Spring(0.28, 0.41) and
  blur Spring(0.51, 0.05) would take 7 frames: both now on a critically damped 0.045 s spring (.325 / .052 one and
  two frames in). The scale keeps the decoded Spring(0.45, 0.05) (1.006 / 1.025 at those frames fit it).

### Light over a white window (spotlight-light-white-empty.png, -results.png; hover clip for the list)

Bar, 2x rows on the column 340 pt into the bar (`live/spotlight-r32/light-sbs2.png`):

| rows | Mac | ours before | ours now |
|---|---|---|---|
| top rim (2 rows) | 51, 31 | 8, 10 | 38, 40 |
| 5 / 14 / 23 % | 8 / 18 / 30 | 15 / 25 / 36 | 11 / 17 / 29 |
| 51 % | 65 | 68 | 65 |
| 74 / 87 % | 94 / 112 | 96 / 113 | 92 / 109 |
| bottom rim (2 rows) | 147, 163 | 127, 127 | 151, 152 |
| shadow +2 / +20 / +60 px | 201 / 219 / 247 | 201 / 219 / 247 | same |
| middle row, left edge -> inside | 220 -> 60 -> 64 | 212 -> 141 -> 72 -> 67 | 212 -> 141 -> 69 -> 64 |

Veil stops .975 / .9325 / .754 / .579 / .517 at 0 / .14 / .5 / .87 / 1 (each row's alpha scaled by Mac / ours), a 1 pt
white rim .13 (top fifth) and .2 (bottom fifth). The same bar is the dark-mode one (Q-panels-14 over white 8 / 65 / 127).
Left open: our side shadow is 6-8 levels darker right at the edge (the plugin's shadow).

Mode list panel over white (read from the h264 clip, see R4.4 below: biased 8-12 dark in the mid-tones): Mac 115
(11 %) -> 151 (mid) -> 188 (95 %); ours with the veil .45 / .38: 142 -> 146 -> 158. A light-only veil .565 / .235 and
a light shortcut alpha .59 were fitted to these clip values first; both are **superseded by R4.4** (one veil and a
plus-lighter shortcut for both appearances, fitted to stills). Results panel: same material; ours ends shorter (fewer
rows).

Placement (scaling hand-off): the bar's top is 205 pt at 932 tall (this still), 251 at 1107 (Q-panels-17), 288 at
1243 (More Space clip, rim row 376 px): its centre at 26.65 % of the height (`Theme.spotlight.barCentre`), 178 pt at
832 (was 189 from "22.7 %", which fitted only 1107).

### R4.4: the mode list in dark over white and over grey 127 (MAC-ANSWERS-4.md R4.4)

Stills `spotlight-modelist-{white,grey}-dark.png` (PNG, no video bias), ours in the same session over the white and
the grey 127 wallpaper, dark, pointer moved; crops `live/spotlight-r32/dark-{white,grey}-sbs.png` (Mac left).
Column 340 pt into the list, rows as a share of its 214 pt:

| share | Mac white / grey | ours before (.45 / .38) | ours now |
|---|---|---|---|
| 2 % | 121 / 68 | 141 / 78 | 123 / 68 |
| 11 % | 134 / 74 | 143 / 79 | 133 / 73 |
| 50 % | 166 / 91 | 150 / 82 | 165 / 91 |
| 80 % | 189 / 104 | 156 / 86 | 188 / 103 |
| 98 % | 203 / 113 | 159 / 88 | 203 / 112 |

- Our glass under the veil reads 256 over white and 141 over grey (out / (1 - veil) on every row): the Mac's grey /
  white ratio is the same (.555 on every row), so one black veil fits both backdrops: the veil each needs agrees within
  .006 per row. Stops .535 / .4775 / .352 / .205 at 0 / .11 / .5 / 1 (`Theme.spotlight.panel*Veil`). Now within -2..+2
  over white, -1..0 over grey. The same share profile matches the light results still (410 tall: 142 at 19 %, 150 /
  164 / 183 / 198 at 29 / 49 / 73 / 92 %, the veil predicts 140 / 148 / 165 / 183 / 198).
- Light and dark are one material. The light clip values (R3.2 above) are an h264 artefact: the same light bar reads
  91 in spotlight-pill-hover-light.mov where spotlight-light-white-empty.png has 103 (71 / 81, 51 / 59 on other rows).
  Our light list with the new veil against the dark stills: -1..+2.
- What passes through (the "blur amount" question): flat backdrops show the transmission, not a blur radius.
  Mac out = c + t x backdrop with t .41 at the top, .59 mid, .70 at the bottom (c 16-24); ours now gives the same rows
  within 2 on both backdrops. The appear blur radius still has no measurement (no structured backdrop in a clip).
- Shortcut "⌘1".."⌘4": **plus-lighter, panel + 67** on both backdrops (white 139 -> 207, 157 -> 224, 174 -> 241; grey
  76 -> 143, 86 -> 152, 105 -> 171; the R3.2 dark-over-dark 86 on 26 is +60 and Q-panels-22's 143 on 79 is +64). Our
  white alpha .36 gave +40 over white, +64 over grey. Now `shaders/plustext.frag` with lift 67 / 255
  (`Theme.spotlight.shortcutLift`, the Control Center subtitle's shader): +68 / +69 over white, +67 / +68 over grey,
  +68 in light.
- Labels and glyphs: white 255 on both (ours the same). The bar in dark over white / grey: the same rows as light
  (within 1-3; 87-97 % of the height 3-9 dark over white).
- Left as they are (the plugin's glass, not Spotlight's): the gap between bar and list reads 102-104 on the Mac over
  white and 116-120 here (51 / 57-60 over grey), the list's middle-row side edge pixel is 144 on the Mac and 96 here
  over white (68 / 34 over grey), the Mac's list has a dark top edge row over white (95 under 117) and a bright bottom
  rim over white too (+13 / +24; ours has it over grey, +13 / +25, not over white). The gap and the rim are traced in
  "Judge #20" below (the whole gap is 95-104 on the Mac, 104-120 here) and fixed there ("Applied").

### Judge #20: the gap and the list's bottom rim in dark (2026-11-14, causes in the plugin; applied, see "Applied")

`spotlight-modelist-{white,grey}-dark.png` against ours (headless, scale 2, dark, flat white / grey 127 wallpaper, the
pointer moved, still 1.4 s later), a 21 px column mean 340 pt into the list, rows from the bar's bottom rim row (Mac 583,
ours 529 px; both lists 428 px):

| rows (2x) | Mac white | ours white | Mac grey | ours grey |
|---|---|---|---|---|
| gap +1 / +4 / +7 / +10 / +13 / +16 / +19 | 95 96 98 99 101 102 104 | 104 107 109 112 114 117 120 | 47 48 49 49 50 51 52 | 52 53 55 56 57 58 60 |
| list top +21 / +22 / +23 | 95 117 122 | 119 121 121 | 80 80 73 | 83 77 70 |
| list bottom -3 / -2 / -1 / 0 (rim) | 207 209 220 231 | 203 203 204 203 | 118 119 134 150 | 115 117 130 142 |

**The gap is the window shadow of both shapes together.** Spotlight's recipe is AppKit's window shadow (Material.cpp
SPOTLIGHT: dark 0.70, y 18, sigma 20). As one shadow of the union, the blurred masks add (a blur is linear):
1 - 0.7 min(1, m_bar + m_list), m = the 1D blurred edge of each shape shifted 18 down. It gives 95 97 98 100 102 103 104
over white (rms 0.7 against the Mac) and 47 .. 52 over grey (rms 0.5). The plugin draws one shadow per glass group (bar,
list: 10 pt apart, spacing 8) and blends each quad over the last (`GL_ONE, GL_ONE_MINUS_SRC_ALPHA`), so the gap gets
(1 - 0.7 m_bar)(1 - 0.7 m_list): 104 106 109 111 114 117 119 / 52 .. 59, ours to rms 0.5. Mac against ours now: rms 12.6
(white), 6.4 (grey). Change (plugin/, for the plugin's owner):

- `plugin/src/GlassElement.cpp`, the quads loop (`for (size_t q = 0; q < quads.size(); ++q)`): when the group's recipe has
  `shadowBlack` (a window shadow), upload the shapes of the groups drawn before it in this element that cast a shadow (not
  `inner`; box centre / half size in quad px, radius px, materialize) as `priorBox[i]`, `priorInfo[i]`, `priorCount`
  (max MAX_SHAPES); 0 for every other recipe.
- `plugin/shaders/liquidglass.frag`, the drop shadow (`sh = gEdge(scene(qp - shadowOffset).d / ...) * shadowOpacity * mat`):

      float r  = max(shadowRadius, 1e-3);
      float mt = gEdge(scene(qp - shadowOffset).d / r) * mat;
      if (priorCount > 0) {   // one shadow for the window: masks add; the groups drawn before left dst x (1 - o min(1, sp))
          float sp = 0.0, inside = 0.0;
          for (int i = 0; i < MAX_SHAPES; i++) {
              if (i >= priorCount) break;
              sp    += gEdge(sdBoxN(qp - shadowOffset - priorBox[i].xy, priorBox[i].zw, priorInfo[i].x).x / r) * priorInfo[i].y;
              inside = max(inside, sat(0.5 - sdBoxN(qp - priorBox[i].xy, priorBox[i].zw, priorInfo[i].x).x));
          }
          float before = shadowOpacity * min(sp, 1.0), after = shadowOpacity * min(sp + mt, 1.0);
          sh = (1.0 - (1.0 - after) / max(1.0 - before, 1e-4)) * (1.0 - inside);   // black: dst x (1 - sh)
      } else
          sh = mt * shadowOpacity;

  (the `cov < 1.0` gate stays). The composite is then dst x (1 - o min(1, sum of m)) whatever the draw order, and a
  shape's own glass is never darkened by the other's shadow, as the Mac's window shadow is drawn behind the window.
  Expected: gap 95 -> 104 over white, 47 -> 52 over grey.

**The list's bottom rim over white is clamped away before the veil.** The rim is the plugin's key/fill highlight
(liquidglass.frag "key/fill highlight layer": `col + hm (clamp(ycc(col, keyYcc), -0.75, 1) - col)`), on the face before
the shell's black veil (`Theme.spotlight.panel*Veil`, .205 at the bottom). Over white the face is about 1.11 (the glass
reads 256 under the veil, R4.4): the target and the 8 bit write clamp at 1, the highlight adds nothing, and the veil
gives 203 on every row. Over grey the face is .567 and the rim (+19 / +34 before the veil) survives x .795: +13 / +25
(Mac +16 / +32). Change: darken the face inside the plugin before the highlight, after a clamp:
- `plugin/src/Material.cpp` SPOTLIGHT: `.fill = {0, 0, 0, 0.205f}` in `.light` and `.dark`, and a new `SRecipe` flag
  (`clampBeforeFill = true`, spotlight only) sent as a uniform; `liquidglass.frag`: `col = mix(clampBeforeFill > 0.5 ?
  min(col, vec3(1.0)) : col, faceFill.rgb, faceFill.a * mat);` (other recipes unchanged: dark Regular's .02 fill acts
  on faces over 1 too).
- With it the shell's veils become the rest of the old ones on the plugin path, 1 - (1 - v) / 0.795: panel .415 / .343 /
  .185 / 0 at 0 / .11 / .5 / 1; bar .969 / .915 / .691 / .470 / .392 at 0 / .14 / .5 / .87 / 1 (the old stops stay for
  the QML fallback, where the glass is not clamped first).
- Expected from the highlight weights our grey rim gives (hm .77 / 1.37 on rows -1 / 0, default key matrix .1471 /
  1.0588: target - c = .147 - .088 c): rows -1 / 0 over white 218 / 230 (Mac 220 / 231), over grey 136 / 152 (Mac 134 /
  150), interiors unchanged (203 / 115). To re-shoot after the build: the bar's bottom rim (its QML rim lines sit on a
  lighter QML veil then) and both top rims (Mac over white: a dark 95 row under the list's top, ours 119).
- Shell not changed for either: without the plugin side the QML veil change would brighten the list (a QML rim cannot
  fit both: from 204 / 130 it needs +16 / +4 on row -1, which no premultiplied blend gives).

**Applied (2026-11-14, agent-sg).** Both changes as written, plus: a group's own shapes enter the prior sum by their
max (their union), the prior's coverage uses its materialize (`appearBlur`) like the glass did, and a group that takes
Regular's shadow by the shadow marker is left out. Code: `plugin/src/Material.hpp` (`clampBeforeFill`),
`Material.cpp` SPOTLIGHT (fill, flag), `GlassElement.cpp` (`inner` / `windowShadow` lambdas, `prior*` and `clampFace`
uniforms, 0 in `drawPanel`), `liquidglass.frag` (`prior*`, `clampFace`, the shadow block, the fill), `check_model.py`
(`face_ours` takes the clamp when a dump has it), `tests/test_main.cpp`; shell `Theme.qml` `spotlight.pluginVeil`: the
veils above on the plugin path (bar bottom k .0435 at a .3925, the same k x a), the old stops for the QML glass. The bar's
bottom QML rim line then read 160 / 167 over white (Mac 147 / 163) and 119 / 128 over grey (Mac 94 / 113): the plugin's
rim is no longer clamped away under it, so `barRimBottom` on the plugin path is .093 (least squares of those four rows;
.2 on the QML glass). Measured as the table above (headless, scale 2, before = the same tree without the change, built
in scratch; one session per build and shell, the shell restarted for the rim line):

| rows (2x) | Mac white | before | after | Mac grey | before | after |
|---|---|---|---|---|---|---|
| gap +1 / +4 / +7 / +10 / +13 / +16 / +19 | 95 96 98 99 101 102 104 | 104 107 109 112 114 117 120 | **96 97 99 100 102 103 105** | 47 48 49 49 50 51 52 | 52 53 55 56 57 58 60 | **48 49 50 50 51 51 53** |
| gap, rms of the 20 rows against the Mac | | 12.6 | **1.1** | | 6.4 | **0.8** |
| list bottom -3 / -2 / -1 / 0 (rim) | 207 209 220 231 | 203 203 204 203 | **207 209 220 233** | 118 120 134 150 | 115 117 130 142 | **117 120 135 153** |
| list at 2 / 11 / 50 / 80 / 98 % | 121 134 166 189 203 | 123 133 165 188 203 | 122 134 166 189 203 | 68 74 91 104 113 | 68 73 91 103 112 | 68 73 91 103 113 |
| list top +21 / +22 / +23 | 95 117 123 | 119 121 121 | 136 129 124 | 80 81 74 | 83 77 70 | 89 79 71 |
| bar bottom -4 .. 0 (rim -1, 0) | 128 130 133 147 163 | 119 119 120 146 147 | 127 128 129 148 156 | 73 75 77 94 113 | 69 69 71 112 119 | 73 74 75 101 112 |
| bar top rows 0, 1 | 51 31 | 38 40 | 39 41 | 51 31 | 36 37 | 37 38 |
| under the list +1 / +20 / +60 | 109 137 205 | 110 137 205 | 110 137 205 | 54 68 102 | 55 68 102 | 55 68 102 |

- The bar's lower rows (-4..-2) were darkened by the list's shadow (5-8 levels): the shadow no longer lies over the
  other shape's glass, as on the Mac. The bare pill over white (light, `spotlight-light-white-empty.png` 128 130 133 147
  163): 124 125 126 151 152 before, 127 128 129 148 156 after.
- Light (shadow 0.40) over white, the gap against `spotlight-light-white-results.png` (164 -> 169 on the Mac): 167 -> 174
  before, **164 -> 169** after; the light list rows are the dark ones above (one material).
- Worse: the list's top row over white 119 -> **136** (Mac 95), over grey 83 -> 89 (Mac 80): the key highlight at the top
  is no longer clamped away either. The Mac's top row is dark over white and bright over grey (95 / 80 against 121 / 72
  inside), which one QML line cannot give (a black line would need .30 over white, .10 over grey); not traced.
- Every other glass is the same pixel for pixel: one session, the build swapped (`hyprctl plugin unload / load`, a new
  copy each time) with the surface open, light and dark over grey 127 and white: desktop and Dock, Control Center, Apple
  menu, Empty Trash alert, Notification Center, a banner, the volume HUD: 0 differing pixels in all 28 pairs (the NC's
  clock widget aside: its hands move).
- Tests: plugin ctest 2 / 2 (lgtests, apple_model), shell 406, ui 104.

### Judge #21: the list's top row (2026-11-15, applied in the plugin)

The clamp before the fill (above) also let the key lobe of the key/fill highlight brighten the list's top rows over
white, where the Mac's do not brighten. Mac (`spotlight-modelist-{white,grey}-dark.png`): the bottom rim over white is
bright (+24 / +28 on 203, the fill lobe), the top row is not (100 / 119 under 121-123). So the two lobes see a different
face: `liquidglass.frag` now applies the key lobe (n.y < 0) to the face as it is, before the clamp and the fill (over
white it has no room there, as before the shared shadow), and the fill lobe after them as above (clampFace only; every
other recipe is unchanged). Headless, scale 2, dark, flat white / grey 127, a 21 px column through the centre (Mac
x 1440, ours 1280), rows from the list's first row (Mac 604, ours 550; the gap rows above unchanged):

| rows | Mac white | before | after | Mac grey | before | after |
|---|---|---|---|---|---|---|
| list top 1 / 2 / 3 / 4 | 100 119 123 121 | 136 129 124 123 | **119 119 120 120** | 85 83 75 72 | 89 79 71 69 | **83 76 69 69** |
| rows 5-24 | 121 .. 126 | 123 .. 126 | 121 .. 126 (within 1 of before from row 6) | 70 .. 69 | 69 .. 69 | 69 .. 69 |

- Light over white (`spotlight-light-white-results.png`, where the Mac's list edge is soft over two rows: 165 142 then
  123): before 136 129 124, after 119 119 120.
- Unchanged pixel for pixel: the list's bottom rim (207 209 220 233), the gap, the bar except its top corners
  (max 5 there); the list's top corners change by up to 9 (the key lobe on the arcs).
- Left: the Mac's first row over white is a dark line (100 at the centre, 88 at the ends; over grey 85 / 72, the same
  +12 at the centre in both), which no term here draws; its rows 1 and 2 behave like a 1 px backdrop-independent line
  split .7 / .3 between them (row 1 = .31 x the row below + 57 on both backdrops). Not traced.

### Round J21: what draws the first row (2026-11-15, traced in part, nothing changed)

Ours now (headless, scale 2, dark, plugin built in scratch from the tree, mode list, column 21 px wide): over grey
83 76 69 69, over white 119 119 120 120, the same at every x from 1032 to 1440 px. The Mac's rows as `row = a x interior
+ b` (white interior 121, grey 69): row 1 a .31 / b 55 (x 1192 px, 136 pt from the list's left edge) to a .29 / b 65 (the
centre); row 2 a .71 / b 30 to .69 / 35; row 3 a .94 / b 8 to .92 / 11; row 4 on.
- **The first rows peak at the centre on both backdrops, as the bar's bottom rim does.** Row 1 white 92 92 93 94 96 98
  100 at x 1192 .. 1440 (grey 76 77 77 78 81 83 85), row 2 +3.5, row 3 +1.5; the bar's last row (583) white 156-160 at
  x 1040-1192 and 167 at the centre (grey 103-110, 118). Additive (the same on both backdrops) and smooth over 100+ pt of
  straight edge: a highlight whose normal is not the edge's. Ours draws it flat by construction (the SDF normal is
  constant along a straight edge). A candidate is the SDF fragment's mix toward a radial direction
  (`SdfFragmentUniforms.arg.w`, QuartzCore-glass-shaders.c header: 0 for NSGlassEffectView shapes, measured); Spotlight
  is SwiftUI glass, whose value is not dumped. Not decoded.
- **Ruled out: the Siri recipe's dark specular** (NOTES.md SiriModifier: height = pixelLength, so 1 px at 2x, offset 0,
  bias -0.25, amount 0.4, spread 75 deg). It is a tone curve, `c (1 + bias h (3 - 2c))`, which keeps the row's
  dependence on the backdrop (a ~ 1): taking the white row 119 -> 100 takes the grey row 83 -> 62 (Mac 85). Its angle
  is not set by SiriModifier (Regular's is pi/2, the sides).
- **The .7 / .3 split is the outer refraction's ramp.** SiriModifier's distances (-1, 0) mix the outer sample in by
  `saturate(d + 1)`: .75 at row 1 (depth .25 pt), .25 at row 2. With the face (0.1 + 0.9 x) and the veil (.465) the
  Mac's rows need an outer sample of about .75 (row 1) to 1.0 (row 2) on both backdrops; the decoded offset (0.4 D
  outward, D 214: about 79 pt up) lands in the bar's dark top (7 / 8 over white / grey). So not this term as decoded
  either, unless the list's backdrop holds something bright there. Our outer sample reads the flat wallpaper, so the term
  draws nothing on these backdrops.
- Left as before: row 1 white 119 against 100, grey 83 / 85; row 2 grey 76 / 83.
- **R8 (2026-11-15, applied in the plugin):** the candidate above is it. `SdfFragmentUniforms.arg.w` is
  CASDFElementLayer.gradientOvalization, 0.5 on SwiftUI / AppKit glass over 64 pt (MAC-ANSWERS-8.md R8.1); the plugin
  now mixes the key/fill normal toward the shape's centre (GLASS-HIG.md 20). Dark, 5 px columns, middle / 200 pt out:
  row 1 over grey 83 / 78 (Mac 85 / 73), row 2 76 / 73 (Mac 83 / 78); over white 119 / 119 (Mac 100 / 89); the bar's
  bottom rim over grey 112 / 105 at 180 pt (Mac 118 / 103), over white 156 / 151 (Mac 167 / 156; a third of ours there
  is the flat QML line `barRimBottom`). The first row's level over white is still open.

### Round 17 (2026-11-15): the list's top edge decided; rims over the veil; stills; Apps (MAC-ANSWERS-17.md R17.5, R17.3, R17.1)

Captures `live/r17/`. Measured here from the PNGs (2x, 5 px columns) and the 60 fps clips; ours headless, scale 2,
plugin built in scratch, flat white / grey 127 / grey 30 / black wallpapers and a black / white step 124 pt right of
the bar's middle (the Mac's step sits there: its window is at x 336, the step at 720). Live checks:
`scripts/motion-capture/spotlight-edge.py`, `apps-view.py`.

**The stills named `white-dark` are over a dark window** (TextEdit in dark mode, about 30), only `white-light` is over
white. Bar and list are 520 pt wide, the bar 87 tall, the list 10 under it (px rows 60..233 and 254 on; the "515 pt,
2.5 narrower" of R17.5 is not in the pixels).

**The edge model.** First rows under the list's top edge, middle column (row 1 / 2 / 3; interior under them):

| capture | list | backdrop | rows | interior |
|---|---|---|---|---|
| modelist-white-light (and R4.4's dark over white) | mode list, D 214 | white | 100 119 123 | 121 |
| typed-white-light | results, D 410 | white | 165 142 123 | 121 |
| modelist-white-dark / typed-white-dark | 214 / 410 | about 30 | 73 55 37 / 80 57 37 | 30 |
| R4.4 grey | 214 | grey 127 | 85 83 75 | 69 |
| step, black side / white side 154 pt out | 410 | black / white | 68 46 25 / 155 134 117 | 22 / 117 |

One list reads 100 and the other 165 over the same white: the row is not local. It is two things:

- **Transmitted: the outer refraction, as decoded.** SiriModifier's outer layer mixes a second sample in by
  `saturate(d + 1 pt)` (.75 at row 1, .25 at row 2 at 2x), taken 0.4 D outward. For the results list (D 410) that is
  164 pt up, past the bar: the backdrop itself. For the mode list (D 214) it is 86 pt up, 11 pt under the bar's top: **the
  sample sees the bar** (its black top, 8-18 on any backdrop), which is what round J21 ruled out too early ("lands in
  the bar's dark top": it does, and that is the dark row). The bar does not see the list: its rows are the same in
  `idle` and `modelist`. Along x the sample leaves along the **ovalized normal** (gradientOvalization 0.5): over the
  step the first row turns bright 25-30 pt before the rows under it (136 at 114 pt from the middle where row 7 reads 31).
- **Added: a light line over the veil.** With T = that mix (in final levels), every capture fits
  `row = .93 T + L`, L = 53 / 31 / 9 on rows 1 / 2 / 3 at the middle, the same over white, grey, 30 and black
  (rms 2). The same line is the bar's top over its .97 veil (57 / 34 / 13 on a 10 interior) and, weaker, its bottom
  (149 / 167 over white). Along x: 53 falls by 2 / 7 / 11 / 14 at 50 / 100 / 150 / 200 pt from the middle (the bar's top
  57 55 49 43 at 0 / 50 / 100 / 150 pt), about `1 - .75 |n.x|` of the ovalized normal (bar top .96).
- Light has the same rows as dark (one material); only the shadow in the gap differs (164-169 against 95-104).

**Applied.** Plugin (`Material.cpp` SPOTLIGHT `outerSeesPrior`, `priorVeil`, `keyTop`; `GlassElement.cpp` `seenCount`;
`liquidglass.frag` `outerSeen`): on this recipe the outer sample reads along the ovalized normal and, where it lands in
window glass above the group, reads that glass as it shows (its face under the shell's veil, .975 / .754 / .517 top /
middle / bottom); the key (top) lobe is no longer drawn on the face (it was clamped away over white and sat under the
veil). Shell: `shaders/spotrim.frag` draws the line over the veil on the bar (top, bottom) and the panel (top)
(`Theme.spotlight.barRimTop / barRimBottom / panelRimTop`, `*Fall`), replacing the flat 1 pt lines (.13 / .093).

| rows, middle (and far out) | Mac | before | after |
|---|---|---|---|
| mode list over white: row 1 / 2 / 3 | 100 119 123 | 119 119 119 | **100 121 126** |
| same, row 1 at 100 / 200 pt | 94 / 90 | 119 / 119 | **93 / 88** |
| results over white: row 1 / 2 / 3; row 1 at 200 pt | 165 142 123; 152 | 119 119 119; 119 | **164 142 125; 153** |
| mode list over grey 127: row 1 / 2; row 1 at 200 pt | 85 83; 73 | 83 76; 78 | **84 82; 71** |
| mode list / results over 30: row 1 / 2 | 73 55 / 80 57 | (not shot) | 71 53 / 78 56 |
| results over black: row 1 / 2 / 3 | 68 46 25 | 37 26 17 | **67 44 22** |
| step: row 1 at 0 / 94 / 114 / 124 / 154 pt | 68 92 136 142 155 | no lead: the row steps where the rows under it do (shot with the step at the middle: 36 left, 84 on it, 119 right) | **67 90 135 143 154** |
| bar bottom over white: rows -1 / 0; row 0 at 150 pt | 149 167; 158 | 148 156; 152 | **149 167; 159** |
| bar bottom over grey 127: row 0 middle / 150 pt | 118 / 105 | 112 / 107 | 118 / 109 |
| bar top: rows 1 / 2 / 3; row 1 at 150 pt | 57 34 13; 43 | 39 40 8; 39 | **56 35 15; 44** |

Light over white after: results 164 142 125, mode list 100 121 126, bar bottom 149 167. Left: the interior near the
step (rows 3 on) is 8-20 lighter than the Mac's on the black side within 10 pt of the step (the face blur, not the
edge); row 3 over white +2..+3.

**Stills (R17.3), ink boxes in pt of the 1160 px crops, Mac against ours before / after:**

| item | Mac | before | after |
|---|---|---|---|
| mic | outline, 14.5 x 21, right edge 39 from the bar's, y 31.5 .. 52.5 of the bar | `mic.fill` 13 x 19.5, 43, 33 .. 52.5 | `microphone` 14.5 x 21, 39, 31.5 .. 52.5 |
| mode list shortcut | SF 17: ⌘ 12.5 x 13 from x 459 of the list, digit 12.5 tall in a monospaced slot | SF 14 with U+2005: ⌘ 11 x 10.5 from 460.5-463 | SF 17, ⌘ 12.5 x 13 from 459, the digit in an 11.5 pt slot |
| Applications glyph | 22.5 x 20 | 20 x 18 | 22.5 x 20.5 |
| mode glyphs' middle | 1.25 pt under the row's | on it | 1 pt under |
| query text | ink from 38.5, y 34.5 .. 51.5 | 39.5, 36 .. 52.5 | 38.5, 33.5 .. 52 |
| inline completion | "calc" + "ulator — Open", grey 178 on the completion pill, no caret | none | the same (`SL.completion`), for an app whose name begins with the query |
| top hit's icon in the bar | 32 x 33 | 29 x 29 | 33 x 33 |
| result title | ink from 79.5, 1 pt above the row's middle | 80.5, on it | 79.5, 1 pt above |

Not changed: the Mac's icons are its Dark icon style; the "Search Calculator" + `tab` hint on the top hit (Tab does
not search inside an app here: no text for a function we do not have); the results list's scroll bar; the caret's
colour halo; Actions and Clipboard glyphs (layered squares, two outline documents: no SVG of either in
themes/icons/sf-symbols; needs a Mac dump of `square.2.layers.3d` and `document.on.document`); Files is a 844 x 520
grid with filter chips on the Mac and a 520 x 490 list here (not rebuilt this round).

**The 54 pt rise of the bar in a mode is the Mac session's own.** Its bar had been dragged to (336, 349) on the 1440 x
932 screen (not centred: x 460 would be); the mode panels would end under the screen there (349 + 617 = 966), so the
window is kept on screen at y 295 (Actions too). At the default place the bar does not move: Q-panels-25 has the Apps
window at (433, 251) on 1728 x 1107, the idle bar's own top. Ours stays (178 + 617 = 795 of 832).

**Apps (R17.1) is the Applications mode here already** (AppsPanel.qml, lib/appsgrid.js, Q-dock-23..26). Re-measured on
`apps-rest-*.png` (icon outlines, chip and separator steps, label ink):

| | Mac r17 pixels | R17.1's estimate | ours |
|---|---|---|---|
| icon | 61 x 61 with its outline | 64 | 60 (art) |
| column middles | 77.5, 307, 537 of the window (pitch 114.9) | 76 .. 761, pitch 114 | 77 + 115 n |
| rows | suggested middle 198.2, second grid row 416.5 (pitch 102 from 187) | pitch 100 | 70 + 30, 187 + 102 n + 30 |
| chips | y 117 .. 143, first x 20 .. 91, gap 8, fill +10 | y about 128 | 117 .. 143, 20 .. 91, 8, +10 |
| separator | y 265, from x 20, +35 | about 263 | 265, 20, +35 |
| labels | "Calculator" 60.5 pt wide, ink bottoms 250 / 365 / 468 | about 11 pt | 60.5 (SF 13), 249.5 / 365 / 468 |

So the grid was already the Mac's to the point; nothing moved. Changed:
- **Cmd-1 from the bar**: the bar takes the mode in one frame and the panel grows out of the list's anchor
  (`apps-open-close-light.mov`: fill .28 .47 .62 .75 .84 .89 .92 .98 of its settled level per frame, 2.917 .. 3.133 s;
  width overshoot 1.5 % 0.15 s after the first frame; first frame about .62 wide and a fifth tall). Ours was one frame;
  now x .45 -> 1, y .03 -> 1 on the list's spring at response 0.2, fade a critically damped 0.21 s two frames in
  (`Theme.spotlight.apps*`). Over a flat white wallpaper (mcap, a strip across the panel): change against the first
  frame .40 .51 .70 .76 .81 .89 .96 .98 1.0 per frame (Mac .28 .47 .62 .75 .84 .89 .92 .98), width 531 626 710 772 828
  853 867 870 864 862 -> 850 pt at half level (first frame .62, overshoot 2.3 %; Mac about .62 and 1.5 %); over Tahoe
  the last frame more than 4 % off is 216 ms after the first (Mac 215 ms by R17.1's reading).
- **Escape**: the grid goes in one frame (5.083 s), then the empty panel shrinks into the anchor (.85 .75 .63 .51 .40
  wide per frame, gone on the sixth). Ours was one frame; now the results panel's collapse with a 0.11 s fade: gone
  100 ms after the first frame.
- **Typed**: `apps-typed-cal-*`: "cal" + " — Open" on the completion pill (the action alone in this mode): added.
- The Mac's latencies (bar 312 ms and panel 396 ms after Cmd-1, 177 ms after Escape) are its own load: not copied.

What the Mac could not capture (R17.1 "limits") and what its clips do not hold:
- the panel's AX tree (sizes from pixels); opening from a Dock tile (no Apps tile; a synthetic click and `open -a Apps`
  did nothing): ours keeps the one-frame open of MAC-ANSWERS R2 there; trackpad scrolling by hand;
- `apps-hover-press-*.mov` show the wallpaper and the pointer only (14 frames, no panel in the 120 x 110 pt region): hover
  and press are **not captured**; ours keeps "hover changes nothing";
- `apps-scroll-*.mov` show the grid filtered by "c" (20 apps, three rows): nothing scrolls in them: scroll is **not
  captured**;
- the dark open / close clip stops after 92 frames; the grid area is blurred in the clips, so the grow's start scale
  is read off the outline (+-10 pt) and the per-frame width is not fitted.

### Judge #25 (2026-11-15): Files grid, tab hint, scroll knobs, mode glyphs, caret halo, Apps grow

Mac data: `live/r17/` only (the Mac is gone). Live checks: `scripts/motion-capture/spotlight-modes.py` (new, reads every
Mac number from the still and ours from the screen with the same code) and `apps-view.py` (`--mac` prints the Mac's
series from the clip). Ours headless at scale 2 over flat (30,31,30) (the r17 "white-dark" backdrop) and grey 127.

**Files (Cmd-2) is the 844 x 520 grid** (`shell/modules/spotlight/FilesPanel.qml`, `lib/spotlight.js` `filesGrid`), pt
of the panel, from `spotlight-mode-files-{white-dark,white-light,wallpaper-dark}.png` (tiles blurred, +-2):

| | Mac | before | after |
|---|---|---|---|
| panel | 844 x 520 | 520 x 490 list | 844 x 520 |
| chips | 5, one width: 20 .. 174.5, gap 8, y 20 .. 46, capsule, fill +12 | none | 5, 20 .. 174.5 x 20 .. 46, +13 |
| chip text | SF 15 regular, ink 27 .. 39, plus-lighter +125 (163 on 39, 255 on 143) | | the same (`plustext.frag`) |
| columns | tile middles 75 191 306 422 537 652 767 (77 + 115 n, as Apps) | | 78 191 307 422 538 653 766 |
| rows | first row middle 100, then 270 and 395 (pitch 125), 520 cut by the panel | rows of 62 | 101 270 397 |
| header | "Recents" at x 20, middle y 211 | at y 30 with a separator | x 20, y 211, no separator |
| scroll knob | grey 124 on every backdrop, to x 841, from y 102.5, 98 long | none | 835 .. 841 from 103 |

The grid scrolls under the chips (the knob starts 40.5 under y 62, as the results knob starts 40.5 under its panel's
top). Chips here are the kinds of the recent files (PDF, Text, Images ...); `FileSearch.recents` holds up to 60 (was 20).

**Typed results** (`spotlight-typed-*.png`): the top hit carries "Search Calculator" (SF 11, plus-lighter +65, ink ending
at 458.5) and a `tab` key cap (467.5 .. 493 x 34 .. 52, r 5.5, plus-lighter +35, "tab" SF 11 +125); the scroll knob is
grey 124, x 511 .. 517, from 40.5, 136 long. Ours before: neither. After: cap 467.5 .. 493.0 x 34 .. 52, +33; text ends
458.5, +65; knob 511 .. 517 from 41 (`ResultRow.hint`, `SL.scrollKnob`).

**Mode glyphs, decoded.** Clipboard is `document.on.document` (string in SpotlightUIShared, 0x22f1ba010). Actions is
the private `app.2.stack.3d`: SpotlightUIServices names `app.2.stack.3d.fill` (0x21325b7ac); the still shows the
outline, and the public `square.2.layers.3d` has pointed corners where the still has round ones. Both decoded from the
27.2.1 image's CoreGlyphs / CoreGlyphsPrivate `Assets.car` with `themes/icons/tools/add-sf.py` (no Mac dump needed).
Ink: Actions 19.5 x 22.0 pt, .32 of its box (Mac 20.0 x 22.5, .30; was a bolt); Clipboard 19.0 x 24.0, .39 (Mac
19.5 x 24.0, .36; was a filled board).

**Caret halo** (`shaders/caretglow.frag`): the same levels are added over the dark and the light bar, so plus-lighter:
the 2 x 26 caret blurred by sigma 3 pt, 1.93 x white, bluish at the top, warm at the bottom. Beside the caret at 1.5 /
3 / 4.5 pt: Mac +96 +57 +33, ours +92 +57 +28 (was 0).

**Apps grow and collapse, re-read with one measure for both sides** (`apps-view.py` `series`: level of the fill in a
band 50 .. 64 pt under the panel's top, width at half of it, bottom edge at half level). The ".28 .47 .62 .75, 215 ms"
of round 17 and judge #25's ".38 .62 .79 .93" were two different measures; like for like:

| per frame | Mac (from 2.917 s) | before | after |
|---|---|---|---|
| level | .46 .62 .74 .76 .83 .88 .92 .97 1 | .24 .49 .61 .72 .81 .87 .92 .95 .97 | .46 .62 .71 .79 .86 .91 .94 .96 .98 (rms .024) |
| width | .45 .62 .76 .78 .84 .88 .93 1 | .52 .62 .73 .82 .90 .95 .99 | .46 .58 .69 .78 .85 .90 .94 (rms .034) |
| bottom, first frame | .48 of the height | 108 of 520 pt (from y .03 about a point 20 down) | .52 |
| level within 4 % | 117 ms | 150-167 ms (judge) | 116-133 ms |
| Escape: level | .95 .89 .79 .70 .60 .44 .38 .24 .13 .07 | .66 .28 .09 | .92 .83 .73 .63 .52 .40 .25 .15 .08 (rms .068) |
| Escape: width | .90 .80 .67 .54 .43 .31 | .96 .83 .70 .57 .46 .38 | .89 .77 .63 .51 .41 .33 (rms .029) |

The Mac's panel has its top edge in place from the first frame: it grows about its top middle, a third tall at first.
Now: x .25 -> 1, y .30 -> 1 about the top edge on Spring(0.26, ratio .78) 40 ms in, fade as before but 50 ms in
(`Theme.spotlight.apps*`). Escape (Mac from 5.217 s: level .95 .89 .79 .70 .60 .44 .38 .24 .13 .07 .02, width .90 .80
.67 .54 .43 .31, about the top edge): critically damped 0.23 s to x .1, y .05, fade 215 ms (was 110 ms about the anchor:
level .66 .28 .09). The Mac's frame at 2.967 s barely moves (.74 -> .76): a stutter of that run, not copied. The check
compares at each frame's own time and retakes a capture with a repeated or late frame (the judge's 2 of 4 failures).

### Still open

- The decoded open contentBlurRadius / the hint timer's indicators: what draws them is not traced.
- The list's appear blur radius (estimated), and the dark appearance's list timing (no contrast in the dark clip).
- Done after judge #25: Actions / Clipboard glyphs, caret halo, "Search <App>" + tab, the results knob, Files as the 844
  grid. Needs a Mac (not available): OPEN-FIXES.md items 47-49.
