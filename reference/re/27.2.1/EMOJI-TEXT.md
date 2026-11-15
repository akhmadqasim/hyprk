# Emoji in text (judge #19, Mac round 5 R5.3)

Sources: `reference/screens/27.2.1/panels/emoji-in-banner-{light,dark}.png` (banner from
`display notification "Emoji test 😀👍🏽🇮🇩 in the body" with title "hyprk 🇮🇩" subtitle "Round 5 👍🏽"`, 2 px per pt) and
`reference/screens/27.2.1/finder/emoji-in-name-{light,dark}.png` (list view, "Report 😀👍🏽🇮🇩.txt" selected, 2 px per pt).
Ours: headless session at scale 2 (scripts/smoke.sh, HYPRK_HEADLESS=1), the same banner text sent with
org.freedesktop.Notifications.Notify (summary "hyprk 🇮🇩", body as above; freedesktop has no subtitle line), and
hyprk-finder `--view list --select "Report 😀👍🏽🇮🇩.txt" --size 1000x360` on a scratch folder with the Mac's four files.
Ink found per column against a background interpolated across the line (max channel difference > 40); all numbers are
device px at 2x. Light and dark give the same numbers within 1 px.

## Mac (13 pt SF Pro text, both captures)

| measure | banner body | Finder name | how |
|---|---|---|---|
| text cap height ('E' / 'R') | rows 123-141, baseline 142 | rows 301-319, baseline 320 | ink rows |
| 😀 ink | 31 x 31, rows 117-147 (-25..+5 from the baseline) | 29 x 29, rows 296-324 (-24..+4) | |
| 👍🏽 ink | 29 x 31, one glyph | 30 x 33 (threshold), one glyph | skin tone sequence = one glyph |
| 🇮🇩 ink | 29 x 21, rows 122-142 (-20..0) | 29 x 21, rows 300-320 (-20..0) | flag = one glyph |
| emoji centre vs cap centre | 132 / 132 | 310 / 310 | centred on the cap height: 9.5-10 px = 0.36-0.38 x 26 px above the baseline |
| pitch 😀 -> 👍🏽 -> 🇮🇩 | 39, 38 | 38, 38 | ink starts |
| gap 't' -> 😀 ink (after a space) | 12 (313 -> 325) | | |
| gap 🇮🇩 -> next ink | 14 to 'i' after a space (430 -> 444) | 8 to '.' (290 -> 298), '.' -> 't' 6 | |
| colour | full colour on the white selected-row text too | same | |

Derived: emoji em = pitch / (1 + trak) with the ".Apple Color Emoji UI" face's `trak` (track 0: 112/800 at 17 pt)
-> 38.5 / 1.14 = 33.8 px = 16.9 pt = **1.3 x the 13 pt text**; 😀's art is 0.92-0.95 of its strike, so 31 px ink fits
(0.93 x 33.8 = 31.4). The original font has no such scale (hmtx 800/800, sbix bitmaps 1 em), so CoreText applies it
for UI text. Sharpness: at 33.8 px CoreText draws from the 40 px strike (down-scaled). Secondary-coloured text with an
emoji is in neither capture: whether CoreText fades the emoji with a translucent text colour is not measured.

## Ours before (themes/fonts/named/AppleColorEmoji.ttf, strikes 20-96, line = ppem + 1)

| measure | banner body | Finder name |
|---|---|---|
| 😀 ink | 22 x 23, rows 147-169 vs baseline 171 (-24..-2) | 22 x 23 (-24..-2) |
| 🇮🇩 ink | 22 x 16, -22..-7 | 22 x 16 |
| pitch | 23, 24 | 24, 23 |
| gap 't' -> 😀 / 🇮🇩 -> 'i' | 10 / 11 | |
| line end ('y' of "body") | 535 (Mac 578) | 'txt' end 205 from 'R' (Mac 238) |
| sharpness | 13 px text took the 20 px strike, drawn 24.8 px at 2x (x 1.24 up-scaled, soft) | same |
| colour emoji, skin tone and flag as one glyph | yes | yes, also on the selected row |

