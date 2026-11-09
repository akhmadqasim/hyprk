import QtQuick
import ".."

// Bottom-right button row of a pane; the "?" help button is always last.
Row {
    property bool help: true
    default property alias buttons: inner.data
    anchors.right: parent ? parent.right : undefined
    spacing: 8
    Row { id: inner; spacing: 8 }
    HelpButton { visible: parent.help }
}
