# System Settings panes, macOS 27.2.1 (round 3, R3.8b)

Display 1440x932 pt (2x). System Settings window at 350,150, default size 740x625 pt (sidebar 232 pt, content scroll
area 582,202 508x573 pt), relaunched after each appearance switch. Wallpaper TahoeLight / TahoeDark. Each pane opened by
its `x-apple.systempreferences:` URL, content scrolled to the top, then: AX dump + window shot `screencapture -x -o -l<id>`
(1480x1250 px, no shadow), one synthetic wheel step of -300 pt over the content (836,470), 1 s settle, repeat until the
AX text positions stop changing. Pointer parked at 1300,880 (outside the window) for every still.
`{pane}-00` = top; the last number = the end of the pane.

Privacy (found through the AX dump of every step, then hidden in the still at the element's frame):
- Sidebar: the Apple Account row (name, avatar) and the Family row (avatars) are filled with the sidebar colour.
- Wi-Fi: every network and hotspot name (connected, Personal Hotspots, Known, Other Networks) blurred.
- Bluetooth: every device name (My Devices, Nearby Devices) and the "This Mac is discoverable as …" line blurred.
- VPN: the VPN configuration names blurred.
- Sound: the two AirPlay output device names blurred.
- The same strings are replaced with "[redacted]" in every field of the AX dumps (titles, values, descriptions and
  identifiers such as `wifi-network-<name>-secure`).
Mouse: no mouse is connected, so the Mouse pane does not exist (its URL opens Keyboard): not captured.

| files | stills | content size (pt) |
|---|---|---|
| general-{00..02}-light.png | 3 | 740x936 |
| accessibility-{00..03}-light.png | 4 | 740x1362.5 |
| appearance-{00..04}-light.png | 5 | 740x1036.5 |
| siri-{00..02}-light.png | 3 | 740x964 |
| control-center-{00..05}-light.png | 6 | 740x1900.5 |
| desktop-dock-{00..04}-light.png | 5 | 740x1624.5 |
| displays-{00..01}-light.png | 2 | 508x210 |
| spotlight-{00..02}-light.png | 3 | 740x877.5 |
| wallpaper-{00..04}-light.png | 5 | 326x95 |
| notifications-{00..06}-light.png | 7 | 740x2292.5 |
| sound-{00..01}-light.png | 2 | 740x703.5 |
| focus-{00..01}-light.png | 2 | 740x581 |
| lock-screen-{00..00}-light.png | 1 | 740x565 |
| privacy-security-{00..05}-light.png | 6 | 740x1877 |
| wifi-{00..02}-light.png | 3 | 740x945.5 |
| bluetooth-{00..01}-light.png | 2 | 740x689.5 |
| network-{00..01}-light.png | 2 | 740x616 |
| vpn-{00..00}-light.png | 1 | 740x234 |
| battery-{00..01}-light.png | 2 | 740x639.5 |
| keyboard-{00..02}-light.png | 3 | 740x876.5 |
| trackpad-{00..00}-light.png | 1 | 740x371.5 |
