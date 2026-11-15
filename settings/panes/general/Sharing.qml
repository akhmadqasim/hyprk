import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// General > Sharing (27.2.1, live/settings-r12/nav-general--sharing-dark.png, ax-nav-...): three headed cards of 53 pt
// service rows, each a switch (off, the Mac's values) and ⓘ, then the local hostname with Edit…, Help. No sharing
// backend: the switches keep their own state (settings/FALLBACKS.md "General"). The hostname is this computer's.
Column {
    id: page
    property var pane
    spacing: Theme.content.sectionGap
    property string host: ""
    Component.onCompleted: Backend.readText("/etc/hostname", t => { try { page.host = t.trim(); } catch (e) {} })
    component Service: FormRow {
        implicitHeight: Positioner.index > 0 ? 53 : 52
        LocalSwitch { anchors.verticalCenter: parent.verticalCenter }
        InfoButton {}
    }
    Card {
        title: "Content & Media"
        Service { label: "File Sharing" }
        Service { label: "Media Sharing" }
        Service { label: "Screen Sharing" }
        Service { label: "Content Caching" }
    }
    Card {
        title: "Accessories & Internet"
        Service { label: "Bluetooth Sharing" }
        Service { label: "Printer Sharing" }
        Service { label: "Internet Sharing" }
    }
    Card {
        title: "Advanced"
        Service { label: "Remote Management" }
        Service { label: "Remote Login" }
        Service { label: "Remote Application Scripting" }
    }
    Card {
        FormRow { label: "Local hostname"; value: page.host !== "" ? page.host + ".local" : "" }
        Item {
            width: parent.width; height: 48
            Rectangle { x: 10; width: parent.width - 20; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); antialiasing: Pixel.soft(Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
            Text {
                x: 10; anchors.verticalCenter: parent.verticalCenter; width: 340; wrapMode: Text.WordWrap
                lineHeight: 14; lineHeightMode: Text.FixedHeight
                text: "Computers on your local network can access your computer at this address."
                font: Typography.subheadline; color: Theme.secondaryLabel
            }
            Button { anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: "Edit…" }
        }
    }
    PaneFooter {}
}
