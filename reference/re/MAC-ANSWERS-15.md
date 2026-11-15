# Answers from the Mac session, round 15 (macOS 27.2.1, 26B131, MacBook Air M2 15")

Request #178 from the PC: Settings > General > About, Storage, Software Update. Capture only, **nothing changed**.
Files under `re/27.2.1/live/settings-r15/` (`INDEX.md` there): `<name>-{dark,light}.png` (2x) and
`ax-<name>-{dark,light}.jsonl`. Window 740x625 pt at 350,150 on 1440x932; frames below are **screen points** (subtract
350,150 for window-relative). The device name, serial number, Apple Account address and app names are blurred /
`[redacted]`; the area outside the window and its child windows is masked grey.

## R15.1 About
- Whole pane: `about-00`, `-01`, `-02` (300 pt scroll steps; content is about 980 pt tall).
- Layout (AX): centred hero (laptop image, "MacBook Air" 759,354 154x31, "15-inch, M2, 2023" 14 pt line under it); one
  group with rows 37 pt apart: **Name** (editable text field 656,431 404x16, right-aligned), **Chip**, **Memory**,
  **Serial number** (values right-aligned to x 1060), **Coverage Expired** + "Details…" 984,575 76x24. Heading
  **macOS**: row with the OS icon, "macOS Golden Gate" and "Version 27.2.1" right; row "Intel-Based Apps" + subtitle +
  "Details…". Heading **Displays**: "Built-in Liquid Retina Display" / "15,3-inch (2880 × 1864)" + "Display
  Settings…" 132x24 below right. Heading **Storage**: "Macintosh HD" / "… GB available of 245,11 GB" + "Storage
  Settings…" 136x24. Then centred "System Report…" 124x24 and three centred small lines (11 pt): "Software Licence
  Agreement - Regulatory Certification", "ENERGY STAR® Compliance - Licence Agreement", "™ and © 1983-2026 Apple Inc.
  All Rights Reserved." (the four names are underlined links, AXStaticText).
- Destinations:

| control | opens | still |
|---|---|---|
| Coverage "Details…" | sheet **470x600** at 485,202 (taller than the window: it hangs 27 pt below the window's bottom edge). Title = device model, a "This Device" card, "Coverage Expired" text with check-mark lines and a link, "Get Support on Web" row with an arrow, small print, Done | `about--coverage-details` |
| Intel-Based Apps "Details…" | sheet **540x585** at 450,202: centred icon, title "Support Ending for Intel-Based Apps", text + "Learn more…", list "Additional apps and components" (icon + name rows), Done | `about--intel-apps-details` |
| Display Settings… | navigates to the **Displays** pane (title changes, Go Back returns) | not kept (same as the Displays pane) |
| Storage Settings… | navigates to **General > Storage** | not kept |
| System Report… | launches the **System Information** app (not pressed: it lists hardware identifiers) | — |
| Regulatory Certification | a **separate window** titled "Regulatory Certification" (about 600 pt wide, white page with the model's regulatory marks, over the Settings window; not a sheet) | `about--regulatory-certification` |
| Software Licence Agreement | opens `/Library/Documentation/License.lpdf` in **Preview** | — |
| ENERGY STAR® Compliance | opens "ENERGY STAR.pdf" in **Preview** | — |
| Licence Agreement | opens a **Finder** window on `/Library/Documentation` | — |

## R15.2 Storage
- Whole pane after calculating: `storage-00`, `storage-01`. While calculating: `storage-calculating` (the bar shows
  the already-known segments, then one grey "Calculating…" segment up to "Available"; rows without a size yet show a
  spinner (AXBusyIndicator 98x16) where the size goes, and the category list is still the long unsorted one). Here
  it finished in about 3 s.
- Header: volume name left (612,227), "193,3 GB of 245,11 GB used" right. **Bar 448x21 pt at 612,254**, segments in
  this order with 1 pt gaps, colours (px, dark / light):

| segment | dark | light |
|---|---|---|
| Applications | 235,83,78 | 235,76,70 |
| Documents | 240,151,72 | 240,147,67 |
| Photos | 248,216,73 | 247,206,70 |
| Mail | 104,206,103 | 101,196,102 |
| Developer | 99,215,195 | 90,197,179 |
| Music | 95,207,221 | 88,192,205 |
| System Data | 128,128,128 | 128,128,128 |
| macOS | 147,147,147 | 147,147,147 |
| Available (the free part, holds the "51,79 GB" label) | 66,67,72 | 214,214,214 |

  Legend under the bar: small coloured dots + names for the coloured categories and System Data (see the stills).
- **Recommendations** heading, then a card: icon, "Store in iCloud" + description, button "Store in iCloud…" 124x24.
- **Category list**: one group 468 pt wide, rows **43 pt** apart (inner row 454x28): icon, name (x 610), size
  right-aligned ending at x 1030, **ⓘ button 17x17 at x 1041.5** (AXButton "Show Detail"). Order: Applications,
  Developer, Documents, iCloud Drive, Mail, Music, Photos, Other Users & Shared, macOS, System Data (the last three
  have no ⓘ). Help button bottom right.
- **Bar hover tooltip**: `storage-bar-tooltip` (pointer included). A small bubble **121x77 pt window** centred above
  the hovered segment with an arrow pointing down: category name and size on two lines ("Applications" / "30,08 GB").
  The shot was taken 2.5 s after the pointer stopped; the exact delay was not measured.
- **ⓘ sheets**: `storage--applications-info` (sheet **650x490** at 395,217: icon, "Applications – 30,08 GB",
  description, "Open Applications" button top right; table with sortable headers Name (303 pt) / Kind (112) / Last
  Accessed (112) / Size (82), rows 24 pt with an 18 pt icon; "Show in Finder" and "Delete…" under the table, Done)
  and `storage--developer-info` (sheet **470x400** at 485,262: "Developer – 1,42 GB", "Manage in Xcode", table Name /
  Size, "Delete…", Done). App names are blurred.
- **All Volumes**: there is no such view or button here (one internal volume only).

## R15.3 Software Update
- **Checking**: `software-update-checking` (still) and `software-update-checking-{dark,light}.mov` (region 582,150
  508x330 pt, 60 fps VFR, pane opened about 1 s into the clip). Row "Checking for updates…" (612,224) with a 16 pt
  spinner at the right (1044,224); below it "Installed" / "macOS Golden Gate 27.2.1". The check took about 6 s in the
  dark run and under 1 s in the light run (cached), so the **dark clip is the one with the spinner**.
- **Idle, up to date**: `software-update-idle`. First row: green check badge, "Your Mac is up to date." with "macOS
  Golden Gate 27.2.1" under it, button "Check for Updates" right. Then rows "Automatic Updates … On ⓘ" and "Beta
  Updates … Off ⓘ" (value text right-aligned before the 17 pt ⓘ), then the centred licence line with a link, Help.
- **Automatic Updates ⓘ**: `software-update--automatic-updates-info`, sheet **470x274** at 485,325: switch rows
  "Automatically" header with "Download new updates when available", "Install macOS updates", "Install system data
  files and security updates"; Done.
- **Beta Updates ⓘ** (extra): `software-update--beta-updates-info`, sheet 470x284: "Beta Updates" + pop-up "Off",
  text + "Learn more…", an Apple Account line (blurred) and a link "Use a different Apple Account for beta updates…";
  Done.

## Restored and checked
Preview quit and the Finder window closed, System Settings quit, wallpaper store copied back, Stage Manager on,
desktop icons back, dark mode, display 1710x1107.
