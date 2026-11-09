import QtQuick
import ".."

// Text in the system font. `weight` drives both font.weight and the SFNS wght
// axis (Qt fakes bold on the variable font unless the axis is set).
Text {
    property int weight: Font.Normal
    font.family: Theme.fontText
    font.pixelSize: Theme.font.body
    font.weight: Theme.fw(weight)
    font.variableAxes: Theme.axes(weight)
    color: Theme.label
}
