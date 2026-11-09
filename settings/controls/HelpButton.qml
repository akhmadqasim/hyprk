import QtQuick
import ".."

// Round "?" help button at the bottom right of most panes.
Rectangle {
    width: 22; height: 22; radius: 11
    color: Theme.controlFill
    border.color: Theme.cardStroke
    Text { anchors.centerIn: parent; text: "?"; font.family: Theme.fontText; font.pixelSize: 13; font.weight: Theme.fw(Font.Medium); font.variableAxes: Theme.axes(Font.Medium); color: Theme.label }
}
