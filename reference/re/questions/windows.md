# Questions for the Mac: windows
Scope: app window chrome as the compositor draws it. Light and dark unless said. Use TextEdit, Finder, Safari, Terminal. No R1..R6 repeats.

Q-windows-01 Window shadow
now: range 60, offset y18, black a0.28 active / a0.18 inactive (hyprland.lua:69-76), source: guessed
ask: Finder window shadow active and inactive: extent px, y offset, alpha at 4 distances from the edge, on white and wallpaper.

Q-windows-02 Corner radius and curve
now: 16 all types, power 2.8 (hyprland.lua:65-66), source: SPEC 16 / guessed power
ask: radius in pt on 2x shots: TextEdit, Finder, Safari (toolbar), utility panel, alert. Continuous curve exponent?

Q-windows-03 Window outline
now: 1px black a0.12 active, a0.09 inactive (hyprland.lua:56-59), source: guessed
ask: pixel colours across the edge (outside, edge, inside) on white and dark wallpaper, active and inactive. Any top rim highlight?

Q-windows-04 Is a plain titlebar glass?
now: solid colour, glass off (Titlebar.cpp:298), source: guessed
ask: yes/no for TextEdit, Terminal, Safari, Finder. Layer dump: CABackdropLayer with glassBackground? else its fill.

Q-windows-05 Titlebar colour
now: #F3F1EF active, #F6F5F4 inactive, or sampled from the client (Config.cpp:70-71, Titlebar.cpp:276), source: guessed
ask: pixel colour of TextEdit and Finder bars, active and inactive. Same as content or a separate material?

Q-windows-06 Titlebar height, divider
now: 32 pt, no divider (Config.hpp:64), source: SPEC
ask: AX frame of the bar in TextEdit, Terminal, Safari, Finder. Divider line (colour, alpha)? Only when content scrolls under?

Q-windows-07 Traffic light position
now: red left edge 15 pt, centred in 32 (Config.hpp:64, TitlebarLayout.cpp:6), source: guessed (SPEC says 7)
ask: AX frames of the 3 buttons relative to window origin in TextEdit, Finder (52 pt toolbar), Safari: x, y, size, pitch.

Q-windows-08 Light colours, active and pressed
now: two-stop gradients (Titlebar.cpp:71-74), pressed flat #C04741 etc (line 75), source: SPEC
ask: pixel colours top/centre/bottom of each disc plus rim, at rest and with the mouse held, 2x.

Q-windows-09 Lights, inactive window
now: flat grey .886 a0.30 / dark .96 a0.18 (Titlebar.cpp:220), source: SPEC
ask: disc colours in a non-key window, and on hover over it (coloured again?).

Q-windows-10 Hover glyphs
now: x - + 1.2 pt strokes, group hover, 0.3 s spring (Titlebar.cpp:76-77,175), source: SPEC
ask: 60 fps pointer in/out: fade frames and curve. 2x glyph: stroke width, size, colour.

Q-windows-11 Title text
now: SF Pro Text 13 semibold centred, #333 a0.85, inactive a0.35 (Titlebar.cpp:79,141, Config.cpp:72), source: guessed
ask: family, size, weight, colour of a TextEdit title, active and inactive. Centred on window or free space? Truncation style?

Q-windows-12 Title in toolbar windows
now: Finder draws own title (finder/qml/Toolbar.qml), source: guessed
ask: Finder, Safari, Mail: title position, size, weight, subtitle style.

Q-windows-13 Toolbar buttons glass?
now: capsules #FAFAFA a1, border a0.07 (finder Theme.qml:87); GTK pill rgba255 a0.86 (gtk build.py:35), source: guessed
ask: yes/no each in Finder and Safari: back/forward, view switcher, search field, Share, tab bar. Layer dump: glassBackground variant, D; else fill and radius.

Q-windows-14 Toolbar container glass?
now: bar is solid (no glass), source: guessed
ask: yes/no: is the 52 pt strip or its background any glass or NSVisualEffectView? Does content blur or fade under it when scrolled (scroll edge effect height)?

Q-windows-15 Sidebar material
now: Finder rgba .93/.62 light, .17/.62 dark, or solid #EDEDED (finder Theme.qml:81), source: measured 1.14x shot
ask: glass (variant 17) or vibrancy? Pixel colour over white and dark wallpaper, active and inactive. Inset from window edge? Row height, selection radius.

Q-windows-16 Window open
now: popin 98%, 0.5 s bezier, no fade (hyprland.lua:139), source: SPEC (recording cannot tell)
ask: 60 fps open of TextEdit and Finder: scale, alpha per frame. With Reduce Motion on.

Q-windows-17 Window close
now: popin 98%, 0.25 s, fade (hyprland.lua:140,142), source: SPEC (blur 0..5 missing)
ask: 60 fps Cmd-W: scale, alpha, blur per frame, total time.

Q-windows-18 Minimise and restore
now: genie 0.5 s (plugin-motion main.cpp:222), source: SPEC 11.3
ask: 60 fps genie frames to Dock and restore, window alpha, default mineffect on a clean account.

Q-windows-19 Green button
now: toggles maximized, not full screen (Titlebar.cpp:367), source: guessed
ask: click, Option-click, 1 s hover on green: result and hover menu (items, size, material, delay). Default on 27.2.1?

Q-windows-20 Zoom and full screen motion
now: windowsMove easeInOut 0.35 s; no full screen motion (hyprland.lua:145), source: SPEC (curve not decoded)
ask: 60 fps zoom and full screen enter/exit: frame size per frame, bar slide, menu bar reveal.

Q-windows-21 Titlebar double-click, drag
now: double-click missing; drag moves (Titlebar.cpp:391), source: none
ask: double-click action (AppleActionOnDoubleClick)? Does drag change shadow or raise the window?

Q-windows-22 Document dot, proxy icon, disabled lights
now: missing (Titlebar.cpp:318 always enabled)
ask: TextEdit edited vs saved: close-light dot, proxy icon, title menu. Lights in a fixed-size window (Settings): grey disc, glyph on hover.

Q-windows-23 Resize
now: resize_on_border 1px (hyprland.lua:61), source: guessed
ask: size in pt of the edge and corner resize zones, cursor at each, min size of TextEdit, live-resize behaviour.

Q-windows-24 Tiling and snap
now: all floating, no snap (hyprland.lua:264), source: guessed
ask: edge-drag, Option-drag, Window > Move and Resize: preview overlay (colour, radius, material), tile gap (SPEC 8), 60 fps animation, hotzone size, screen-edge margin.

Q-windows-25 Non-key window look
now: only lights and title dim (Titlebar.cpp:278,318)
ask: Finder active vs inactive shots: what else changes (sidebar, toolbar buttons, selection)?

Q-windows-26 Cursor shapes
now: arrow id 100, I-beam 101 (themes/cursors MAPPING.md), source: SPEC (ids inferred)
ask: 2x cursor dump with hotspot for arrow, I-beam, link hand, edge/corner resize, column resize.

Q-windows-27 Drag and drop cursor
now: arrow kept, no copy/alias badge (hyprland-dnd-arrow.patch), source: SPEC
ask: Finder drag: cursor, badge for Option (copy) and Cmd-Option, not-allowed, drag image alpha and scale, spring-back.

Q-windows-28 Foreign app chrome
now: GTK headerbar 52 px, Qt gets plugin bar (gtk4.css:36), source: guessed
ask: Chrome or VS Code on 27.2.1: titlebar height, lights, radius, shadow, toolbar look.
