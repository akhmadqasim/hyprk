import QtQuick
import ".."

// Round "?" help button at the bottom right of most panes.
Rectangle {
    width: 22; height: 22; radius: 11
    color: Theme.controlFill
    border.color: Theme.cardStroke
    MacText { anchors.centerIn: parent; text: "?"; font.family: Theme.fontText; font.pixelSize: 13; weight: Font.Medium; color: Theme.label }
}
