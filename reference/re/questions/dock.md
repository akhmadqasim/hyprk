# Questions for the Mac: dock
Scope: Dock, Apps/Launchpad, Cmd-Tab, Mission Control on 27.2.1. Skipped, R2 has them: bounce, magnify curve, label timing, open/close motion, minimise motion.
Paths under shell/: D=modules/Dock.qml L=Launchpad.qml S=Switcher.qml M=MissionControl.qml T=Theme.qml. pt, light+dark if different.

Q-dock-01 Dock material
now: Glass tintClear (a .26 white / .30 grey) over plugin "dock" recipe D:199, T:171, source: SPEC+guessed tint
ask: Dump the real Dock window layer tree: CABackdropLayer? glassBackground inputs, any extra tint/fill layer, shadow. Light+dark, on a bright and a dark wallpaper.

Q-dock-02 Tile and Dock size
now: tile = 0.034 x screen width, D:27, T:220, source: guessed from a 9to5mac image
ask: Fresh account: tilesize, icon art pt, Dock height and width with 10 items. Do on two displays (MBA 2x, plus one other size if any).

Q-dock-03 Dock padding
now: top/bottom 6, sides 8, bottom gap 4, T:224-227, source: SPEC (medium)
ask: AX frames: Dock bg to icon top, icon bottom to bg bottom, bg left to first icon, bg bottom to screen edge.

Q-dock-04 Corner radius
now: 26 fixed, T:226, source: eyeballed from a web image
ask: Radius in pt at tilesize 32, 48, 64. Fixed, or a fraction of height?

Q-dock-05 Icon spacing
now: 2 pt between tiles, T:223, source: SPEC (medium)
ask: Gap between neighbouring icon frames and between art edges.

Q-dock-06 Separator
now: 1 pt, inset 7, hPad 8, black .55 / white .30, D:226 T:230-234, source: guessed
ask: Width, height, colour light+dark (vibrant?), art-to-art distance across it.

Q-dock-07 Running dot
now: 3 pt circle, 1 pt below icon, black .55 / white .65, D:269 T:228, source: eyeballed
ask: Diameter, offset from icon bottom, colour light+dark. Does it differ for hidden app or several windows?

Q-dock-08 Hover label: glass?
now: solid chip .92 alpha + hairline, radius 8, h 24, D:280 T:156,237, source: guessed (font 14 from SPEC)
ask: Yes/no: is the label a glass layer? If yes, variant and radius. Also height, h-padding, gap to icon, text colour, shadow, light+dark.

Q-dock-09 Press state
now: icon scales down by spring and gets black .25 overlay, D:247-266, source: guessed
ask: Mouse down on an icon: scale, brightness change, duration, release curve.

Q-dock-10 Dock context menu
now: windows, Options (disabled), Show in Finder (disabled), Quit/Open, D:308, Apps.qml:229, source: guessed
ask: Exact items and order for running app, not running, Finder, Trash, Downloads, with modifiers. Does it use the standard menu glass? Offset above icon.

Q-dock-11 Default Dock items
now: Apps.dockItems + separator + Downloads + Trash, D:127, source: none
ask: Item list and order on a clean 27.2.1 account. Is Launchpad/Apps still present? Is Finder pinned first?

Q-dock-12 Downloads stack
now: plain folder icon, click opens the folder, D:315, source: missing
ask: Stack icon look (fan/grid/list), click popup: layout, size, glass yes/no, radius (SPEC says 16/24), labels, Open-in-Finder row.

Q-dock-13 Minimised window tiles
now: missing, window genies to the Downloads slot D:61, source: missing
ask: Minimise a window: tile size, position (right of separator?), art, app badge size and position, genie duration/curve in 27.2.1, default mineffect.

Q-dock-14 Recent apps section
now: missing, source: missing
ask: Is there a second section of recent apps with its own separator by default? Setting name, count, tile look.

Q-dock-15 Badges and attention
now: missing, source: missing
ask: Red badge: size, position, font, colour, max text. Attention bounce: height, period, count.

