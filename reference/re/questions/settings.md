# Questions for the Mac: settings
Scope: Settings clone and shared controls (settings/, ui/HyprK), most visible first, light+dark if they differ. webp = 9to5mac shot, not the Mac. R1..R6 = MAC-REQUESTS.md. Th/Tk/SA = Theme/Tokens/SettingsApp.qml.

Q-settings-01 Sidebar material
now: flat fill rgba(.93,.925,.918,.88) over blur, Th:113, webp
ask: Is the sidebar a CABackdropLayer glassBackground (which _variant) or an NSVisualEffectView? Dump layer tree. Flush to the window edge or inset? Sampled fill.

Q-settings-02 Toolbar back/forward capsule: glass?
now: 72x36 r18 fill black 3% + 1px stroke, SA:192, webp
ask: yes/no: Liquid Glass (variant) or flat fill? Size, x, icon size and weight, divider, disabled colour, hover and pressed.

Q-settings-03 Window frame
now: 745x630, r26, toolbar 52, min 680x420, Th:78-83, webp/TODO
ask: Default and min size, corner radius pt, toolbar height, border or shadow. Does content scroll under the toolbar?

Q-settings-04 Toolbar scroll edge
now: missing (content just clips at 52 px)
ask: Scroll Keyboard pane. Blur or fade under the toolbar? Height, blur radius, tint, glass yes/no. 60 fps clip.

Q-settings-05 Sidebar selected row
now: accent pill r10, inset 10, white DemiBold text, Th:100-110, webp
ask: Fill, radius, inset, text weight and colour, hover fill. Glass or flat?

Q-settings-06 Inactive and disabled
now: missing inactive look (accent stays); disabled = opacity 0.4, Tk:51
ask: Inactive Settings window: sidebar selection, switch/slider/checkbox fill, text, tiles. Disabled switch, slider, popup, button, label: real colours.

Q-settings-07 Sidebar metrics and account header
now: row 32, font 13, icon 21, gap 7, group gap 13, search y 61, avatar 40, Th:100-110, webp; S/L icon 16/26 guessed
ask: AX frames: search, account block (avatar, fonts, gaps), 3 rows, a group break. Row height and icon at size S/M/L.

Q-settings-08 Sidebar items
now: 22 panes, "Control Center" no "Menu Bar", Panes.js:3-26
ask: Full 27.2.1 sidebar list in order with group breaks (Apple Account, Family, Passwords, Menu Bar...). Which differ on a Mac without battery.

Q-settings-09 Sidebar icon tile
now: r=.27*size gradient tile, glyph .68, PaneIcon:217; real art only Siri, Spotlight
ask: Enclosure shape, radius, gradient/flat colour per pane, glyph size, edge or gloss, light+dark. Art itself is R3b.

Q-settings-10 Sidebar search field
now: 28 high, r14, black 4%, white 85% rim, Tk:60-64, webp
ask: Glass yes/no. Height, radius, icon size, placeholder colour/font, focus look, clear button. Does it search inside panes too?

Q-settings-11 Content card
now: r12, black 3% / white 5% on #FFF / #1E1E1E, no stroke, Tk:30-31, webp
ask: Sampled window bg and card fill, radius, stroke or shadow. Solid or backdrop layer (glass yes/no)?

Q-settings-12 Row metrics
now: row 37, pad 10, separator inset 10, black 5.5%, Th:124-144, webp
ask: Heights: 1 line, with 11 pt sublabel, with icon, picker. Padding, separator inset and colour, card gap, header gap.

Q-settings-13 Text styles
now: SFNS 13/11, labels 85%/50%, header 13 Bold, title 16 Bold, no tracking set, Th:60-72
ask: Per element (sidebar row, label, sublabel, section header, title, hero, button, popup): family, pt, weight, tracking, line height, rgba. Does opsz change at 11/13/17? Emoji size in a label. R4.

Q-settings-14 Pane hero
now: card >=110 high, icon 56, title 18 Bold, desc 11, HeroCard.qml
ask: Which panes show a hero? Card or bg? Icon size, title and desc fonts, gaps, height. Section header gaps.

Q-settings-15 Push button
now: 24 high r12 capsule, black 8%, accent default, min 64, Tk:49-50 TODO
ask: Regular/small/mini height (alert buttons are 28 in LIVE), radius, min width, padding, fills, default, pressed, disabled. Glass or flat? Same for "?" help button.

