# Questions for the Mac: finder
Scope: Finder window on 27.2.1, default window, Documents folder. hyprk px values come from a 1.14x screenshot, so give POINTS. Light and dark if they differ.

Q-finder-01 Toolbar capsules glass?
now: 5 capsules are solid #FAFAFA + 1px border + fake shadow (Capsule.qml:13, Theme:87), guessed
ask: for nav, view switcher, group, actions, search: is it a CABackdropLayer with glassBackground? yes/no each, plus variant and recipe inputs, light and dark.

Q-finder-02 Toolbar geometry
now: height 64, capsule 44 at y10, gap 20, buttons 44 wide, icon 24 (Theme:162), source: 1.14x ref
ask: AX frames in pt: toolbar height, each capsule frame, gaps, icon size, left/right inset.

Q-finder-03 Sidebar material
now: solid #EDEDED / #2B2B2D, translucent 62% only with blur (Theme:81), source: ref colour
ask: is the sidebar glass (which _variant, inputs, D) or vibrancy or solid? Is it a floating inset panel (frame, radius) or edge to edge?

Q-finder-04 Sidebar geometry
now: width 191, row 38, inset 14, radius 10, icon 22, text x56, header 30 (Theme:147), source: 1.14x ref
ask: pt values of all of these, plus first row y, gap between sections.

Q-finder-05 Window radius, border, shadow
now: radius 22, 1px #BEBEBE border (Main.qml:63), shadow by compositor, source: ref/by eye (SPEC says 16)
ask: window corner radius with toolbar, outer border colour and width, shadow, light and dark.

Q-finder-06 Title text
now: "Documents — Local" 17.5 DemiBold #4D4D4D, left of the view switcher (Toolbar.qml:49), source: ref px
ask: font size pt, weight, colour, x position, subtitle if any, inactive colour.

Q-finder-07 Sidebar text and headers
now: items 15.5, headers 13.5 DemiBold a0.45, no collapse arrow (Theme:57), source: ref px
ask: pt size, weight, colour of items and headers; chevron on header hover; selected-row weight.

Q-finder-08 Sidebar icon colour
now: all icons accent-like #0C72EF, 22 px (Theme:76), source: ref
ask: which icons are tinted and with what (accent, fixed colour, hierarchical); size; tag dot size; Recents/Shared/AirDrop icons.

Q-finder-09 Sidebar selection and hover
now: #E2E2E2 / white 12%, radius 10, no hover, no inactive state (Sidebar.qml:406), source: ref (light only)
ask: selected row fill, light and dark, active vs inactive window; hover fill; pressed fill.

Q-finder-10 Toolbar button states
now: pressed = 7% pill; disabled opacity 0.9 with lighter glyph; no hover (ToolButton.qml), guessed
ask: hover, pressed, disabled look of back/forward and action buttons; is the pill glass; light and dark.

Q-finder-11 View switcher selection
now: 4 segments of 46, selected = 7% pill inset 4, separators 1px (Toolbar.qml:67), guessed
ask: selected segment fill and shape (glass?), dimensions, separators, icons used, movement when switching.

Q-finder-12 Icon grid metrics
now: cell 154x138, icon 77, label gap 8, label width 132, side pad 13 (Theme:176), source: 1.14x ref
ask: pt: cell size, icon size at default zoom, gap icon-label, label max width, padding, first icon origin.

Q-finder-13 Icon and label selection
now: icon plate 8% black r8, label capsule accent r5 white text (IconView.qml:87,104), source: by eye
ask: plate and label fill, radii, paddings, inactive window, light and dark; hover state.

Q-finder-14 Icon label text
now: 14.3 px, 2 lines, line height 1.12, centred (IconView.qml:113), source: ref px
ask: font size pt, weight, line spacing, colour, truncation style, tag dot placement.

Q-finder-15 List view metrics
now: row 24, header 28, icon 18, cols Date 190, Size 90, Kind 160, font 13/12 (Theme:189), guessed
ask: pt: row height, header height, icon size, default column widths, text sizes and colours, left padding.

