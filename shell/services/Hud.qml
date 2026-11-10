pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../lib/hud.js" as HudLib

// Volume and brightness HUD state (macOS 27.2.1: drawn by MenuBarAgent from the Control Center
// menu bar item, MAC-ANSWERS.md HUD (27.2.1)). Follows the real output volume and mute (PipeWire,
// services/Audio) and the backlight (sysfs actual_brightness, inotify), from any source, and shows
// only on changes: never for the values read at startup or when the default sink changes.
// modules/HudWindow.qml draws it. While `shown`, the menu bar's Control Center icon shows its
// highlight pill (macOS presents the HUD from that item).
// Idle cost: no timer or animation runs while hidden; the hide timer runs only while shown.
Singleton {
    id: root

    // ---------- tokens: MAC-ANSWERS.md HUD (27.2.1), 60 fps recordings and 2x stills ----------
    readonly property QtObject metrics: QtObject {
        readonly property real width: 307.5             // capsule 1392.5..1700 pt
        readonly property real height: 65.5             // capsule 44..109.5 pt, radius = height / 2
        readonly property real gap: 10                  // from the screen's right edge and below the menu bar
        readonly property real glyphSize: 26            // SF Symbol point size: speaker.wave.2.fill 27.5 x 21.5 pt (fitted, regular weight)
        readonly property real glyphBaseline: 42.4      // glyph baseline from the capsule top (fitted from 3 symbols in the stills)
        readonly property real glyphLeft: 16.4          // symbol canvas left edge, speaker symbols (stills)
        readonly property real glyphLeftSun: 20.1       // sun.max.fill sits 3.7 pt further right (stills)
        readonly property int dashes: 16                // one key press = 1/16
        readonly property real barX: 62.6               // bar start from the capsule's left edge (stills: 62.57; text: 63)
        readonly property real barLength: 214
        readonly property real dashHeight: 4
        readonly property real barY: 31                 // dashes at y 31..35 pt in the capsule, on whole pixels (stills)
        readonly property real dashGap: 1               // 1.95 px at 2x in the stills; the first dash is one gap longer
        readonly property color fill: "#FFFFFF"         // filled dashes and glyph, light and dark alike
        readonly property color empty: Qt.rgba(1, 1, 1, 0.16)   // empty dash over the glass: (68,85,232) -> (96,113,255)
    }
    readonly property QtObject motion: QtObject {
        readonly property int showDelay: 50             // HUD starts 3 frames after the key (menu bar highlight first)
        readonly property int hideAfter: 1050           // hides 1.05 s after the last change; restarts on every change
        // fade in: 30 alpha samples 0.01..0.98, fitted cubic bezier over 0.57 s (rmse 0.007)
        readonly property int appearDuration: 570
        readonly property var appearCurve: [0.303, 0.027, 0.366, 1.0, 1, 1]
        // grow: width 0.82 -> 0.92 in the first 0.1 s, at 1.0 by 0.4 s: critically damped spring, response 0.37
        readonly property real appearScale: 0.82
        readonly property real appearResponse: 0.37
        // fade out: 16 alpha samples 0.96..0.03 (about x0.8 per frame), fitted bezier over 0.35 s (rmse 0.004)
        readonly property int hideDuration: 350
        readonly property var hideCurve: [0.212, 0.118, 0.077, 1.0, 1, 1]
        readonly property real hideScale: 0.92          // scales back towards 0.92 while it fades
        // repeated presses: the fill moves continuously and comes to rest 0.15..0.2 s after the last one
        // (critically damped, 99 % at 0.18 s)
        readonly property real fillResponse: 0.17
        readonly property int crossfade: 50             // volume <-> brightness: glyph and bar crossfade in about 3 frames
    }

    // ---------- state ----------
    property bool shown: false                          // from the change until the hide starts
    property string kind: "volume"                      // "volume" | "brightness"
    property real volume: 0
    property bool muted: false
    property real brightness: 0
    property var screen: Panels.screen                  // where it shows: the focused monitor at show time
    readonly property real volumeLevel: muted ? 0 : volume
    readonly property string volumeSymbol: HudLib.volumeSymbol(volume, muted)

    function show(k) {
        // the Control Center sliders are their own feedback, and the HUD would sit on top of them
        if (Panels.open === "cc") return;
        if (!shown) {
            const name = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "";
            screen = Quickshell.screens.find(s => s.name === name) || Panels.screen;
        }
        kind = k;
        shown = true;
        hideTimer.restart();
    }
    function hide() {
        hideTimer.stop();
        shown = false;
    }
    Timer { id: hideTimer; interval: root.motion.hideAfter; onTriggered: root.shown = false }
    Connections {
        target: Panels
        function onOpenChanged() { if (Panels.open === "cc") root.hide(); }
    }

    // ---------- volume (PipeWire) ----------
    // A new default sink (startup, headphones plugged in) brings its own values: they are taken
    // as the baseline for a moment, not shown.
    property double audioQuietUntil: Date.now() + 1500
    readonly property var sink: Audio.sink
    onSinkChanged: audioQuietUntil = Date.now() + 1500
    Connections {
        target: root.sink
        function onReadyChanged() { root.audioQuietUntil = Date.now() + 1500; }
    }
    Connections {
        target: Audio
        function onVolumeChanged() { root.audioChanged(); }
        function onMutedChanged() { root.audioChanged(); }
    }
    function audioChanged() {
        if (!Audio.available) return;
        const v = HudLib.clamp01(Audio.volume), m = Audio.muted;
        if (v === volume && m === muted) return;
        volume = v;
        muted = m;
        if (Date.now() >= audioQuietUntil) show("volume");
    }

    // ---------- brightness (backlight sysfs) ----------
    // The kernel notifies actual_brightness on every change (backlight_generate_event), so the file
    // watch sees brightnessctl, the Control Center slider and firmware hotkeys alike.
    // HYPRK_BACKLIGHT overrides the device folder (tests).
    property string backlight: Quickshell.env("HYPRK_BACKLIGHT") || ""
    property real backlightMax: 0
    property bool backlightRead: false
    Process {
        running: root.backlight === ""
        command: ["sh", "-c", "for d in /sys/class/backlight/*; do [ -r \"$d/max_brightness\" ] && { echo \"$d\"; break; }; done"]
        stdout: StdioCollector { onStreamFinished: root.backlight = text.trim() }
    }
    FileView {
        path: root.backlight ? root.backlight + "/max_brightness" : ""
        printErrors: false
        onLoaded: root.backlightMax = parseInt(text()) || 0
    }
    FileView {
        id: actual
        path: root.backlight && root.backlightMax > 0 ? root.backlight + "/actual_brightness" : ""
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            if (text().trim() === "") return;   // a file rewritten in place (tests) reads empty in between
            const v = HudLib.clamp01(parseInt(text()) / root.backlightMax);
            const first = !root.backlightRead;
            root.backlightRead = true;
            if (!first && v === root.brightness) return;
            root.brightness = v;
            if (!first) root.show("brightness");
        }
    }

    // test entry (drives the HUD without a sink or backlight): qs ipc call hud volume 0.5,
    // hud brightness 0.3, hud mute, hud hide, hud state. ("show" would clash with `qs ipc show`.)
    IpcHandler {
        target: "hud"
        function volume(level: real): void {
            root.volume = HudLib.clamp01(level);
            root.muted = false;
            root.show("volume");
        }
        function brightness(level: real): void {
            root.brightness = HudLib.clamp01(level);
            root.show("brightness");
        }
        function mute(): void {
            root.muted = true;
            root.show("volume");
        }
        function hide(): void { root.hide(); }
        function state(): string {
            return JSON.stringify({ shown: root.shown, kind: root.kind, volume: root.volume, muted: root.muted,
                                    brightness: root.brightness, screen: root.screen ? root.screen.name : "",
                                    backlight: root.backlight });
        }
    }
}
