import QtQuick
import ".."
import "../controls"
import "../HyprK"
import "../Parsers.js" as P

// Functional: monitors from `hyprctl monitors -j`, sizes from config/hypr/scale-policy.lua (report() through
// `hyprctl eval`). A HiDPI display gets the macOS row of scaled sizes ("Larger Text" .. "More Space"), a 1x
// display the resolution list. The choice is saved per output to state/displays.json (read by scale-policy.lua
// at start and on hotplug) and applied at once with scale-policy.lua set().
Column {
    id: pane
    spacing: Theme.content.sectionGap

    property string status: "loading"   // loading | missing | failed | ok
    property var monitors: []
    property var report: null           // P.parseScaleReport result, null = scale policy not reachable
    property int sel: 0
    property string note: ""
    property string hovered: ""          // chiclet under the pointer ("WxH")
    readonly property var mon: monitors.length ? monitors[Math.min(sel, monitors.length - 1)] : null
    readonly property var out: report && mon ? report.outputs.find(o => o.name === mon.name) ?? null : null
    readonly property string block: status === "ok" ? P.looksLikeBlock(report, out) : ""
    readonly property bool canPick: status === "ok" && block === ""
    readonly property string saved: mon ? AppState.displays.looksLike[mon.name] ?? "" : ""
    readonly property string selected: P.looksLikeSelected(out, report && report.policy === "on" ? saved : "")
    // virtual outputs (MBA, HEADLESS-*, nested WAYLAND-*/X11-*) keep their own mode: no list, only the reason
    readonly property bool real: status === "ok" && !!out && !out.virtual
    readonly property var chiclets: real && out.hidpi ? P.looksLikeChiclets(out.choices) : []
    readonly property bool showList: real && !out.hidpi && out.choices.length > 0

    function refresh() {
        Backend.run(["hyprctl", "monitors", "-j"], (code, text) => {
            monitors = code === 0 ? P.parseHyprMonitors(text) : [];
            // first load: start on the focused display, like macOS starts on the one with the window
            if (status === "loading") sel = Math.max(0, monitors.findIndex(m => m.focused));
            // hyprctl outside a Hyprland session exits non-zero; empty output is the same case
            status = code === 0 && !monitors.length ? "failed" : Backend.status(code);
        });
        // report() writes JSON to a temp file (hyprctl eval only prints "ok")
        Backend.run(["sh", "-c", 'f=$(mktemp) || exit 1; r=$(hyprctl eval "$1\\"$f\\")"); [ "$r" = ok ] && cat "$f"; c=$?; rm -f "$f"; exit $c',
                     "sh", P.luaScalePolicy(Backend.root) + ".report("],   // sh appends "<file>")
                    (code, text) => report = code === 0 ? P.parseScaleReport(text) : null);
    }
    // c = a choice from the report ({w, h, isDefault}); the Default is stored as "no entry"
    function pick(c) {
        if (!canPick || !mon) return;
        const name = mon.name, key = P.sizeKey(c);
        const map = Object.assign({}, AppState.displays.looksLike);
        if (c.isDefault) delete map[name]; else map[name] = key;
        AppState.set("displays", { looksLike: map });
        note = "";
        Backend.hyprEval(P.luaScaleSet(Backend.root, name, c.isDefault ? "" : key), st => {
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
                scale: Math.min(1, (parent.width - 24) / Math.max(1, width))   // many displays: shrink to fit
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
        text: pane.status === "missing" || pane.status === "failed" ? "Display details come from Hyprland. Open System Settings inside a Hyprland session to change resolution and scale."
            : pane.note || pane.block
    }

    // HiDPI: the five scaled sizes. Tile size, "Aa" sizes and spacing are guessed (no reference shot of the
    // macOS 27 Displays pane in reference/ yet); labels and the "Looks like" wording are macOS's.
    Card {
        visible: pane.chiclets.length > 0
        Item {
            width: parent.width
            height: 118
            opacity: pane.canPick ? 1 : 0.45
            Row {
                id: chicletRow
                anchors.horizontalCenter: parent.horizontalCenter
                y: 14
                spacing: 18                                   // guessed
                Repeater {
                    model: pane.chiclets
                    Column {
                        id: ch
                        required property var modelData
                        readonly property bool on: P.sizeKey(modelData) === pane.selected
                        spacing: 6
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 64; height: 40; radius: 6         // guessed, 16:10 tile
                            color: Theme.controlFill
                            border.width: ch.on ? 3 : 1
                            border.color: ch.on ? Theme.accent : Theme.separator
                            MacText {
                                anchors.centerIn: parent
                                text: "Aa"
                                // bigger text for smaller looks-like sizes: relative to the Default's size (guessed)
                                font.pixelSize: Math.max(8, Math.min(24, Math.round(15 * (pane.out ? pane.out.def[0] : ch.modelData.w) / ch.modelData.w)))
                                color: Theme.secondaryLabel
                            }
                            MouseArea {
                                anchors.fill: parent
                                enabled: pane.canPick
                                hoverEnabled: true
                                onEntered: pane.hovered = P.sizeKey(ch.modelData)
                                onExited: if (pane.hovered === P.sizeKey(ch.modelData)) pane.hovered = ""
                                onClicked: pane.pick(ch.modelData)
                            }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: ch.modelData.label
                            font.family: Theme.fontText; font.pixelSize: Theme.font.small
                            color: Theme.secondaryLabel
                        }
                    }
                }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: chicletRow.bottom; anchors.topMargin: 10
                readonly property var c: (pane.hovered || pane.selected).split("x")
                text: c.length === 2 ? "Looks like " + P.sizeText(c[0], c[1]) : ""
                font.family: Theme.fontText; font.pixelSize: Theme.font.small
                color: Theme.secondaryLabel
            }
        }
    }

    // 1x display: the plain resolution list, Default marked, check on the current size (macOS list style)
    Card {
        visible: pane.showList
        title: "Resolution"
        Repeater {
            model: pane.showList ? pane.out.choices.slice().reverse() : []
            FormRow {
                required property var modelData
                label: P.sizeText(modelData.w, modelData.h) + (modelData.isDefault ? " (Default)" : "")
                dim: !pane.canPick
                onClicked: pane.pick(modelData)
                Text {
                    visible: P.sizeKey(modelData) === pane.selected
                    text: "check"; font.family: Theme.fontGlyph; font.pixelSize: 18; color: Theme.accent
                }
            }
        }
    }

    Card {
        FormRow {
            // only when there are no sizes to show above (no Hyprland, no report, virtual output)
            visible: pane.chiclets.length === 0 && !pane.showList
            label: "Resolution"
            Popup {
                enabled: false
                model: [pane.mon ? P.sizeText(pane.mon.width, pane.mon.height) : "Default for display"]
            }
        }
        FormRow { label: "Refresh rate"; Popup { enabled: false; model: [pane.mon ? pane.mon.refreshRate + " Hertz" : "—"] } }
        FormRow { label: "Automatically adjust brightness"; Switch { enabled: false } }
        FormRow { label: "True Tone"; sublabel: "Automatically adapt display to make colors appear consistent in different ambient lighting."; Switch { enabled: false } }
    }

    PaneFooter { Button { text: "Advanced…" } Button { text: "Night Shift…" } }
}
