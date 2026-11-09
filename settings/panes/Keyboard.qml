import QtQuick
import ".."
import "../controls"
import "../Parsers.js" as P

// Key repeat is functional: applied live with `hyprctl eval` and saved in
// state/input.json (for the session config to re-apply at login). The rest is visual.
Column {
    id: pane
    spacing: Theme.content.sectionGap
    property string note: ""

    // Slider positions <-> Hyprland values. Rate 2..50 keys/s; delay 1500 (long) .. 150 ms (short).
    function rateToPos(r) { return (r - 2) / 48; }
    function posToRate(v) { return Math.round(2 + v * 48); }
    function delayToPos(d) { return (1500 - d) / 1350; }
    function posToDelay(v) { return Math.round(1500 - v * 1350); }

    // What the sliders show: state/input.json, replaced by Hyprland's live values
    // once hyprctl answers (Hyprland is the source of truth when it runs).
    property int rate: AppState.input.repeatRate
    property int delay: AppState.input.repeatDelay

    function apply(patch) {
        AppState.set("input", patch);
        if (patch.repeatRate !== undefined) rate = patch.repeatRate;
        if (patch.repeatDelay !== undefined) delay = patch.repeatDelay;
        Backend.hyprEval(P.luaInput(rate, delay), st => {
            note = st === "ok" ? "" : "Saved to state/input.json, but Hyprland isn't reachable here, so the keyboard didn't change.";
        });
    }
    Component.onCompleted: {
        Backend.run(["hyprctl", "getoption", "input:repeat_rate", "-j"], (c, o) => {
            const v = P.parseHyprOption(o);
            if (c === 0 && v !== null) rate = v;
        });
        Backend.run(["hyprctl", "getoption", "input:repeat_delay", "-j"], (c, o) => {
            const v = P.parseHyprOption(o);
            if (c === 0 && v !== null) delay = v;
        });
    }

    Card {
        FormRow {
            label: "Key repeat rate"
            MacSlider {
                width: 260; leftText: "Slow"; rightText: "Fast"
                value: pane.rateToPos(pane.rate)
                onReleased: pane.apply({ repeatRate: pane.posToRate(_dragValue) })
            }
        }
        FormRow {
            label: "Delay until repeat"
            MacSlider {
                width: 260; leftText: "Long"; rightText: "Short"
                value: pane.delayToPos(pane.delay)
                onReleased: pane.apply({ repeatDelay: pane.posToDelay(_dragValue) })
            }
        }
        FormRow { label: "Adjust keyboard brightness in low light"; MacSwitch { checked: true } }
        FormRow { label: "Press 🌐 key to"; MacPopup { model: ["Change Input Source", "Show Emoji & Symbols", "Start Dictation", "Do Nothing"]; currentIndex: 1 } }
        FormRow { label: "Keyboard navigation"; sublabel: "Use keyboard navigation to move focus between controls."; MacSwitch {} }
    }
    InlineNote { text: pane.note }
    PaneFooter { help: false; MacButton { text: "Keyboard Shortcuts…" } }
    Card {
        title: "Text Input"
        FormRow { label: "Input Sources"; value: "U.S."; MacButton { text: "Edit…" } }
    }
    Card {
        title: "Dictation"
        FormRow { label: "Dictation"; sublabel: "Use Dictation wherever you can type text."; MacSwitch {} }
    }
    PaneFooter { MacButton { text: "Set Up Keyboard…" } }
}
