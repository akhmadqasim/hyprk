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
        { header: "Locations", items: [
            { label: "iCloud Drive", icon: "icloud", path: "" },
            { label: "AirDrop", icon: "airdrop", path: "" }
        ].concat(volumes.map(v => ({ label: v.name, icon: "drive", path: v.path })))
         .concat([{ label: "Trash", icon: "trash", path: FileOps.standardPath("trash"), drop: "trash:" }]) },
        { header: "Tags", items: Theme.color.tags.slice(0, 5).map(t => ({ label: t.name, dot: t.color, path: "tag:" + t.name })) }
    ]

    Flickable {
        anchors.fill: parent
        anchors.topMargin: Theme.sidebar.top
        contentHeight: column.height + 16
        clip: true
        boundsBehavior: Flickable.StopAtBounds

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

                    TextLabel {
                        visible: section.modelData.header !== ""
                        x: Theme.sidebar.headerX
                        height: Theme.sidebar.headerHeight
                        verticalAlignment: Text.AlignVCenter
                        text: section.modelData.header
                        color: Theme.color.sidebarHeader
                        size: Theme.font.sidebarHeader
                        weight: Typography.semibold
                    }

                    Repeater {
                        model: section.modelData.items

                        Item {
                            id: row
                            required property var modelData
                            readonly property bool current: modelData.path !== "" && modelData.path === root.browser.path
                            width: column.width
                            height: Theme.sidebar.rowHeight

                            Rectangle {
                                x: Theme.sidebar.rowInset
                                width: parent.width - 2 * Theme.sidebar.rowInset + 2
                                height: parent.height
                                radius: Theme.sidebar.rowRadius
                                color: Theme.color.sidebarSelection
                                visible: row.current || tap.pressed || drop.hovered
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
                                color: Theme.color.sidebarIcon
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
                                color: Theme.color.label
                                size: Theme.font.sidebarItem
                                weight: row.current ? Typography.semibold : Typography.regular
                            }
                            TapHandler {
                                id: tap
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

    // soft edge between sidebar and content (27.2.1: one 0.5 pt step at x 325 px, 211 between 237 and 255)
    Rectangle {
        anchors.right: parent.right
        width: 1
        height: parent.height
        color: Theme.color.separator
        opacity: 0.5
    }
}
