import QtQuick
import "../.."
import "A11y.js" as A

// Shared by the Accessibility pages: reads/writes the state and applies it.
// Every change rewrites state/accessibility.lua (+ the screen filter shader) and
// evaluates it with `hyprctl eval`; the shell re-runs the same file at login.
QtObject {
    id: ctl

    readonly property var a: AppState.accessibility
    readonly property var ap: AppState.appearance
    readonly property string root: Backend.root
    readonly property string scripts: root + "/settings/scripts/"

    // "ok" | "missing" (not in Hyprland, or no process support) | "failed"
    property string hyprStatus: "ok"
    readonly property string hyprNote: hyprStatus === "ok" ? ""
        : "Saved, but Hyprland isn't reachable here, so the change applies at the next login."

    // Tools found on this system (checked once)
    property bool hasOrca: false
    property bool hasSpeech: false
    property bool hasGsettings: false
    property bool orcaRunning: false

    function set(patch) { AppState.set("accessibility", patch); _apply.restart(); }
    function setAppearance(patch) { AppState.set("appearance", patch); _apply.restart(); }

    property string _template: ""
    property Timer _apply: Timer {
        interval: 120
        onTriggered: ctl.applyNow()
    }
    property string _applied: ""      // last Lua + shader sent, to skip no-op applies
    function applyNow() {
        const lua = A.luaApply(a, ap, root, Backend.stateDir);
        const shader = A.needsShader(a) ? A.shaderSource(_template, a) : "";
        if (A.needsShader(a) && shader === "") return;   // template not read yet: applied once it is
        if (lua + shader === _applied) return;
        _applied = lua + shader;
        const dir = Backend.stateDir;
        // shader first (Hyprland reads it when screen_shader is set), then the Lua, both atomic
        Backend.run(["sh", "-c",
            'w() { t=$(mktemp "$1.XXXXXX") && printf "%s" "$2" > "$t" && mv "$t" "$1"; }; '
            + 'mkdir -p "$1" && { [ -z "$2" ] || w "$1/a11y-screen.frag" "$2"; } && w "$1/accessibility.lua" "$3"',
            "sh", dir, shader, lua], () => Backend.hyprEval(lua, st => ctl.hyprStatus = st));
    }

    // VoiceOver = Orca, started/stopped by scripts/a11y-orca.sh (only its own instance)
    function setVoiceOver(on) {
        set({ voiceOver: on });
        orcaRunning = on;            // shown at once; refreshOrca() corrects it if Orca did not start/stop
        Backend.run([scripts + "a11y-orca.sh", on ? "start" : "stop"], () => refreshOrca());
    }
    function refreshOrca() {
        Backend.run([scripts + "a11y-orca.sh", "status"], c => { hasOrca = c !== 3 && c !== 127; orcaRunning = c === 0; });
    }
    function speak(text) { Backend.run([scripts + "a11y-speak.sh", "say", text]); }

    // GTK/GNOME setting shared with the host desktop: only written on an explicit change.
    function setNonBlinkingCursor(on) {
        AppState.set("accessibility", { nonBlinkingCursor: on });
        Backend.run(["gsettings", "set", "org.gnome.desktop.interface", "cursor-blink", on ? "false" : "true"]);
    }

    Component.onCompleted: {
        Backend.readText(root + "/config/hypr/shaders/a11y-filter.frag", t => { _template = t; if (A.needsShader(a)) _apply.restart(); });
        refreshOrca();
        Backend.run(["sh", "-c", "command -v spd-say gsettings"], (c, out) => {
            hasSpeech = /spd-say/.test(out);
            hasGsettings = /gsettings/.test(out);
        });
    }
}
