import QtQuick
import ".."
import "../controls"

Column {
    spacing: Theme.content.sectionGap
    Card {
        FormRow { label: "No VPN configurations"; sublabel: "VPN connections from NetworkManager will be listed here."; dim: true }
    }
    PaneFooter { MacButton { text: "Add VPN Configuration…" } }
}