Q-settings-16 Switch
now: 38x22, knob 18, off black 9%, white knob, Tk:40,57 TODO
ask: Track and knob size per control size, on/off colours, knob colour and shadow, inset. Is the knob glass at rest?

Q-settings-17 Switch and slider press
now: knob x1.55 / x1.25, springs .47/.7 and .25/.75, Tk:106-118, SPEC only
ask: 60 fps: peak knob size, time to peak, overshoot, travel curve, track colour time; slider jump-to-click time. Extends R2.

Q-settings-18 Slider
now: track 4, knob 24x16, ends glyph 15/18, ticks 1x4, Tk:46-48 TODO
ask: Track height, knob size and shadow, fills, tick size and colour, end icon size and gap, row height.

Q-settings-19 Pop-up button
now: label + round 20 px chevron, h22, black 8%, Popup.qml:199, webp
ask: Same look for every pop-up? Sizes, chevron symbol, gaps, hover, pressed, disabled.

Q-settings-20 Pop-up menu
now: solid #F6F6F6 r10, row 24, hot row accent r5, Tk:44-45,59
ask: Glass (LIVE: regular glass r12)? Row highlight colour, radius, inset, text colour, checkmark column, position over button, open and close motion.

Q-settings-21 Checkbox and radio
now: checkbox 14 r4 white, border 22%, tick 2, gap 6, Tk:68-77 guessed; radio missing
ask: Size and radius at regular/small/mini, off/on/mixed/disabled/pressed colours, border, tick geometry, gap, label. Radio: ring, dot, colours. Glass yes/no.

Q-settings-22 Segmented control
now: h24, track black 8%, pill white / white 24%, inset 2, pad 10, Tk:79-84 guessed
ask: Height by size, track and pill colours, glass yes/no for pill and track, separators, pressed, pill slide time and curve.

Q-settings-23 Text field and stepper
now: missing (only the sidebar search field)
ask: NSTextField rounded and plain: height, radius, fill, border, font, focus look. NSStepper: size, shape, glass yes/no, glyphs, pressed.

Q-settings-24 Focus ring
now: 3 px, accent a0.5, no scale-in, Tk:85-86, opacity SPEC 10.6
ask: Tab to button, switch, checkbox, popup, text field: width, gap, rgba (keyboardFocusIndicatorColor), radius per control.

Q-settings-25 Appearance: accent row
now: swatch 24, ring 32/3, pitch 36, name 11 under selected, Appearance:154-221, SPEC 15
ask: AX frames of 9 swatches: pitch, row height, label font and gap, hover, press, ring animation. Colours are R5.

Q-settings-26 Appearance: mode and Liquid Glass
now: Light/Dark/Auto 68x46 r8 ring 3; preview 268x180 r14 + slider, Appearance:17-143, webp
ask: Sizes, radius, ring, caption font, row heights. What changes in the preview as the slider moves (0, 50, 100)? Slider end icons, ticks.

Q-settings-27 Appearance: highlight and icon style
now: 16 px dot + popup; tiles 44 Default/Dark/Clear/Tinted, Appearance:225-270, webp
ask: Highlight popup items and swatches. Icon style tile size, ring, caption; what each style does to Settings' sidebar icons (4 shots).

Q-settings-28 Displays
now: thumbs 44-74 r6, 5 tiles 64x40 "Aa", gap 18, Displays:64-230, guessed
ask: AX frames and fonts: thumbnail size/radius/ring, label, 5 size tiles ("Aa" pt, gap), caption, card or not, rows below. External display too.

Q-settings-29 Desktop & Dock
now: sliders with -/+ glyphs, 3 cards, Dock.qml, guessed
ask: Rows, section titles, order on 27.2.1. Slider end labels or icons, width, ticks, row heights. Magnification default (R2).

Q-settings-30 Accessibility
now: hero + cards, 22 px blue tile, chevron 18, Accessibility.qml:26-89
ask: Sections, row order, tile size/colour per row, chevron, sub-page title and back button look.

Q-settings-31 Wallpaper
now: preview 128x72, flat 4-col grid r8 ring 3, Wallpaper.qml:49-98, guessed
ask: Layout: preview size, popup, categories, tile size/radius/gap, selected ring, Add button, dynamic options.
