pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../lib/state.js" as State

// Accessibility for the shell, from the files the Settings app writes:
//   state/appearance.json     reduceMotion, increaseContrast (read here, like Theme
//                             reads reduceTransparency)
//   state/accessibility.lua   Hyprland side (zoom keys, pointer size, screen filter,
//                             animations, borders). Settings evaluates it on every
//                             change; this service evaluates it at login and after
//                             each Hyprland config reload, which drops runtime changes.
// Singletons start on first use, so shell.qml must touch A11y once (see the
// settings agent's report). Helpers for animations and strokes are below.
Singleton {
    id: root

    readonly property string dir: (Quickshell.env("HYPRK_STATE") || Quickshell.shellDir + "/../state") + "/"

    property bool reduceMotion: false
    property bool increaseContrast: false

    // Duration for an animation of `ms` milliseconds. macOS Reduce motion swaps
    // slides and zooms for short dissolves, so motion gets at most 150 ms.
    function ms(ms: int): int { return reduceMotion ? Math.min(ms, 150) : ms; }
    // Distance or scale delta to animate: 0 under Reduce motion (cross-fade only).
    function travel(v: real): real { return reduceMotion ? 0 : v; }
    // Stroke / separator alpha: Increase contrast makes hairlines clearly visible.
    function strokeAlpha(a: real): real { return increaseContrast ? Math.max(a, 0.45) : a; }

    // liquidglass plugin (plugin/) eases its glass motion off too; an error when the
    // plugin isn't loaded is ignored (detached, output dropped)
    function syncPlugin(): void {
        Quickshell.execDetached(["hyprctl", "eval", `hl.config({ plugin = { liquidglass = { reduce_motion = ${reduceMotion ? 1 : 0} } } })`]);
    }
    onReduceMotionChanged: syncPlugin()
    Component.onCompleted: syncPlugin()

    FileView {
        path: root.dir + "appearance.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            const o = State.parse(text(), { reduceMotion: false, increaseContrast: false });
            root.reduceMotion = o.reduceMotion;
            root.increaseContrast = o.increaseContrast;
        }
    }

    FileView {
        id: lua
        path: root.dir + "accessibility.lua"
        printErrors: false
        onLoaded: root.applyHyprland()
    }

    function applyHyprland(): void {
        const text = lua.text();
        // the file never starts with "--" (hyprctl would read it as a flag)
        if (text.trim() === "" || text.startsWith("-")) return;
        Quickshell.execDetached(["hyprctl", "eval", text]);
    }

    Connections {
        target: Hyprland
        function onRawEvent(event: HyprlandEvent): void {
            if (event.name === "configreloaded") lua.reload();
        }
    }

    IpcHandler {
        target: "a11y"
        function apply(): void { lua.reload(); }
        function state(): string { return JSON.stringify({ reduceMotion: root.reduceMotion, increaseContrast: root.increaseContrast }); }
    }
}
