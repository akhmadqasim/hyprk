import QtQuick
import ".."
import "../controls"
import "../HyprK"
import "../Parsers.js" as P

// Read-only list of NetworkManager devices.
Column {
    id: pane
    spacing: Theme.content.sectionGap
    property var devices: []
    property string status: "loading"
    readonly property bool supported: status !== "missing" && status !== "failed"
    function refresh() {
        Backend.run(["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device"], (c, o) => {
            status = Backend.status(c);
            devices = P.parseNmcliDevices(o).filter(d => ["ethernet", "wifi", "vpn", "wireguard", "bt"].indexOf(d.type) !== -1);
        });
    }
    Component.onCompleted: refresh()
    EventSource { command: ["nmcli", "monitor"]; onChanged: pane.refresh() }

    Card {
        FormRow { visible: !pane.supported || pane.devices.length === 0; label: pane.supported ? "No network services" : "Network services can't be listed"; sublabel: Backend.statusNote(pane.status, "NetworkManager (nmcli)", "network services"); dim: true }
        Repeater {
            model: pane.devices
            FormRow {
                id: dev
                required property var modelData
                readonly property bool up: modelData.state.startsWith("connected")
                iconId: modelData.type === "wifi" ? "wifi" : modelData.type === "ethernet" ? "network-ethernet" : "vpn"
                label: modelData.type === "wifi" ? "Wi‑Fi" : modelData.type === "ethernet" ? "Ethernet" : modelData.device
                sublabel: up ? "Connected" : "Not Connected"
                Rectangle { width: 8; height: 8; radius: 4; color: dev.up ? Theme.tile.green : Theme.tertiaryLabel }
            }
        }
    }
    Card {
        FormRow { iconId: "network-firewall"; label: "Firewall"; value: "Inactive"; }
    }
    Card {
        title: "Other Services"
        FormRow { iconId: "vpn"; label: "VPN"; sublabel: "Not Configured" }
    }
    PaneFooter { Button { text: "…" } }
}
