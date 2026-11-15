import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > RTT (ax-acc-rtt-00). No backend: the controls keep their own state. The row's tile is not extracted
// from the Mac yet: a plain green tile.
AxPage {
    Card {
        AxRow { h: 51; labelY: 17; ctlY: 26; iconId: "ax-rtt"; iconSize: 28; tint: Theme.tile.green; label: "RTT"
                LocalSwitch { controlSize: "small" } }
        AxRow { h: 67; label: "Send immediately"; subWidth: 352.5
                sub: "Send characters as they are typed. Turn off to complete messages before sending."
                LocalSwitch { checked: true } }
        AxRow { h: 66; label: "RTT relay number"; subWidth: 207.5
                sub: "The phone number to use to start relay calls with software RTT/Textphone."
                TextInput {
                    id: relay
                    width: 232.5; height: 16
                    horizontalAlignment: TextInput.AlignRight
                    clip: true; selectByMouse: true
                    font: Typography.body
                    color: Theme.label
                    Text { anchors.right: parent.right; visible: relay.text === ""; text: "Enter relay number"
                           font: Typography.body; color: Theme.tertiaryLabel }
                } }
    }
    PaneFooter {}
}