Q-finder-16 List selection and stripes
now: accent row r6 full width, stripes #F4F5F5, inactive #DCDCDC (FileList.qml:271), guessed
ask: selected fill, radius, inset, text colours, stripe colours, inactive window, light and dark; disclosure triangle in folder rows.

Q-finder-17 List header
now: 1px separators 14 high, sort chevron, DemiBold when sorted (FileList.qml:196), guessed
ask: header fill/material, separator, chevron, font, hover/pressed state, column resize cursor.

Q-finder-18 Date and size format
now: "Today at 14:03", "5 Nov 2026 at 14:03", sizes via formatSize (files.js:218), guessed
ask: exact strings for today, yesterday, this year, older, 12h vs 24h, "--" for folders, size units (KB/MB, decimals).

Q-finder-19 Column view
now: column 240, row 24, chevron 14, last column accent, others grey, no resize handle (ColumnView.qml), guessed
ask: column width, row height, selection colours per column, resize handle, preview column layout and fonts.

Q-finder-20 Gallery view
now: big preview + 66px strip + name; no inspector (GalleryView.qml), guessed
ask: layout in pt: preview area, strip thumb size and spacing, selected thumb look, right-side Preview pane contents.

Q-finder-21 Status bar
now: missing
ask: does 27.2.1 Finder have a status bar (item count, "x of y selected", space)? Height, font, colour, material, where.

Q-finder-22 Path bar
now: 26 high, solid, 12px text, chevrons, folder icons 14 (PathBar.qml), guessed
ask: height, material (glass?), position, font, icon size, separators, hover/selected item, drag target look.

Q-finder-23 Context menu items
now: file: Open, Trash, tag dots, Quick Look, Rename; background: New Folder + sort (Main.qml:249), guessed
ask: full item lists for a file, folder, multi-select, empty background, in order with separators, shortcuts, submenus.

Q-finder-24 Menu hover highlight
now: accent r6 full row, text x24, shortcut margin 10 (PopupMenu.qml:455), guessed; LIVE says x28/13
ask: hover fill, radius, inset, text colour on hover, disabled colour; does it animate.

Q-finder-25 Tag dots row
now: 7 dots 15 px, spacing 9, hover scale 1.2, row 30 high (PopupMenu.qml:497), guessed
ask: dot size, spacing, row height, tag name label, hover/selected look, order of tags.

Q-finder-26 Quick Look
now: in-window panel r16 97% opaque, 44 title bar, "Open" pill (QuickLook.qml), guessed
ask: separate window? size rule, material (glass?), radius, title bar controls, shadow, open/close motion.

Q-finder-27 Rename field
now: white box r3, 2px ring a0.45, base name selected (RenameField.qml:10), guessed
ask: fill, radius, ring colour and width, padding, selection colour, size in icon and list view.

Q-finder-28 Drag feedback
now: icons 62% opacity, red 20px badge, folder ring 2px accent, snap-back 220ms (DragSession.qml), guessed
ask: drag image opacity, badge size and colour, target highlight in icon/list/sidebar, spring-load, snap-back timing.

Q-finder-29 Inactive window
now: missing (only traffic lights react)
ask: toolbar, title, sidebar, selection, icon-view colours when the window is not key, light and dark.

Q-finder-30 Motion
now: search width 120ms OutCubic, no other motion (Toolbar.qml:119), guessed
ask: 60fps: view switch, folder enter/back, selection change, sidebar hover, search expand, Quick Look open/close.

Q-finder-31 Folder and file icons
now: 27.2 IPSW PNGs, folder tinted to ref (113,185,228), 18px in lists (FileIcon.qml), source: SPEC/ref
ask: render the generic folder, Documents folder and a PDF/txt icon as shown at 18 and 77 pt; tint changes in dark?

Q-finder-32 Tabs and tab bar
now: missing
ask: how does the tab bar look with 2 tabs (height, material, tab shape, close button, colours)?
