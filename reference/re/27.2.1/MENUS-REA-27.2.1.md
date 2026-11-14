# Menus against macOS 27.2.1 (26B131), reverse engineered

Every menu hyprk draws, row by row against the Mac. Sources:

- **R** resource (observed): a loctable / .strings / nib / plist read from the 27.2.1 system volume
  (`141-12228-174.dmg` mounted read-only with apfs-fuse; nibs decoded with `rea decode-interface-builder`, REA 6.8.0).
- **C** code (decoded): Ghidra 12.1.4 headless on the arm64e slice (`llvm-lipo -thin arm64e`). REA's own Ghidra route timed
  out importing Finder (330 s startup deadline), so the decompiles were run with Ghidra's `analyzeHeadless` and small
  scripts (DecompNames / DecompRefs / DecompCallers / DecompAt / PtrTable). Work files: `~/Downloads/macos/re-work/menus/`
  (`dec1.c`, `dec2.c`, `dec-ss*.c`, `arrange-ib.json`, `strings/`).
- **A** AX dump with the menus open on the Mac (`live/menubar/finder-menus-ax.txt`, `live/dock/dock-menus.json`).
- **S** screenshot (`screens/27.2.1/menubar/*.png`, `live/finder/crops/context-menu-*-light.png`).
- **GUESS** none of the above.

The Mac account used for A and S is en_GB ("Bin", "Customise", "Minimise", "Centre"). Labels here use the en (US) resources,
as the resources give them: "Trash", "Customize", "Minimize", "Center", "Full Screen Tile" (AppKit MenuCommands.loctable has
no hyphen; the en_GB AX shows "Full-Screen Tile").

"Ours before" is the state before this pass. Action column: = kept, + added, − removed, ~ changed.

## Apple menu

Built by AppKit (not the app): **R** `AppKit.framework/Resources/Menus.loctable` (en) keys "About This Mac",
"System Settings...", "App Store", "Recent Items", "Force Quit...", "Sleep", "Restart...", "Shut Down...", "Lock Screen",
"Log Out %@..."; order, keys and icons **A** + **S** (Q-menubar-31, -17).

| Mac item | ours before | action |
|---|---|---|
| About This Mac [laptop icon] (⌥: System Information) | "About This Computer" | ~ label. Icon: laptopcomputer, drawn since 2026-11-14 (ICONS-REA-27.2.1.md part 1). Option alternate not built |
| — | = | = |
| System Settings… [gear] | = | = |
| App Store [appstore] | = (disabled) | = |
| — / Recent Items ▸ / — | = (Recent Items disabled, no items) | = |
| Force Quit… ⌥⌘⎋ | = | = |
| — / Sleep / Restart… / Shut Down… / — | = | = |
| Lock Screen ⌃⌘Q / Log Out <name>… ⇧⌘Q | = | = |

## App-name menu

| Menu | Mac rows | source | ours before → action |
|---|---|---|---|
| Finder | About Finder, —, Settings… ⌘,, —, Empty Trash… ⇧⌘⌫, —, Services ▸, —, Hide Finder ⌘H, Hide Others ⌥⌘H, Show All | **A** | rows equal. ~ Settings… now disabled: it sent Ctrl+, which opened the invented toolbar menu (below); hyprk Finder has no settings window |
| other apps | About X, —, Settings… ⌘,, —, Services ▸, —, Hide X ⌘H, Hide Others ⌥⌘H, Show All, —, Quit X ⌘Q | app template, as Finder's **A** plus Quit | + Services ▸ (was missing) |
| System Settings | About System Settings, —, Services ▸, —, Hide…, Hide Others, Show All, —, Quit System Settings | **C** `FUN_10002bca8` (SettingsAppCommands body): `CommandGroup(replacing: .appSettings)` whose only row is an Apple-internal ⌘/ item | − Settings… |

## Finder menu bar (File, Edit, View, Go, Window, Help)

Source **A** `finder-menus-ax.txt` (desktop, no window) + **S** `pulldown-{light,dark}.png` (File). Rows, order, separators and
keys were already equal to the dump except:

| Menu | Mac | ours before | action |
|---|---|---|---|
| View > Sort By ▸ | **R** `Finder.app/Contents/Resources/Base.lproj/ArrangeByMenu.nib` outlet `sortByMenu`: None ⌃⌥⌘0, —, Snap to Grid, —, Name ⌃⌥⌘1, Kind ⌃⌥⌘2, [Shared By, Last Modified By: shared items], Date Last Opened ⌃⌥⌘3, Date Added ⌃⌥⌘4, Date Modified ⌃⌥⌘5, Date Created, Size ⌃⌥⌘6, Tags ⌃⌥⌘7 | empty, disabled | + 12 rows (disabled: the desktop has no icon layout here) |
| View > Clean Up By ▸ | **C** `-[TContextMenu addViewSpecificStuffToMenu:clickedView:contextMenuDelegate:context:]` 0x10042098c, table 0x100b267a8 = N220 Name, N224 Kind, N221 Date Modified, N222 Date Created, N223 Size, N225 Tags | empty | + 6 rows (disabled) |
| Window | AppKit rows **R** `MenuCommands.loctable`; order **A** | "Full-Screen Tile" | ~ "Full Screen Tile" |
| Window tail | open-window list ("◆ Applications"), see "Window menu window list" below | none | + built |
| Help | search field (40 pt), Mac User Guide, Tips for Your Mac | "Search" as a plain disabled row | = (stand-in for the field) |
| Edit icons | settled, see "Edit menu icons" below: AutoFill [rectangle.and.pencil.and.ellipsis], Start Dictation [microphone], Emoji & Symbols [emoji.face.grinning] | icon on Search only | = all three (AutoFill and Start Dictation glyphs decoded from CoreGlyphs 2026-11-14, ICONS-REA-27.2.1.md part 1) |

## Other apps' menu bar (AppKit's rows only)

| Menu | Mac | ours before | action |
|---|---|---|---|
| Edit | Undo, Redo, —, Cut, Copy, Paste, Select All, —, AutoFill ▸, Start Dictation, Emoji & Symbols (AppKit appends the last three, **A** Finder Edit tail) | = | = |
| View | AppKit inserts Show Tab Bar ⇧⌘T, Show All Tabs ⇧⌘\\, Enter Full Screen fn F (**R** MenuCommands.loctable; keys **A** Finder View) | + "Show Sidebar ⌃⌘S" and no keys | − Show Sidebar, ~ keys added |
| Window | the Finder's AppKit rows (**A**) minus Show Progress Window | Minimize, Zoom, Fill, Center, —, Move & Resize, —, Bring All to Front | + Full Screen Tile, Cycle Through Windows ⌘`, Remove Window from Set, the four tab rows; ~ order |
| Help | search field + "<App> Help ⌘?" (template) | Search, —, "Help ⌘?" | − separator, ~ "<App> Help" |
| File, per-app menus (Firefox History/Bookmarks/Tools, TextEdit Format, Terminal Shell) | the app's own (not macOS) | partial guesses | = kept, **GUESS** (not from 27.2.1) |

## System Settings' menu bar

**C** System Settings.app (`SettingsApp/SettingsAppCommands.swift`, `SettingsApp/HelpMenu.swift`), `FUN_10002bca8`:

| Menu | Mac | ours before | action |
|---|---|---|---|
| View | `CommandGroup(before: .toolbar)` FUN_10002cf84: Back ⌘[ (label 0x10002df80 "Back"), Forward ⌘] (0x10002e170 "Forward"), Divider, Search ⌘F with `Image(systemName: "magnifyingglass")` (0x10002e46c, 0x10002e650), Divider; `CommandGroup(after: .toolbar)` FUN_10002e704: the pane list | the generic View (Show Tab Bar, Show All Tabs, Show Sidebar, Enter Full Screen) | ~ replaced: Back, Forward, —, Search [magnifyingglass]. Pane list not built. Settings got Ctrl+[ / Ctrl+] / Ctrl+F (SettingsApp.qml) so the rows act |
| Help | search field, then `CommandGroup(after: .help)` HelpMenu FUN_100066b04: Mac User Guide [book.pages] (0x100067964), Divider, User Manual (0x100067a38), macOS Support (0x100067e38), "<model> Specifications" (0x100067f60), Hardware Support (0x100068504) | Search, —, Help ⌘? | ~ replaced; rows open Apple web pages: disabled; book.pages drawn (decoded 2026-11-14, ICONS-REA part 1); "<model>" drawn as "Mac" |
| Edit, Window | SwiftUI/AppKit defaults: the app imports only the `appSettings`, `appShortcuts`, `toolbar` and `help` CommandGroupPlacements (**C** symbol imports in dec-ss3.c), so it adds nothing to Edit or Window; SwiftUI's own default rows were not decoded (SwiftUI framework) | generic | = generic AppKit rows (+ the window list) |

## Desktop context menu

**S** `screens/27.2.1/menubar/context-{light,dark}.png` (Use Stacks on), rows **R** Finder LocalizableMerged.strings N156,
N165, N164, N164.5, N148.1, N149.1, N169.3, N169.3.2, N35; submenus as the View menu above, without keys
(`TArrangeByMenuController removeCommandKeyEquivalents`).

| Mac item | ours before | action |
|---|---|---|
| [Ask Siri header] | none | not built (no Siri) |
| New Folder / [Paste Item] / — | = (no Paste Item: no file clipboard in the shell) | = |
| Get Info, Change Wallpaper…, Edit Widgets… (no separator between Get Info and Change Wallpaper) | separator after Get Info | − separator |
| — / Use Stacks ✓ / Sort By ▸ (stacks off) or Group Stacks By ▸ / Clean Up / Clean Up By ▸ / Show View Options | Sort By and Clean Up By empty | + 12 + 6 submenu rows (disabled) |

## Finder window menus

| Menu | Mac | source | ours before | action |
|---|---|---|---|---|
| File item / folder / several items | Open (or Open in New Tab, Paste Item for a folder; New Folder with Selection (n Items) first for several), Open With ▸, —, Move to Trash [trash], —, Get Info, Rename(…), Compress “x”, Duplicate, Make Alias, Quick Look, Copy, —, Share… [share], —, [Customize Folder… [tag], —], Quick Actions ▸ [gear], —, Services ▸ | **S** crops/context-menu-{file,folder,multi}-light.png, **R** N151–N168 | = | = (no Ask Siri header, no tag-dot row) |
| Window background | New Folder, [Paste Item], —, Get Info, —, View ▸, Use Groups, Sort By ▸, Clean Up, Clean Up By ▸, Show View Options | **S** context-menu-background-light.png; order **C** `addArrangeByAndSortByToMenu:` 0x100420e8c | Sort By ▸ = "Sort by Name/Kind/Date Modified/Size", —, "Keep Folders on Top"; Clean Up By empty | ~ Sort By = the nib's rows (unsupported orders disabled), − Keep Folders on Top, + Clean Up By rows |
| Toolbar Action (•••) | the context menu of the selection, or of the window: `-[TContextMenu populateActionMenu:contextMenuDelegate:]` 0x1004208c8 calls `+buildContextMenu:forContext:4 ... maxItems:10 addServices:1`; Toolbar.nib's "Action" NSMenu is empty | **C** + **R** | New Folder ⇧⌃N, Rename, Move to Trash, —, Show/Hide Path Bar ⌥⌃P, Show/Hide Hidden Files ⇧⌃. | ~ replaced by the context menu |
| Toolbar group button | Group By: ArrangeByMenu.nib outlet `arrangeByMenu` (**R**): None, —, [Volume], Name, Kind, Application, [Application Category, Shared By, Last Modified By], Date Last Opened, Date Added, Date Modified, Date Created, Size, Tags; picked by `-[FIArrangeByPopUp mouseDown:]` 0x1005c0634 / `-[TArrangementToolbarItem menuNeedsUpdate:]` 0x1005fe6b8 unless ⌥ is held or cmdArrange: is invalid (then sortByMenu); keys stripped by `initWithItemIdentifier:...` calling removeCommandKeyEquivalents (**C**) | Sort By rows | ~ Group By rows (None ✓, others disabled: no grouping here); ⌥ alternate not built |
| Toolbar view popup (narrow window) | as Icons / List / Columns / Gallery | **A** View menu rows | = | = |
| Sidebar item | see "Finder sidebar context menu" below | **C** | none | + built |