So the emoji were 0.71 of the Mac's size, sat on the baseline instead of the cap-height centre, had no tracking, and
were up-scaled.

## Fix (font, shipped by the repo)

`themes/fonts/tools/build-apple-color-emoji.py` (rebuilt `themes/fonts/named/AppleColorEmoji.ttf`, 64.8 MB, all 5,225
sequences still shape exactly as morx):
- `EM_SCALE = 1.3`: each strike's line (CBLC ascender - descender) is ppem / 1.3 (31, 40, 74 px). Qt scales a colour
  strike by pixelSize / line (ASSETS.md), so the emoji em is 1.3 x the text size.
- `CENTRE = 0.36`: the bitmaps move down so the 1 em box is centred 0.36 x the text size above the baseline (Mac 9.5-10
  of 26 px). Ascender = the UI face's 773/942 of the line, so the scaled line (0.82 / 0.18 of the text size) stays
  inside SF Pro's (0.97 / 0.21): lines with emoji keep their height and baseline.
- tracking: the UI face's `trak` at ppem / 2 pt (40 px strike: 110/800 -> 5.5 px) + 1 px, half before the art. The +1:
  Qt applies SF Pro's letterSpacing (Typography, -0.25 px at 13 px) to emoji too and lands advances on whole pixels;
  Finder pitches were 37/36 with 6 px, 37/38 with 7 px, 38/39 with 8 px against the Mac's 38/38.
- strikes 40, 52, 96 only (20, 26, 32 dropped): Qt picks the smallest strike whose line is >= the logical pixel size,
  so 13 px text now takes the 40 px strike, drawn at 33.5 px at 2x (down-scaled, as on the Mac).
- pango/HarfBuzz (GTK apps) keep the hmtx advance (1 em); there the centring moves the emoji 0.22 em down (centre
  0.28 x the text size above the baseline). Rendered with pango-view: inline and in colour.
- Emoji & Symbols picker (`shell/Theme.qml` emoji.glyphSize 32.8 -> 24.8): 32.8 / 41 and 24.8 / 31 are the same 0.8
  scale of the same 40 px strike, so the faces keep their size (yellow ink 58 px by a yellow mask, centre row 894.5
  as before). New `glyphOffsetX` 1.25 pt: the uneven tracking (3 + 4 px) left the faces 2.5 px left of the cell
  centre (1023.5 against 1026); after it 1026.5.
- The character right after an emoji (`config/fontconfig/emoji.conf`, `fonts.conf`, `themes/fontconfig/60-hyprk-sf.conf.in`):
  Qt 6.10 takes it from the emoji family's fallbacks, which were Noto Color Emoji then Noto Sans, so the '.' of
  "🇮🇩.txt" was Noto Sans' wider dot (flag -> '.' 11 px, '.' -> 't' 10 px; Mac 8 and 6; also before this change). A rule
  appends SF Pro after "Apple Color Emoji" when that is the first family (Qt's query for the emoji font's fallbacks);
  monospace and the other generic families keep theirs (fc-match -s monospace unchanged: SF Mono, Apple Color Emoji,
  DejaVu Sans Mono). After: 7 and 6 px ("🌅.png": 6 and 8 against 7 and 7).

## Ours after

