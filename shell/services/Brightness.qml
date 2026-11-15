pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../lib/hardware.js" as HW

// Display brightness: the one backend of the Control Center Display slider, Settings > Displays' Brightness slider,
// the brightness keys and the HUD.
// - `mode` "backlight": a backlight class device through brightnessctl (laptops).
// - `mode` "ddc": external monitors through DDC/CI VCP 10 (ddcutil; scripts/brightness.sh). One level for all of them.
// - `mode` "": neither works. `available` is false and both sliders are disabled, as the Mac's on a display it
//   cannot dim. A monitor that sleeps or shows another input does not answer DDC, so the hardware is looked at
//   again (probe()) when Control Center opens and when Settings > Displays asks.
// Every command is a Process (never on the UI thread). Writes are throttled: one runs at a time and the newest level
// goes out when it ends, so a drag sends as many DDC writes as the monitors can take (about 0.1 s each) and no more.
// Settings is another process: $HYPRK_STATE/brightness.json { value, available, source, probe } carries the state
// both ways, like the other state files (Prefs.qml, settings/AppState.qml). This service writes it on every change
// (at most every 50 ms); a value Settings writes there is applied here; Settings raises `probe` to ask for a new look.
Singleton {
    id: root

    // HYPRK_BRIGHTNESS_STUB (headless test sessions only): "1" = a made-up backlight kept in memory, at 0.6, no
    // command is ever run, so a test can drag the sliders on a machine without a backlight (and never dims a real
    // display); "none" = no brightness control at all, whatever the machine has
    readonly property string stubEnv: Quickshell.env("HYPRK_BRIGHTNESS_STUB") || ""
    readonly property bool stub: stubEnv === "1"
    readonly property bool fixed: stub || stubEnv === "none"
    property string mode: stub ? "stub" : ""          // "" | "stub" | "backlight" | "ddc"
    readonly property bool available: mode !== ""
    property real value: stub ? 0.6 : 1.0
    property bool ready: fixed                          // the hardware has been looked at once
    property var ddc: []                                // [{ bus, max }]
    readonly property string script: Quickshell.shellDir + "/scripts/brightness.sh"

    // quiet: a change from Settings (no HUD, as the Mac's slider there)
    function set(v, quiet) {
        if (!available) return;
        v = HW.level(v);
        if (v === value) return;
        value = v;
        sets++;
        if (mode === "backlight") { if (quiet) Hud.brightnessQuietUntil = Date.now() + 1000; }
        else Hud.brightness = v;
        apply();
        publish();
    }
    // a brightness key: dir +1 / -1, n = 16 (Option+Shift: 64) steps over the range, then the HUD
    function step(dir, n) {
        if (!available) return;
        if (mode === "backlight") {
            // brightnessctl takes whole percents only, so the step is in raw units of max/n; -n1 keeps the backlight
            // on at the bottom. The sysfs watch (Hud.qml) shows the HUD and brings the level back here
            keyProc.command = ["sh", "-c", "brightnessctl -q -n1 set $(( ($(brightnessctl max) + " + Math.floor(n / 2) + ") / " + n + " ))" + (dir > 0 ? "+" : "-")];
            keyProc.running = true;
            return;
        }
        set(HW.stepLevel(value, dir, n), false);
        Hud.brightness = value;      // also at the ends, where the level stays: the Mac shows the HUD on every step
        Hud.show("brightness");
    }

    // ---------- writes: one at a time, the newest level when it ends ----------
    property real sent: -1
    property int sets: 0
    function apply() {
        if (writer.running || value === sent) return;
        if (mode === "backlight") writer.command = ["brightnessctl", "-q", "-c", "backlight", "set", Math.round(value * 100) + "%"];
        else if (mode === "ddc") writer.command = [script, "set", String(value)].concat(ddc.map(d => d.bus + ":" + d.max));
        else return;
        sent = value;
        writer.running = true;
    }
    Process { id: writer; onExited: root.apply() }
    Process { id: keyProc }

    // the backlight moved (keys, another tool): follow it. A difference under a percent is brightnessctl's rounding
    // of our own write, and following that would pull the knob under the pointer
    Connections {
        target: Hud
        enabled: root.mode === "backlight"
        function onBacklightLevelChanged() {
            if (Hud.backlightLevel < 0 || writer.running || Math.abs(Hud.backlightLevel - root.value) <= 0.011) return;
            root.value = HW.level(Hud.backlightLevel);
            root.sent = root.value;
            root.publish();
        }
    }

    // ---------- the hardware ----------
    property double lastProbe: 0
    property int probeSets: 0
    function probe() {
        if (fixed || prober.running || writer.running || Date.now() - lastProbe < 5000) return;
        lastProbe = Date.now();
        probeSets = sets;
        prober.running = true;
    }
    Process {
        id: prober
        command: [root.script, "probe"]
        stdout: StdioCollector { onStreamFinished: root.probed(HW.parseProbe(text)) }
    }
    function probed(p) {
        ddc = p.ddc;
        mode = p.mode;
        // a level set while the probe ran is newer than what it read
        if (p.mode !== "" && sets === probeSets) { value = HW.level(p.value); sent = value; }
        if (mode === "ddc") Hud.brightness = value;
        ready = true;
        publish();
    }
    Component.onCompleted: { if (stub) Hud.brightness = value; probe(); }
    Connections {
        target: Panels
        function onOpenChanged() { if (Panels.open === "cc") root.probe(); }
    }

    // ---------- the keys (config/hypr/hyprland.lua: XF86MonBrightnessUp / Down, Alt+Shift for the 1/64 step) ----------
    GlobalShortcut { appid: "hyprk"; name: "brightness-up"; description: "Brightness up"; onPressed: root.step(1, 16) }
    GlobalShortcut { appid: "hyprk"; name: "brightness-down"; description: "Brightness down"; onPressed: root.step(-1, 16) }
    GlobalShortcut { appid: "hyprk"; name: "brightness-up-fine"; description: "Brightness up, 1/64"; onPressed: root.step(1, 64) }
    GlobalShortcut { appid: "hyprk"; name: "brightness-down-fine"; description: "Brightness down, 1/64"; onPressed: root.step(-1, 64) }

    // ---------- $HYPRK_STATE/brightness.json ----------
    property int probeToken: 0
    property var fileState: null        // what the file holds (HW.parseState)
    property bool fileSeen: false       // the file as a session before this one left it has been read (or is not there)
    function stateObj() { return { value: value, available: available, source: mode, probe: probeToken }; }
    function publish() { if (ready && fileSeen && !pub.running) pub.start(); }
    Timer {
        id: pub
        interval: 50
        onTriggered: {
            const o = root.stateObj();
            if (HW.sameState(root.fileState, o)) return;
            root.fileState = o;
            file.setText(JSON.stringify(o, null, 2) + "\n");
        }
    }
    FileView {
        id: file
        path: (Quickshell.env("HYPRK_STATE") || Quickshell.shellDir + "/../state") + "/brightness.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            const o = HW.parseState(text());
            const first = !root.fileSeen;
            root.fileSeen = true;
            root.fileState = o;
            // the first read is what an earlier session left: its level is never sent to the hardware
            if (first) { root.probeToken = o.probe; root.publish(); return; }
            if (o.probe !== root.probeToken) { root.probeToken = o.probe; root.lastProbe = 0; root.probe(); }
            if (root.ready && root.available && o.value !== null && HW.level(o.value) !== root.value) root.set(o.value, true);
            root.publish();   // puts back what only this service decides (available, source, the clamped level)
        }
        onLoadFailed: { root.fileSeen = true; root.publish(); }
    }

    // qs ipc call brightness state | set 0.4 | step up 16 | probe   (tests and scripts)
    IpcHandler {
        target: "brightness"
        function state(): string {
            return JSON.stringify({ mode: root.mode, available: root.available, value: root.value, ready: root.ready,
                                    ddc: root.ddc, writing: writer.running, sent: root.sent });
        }
        function set(level: real): void { root.set(level, false); }
        function step(dir: string, n: int): void { root.step(dir === "down" ? -1 : 1, n > 0 ? n : 16); }
        function probe(): void { root.lastProbe = 0; root.probe(); }
    }
}
