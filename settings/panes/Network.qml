import QtQuick
import ".."
import "../controls"
import "../HyprK"
import "../Parsers.js" as P

// Network, 27.2.1 (R3.8b network-{00..01}-light.png; MAC-ANSWERS-13.md R13.1, live/settings-r13/dest-network*.png and
// ax-dest-network*): the services NetworkManager knows (read-only), VPN and Firewall. Every row pushes a sub-pane on
// the window's navigation (SettingsApp.qml: toolbar title, Go Back; the sidebar keeps Network): Wi-Fi is the Wi-Fi
// pane and VPN the VPN pane, Firewall and a service are panes/network/*.qml. The "…" button is the Mac's More menu.
Column {
    id: pane
    spacing: Theme.content.sectionGap
    property var devices: []
    // no Wi-Fi adapter: no Wi-Fi row (AppState.hw, FALLBACKS.md "Absent hardware"); the rows under it move up
    readonly property var shownDevices: devices.filter(d => d.type !== "wifi" || AppState.hw.wifi)
    property string page: ""          // "" = the root, "wifi", "vpn", "firewall" or "svc:<device>"
    // the firewall: no backend, the Mac's value (on) kept while the pane is open (settings/FALLBACKS.md)
    property bool firewallOn: true
    readonly property var service: page.indexOf("svc:") === 0 ? devices.find(d => d.device === page.slice(4)) || null : null
    readonly property string pageTitle: page === "wifi" ? "Wi‑Fi" : page === "vpn" ? "VPN" : page === "firewall" ? "Firewall"
                                       : service ? serviceName(service) : ""
    function serviceName(d) { return d.type === "wifi" ? "Wi‑Fi" : d.type === "ethernet" ? "Ethernet" : d.device; }
    function serviceIcon(d) { return d.type === "wifi" ? "wifi" : d.type === "ethernet" ? "network-ethernet" : "vpn"; }
    function refresh() {
        Backend.run(["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device"], (c, o) => {
            devices = P.parseNmcliDevices(o).filter(d => ["ethernet", "wifi", "vpn", "wireguard", "bt"].indexOf(d.type) !== -1);
        });
    }
    Component.onCompleted: refresh()
    EventSource { command: ["nmcli", "monitor"]; onChanged: pane.refresh() }

    // rows 52 with the state under the name after a coloured dot, a chevron; the connected services first, then VPN
    // and Firewall, then "Other Services" (the rest)
    component Chevron: Item {
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        width: 6; height: 10
        SfSymbol { name: "chevron.forward"; weight: "semibold"; pointSize: 10.5; color: Theme.tertiaryLabel }
    }
    component Service: FormRow {
        implicitHeight: Positioner.index > 0 ? 53 : 52
        Chevron {}
    }
    component Device: Service {
        required property var modelData
        readonly property bool up: modelData.state.startsWith("connected")
        objectName: "networkRow-" + modelData.device
        iconId: pane.serviceIcon(modelData)
        label: pane.serviceName(modelData)
        sublabel: up ? "Connected" : "Not connected"   // 27.2.1 "Not connected" (ax-network-light.jsonl)
        subdot: up ? Theme.tile.green : Theme.tile.red
        onClicked: pane.page = modelData.type === "wifi" ? "wifi" : "svc:" + modelData.device
    }
    readonly property var upDevices: shownDevices.filter(d => d.state.startsWith("connected"))
    readonly property var downDevices: shownDevices.filter(d => !d.state.startsWith("connected"))
    Card {
        visible: pane.page === "" && pane.upDevices.length > 0
        Repeater { model: pane.upDevices; Device {} }
    }
    Card {
        visible: pane.page === ""
        Service { objectName: "networkRow-vpn"; iconId: "vpn"; label: "VPN"; sublabel: "Not configured"; onClicked: pane.page = "vpn" }   // Network.appex "Not Configured" key, en value
        Service {
            objectName: "networkRow-firewall"
            iconId: "network-firewall"; label: "Firewall"
            sublabel: pane.firewallOn ? "Active" : "Inactive"; subdot: pane.firewallOn ? Theme.tile.green : Theme.tile.red
            onClicked: pane.page = "firewall"
        }
    }
    Card {
        visible: pane.page === "" && pane.downDevices.length > 0
        title: "Other Services"
        Repeater { model: pane.downDevices; Device {} }
    }
    // More (AXMenuButton "ellipsis" 61.5 x 24; popups.json "network", pop-network-00-dark.png; items and submenus as
    // MAC-ANSWERS-14.md R14.1 lists them): the menu opens over the button. What its items open is not on a shot: a pick
    // closes the menu.
    PaneFooter {
        visible: pane.page === ""
        PullDown {
            objectName: "networkMore"
            above: true
            items: [
                { title: "Add Service…" },
                { title: "Add VPN Configuration", sub: [{ title: "L2TP over IPSec…" }, { title: "Cisco IPSec…" }, { title: "IKEv2…" }] },
                { sep: true },
                { title: "Manage Virtual Interfaces…" },
                { title: "Set Service Order…" },
                { sep: true },
                { title: "Locations", sub: [{ title: "Automatic", checked: true }, { sep: true }, { title: "Edit Locations…" }] }
            ]
        }
    }
    // ---------- sub-pane ----------
    Loader {
        id: sub
        objectName: "networkSub"
        width: parent.width
        function load() {
            if (pane.page === "wifi") setSource("WiFi.qml");
            else if (pane.page === "vpn") setSource("VPN.qml");
            else if (pane.page === "firewall") setSource("network/Firewall.qml", { pane: pane });
            else if (pane.service) setSource("network/Service.qml", { pane: pane, dev: pane.service });
            else source = "";
        }
        Connections { target: pane; function onPageChanged() { sub.load(); } }
    }
}
