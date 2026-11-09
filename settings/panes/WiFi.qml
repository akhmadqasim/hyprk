import QtQuick
import ".."
import "../controls"
import "../Parsers.js" as P

// Functional via nmcli. States: nmcli missing / NM not running, no Wi-Fi
// hardware (macOS: "No hardware installed"), radio off, list of networks.
Column {
    id: pane
    spacing: Theme.content.sectionGap

    property string status: "loading"    // loading | unsupported | nohw | ok
    property var device: null
    property bool radioOn: false
    property var networks: []
    property string note: ""
    property bool scanning: false

    function refresh() {
        Backend.run(["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device"], (code, out) => {
            if (code !== 0) { status = "unsupported"; return; }
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
        Backend.run(["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi", "list"], (c, o) => {
            scanning = false;
            networks = c === 0 ? P.parseNmcliWifi(o) : [];
        });
    }
    function setRadio(on) {
        note = "";
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
    Timer { interval: 10000; running: pane.status === "ok" && pane.radioOn; repeat: true; onTriggered: pane.listNetworks() }

    readonly property var current: networks.find(n => n.inUse) || null
    readonly property var others: networks.filter(n => !n.inUse)

    Card {
        FormRow {
            glyph: "wifi"; tint: Theme.tile.blue
            label: "Wi‑Fi"
            sublabel: pane.status === "nohw" ? "No hardware installed"
                    : pane.status === "unsupported" ? "Not available on this system"
                    : pane.status === "ok" && pane.radioOn && pane.current ? "Connected" : ""
            MacSwitch {
                enabled_: pane.status === "ok"
                checked: pane.status === "ok" && pane.radioOn
                onToggled: on => pane.setRadio(on)
            }
        }
        FormRow {
            visible: pane.current !== null && pane.radioOn
            label: pane.current ? pane.current.ssid : ""
            sublabel: "Connected"
            Text { text: pane.current && pane.current.secure ? "lock" : ""; font.family: Theme.fontGlyph; font.pixelSize: 14; color: Theme.secondaryLabel }
            Text { text: "wifi"; font.family: Theme.fontGlyph; font.pixelSize: 16; color: Theme.label }
            MacButton { text: "Details…" }
        }
    }

    InlineNote {
        text: pane.status === "unsupported" ? "NetworkManager (nmcli) is not available, so Wi‑Fi can't be managed here."
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
                Text { text: modelData.secure ? "lock" : ""; font.family: Theme.fontGlyph; font.pixelSize: 14; color: Theme.secondaryLabel }
                Text {
                    text: modelData.signal > 66 ? "wifi" : modelData.signal > 33 ? "wifi_2_bar" : "wifi_1_bar"
                    font.family: Theme.fontGlyph; font.pixelSize: 16; color: Theme.label
                }
            }
        }
    }

    Card {
        FormRow { label: "Ask to join networks"; sublabel: "Known networks will be joined automatically."; MacPopup { model: ["Off", "Notify", "Ask"]; currentIndex: 1; enabled_: pane.status === "ok" } }
        FormRow { label: "Ask to join hotspots"; MacPopup { model: ["Never", "Ask to Join", "Automatic"]; currentIndex: 1; enabled_: pane.status === "ok" } }
    }

    Row {
        anchors.right: parent.right
        spacing: 8
        MacButton { text: "Advanced…"; enabled_: pane.status === "ok" }
        HelpButton {}
    }
}
