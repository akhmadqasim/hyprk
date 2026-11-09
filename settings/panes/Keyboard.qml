import QtQuick
import ".."
import "../controls"
import "../Parsers.js" as P

// Key repeat is functional: applied with `hyprctl eval` and saved in state/input.json
// (the shell config can re-apply it at login). The rest is visual.
Column {
    id: pane
    spacing: Theme.content.sectionGap
    property string note: ""

    // Slider positions <-> Hyprland values. Rate 2..50 keys/s; delay 1500 (long) .. 150 ms (short).
    function rateToPos(r) { return (r - 2) / 48; }
    function posToRate(v) { return Math.round(2 + v * 48); }
    function delayToPos(d) { return (1500 - d) / 1350; }
    function posToDelay(v) { return Math.round(1500 - v * 1350); }

    function apply(patch) {
        AppState.set("input", patch);
        Backend.hyprEval(P.luaInput(AppState.input.repeatRate, AppState.input.repeatDelay), st => {
            note = st === "ok" ? "" : "Saved. It takes effect the next time Hyprland starts.";
        });
    }
    // Hyprland is the source of truth when it runs (the config may set other values).
    // Only the in-memory copy is updated here; state/input.json changes when the user does.
    Component.onCompleted: {
        for (const [option, key] of [["input:repeat_rate", "repeatRate"], ["input:repeat_delay", "repeatDelay"]])
            Backend.run(["hyprctl", "getoption", option, "-j"], (c, o) => {
                const v = P.parseHyprOption(o);
                if (c === 0 && v !== null) AppState.input = P.normalizeInput(Object.assign({}, AppState.input, { [key]: v }));
            });
    }

    Card {
        FormRow {
            label: "Key repeat rate"
            MacSlider {
                width: 260; leftText: "Slow"; rightText: "Fast"
                value: pane.rateToPos(AppState.input.repeatRate)
                onReleased: pane.apply({ repeatRate: pane.posToRate(_dragValue) })
            }
        }
        FormRow {
            label: "Delay until repeat"
            MacSlider {
                width: 260; leftText: "Long"; rightText: "Short"
                value: pane.delayToPos(AppState.input.repeatDelay)
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
