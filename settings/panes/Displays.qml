import QtQuick
import ".."
import "../controls"
import "../Parsers.js" as P

// Functional (read + scale) via `hyprctl monitors -j`.
Column {
    id: pane
    spacing: Theme.content.sectionGap

    property string status: "loading"   // loading | missing | failed | ok
    property var monitors: []
    property int sel: 0
    property string note: ""
    readonly property var mon: monitors.length ? monitors[Math.min(sel, monitors.length - 1)] : null
    readonly property var scales: [1, 1.25, 1.5, 1.75, 2]

    function refresh() {
        Backend.run(["hyprctl", "monitors", "-j"], (code, out) => {
            monitors = code === 0 ? P.parseHyprMonitors(out) : [];
            // hyprctl outside a Hyprland session exits non-zero; empty output is the same case
            status = code === 0 && !monitors.length ? "failed" : Backend.status(code);
        });
    }
    function apply(m, mode, scale) {
        note = "";
        Backend.hyprEval(P.luaMonitor(m.name, mode, scale), st => {
            if (st !== "ok") note = "Hyprland did not accept that display setting.";
            refresh();
        });
    }
    Component.onCompleted: refresh()

    // Arrangement strip
    Card {
        Item {
            width: parent.width; height: 150
            Row {
                anchors.centerIn: parent
                spacing: 16
                Repeater {
                    model: pane.status === "ok" ? pane.monitors : [{ name: "", description: "Display", width: 16, height: 10 }]
                    Column {
                        required property var modelData
                        required property int index
                        spacing: 6
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            height: 74; width: Math.round(height * modelData.width / Math.max(1, modelData.height))
                            radius: 6
                            border.width: index === pane.sel && pane.status === "ok" ? 3 : 1
                            border.color: index === pane.sel && pane.status === "ok" ? Theme.accent : Theme.separator
                            gradient: Gradient { GradientStop { position: 0; color: "#3B7BD6" } GradientStop { position: 1; color: "#7A5BC9" } }
                            opacity: pane.status === "ok" ? 1 : 0.35
                            MouseArea { anchors.fill: parent; onClicked: pane.sel = index }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.model || modelData.description
                            font.family: Theme.fontText; font.pixelSize: Theme.font.small; color: Theme.label
                        }
                    }
                }
            }
        }
    }

    InlineNote {
        text: pane.status === "missing" || pane.status === "failed" ? "Display details come from Hyprland. Open System Settings inside a Hyprland session to change resolution and scale." : pane.note
    }

    Card {
        FormRow {
            label: "Resolution"
            MacPopup {
                enabled_: pane.status === "ok"
                model: pane.mon && pane.mon.modes.length ? pane.mon.modes.map(s => s.replace(/@.*/, "").replace("x", " × ")) : ["Default for display"]
                currentIndex: pane.mon ? Math.max(0, pane.mon.modes.findIndex(s => s.startsWith(pane.mon.width + "x" + pane.mon.height))) : 0
                onActivated: i => pane.apply(pane.mon, pane.mon.modes[i].replace(/Hz$/, ""), pane.mon.scale)
            }
        }
        FormRow {
            label: "Scale"
            MacPopup {
                enabled_: pane.status === "ok"
                model: pane.scales.map(s => Math.round(s * 100) + "%")
                currentIndex: pane.mon ? Math.max(0, pane.scales.indexOf(pane.mon.scale)) : 0
                onActivated: i => pane.apply(pane.mon, pane.mon.width + "x" + pane.mon.height + "@" + pane.mon.refreshRate, pane.scales[i])
            }
        }
        FormRow { label: "Refresh rate"; MacPopup { enabled_: false; model: [pane.mon ? pane.mon.refreshRate + " Hertz" : "—"] } }
        FormRow { label: "Automatically adjust brightness"; MacSwitch { enabled_: false } }
        FormRow { label: "True Tone"; sublabel: "Automatically adapt display to make colors appear consistent in different ambient lighting."; MacSwitch { enabled_: false } }
    }

    PaneFooter { MacButton { text: "Advanced…" } MacButton { text: "Night Shift…" } }
}
