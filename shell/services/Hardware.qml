pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.UPower
import "../lib/state.js" as State
import "../lib/hardware.js" as HW

// Which hardware-bound items exist. The user's choice of 2026-11-15 ("wifi kalau ga ada di hidden aja", "bluetooth
// dll nya juga begitu"): an item whose hardware is absent is hidden everywhere (menu bar, Control Center, lock
// screen, Spotlight actions), never drawn off or disabled; the items around it close the gap (lib/hardware.js
// ccLayout). All three follow their service, so a dongle plugged in while running shows its items at once.
// HYPRK_HW="wifi=0,bluetooth=1,battery=0" (tests) decides an item whatever the machine has; HYPRK_STATUS_STUB=1 (the
// status modules' made-up Wi-Fi and battery) counts as a Wi-Fi adapter and a battery.
Singleton {
    id: root

    readonly property var ov: HW.overrides(Quickshell.env("HYPRK_HW"))
    readonly property bool statusStub: Quickshell.env("HYPRK_STATUS_STUB") === "1"
    readonly property bool wifi: HW.present("wifi", statusStub || State.wifiDevice(Networking.devices.values) !== null, ov)
    readonly property bool bluetooth: HW.present("bluetooth", State.hasBluetooth(Bluetooth.defaultAdapter), ov)
    readonly property bool battery: HW.present("battery", statusStub || State.hasBattery(UPower.devices.values), ov)
    readonly property bool airdrop: HW.hasAirdrop(wifi, bluetooth)
    readonly property var ccLayout: HW.ccLayout({ wifi: wifi, bluetooth: bluetooth, airdrop: airdrop })

    // qs ipc call hardware state (tests)
    IpcHandler {
        target: "hardware"
        function state(): string {
            return JSON.stringify({ wifi: root.wifi, bluetooth: root.bluetooth, battery: root.battery, airdrop: root.airdrop,
                                    ccLayout: root.ccLayout });
        }
    }
}
