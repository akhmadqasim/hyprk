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
        Tokens.fontText = Qt.binding(() => theme.fontText);
        Tokens.windowActive = Qt.binding(() => theme.active);
    }
    // No compositor blur behind the window (plain GNOME, offscreen) -> solid sidebar.
    // Set HYPRK_BLUR=1 (Hyprland with a blur windowrule) to get the translucent sidebar.
    property bool blur: false

    // ---------- macOS file icons (themes/icons/system), "" = use the drawn fallbacks ----------
    property bool hasSysIcons: false
    // tint: the folder blue; tag: a tag colour ("#RRGGBB") for a tagged folder
    function sysIcon(name, px, tint, tag) {
        return !hasSysIcons ? "" : "image://sysicon/" + (tag ? "tag/" + tag.slice(1, 7) + "/" : tint ? "tint/" : "") + name + "@" + px;
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
        // rename field: the selected base name (186,214,251) (Q-finder-27)
        readonly property color textSelection: blueAccent && !theme.dark ? "#BAD6FB" : Accent.selectedText

        readonly property color window: Tokens.windowBackground
        // sidebar (Q-finder-03/07/08/09): fill, text, headers, icons; a = key window, i = inactive
        // key window: + the chameleon layer (10 % dark / 5 % light colour blend); the inactive sidebar is flat
        readonly property color sidebarSolid: theme.chameleonOf(theme.dark ? "#242637" : theme.active ? "#EDEDEE" : "#F2F2F3")
        // over compositor blur: the sidebar glass fill colour (LIVE-27.2.1.md Sidebar, glass-table-dark.txt)
        readonly property color sidebarGlass: theme.chameleonOf(theme.dark ? Qt.rgba(0.15, 0.15, 0.15, 0.75) : Qt.rgba(0.87, 0.88, 0.91, 0.7))
        readonly property color sidebarSelection: theme.dark ? (theme.active ? "#414354" : "#323443")
                                                             : (theme.active ? "#D7D7D8" : "#E7E7E8")
        readonly property color sidebarDrop: "#2F6EED"          // drop target pill, white text (Q-finder-09)
        readonly property color sidebarText: theme.dark ? (theme.active ? "#FFFFFF" : "#92939B") : (theme.active ? "#000000" : "#717171")
        readonly property color sidebarHeader: theme.dark ? Qt.rgba(1, 1, 1, theme.active ? 0.35 : 0.23)
                                                          : Qt.rgba(0, 0, 0, theme.active ? 0.43 : 0.30)
        // Recents, Shared and Favourites: accent; Locations: grey; all grey while inactive
        readonly property color sidebarIconAccent: !theme.active ? sidebarIconInactive : blueAccent ? (theme.dark ? "#1E98FF" : "#006BEF") : accent
        readonly property color sidebarIconGrey: !theme.active ? sidebarIconInactive : theme.dark ? "#B5B5C3" : "#7B7B80"
        readonly property color sidebarIconInactive: theme.dark ? "#8F909B" : "#7F7F7F"

        // toolbar capsules: HyprK ToolbarPlatter (Tokens.toolbar, measured on 27.2.1)
        readonly property color capsuleSelected: Tokens.toolbar.selection
        // inactive window: the capsule darkens 252 -> 240 | (61,62,70) -> (58,60,67) (Q-finder-29)
        readonly property color capsuleInactive: Qt.rgba(0, 0, 0, theme.dark ? 0.05 : 0.048)
        // hover / pressed inner capsule: 242 on 252 (Search 236) | (87,89,96) on (67,69,77) (Q-finder-10)
        readonly property color toolbarHover: theme.dark ? Qt.rgba(1, 1, 1, 0.106) : Qt.rgba(0, 0, 0, 0.04)
        readonly property color searchHover: theme.dark ? Qt.rgba(1, 1, 1, 0.106) : Qt.rgba(0, 0, 0, 0.064)
        // Quick Look panel (live/finder/crops/quicklook-titlebar-light.png, 2x): frame 136 (134-138 top to bottom), discs
        // and button glyphs 6-8, title and "Open with" text 36-41 at the stroke cores. Dark: not measured, so the same
        readonly property color quickLookFrame: "#888888"
        readonly property color quickLookInk: "#070707"
        readonly property color quickLookText: "#282828"
        readonly property color toolbarSeparator: Tokens.toolbar.separator
        // glyphs: light 0, inactive 164 (Q-finder-29); dark not measured
        readonly property color toolbarIcon: theme.dark ? Qt.rgba(1, 1, 1, 0.85) : theme.active ? "#000000" : "#A4A4A4"
        // disabled: light 173 on 252, dark (113,114,122) on (61,62,70) (Q-finder-10)
        readonly property color toolbarIconDisabled: theme.dark ? Qt.rgba(1, 1, 1, 0.27) : Qt.rgba(0, 0, 0, 0.31)
        // title (Q-finder-06): light #4C4C4C a / #BFBDBD i, dark #E9E9E9 a / #5F5F64 i
        readonly property color title: theme.dark ? (theme.active ? "#E9E9E9" : "#5F5F64") : (theme.active ? "#4C4C4C" : "#BFBDBD")

        // content selection (Q-finder-13/16/19/29): accent while key, grey with label-coloured text while not
        readonly property color iconPlate: theme.dark ? "#36373C" : "#E6E6E6"         // icon plate, unchanged inactive
        readonly property color labelSelection: !theme.active ? Accent.unemphasizedSelectedContent
                                              : blueAccent ? (theme.dark ? "#2558C9" : "#2A63D9") : Accent.selectedContent
        readonly property color listSelection: !theme.active ? Accent.unemphasizedSelectedContent
                                             : blueAccent ? (theme.dark ? "#2457C9" : "#2A62D9") : Accent.selectedContent
        readonly property color listSelectionInactive: Accent.unemphasizedSelectedContent   // parent columns
        readonly property color selectedText: theme.active ? "#FFFFFF" : theme.dark ? "#E3E3E3" : "#212121"
        readonly property color selectedSecondaryText: theme.active ? "#BFD0F4" : theme.dark ? "#ACACAC" : "#6D6D6D"
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
        // drawn-fallback folder; SysIconProvider tints the PNG folders to the same ref colours
        readonly property color folderBack: "#5FA9DA"    // ref (95,169,218)
        readonly property color folderFront: "#71B9E4"   // ref (113,185,228)
        readonly property color folderTop: "#81C6EE"     // ref (129,198,238)

        // context menu over Hyprland's popup blur: the 27.2.1 menu glass's empty-area pixel over flat backdrops
        // (MAC-ANSWERS.md Q-menubar-13: light over white 251,252,255 / over black 137,137,138; dark 120,120,121 /
        // 33,34,44) solved per channel for fill c and alpha a (over black c a, over white c a + 255 (1 - a))
        readonly property color menuGlassFill: theme.dark ? Qt.rgba(50 / 255, 51 / 255, 63 / 255, 0.67) : Qt.rgba(248 / 255, 250 / 255, 1, 0.55)
        readonly property color fieldBg: theme.dark ? Qt.rgba(1, 1, 1, 0.08) : "#FFFFFF"
        // rename field ring: 3 pt accent a.5 outside, 0.5 pt darker inner edge (114,158,244) (Q-finder-27)
        readonly property color focusRing: Accent.focusRing
        readonly property color focusEdge: blueAccent && !theme.dark ? "#729EF4" : Accent.color

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
        readonly property int capsuleHeight: 36
        readonly property int capsuleY: 8
        readonly property int buttonWidth: 36    // a lone button is a 36 pt circle
        readonly property int navWidth: 74       // back/forward: one 74 x 36 capsule
        readonly property int dividerHeight: 20  // its 1 x 20 divider, hidden on hover
        readonly property real iconSize: 19.6    // ref / 1.22 (24 px)
        readonly property real gap: 7            // between capsule groups (7..7.5)
        readonly property real leftPad: 7.5      // sidebar edge to the back/forward capsule
        readonly property real rightPad: 7.5     // last capsule to the window edge
        readonly property real titleGap: 11.5    // capsule ends at 244.5, title ink starts at 256
        readonly property int viewsWidth: 161    // view switcher: 4 segments of 40.25
        readonly property real segmentInsetX: 2.4  // selected segment 35.5 x 28, r 14 (Q-finder-11)
        readonly property real segmentInsetY: 4
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
