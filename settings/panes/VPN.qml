import QtQuick
import ".."
import "../controls"
import "../HyprK"

// VPN, 27.2.1 (the pane and Network's VPN row show the same: MAC-ANSWERS-13.md R13.1, live/settings-r13/
// dest-network--vpn-*.png, ax-dest-network--vpn-*): the configurations (the Mac's own, redacted; none here), then
// "About VPNs & Privacy…" at the left (167.5 x 24), the Add menu button ("plus", 61 x 24) and Help at the right.
// The Add menu (MAC-ANSWERS-14.md R14.1: 142 x 82, opening below the button): "L2TP over IPSec…", "Cisco IPSec…",
// "IKEv2…". No VPN backend: a pick closes the menu (settings/FALLBACKS.md).
Column {
    spacing: Theme.content.sectionGap
    Card {
        FormRow { label: "No VPN configurations"; dim: true }
    }
    Item {
        width: parent.width; height: 34
        Button { y: 10; text: "About VPNs & Privacy…" }
        Row {
            anchors.right: parent.right; y: 10; spacing: 10
            PullDown {
                objectName: "vpnAdd"
                width: 61; glyph: "plus"
                items: [{ title: "L2TP over IPSec…" }, { title: "Cisco IPSec…" }, { title: "IKEv2…" }]
            }
            HelpButton {}
        }
    }
}
