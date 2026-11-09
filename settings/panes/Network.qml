import QtQuick
import ".."
import "../controls"
import "../Parsers.js" as P

// Read-only list of NetworkManager devices.
Column {
    id: pane
    spacing: Theme.content.sectionGap
    property var devices: []
    property bool supported: true
    Component.onCompleted: Backend.run(["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device"], (c, o) => {
        supported = c === 0;
        devices = P.parseNmcliDevices(o).filter(d => ["ethernet", "wifi", "vpn", "wireguard", "bt"].indexOf(d.type) !== -1);
    })

    Card {
        FormRow { visible: !pane.supported || pane.devices.length === 0; label: pane.supported ? "No network services" : "Network services can't be listed"; sublabel: pane.supported ? "" : "NetworkManager (nmcli) is not available."; dim: true }
        Repeater {
            model: pane.devices
            FormRow {
                id: dev
                required property var modelData
                readonly property bool up: modelData.state.startsWith("connected")
                glyph: modelData.type === "wifi" ? "wifi" : modelData.type === "ethernet" ? "settings_ethernet" : "vpn_key"
                tint: Theme.tile.blue
                label: modelData.type === "wifi" ? "Wi‑Fi" : modelData.type === "ethernet" ? "Ethernet" : modelData.device
                sublabel: up ? "Connected" : "Not Connected"
                Rectangle { width: 8; height: 8; radius: 4; color: dev.up ? Theme.tile.green : Theme.tertiaryLabel }
            }
        }
    }
    Card {
        FormRow { glyph: "local_fire_department"; tint: Theme.tile.gray; label: "Firewall"; Text { text: "Inactive"; font.family: Theme.fontText; font.pixelSize: Theme.font.body; color: Theme.secondaryLabel } }
    }
    Card {
        title: "Other Services"
        FormRow { glyph: "vpn_lock"; tint: Theme.tile.blue; label: "VPN"; sublabel: "Not Configured" }
    }
    Row { anchors.right: parent.right; spacing: 8; MacButton { text: "…" } HelpButton {} }
}
