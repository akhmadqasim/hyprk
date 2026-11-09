import QtQuick
import "lib/files.js" as Files

// Path bar (View > Show Path Bar): every ancestor of the current folder, clickable.
Rectangle {
    id: root

    required property var browser

    height: Theme.pathBar.height
    color: Theme.color.window

    Rectangle { width: parent.width; height: 1; color: Theme.color.separator }

    Flickable {
        anchors.fill: parent
        anchors.leftMargin: 10
        contentWidth: row.width
        clip: true
        flickableDirection: Flickable.HorizontalFlick
        Row {
            id: row
            height: root.height
            spacing: 2
            Repeater {
                model: root.browser.isVirtual ? [{ name: root.browser.title, path: root.browser.path }]
                                              : Files.segments(root.browser.path, "Macintosh HD")
                Row {
                    required property var modelData
                    required property int index
                    height: row.height
                    spacing: 4
                    Symbol {
                        visible: index > 0
                        anchors.verticalCenter: parent.verticalCenter
                        name: "chevron.small.right"
                        size: 12
                        color: Theme.color.tertiaryLabel
                    }
                    Symbol {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: modelData.path === "/"
                        name: "drive"
                        size: Theme.pathBar.iconSize
                        color: Theme.color.sidebarIcon
                    }
                    FileIcon {
                        visible: modelData.path !== "/"
                        anchors.verticalCenter: parent.verticalCenter
                        entry: ({ name: modelData.name, path: modelData.path, isDir: true, mime: "inode/directory" })
                        size: Theme.pathBar.iconSize
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.name
                        color: Theme.color.secondaryLabel
                        font.family: Theme.fontText
                        font.pixelSize: Theme.font.pathBar
                        TapHandler { onTapped: root.browser.go(modelData.path) }
                    }
                }
            }
        }
    }
}
