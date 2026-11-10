pragma Singleton

import QtQuick
import Finder.Native
import HyprK

// Every metric and color of the Finder window.
// Metrics are measured in px from reference/screens/macos27-finder-window.png (1144x726, 1x),
// so a default-size window can be diffed against the reference pixel for pixel.
// /mnt/code/liquid-glass-re/SPEC.md "Layout metrics" did not exist yet (2026-11-10 03:00);
// values marked "ref" come from the screenshot. Shared values come from the HyprK Tokens (ui/HyprK),
// which this Theme feeds with the Finder's appearance.
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

    readonly property QtObject font: QtObject {
        readonly property real title: 17.5         // "Documents — Local", ref
        readonly property real sidebarItem: 15.5   // ref
        readonly property real sidebarHeader: 13.5 // ref
        readonly property real label: 14.3         // icon grid label, ref
        readonly property real list: 13
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
        readonly property color accent: Tokens.accent
        readonly property color sidebarIcon: theme.dark ? "#3D9BFF" : "#0C72EF"   // ref (12,114,239)

        readonly property color window: Tokens.windowBackground
        readonly property color windowBorder: theme.dark ? Qt.rgba(1, 1, 1, 0.14) : "#BEBEBE"  // ref 1px
        // solid fallback sidebar is what the reference shows: #EDEDED
        // dark: 27.2.1 Finder sidebar reads 38..39 (reference/screens/27.2.1/finder-toolbar-dark.png)
        readonly property color sidebarSolid: theme.dark ? "#272727" : "#EDEDED"
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
        readonly property color title: theme.dark ? Qt.rgba(1, 1, 1, 0.80) : "#4D4D4D"     // ref (77)

        // content selection
        readonly property color iconSelection: theme.dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08)
        readonly property color labelSelection: accent
        readonly property color listSelection: accent
        readonly property color listSelectionInactive: theme.dark ? Qt.rgba(1, 1, 1, 0.12) : "#DCDCDC"
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
        readonly property int width: 1144        // ref
        readonly property int height: 726        // ref
        readonly property int radius: 22         // ref (diagonal inset 6.5px)
        readonly property int minWidth: 560
        readonly property int minHeight: 320
        readonly property int resizeMargin: 6
    }

    // Traffic lights: SPEC 13 (Tokens.lights), placed like the reference. (The reference shot is
    // ~1.14x: its 16 px discs are 14 pt.)
    readonly property QtObject lights: QtObject {
        readonly property int x: 19                  // left edge of the red disc from the window edge
        readonly property int y: (theme.toolbar.height - Tokens.lights.size) / 2   // centred in the toolbar
    }

    readonly property QtObject sidebar: QtObject {
        readonly property int width: 191         // ref (0..190)
        readonly property int top: 64            // first row starts below traffic lights, ref
        readonly property int rowHeight: 38      // ref (Documents highlight 254..292)
        readonly property int rowInset: 14       // highlight x inset, ref
        readonly property int rowRadius: 10      // ref
        readonly property int iconSize: 22      // ref (sidebar)
        readonly property int iconX: 24          // icon left edge, ref
        readonly property int textX: 56          // ref ("Recents" starts at x=56)
        readonly property int headerHeight: 30   // "Favorites" row, ref
        readonly property int headerX: 20        // ref
        readonly property int sectionGap: 10     // ref
        readonly property int tagDot: 14         // ref
    }

    // Toolbar: the strip has no fill and no glass, only the item-group capsules (MAC-ANSWERS.md Q9.2).
    // The Finder is drawn at its reference image's scale: the 44 px capsule of the ref is the 36 pt capsule
    // measured on 27.2.1, so pt values below are x pt (= 44 / 36). The ref's 64 px toolbar and 10 px capsule y
    // agree (52 pt toolbar, capsule at 8 pt).
    readonly property QtObject toolbar: QtObject {
        readonly property real pt: 44 / 36
        readonly property int height: 64         // ref (capsules 10..53, content starts ~64) = 52 pt
        readonly property int capsuleHeight: 44  // ref = 36 pt (27.2.1)
        readonly property int capsuleY: 10       // ref = 8 pt
        readonly property int buttonWidth: 44    // a lone button is a 36 pt circle (27.2.1)
        readonly property real navWidth: Math.round(74 * pt)        // back/forward: one 74 x 36 pt capsule (27.2.1)
        readonly property real dividerHeight: Math.round(20 * pt)   // its 1 x 20 pt divider (27.2.1)
        readonly property int iconSize: 24
        readonly property int gap: Math.round(8 * pt)       // between capsule groups: 8 pt (27.2.1 toolbar probe dump)
        readonly property int leftPad: 10        // sidebar edge to back/forward capsule, ref (191 -> 200) = 8 pt (27.2.1)
        readonly property int rightPad: Math.round(8 * pt)  // last capsule to the window edge: 8 pt (27.2.1 probe dump)
        readonly property int titleGap: Math.round(13.5 * pt)  // capsule to title: 13.5 pt (27.2.1 Finder shot)
        readonly property real viewsWidth: Math.round(158 * pt)   // view switcher: one 158 x 36 pt capsule (27.2.1)
        readonly property real segmentInsetX: 3 * pt     // selected segment 33.5 x 28 pt in a 39.5 pt segment (27.2.1)
        readonly property real segmentInsetY: 4 * pt
        readonly property real segmentSeparator: Math.round(24 * pt)   // 1 x ~24 pt (27.2.1 Finder shot)
        readonly property real actionsWidth: Math.round(112 * pt)   // share, tag, action: one 112 pt capsule (27.2.1)
        readonly property int searchWidth: 220   // expanded search field
    }

    readonly property QtObject grid: QtObject {
        readonly property int cellWidth: 154     // ref (column centers 154 apart)
        readonly property int cellHeight: 138    // ref
        readonly property int iconSize: 77       // ref: folder art 72 px wide, the PNG has ~3 px padding
        readonly property real thumbScale: 0.88  // ref: 68 px thumbnails, the rest is PNG padding
        readonly property int iconTop: 26        // ref (first icon top y ~90 = 64 + 26)
        readonly property int labelGap: 8
        readonly property int labelWidth: 132
        readonly property int sidePad: 13        // ref (first column center 281 = 191 + 13 + 77)
        readonly property int selectionRadius: 8
        readonly property int labelRadius: 5
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
        readonly property int width: 240
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
