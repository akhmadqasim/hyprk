pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../lib/hud.js" as HudLib
import "../lib/spring.js" as SpringLib

// Volume and brightness HUD state (macOS 27.2.1: drawn by MenuBarAgent from the Control Center
// menu bar item, MAC-ANSWERS.md HUD (27.2.1)). Follows the real output volume and mute (PipeWire,
// services/Audio) and the backlight (sysfs actual_brightness, inotify), from any source, and shows
// only on changes: never for the values read at startup or when the default sink changes.
// modules/HudWindow.qml draws it. While `shown`, the menu bar's Control Center icon shows its
// highlight pill (macOS presents the HUD from that item).
// Idle cost: no timer or animation runs while hidden; the hide timer runs only while shown.
Singleton {
    id: root

    // ---------- tokens: MAC-ANSWERS.md "REA 27.2.1" section 1 (SystemBannerUI code), else 2x stills ----------
    readonly property QtObject metrics: QtObject {
        readonly property real width: 307               // frame(width: 307, height: 66) (stills: 307.5 x 65.5)
        readonly property real height: 66               // radius = height / 2 (Capsule)
        readonly property real gap: 10                  // below the menu bar (_topMargin 10); from the screen's right edge (stills, not in the code)
        readonly property real glyphSize: 26            // SF Symbol point size: speaker.wave.2.fill 27.5 x 21.5 pt (fitted, regular weight)
        readonly property real glyphBaseline: 42.4      // glyph baseline from the capsule top (fitted from 3 symbols in the stills)
        readonly property real glyphLeft: 16.4          // symbol canvas left edge, speaker symbols (stills; code: leading padding 16)
        readonly property real glyphLeftSun: 20.1       // sun.max.fill sits 3.7 pt further right (stills)
        readonly property int dashes: 16                // TickedTrackMask(tickCount: 16, tickWidth: 1)
        readonly property real barX: 62.6               // bar start from the capsule's left edge (stills: 62.57; the glyph frame width is not read)
        readonly property real barLength: width - 31 - barX   // ends at the trailing padding 31
        readonly property real dashHeight: 4            // track frame height 4, leading corner radius 2
        readonly property real barY: 31                 // dashes at y 31..35 pt: centred in 66 (stills)
        readonly property real dashGap: 1               // tickWidth 1; the first dash is one gap longer (stills)
        readonly property color fill: "#FFFFFF"         // filled dashes and glyph, light and dark alike
        readonly property color empty: Qt.rgba(1, 1, 1, 0.16)   // empty dash over the glass: (68,85,232) -> (96,113,255)
    }
    readonly property QtObject motion: QtObject {
        readonly property int showDelay: 50             // about 3 frames of hosting latency (recorded; not in the code)
        readonly property int hideAfter: 1050           // SystemBannerTimeoutMode.short 1.0 s + the same 3 frames; restarts on every change
        readonly property real appearScale: 0.9         // _scaleFactor 0.9 when hidden
        // appear: interpolatingSpring(mass: 2, stiffness: 300, damping: 50)
        readonly property var appear: SpringLib.fromPhysics(2, 300, 50)
        // hide: spring(response: 0.48669, dampingFraction: 1); dismissal completes asyncAfter(0.48669)
        readonly property var hide: SpringLib.fromResponse(0.48669, 1)
        readonly property real hideSeconds: 0.48669
        // new content while showing (bar fill, volume <-> brightness): spring(response: 0.2, dampingFraction: 0.85)
        readonly property var content: SpringLib.fromResponse(0.2, 0.85)
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
