# Answers from the Mac session, round 3 (macOS 27.2.1, 26B131, MacBook Air M2 15")

Requests from the PC over the relay (#89). Same conditions as `MAC-ANSWERS-2.md`: default 1440x932 pt @2x, Reduce
Transparency / Increase Contrast / Reduce Motion off, Stage Manager off and desktop icons hidden during the shots
(restored after), 60 Hz panel so clips are 60 fps at most, `screencapture -v` clips are VFR on a 60 fps time base.

## R3.1 Alert appear and dismiss over flat grey: done
- `screens/27.2.1/windows/alert-appear-dismiss-grey-{dark,light}.mov`, extra stills `alert-shown-grey-{dark,light}.png`
- Finder app-modal NSAlert via `display alert ... as warning` with the Empty Trash text and buttons (the real Empty Trash
  was not used, so nothing could be deleted). Alert window frame 515,109 410x384 pt (CGWindowList, layer 8, incl. shadow).
  Dismissed with Esc.

## R3.2 Spotlight light over white: done
- `screens/27.2.1/panels/spotlight-light-white-{empty,results}.png`, `spotlight-light-white-open-close.mov`
- TextEdit window 0,29 1440x851 pt behind. In light mode the field reads dark over the white window (see the stills).
  The results for "text" list only the app and Settings items, nothing personal.

## R3.3 More Space scaled mode: done
- `screens/27.2.1/scaled/more-space-{dock,menu,settings}.png`, `more-space-spotlight-close.mov`
- Mode: 1920x1243 pt, 3840x2486 px backing (2x), panel 2880x1864, 60 Hz. Display put back to 1440x932 afterwards.
- Note on "default": Displays labels **1710x1107 as "Default"** on this 15" MacBook Air. Rounds 2 and 3 use 1440x932,
  the unscaled 2x mode (1 pt = 2 panel px), as the brief asked ("2x, no scaled mode"). Round 1 was at 1710x1107 (Apple's
  Default, which is a scaled mode on this panel).

## R3.2b Spotlight pill idle / hover / clear: done
Files: `screens/27.2.1/panels/spotlight-pill-{idle,hover,clear}-{light,dark}.mov`, `spotlight-pill-idle-{light,dark}.png`.
Times are clip pts. Keystrokes come from `osascript` so their exact moments are only known from the pixels.
- **a) idle:** with the pointer parked and never moved, only the pill shows: "Search or Ask" placeholder + caret on the
  left, mic glyph on the right. No mode icons, no suggestion rows, no panel below. Same in light and dark. In light over
  the white window the pill is dark (black at the top, grading lighter at the bottom).
- **b) hover:** the mode list is a separate rounded panel under the pill, with 4 rows: Applications ⌘1, Files ⌘2,
  Actions ⌘3, Clipboard ⌘4. It appears when the pointer **starts moving**, while the pointer is still far from the bar
  (first change 0.82 s light / 0.73 s dark, fully in by about 0.98 s / 0.93 s, so a fade / grow of about 0.2 s). It
  does **not** go away when the pointer leaves: it is still there at the end of the clip (about 1.5 s after the pointer
  left). With no pointer movement (a) it never shows.
- **c) clear:** the "te" results panel (Terminal row highlighted with "Search Terminal tab", TextEdit, TeraBox,
  TestFlight, more) stays while the field holds text. Field empty (placeholder back) at about 3.55 s light / 3.88 s dark.
  The panel then collapses to the bare pill: light from 3.80 s to 4.02 s (starts about 0.25 s after the field empties,
  about 0.22 s long); dark at about 4.45 to 4.52 s (about 0.6 s after the field empties; the 4.5 s frame shows a smaller
  empty panel shrinking under the pill). After that, only the bare pill until the clip ends (1 s later and more).

## R3.4 Volume HUD appear and fade: done
- `screens/27.2.1/panels/hud-volume-appear-grey-dark.mov`
- HUD: a capsule in the top-right corner under the menu bar (in the clip at about x 1123..1430, y 39..104 pt on screen),
  speaker glyph + 16-segment level. First HUD frame at 0.600 s, then continuous frames to 1.383 s, a pause, changes again
  1.567 s to 2.083 s (the fade), static after 2.083 s. So it is on screen about 1.0 s after the press, and the fade lasts
  about 0.5 s. `output volume` 81 -> 88 for one step (16 steps total), restored to 81.

## R3.5 Pop-up button menu open, choose, close: done
- `screens/27.2.1/controls/popup-menu-open-close-{dark,light}.mov` (pointer included, `-C`)
- Settings > Appearance > Text highlight colour (value Automatic, re-chosen, so nothing changed). The menu opens with the
  checked item over the button. Note: after switching Light/Dark, System Settings stopped reacting to synthetic clicks
  until it was relaunched, so it was relaunched before each clip. In the light clip the button shows its pressed state
  for a few frames before the menu appears.

## R3.6 Held switch strip, dark: done (frames from the round 2 clip)
- `screens/27.2.1/controls/switch-press-strip-dark.png`, built from `switch-held-stripes-dark.mov` frames (no new probe
  run). Press lands at 0.900 s (first change), the knob grows into the lens until 1.150 s (about 0.25 s), then static
  until the release at 2.000 s. The clip is 60 fps VFR, so every frame from 0.900 to 1.150 s is present (1/60 s apart);
  the strip uses every 2nd one.

