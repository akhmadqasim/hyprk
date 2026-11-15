import QtQuick
import ".."
import "../controls"
import "../HyprK"
import "../Parsers.js" as P

// Functional: monitors from `hyprctl monitors -j`, sizes from config/hypr/scale-policy.lua (report() through
// `hyprctl eval`). A HiDPI display gets the macOS row of scaled sizes ("Larger Text" .. "More Space"), a 1x
// display the resolution list. The choice is saved per output to state/displays.json (read by scale-policy.lua
// at start and on hotplug) and applied at once with scale-policy.lua set().
// Several displays: one thumbnail each in the strip (the session's outputs, in Hyprland's order; two of one model are
// numbered), a click selects the display the rows below are about; "Use as" says its role and Arrange… shows where
// Hyprland has them. A nested preview session has one output, so it shows one display.
// Brightness: the shell's services/Brightness.qml through state/brightness.json (AppState.brightness), the same level
// as Control Center's Display slider and the keys.
Column {
    id: pane
    spacing: Theme.content.sectionGap

    property string status: "loading"   // loading | missing | failed | ok
    property var monitors: []
    property var report: null           // P.parseScaleReport result, null = scale policy not reachable
    property int sel: 0
    readonly property var mon: monitors.length ? monitors[Math.min(sel, monitors.length - 1)] : null
    readonly property var out: report && mon ? report.outputs.find(o => o.name === mon.name) ?? null : null
    readonly property string block: status === "ok" ? P.looksLikeBlock(report, out) : ""
    readonly property bool canPick: status === "ok" && block === ""
    readonly property string saved: mon ? AppState.displays.looksLike[mon.name] ?? "" : ""
    readonly property string selected: P.looksLikeSelected(out, report && report.policy === "on" ? saved : "")
    // virtual outputs (MBA, HEADLESS-*, nested WAYLAND-*/X11-*) keep their own mode: no list, a disabled Resolution row
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
        Backend.hyprEval(P.luaScaleSet(Backend.root, name, c.isDefault ? "" : key), () => refresh());
    }
    readonly property var names: P.displayNames(monitors)
    readonly property bool several: status === "ok" && monitors.length > 1
    Component.onCompleted: {
        refresh();
        // a monitor that was asleep when the shell looked answers DDC now: ask it to look again
        AppState.askBrightnessProbe();
    }

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
        // Add (MAC-ANSWERS-14.md R14.5, live/settings-r13/pop-displayAndBrightness-00-dark.png): an AXMenuButton "plus"
        // 61 x 24 at the strip's right end, window 659,171. Its menu opens below it, 5 pt to the left: the disabled
        // heading "Mirror or extend to", then a row per available display with a display glyph (the Mac's two are
        // redacted; here the session's other outputs, hyprctl monitors). No mirror backend: a pick closes the menu.
        PullDown {
            objectName: "displaysAdd"
            z: 1
            x: parent.width - width; y: 171 - Theme.window.toolbarHeight - Theme.content.top
            width: 61; glyph: "plus"
            items: [{ title: "Mirror or extend to", header: true }].concat(
                pane.status === "ok" ? pane.monitors.map((m, i) => ({ title: pane.names[i], glyph: "display" })).filter((m, i) => i !== pane.sel) : [])
        }
        // Arrange… (DisplaysExt "Arrange…"): only with several displays, left of Add. Not on a Mac shot here (the
        // captures are of one display): its place and the sheet are this copy's (settings/FALLBACKS.md)
        Button {
            objectName: "displaysArrangeButton"
            z: 1
            visible: pane.several
            x: parent.width - 61 - 8 - width; y: 171 - Theme.window.toolbarHeight - Theme.content.top
            text: "Arrange…"
            onClicked: arrange.open()
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
                acceptedButtons: Qt.NoButton                  // no mouse-drag scrolling (AppKit)
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
                                objectName: "displayName-" + index
                                text: pane.status === "ok" ? pane.names[index] || "" : modelData.description
                                font: Typography.subheadline; color: Theme.label
                            }
                        }
                    }
                }
            }
        }
    }

    // HiDPI: the five scaled sizes. Tile size, "Aa" sizes and spacing are guessed; labels are macOS's. No "Looks like"
    // line under them: displays-light.png has none and 27.2.1 DisplaysExt has no such string.
    Card {
        visible: pane.chiclets.length > 0
        Item {
            width: parent.width
            height: 118
            opacity: pane.canPick ? 1 : 0.45
            Row {
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
                SfSymbol {   // checkmark at the body size (this list is not on a Mac shot: the size is not measured)
                    visible: P.sizeKey(modelData) === pane.selected
                    name: "checkmark"; pointSize: 13; color: Theme.accent
                }
            }
        }
    }

    // several displays: what the selected one is used as. Hyprland has no main display or mirroring switch here, so
    // the pop-up shows the state and cannot change it
    Card {
        visible: pane.several
        FormRow {
            objectName: "displaysUseAs"
            label: "Use as"
            Popup { enabled: false; model: [pane.several ? P.displayRole(pane.monitors, pane.sel) : ""] }
        }
    }

    Card {
        FormRow {
            // only when there are no sizes to show above (no Hyprland, no report, virtual output)
            visible: pane.chiclets.length === 0 && !pane.showList
            label: "Resolution"
            Popup {
                enabled: false
                model: [pane.mon ? P.sizeText(pane.mon.width, pane.mon.height) : "Default"]   // DisplaysExt "Default"
            }
        }
        FormRow { label: "Refresh rate"; Popup { enabled: false; model: [pane.mon ? pane.mon.refreshRate + " Hertz" : "—"] } }
    }

    // 27.2.1 below the sizes (displays-light.png): a Brightness card (slider with sun end buttons, Automatically adjust
    // brightness, True Tone), Colour profile, When connected to TV.
    // Brightness is the shell's (AppState.brightness: a backlight or the monitors' DDC/CI): the slider shows its level,
    // follows Control Center's slider and the keys, and a drag is written back every 50 ms. Disabled when nothing can
    // dim the display (or no shell runs), as the Mac's on a display without brightness control. The two rows under it
    // need an ambient light sensor and are not shown without one (AppState.hw); they have no backend.
    Card {
        FormRow {
            objectName: "displaysBrightnessRow"
            label: "Brightness"
            dim: !AppState.brightness.available
            Slider {
                id: bright
                objectName: "displaysBrightness"
                width: 246   // as Sound's: the frames span 463.5 .. 709.7 pt on displays-light.png
                enabled: AppState.brightness.available
                value: AppState.brightness.available ? AppState.brightness.value : 1
                leftGlyph: "sun.min.fill"; rightGlyph: "sun.max.fill"; glyphSize: 16.5   // displays-light.png: alpha rms 0.041 / 0.056 at 16.5 pt
                onMoved: v => AppState.set("brightness", { value: v })
            }
        }
        FormRow { objectName: "displaysAutoBrightness"; visible: AppState.hw.ambientLight; label: "Automatically adjust brightness"; LocalSwitch { checked: true } }
        FormRow {
            objectName: "displaysTrueTone"
            visible: AppState.hw.ambientLight
            label: "True Tone"
            sublabel: "Automatically adapt display to make colors appear consistent in different ambient lighting conditions."
            LocalSwitch { }
        }
    }
    Card {
        FormRow { label: "Color profile"; LocalPopup {   // R13.2 popups.json: the Mac's profiles, the display's own checked, then Customize…
                objectName: "displaysColorProfile"
                model: ["ACES CG Linear (Academy Color Encoding System AP1)", "Adobe RGB (1998)", "SMPTE RP 431-2-2007 DCI (P3)", "Display P3", "Generic RGB Profile", "Rec. ITU-R BT.2020-1", "Rec. ITU-R BT.709-5", "ROMM RGB: ISO 22028-2:2013", "sRGB IEC61966-2.1", "Color LCD", "Customize…"]
                separators: [9]; currentIndex: 9
                actions: [10]   // no profile editor here
            } }
    }
    Card {
        FormRow {
            label: "When connected to TV"
            sublabel: "Choose what to show or use the TV as a secondary display."
            LocalPopup { objectName: "displaysTV"; model: ["Ask What to Show", "Mirror Entire Screen", "Choose Window or App", "Use as Extended Display"] }
        }
    }

    PaneFooter {   // DisplaysExt.appex: "Displays settings on Mac"
        helpAnchor: "mh40768"
        Button { objectName: "displaysAdvancedButton"; text: "Advanced…"; onClicked: advanced.open() }
        Button { objectName: "displaysNightShiftButton"; text: "Night Shift…"; onClicked: nightShift.open() }
    }

    // Advanced… (MAC-ANSWERS-12.md R12.3; live/settings-r12/nav-displayAndBrightness--advanced-dark.png, ax-nav-...):
    // 470 x 432: [Show resolutions as list] and "Link to Mac or iPad" with three switches, the last two disabled while
    // the first is off. The Mac's values; nothing is behind them here (settings/FALLBACKS.md "Sheets").
    SubSheet {
        id: advanced
        objectName: "displaysAdvanced"
        sheetWidth: 470; sheetHeight: 432
        Column {
            x: 20; y: 20; width: 430
            spacing: Theme.content.sectionGap
            Card { FormRow { label: "Show resolutions as list"; LocalSwitch {} } }
            Card {
                title: "Link to Mac or iPad"
                FormRow {
                    sublabelPad: 21; sublabelGap: 2; sublabelLineHeight: 14
                    label: "Allow your pointer and keyboard to move between any nearby Mac or iPad"
                    sublabel: "Your pointer and keyboard can be used on any nearby Mac or iPad signed in to your iCloud account."
                    LocalSwitch { id: link }
                }
                FormRow {
                    sublabelPad: 21; sublabelGap: 2; sublabelLineHeight: 14; dim: !link.checked
                    label: "Push through the edge of a display to connect a nearby Mac or iPad"
                    sublabel: "Allow the pointer to connect to a nearby Mac or iPad by pushing against the edge of a display."
                    LocalSwitch { enabled: link.checked; checked: true }
                }
                FormRow {
                    sublabelPad: 21; sublabelGap: 2; sublabelLineHeight: 14; dim: !link.checked
                    label: "Automatically reconnect to any nearby Mac or iPad"
                    sublabel: "Allow this Mac to automatically reconnect to any nearby Mac or iPad you’ve previously connected to."
                    LocalSwitch { enabled: link.checked }
                }
            }
        }
    }
    // Arrange…: the displays where Hyprland has them (hyprctl monitors x, y, size over scale), the main one with the
    // Mac's white menu bar strip. Read-only: no drag (the layout is the Hyprland config's).
    SubSheet {
        id: arrange
        objectName: "displaysArrange"
        sheetWidth: 470; sheetHeight: 300
        Item {
            id: field
            x: 20; y: 20; width: 430; height: 200
            readonly property var rects: pane.several ? P.arrangement(pane.monitors, width, height) : []
            Repeater {
                model: field.rects
                Rectangle {
                    required property var modelData
                    required property int index
                    objectName: "displaysArrangeRect-" + index
                    x: modelData.x; y: modelData.y; width: modelData.w; height: modelData.h
                    radius: 4
                    border.width: 1; border.color: Theme.separator
                    gradient: Gradient { GradientStop { position: 0; color: "#3B7BD6" } GradientStop { position: 1; color: "#7A5BC9" } }
                    Rectangle { visible: index === P.mainDisplay(pane.monitors); x: 1; y: 1; width: parent.width - 2; height: 5; radius: 3; color: "#FFFFFF" }
                    Text { anchors.centerIn: parent; width: parent.width - 8; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight
                           text: pane.names[index] || ""; font: Typography.subheadline; color: "#FFFFFF" }
                }
            }
        }
    }
    // Night Shift… (nav-displayAndBrightness--night-shift-dark.png, ax-nav-...): 470 x 331, one card: three lines about
    // it, Schedule ("Off": the other items are not on a shot), Turn on until tomorrow, Colour temperature with a
    // 215.5 pt slider (Less Warm / More Warm, at the middle); Help at the strip's left. No colour temperature backend.
    SubSheet {
        id: nightShift
        objectName: "displaysNightShift"
        sheetWidth: 470; sheetHeight: 331
        help: true
        Card {
            x: 20; y: 20; width: 430
            Item {
                width: parent.width; height: 65
                Text {
                    x: 10; y: 10; width: parent.width - 20; wrapMode: Text.WordWrap
                    lineHeight: 15; lineHeightMode: Text.FixedHeight
                    text: "Night Shift automatically shifts the colors of your display to the warmer end of the color spectrum after dark. This may help you get a better night’s sleep."
                    font: Typography.body; color: Theme.label
                }
            }
            FormRow { label: "Schedule"; LocalPopup { model: ["Off"] } }
            FormRow { label: "Turn on until tomorrow"; LocalSwitch {} }
            FormRow {
                sublabelPad: 21; sublabelGap: 2; sublabelLineHeight: 14
                label: "Color temperature"
                sublabel: "Warmer settings may affect the appearance of some onscreen motion."
                Slider { id: warmth; width: 215.5; value: 0.5; tickMarks: 2; leftText: "Less Warm"; rightText: "More Warm"; onMoved: v => value = v }
            }
        }
    }
}
