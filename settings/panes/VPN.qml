import QtQuick
import ".."
import "../controls"
import "../HyprK"

Column {
    spacing: Theme.content.sectionGap
    Card {
        FormRow { label: "No VPN configurations"; sublabel: "VPN connections from NetworkManager will be listed here."; dim: true }
    }
    PaneFooter { Button { text: "Add VPN Configuration…" } }
}