## R3.7 Liquid Glass preview article: done (a, b, c)
- a) `screens/27.2.1/settings/appearance/preview-article-scroll-{00..11}-{light,dark}.png`: crop = window px 884,322
  536x360 = the scroll area (screen pt 792,311 268x180). 100 pt wheel steps; 12 stills per mode (00 top, 11 end).
- b) `re/27.2.1/live/settings/appearance/ax-preview-article-{top,end}-{light,dark}.jsonl`: one JSON object per AX
  element (depth-first, `path` = child indices), every attribute that has a value, plus `frame` [x,y,w,h] in screen pt.
  Scroll area: frame 792,311 268x180, **AXContentSize 268 x 1257.5**. A vertical AXScrollBar (overlay, 1042,362 19x114)
  is present. The first image's frame at the top is y 296.0 (and 297.8 in an earlier dump), 15 pt above the scroll area
  top, so the hero image is slightly taller / offset (stretch or parallax); at the end it is at y -780.
- c) Content in reading order (AX values verbatim; sizes in pt from the top dump, x relative to the scroll area):
  1. Image "Apple Park": x 0, 268 x 178.5 (full width hero)
  2. Text "Welcome to Apple Park" (x 16, 165.5 x 19, bold title)
  3. Text "Cupertino, California" (141 x 19, secondary)
  4. Text "Learn about the design and history of Apple Park, and discover its unique nature and beauty." (230.5 x 48)
  5. Image "The Architecture" (x 16, 236 x 157.5, rounded)
  6. Text "The Architecture" (123.5 x 19)
  7. Text "Apple Park was made for walking and exploring. The innovative design elements emphasise openness and
     connection to nature." (229.5 x 64)
  8. Image "The Pond" (236 x 157.5)
  9. Text "The Pond" (69 x 19)
  10. Text "With gently lapping waves and a surrounding of trees, it’s one of the most serene spots on campus." (217 x 48)
  11. Image "The Rainbow" (236 x 263.5)
  12. Text "The Rainbow" (94.5 x 19)
  13. Text "One of the most iconic features of Apple Park, the Rainbow brings much joy to all who experience it." (230 x 48)
  Vertical positions (top dump, screen y): hero 296.0, title 478.9, subtitle 501.9, intro 532.9, image 604.9, heading
  786.6, body 813.6, image 901.9, heading 1083.0, body 1110.0, image 1182.5, heading 1469.6, body 1496.6.
  Text is English (UK spelling "emphasise") because the system language is English (UK).

## R3.8a Appearance pop-ups up close: done
- `screens/27.2.1/settings/appearance/control-{text-highlight-colour,folder-colour,sidebar-icon-size}-{rest,hover,pressed,open}-{light,dark}.png`
- Appearance has 3 pop-up buttons (AX): Text highlight colour, Folder colour, Sidebar icon size. "Accent colour" is the
  row of colour swatches, not a pop-up. Pop-up sizes: 133x24 pt (with colour dot), 96x24 pt (Sidebar icon size).
- Menu windows (CGWindowList, layer 101, owner "Appearance"): 318x422, 296x422, 246x232 pt incl. shadow margin. The
  menu opens with the checked item over the button. "pressed" was taken 30 ms after mouse down, before the menu draws.

## R3.8b Settings panes: light done (dark next)
- `screens/27.2.1/settings/panes/{pane}-{NN}-light.png` for 21 panes, AX dumps at the top:
  `re/27.2.1/live/settings/panes/ax-{pane}-light.jsonl` (one JSON object per element, depth-first; role, subrole, title,
  value, description, help, identifier, enabled, selected, frame [x,y,w,h] screen pt, contentSize for scroll areas).
  Step counts and content sizes are in `screens/27.2.1/settings/panes/INDEX.md`.
- Pane names: "Control Center" is called **Menu Bar** in 27.2.1 (URL `com.apple.ControlCenter-Settings.extension`);
  "Apple Intelligence & Siri" shows as **Siri** here. Mouse: not present (no mouse connected), not captured.
- Blurred / filled: sidebar Apple Account + Family rows; Wi-Fi network and hotspot names; Bluetooth device names and the
  "discoverable as" line; VPN configuration names; Sound AirPlay device names. Same strings "[redacted]" in the AX dumps.

## R3.9 Sidebar scrolled under the search field: done
- `screens/27.2.1/settings/sidebar-scrolled-{1,2,5}-{light,dark}.png` (crop = window px 0,0 464x1250, i.e. the whole
  sidebar column), `sidebar-scroll-{light,dark}.mov`, AX `re/27.2.1/live/settings/ax-sidebar-scrolled-2-{light,dark}.jsonl`
  (window root + every sidebar element: search field, outline rows and cells, buttons; frames in screen pt).
- Geometry: search field 360,211 212x28 pt (window-relative 10,61); the sidebar scroll area starts at y 248 (window 98),
  so rows scroll up behind the field and the area above it (traffic-light strip). Row pitch 32 pt, account row 46 pt.
  At 1 row (32 pt) the account name sits under the field: it shows only as a faint blur through the glass.
- Privacy edits (see INDEX): account / Family rows filled below the field, blurred above it, left as is under the field.
  The clip was re-encoded (60 fps CFR) after the edit; the raw clip had VFR timing.
