import QtQuick
import "../../.."
import "../../../HyprK"

// A number field with a stepper inside its right end and a unit after it (ax-acc-live-captions: field 80 x 24, the
// AXIncrementor its last 20 pt, "pt" 8 pt after; Switch Control's is 65 wide). Keeps its own value.
Row {
    id: s
    property real value: 0
    property real from: 0
    property real to: 999
    property string unit
    property string shown: String(value)     // what the field shows (Switch Control: "15,00")
    property real fieldWidth: 80
    spacing: 8
    function step(d) { value = Math.max(from, Math.min(to, value + d)); input.text = shown; }
    Rectangle {
        width: s.fieldWidth; height: 24; radius: 6
        color: Theme.dark ? Qt.rgba(0, 0, 0, 0.3) : "#FFFFFF"   // acc-live-captions-00-dark.png: darker than the card
        border.width: 0.5; border.color: Theme.dark ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(0, 0, 0, 0.12)
        opacity: s.enabled ? 1 : 0.5
        TextInput {
            id: input
            anchors.left: parent.left; anchors.right: arrows.left; anchors.leftMargin: 6; anchors.rightMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: TextInput.AlignRight
            clip: true; selectByMouse: true
            text: s.shown
            font: Typography.body
            color: s.enabled ? Theme.label : Tokens.control.disabledText
            validator: RegularExpressionValidator { regularExpression: /[0-9]{0,3}([.,][0-9]{0,2})?/ }
            onEditingFinished: {
                const v = parseFloat(text.replace(",", "."));
                if (isFinite(v)) s.value = Math.max(s.from, Math.min(s.to, v));
                text = s.shown;
            }
        }
        Item {
            id: arrows
            anchors.right: parent.right
            width: 20; height: parent.height
            SfSymbol { anchors.horizontalCenter: parent.horizontalCenter; y: 4.5; name: "chevron.up"; pointSize: 10.5
                       color: s.enabled ? Theme.label : Tokens.control.disabledText }
            SfSymbol { anchors.horizontalCenter: parent.horizontalCenter; y: parent.height - 4.5 - height; name: "chevron.down"; pointSize: 10.5
                       color: s.enabled ? Theme.label : Tokens.control.disabledText }
            MouseArea { width: parent.width; height: parent.height / 2; onClicked: s.step(1) }
            MouseArea { y: parent.height / 2; width: parent.width; height: parent.height / 2; onClicked: s.step(-1) }
        }
    }
    Text {
        visible: s.unit !== ""
        anchors.verticalCenter: parent.verticalCenter
        text: s.unit
        font: Typography.body
        color: s.enabled ? Theme.secondaryLabel : Tokens.control.disabledText
    }
}
