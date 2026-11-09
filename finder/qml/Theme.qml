pragma Singleton

import QtQuick
import Finder.Native

// Every metric and color of the Finder window.
// Metrics are measured in px from reference/screens/macos27-finder-window.png (1144x726, 1x),
// so a default-size window can be diffed against the reference pixel for pixel.
// /mnt/code/liquid-glass-re/SPEC.md "Layout metrics" did not exist yet (2026-11-10 03:00);
// values marked "ref" come from the screenshot. Shared values mirror shell/Theme.qml.
QtObject {
    id: theme

    property bool dark: false
    // No compositor blur behind the window (plain GNOME, offscreen) -> solid sidebar.
    // Set HYPRK_BLUR=1 (Hyprland with a blur windowrule) to get the translucent sidebar.
    property bool blur: false

    // ---------- macOS file icons (themes/icons/system), "" = use the drawn fallbacks ----------
    property string iconDir: ""
    function sysIcon(name, px) {
        return iconDir ? "file://" + iconDir + "/" + name + (px > 128 ? "-512.png" : "-128.png") : "";
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
        // AppKit label hierarchy, same as shell/Theme.qml
        readonly property color label: theme.dark ? Qt.rgba(1, 1, 1, 0.85) : Qt.rgba(0, 0, 0, 0.85)
        readonly property color secondaryLabel: theme.dark ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.50)
        readonly property color tertiaryLabel: theme.dark ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.26)
        readonly property color separator: theme.dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.10)
        readonly property color accent: theme.dark ? "#0A84FF" : "#007AFF"
        readonly property color sidebarIcon: theme.dark ? "#3D9BFF" : "#0C72EF"   // ref (12,114,239)

        readonly property color window: theme.dark ? "#1E1E1E" : "#FFFFFF"
        readonly property color windowBorder: theme.dark ? Qt.rgba(1, 1, 1, 0.14) : "#BEBEBE"  // ref 1px
        // solid fallback sidebar is what the reference shows: #EDEDED
        readonly property color sidebarSolid: theme.dark ? "#2B2B2D" : "#EDEDED"
        readonly property color sidebarGlass: theme.dark ? Qt.rgba(0.17, 0.17, 0.18, 0.62) : Qt.rgba(0.93, 0.93, 0.93, 0.62)
        readonly property color sidebarSelection: theme.dark ? Qt.rgba(1, 1, 1, 0.12) : "#E2E2E2"  // ref (226)
        readonly property color sidebarHeader: theme.dark ? Qt.rgba(1, 1, 1, 0.40) : Qt.rgba(0, 0, 0, 0.45)

        // toolbar glass capsules
        readonly property color capsule: theme.dark ? Qt.rgba(1, 1, 1, 0.08) : "#FAFAFA"
        readonly property color capsuleBorder: theme.dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.07)
        readonly property color capsuleShadow: Qt.rgba(0, 0, 0, theme.dark ? 0.30 : 0.06)
        readonly property color capsuleSelected: theme.dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.07)
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

        // traffic lights, ref
        readonly property color close: "#EC6765"
        readonly property color minimize: "#F2CA44"
        readonly property color zoom: "#65C466"
        readonly property color lightRim: Qt.rgba(0, 0, 0, 0.12)
        readonly property color lightGlyph: Qt.rgba(0, 0, 0, 0.55)
        readonly property color lightInactive: theme.dark ? "#4A4A4C" : "#D6D6D6"

        // folder icon (macOS blue folder)
        readonly property color folderBack: "#5BAEEA"
        readonly property color folderFront: "#80C4F2"
        readonly property color folderTop: "#A5D8F8"

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

    readonly property QtObject lights: QtObject {
        readonly property int size: 16           // ref (diameter)
        readonly property int spacing: 12        // gap between circles, ref (centers 28 apart)
        readonly property int x: 24              // ref (left edge of red)
        readonly property int y: 24              // ref (top edge)
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

    readonly property QtObject toolbar: QtObject {
        readonly property int height: 64         // ref (capsules 10..53, content starts ~64)
        readonly property int capsuleHeight: 44  // ref
        readonly property int capsuleY: 10       // ref
        readonly property int buttonWidth: 44    // ref (back/forward halves of 88)
        readonly property int iconSize: 24
        readonly property int gap: 20            // between capsule groups, ref
        readonly property int leftPad: 10        // sidebar edge to back/forward capsule, ref (191 -> 200)
        readonly property int rightPad: 12       // ref
        readonly property int titleGap: 15       // capsule to title, ref
        readonly property int segment: 46        // view switcher segment width, ref (648..840 / 4)
        readonly property int searchWidth: 220   // expanded search field
    }

    readonly property QtObject grid: QtObject {
        readonly property int cellWidth: 154     // ref (column centers 154 apart)
        readonly property int cellHeight: 138    // ref
        readonly property int iconSize: 72       // ref (folder ~72x60)
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