Q-dock-16 Autohide motion
now: dissolve/slide by materialize, delay .15 s, D:94 T:466, source: SPEC delay, motion guessed
ask: Record hide and show with autohide on: slide or fade, duration, curve, visible sliver in px, trigger zone height, delay.

Q-dock-17 Drag and remove
now: missing, source: missing
ask: Drag an icon out (Remove label look, poof), reorder gap animation, drag lift scale.

Q-dock-18 Dock position
now: bottom only, source: missing
ask: Are left/right still offered in Settings? Frame of bg and labels when left.

Q-dock-19 Cmd-Tab: glass?
now: Glass tintStrong, regular recipe, S:302, source: guessed
ask: Yes/no: panel is Liquid Glass? Layer tree, variant, radius, shadow, light+dark.

Q-dock-20 Cmd-Tab size
now: icon 128, cell pad 10, panel pad 18, radius 34, S:288 T:352-355, source: guessed ("no reference shot")
ask: With 5 apps: panel w/h, icon pt, gaps, radius. Where on screen (vertical centre?). Layout when too many apps (shrink or two rows).

Q-dock-21 Cmd-Tab selection and label
now: rounded rect white .18 / black .12, r 24; name under selected, 13 pt, S:323-347, source: guessed
ask: Selection fill, radius, inset, vibrancy? Label position, font, size, weight, colour. Hover state?

Q-dock-22 Cmd-Tab behaviour
now: Tab/arrows/Return, release Super commits, order = active then dock order, S:273, source: guessed
ask: Order (MRU?), delay before panel shows, Q, H, 1 keys, Cmd-` windows, fullscreen/hidden apps, mouse click, wrap at ends.

Q-dock-23 Apps panel: what and where
now: centred glass panel .56 x .56 of screen, L:58 T:366, source: measured on an Apple guide image
ask: What does the Dock Apps icon / F4 open in 27.2.1: Spotlight mode or own window? Panel w/h in pt, position, radius, glass yes/no and variant, backdrop dim.

Q-dock-24 Apps grid
now: 7 columns, icon 52, row pitch 88, label 11, L:141 T:369-371, source: partly measured, label TODO
ask: Columns, rows, icon pt, cell pitch, label font/size/colour, gap icon to label, sort order, selection/hover state.

Q-dock-25 Apps search and header
now: appstore glyph + 20 pt field + ellipsis, header 46, pad 18, L:84-139, source: measured/TODO
ask: Header frame, field height, font, placeholder text, glyph names, ellipsis menu content, separator line, search result layout.

Q-dock-26 Apps folders, paging, edit
now: pages with dots 7 pt; no folders, no wiggle/drag, L:185, source: partly guessed
ask: Folders: icon, open view, radius. Page dots size/colour, swipe/wheel behaviour, edit/drag mode, categories.

Q-dock-27 Mission Control backdrop
now: blurred wallpaper + black .35, M:77-84, source: guessed
ask: Wallpaper dim and blur radius, light+dark. Is anything glass in MC? Menu bar and Dock still visible?

Q-dock-28 Mission Control windows
now: square grid, margin 60, gap 40, radius 10, max scale .8, T:419-422, source: guessed
ask: Layout of 1, 2, 4, 7 windows: frames, gaps, radius, shadow, scale limit, ordering, multi-display.

Q-dock-29 Window title in MC
now: tooltip-style chip with border on hover, M:217-237, source: guessed
ask: Yes/no: title is drawn on a glass/solid chip? Always shown or hover only, app icon 48 pt (SPEC) position, font, size, colour.

Q-dock-30 MC hover outline
now: accent border 3 pt, scale 1.03, M:208 T:420-423, source: guessed
ask: Hover/selected outline: width, colour, radius, scale. Cursor state, close button, drag to Space.

Q-dock-31 Spaces bar
now: bare thumbnails 150 pt, labels "Desktop N", current outlined, no bg, T:415-418, source: guessed
ask: Bar frame, thumbnail w/h/radius, label font, current-space marker, "+" button, full-screen app tiles, hover expand, bar glass yes/no.
