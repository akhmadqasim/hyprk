# Window surfaces against the Mac (re20, 2026-11-12)

Headless session, scale 2, Finder `--size 920x560` icon view on a scratch folder, Settings 740 x 625 (Appearance and
Desktop & Dock panes), dark and light. Mac shots are 2 px/pt like ours; colours P3-converted (`p3_to_srgb`).
Levels are sRGB 0..255, positions in pt from the window's top-left.

## Ranked differences
1. FIXED. Settings sidebar fill, key window: Mac dark (34,38,53) uniform, light (236,237,238) (`settings/appearance-*.png`, Q-settings-01); ours dark (34..39, 38..40, 68..77), light 210..235 (88 % over blurred Tahoe + chameleon on a colour that already holds it) → now (35,38,52) / (235,237,239) everywhere.
2. FIXED. Settings toolbar title, window not key: Mac ink 91..93 dark, 189 light (`settings/desktop-dock-inactive-*.png`, Q-settings-06 #5C5D5E / #BDBDBD); ours 232 / 76 → 92 / 189.
3. FIXED. Settings rows with only a switch: Mac 37.5 pitch (`settings/desktop-dock-dark.png` separators 366.5 / 404 / 441.5; `ax-desktop-dock-dark.jsonl` labels 572.2 / 609.7 / 647.2 / 684.7); ours 38 (FormRow tested children[0], the value Text) → 37.5; card 3 top 541 → 538.5 (Mac 536.5).
4. OPEN. Settings dark, window not key: content background Mac (37,38,39), cards (36,37,39) (`settings/desktop-dock-inactive-dark-iconDark.png`); ours (30,31,36) / (37,38,43). Light matches (255 / 247). One Mac shot only: wants a second capture before changing.
5. OPEN (re-measured by re21). Settings Desktop & Dock: the card-to-card gap is 10 on both (edges at x 700 pt: Mac 159 / 169 and 320 / 330, ours 159 / 169 and 320.5 / 330.5; `settings/desktop-dock-{dark,light}.png`, dark and light the same), so the 13 vs 14 above was not a gap. The drift is the first row of each card: the Mac's has no separator and is 1 pt shorter (card 2 rows 37 / 38.5 / 38 / 37.5, card 3 36.5 / 37.5 / 37.5 / 37.5), ours takes the full 38 / 37.5 (card 2 38 / 38 / 38 / 37.5, card 3 37.5 x 4): card 2 bottom 320.5 vs 320, card 3 330.5..480.5 vs 330..479, the next heading's card 536.5 vs 535. Not one constant: FormRow's first row would lose 1 pt in every pane, and Appearance's card heights (Appearance.qml header) were fitted with the current rows, so it wants all panes re-checked.
6. OPEN. Settings dark search capsule: Mac (81,86,105) (`settings/appearance-dark.png`), ours (82,84,95) (was (82,81,111) over the old translucent sidebar); a white 21 % fill cannot add the blue. Light (233,234,235) vs (231,233,235).
7. OPEN. Settings sidebar over wallpapers other than Tahoe: now flat in dark / 5 % chameleon in light; the Mac over a plain desktop reads (37,38,38) dark (`settings-toolbar-dark.png`), so ours may be up to ~15 levels off in blue elsewhere. Needs Mac captures over other wallpapers.
8. OPEN. Finder inactive title: Q-finder-06 says #BFBDBD light (ours 189..191 on white) but `windows/finder-toolbar-light-inactive.png` reads 130 over blurred content (Q-windows-25 "58 → 129"). Sources disagree: needs a Mac shot of an inactive Finder over plain content.

## Checked, no difference (≤ 1 pt / ≤ 4 levels)
- Traffic lights in Finder and Settings: centres x 25.75 / 48.75 / 71.75, y 25.75, 14 pt (`finder/icons-dark.png`, `settings/appearance-dark.png`).
- Finder: sidebar (36,38,55) vs (36,37,54) dark, (237,237,238) vs (236,237,238) light; content (31,31,37) vs (31,31,38); title ink 233 / 76 vs 232 / 77; sidebar divider x 158.5; sidebar rows to Applications 0..0.4 pt; inactive sidebar light (242,242,243) vs Q-windows-25 #F1F1F2.
- Settings: divider x 231.5; content (30,31,36) vs (31,31,36); cards (37,38,43) both; selection (6,125,255) vs (0,122,255); inactive sidebar (36,38,43) / (242,242,242) and pill (50,52,57) / (231,231,231) exact.

## Not compared
Window shadows and rims (plugin), resize edges, traffic-light hover / press / Option states, Finder list / column / gallery views, popovers, sheets, alerts, scale 1.6.
