# Questions for the Mac: panels
Scope: Control Center (CC), Notification Center (NC), banners, Spotlight, alerts, sheets. T=shell/Theme.qml CC=modules/ControlCenter.qml SP=Spotlight.qml NF=components/NotifCard.qml BN=Banners.qml AD=AlertDialog.qml MV/MB=modules/spotlight/. R1..R6=MAC-REQUESTS.md. Light+dark each.

Q-panels-01 CC tiles glass or fill?
now: every tile is Glass, tint rgba(.30,.28,.27,.42), CC:195, T:300. guessed
ask: CC layer dump. Per element (tile, toggle circle, round button, slider module, Now Playing): CABackdropLayer+glassBackground yes/no, variant, inputs.

Q-panels-02 CC toggle on/off colours
now: on = white circle + blue glyph; off = white .92 + grey glyph; T:314-318. guessed
ask: pixel RGB of circle and glyph: Wi-Fi on, off; Focus on (is on-state accent blue?).

Q-panels-03 CC tile fill
now: plugin recipe tuned by eye, Material.cpp:76. guessed
ask: tile RGB over flat white, grey, dark wallpaper, centre and 2 pt from edge. Same for slider module.

Q-panels-04 CC element list
now: Wi-Fi, BT, AirDrop, Now Playing, 2 dead round, Dark Mode, Reduce Transparency, Focus, Display, Sound; CC:38-171. guessed
ask: AX list with frames and order in a default CC. Do Dark Mode and Reduce Transparency buttons exist? Any recents pill or extra rows (missing in hyprk)?

Q-panels-05 CC window and tile frames
now: width 292, right 12, top 10, tiles 140x64, gap 12, radius 32; T:288-304. SPEC derived, radius guessed
ask: AX frame of CC and each tile; radius of 2x1, 2x2, round, slider tile; container panel behind (yes/no).

Q-panels-06 CC tile text
now: title 13 semibold white, sub 11 white .78; T:111-112,305. SPEC low
ask: font, size, weight, colour of "Wi-Fi" and subtitle; changes over light wallpaper?

Q-panels-07 CC tile inner layout
now: circle 38 at x 13, text gap 8, right pad 10, glyph .56; CC:218-236. by eye
ask: AX frames of circle, glyph, title, subtitle in a 140x64 tile; round button glyph size (now 22).

Q-panels-08 CC slider module
now: title y 9, track 6 at bottom-19, no knob, white fill, icons 13/18, inset 16; CC:315-359. by eye
ask: frames of title, track, icons; thumb yes/no; track and fill colours; symbols; Display and Sound.

Q-panels-09 CC slider motion
now: click springs 0.3 s, drag 1:1, rubber band, press lift; CC:306,366. guessed
ask: 60 fps: click jump ms, drag, pressed look, stretch past the end.

Q-panels-10 CC hover, press
now: press lift, plugin pointer light, no hover fill. guessed
ask: hover and pressed look of tile, circle, round button: scale, colour, ms.

Q-panels-11 CC Now Playing tile
now: art 38 r8, 3 buttons 22/26 gap 14, "Not Playing"; CC:66-127. guessed
ask: idle and playing: frames, fonts, glyphs, art size (fills tile?).

Q-panels-12 CC sub-panels
now: missing
ask: click Wi-Fi, Bluetooth, Focus, Display, Sound: what opens, frame, glass or solid, rows, way back.

Q-panels-13 CC open and close
now: each tile materializes, spring .5/.7; ControlCenterWindow.qml:53. SPEC only
ask: (R2) scale start, anchor, ms, overshoot, fade, close; whole or per tile.

Q-panels-14 Spotlight glass layers
now: one Glass, plugin "spotlight" recipe = SiriModifier branch A, unconfirmed; SP:182. NOTES
ask: layer dump if possible: backdrops, inputs, field separate from results? Else pixels over white/black/colour.

Q-panels-15 Spotlight inner field
now: capsule inside bar, inset 8, fill white .08 / grey .12; SP:198, T:337. guessed
ask: yes/no inner field shape in empty bar? frame, fill colour.

