import QtQuick
import ".."

// Bottom-right button row of a pane; the "?" help button is always last. 20 below the last card (10 on top of the
// pane's 10 card gap), buttons 10 apart (Appearance: "More in Accessibility Settings…" then "?", PC #60 section 1).
Row {
    property bool help: true
    default property alias buttons: inner.data
    anchors.right: parent ? parent.right : undefined
    topPadding: 10
    spacing: 10
    Row { id: inner; spacing: 10 }
    HelpButton { visible: parent.help }
}
