import QtQuick
import ".."
import "../controls"
import "../Parsers.js" as P

// Functional via bluetoothctl. No controller -> "Bluetooth Unavailable" like macOS.
Column {
    id: pane
    spacing: Theme.content.sectionGap

    property string status: "loading"    // loading | unsupported | nocontroller | ok
    property var ctl: P.parseBluetoothShow("")
    property var devices: []
    property var connected: []
    property string note: ""

    function refresh() {
        Backend.run(["timeout", "4", "bluetoothctl", "show"], (code, out) => {
            if (code === 127) { status = "unsupported"; return; }
            ctl = P.parseBluetoothShow(out);
            if (!ctl.available) { status = "nocontroller"; return; }
            status = "ok";
            Backend.run(["timeout", "4", "bluetoothctl", "devices", "Paired"], (c, o) => devices = P.parseBluetoothDevices(o));
            Backend.run(["timeout", "4", "bluetoothctl", "devices", "Connected"], (c, o) => connected = P.parseBluetoothDevices(o).map(d => d.mac));
        });
    }
    function cmd(args, failMsg) {
        note = "";
        Backend.run(["timeout", "15"].concat(["bluetoothctl"], args), c => { if (c !== 0) note = failMsg; refresh(); });
    }
    Component.onCompleted: refresh()
    Timer { interval: 5000; running: pane.status === "ok"; repeat: true; onTriggered: pane.refresh() }

    Unavailable {
        visible: pane.status === "nocontroller" || pane.status === "unsupported"
        glyph: "bluetooth_disabled"
        title: "Bluetooth Unavailable"
        text: pane.status === "unsupported" ? "BlueZ (bluetoothctl) is not installed." : "No Bluetooth controller was found. Connect a Bluetooth adapter to use wireless devices."
    }

    Card {
        visible: pane.status === "ok" || pane.status === "loading"
        FormRow {
            glyph: "bluetooth"; tint: Theme.tile.blue
            label: "Bluetooth"
            sublabel: pane.ctl.powered ? "Now discoverable as “" + pane.ctl.name + "”." : ""
            MacSwitch { checked: pane.ctl.powered; enabled_: pane.status === "ok"; onToggled: on => pane.cmd(["power", on ? "on" : "off"], "Bluetooth could not be turned " + (on ? "on." : "off.")) }
        }
    }

    InlineNote { text: pane.note }

    Card {
        visible: pane.status === "ok" && pane.ctl.powered
        title: "My Devices"
        FormRow { visible: pane.devices.length === 0; label: "No paired devices"; dim: true }
        Repeater {
            model: pane.devices
            FormRow {
                id: dev
                required property var modelData
                readonly property bool isOn: pane.connected.indexOf(modelData.mac) !== -1
                glyph: /airpod|bud|head|phone|speaker/i.test(modelData.name) ? "headphones" : /mouse/i.test(modelData.name) ? "mouse" : /keyboard/i.test(modelData.name) ? "keyboard" : "bluetooth"
                tint: Theme.tile.gray
                label: modelData.name
                sublabel: isOn ? "Connected" : "Not Connected"
                MacButton {
                    text: dev.isOn ? "Disconnect" : "Connect"
                    onClicked: pane.cmd([dev.isOn ? "disconnect" : "connect", modelData.mac], "Couldn't reach “" + modelData.name + "”. Make sure it's turned on and nearby.")
                }
            }
        }
    }

    Card {
        visible: pane.status === "ok" && pane.ctl.powered
        title: "Nearby Devices"
        FormRow { label: "Searching…"; dim: true }
    }

    Row { anchors.right: parent.right; spacing: 8; MacButton { text: "Advanced…"; enabled_: pane.status === "ok" } HelpButton {} }
}