| measure | Mac | ours after |
|---|---|---|
| banner 😀 ink, x / rows vs baseline | 31 x 31, 325-355, -25..+5 | 31 x 31, 325-355, -25..+5 |
| banner 👍🏽 x | 364-392 | 363-391 |
| banner 🇮🇩 ink, rows vs baseline | 29 x 21, 402-430, -20..0 | 31 x 21, 400-430, -20..0 |
| banner gap 't' -> 😀 / 🇮🇩 -> 'i' | 12 / 14 | 12 / 14 (325 and 444 both) |
| banner line end | 578 | 576 |
| banner title 🇮🇩 rows vs baseline (semibold) | -20..0 | -20..0 |
| Finder pitches | 38, 38 | 37, 38 |
| Finder 😀 / 🇮🇩 from 'R' | 90-118 / 166-194 | 90-120 / 165-195 |
| Finder rows vs baseline | -24..+4 / -20..0 | -25..+5 / -20..0 |
| strike at 13 pt, 2x | 40 px down-scaled | 40 px x 0.84 |
| skin tone / flag one glyph, colour on the selected row | yes | yes |
| Finder 🇮🇩 -> '.' -> 't' (ink starts) | 8, 6 | 7, 6 |
| Finder name end ('txt') from 'R' | 238 | 238 |

Plain text unchanged: banner 'E'...'t' at 198-313 before and after, title -> body baseline pitch 34 px (Mac 34),
Finder "Notes.txt" ink identical. Tests: shell 403, finder 33, ui 98 pass.

## Secondary text (R6.5, OPEN-FIXES.md 16): done

Mac (`screens/27.2.1/finder/emoji-secondary-{list,menu}-{light,dark}.png`): the list name is labelColor (.85), yet the
emoji's inner pixels are the same in light and dark (795 px, mean 0.05, max 1): CoreText draws colour emoji at alpha 1
whatever the text colour's alpha. Qt's GPU text path multiplied them by it (0.850 in a label, 0.5 in secondary text);
the software scene graph does not (offscreen tests cannot show it).

Fix: `ui/HyprK/emojitext.js` (`EmojiText`): `opaque(s, color)` returns `s` without emoji (the Text stays
`Text.PlainText`), else StyledText with each emoji run in `<font color>` at the text colour's RGB and alpha 1, the rest
escaped so it lays out like the plain string (`&#32;` / `&#9;` for whitespace, which StyledText would collapse, `<br>`
for newlines; widths, line counts and ElideMiddle pixels equal, ui/tests/tst_emojitext.qml). `wrap(styled, color)` does
only the runs, for the tagged icon label. Bound as `text: EmojiText.opaque(x, color)` + `textFormat: EmojiText.has(x) ?
Text.StyledText : Text.PlainText` in the Finder list / column / icon / gallery names, path bar, menu items, Get Info,
tag popover and rename example, the Spotlight row subtitle and the notification summary / body (OPEN-FIXES.md 16 has
the lines).

| inner emoji pixels, light vs dark (headless, scale 2) | Mac | ours before | ours after |
|---|---|---|---|
| Finder list name "Trip 😀👍🏽🇮🇩.txt" | 795 px, mean 0.05 | 819 px, mean 33.7 | 844 px, 0.0 |
| menu item with the name | 1169 px, 0.0 (highlighted) | 775 px, 29.0 | 812 px, 0.0 |
| notification summary / body | | | 682 / 1115 px, 0.0 |

Emoji alpha before, against after: 0.850 (list and menu). Plain text unchanged: rows without emoji, "Trip" / ".txt",
the header and the Date / Size / Kind columns within 1 level, the noise of two runs of one build.

## Left over

- Sizes other than 13 pt are not measured; the 52 and 96 px strikes follow the same rule. At exactly 31, 40 and 74 px
  text Qt still skips the scaling (half-size emoji at DPR 2), as it did at 21, 27, 33, 41, 53 and 97 px before.
- The banner's subtitle line ("Round 5 👍🏽") has no freedesktop counterpart, so it was not compared.
- Emoji runs: a bare BMP symbol that SF Pro lacks and that is not Emoji_Presentation (✔ U+2714, ❤ U+2764 and ☀ U+2600
  without VS16) still comes from Apple Color Emoji in colour and keeps the label's alpha; the Mac would take a text
  font for them (not measured). A keycap (1️⃣) is not wrapped either. Spotlight subtitles were not shot on screen.