Q-panels-16 Spotlight query text
now: 26 px Display, placeholder "Spotlight Search" tertiary; SP:220,237. by eye
ask: font, size, weight, colours, placeholder string, caret, selection colour.

Q-panels-17 Spotlight bar frame
now: 640x56 r28, top 22% of screen, magnifier 20 at x20; T:327-330. SPEC w/h/r; 22% doc image
ask: AX frame with screen size, empty and with results; magnifier size, x, colour.

Q-panels-18 Spotlight results container
now: same panel grows under 1 px inset divider, spring; SP:162-259. guessed
ask: one glass or two? gap, radius, divider yes/no, max height, max rows.

Q-panels-19 Spotlight rows
now: row 48, icon 34, text 15, pill r14 inset 8; T:331-340. TODO
ask: frames per row type, fonts, colours, selection fill, hover vs keyboard.

Q-panels-20 Spotlight sections, trailing
now: headers 11 semibold h24: Calculator, Applications, Actions, Files; no Top Hit, no kind text, no preview pane; SP:54-77. TODO
ask: section titles and order for "safari", "2+2", a file; Top Hit, Show More, right-side text, preview pane (yes/no, frame).

Q-panels-21 Spotlight calculator row
now: row x1.3, result 26, sub 11; SP:292,347. guessed
ask: "2+2" row frame, fonts, hint; unit conversion layout.

Q-panels-22 Mode buttons: glass?
now: 4 glass circles 56, gap 10, 12 right of bar; MB:23-60. guessed
ask: frames, backdrop yes/no, variant, glyph names and size, when shown.

Q-panels-23 Mode button states
now: active accent disc inset 6, hover grey disc; MB:79. guessed
ask: active, hover, pressed: colours, glyph colour, label or tooltip.

Q-panels-24 Cmd+1..4 modes
now: Apps, Files, Actions, Clipboard, "Search Apps", Left/Right cycle; lib/spotlight.js:8. guessed
ask: names, order, key map, placeholder, field icon or token, arrows, Esc.

Q-panels-25 Spotlight mode views
now: Apps 6 cols icon 56 3 rows, chips 26, lists 7 rows; MV:22-27. "no reference shot"
ask: per mode panel frame, cell, rows, chips, headers, empty and first-use texts.

Q-panels-26 Spotlight open and close
now: materialize at field centre, results spring .5/.85; T:463. by eye (R2)
ask: 60 fps scale start, anchor, ms, fade, results growth, mode buttons timing.

Q-panels-27 Banner frame, glass
now: 344 wide, r24, pad 14, icon 34, top 8, right 10; T:246-253. TODO, SPEC none
ask: AX frame short and 4-line text, radius, margins, glass yes/no, variant.

Q-panels-28 Banner text
now: title 13 semibold + time 11, body 13 x4 lines; NF:146-176. TODO
ask: fonts, colours, app-name line?, time format, icon frame, sender photo + badge.

Q-panels-29 Banner hover, actions
now: 20 px close button top-left only; NF:187. guessed
ask: hover frame, Close/Options/action pills, glass, expanded banner, reply field.

Q-panels-30 Banner motion
now: 5 s, in .5 s spring, out .38 s, swipe 30%; BN:336-390. guessed, not in R2
ask: direction, anchor, ms, curve, hover pause, swipe, same-app stacking.

Q-panels-31 NC frame, material
now: 328 wide, top 10, right 14, gap 16, widget r22; T:259. doc image
ask: AX frames of NC, widgets, cards; default widgets; widgets glass, solid or vibrant (yes/no); cards variant (10?); scrim.

Q-panels-32 NC groups, motion
now: peek 8, header 15 semibold, pills h24, slide .5/.4 s; NCt:80,226. guessed
ask: header, pills, stack, Clear All; open/close direction, ms, curve.

Q-panels-33 Alert layout, buttons
now: 260 wide r26, icon 64, centre 1/3, buttons 28 capsule fill .06/.14; AD, T:389. size measured, rest guessed
ask: icon frame, position, dim scrim, 3 buttons layout, fills, weight, pressed, destructive.

Q-panels-34 Sheets, accessories
now: missing
ask: sheet frame, radius, glass or solid, parent dim; alert with checkbox or text field.
