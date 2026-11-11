pragma Singleton

import QtQuick
import Finder.Native
import HyprK
import "../../ui/HyprK/chameleon.js" as Ch

// Every metric and color of the Finder window, in pt (1 pt = 1 logical px; HiDPI is the output scale, as for
// the shell and Settings). "27.2.1" = measured on reference/screens/27.2.1/finder-toolbar-{light,dark}.png (2x)
// or the toolbar probe dumps (reference/re/27.2.1/live/toolbar). "ref / 1.22" = measured on
// reference/screens/macos27-finder-window.png, which is drawn at about 1.22 px per pt (its 44 px toolbar
// capsule is the 36 pt capsule measured on 27.2.1), converted to pt. Shared values come from the HyprK
// Tokens, Typography and Accent (ui/HyprK), which this Theme feeds with the Finder's appearance.
QtObject {
    id: theme

    property bool dark: false
    // the window is key (set by Main: Window.active, or --inactive for screenshots); inactive colours follow
    property bool active: true
    // normalized state/appearance.json (Main.qml follows the file): accent, sidebar icon size, accessibility
    property var appearance: ({})
    readonly property string sidebarSize: appearance.sidebarIconSize || "medium"
    // Appearance > "Tint window background with wallpaper color" (default on, as on the Mac)
    readonly property bool tintWindow: appearance.tintWindowBackground !== false
    // sidebar chameleon tint (MAC-ANSWERS.md C3.1): mean wallpaper colour from Main's WallpaperTint
    property var chameleon: null
    function chameleonOf(c) {
        c = Qt.lighter(c, 1);   // a colour, also when given "#RRGGBB"
        const o = active && tintWindow ? Ch.apply(c, chameleon, dark) : null;
        return o ? Qt.rgba(o.r, o.g, o.b, c.a) : c;
    }
    Component.onCompleted: {
        Tokens.dark = Qt.binding(() => theme.dark);
        Tokens.reduceTransparency = Qt.binding(() => theme.appearance.reduceTransparency === true);
        Tokens.increaseContrast = Qt.binding(() => theme.appearance.increaseContrast === true);
        Tokens.reduceMotion = Qt.binding(() => theme.appearance.reduceMotion === true);
        Accent.name = Qt.binding(() => theme.appearance.accent || "multicolor");
        // Appearance > Text highlight colour ("" = Automatic: follows the accent). AppKit's highlight key decides
        // selectedTextBackgroundColor and selectedControlColor only (reference/re/27.2.1/live/accent-colors.json:
        // highlightColor.tests, e.g. accent Purple + highlight Blue -> #B3D7FF / #3F638B; the two colours are equal
        // in all 9 accents), so here it reaches the text selections (Theme.color.textSelection / Accent.selectedText:
        // rename field, search field, rename sheet, tag field, Quick Look text). Selected icons and rows are
        // selectedContentBackgroundColor, a colour of the accent: they do not follow it.
        Accent.highlight = Qt.binding(() => theme.appearance.highlight || "");
        Tokens.fontText = Qt.binding(() => theme.fontText);
        Tokens.windowActive = Qt.binding(() => theme.active);
    }
    // No compositor blur behind the window (plain GNOME, offscreen) -> solid sidebar.
    // Set HYPRK_BLUR=1 (Hyprland with a blur windowrule) to get the translucent sidebar.
    property bool blur: false

    // ---------- macOS file icons (themes/icons/system), "" = use the drawn fallbacks ----------
    property bool hasSysIcons: false
    // tag: a colour ("#RRGGBB") that tints a folder (a tagged folder: Theme.color.tagFolderColors)
    function sysIcon(name, px, tag) {
        return !hasSysIcons ? "" : "image://sysicon/" + (tag ? "tag/" + tag.slice(1, 7) + "/" : "") + name + "@" + px;
    }
    // folders that get their own icon, by absolute path
    readonly property var folderIcons: {
        const m = {};
        const special = [["desktop", "DesktopFolderIcon"], ["documents", "DocumentsFolderIcon"],
                         ["downloads", "DownloadsFolder"], ["pictures", "PicturesFolderIcon"],
                         ["music", "MusicFolderIcon"], ["movies", "MovieFolderIcon"]];
        for (const [key, icon] of special) m[FileOps.standardPath(key)] = icon;
        m[FileOps.homePath() + "/Public"] = "PublicFolderIcon";
        m[FileOps.homePath() + "/Library"] = "LibraryFolderIcon";
        // last, so an XDG dir disabled by pointing it at $HOME can't take the home icon
        m[FileOps.homePath()] = "HomeFolderIcon";
        return m;
    }

    // ---------- fonts (fallback chain in FALLBACKS.md) ----------
    readonly property var _families: Qt.fontFamilies()
    function pickFont(list) {
        for (const f of list)
            if (_families.indexOf(f) !== -1)
                return f;
        return list[list.length - 1];
    }
    readonly property string fontText: pickFont(["SF Pro Text", "SF Pro", "System Font", ".SF NS", "Inter", "Cantarell", "Sans Serif"])
    readonly property string fontMono: pickFont(["SF Mono", ".SF NS Mono", "JetBrains Mono", "DejaVu Sans Mono", "Monospace"])

    // Text sizes in pt; the fonts themselves come from HyprK Typography (TextLabel, or font: Typography.font(pt)).
    readonly property QtObject font: QtObject {
        readonly property real title: 15           // toolbar title: Typography.toolbarTitle, 15 Semibold (Q-finder-06)
        // Q-finder-07: 13 Regular, the selected row 13 Semibold (medium); small / large 11 / 15 as every AppKit
        // source list at that Sidebar icon size (Q-settings-01, measured in System Settings)
        readonly property real sidebarItem: theme.sidebar.fontSize
        readonly property real sidebarHeader: 11   // Q-finder-07: 11 Semibold
        readonly property real label: 12           // icon label: 12 Regular, line pitch 16 (Q-finder-14)
        readonly property real list: 13            // list and column rows: 13 Regular (Q-finder-15)
        readonly property real listHeader: 11      // Q-finder-17: sorted 11 Semibold, others 11 Regular
        readonly property real pathBar: 11         // Q-finder-22: 11 Regular
        readonly property real preview: 13
        readonly property real small: 11           // gallery / preview info rows (Q-finder-19/20)
    }

    // ---------- colors ----------
    // Q-finder-NN = reference/re/MAC-ANSWERS.md, measured on 27.2.1 (2x captures, Multicolour accent). The dark
    // sidebar and content were captured over the Electric Blue wallpaper; the sidebar glass takes its tint.
    readonly property QtObject color: QtObject {
        readonly property bool blueAccent: Accent.name === "multicolor" || Accent.name === "blue"
        // AppKit label hierarchy (Tokens)
        readonly property color label: Tokens.label
        readonly property color secondaryLabel: Tokens.secondaryLabel
        readonly property color tertiaryLabel: Tokens.tertiaryLabel
        readonly property color separator: theme.dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.10)
        // Finder has no accent of its own: Blue #007AFF under Multicolor (accent-colors.json), the user's accent otherwise
        readonly property color accent: Tokens.accent
        // rename field: the selected base name. Q-finder-27's (186,214,251) is a Display P3 reading = #B3D7FF in sRGB,
        // the catalog selectedTextBackground (reference/ours/COLOUR-P3-AUDIT.md)
        readonly property color textSelection: Accent.selectedText

        // the content background. Dark: (31,31,37) in every view's 27.2.1 shot (icons / list / columns / gallery-dark.png,
        // over TahoeDark, as the sidebar's measured colour); the shared token's 30 grey is not measured
        readonly property color window: theme.dark ? Qt.rgba(31 / 255, 31 / 255, 37 / 255, 1) : Tokens.windowBackground
        // sidebar (Q-finder-03/07/08/09): fill, text, headers, icons; a = key window, i = inactive
        // key window: + the chameleon layer (5 % light colour blend); the inactive sidebar is flat. Dark: the measured
        // (36,38,55) already holds the wallpaper's tint: over TahoeDark the Mac shows (36,37,53) active (list-dark.png)
        // and (36,38,55) / (36,38,54) active / inactive (crops/sidebar-top-dark-*), while the 10 % layer on top made it
        // (36,37,62); so dark takes the measured colour as it is
        readonly property color sidebarSolid: theme.dark ? "#242637" : theme.chameleonOf(theme.active ? "#EDEDEE" : "#F2F2F3")
        // over compositor blur: the sidebar glass fill colour (LIVE-27.2.1.md Sidebar, glass-table-dark.txt)
        readonly property color sidebarGlass: theme.chameleonOf(theme.dark ? Qt.rgba(0.15, 0.15, 0.15, 0.75) : Qt.rgba(0.87, 0.88, 0.91, 0.7))
        readonly property color sidebarSelection: theme.dark ? (theme.active ? "#414354" : "#323443")
                                                             : (theme.active ? "#D7D7D8" : "#E7E7E8")
        // drop target pill, white text: Q-finder-09 (47,110,237) is a Display P3 reading, #0070F5 in sRGB
        readonly property color sidebarDrop: "#0070F5"
        readonly property color sidebarText: theme.dark ? (theme.active ? "#FFFFFF" : "#92939B") : (theme.active ? "#000000" : "#717171")
        readonly property color sidebarHeader: theme.dark ? Qt.rgba(1, 1, 1, theme.active ? 0.35 : 0.23)
                                                          : Qt.rgba(0, 0, 0, theme.active ? 0.43 : 0.30)
        // Recents, Shared and Favourites: accent; Locations: grey; all grey while inactive. Blue: Q-finder-08 reads
        // (30,152,255) dark / (0,107,239) light in Display P3 = #009BFF / #006DF8 in sRGB
        readonly property color sidebarIconAccent: !theme.active ? sidebarIconInactive : blueAccent ? (theme.dark ? "#009BFF" : "#006DF8") : accent
        readonly property color sidebarIconGrey: !theme.active ? sidebarIconInactive : theme.dark ? "#B5B5C3" : "#7B7B80"
        readonly property color sidebarIconInactive: theme.dark ? "#8F909B" : "#7F7F7F"

        // toolbar capsules: HyprK ToolbarPlatter (Tokens.toolbar, measured on 27.2.1)
        // the view switcher's selected segment: light 229..232 on the 249..253 face (crops/toolbar-light-active.png), 220 on
        // 240 inactive; dark as Tokens (82 on 61)
        readonly property color capsuleSelected: theme.dark ? Tokens.toolbar.selection : Qt.rgba(0, 0, 0, 0.082)
        // inactive window: the capsule darkens 252 -> 240 | (61,62,70) -> (58,60,67) (Q-finder-29)
        readonly property color capsuleInactive: theme.dark ? "#3B3B3B" : "#F0F0F0"   // flat face (Capsule.qml)
        // hover / pressed inner capsule: 242 on 252 (Search 236) | (87,89,96) on (67,69,77) (Q-finder-10)
        readonly property color toolbarHover: theme.dark ? Qt.rgba(1, 1, 1, 0.106) : Qt.rgba(0, 0, 0, 0.04)
        readonly property color searchHover: theme.dark ? Qt.rgba(1, 1, 1, 0.106) : Qt.rgba(0, 0, 0, 0.064)
        // Quick Look panel (live/finder/crops/quicklook-titlebar-light.png, 2x): frame 136 (134-138 top to bottom), discs
        // and button glyphs 6-8, title and "Open with" text 36-41 at the stroke cores. Dark: not measured, so the same
        readonly property color quickLookFrame: "#888888"
        readonly property color quickLookInk: "#070707"
        readonly property color quickLookText: "#282828"
        readonly property color toolbarSeparator: Tokens.toolbar.separator
        // glyphs: light 0, inactive 164 (Q-finder-29); dark white (the ellipsis dots and list bullets reach 255 on the 61
        // face), inactive 111 on 60 (crops/toolbar-dark-{active,inactive}.png)
        readonly property color toolbarIcon: theme.dark ? Qt.rgba(1, 1, 1, theme.active ? 1 : 0.26) : theme.active ? "#000000" : "#A4A4A4"
        // disabled: light 173 on 252, dark (113,114,122) on (61,62,70) (Q-finder-10); inactive light 176 on 240, dark 98 on 60
        readonly property color toolbarIconDisabled: theme.dark ? Qt.rgba(1, 1, 1, theme.active ? 0.27 : 0.195)
                                                                : Qt.rgba(0, 0, 0, theme.active ? 0.31 : 0.267)
        // the Search glyph is fainter than the others: light 74 on 249 / inactive 175 on 240, dark 236 on 61 / inactive
        // 126 on 60 (crops/toolbar-*: the magnifying glass's darkest / lightest pixel; its ink is .70 of the black one)
        readonly property color searchIcon: theme.dark ? Qt.rgba(1, 1, 1, theme.active ? 0.90 : 0.34)
                                                       : Qt.rgba(0, 0, 0, theme.active ? 0.70 : 0.27)
        // open search field: the placeholder and the magnifier 112 on 250 (crops/search-expand-frames-light.png); dark not
        // captured, the secondary label there
        readonly property color searchPlaceholder: theme.dark ? Tokens.secondaryLabel : Qt.rgba(0, 0, 0, 0.55)
        // dark inactive: the toolbar strip lightens from (31,34,39) to (38,42,47) (Q-finder-29; crops/toolbar-dark-inactive)
        readonly property color toolbarStripInactive: "#292929"
        // title (Q-finder-06): light #4C4C4C a / #BFBDBD i, dark #E9E9E9 a / #5F5F64 i
        readonly property color title: theme.dark ? (theme.active ? "#E9E9E9" : "#5F5F64") : (theme.active ? "#4C4C4C" : "#BFBDBD")

        // content selection (Q-finder-13/16/19/29): accent while key, grey with label-coloured text while not. Blue: the
        // shots read (42,98,217) light / (36,87,201) dark in Display P3 = (3,100,225) / (1,88,208) in sRGB, the catalog
        // selectedContentBackground #0064E1 / #0059D1 (reference/ours/COLOUR-P3-AUDIT.md), so the shared token serves
        readonly property color iconPlate: theme.dark ? "#36373C" : "#E6E6E6"         // icon plate, unchanged inactive
        readonly property color labelSelection: !theme.active ? Accent.unemphasizedSelectedContent : Accent.selectedContent
        readonly property color listSelection: labelSelection
        readonly property color listSelectionInactive: Accent.unemphasizedSelectedContent   // parent columns
        readonly property color selectedText: theme.active ? "#FFFFFF" : theme.dark ? "#E3E3E3" : "#212121"
        // Q-finder-16 (191,208,244), a Display P3 reading: #BBD1F7 in sRGB
        readonly property color selectedSecondaryText: theme.active ? "#BBD1F7" : theme.dark ? "#ACACAC" : "#6D6D6D"
        readonly property color listAlternate: theme.dark ? "#2A2B31" : "#F4F5F5"
        // list header (Q-finder-17): dark = a solid bar (hard pocket) under the toolbar too; light no fill
        readonly property color listHeaderFill: theme.dark ? "#28282E" : "transparent"
        readonly property color listHeaderSeparator: theme.dark ? "#4C4C52" : "#E5E5E5"
        readonly property color listHeaderLine: theme.dark ? "#424248" : "#E5E5E5"
        readonly property color listHeaderSorted: theme.dark ? "#FFFFFF" : "#4C4C4C"
        readonly property color columnDivider: theme.dark ? "#393939" : "#E5E5E5"       // Q-finder-19
        readonly property color galleryPlate: theme.dark ? "#57585C" : "#BDBDBD"        // Q-finder-20
        readonly property color pathBarLine: theme.dark ? "#424349" : "#E1E1E1"         // Q-finder-22
        // drag selection rectangle: not measured
        readonly property color rubberBand: theme.dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.08)
        readonly property color rubberBandBorder: theme.dark ? Qt.rgba(1, 1, 1, 0.35) : Qt.rgba(0, 0, 0, 0.25)

        // folder icon (macOS blue folder)
        // drawn-fallback folder; SysIconProvider tints the PNG folders to the same crops. ref = the live folder crops,
        // which hold Display P3 values; the colours are those converted to sRGB (reference/ours/COLOUR-P3-AUDIT.md)
        readonly property color folderBack: "#40ABDF"    // ref (95,169,218) P3 = (64,171,223)
        readonly property color folderFront: "#56BBE8"   // ref (113,185,228) P3 = (86,187,232)
        readonly property color folderTop: "#69C8F2"     // ref (129,198,238) P3 = (105,200,242)

        readonly property color fieldBg: theme.dark ? Qt.rgba(1, 1, 1, 0.08) : "#FFFFFF"
        // rename field ring: 3 pt accent a.5 outside, 0.5 pt darker inner edge: Q-finder-27 (114,158,244), a Display P3
        // reading = #65A0FB in sRGB
        readonly property color focusRing: Accent.focusRing
        readonly property color focusEdge: blueAccent && !theme.dark ? "#65A0FB" : Accent.color

        // Finder tag colors (system palette)
        readonly property var tags: [
            { name: "Red", color: "#FF3B30" }, { name: "Orange", color: "#FF9500" },
            { name: "Yellow", color: "#FFCC00" }, { name: "Green", color: "#28CD41" },
            { name: "Blue", color: "#007AFF" }, { name: "Purple", color: "#AF52DE" },
            { name: "Gray", color: "#8E8E93" }
        ]
        readonly property var tagColors: {
            const m = {};
            for (const t of tags) m[t.name] = t.color;
            return m;
        }
        // What tints a tagged folder: the tag's system colour (IconServices systemColorFromTagColorIndex), light
        // appearance. Red, Green, Blue, Purple: macOS 27's values as measured elsewhere in this repo; Orange: checked
        // on the Mac's tagged folder crop (sysicons.cpp); Yellow and Gray: Apple's published palette, not measured.
        // Whether the Mac takes the dark variants for a folder in dark appearance was not checked.
        readonly property var tagFolderColors: ({ Red: "#FF383C", Orange: "#FF8D28", Yellow: "#FFCC00", Green: "#34C759",
                                                  Blue: "#0088FF", Purple: "#CB30E0", Gray: "#8E8E93" })
    }

    // ---------- window ----------
    readonly property QtObject win: QtObject {
        readonly property int width: 936         // ref / 1.22 (1144 px)
        readonly property int height: 594        // ref / 1.22 (726 px)
        // the 27.2.1 Finder and System Settings windows have the same corner (identical alpha profile in
        // finder-toolbar-light.png and settings-toolbar-light.png): 16 pt (MAC-ANSWERS.md Q-windows-02, Tokens.frame)
        readonly property int radius: Tokens.frame.radius
        readonly property int minWidth: 460
        readonly property int minHeight: 280
        readonly property int resizeMargin: 6
    }

    // Traffic lights: SPEC 13 (Tokens.lights). Red disc 19 pt from the window edge, centred in the 52 pt
    // toolbar (27.2.1: x 38 px at 2x).
    readonly property QtObject lights: QtObject {
        readonly property int x: 19
        readonly property int y: (theme.toolbar.height - Tokens.lights.size) / 2
    }

    readonly property QtObject sidebar: QtObject {
        // AX says 163 (divider at 162.5), but every 27.2.1 window picture draws the divider at 158.5..159 and
        // everything right of it (toolbar capsules, title, grid) 4 pt left of the AX frames: the drawn width is 159
        readonly property int width: 159
        readonly property int top: 52            // Q-finder-04: first row (Recents) at y 52, right under the toolbar
        // Appearance > Sidebar icon size: medium measured in the Finder (Q-finder-04/07); small and large take the
        // System Settings source list's steps at the same setting (Q-settings-01: rows 24/32/40, tiles 14/20/26,
        // text 11/13/15, label x -3.5/0/+2.5 from medium). The Finder itself was only captured at medium.
        readonly property int _i: Math.max(0, ["small", "medium", "large"].indexOf(theme.sidebarSize))
        readonly property int rowHeight: [24, 32, 40][_i]   // Q-finder-04 (medium)
        readonly property int rowInset: 10       // selection x 10..153 (143 wide)
        readonly property int rowRadius: 8       // about 8
        readonly property int iconSize: [14, 20, 26][_i]    // medium: 13 pt .large symbols, ink 16..18
        readonly property real iconX: 29 - iconSize / 2     // icon centre x 29
        readonly property real textX: [41.5, 45, 47.5][_i]  // AX text x 45 (ink 46.5) at medium
        readonly property int fontSize: [11, 13, 15][_i]
        readonly property int headerHeight: 19   // Q-finder-04: header rows 19
        readonly property int headerX: 15        // header text x 15 (ink 16.5)
        readonly property int sectionGap: 13     // 13 pt empty before each header row
        readonly property int tagDot: 11         // not measured (Tags section off on the Mac)
    }

    // Toolbar: the strip has no fill and no glass, only the item-group capsules (MAC-ANSWERS.md Q9.2).
    // Q-finder-02 (920 pt window): back/forward 170.5..244.5, title ink 256, views 533.5..694.5 (4 x 40.25),
    // group 702..749.5, share/tags/action 756.5..868.5, search 875.5..912.5, gaps 7..7.5, right inset 7.5.
    readonly property QtObject toolbar: QtObject {
        readonly property int height: 52         // AXToolbar 52, capsules y 8..44
        // drawn 37 tall: the edge rows of every capsule are y 15 and 88 px at 2x (icons-light.png), so 7.5..44.5 pt
        readonly property real capsuleHeight: 37
        readonly property real capsuleY: 7.5
        readonly property int buttonWidth: 37    // a lone button is a circle: search 875.5..912.5 (AX, drawn the same)
        readonly property int navWidth: 74       // back/forward: one 74 x 36 capsule
        readonly property int dividerHeight: 20  // its 1 x 20 divider, hidden on hover
        readonly property real iconSize: 19.6    // ref / 1.22 (24 px)
        readonly property real gap: 7            // between capsule groups (7..7.5)
        readonly property real viewsGap: 7.5     // views 694.5 to group 702
        readonly property real leftPad: 7.5      // sidebar edge to the back/forward capsule
        readonly property real rightPad: 7.5     // last capsule to the window edge
        readonly property real titleGap: 11.5    // capsule ends at 244.5, title ink starts at 256
        readonly property int viewsWidth: 161    // view switcher capsule (AX: 4 segments of 40.25)
        readonly property real segmentWidth: 39.6  // drawn: 2 pt in, glyphs 39.6 apart (Toolbar.qml)
        readonly property real segmentInsetX: 2.8  // selected segment 34 x 28 drawn (1076..1144 px in icons-light), r 14 (Q-finder-11)
        readonly property real segmentInsetY: 4.5   // 28 tall in the 37 capsule
        readonly property int segmentSeparator: 20   // 1 x ~20, only between two unselected segments
        readonly property int actionsWidth: 112  // share 36, tags 38, action 37 (AX)
        readonly property real groupWidth: 47.5 // group button + chevron
        readonly property int hoverHeight: 28    // hover / pressed inner capsule 28 tall (y 12..40) (Q-finder-10)
        readonly property int hoverWidth: 30     // 30 on back/forward and Action, 35.5 on view segments
        readonly property int searchWidth: 241   // expanded search capsule (Q-finder-30)
        readonly property int searchDuration: 160    // 0.15..0.17 s, ease-out
    }

    // Icon view (Q-finder-12/13/14): 64 pt icons in 112 x 112 cells, grid 10 pt under the toolbar and 10 pt into
    // the content (icon centre at content x 66).
    readonly property QtObject grid: QtObject {
        readonly property int cellWidth: 112
        readonly property int cellHeight: 112
        readonly property int iconSize: 64
        readonly property real thumbScale: 0.88  // ref: 68 px thumbnails, the rest is PNG padding
        readonly property int top: 10            // grid origin y = toolbar + 10
        readonly property int sidePad: 10
        readonly property int iconTop: 4         // icon 4 pt from the cell top
        readonly property int plate: 72          // selection plate 72 x 72, r 7, icon inset 4
        readonly property int plateRadius: 7
        readonly property real labelGap: 7.5     // label pill 2 pt under the plate; text ink 140 for icons at 66 (pictures)
        readonly property int labelWidth: 104    // max label ink width
        readonly property int lineHeight: 16     // line pitch 16, at most 2 lines
        readonly property int labelRadius: 5     // pill r 5, about 5 pt side padding, 17 tall for one line
        readonly property int labelPad: 5
    }

    // List view (Q-finder-15/16/17): header 52..80, rows 20 from y 85, inset 10 pt both sides.
    readonly property QtObject list: QtObject {
        readonly property int rowHeight: 20
        readonly property int headerHeight: 28
        readonly property int firstRowGap: 5     // header bottom 80, first row 85
        readonly property int iconSize: 16
        readonly property int iconX: 16          // icon x 189 = row x 173 + 16 (disclosure triangle at +1)
        readonly property int nameX: 36          // name x 209
        readonly property int disclosureX: 1     // disclosure triangle AX x 174 = row + 1, 15 wide
        readonly property int disclosureWidth: 15
        readonly property int indent: 16         // per level; not measured (see FileList)
        readonly property int sidePad: 10
        readonly property int rowRadius: 8
        readonly property int dateWidth: 181     // Name takes the rest: 338 in a 920 pt window
        readonly property int sizeWidth: 97      // right-aligned, 7 pt pad
        readonly property int kindWidth: 121
        readonly property int cellPad: 7
        readonly property int headerSeparator: 16    // 1 x 16 (y 58..74)
        readonly property real sortChevronRight: 6.5 // 7.5 x 5 chevron, 6.5 pt left of the column edge
    }

    // Column view (Q-finder-19): 245 pt columns, 1 pt divider, rows 24, icon 18, text at column x + 38.
    readonly property QtObject columns: QtObject {
        readonly property int width: 245
        readonly property int rowHeight: 24
        readonly property int iconSize: 18
        readonly property int iconX: 15          // icon centre at 24 (ink 17..)
        readonly property int textX: 38
        readonly property int insetLeft: 10      // selection inset 10 left / 11 right, r 8
        readonly property int insetRight: 11
        readonly property int top: 10            // first row 10 pt under the toolbar
        readonly property int previewWidth: 240  // preview column about 240
        readonly property int previewImage: 219  // preview 219 x 259
    }

    // Gallery view (Q-finder-20): preview 443 x 357 at content (32, 32), strip of 48 pt thumbnails at pitch 59,
    // selected plate 54 r 7, info pane about 240 wide on the right in the sidebar material.
    readonly property QtObject gallery: QtObject {
        readonly property int pad: 32
        readonly property int thumb: 48
        readonly property int pitch: 59
        readonly property int plate: 54
        readonly property int plateRadius: 7
        readonly property real stripBottom: 7.5  // strip bottom 7.5 pt above the path bar line
        readonly property int stageGap: 35       // preview box bottom (84 + 357) to the strip (476)
        readonly property int paneWidth: 240
        readonly property int paneIcon: 50
        readonly property int infoPitch: 23      // Created / Modified / Last opened rows
    }

    // Path bar (Q-finder-22): 1 pt top line, 28 tall, no fill; 16 pt icons, 11 pt text, items from x 6.
    readonly property QtObject pathBar: QtObject {
        readonly property int height: 28
        readonly property int iconSize: 16
        readonly property int x: 6
    }
}
