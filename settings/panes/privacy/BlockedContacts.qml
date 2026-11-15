import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "PrivacyData.js" as PD

// Privacy & Security > Blocked Contacts (27.2.1, dest-privacyAndSecurity--blocked-contacts-*.png, ax-dest-...): a list
// (38 pt rows) over a + / − strip. The Mac's one entry is blurred, and there are no contacts here: the list is empty
// (the strip alone; "No Items" is the Mac's word for an empty list, as System Audio Recording Only shows).
Column {
    id: page
    property var pane
    property var cls
    spacing: Theme.content.sectionGap
    Card {
        Item {
            width: parent.width; height: 38
            MacText { anchors.centerIn: parent; text: "No Items"; color: Theme.secondaryLabel }
        }
        ListBar {}
    }
}
