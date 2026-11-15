import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// General > Login Items & Extensions (27.2.1, live/settings-r12/nav-general--loginItems-dark.png, ax-nav-...; toolbar
// title "Login Items"): "Open at Login" with its line over a two-column table (Item | Kind: a 28 pt header, 24 pt
// rows, + / −), then Help. The rows are the session's XDG autostart entries (~/.config/autostart/*.desktop), read-only
// (settings/FALLBACKS.md "General"). Not here: Background App Activity and Extensions, lists of the Mac's own apps.
Column {
    id: page
    property var pane
    spacing: Theme.content.sectionGap
    property var items: []
    Component.onCompleted: Backend.run(["sh", "-c", "for f in \"$HOME\"/.config/autostart/*.desktop; do [ -f \"$f\" ] && sed -n 's/^Name=//p' \"$f\" | head -n 1; done"],
                                       (c, out) => { try { page.items = out.split("\n").filter(l => l !== ""); } catch (e) {} })
    Card {
        title: "Open at Login"
        subtitle: "These items will open automatically when you log in."
        Item {
            width: parent.width; height: 28
            Text { x: 10; anchors.verticalCenter: parent.verticalCenter; text: "Item"; font: Typography.font(11, 590); color: Theme.label }
            Text { x: 246.5; anchors.verticalCenter: parent.verticalCenter; text: "Kind"; font: Typography.font(11, 590); color: Theme.label }
            Rectangle { x: 234.5; y: 6; width: 1; height: 16; color: Theme.separator }
            Rectangle { y: parent.height - height; width: parent.width; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); antialiasing: Pixel.soft(Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
        }
        Item {
            width: parent.width; height: Math.max(68.5, page.items.length * 24)
            Repeater {
                model: page.items
                Item {
                    required property string modelData
                    required property int index
                    y: index * 24; width: parent.width; height: 24
                    MacText { x: 10; anchors.verticalCenter: parent.verticalCenter; width: 214; elide: Text.ElideRight; text: modelData }
                    MacText { x: 246.5; anchors.verticalCenter: parent.verticalCenter; text: "Application" }
                }
            }
        }
        ListBar {}
    }
    PaneFooter {}
}
