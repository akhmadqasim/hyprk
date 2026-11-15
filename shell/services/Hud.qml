pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../lib/hud.js" as HudLib
import "../lib/spring.js" as SpringLib

// Volume and brightness HUD state (macOS 27.2.1: drawn by MenuBarAgent from the Control Center
// menu bar item, MAC-ANSWERS.md HUD (27.2.1)). Follows the real output volume and mute (PipeWire,
// services/Audio) and the backlight (sysfs actual_brightness, inotify; a DDC monitor's level comes from
// services/Brightness, which shows the HUD for its keys), from any source, and shows
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
        // the Mac's empty dash is the glass + 28 on every channel, clipped (plus-lighter: hud-vol-{light,dark}.png over
        // (69,83,206), MOTION-AUDIT.md "HUD" Round R5.1 item 3); drawn additively (shaders/plustext.frag)
        // (was a white 0.16 dash: empty dash over the glass (68,85,232) -> (96,113,255))
        readonly property real emptyLift: 28 / 255
    }
    readonly property QtObject motion: QtObject {
        // show() -> appear spring start: the Mac's first frame is 3 frames (50 ms) after the key and 18 ms after its spring
        // start (R3.4), so the spring starts about 32 ms in; its hold (appear start -> hide start) is 1.000 s (R3.4,
        // MOTION-AUDIT.md "HUD, Round R3.4"). Ours (the Timer fires on a frame, the spring starts a frame later), 3 IPC
        // runs each: 50 -> spring 82 ms after show(), hold .969; 34 -> .985-1.002; 18 -> 1.018; 26 -> .986-1.003.
        // Re-derived from the menu bar pill (R5.1 sound/volume-pop.mov, MOTION-AUDIT.md "HUD", "Round R5.1"): Mac pill ->
        // spring start 32-49 ms, ours 30-63 (mean 44, 4 IPC runs). Ours' later first visible frame (pill +133 ms,
        // Mac +67) was the first frames' faintness, not this delay (content held to o .25: fixed, "Round J20").
        // Round J20, one clock: Mac pill -> spring start 48 ms (volume-pop.mov, t0 from the content alpha); ours on the
        // key path 17-50 (8 runs, median 33.5, one or two frames): 26 -> 42, one frame more
        readonly property int showDelay: 42
        // SystemBannerTimeoutMode.short 1.0 s + showDelay + 24, so the hold (appear spring start -> hide spring start)
        // stays the Mac's 1.000 s (R3.4: 1050 with showDelay 26 held .986-1.019, mean 1.003); restarts on every change
        readonly property int hideAfter: 1066
        readonly property real appearScale: 0.9         // _scaleFactor 0.9 when hidden
        // the scale's anchor: the capsule's horizontal centre, anchorAbove pt above its top (the banner's top edge, its
        // _topMargin 10). R3.4 / R6.2 clips (3), glass and content registered per frame: anchor at that edge (a scan in
        // 6 px steps at 2x, parabola minimum 0.3 px above it; frame rms 1.3 levels, about the capsule's centre 12-13
        // mid-appear); the capsule rides 4.3 pt x
        // (1 - o) high while it grows. MOTION-AUDIT.md "HUD", "Round J20"
        readonly property real anchorAbove: 10
        // appear: interpolatingSpring(mass: 2, stiffness: 300, damping: 50)
        readonly property var appear: SpringLib.fromPhysics(2, 300, 50)
        // hide: spring(response: 0.48669, dampingFraction: 1); dismissal completes asyncAfter(0.48669)
        readonly property var hide: SpringLib.fromResponse(0.48669, 1)
        readonly property real hideSeconds: 0.48669
        // the content's alpha is the spring value o (BannerSlider content.opacity(o)): 3 clips with the top anchor, appear
        // and hide, glyph rms .013 (o^1.06 .008), bar .023 (o^0.90 .011). R3.4's o x clamp((o - .25) / .51) came from
        // dash rows sampled about the capsule's centre, 4-8 px under the early dashes (rms .111 / .139 here)
        // new content while showing (bar fill, volume <-> brightness): spring(response: 0.2, dampingFraction: 0.85)
        readonly property var content: SpringLib.fromResponse(0.2, 0.85)
        // the speaker's bounce at 0 and at full runs layer by layer (R11.4 hud-volume-steps clips, each layer's box per
        // frame): every layer scales about the symbol's centre on the .bounce curve, peak 1.25 and trough 0.90, each
        // 0.05 s after the layer before (speaker, wave 1, 2, 3; speaker.slash: the slash, then the speaker).
        // Fit over 3 bounces: rms .013-.016 of scale (all layers together at 1.21 / 0.87: .044-.063)
        readonly property real bounceStagger: 0.05
        readonly property var bounceAmp: [1.25, 0.90]
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
    // The sink's last level and mute, apart from what the HUD shows: the test entry below (qs ipc call hud volume)
    // sets the shown level only, and a key step that landed on that level then showed no HUD although the sink's
    // level had changed (JUDGE-95-23 claim 3c: stub 1.0 -> 0.9375 after `hud volume 0.9375`, no HUD)
    property real sinkVolume: -1
    property bool sinkMuted: false
    Component.onCompleted: if (Audio.available) { sinkVolume = HudLib.clamp01(Audio.volume); sinkMuted = Audio.muted; }
    function audioChanged() {
        if (!Audio.available) return;
        const v = HudLib.clamp01(Audio.volume), m = Audio.muted;
        if (v === sinkVolume && m === sinkMuted) return;
        sinkVolume = v;
        sinkMuted = m;
        volume = v;
        muted = m;
        if (Date.now() >= audioQuietUntil) show("volume");
    }
    // A volume key step that leaves the level and mute as they were (up at full volume, down at zero) still shows the
    // HUD on the Mac: HUDActionDelegate.showVolume runs on every step, before the feedback gate (ControlCenter.framework
    // volume step 0x20a595dac, SOUND-REA-27.2.1.md section 2). scripts/volume-key.sh rewrites "hud-step" in its folder
    // for such a step only, so a level change still shows through audioChanged() with the same timing
    property bool stepDirMade: false
    property string stepLast: ""
    Process {
        // emptied at start: what a session before this one wrote is not a step
        running: !root.stepDirMade
        command: ["sh", "-c", "mkdir -p \"$1\" && : > \"$1/hud-step\"", "sh", Audio.stubDir]
        onExited: root.stepDirMade = true
    }
    FileView {
        path: root.stepDirMade ? Audio.stubDir + "/hud-step" : ""
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            const t = text().trim();                   // "<pid> <ns>": every step a new line
            if (t === "" || t === root.stepLast) return;
            root.stepLast = t;
            if (!Audio.available) return;
            root.volume = HudLib.clamp01(Audio.volume);
            root.muted = Audio.muted;
            root.show("volume");
        }
    }

    // ---------- brightness (backlight sysfs) ----------
    // The kernel notifies actual_brightness on every change (backlight_generate_event), so the file
    // watch sees brightnessctl, the Control Center slider and firmware hotkeys alike.
    // HYPRK_BACKLIGHT overrides the device folder (tests).
    property string backlight: Quickshell.env("HYPRK_BACKLIGHT") || ""
    property real backlightMax: 0
    property bool backlightRead: false
    // the backlight's own level as last read (-1: none read): services/Brightness.qml follows it, so the Control Center
    // and Settings sliders move with the keys. `brightness` above is what the HUD shows (the test entry sets it too)
    property real backlightLevel: -1
    // a change Settings > Displays asked for shows no HUD (the Mac's slider there shows none): Brightness sets this
    property double brightnessQuietUntil: 0
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
            root.backlightLevel = v;
            if (!first && v === root.brightness) return;
            root.brightness = v;
            if (!first && Date.now() >= root.brightnessQuietUntil) root.show("brightness");
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
