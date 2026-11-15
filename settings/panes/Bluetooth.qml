import QtQuick
import ".."
import "../controls"
import "../HyprK"
import "../Parsers.js" as P

// Functional via bluetoothctl. No bluetoothctl or no controller: the Bluetooth switch is disabled.
Column {
    id: pane
    spacing: Theme.content.sectionGap

    property string status: "loading"    // loading | missing | nocontroller | ok
    property var ctl: P.parseBluetoothShow("")
    property var devices: []
    property var connected: []

    function refresh() {
        Backend.run(["timeout", "4", "bluetoothctl", "show"], (code, out) => {
            if (Backend.status(code) === "missing") { status = "missing"; return; }
            ctl = P.parseBluetoothShow(out);
            if (!ctl.available) { status = "nocontroller"; return; }
            status = "ok";
            Backend.run(["timeout", "4", "bluetoothctl", "devices", "Paired"], (c, o) => devices = P.parseBluetoothDevices(o));
            Backend.run(["timeout", "4", "bluetoothctl", "devices", "Connected"], (c, o) => connected = P.parseBluetoothDevices(o).map(d => d.mac));
        });
    }
    function cmd(args) {
        Backend.run(["timeout", "15"].concat(["bluetoothctl"], args), () => refresh());
    }
    Component.onCompleted: refresh()
    // BlueZ property changes (power, connect, pairing) arrive as D-Bus signals.
    EventSource {
        // property changes, plus devices appearing/disappearing (ObjectManager)
        command: ["dbus-monitor", "--system",
                  "type='signal',interface='org.freedesktop.DBus.Properties',path_namespace='/org/bluez'",
                  "type='signal',sender='org.bluez',interface='org.freedesktop.DBus.ObjectManager'"]
        onChanged: pane.refresh()
    }

    // 27.2.1 (R3.8b bluetooth-{00..01}-light.png, ax-bluetooth-light.jsonl): the hero line with the switch at its top,
    // then the "discoverable as" line on a card of its own (blurred on the shot), then My Devices
    Card {
        FormRow {
            iconId: "bluetooth"
            iconSize: 26
            label: "Bluetooth"
            sublabel: "Connect to accessories you can use for activities such as streaming music, typing and gaming."
            sublink: "Learn more…"
            helpAnchor: "blth1004"   // ax-bluetooth-light.jsonl
            Switch { checked: pane.ctl.powered; enabled: pane.status === "ok"; onToggled: on => { pane.ctl = Object.assign({}, pane.ctl, { powered: on }); pane.cmd(["power", on ? "on" : "off"]); } }
        }
    }
    Card {
        visible: pane.ctl.powered
        // Bluetooth.appex now_discoverable_as_mac: one secondary line on the shot (blurred there, its ink ~11 pt tall
        // across most of the card), so the 11 pt subheadline, 10 in, centred in a 38 pt card
        Item {
            width: parent.width; height: 38
            Text {
                x: Theme.content.rowPadding; width: parent.width - 2 * x; anchors.verticalCenter: parent.verticalCenter
                wrapMode: Text.WordWrap
                text: "This Mac is discoverable as “" + pane.ctl.name + "” while Bluetooth Settings is open."
                font: Typography.subheadline
                color: Theme.secondaryLabel
            }
        }
    }

    Card {
        visible: pane.status === "ok" && pane.ctl.powered
        title: "My Devices"
        FormRow { visible: pane.devices.length === 0; label: "No Bluetooth Devices"; dim: true }   // Bluetooth.appex empty_connected_paired_devices
        Repeater {
            model: pane.devices
            FormRow {
                id: dev
                required property var modelData
                readonly property bool isOn: pane.connected.indexOf(modelData.mac) !== -1
                // by the device's name; the tiles are hyprk's choice (the Mac's device rows were not read)
                iconId: /airpod|bud|head|phone|speaker/i.test(modelData.name) ? "bluetooth-headphones" : /mouse/i.test(modelData.name) ? "mouse" : /keyboard/i.test(modelData.name) ? "keyboard" : "bluetooth"
                label: modelData.name
                sublabel: isOn ? "Connected" : "Not Connected"
                Button {
                    text: dev.isOn ? "Disconnect" : "Connect"
                    onClicked: pane.cmd([dev.isOn ? "disconnect" : "connect", modelData.mac])
                }
            }
        }
    }

    Card {
        visible: pane.status === "ok" && pane.ctl.powered
        title: "Nearby Devices"
        FormRow { label: "Searching…"; dim: true }
    }

    PaneFooter { Button { text: "Advanced…"; enabled: pane.status === "ok" } }
}
