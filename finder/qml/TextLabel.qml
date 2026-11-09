import QtQuick

// Text in the UI font (not named Label: QtQuick.Controls has one). `weight` drives both the static weight and SF's variable wght axis,
// and pins SF's text optical size (its default instance is the display cut).
Text {
    property int weight: Font.Normal

    color: Theme.color.label
    font.family: Theme.fontText
    font.weight: weight
    font.variableAxes: ({ "wght": weight, "opsz": 17 })
}
