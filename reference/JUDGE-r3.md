# hyprk independent judge, round 3 (2026-11-10 ~04:20)

Same rules as JUDGE.md and JUDGE-r2.md: strict, 80 = a casual Mac user mistakes it for macOS at a glance. I ignored the owners' self-scores.

Shots used: ours/shell-final-*.png (04:03, 2560x1664), shell-4k-*.png (04:18, 3840x2160), dist-try-ghostty.png and
dist-try-qt.png (04:18), dist-try-adw.png (04:00), gtk-tabs-*/gtk-ghostty-dark/lockscreen.png (04:02).
**Stale:** settings-*.png (03:53) and finder-*.png (03:54) predate r2, so no iteration-3 shots exist for Settings or Finder.
I judged them from those files, plus Settings and Finder as they appear inside shell-final-* (04:03). Their scores are
carried over from r2 until fresh shots exist.

## Per-surface scores

| surface | ref image | our image | r2 | r3 | delta | top 3 concrete differences still left |
|---|---|---|---|---|---|---|
| Desktop + menu bar + Dock | screens/macos27-desktop-menubar-dock.jpg, macos27-apps-view.png | shell-final-desktop.png, shell-4k-desktop.png, dist-try-ghostty.png | 80 | 82 | +2 | Fixed: Dock icon now ~2.5–2.9% of screen width (ref 2.7%). Left: 1) Clock still `Tue 10 Nov 04:18` (24h, day before month), not `Tue Nov 10  4:18 AM`, and still no battery icon. 2) The Dock has two near-identical terminal icons (Terminal and Ghostty). The Text Editor tile looks like a blank sheet. 3) The menu bar on 4K is very small (scale 1.5 nested), which is correct for scale but reads tiny in shots. |
| Control Center | screens/macos27-control-center.png | shell-4k-control-center.png, shell-final-control-center.png | 75 | 76 | +1 | Display slider now shows a full track. Left: 1) Wi-Fi still greyed `Not Available`. 2) The glass is a uniform dark grey (~(91,96,100)) with no lighter rim or refraction. The ref is a warmer, more translucent frosted tile with a bright rim. 3) No `recently used` pill above the grid. The media tile artwork is cropped small next to the ref's large `Not Playing` tile. |
| Notification Center | screens/macos27-notification-center.png | shell-final-notification-center.png, shell-final-banner.png | 75 | 79 | +4 | Fixed: the calendar widget is opaque white. Banners use a real app icon (Messages). The Edit Widgets pills are visible. Left: 1) The left half of the calendar is still empty (`No events today`). The ref shows coloured event pills. 2) The photo widget is just the wallpaper with a heavy `Featured Photo` label, and the ref uses a real photo with a play button. 3) The widget column overlaps the open Settings window with no dimming. That is correct macOS behaviour, but the clock widget's black square sits hard against white. |
| Spotlight (+ Apps) | screens/macos27-spotlight.png, macos27-apps-view.png | shell-final-spotlight.png, shell-4k-spotlight.png, shell-final-apps.png | 74 | 77 | +3 | Fixed: the results glass is now neutral frost (no cyan smudges). Left: 1) The empty-query bar (4K shot) is a heavy mid-grey capsule (~(150,150,150) look) with a dark rim, and the ref field is light, warm and translucent. It also sits on top of the Finder toolbar instead of around 1/4 down the screen. 2) The query has no tokens or capsule, and the divider runs full width. 3) The Apps view still lists Linux helper entries and icons. |
| System Settings | screens/macos27-system-settings-appearance.webp | settings-appearance.png (stale 03:53), shell-final-desktop.png | 85 | 85 | 0 | No new shot. Same remaining issues as r2: the `Linux Account` row, `Energy` instead of `Battery`, and an oversized `Default Aerial` preview title. In-session the window renders correctly with its own traffic lights. |
| Finder | screens/macos27-finder-window.png | finder-icons.png (stale 03:54), shell-4k-desktop.png | 87 | 87 | 0 | No new shot. Same as r2: synthetic thumbnails and a few dark image thumbnails. In-session at 4K it looks right (sidebar, toolbar, folder colour). |
| Windows / app theme | Finder + Settings refs | dist-try-ghostty.png, dist-try-qt.png, dist-try-adw.png, gtk-tabs-light.png | 58 | 68 | +10 | Fixed: the plugin title bar gives Ghostty and Qt left-side traffic lights in mac order with a centred title, and the Adwaita dialog has proper lights. Left: 1) Seam: Ghostty content keeps its own ~10 px top corner radius under the plugin title bar, so title-bar-coloured (243,241,239) notches show at both top corners (measured at x 240–250, y 50–57). Terminal text also sits flush against the left edge (2 px). 2) Qt content is still Fusion-like, with emoji icons on OK/Cancel/Apply, a legacy `Preview Window` and plain tabs. 3) Light title bar over dark terminal content. macOS Terminal would use a dark title bar for a dark profile. In GTK tab/gallery shots the yellow and green lights are pale (look unfocused) while red is full. |
| Lock screen | none | lockscreen.png | 78 | 81 | +3 | Fixed: monogram avatar `AQ`, clock halo gone, narrower field. Left: 1) The password field placeholder is tiny (~11 px) and grey, and macOS uses a larger placeholder with a frosted field. 2) The date weight is slightly heavier than macOS. 3) No `Touch ID or Enter Password` hint or bottom controls. |

## Weighted overall

| surface | weight | r2 | r3 | r3 weighted |
|---|---|---|---|---|
| desktop + menu bar + Dock | 25 | 80 | 82 | 20.50 |
| Control Center | 10 | 75 | 76 | 7.60 |
| Notifications | 10 | 75 | 79 | 7.90 |
| Spotlight | 10 | 74 | 77 | 7.70 |
| Settings | 15 | 85 | 85 | 12.75 |
| Finder | 15 | 87 | 87 | 13.05 |
| windows / app theme | 10 | 58 | 68 | 6.80 |
| lock | 5 | 78 | 81 | 4.05 |
| **overall** | 100 | **77.9** | **80.4 (80)** | |

80 is reached, but only just, and two of the heavy surfaces (Settings, Finder) were not re-shot. A regression in either
would drop the total below 80. Re-shoot them before claiming the target.

## Top 8 remaining fixes (ranked by impact)

1. **plugin/** (+ **themes/gtk**): when the plugin title bar is on, force square top corners on client content (GTK CSS
   `window.csd { border-radius: 0 0 R R }` or clip the client's top corners in the plugin) to remove the notches.
   Add a dark title bar variant when the client's top row is dark (Ghostty dark profile).
2. **shell/**: menu bar clock in macOS format (`Tue Nov 10  4:18 AM`, honour 12/24h setting) plus battery icon.
3. **themes/qt**: drop emoji/standard icons on dialog buttons, accent default button, flatter tab bar. Make Qt dialogs
   look like the GTK ones.
4. **plugin/** + **shell/** (Spotlight): light translucent field material for the empty query bar. Place it at ~22% of
   screen height, not over the window toolbar.
5. **plugin/** (CC material): lighter, warmer frost with a visible rim. Now it reads as a flat dark grey slab.
6. **shell/** (NC): event list or `Up next` on the left of the calendar widget. Real photo for the photo widget.
7. **settings/** + **finder/**: deliver fresh iteration-3 shots, then fix `Linux Account`, `Energy`→`Battery`, the oversized
   preview title, and the dark image thumbnails.
8. **shell/** (Dock/Apps): dedupe the Terminal/Ghostty and Foot helper entries, map more apps to macOS-style icons.
   **lockscreen/**: larger placeholder and frosted field.
