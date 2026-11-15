import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Networking
import Quickshell.Services.UPower
import qs
import qs.components
import qs.HyprK
import qs.services
import "../lib/spring.js" as SpringLib
import "../lib/state.js" as State
import "../lib/statusmodule.js" as SM

// The module a menu bar status item opens (macOS 27.2.1: Wi-Fi, Battery, Focus each open their ControlCenter module
// in a ModuleWindow under the item, not Control Center; reference/re/27.2.1/STATUS-REA-27.2.1.md). Placement from
// MenuPositionCoordinator (lib/statusmodule.js placeX) on the open item's pill, 1 pt under the bar (the Mac shots,
// lib/statusmodule.js top / pillInset). The menus' layer (hyprk-overlay: the plugin's menu glass, Regular with the
// menu shadow), not Control Center's: the Mac's panel is light glass in light and dark glass in dark (the module
// shots), the tiles' glass is dark in both. Opens and closes on Control Center's spring (REA section 2,
// ControlCenterWindow.qml); a click outside or Esc closes it, a click on the item again closes it (Panels.toggle).
ShellWindow {
    id: smw

    required property var modelData
    screen: modelData

    readonly property var kinds: ["wifi", "battery", "focus"]
    readonly property bool shown: kinds.indexOf(Panels.open) >= 0 && Panels.activeScreen === modelData
    property string kind: ""
    visible: shown || fadeAnim.running

    anchors { top: true; left: true; right: true; bottom: true }
    margins.top: Theme.menuBar.height
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-overlay"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    property real fade: 0
    readonly property var fadeSpring: SpringLib.fromBounce(0.25, -0.027)
    SpringCurve { id: fadeAnim; target: smw; property: "fade"; spring: smw.fadeSpring; settlesGlass: true }
    onShownChanged: {
        if (shown) { kind = Panels.open; otherExpanded = false; }
        fadeAnim.go(shown ? 1 : 0);
    }
    // a click on another module's item while one is open swaps it at once
    Connections {
        target: Panels
        function onOpenChanged() { if (smw.shown) smw.kind = Panels.open; }
    }
    glassMaterialize: 1
    glassOpacity: fade
    acceptsInput: shown
    MouseArea { anchors.fill: parent; enabled: smw.shown; onPressed: Panels.close() }
    Item { anchors.fill: parent; focus: true; Keys.onEscapePressed: Panels.close() }

    // ---- data ----
    readonly property var wifiDev: State.wifiDevice(Networking.devices.values)
    // the scanner runs only while the Wi-Fi module is open (a scan changes no connection)
    Binding { target: smw.wifiDev; property: "scannerEnabled"; value: true; when: smw.shown && smw.kind === "wifi" && smw.wifiDev !== null }
    property bool otherExpanded: false      // the Mac shots: Other Networks shown collapsed (C: a disclosure control)
    readonly property var nets: wifiDev ? wifiDev.networks.values.map(n => ({
        name: n.name, known: n.known, connected: n.connected, strength: n.signalStrength,
        secure: n.security !== WifiSecurityType.Open })) : []
    readonly property var battery: UPower.displayDevice
    function batteryStateName(s) {
        return s === UPowerDeviceState.Charging ? "charging" : s === UPowerDeviceState.Discharging ? "discharging"
             : s === UPowerDeviceState.FullyCharged ? "full" : s === UPowerDeviceState.PendingCharge ? "pending" : "other";
    }
    // HYPRK_STATUS_STUB=1 (tests only): made-up networks and battery in the Mac shots' states (one known network,
    // connected and secured; on the adapter, fully charged), and no row, switch or toggle reaches the real network or
    // Focus state
    readonly property bool stub: Quickshell.env("HYPRK_STATUS_STUB") === "1"
    readonly property var stubNets: [
        { name: "Home", known: true, connected: true, strength: 1, secure: true },
        { name: "Cafe Guest", known: false, connected: false, strength: 0.7, secure: false },
        { name: "Neighbour 5G", known: false, connected: false, strength: 0.4, secure: true }]
    readonly property var rows: kind === "wifi"
        ? SM.wifiRows({ available: stub || wifiDev !== null, on: stub || (wifiDev !== null && Networking.wifiEnabled),
                        networks: stub ? stubNets : nets, otherExpanded: otherExpanded })
        : kind === "battery" && stub
        ? SM.batteryRows({ percent: 1, state: "full", minutesToFull: 0, showPercentInBar: false })
        : kind === "battery"
        ? SM.batteryRows({ percent: battery.percentage, state: batteryStateName(battery.state),
                           minutesToFull: battery.timeToFull / 60, showPercentInBar: false })   // the bar hides it (Q-menubar-29)
        : kind === "focus" ? SM.focusRows({ dnd: Notifs.dnd }) : []

    StatusModulePanel {
        id: panel
        readonly property var anchorRect: Panels.statusAnchor
        // the open item's pill (item frame + statusPillOutset a side), its edges 1 pt in (lib/statusmodule.js pillInset)
        readonly property real edge: Theme.menuBar.statusPillOutset - m.pillInset
        x: SM.placeX(anchorRect.x - edge, anchorRect.w + 2 * edge, width, smw.width)
        y: m.top
        originX: x
        originY: y + Theme.menuBar.height
        rows: smw.rows
        opacity: smw.fade
        scale: 1 + Theme.travel(0.01) * (1 - smw.fade)
        onSwitchToggled: on => { if (smw.kind === "wifi" && !smw.stub) Networking.wifiEnabled = on; }
        onDisclosureToggled: smw.otherExpanded = !smw.otherExpanded
        onRowActivated: r => {
            if (smw.stub) { console.log("hyprk: status module stub, row", r.title); return; }
            if (r.focus) { Notifs.dnd = !Notifs.dnd; return; }
            if (r.net && smw.wifiDev) {
                const n = smw.wifiDev.networks.values.find(x => x.name === r.net);
                if (n && !n.connected) n.connect();
            }
        }
        onSettingsRequested: pane => {
            Panels.close();
            const id = pane === "battery" && !State.hasBattery(UPower.devices.values) ? "energy" : pane;
            Apps.runHyprkApp("org.hyprk.Settings", { HYPRK_SETTINGS_PANE: id });
        }
        MouseArea { anchors.fill: parent; z: -1 }   // swallow clicks so they don't close
    }
}
