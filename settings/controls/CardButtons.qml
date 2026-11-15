import QtQuick
import ".."
import "../HyprK"

// A line of a card holding only buttons, right-aligned (27.2.1: General > About "Display Settings…", AirDrop &
// Continuity "About AirDrop & Privacy…", Keyboard "Keyboard Shortcuts…": a 24 pt button, 10 pt above and below it)
Item {
    default property alias buttons: row.data
    width: parent ? parent.width : 0
    height: 44
    Rectangle {
        visible: parent.Positioner.index > 0
        x: Theme.content.separatorInset; width: parent.width - 2 * x
        height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio))
        color: Theme.separator
    }
    Row { id: row; anchors.right: parent.right; anchors.rightMargin: Theme.content.rowPadding; anchors.verticalCenter: parent.verticalCenter; spacing: 10 }
}
