import QtQuick
import HyprK

// Text in the UI font (not named Label: QtQuick.Controls has one): SF Pro at `size` pt with wght `weight`
// (Typography.regular 400, medium 510, semibold 590, bold 700), with the 27.2.1 optical size, tracking and
// real weights (HyprK Typography). Set size and weight (or a whole font: Typography.x), not single font.*.
Text {
    property real size: Theme.font.list
    property int weight: Typography.regular

    color: Theme.color.label
    font: Typography.font(size, weight)
}
