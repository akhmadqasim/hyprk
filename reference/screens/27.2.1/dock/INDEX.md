# Dock, Cmd-Tab, Mission Control, Apps (macOS 27.2.1)

MacBook Air M2, 1710 x 1107 pt, 2x unless noted. User account (not clean): Multicolour accent, icon style "Dark",
Dock tilesize 33, magnification off. Wallpapers: Tahoe Light / Tahoe Dark (system default pictures).
The WhatsApp badge count is pixelated for privacy in the Dock, Cmd-Tab and Mission Control shots.
Numbers: `reference/re/27.2.1/live/dock/*.json` and the Q-dock answers.

| File | What |
|---|---|
| dock-light.png, dock-dark.png | Dock alone, crop with 14 pt side and 10 pt top margin (crop origin 472,1040 pt; this Dock layout has a test app in the recent section). Sections: pinned apps, recent/running apps, Downloads stack + Bin |
| cmdtab-light.png, cmdtab-dark.png | Cmd-Tab with 11 apps, 2nd app (TextEdit) selected; crop = panel + 30 pt (crop origin 67,436 pt; panel 97,466 1516x176 pt). First icon is a test app with the generic icon |
| mc-light.png, mc-dark.png | Mission Control with 5 test windows, collapsed Spaces bar, Dock visible. 1x (1710x1107) to save space. In the light shot the Calculator window is hovered (outline + title chip) |
| mc-bar-expanded-light.png, mc-bar-expanded-dark.png | Spaces bar expanded by moving the pointer to the top (0,0 1710x190 pt) |
| mc-hover-light.png, mc-hover-dark.png | One hovered window in Mission Control: accent outline + centred title chip (crop 120,90 630x440 pt) |
| apps-light.png, apps-dark.png | Applications (Dock "Apps", `open -a Apps`): search capsule + panel with category chips, suggestions row, A-Z grid (crop 403,221 904x677 pt; window 433,251 844x617) |
| apps-category-light.png, apps-category-dark.png | Same after clicking the "Utilities" category chip |

## Round 2 (M1.4): Downloads stack, fan and grid (dark)
Display 1440x932 pt (2x), dark, wallpaper TahoeDark (`themes/wallpapers/heic/TahoeDark.heic`), other apps hidden,
desktop icons hidden. The real Downloads folder holds personal file names, so a temporary Dock stack labelled
"Downloads" (folder of 13 neutral dummy files + 1 folder, sort by Date Added, display as Stack) was added left of the
Trash for these shots and removed afterwards. Opened / closed by a synthetic click on the stack tile (982,905 pt).
Clips: `screencapture -x -v -R` (H.264, 60 fps time base, VFR: frames only while the screen changes). Stills:
`screencapture -x -R`.

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| stack-fan-open.mov | region 700,30 560x902 pt, 1.17 s | fan opens: 9 items + "5 More in Finder" arrow, tile turns into a chevron | dark | TahoeDark |
| stack-fan-close.mov | same region, 1.05 s | fan closes (second click on the chevron) | dark | TahoeDark |
| stack-fan-open-dark.png | same region | fan fully open | dark | TahoeDark |
| stack-grid-open.mov | region 480,300 960x632 pt, 2.0 s | grid opens: titled "Downloads" panel 5x3 + "Open in Finder", pointer arrow down to the chevron | dark | TahoeDark |
| stack-grid-close.mov | same region, 1.15 s | grid closes | dark | TahoeDark |
| stack-grid-open-dark.png | same region | grid fully open | dark | TahoeDark |
