import QtQuick
import ".."
import "../HyprK"

// Text in the system font: SF Pro at `size` pt with wght `weight` (Typography.regular 400, medium 510,
// semibold 590, bold 700), with the 27.2.1 optical size, tracking and real weights (HyprK Typography).
// Set size and weight, or a whole style (font: Typography.headline), not single font.* properties.
Text {
    property real size: Typography.styles.body.size
    property int weight: Typography.regular
    font: Typography.font(size, weight)
    color: Theme.label
}
