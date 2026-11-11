import QtQuick
import Finder.Native
import HyprK
import "lib/files.js" as Files

// Sidebar: Recents, Favorites, Locations, Tags. A flat full-height panel flush with the window's left, top
// and bottom edges, no radius of its own (the window corners clip it), no shadow: macOS 27.2.1 sidebar glass
// (_variant 18) has refraction opacity 0 and no shadows (MAC-ANSWERS.md Q9.3).
// Translucent when the compositor blurs behind us, else the solid reference color.
Rectangle {
    id: root

    required property var browser
    property var volumes: []

    color: Theme.blur ? Theme.color.sidebarGlass : Theme.color.sidebarSolid
    property var collapsed: ({})   // header -> true: the section's rows are hidden (click the header)

    function refreshVolumes() {
        const user = Files.baseName(FileOps.homePath());
        let out = [];
        for (const base of ["/media/" + user, "/run/media/" + user])
            if (FileOps.isDir(base))
                out = out.concat(FileOps.list(base, false).filter(e => e.isDir));
        volumes = out;
    }
    Component.onCompleted: refreshVolumes()

    readonly property var sections: [
        // macOS default sidebar (no Home or disk rows; reach them with Ctrl+Shift+H and the path bar).
        // Shared, iCloud Drive and AirDrop are visual placeholders (no Linux backend).
        { header: "", items: [
            { label: "Recents", icon: "clock", path: "recents:" },
            { label: "Shared", icon: "shared", path: "" }
        ] },
        { header: "Favorites", items: [
            { label: "Applications", icon: "applications", path: "applications:" },
            { label: "Desktop", icon: "desktop", path: FileOps.standardPath("desktop") },
            { label: "Documents", icon: "doc", path: FileOps.standardPath("documents") },
            { label: "Downloads", icon: "download", path: FileOps.standardPath("downloads") }
        ] },
        // Locations icons are grey, not the accent (Q-finder-08)
        { header: "Locations", items: [
            { label: "iCloud Drive", icon: "icloud", path: "", grey: true },
            { label: "AirDrop", icon: "airdrop", path: "", grey: true }
        ].concat(volumes.map(v => ({ label: v.name, icon: "drive", path: v.path, grey: true })))
         .concat([{ label: "Trash", icon: "trash", path: FileOps.standardPath("trash"), drop: "trash:", grey: true }]) },
        { header: "Tags", items: Theme.color.tags.slice(0, 5).map(t => ({ label: t.name, dot: t.color, path: "tag:" + t.name })) }
    ]

    Flickable {
        anchors.fill: parent
        anchors.topMargin: Theme.sidebar.top
        id: flick
        contentHeight: column.height + 16
        clip: true
        boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
        RubberBand { flickable: flick }

        Column {
            id: column
            width: parent.width

            Repeater {
                model: root.sections

                Column {
                    id: section
                    required property var modelData
                    required property int index
                    width: column.width
                    topPadding: index > 0 ? Theme.sidebar.sectionGap : 0

                    // 19 pt header row; hovering shows a chevron at the right, a click folds the section (Q-finder-07)
                    Item {
                        visible: section.modelData.header !== ""
                        width: column.width
                        height: Theme.sidebar.headerHeight
                        TextLabel {
                            x: Theme.sidebar.headerX
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: 1.5   // ink 135.5..144 in the 129..148 row (pictures)
                            text: section.modelData.header
                            color: Theme.color.sidebarHeader
                            size: Theme.font.sidebarHeader
                            weight: Typography.semibold
                        }
                        Symbol {
                            visible: headerHover.hovered
                            x: 136.5 - (width - 9.5) / 2
                            anchors.verticalCenter: parent.verticalCenter
                            name: "chevron.down"
                            size: 11
                            weight: "semibold"
                            rotation: root.collapsed[section.modelData.header] ? -90 : 0
                            color: Theme.color.sidebarHeader
                        }
                        HoverHandler { id: headerHover }
                        TapHandler {
                            onTapped: {
                                const c = Object.assign({}, root.collapsed);
                                c[section.modelData.header] = !c[section.modelData.header];
                                root.collapsed = c;
                            }
                        }
                    }

                    Repeater {
                        model: root.collapsed[section.modelData.header] ? [] : section.modelData.items

                        Item {
                            id: row
                            required property var modelData
                            readonly property bool current: modelData.path !== "" && modelData.path === root.browser.path
                            readonly property bool dropping: drop.hovered
                            width: column.width
                            height: Theme.sidebar.rowHeight

                            // grey pill, no hover or pressed state; an accent pill with white text under a drop
                            Rectangle {
                                x: Theme.sidebar.rowInset
                                width: parent.width - 2 * Theme.sidebar.rowInset
                                height: parent.height
                                radius: Theme.sidebar.rowRadius
                                color: row.dropping ? Theme.color.sidebarDrop : Theme.color.sidebarSelection
                                visible: row.current || row.dropping
                            }
                            Symbol {
                                visible: !row.modelData.dot
                                x: Theme.sidebar.iconX
                                anchors.verticalCenter: parent.verticalCenter
                                name: row.modelData.icon || ""
                                size: Theme.sidebar.iconSize
                                pointSize: 13          // 27.2.1 (names.json finder.sidebarGlyph, sure): 13 pt, .large, medium
                                weight: "medium"
                                scale: "large"
                                color: row.dropping ? "white" : row.modelData.grey ? Theme.color.sidebarIconGrey : Theme.color.sidebarIconAccent
                            }
                            Rectangle {
                                visible: !!row.modelData.dot
                                x: Theme.sidebar.iconX + (Theme.sidebar.iconSize - width) / 2
                                anchors.verticalCenter: parent.verticalCenter
                                width: Theme.sidebar.tagDot
                                height: width
                                radius: width / 2
                                color: row.modelData.dot || "transparent"
                            }
                            TextLabel {
                                x: Theme.sidebar.textX
                                width: parent.width - x - Theme.sidebar.rowInset - 4
                                anchors.verticalCenter: parent.verticalCenter
                                text: row.modelData.label
                                elide: Text.ElideRight
                                color: row.dropping ? "white" : Theme.color.sidebarText
                                size: Theme.font.sidebarItem
                                weight: row.current ? Typography.semibold : Typography.regular
                            }
                            TapHandler {
                                onTapped: if (row.modelData.path) root.browser.go(row.modelData.path)
                            }
                            FolderDrop {   // real folders and the Trash take drops; virtual rows do not
                                id: drop
                                anchors.fill: parent
                                enabled: row.modelData.path !== "" && !root.browser.isVirtualPath(row.modelData.path)
                                browser: root.browser
                                path: row.modelData.drop || row.modelData.path   // the Trash row drops via gio trash
                            }
                        }
                    }
                }
            }
        }
    }

    OverlayScrollbar {
        flickable: flick
        x: parent.width - width - Tokens.scroller.inset
        y: Theme.sidebar.top + Tokens.scroller.inset
        height: parent.height - y - Tokens.scroller.inset
    }

    // soft edge between sidebar and content (27.2.1: one 0.5 pt step at x 325 px, 211 between 237 and 255)
    Rectangle {
        anchors.right: parent.right
        width: 0.5
        height: parent.height
        color: Theme.color.separator
    }
}
