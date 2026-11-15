import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// Focus > Focus Status (27.2.1, live/settings-r13/dest-focus--focus-status-light.png, ax-dest-focus--focus-status-light):
// "Share Focus status" with its line and link, then "Share From": a switch per mode (all on). No Focus backend: the
// switches keep their own state (settings/FALLBACKS.md "Focus").
Column {
    id: page
    property var pane
    spacing: Theme.content.sectionGap
    Card {
        FormRow {
            label: "Share Focus status"
            sublabel: "When a Focus is on, apps that you allow can show that you have notifications silenced."
            sublink: "Learn more…"
            sublabelPad: 20; sublabelGap: 2; sublabelLineHeight: 14
            LocalSwitch { objectName: "focusShareStatus"; checked: true }
        }
    }
    Card {
        title: "Share From"
        subtitle: "Customize which Focus profiles can share that you have notifications silenced."
        Repeater {
            model: page.pane ? page.pane.modes : []
            FormRow { required property var modelData; label: modelData.name; LocalSwitch { checked: true } }
        }
    }
    PaneFooter {}
}
