pragma Singleton

import QtQuick
import Finder.Native
import HyprK

// Every metric and color of the Finder window, in pt (1 pt = 1 logical px; HiDPI is the output scale, as for
// the shell and Settings). "27.2.1" = measured on reference/screens/27.2.1/finder-toolbar-{light,dark}.png (2x)
// or the toolbar probe dumps (reference/re/27.2.1/live/toolbar). "ref / 1.22" = measured on
// reference/screens/macos27-finder-window.png, which is drawn at about 1.22 px per pt (its 44 px toolbar
// capsule is the 36 pt capsule measured on 27.2.1), converted to pt. Shared values come from the HyprK
// Tokens, Typography and Accent (ui/HyprK), which this Theme feeds with the Finder's appearance.
QtObject {
    id: theme

    property bool dark: false
    // the Finder has no Reduce motion / transparency / contrast settings of its own yet
    Component.onCompleted: {
        Tokens.dark = Qt.binding(() => theme.dark);
        Tokens.fontText = Qt.binding(() => theme.fontText);
    }
    // No compositor blur behind the window (plain GNOME, offscreen) -> solid sidebar.
    // Set HYPRK_BLUR=1 (Hyprland with a blur windowrule) to get the translucent sidebar.
    property bool blur: false

    // ---------- macOS file icons (themes/icons/system), "" = use the drawn fallbacks ----------
    property bool hasSysIcons: false
    function sysIcon(name, px, tint) {
        return hasSysIcons ? "image://sysicon/" + (tint ? "tint/" : "") + name + "@" + px : "";
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
        readonly property real title: 15           // toolbar title: Typography.toolbarTitle, 15 Semibold (27.2.1)
        readonly property real sidebarItem: 13     // 27.2.1 ("Recents", "Shared" match 13 Regular at 2x)
        readonly property real sidebarHeader: 11   // ref / 1.22 (13.5 px)
        readonly property real label: 12          // icon grid label: ref / 1.22 (14.3 px), Finder's default text size 12
        readonly property real list: 13            // 27.2.1 column view ("App Store", "Apps" match 13 Regular)
        readonly property real listHeader: 12
        readonly property real pathBar: 12
        readonly property real status: 12
        readonly property real preview: 13
    }

    // ---------- colors ----------
    readonly property QtObject color: QtObject {
        // AppKit label hierarchy (Tokens)
        readonly property color label: Tokens.label
        readonly property color secondaryLabel: Tokens.secondaryLabel
        readonly property color tertiaryLabel: Tokens.tertiaryLabel
        readonly property color separator: theme.dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.10)
        // Finder has no accent of its own: Blue #007AFF under Multicolor (accent-colors.json), the user's accent otherwise
        readonly property color accent: Tokens.accent
        readonly property color textSelection: Accent.selectedText   // selectedTextBackgroundColor
        readonly property color sidebarIcon: theme.dark ? "#3D9BFF" : "#0C72EF"   // ref (12,114,239)

        readonly property color window: Tokens.windowBackground
        // solid sidebar: 27.2.1 Finder sidebar reads (38,38,38) dark, (237,237,237) light (finder-toolbar-*.png)
        readonly property color sidebarSolid: theme.dark ? "#262626" : "#EDEDED"
        // over compositor blur: the sidebar glass fill colour (LIVE-27.2.1.md Sidebar, glass-table-dark.txt)
        readonly property color sidebarGlass: theme.dark ? Qt.rgba(0.15, 0.15, 0.15, 0.75) : Qt.rgba(0.87, 0.88, 0.91, 0.7)
        readonly property color sidebarSelection: theme.dark ? Qt.rgba(1, 1, 1, 0.12) : "#E2E2E2"  // ref (226)
        readonly property color sidebarHeader: theme.dark ? Qt.rgba(1, 1, 1, 0.40) : Qt.rgba(0, 0, 0, 0.45)

        // toolbar capsules: HyprK ToolbarPlatter (Tokens.toolbar, measured on 27.2.1)
        readonly property color capsuleSelected: Tokens.toolbar.selection
        // Quick Look's Open button (not a toolbar platter)
        readonly property color capsule: theme.dark ? Qt.rgba(1, 1, 1, 0.08) : "#FAFAFA"
        readonly property color capsuleBorder: theme.dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.07)
        readonly property color toolbarSeparator: Tokens.toolbar.separator
        readonly property color toolbarIcon: theme.dark ? Qt.rgba(1, 1, 1, 0.85) : "#1C1C1C"
        readonly property color toolbarIconDisabled: theme.dark ? Qt.rgba(1, 1, 1, 0.30) : Qt.rgba(0, 0, 0, 0.28)
        // toolbar title, MAC-ANSWERS.md Q-windows-12 / -25: (58,59,57) light, (236,236,235) dark; inactive
        // (129,132,128) / (117,115,103)
        readonly property color title: theme.dark ? "#ECECEB" : "#3A3B39"
        readonly property color titleInactive: theme.dark ? "#757367" : "#818480"

        // content selection
        readonly property color iconSelection: theme.dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08)
        // selectedContentBackgroundColor / unemphasized (27.2.1, per accent: Accent)
        readonly property color labelSelection: Accent.selectedContent
        readonly property color listSelection: Accent.selectedContent
        readonly property color listSelectionInactive: Accent.unemphasizedSelectedContent
        readonly property color listAlternate: theme.dark ? Qt.rgba(1, 1, 1, 0.03) : "#F4F5F5"
        readonly property color rubberBand: theme.dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.08)
        readonly property color rubberBandBorder: theme.dark ? Qt.rgba(1, 1, 1, 0.35) : Qt.rgba(0, 0, 0, 0.25)


        // folder icon (macOS blue folder)
        // drawn-fallback folder; SysIconProvider tints the PNG folders to the same ref colours
        readonly property color folderBack: "#5FA9DA"    // ref (95,169,218)
        readonly property color folderFront: "#71B9E4"   // ref (113,185,228)
        readonly property color folderTop: "#81C6EE"     // ref (129,198,238)

        readonly property color previewPanel: theme.dark ? Qt.rgba(0.15, 0.15, 0.16, 0.97) : Qt.rgba(0.97, 0.97, 0.97, 0.98)
        readonly property color alert: theme.dark ? "#2C2C2E" : "#F5F5F5"
        readonly property color fieldBg: theme.dark ? Qt.rgba(1, 1, 1, 0.08) : "#FFFFFF"
        readonly property color focusRing: theme.dark ? Qt.rgba(0.04, 0.52, 1, 0.55) : Qt.rgba(0, 0.48, 1, 0.45)

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
        readonly property int width: 163         // 27.2.1: sidebar edge at x 325..326 px (2x)
        readonly property int top: 52            // 27.2.1: first row (Recents) right below the 52 pt toolbar, centred at 68.5
        readonly property int rowHeight: 32      // 27.2.1: Recents to Shared 32 pt (medium sidebar, SPEC 7 row 24/32/40)
        readonly property int rowInset: 10       // same as System Settings' sidebar pill (pt ref), ref / 1.22 was 11.5
        readonly property int rowRadius: 10      // same as System Settings, ref / 1.22 was 8
        readonly property int iconSize: 20       // 27.2.1: Recents clock ink 16.5 pt wide (an 18 box drew 15)
        readonly property real iconX: 18.5       // 27.2.1: icon ink 20.5..36.5 pt
        readonly property int textX: 45          // 27.2.1: "Recents" ink starts at 47 pt (R's side bearing)
        readonly property int headerHeight: 24   // ref / 1.22 (30 px)
        readonly property int headerX: 16        // ref / 1.22 (20 px)
        readonly property int sectionGap: 8      // ref / 1.22 (10 px)
        readonly property int tagDot: 11         // ref / 1.22 (14 px)
    }

    // Toolbar: the strip has no fill and no glass, only the item-group capsules (MAC-ANSWERS.md Q9.2).
    // Capsule extents on the 27.2.1 Finder shot (2x): back/forward 170.75..244.25, view switcher 593.75..753.75
    // (incl. rim), group 762.25..808.75, actions 816.75..927.75, search 935.75..971.75 pt in a 980 pt window.
    readonly property QtObject toolbar: QtObject {
        readonly property int height: 52         // 27.2.1 (capsules at 8, 36 tall, 8 below)
        readonly property int capsuleHeight: 36  // 27.2.1
        readonly property int capsuleY: 8        // 27.2.1
        readonly property int buttonWidth: 36    // a lone button is a 36 pt circle (27.2.1)
        readonly property int navWidth: 74       // back/forward: one 74 x 36 capsule (27.2.1)
        readonly property int dividerHeight: 20  // its 1 x 20 divider (27.2.1)
        readonly property real iconSize: 19.6    // ref / 1.22 (24 px)
        readonly property int gap: 8             // between capsule groups (27.2.1 toolbar probe dump)
        readonly property int leftPad: 8        // sidebar edge to the back/forward capsule (27.2.1)
        readonly property int rightPad: 8        // last capsule to the window edge (27.2.1 probe dump)
        readonly property real titleGap: 11.5    // 27.2.1 Finder shot: capsule ends at 244.25, title ink starts at 256.5
        readonly property int viewsWidth: 158    // view switcher: one 158 x 36 capsule (27.2.1)
        readonly property real segmentInsetX: 3  // selected segment 33.5 x 28 in a 39.5 segment (27.2.1)
        readonly property real segmentInsetY: 4
        readonly property int segmentSeparator: 24   // 1 x ~24 (27.2.1 Finder shot)
        readonly property int actionsWidth: 112  // share, tag, action: one 112 capsule (27.2.1)
        readonly property int groupWidth: 46     // group button + chevron (27.2.1: 762.25..808.75)
        readonly property int searchWidth: 180   // expanded search field, ref / 1.22 (220 px)
    }

    readonly property QtObject grid: QtObject {
        readonly property int cellWidth: 126     // ref / 1.22 (column centres 154 px apart)
        readonly property int cellHeight: 113    // ref / 1.22 (138 px)
        readonly property int iconSize: 64       // ref / 1.22 (77 px = 63); Finder's default icon size is 64
        readonly property real thumbScale: 0.88  // ref: 68 px thumbnails, the rest is PNG padding
        readonly property int iconTop: 21        // ref / 1.22 (26 px)
        readonly property int labelGap: 7        // ref / 1.22 (8 px)
        readonly property int labelWidth: 108    // ref / 1.22 (132 px)
        readonly property int sidePad: 11        // ref / 1.22 (13 px)
        readonly property real selectionRadius: 6.5   // ref / 1.22 (8 px)
        readonly property int labelRadius: 4     // ref / 1.22 (5 px)
    }

    readonly property QtObject list: QtObject {
        readonly property int rowHeight: 24
        readonly property int headerHeight: 28
        readonly property int iconSize: 18
        readonly property int sidePad: 10
        readonly property int rowRadius: 6
        readonly property int dateWidth: 190
        readonly property int sizeWidth: 90
        readonly property int kindWidth: 160
    }

    readonly property QtObject columns: QtObject {
        readonly property int width: 245         // 27.2.1: column divider at x 815 px (2x), sidebar edge at 326
        readonly property int rowHeight: 24
        readonly property int iconSize: 18
    }

    readonly property QtObject pathBar: QtObject {
        readonly property int height: 26
        readonly property int iconSize: 14
    }

    readonly property QtObject anim: QtObject {
        readonly property int fast: 120
        readonly property int easing: Easing.OutCubic
    }
}
