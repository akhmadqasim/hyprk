import QtQuick
import ".."
import "../HyprK"

// chevron.forward at the end of a row that pushes a sub-pane (as Accessibility's and General's rows: semibold 10.5 pt,
// the ink's right edge 10.5 pt inside the card)
// It sits on the row's centre, also in a row with a sublabel (where FormRow puts its controls on the label's line).
Item {
    id: nav
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    width: 6; height: 10
    transform: Translate { y: nav.parent && nav.parent.parent ? nav.parent.parent.height / 2 - (nav.parent.y + nav.parent.height / 2) : 0 }
    SfSymbol { name: "chevron.forward"; weight: "semibold"; pointSize: 10.5; color: Theme.tertiaryLabel }
}
