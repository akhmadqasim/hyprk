# hyprk independent judge, round 5 (final, 2026-11-10 ~04:55)

Same rules as r1–r4 (strict, 80 = a casual Mac user mistakes it for macOS at a glance; self-scores ignored).
New shots: shell-final-*.png (04:37–04:51), plugin-cc-vs-ref.png (04:49). Settings, Finder, Qt and lock are unchanged
since r4 (04:24–04:28 shots).
Real-session check: ours/judge-r5-session.png (04:52), my own try-nested session with Ghostty open. I exited cleanly
and left no PIDs.

## Per-surface scores

| surface | our image | r4 | r5 | delta | notes |
|---|---|---|---|---|---|
| Desktop + menu bar + Dock | judge-r5-session.png, shell-final-desktop.png | 82 | 85 | +3 | Clock now `Tue Nov 10  4:52 AM` (macOS format). Left: no battery icon, Wi-Fi crossed out (no adapter in nested), and the Dock has only 7 items with non-Apple glyphs (Launchpad grid, blank notepad). |
| Control Center | plugin-cc-vs-ref.png, shell-final-control-center.png | 77 | 82 | +5 | Over the wallpaper it is now translucent and close to the ref, side by side: same grid, capsules, white glyph discs. Left: rims are thicker and cyan-tinted vs the ref's thin warm-white rim. Over a white window it still reads as a grey slab. No `recently used` pill. |
| Notification Center | shell-final-notification-center.png | 79 | 82 | +3 | The medium calendar (month grid + day + `No more events today`) matches the macOS medium Calendar widget, and the real photo widget looks right. Left: no event pills (no data), and `Featured Photo` is set in a heavier, tighter face than macOS. |
| Spotlight | shell-final-spotlight.png | 77 | 81 | +4 | Capsule query field, translucent frost, duplicate Terminal entry gone. Left: a full-width divider still runs under the capsule (redundant), there's no selection pill on the first result, and the panel is very tall for 5 results. |
| System Settings | settings-appearance.png | 86 | 86 | 0 | Unchanged: `Energy` instead of `Battery`. |
| Finder | finder-icons.png | 87 | 87 | 0 | Unchanged: synthetic demo thumbnails. |
| Windows / app theme | judge-r5-session.png, qt-*.png | 76 | 78 | +2 | Ghostty now has ~12 px padding, a content-coloured title bar and mac-order lights (real session verified). Left: Qt apps keep an in-window menu bar and text-only toolbar. GTK header-bar apps still use Adwaita-shaped buttons. |
| Lock screen | lockscreen.png | 83 | 83 | 0 | Unchanged. |

## Weighted overall

| surface | weight | r4 | r5 | r5 weighted |
|---|---|---|---|---|
| desktop + menu bar + Dock | 25 | 82 | 85 | 21.25 |
| Control Center | 10 | 77 | 82 | 8.20 |
| Notifications | 10 | 79 | 82 | 8.20 |
| Spotlight | 10 | 77 | 81 | 8.10 |
| Settings | 15 | 86 | 86 | 12.90 |
| Finder | 15 | 87 | 87 | 13.05 |
| windows / app theme | 10 | 76 | 78 | 7.80 |
| lock | 5 | 83 | 83 | 4.15 |
| **overall** | 100 | **81.5** | **83.7** | |

Score history: r1 71.8, r2 77.9, r3 80.4, r4 81.5, r5 83.7. Every surface is now at or above 78, and only the windows/app theme surface is below 80.

## Top 5 things still most unlike macOS (for follow-up)

1. **Third-party app chrome (themes/qt, themes/gtk)**: Qt apps show an in-window `File Edit View` menu and text toolbars.
   GTK header bars use Adwaita button shapes. This is the first thing that breaks the illusion once real apps are open.
2. **Icons (shell/, themes/icons)**: the Dock and Apps view show Linux app icons (Discord, btop, Foot, ImageMagick) and generic
   glyphs. macOS has a uniform squircle icon set. This is the biggest at-a-glance difference on a busy desktop.
3. **Glass rim (plugin/)**: the rim is thick and cyan on blue wallpaper. macOS uses a thin, neutral-white specular edge. Over white
   windows the CC tiles turn flat grey.
4. **Menu bar status (shell/)**: no battery item and a crossed Wi-Fi in nested sessions. On a real laptop, check that both look
   like the macOS glyphs.
5. **Small labels and content (settings/, finder/, shell/)**: `Energy` should be `Battery`, the Finder demo content is synthetic,
   Spotlight has a redundant divider under the capsule and no first-row selection, and the `Featured Photo` font weight is off.
