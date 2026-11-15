import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// General > Time Machine (27.2.1, live/settings-r12/nav-general--timeMachine-dark.png, ax-nav-...): the placard (32 pt
// icon, name, four lines), the backup disks' list with + / −, then Options… and Help. No backup backend: the list is
// empty (the Mac's lists its own disk and backup state; settings/FALLBACKS.md "General").
Column {
    id: page
    property var pane
    spacing: Theme.content.sectionGap
    Card {
        Item {
            width: parent.width; height: 94
            Image { x: 10; y: 10; width: 32; height: 32; sourceSize: Qt.size(128, 128); source: "file://" + Backend.root + "/themes/icons/apps/Time_Machine-128.png" }
            MacText { x: 52; y: 10; text: "Time Machine" }
            Text {
                x: 52; y: 28; width: parent.width - 62; wrapMode: Text.WordWrap
                lineHeight: 14; lineHeightMode: Text.FixedHeight
                text: "Time Machine backs up your computer and keeps local snapshots and hourly backups for the past 24 hours, daily backups for the past month and weekly backups for all previous months. The oldest backups and any local snapshots are deleted as space is needed."
                font: Typography.subheadline; color: Theme.secondaryLabel
            }
        }
    }
    Card {
        Item { width: parent.width; height: 72.5 }
        ListBar {}
    }
    PaneFooter { Button { text: "Options…" } }
}
