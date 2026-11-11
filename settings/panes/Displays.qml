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

    // Arrangement strip. Centred when it fits. When it does not, the thumbnails shrink step by step down to
    // `minThumb` high and then the row scrolls sideways inside the card (clipped to it). macOS shows the display
    // thumbnails centred in a row, but there is no reference shot of this pane in reference/, so everything about
    // the overflow behaviour (minimum size, scrolling instead of a scaled row, gaps, padding) is guessed.
    // Hero strip, not a card (Q-settings-14, displays-{light,dark}.png): full content width from the toolbar's bottom,
    // 158 pt tall, a vertical gradient white -> #F3F3F3 (dark #1E1F24 -> #28292E), a 1 pt divider #E6E6E6 / #343539
    // at its bottom; the next card 23 pt below it. The Mac draws a MacBook picture and the display's name; no Apple
    // art is shipped, so the arrangement thumbnails sit in it.
    Item {
        width: parent.width; height: 158 - Theme.content.top + 13   // + 13: 10 spacing makes the 23 pt gap
        Rectangle {
            x: -Theme.content.padding; y: -Theme.content.top
            width: parent.width + 2 * Theme.content.padding; height: 158
            gradient: Gradient {
                GradientStop { position: 0; color: Theme.dark ? "#1E1F24" : "#FFFFFF" }
                GradientStop { position: 1; color: Theme.dark ? "#28292E" : "#F3F3F3" }
            }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.dark ? "#343539" : "#E6E6E6" }
        }
        Item {
            id: strip
            y: -Theme.content.top + 4
            width: parent.width; height: 150

            readonly property var items: pane.status === "ok" ? pane.monitors : [{ name: "", description: "Display", width: 16, height: 10 }]
            readonly property int pad: 16                // keeps the selection ring away from the card edge
            readonly property int gap: 16
            readonly property int minSlot: 72            // a label column is never narrower, so short names stay readable
            readonly property int maxThumb: 74
            readonly property int minThumb: 44
            // width of the whole row for thumbnails `h` high
            function rowWidth(h) {
                let w = Math.max(0, items.length - 1) * gap;
                for (const m of items) w += Math.max(minSlot, Math.round(h * m.width / Math.max(1, m.height)));
                return w;
            }
            // tallest thumbnail height (maxThumb .. minThumb) whose row fits the card; minThumb when none does
            readonly property int thumbH: {
                for (let h = maxThumb; h > minThumb; h -= 2)
                    if (rowWidth(h) <= width - 2 * pad) return h;
                return minThumb;
            }

            Flickable {
                id: flick
                anchors.fill: parent
                clip: true                               // nothing is drawn outside the strip
                contentWidth: Math.max(width, row.width + 2 * strip.pad)
                contentHeight: height
                flickableDirection: Flickable.HorizontalFlick
                boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
                RubberBand { flickable: flick }

                // keep the selected display in view when it changes (arrow keys, a new first selection)
                function reveal() {
                    const it = row.children[pane.sel];
                    if (!it || !it.width) return;
                    const left = row.x + it.x - strip.pad, right = row.x + it.x + it.width + strip.pad;
                    if (left < contentX) contentX = Math.max(0, left);
                    else if (right > contentX + width) contentX = Math.min(contentWidth - width, right - width);
                }
                Connections { target: pane; function onSelChanged() { Qt.callLater(flick.reveal) } }
                onWidthChanged: Qt.callLater(reveal)
                onContentWidthChanged: Qt.callLater(reveal)   // the displays were listed after the first draw

                WheelHandler {                            // wheel / trackpad scroll sideways, only while the row overflows
                    enabled: flick.contentWidth > flick.width
                    orientation: Qt.Vertical | Qt.Horizontal
                    onWheel: event => {
                        const d = event.angleDelta.x !== 0 ? event.angleDelta.x : event.angleDelta.y;
                        flick.contentX = Math.max(0, Math.min(flick.contentWidth - flick.width, flick.contentX - d));
                    }
                }

                // position bar, only while there is more to scroll to (guessed: macOS shows overlay scroll bars)
                Rectangle {
                    visible: flick.contentWidth > flick.width + 1
                    parent: strip                             // stays put while the content moves
                    y: strip.height - 8; height: 3; radius: 1.5
                    width: Math.max(20, strip.width * flick.width / flick.contentWidth)
                    x: (strip.width - width) * flick.contentX / Math.max(1, flick.contentWidth - flick.width)
                    color: Theme.secondaryLabel; opacity: 0.5
                }

                Row {
                    id: row
                    x: Math.max(strip.pad, (flick.width - width) / 2)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: strip.gap
                    Repeater {
                        model: strip.items
                        Column {
                            required property var modelData
                            required property int index
                            spacing: 6
                            readonly property int thumbW: Math.round(strip.thumbH * modelData.width / Math.max(1, modelData.height))
                            width: Math.max(strip.minSlot, thumbW)
                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: strip.thumbH; width: parent.thumbW
                                radius: 6
                                border.width: index === pane.sel && pane.status === "ok" ? 3 : 1
                                border.color: index === pane.sel && pane.status === "ok" ? Theme.accent : Theme.separator
                                gradient: Gradient { GradientStop { position: 0; color: "#3B7BD6" } GradientStop { position: 1; color: "#7A5BC9" } }
                                opacity: pane.status === "ok" ? 1 : 0.35
                                MouseArea { anchors.fill: parent; onClicked: pane.sel = index }
                            }
                            Text {
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                text: modelData.model || modelData.description
                                font: Typography.subheadline; color: Theme.label
                            }
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
                                size: Math.max(8, Math.min(24, Math.round(15 * (pane.out ? pane.out.def[0] : ch.modelData.w) / ch.modelData.w)))
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
                            font: Typography.subheadline
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
                font: Typography.subheadline
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
    }

    // 27.2.1 below the sizes (displays-light.png): a Brightness card (slider with sun end buttons, Automatically adjust
    // brightness, True Tone), Colour profile, When connected to TV. No backend for any of these yet: kept locally.
    Card {
        FormRow {
            label: "Brightness"
            Slider {
                id: bright
                width: 230
                value: 0.5
                leftGlyph: "light_mode"; rightGlyph: "light_mode"
                onMoved: v => value = v
            }
        }
        FormRow { label: "Automatically adjust brightness"; LocalSwitch { checked: true } }
        FormRow {
            label: "True Tone"
            sublabel: "Automatically adapt display to make colors appear consistent in different ambient lighting conditions."
            LocalSwitch { }
        }
    }
    Card {
        FormRow { label: "Color profile"; LocalPopup { model: ["Color LCD", "sRGB IEC61966-2.1", "Display P3"] } }
    }
    Card {
        FormRow {
            label: "When connected to TV"
            sublabel: "Choose what to show or use the TV as a secondary display."
            LocalPopup { model: ["Ask What to Show", "Mirror Entire Screen", "Extended Display"] }
        }
    }

    PaneFooter { Button { text: "Advanced…" } Button { text: "Night Shift…" } }
}
