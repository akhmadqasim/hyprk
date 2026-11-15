import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "PrivacyData.js" as PD

// Privacy & Security > Accessories ("Wired Accessories" in the toolbar; 27.2.1, dest-privacyAndSecurity--accessories-
// *.png, ax-dest-...): one row with a pop-up ("Ask for new accessories": its other items are not on a shot).
Column {
    id: page
    property var pane
    property var cls
    spacing: Theme.content.sectionGap
    Card { FormRow { label: "Allow accessories to connect"; LocalPopup { objectName: "accessoriesPopup"; model: ["Ask for new accessories"] } } }
}
