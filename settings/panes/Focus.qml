import QtQuick
import ".."
import "../controls"
import "../HyprK"

// 27.2.1 (MAC-ANSWERS-13.md R13.1, live/settings-r13/dest-focus-{dark,light}.png, ax-dest-focus-*.jsonl): the modes in
// 52 pt rows with a chevron (the Mac's six: Do Not Disturb, Driving, Mindfulness, Reduce Interruptions, Sleep, Work),
// "Add Focus…" right under the card, "Share across devices" with its line, "Focus status" as a row into its sub-pane
// (value "On", 68 tall with its line), Help 20 below. Every mode row and "Focus status" push a sub-pane on the
// window's navigation (SettingsApp.qml): panes/focus/Mode.qml and panes/focus/Status.qml. No Focus backend
// (settings/Backend.qml has none): the controls keep the Mac's values (settings/FALLBACKS.md "Focus").
Column {
    id: pane
    spacing: Theme.content.sectionGap
    property string page: ""          // "" = the root, a mode's id or "status"
    // each mode's row tile (icon: the Mac's own, Panes.cropIcons), and its symbol and colour for the sub-pane:
    // themes/icons/sf-symbols/names.json focusModes (Sleep is drawn mint on the Mac's stills, not the table's indigo). `people`: the Allowed People row; `schedule` / `filters`: the sections the
    // mode's sub-pane has; `note`: the line of a mode that follows the iPhone; `locked`: the first switch on and dimmed
    readonly property var modes: [
        { id: "dnd", icon: "focus-dnd", name: "Do Not Disturb", symbol: "moon.fill", dark: "#6D7CFF", light: "#6155F5", short: true, apps: true, schedule: true, empty: true, filters: true, remove: false },
        { id: "driving", icon: "focus-driving", name: "Driving", symbol: "car.fill", dark: "#6D7CFF", light: "#6155F5", apps: false, schedule: false, filters: false, remove: true,
          noteIcon: "settings", note: "Driving Focus follows the activation method you’ve set on iPhone. To edit how it turns on, go to Focus settings on your iPhone." },
        { id: "mindfulness", icon: "focus-mindfulness", name: "Mindfulness", symbol: "apple.mindfulness", dark: "#00DAC3", light: "#00C8B3", apps: true, schedule: true, empty: false, filters: true, remove: true },
        { id: "reduce", icon: "focus-reduce", name: "Reduce Interruptions", symbol: "_gm", dark: "#DB34F2", light: "#CB30E0", short: true, locked: true, apps: true, schedule: true, empty: true, filters: true, remove: true },
        { id: "sleep", icon: "focus-sleep", name: "Sleep", symbol: "bed.double.fill", dark: "#00DAC3", light: "#00C8B3", apps: true, schedule: false, filters: true, remove: true,
          noteIcon: "health", note: "Sleep Focus follows the Sleep schedule you’ve set on iPhone. To add or edit your schedule, open the Health app on iPhone, tap Search, then Sleep." },
        { id: "work", icon: "focus-work", name: "Work", symbol: "person.lanyardcard.fill", dark: "#00D2E0", light: "#00C3D0", apps: true, schedule: true, empty: true, filters: true, remove: true }
    ]
    readonly property var mode: modes.find(m => m.id === page) || null
    readonly property string pageTitle: mode ? mode.name : page === "status" ? "Focus Status" : ""
    function tint(m) { return Theme.dark ? m.dark : m.light; }

    component ModeRow: FormRow {
        property var m
        objectName: "focusRow-" + m.id
        implicitHeight: Positioner.index > 0 ? 53 : 52
        // the Mac's own 26 pt tile, cut from its row (MAC-ANSWERS-14.md R14.3, themes/icons/settings/crops/focus-*: the
        // Dark icon style's, a black tile with the symbol in its colour); dest-focus-light.png: the tile 13 pt in the
        // card (px 530 of the card's 504), the label 13 after it
        iconSize: 26; iconX: 13; labelGap: 13
        iconId: m.icon; label: m.name
        onClicked: pane.page = m.id
        NavChevron {}
    }
    Card {
        visible: pane.page === ""
        Repeater { model: pane.modes; ModeRow { required property var modelData; m: modelData } }
    }
    // right under the card, no extra space (ax-dest-focus: the card ends at 381, the button is at 391, the next card at 425)
    Row { visible: pane.page === ""; anchors.right: parent.right; Button { objectName: "focusAdd"; text: "Add Focus…" } }
    Card {
        visible: pane.page === ""
        FormRow {
            label: "Share across devices"
            sublabel: "Focus is shared across your devices, and turning one on for this device will turn it on for all of them."
            LocalSwitch { checked: true }
        }
    }
    Card {
        visible: pane.page === ""
        FormRow {
            objectName: "focusRow-status"
            label: "Focus status"
            sublabel: "When you give an app permission, it can share that you have notifications silenced when using Focus."
            value: "On"
            onClicked: pane.page = "status"
            NavChevron {}
        }
    }
    PaneFooter { visible: pane.page === "" }
    // ---------- sub-pane ----------
    Loader {
        id: sub
        objectName: "focusSub"
        width: parent.width
        function load() {
            if (pane.mode) setSource("focus/Mode.qml", { pane: pane, mode: pane.mode });
            else if (pane.page === "status") setSource("focus/Status.qml", { pane: pane });
            else source = "";
        }
        Connections { target: pane; function onPageChanged() { sub.load(); } }
    }
}
