import QtQuick
import ".."
import "../HyprK"

// Calm one-line explanation shown instead of raw errors.
Row {
    id: n
    property string text
    spacing: 6
    visible: text !== ""
    SfSymbol {   // info.circle at the text's size (hyprk's own control: no Mac measure)
        name: "info.circle"; pointSize: 11
        color: Theme.secondaryLabel
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        width: Math.min(implicitWidth, (n.parent ? n.parent.width : 400) - 24)
        wrapMode: Text.WordWrap
        text: n.text
        font: Typography.subheadline
        color: Theme.secondaryLabel
        anchors.verticalCenter: parent.verticalCenter
    }
}
