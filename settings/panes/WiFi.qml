import QtQuick
import ".."
import "../controls"
import "../HyprK"
import "../Parsers.js" as P

// Functional via nmcli. States: nmcli missing / NM not running, no Wi-Fi
// hardware (macOS: "No hardware installed"), radio off, list of networks.
Column {
    id: pane
    spacing: Theme.content.sectionGap

    property string status: "loading"    // loading | missing | failed | nohw | ok
    property var device: null
    property bool radioOn: false
    property var networks: []
    property string note: ""
    property bool scanning: false

    function refresh() {
        Backend.run(["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device"], (code, out) => {
            status = Backend.status(code);
            if (status !== "ok") return;
            device = P.wifiDevice(P.parseNmcliDevices(out));
            if (!device) { status = "nohw"; return; }
            status = "ok";
            Backend.run(["nmcli", "-t", "radio", "wifi"], (c, o) => {
                radioOn = o.trim() === "enabled";
                if (radioOn) listNetworks();
            });
        });
    }
    function listNetworks() {
        scanning = true;
        Backend.run(["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi", "list", "--rescan", "no"], (c, o) => {
            scanning = false;
            networks = c === 0 ? P.parseNmcliWifi(o) : [];
        });
    }
    // the switch shows the new state at once (like macOS); refresh() puts it back if nmcli fails
    function setRadio(on) {
        note = "";
        radioOn = on;
        Backend.run(["nmcli", "radio", "wifi", on ? "on" : "off"], c => {
            if (c !== 0) note = "Wi‑Fi could not be turned " + (on ? "on" : "off") + ". You may need permission from NetworkManager.";
            refresh();
        });
    }
    function join(ssid) {
        note = "Joining “" + ssid + "”…";
        Backend.run(["nmcli", "dev", "wifi", "connect", ssid], c => {
            note = c === 0 ? "" : "Could not join “" + ssid + "”. Networks with a password must be joined once from nmtui or nm-applet.";
            refresh();
        });
    }
    Component.onCompleted: refresh()
    EventSource { command: ["nmcli", "monitor"]; onChanged: pane.refresh() }
    // nmcli monitor doesn't report new access points; rescan the list slowly.
    Timer { interval: 10000; running: pane.status === "ok" && pane.radioOn; repeat: true; onTriggered: pane.listNetworks() }

    readonly property var current: networks.find(n => n.inUse) || null
    readonly property var others: networks.filter(n => !n.inUse)

    Card {
        FormRow {
            iconId: "wifi"
            label: "Wi‑Fi"
            sublabel: pane.status === "nohw" ? "No hardware installed"
                    : pane.status === "missing" || pane.status === "failed" ? "Not available on this system"
                    : pane.status === "ok" && pane.radioOn && pane.current ? "Connected" : ""
            Switch {
                enabled: pane.status === "ok"
                checked: pane.status === "ok" && pane.radioOn
                onToggled: on => pane.setRadio(on)
            }
        }
        FormRow {
            visible: pane.current !== null && pane.radioOn
            label: pane.current ? pane.current.ssid : ""
            sublabel: "Connected"
            // lock.fill and wifi: .font(.system(size: 14)), no weight, in the network row of WiFiSettingsKit 27.2.1
            // (Font.system(size:weight:design:) called with 14.0 at 0x2b4e44e7c for lock.fill and at 0x2b4e44bb8 for
            // Image(systemName: "wifi", variableValue: bars / 3)). Colours not decoded, no Mac shot of this pane.
            SfSymbol { visible: pane.current !== null && pane.current.secure; anchors.verticalCenter: parent ? parent.verticalCenter : undefined; name: "lock.fill"; pointSize: 14; color: Theme.secondaryLabel }
            SfSymbol { anchors.verticalCenter: parent ? parent.verticalCenter : undefined; name: "wifi"; pointSize: 14; color: Theme.label }
            Button { text: "Details…" }
        }
    }

    InlineNote {
        text: pane.status === "missing" || pane.status === "failed" ? Backend.statusNote(pane.status, "NetworkManager (nmcli)", "Wi‑Fi")
            : pane.status === "nohw" ? "This computer has no Wi‑Fi adapter. Wired connections are in Network."
            : pane.note
    }

    Card {
        visible: pane.status === "ok" && pane.radioOn
        title: "Other Networks"
        FormRow {
            visible: pane.others.length === 0
            label: pane.scanning ? "Searching…" : "No networks found"
            dim: true
        }
        Repeater {
            model: pane.others
            FormRow {
                required property var modelData
                label: modelData.ssid
                onClicked: pane.join(modelData.ssid)
                SfSymbol { visible: modelData.secure; anchors.verticalCenter: parent ? parent.verticalCenter : undefined; name: "lock.fill"; pointSize: 14; color: Theme.secondaryLabel }
                SfSymbol {   // the variable symbol's 2 and 1 bar states (the Mac passes bars / 3; CoreGlyphs wifi at 0.5 and 0.2)
                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                    name: modelData.signal > 66 ? "wifi" : modelData.signal > 33 ? "wifi.var-50" : "wifi.var-20"
                    pointSize: 14; color: Theme.label
                }
            }
        }
    }

    Card {
        FormRow { label: "Ask to join networks"; sublabel: "Known networks will be joined automatically."; LocalPopup { model: ["Off", "Notify", "Ask"]; currentIndex: 1; enabled: pane.status === "ok" } }
        FormRow { label: "Ask to join hotspots"; LocalPopup { model: ["Never", "Ask to Join", "Automatic"]; currentIndex: 1; enabled: pane.status === "ok" } }
    }

    PaneFooter { Button { text: "Advanced…"; enabled: pane.status === "ok" } }
}
