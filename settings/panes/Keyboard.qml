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
    Component.onCompleted: {
        Backend.run(["hyprctl", "getoption", "input:repeat_rate", "-j"], (c, o) => {
            const v = P.parseHyprOption(o);
            if (c === 0 && v !== null) AppState.input = P.normalizeInput(Object.assign({}, AppState.input, { repeatRate: v }));
        });
        Backend.run(["hyprctl", "getoption", "input:repeat_delay", "-j"], (c, o) => {
            const v = P.parseHyprOption(o);
            if (c === 0 && v !== null) AppState.input = P.normalizeInput(Object.assign({}, AppState.input, { repeatDelay: v }));
        });
    }

    Card {
        FormRow {
            label: "Key repeat rate"
            Row {
                spacing: 8
                MacText { width: 30; horizontalAlignment: Text.AlignRight; text: "Slow"; color: Theme.secondaryLabel; font.pixelSize: Theme.font.small; anchors.verticalCenter: parent.verticalCenter }
                MacSlider {
                    width: 180
                    value: pane.rateToPos(AppState.input.repeatRate)
                    onReleased: pane.apply({ repeatRate: pane.posToRate(_dragValue) })
                }
                MacText { width: 34; text: "Fast"; color: Theme.secondaryLabel; font.pixelSize: Theme.font.small; anchors.verticalCenter: parent.verticalCenter }
            }
        }
        FormRow {
            label: "Delay until repeat"
            Row {
                spacing: 8
                MacText { width: 30; horizontalAlignment: Text.AlignRight; text: "Long"; color: Theme.secondaryLabel; font.pixelSize: Theme.font.small; anchors.verticalCenter: parent.verticalCenter }
                MacSlider {
                    width: 180
                    value: pane.delayToPos(AppState.input.repeatDelay)
                    onReleased: pane.apply({ repeatDelay: pane.posToDelay(_dragValue) })
                }
                MacText { width: 34; text: "Short"; color: Theme.secondaryLabel; font.pixelSize: Theme.font.small; anchors.verticalCenter: parent.verticalCenter }
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
