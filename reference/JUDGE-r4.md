# hyprk independent judge, round 4 (2026-11-10 ~04:35)

Same rules as r1–r3 (strict, 80 = a casual Mac user mistakes it for macOS at a glance; self-scores ignored).
All shots fresh: shell-final-*.png (04:31–04:32), settings-*.png (04:25–04:27), finder-*.png (04:28),
qt-kvantum-light / qt-qss-light / lockscreen.png (04:24), plugin-s8.png (04:30).
Judge shots (own try-nested session, exited cleanly, 0 leftover pids): ours/judge-r4-ghostty.png, ours/judge-r4-foot.png (04:33).

## Per-surface scores

| surface | our image | r3 | r4 | delta | what is still different |
|---|---|---|---|---|---|
| Desktop + menu bar + Dock | shell-final-desktop.png, judge-r4-ghostty.png | 82 | 82 | 0 | Clock still `Tue 10 Nov 04:31` (24h, day-month), not `Tue Nov 10  4:31 AM`. No battery icon. The Wi-Fi icon is crossed out (no adapter in nested). Dock size and glass are right. |
| Control Center | shell-final-control-center.png | 76 | 77 | +1 | Wi-Fi now `Off` with a white glyph disc, and a light rim on the tiles. The glass is still an opaque mid-grey slab (~(80,80,80)) with no frosted content showing through. The ref is a translucent, warm, lighter tile. No `recently used` pill. |
| Notification Center | shell-final-notification-center.png | 79 | 79 | 0 | Photo widget now a real photo (+). The calendar widget lost the mini month grid. It is now a large white card with only `No more events today` in the middle, so most of it is empty. The ref fills it with event pills. Net change 0. |
| Spotlight | shell-final-spotlight.png | 77 | 77 | 0 | Unchanged from r3. Neutral frosted results with a grey pill. The query has no capsule or tokens, the divider runs full width, and the result list includes Linux helpers (`Register TMOG with XScreenSaver`). |
| System Settings | settings-appearance.png (04:27) | 85 | 86 | +1 | Fixed: preview title is now the ref size, and `Local Account` replaces `Linux Account`. Left: `Energy` should be `Battery` on a laptop. An extra account row sits in the sidebar (the ref has none on this pane). Coloured vs grey icons depends on style, so this is acceptable. |
| Finder | finder-icons.png (04:28) | 87 | 87 | 0 | The dark thumbnails are gone. The demo content is still synthetic (stripe patterns as `.jpeg`), which reads as fake next to the ref's real photos. Chrome matches the ref. |
| Windows / app theme | judge-r4-ghostty.png, judge-r4-foot.png, qt-kvantum-light.png, qt-qss-light.png | 68 | 76 | +8 | Fixed: the plugin title bar samples the content colour (dark (40,44,52) on Ghostty, (36,36,37) on foot). The corner notches are gone: only a faint 1 px, 4-level line remains. Inactive windows show grey lights like macOS. Qt has an accent default button and no emoji. Left: 1) Terminal text is flush against the left edge (~2 px padding). macOS Terminal has ~8–10 px. 2) Qt in the rig still has an in-window `File Edit View` menu and plain-text `Back Forward Share` toolbar. 3) No shot here shows Qt with the plugin title bar after iteration 5 (dist-try-qt.png is 04:18). |
| Lock screen | lockscreen.png (04:24) | 81 | 83 | +2 | Placeholder is larger and the field is frosted. Left: no `Touch ID or Enter Password` hint. The date weight is a bit heavy. |

## Weighted overall

| surface | weight | r3 | r4 | r4 weighted |
|---|---|---|---|---|
| desktop + menu bar + Dock | 25 | 82 | 82 | 20.50 |
| Control Center | 10 | 76 | 77 | 7.70 |
| Notifications | 10 | 79 | 79 | 7.90 |
| Spotlight | 10 | 77 | 77 | 7.70 |
| Settings | 15 | 85 | 86 | 12.90 |
| Finder | 15 | 87 | 87 | 13.05 |
| windows / app theme | 10 | 68 | 76 | 7.60 |
| lock | 5 | 81 | 83 | 4.15 |
| **overall** | 100 | **80.4** | **81.5** | |

Target 80 met, this time on fresh shots for every surface. The margin is small. The heaviest surface (desktop, 25%) has
not moved since r3, so it is the cheapest place to gain.

## Top 6 remaining fixes

1. **shell/**: menu bar clock in macOS format (`Tue Nov 10  4:31 AM`, 12/24h from settings) plus battery icon. This is the desktop surface,
   weight 25.
2. **plugin/**: Control Center material should be translucent and lighter (content visible through frost, warm-neutral tint) instead of an opaque grey slab.
3. **shell/** (NC): restore the mini month grid, or add `Up next` event rows, so the calendar card is not mostly blank.
4. **shell/** (Spotlight/Apps): hide helper and NoDisplay-like entries (XScreenSaver hacks, Foot Client/Server). Give the query a
   capsule and an inset divider.
5. **themes/qt**: hide the in-window menu bar when the global menu bar is present, use icon toolbar buttons, and take a fresh
   dist shot of Qt with the plugin title bar.
6. **config/** (terminal defaults) + **settings/**: Ghostty/foot padding ~10 px (`window-padding-x`, foot `pad`).
   Rename `Energy` to `Battery` when a battery exists. **finder/**: real sample photos in the demo home.