PopupMenu look (Finder's own menus): separator inset 15 → 16 pt from each edge (Q-menubar-20); submenu chevron centre
W−17.5 → W−23.25 (Q-menubar-23). Width: our menus have a 200 pt minimum, the Mac has none (Q-menubar-19): not changed
(the context menus measured on the Mac are wider than 200 anyway; the background menu is 200 on both).

## Dock menus

**R** `Dock.app/Contents/Resources/DockMenus.plist` (27.2.1) with titles from `en.lproj/DockMenus.strings`; **A**
`live/dock/dock-menus.json`.

| Menu (plist key) | Mac | ours before | action |
|---|---|---|---|
| app (`process`): running | [windows], —, Options ▸ (Keep in Dock / Remove from Dock, Open at Login, Show in Finder), —, Show All Windows, Hide / Show, Quit (⌥ Force Quit) | = | = |
| app not running | Options ▸, —, Open | = | = |
| Finder (`finder-running`) | [windows], —, New Finder Window, New Smart Folder, Find…, —, Go to Folder…, Connect to Server…, —, Show All Windows, Hide/Show (no Options rows, no Quit) | = | = |
| Trash (`trash`) | Open, —, Empty Trash | = | = |
| Downloads (`directory`) | Sort by, Name, Date Added, Date Modified, Date Created, Kind, —, Display as, Folder, Stack, —, View content as, Fan, Grid, List, Automatic, —, Options ▸ (Remove from Dock, Show in Finder), —, Open “Downloads” | = | = |
| Downloads as List (`directorylist`) | [files], —, Options ▸ (the Sort by / Display as / View content as rows), Open in Finder | Options ▸ held the whole Downloads menu (with its own Options ▸ and Open “Downloads”) | ~ Options ▸ = the three sections only |
| Dock separator (`dock`) | Turn Hiding On/Off, Turn Magnification On/Off, Position on Screen ▸ (Left, Bottom, Right), Minimize Using ▸ (Genie Effect, Scale Effect), —, Dock Settings… | none (separator not clickable) | + whole menu: hiding and magnification write dock.json, Bottom checked (Left/Right disabled), Minimize Using shows the setting, disabled; Dock Settings… opens Desktop & Dock |

## Menus with no menu here

- Status items: see "Menu bar status items" below.
- Text fields: see "Text field context menu" below.

## Removed rows whose function has no other menu path

- Finder toolbar menu "Show Hidden Files / Hide Hidden Files": still ⇧⌘. (Ctrl+Shift+.), no menu row (the Mac has none either).
- Finder toolbar menu "Show / Hide Path Bar": still View > Show Path Bar ⌥⌘P.
- Finder "Keep Folders on Top" (Sort menu): now unreachable (on the Mac it lives in Finder Settings > Advanced, which hyprk
  does not have).
- Finder Settings… ⌘, used to open that toolbar menu: now disabled.
- Finder toolbar group button: it showed Sort By; it now shows Group By. Sorting stays on the window background menu's Sort By ▸.

## Pass 2 (2026-11-14): method

Same volume, mounted read-only again (`apfs-fuse -o ro sys.dmg mnt`, unmounted after). New tools in
`~/Downloads/macos/re-work/menus/n/`: `nib.py` (a NIBArchive reader that prints NSMenu trees with titles, loc keys, key
equivalents and actions; REA's decode-interface-builder graph does not keep NSMenuItems array order), Ghidra headless on
the existing Finder / SS projects (script `Dec.java`: decompile at / refs to / by name), AppKit from the dyld cache:
`ipsw dyld disass` per symbol (`appkit-syms.txt` from `ipsw dyld symaddr --image AppKit`) with objc stub selectors
resolved by reading each stub's adrp/add from the cache files (`dsc.py`), plus Ghidra on `ex/AppKit.fixed` imported with
`-noanalysis` (project `n/gp`). CFString constants decoded as (ptr & 0x3ffffffff) + 0x180000000.

## Finder sidebar context menu

**C** `-[TContextMenu configureForSidebar:contextMenuDelegate:clickedView:constrained:data:]` 0x1004204cc calls
`+buildContextMenu:forContext:8` (16 when constrained) `maxItems:10 addServices:0`. buildContextMenu (0x1004216b0) walks
the 84-entry command table built by FUN_10081f3f0 at 0x100c15450 (entry 0x30 bytes: context mask, selector, title
TString, alternate modifier mask, image id, image-visible flag) and adds every entry whose mask has the context bit;
selector-less entries are separators and `_setCondensesSeparators:YES` drops leading/trailing/double ones. Invalid rows are
hidden (TContextMenuItem `showMeAnyway` exists for the exceptions). Context 8 rows, in order (titles **R** Finder
LocalizableMerged): Open (in a browser window "Open in New Tab" N151.1, ⌥ alternate "Open in New Window" N151.3 via
TUserDefaults reg 0x10), Open With, Screen Share, Show in Enclosing Folder N162, Show "x" N169.4 (file providers),
Download Now, Remove Download, —, Eject "x" N57 (⌃ Eject Only, ⌥ Eject All), —, Format, —, Encrypt "x"…,
Remove from Sidebar N169.2, Delete Tag "x" (TG16_V2), Delete backups ×2, Erase Disc, —, Get Info N165 (⌥ Show
Inspector, ⌃ Get Summary Info), Manage Storage… N167, Back Up Now, Change Wallpaper…, Edit Widgets…, Rename "x"
(cmdRenameInSidebar; `-[TSidebarViewController validateRenameInSidebar:]` 0x100583d60 titles it N169.6 "Rename “^0”" or
N169.7 "Rename"), Add to Dock N169.13, search slices, —, Share N166 (placeholderShareMenu → cmdShare, no ellipsis),
Manage Shared…, —, tags (cmdSetLabel), —, plug-ins, —. None of these has the image-visible flag: no icons.
A tag row: the same context 8 (the All Tags column uses context 0x40: Delete Tag, Rename, tags).

Built (finder/qml/lib/files.js `sidebarMenu`, Sidebar.qml right-click TapHandler, Main.qml `sidebarMenu`):

| kind | rows | acts |
|---|---|---|
| Favorites folder | Open in New Tab, Show in Enclosing Folder, —, Remove from Sidebar, —, Get Info, Add to Dock, —, Share | Open in New Tab, Show in Enclosing Folder, Get Info (Applications is virtual here: only Open in New Tab) |
| volume | Open in New Tab, —, Eject "x", —, Get Info, Rename "x" | Open in New Tab, Get Info |
| tag | Open in New Tab, —, Remove from Sidebar, Delete Tag "x", —, Rename "x" | Open in New Tab |
| Recents, Shared, iCloud Drive, AirDrop | Open in New Tab, —, Remove from Sidebar | Open in New Tab (when the row has a place) |
| Trash | Open in New Tab | yes |

**GUESS**: which rows Finder's validation keeps per kind (not decoded per command): no Rename for the system Favorites,
no Show in Enclosing Folder / Add to Dock / Share for volumes, the virtual rows' and Trash's lists. Not built: the ⌥ / ⌃
alternates, the tag colour row (left out as in the item menu).

## Toolbar group button

See the Finder window table above: Group By (arrangeByMenu), keys removed. Desktop menu separators: **C** context 2 rows of
the same table: New Folder (at mouse), [paste rows], —, [trash / eject / format / encrypt rows: invalid on the desktop],
—, Get Info, Change Wallpaper…, Edit Widgets…, —, [share rows], —, —, cmdViewAsSubmenu, placeholderViewSpecificStuff
(Use Stacks / Sort By / Clean Up / Clean Up By), Show View Options, Show Preview Options, —, Import from iPhone, —. After
condensing: New Folder | Get Info, Change Wallpaper…, Edit Widgets… | view rows, Show View Options = what menus.js
`desktop()` draws (no longer GUESS).

## Text field context menu

**R** `AppKit.framework/Resources/Base.lproj/NSTextViewContextMenu.nib` (`+[NSTextView defaultMenu]` 0x18a710e68 loads it):
Cut, Copy, Paste, Paste and Match Style (pasteAsPlainText:), Paste and Retain Style (pasteAsRichText:), —, Quick Look
Attachments, Font ▸ (Show Fonts, —, Bold, Italic, Underline, Outline, —, Highlight, Styles…, Format…, —, Show Colors),
—, Spelling and Grammar ▸ (Show Spelling and Grammar, Check Document Now, —, Check Spelling While Typing, Check Grammar
with Spelling, Correct Spelling Automatically), Substitutions ▸ (Replace Quotes, Replace Dashes, Add Links, Replace Text, —,
Show Substitutions, —, Smart Copy/Paste, Smart Quotes, Smart Dashes, Smart Links, Data Detectors, Text Replacement),
Transformations ▸ (Make Upper Case, Make Lower Case, Capitalize, Convert to Full / Half Width, Convert to Traditional /
Simplified Chinese), Speech ▸ (Start / Stop Speaking), Writing Direction ▸, Layout Orientation ▸ (Horizontal, Vertical).
No Select All. **C** `-[NSTextView menuForEvent:]` 0x18a70ee44 (asm with resolved selectors, `n/mfe-all.s`):
- a right click outside the selection selects the word under it (selectionRangeForProposedRange:granularity:, setSelectedRange:);
- Reveal rows first (`_menuItemsForRevealItem:...`: Look Up "x" = MenuCommands.loctable "Look Up \U201C%@\U201D"; Translate:
  title not in AppKit, **GUESS** "Translate “x”");
- with a selection and no marked text: "Search With %WebSearchProvider@" (CFString 0x1e28c3160, action
  _searchWithGoogleFromMenu:) and a separator;
- the nib rows copied; Share (`_configureSharingServicesMenuItemInRange:`) inserted after the Cut/Copy/Paste group between
  separators; Writing Tools rows only when `_supportsWritingTools`; Quick Look Attachments only when
  `_shouldIncludePreviewActionInContextMenu`;
- Paste and Retain Style removed unless the default NSTextViewDefaultContextMenuHasPasteAndRetainStyle (defaultMenu block);
- per-submenu pruning (flags isRichText, usesFontPanel, isEditable, isFieldEditor, NSUseWritingDirectionKeyBindings):
  not rich → Bold/Italic/Underline/Outline/Highlight/Styles/modifyFont go; no font panel → Show Fonts/Colors go; no
  selection or not editable → Replace Quotes/Dashes/Text, Add Links go; not editable → case transforms go; Chinese / width
  conversions ask shouldRemoveTransformationAction:; Writing Direction goes without the key-binding default; Layout
  Orientation goes for a field editor or without the font panel; empty submenus and stray separators removed;
- the delegate may drop the editing rows (`textViewShouldOmitEditingMenuItems:`; NSTextField answers by isEditable).
`-[NSTextView validateUserInterfaceItem:]`: paste rows enabled when editable and the pasteboard has a matching type.
AppKit appends AutoFill (and Services) to context menus.

hyprk (ui/HyprK/textmenu.js rows, ui/HyprK/TextMenu.qml popup with one submenu level): for a plain field with a selection
Look Up "x", Translate "x", Search With Google, —, Cut, Copy, Paste, Paste and Match Style, —, Share, —, Spelling and
Grammar ▸, Substitutions ▸, Transformations ▸, Speech ▸. Acting: Cut, Copy, Paste, Paste and Match Style (plain paste),
Search With Google (browser), Make Upper / Lower Case, Capitalize. Disabled: Look Up, Translate, Share, every Spelling /
Substitutions / Speech row. **GUESS**: Font ▸ left out (whether the field editor keeps usesFontPanel was not decoded:
`-[NSTextView usesFontPanel]` reads bit 5 of the shared data, not traced to the field-editor setup); Chinese/width rows
left out; the Look Up cut-off length (30). Not built: AutoFill ▸, Services ▸ appends.
Fields that have it: ui/HyprK SearchField (Settings' search), Finder RenameField (IconView loader raised over the cell's
mouse area so the field gets the right click), RenameSheet, TagPopover, Settings LiveSpeech, Finder's toolbar search
field, Spotlight's field and the Emoji picker's search (2026-11-14; a Qt popup of the layer surface works, drawn opaque:
the plugin's popup glass covers windows only). **Not done**: Spotlight's mode fields, the lock screen password field
(NSSecureTextField menu not decoded: left without a menu), Quick Look's text view.

## Window menu window list

**C** `-[NSApplication(NSWindowsMenu_Private) _addWindowsMenu:enabled:]` 0x18a558ab0 adds one entry per window
(`-[NSWindow(NSWindow_Theme) _createWindowsMenuEntryWithTitle:enabled:]` 0x18a5590b0; a window with a visible tab bar adds
each tab), entry keys command / tag / system-icon / mark / enabled: mark set for the key window (checkmark) and for a
miniaturised or edited window (NSMenuItemDiamond / NSMenuItemBullet images, cstrings 0x1e28a4940/60). **A**
finder-menus-ax.txt ends the Window menu with —, "◆ Applications", "◆ Utilities" (two minimised windows). Built: menus.js
`windowList` (forIndex appends it to every Window menu), Overlay.qml passes `Apps.activeAppWindows()` (key = the active
toplevel, ◆ = on special:minimized; a row focuses or restores its window), MenuDropdown draws ◆ as a 5 pt square at 45°
(**GUESS** size). Not built: the bullet for unsaved changes, tab rows.

## System Settings View menu pane list

**C** FUN_10002e704 (`CommandGroup(after: .toolbar)`) = Divider + `ExtensionPicker` (Swift struct descriptor
0x1001b0ba0, fields `_navigationSplitViewState`, `navigationMethod`): 27.2.1's View menu does list the panes after a
separator. Its body (row order, checkmark) was not decoded. **Not built**: the shell has no way to switch the running
Settings window's pane (only HYPRK_SETTINGS_PANE at launch). Gap.

## Edit menu icons

**C** `+[NSMenuItem _standardAutoFillMenuItem]` 0x18aa1103c: AutoFill gets the private symbol image through
`imageWithPrivateSystemSymbolName:` + `_setActionImage:` + `_setImageVisibility:`; AppKit's action → symbol table
(cstrings 0x1e28a55a0…: "microphone" next to startDictation:, "emoji.face.grinning" next to orderFrontCharacterPalette:,
"rectangle.and.pencil.and.ellipsis" next to "AutoFill"; also undo/redo/cut/copy/paste symbols, not drawn by Finder's Edit
menu per Q-menubar-17). With **S** Q-menubar-17 (icons on Search, AutoFill, Start Dictation, Emoji & Symbols): all three
carry icons. Applied: Emoji & Symbols [emoji.face.grinning] in Finder's and the other apps' Edit menus; AutoFill and Start
Dictation since 2026-11-14 too (their glyphs decoded from CoreGlyphs' BVG data, ICONS-REA-27.2.1.md part 1).

## Menu bar status items

On 27.2.1 MenuBarAgent hosts the system items (**A** `live/menubar/menubaragent-ax.jsonl`: ids
`com.apple.menuextra.{battery,wifi,controlcenter,clock}`, AXMenuExtra; MAC-ANSWERS Q-menubar-08) and ControlCenter.app
supplies their content: **C** class names in ControlCenter arm64e `BatteryMenuExtraView`, `WiFiMenuExtraView`,
`BluetoothMenuExtraView`, `SoundMenuExtraView`, `DisplayMenuExtraView`, `FocusModesMenuExtraView`,
`NowPlayingMenuExtraView`, `ScreenMirroringMenuExtraView`, `UserSwitcherMenuExtraView`, `ClockController`,
`ModuleMenuExtraPopoversController`, `ControlCenterApp.ModuleWindow`. A click opens a ControlCenter module window, not an
NSMenu (inferred from the class names, not decompiled). Row words **R** `ControlCenter.app/Contents/Resources/<X>.loctable`
(en); their order inside each module **GUESS** (no screenshot of an open module; `status-pills-open-blue.png` shows only
the pills). Legacy extras stay classic NSMenus in SystemUIServer (`CoreServices/Menu Extras/{TimeMachine,VPN,Eject}.menu`).

| item | owner | opens | rows (**R** loctable, order GUESS) | hyprk today |
|---|---|---|---|---|
| Battery | ControlCenter | module | "Battery" + percent; one state line ("Power Source: Power Adapter / Battery", "Fully Charged", "%@ until fully charged", "Charging On Hold"); —; "Using Significant Energy" + apps or "No Apps Using Significant Energy"; —; "Battery Settings…" | glyph + "NN%" (the Mac hides the percent by default, Q-menubar-29), no click action |
| Wi-Fi | ControlCenter | module | "Wi‑Fi" toggle, Known Network(s), Personal Hotspots, Other Networks, —, "Wi‑Fi Settings…" (⌥: details, diagnostics) | opens Control Center |
| Bluetooth | ControlCenter | module | toggle, Devices (battery levels), —, "Bluetooth Settings…" | not shown |
| Sound | ControlCenter | module | volume slider, Output list, —, "Sound Settings…" | not shown |
| Display | ControlCenter | module | brightness, Dark Mode, Night Shift, True Tone, mirror/extend, —, "Display Settings…" | not shown |
| Focus | ControlCenter | module | modes, —, "Focus Settings…" | moon while DND, opens Control Center |
| Now Playing | ControlCenter | module | artwork, title / "Not Playing", transport | not shown |
| Screen Mirroring | ControlCenter | module | devices, "Display Settings…" | not shown |
| Fast User Switching | ControlCenter | module | users, —, "Login Window…", "Users & Groups Settings…" | not shown |
| Control Center | ControlCenter | CC window | **A** cc-ax.json | = |
| Clock | ControlCenter `ClockController` | Notification Center | **A** | = |
| Spotlight | Spotlight | Spotlight panel | – | = |
| Text Input | TextInputMenuAgent (`NSStatusItem setMenu:`, **C**) | classic NSMenu | input sources (✓ current), Show Input Source Name, Open Keyboard Settings…, Show Input Source Palette, Edit Text Substitutions…, Remove Current Input Source (**R** TextInputMenuCore; order GUESS) | not shown |
| Siri, Time Machine, VPN | Siri / SystemUIServer | Siri, classic menus (not decoded) | – | not shown |

Gaps, most visible first: 1. Wi-Fi opens Control Center, not its module (on every bar). 2. Battery: no click action, and
it draws the percent the Mac hides by default. 3. Focus opens Control Center. 4. Bluetooth, Sound, Display, Now Playing
missing (shown on the Mac when enabled / while active). 5. Text Input menu missing (a classic NSMenu; needs an
input-source list). 6. Fast User Switching, Screen Mirroring, Time Machine, VPN, Siri missing (off by default).
Not built in this pass: Battery is a module, not a plain menu, and its row order is GUESS; nothing here was a plain menu
with data hyprk already has.

Gaps 1-3 decoded and built on 2026-11-14: **STATUS-REA-27.2.1.md** (row order, widths and placement from
ControlCenter's code, no longer GUESS; the bar's battery percentage removed). Gaps 4-6 stay open.
