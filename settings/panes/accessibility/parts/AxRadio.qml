import QtQuick
import "../../../HyprK"

// A radio group in a row: buttons 16 pt apart (ax-acc-display: Smart 572 + 57.5, Classic 645.5). Keeps its own choice
// unless the caller sets currentIndex from `activated`.
Row {
    id: g
    property var model: []
    property int currentIndex: 0
    signal activated(int index)
    spacing: 16
    Repeater {
        model: g.model
        Checkbox {
            required property string modelData
            required property int index
            radio: true
            text: modelData
            enabled: g.enabled
            checked: index === g.currentIndex
            onToggled: { g.currentIndex = index; g.activated(index); }
        }
    }
}
