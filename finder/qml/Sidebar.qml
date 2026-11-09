import QtQuick
import Finder.Native

// Floating sidebar: Recents, Favorites, Locations, Tags.
// Glass (translucent) when the compositor blurs behind us, else the solid reference color.
Rectangle {
    id: root

    required property var browser
    property var volumes: []

    color: Theme.blur ? Theme.color.sidebarGlass : Theme.color.sidebarSolid

    function refreshVolumes() {
        const user = FileOps.homePath().split("/").pop();
        let out = [];
        for (const base of ["/media/" + user, "/run/media/" + user])
            if (FileOps.isDir(base))
                out = out.concat(FileOps.list(base, false).filter(e => e.isDir));
        volumes = out;
    }
    Component.onCompleted: refreshVolumes()

    readonly property var sections: [
        { header: "", items: [{ label: "Recents", icon: "clock", path: "recents:" }] },
        { header: "Favorites", items: [
            { label: "Applications", icon: "applications", path: "applications:" },
            { label: "Desktop", icon: "desktop", path: FileOps.standardPath("desktop") },
            { label: "Documents", icon: "doc", path: FileOps.standardPath("documents") },
            { label: "Downloads", icon: "download", path: FileOps.standardPath("downloads") },
            { label: FileOps.homePath().split("/").pop(), icon: "house", path: FileOps.homePath() }
        ] },
        { header: "Locations", items: [
            { label: "Macintosh HD", icon: "drive", path: "/" }
        ].concat(volumes.map(v => ({ label: v.name, icon: "drive", path: v.path })))
         .concat([{ label: "Trash", icon: "trash", path: FileOps.standardPath("trash") }]) },
        { header: "Tags", items: Theme.color.tags.slice(0, 5).map(t => ({ label: t.name, dot: t.color, path: "" })) }
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

                    Text {
                        visible: section.modelData.header !== ""
                        x: Theme.sidebar.headerX
                        height: Theme.sidebar.headerHeight
                        verticalAlignment: Text.AlignVCenter
                        text: section.modelData.header
                        color: Theme.color.sidebarHeader
                        font.family: Theme.fontText
                        font.pixelSize: Theme.font.sidebarHeader
                        font.weight: Font.DemiBold
                        font.variableAxes: ({ "wght": Font.DemiBold, "opsz": 17 })  // SF variable font: weight + text optical size
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
                                visible: row.current || tap.pressed
                            }
                            Symbol {
                                visible: !row.modelData.dot
                                x: Theme.sidebar.iconX
                                anchors.verticalCenter: parent.verticalCenter
                                name: row.modelData.icon || ""
                                size: Theme.sidebar.iconSize
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
                            Text {
                                x: Theme.sidebar.textX
                                width: parent.width - x - Theme.sidebar.rowInset - 4
                                anchors.verticalCenter: parent.verticalCenter
                                text: row.modelData.label
                                elide: Text.ElideRight
                                color: Theme.color.label
                                font.family: Theme.fontText
                                font.pixelSize: Theme.font.sidebarItem
                                font.weight: row.current ? Font.DemiBold : Font.Normal
                                font.variableAxes: ({ "wght": row.current ? Font.DemiBold : Font.Normal, "opsz": 17 })  // SF variable font: weight + text optical size
                            }
                            TapHandler {
                                id: tap
                                onTapped: if (row.modelData.path) root.browser.go(row.modelData.path)
                            }
                        }
                    }
                }
            }
        }
    }

    // soft edge between sidebar and content, ref (189..193 fades to white)
    Rectangle {
        anchors.right: parent.right
        width: 1
        height: parent.height
        color: Theme.color.separator
        opacity: 0.5
    }
}
