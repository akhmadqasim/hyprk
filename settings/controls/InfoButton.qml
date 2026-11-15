import QtQuick
import ".."
import "../HyprK"

// The ⓘ at a row's end (27.2.1 AX "Show Detail", 17 x 17: Sharing's services, Software Update's Automatic Updates,
// Storage's categories). It only reports the press: the row opens what the Mac's does where that is known.
Item {
    signal clicked()
    // the glyph's size: 14.5, or 16.5 where it is measured (General > Software Update and Storage: ink 16.5 pt,
    // live/settings-r12/nav-general--softwareUpdate-dark.png px 1383..1416)
    property real glyphSize: 14.5
    width: 17; height: 17
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    SfSymbol { anchors.centerIn: parent; name: "info.circle"; pointSize: parent.glyphSize; color: Theme.secondaryLabel }
    MouseArea { anchors.fill: parent; onClicked: parent.clicked() }
}
