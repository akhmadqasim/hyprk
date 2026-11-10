import QtQuick
import ".."
import "../controls"
import "../HyprK"

// Shown as "Battery" on laptops and "Energy" on desktops (hasBattery). Visual only.
Column {
    spacing: Theme.content.sectionGap
    Card {
        visible: AppState.hasBattery
        FormRow { label: "Low Power Mode"; LocalPopup { model: ["Never", "Always", "Only on Battery", "Only on Power Adapter"] } }
        FormRow { label: "Battery Health"; value: "Normal"; }
    }
    Card {
        visible: !AppState.hasBattery
        FormRow { label: "Low Power Mode"; LocalPopup { model: ["Never", "Always"] } }
        FormRow { label: "Prevent automatic sleeping when the display is off"; LocalSwitch {} }
        FormRow { label: "Wake for network access"; LocalSwitch { checked: true } }
        FormRow { label: "Start up automatically after a power failure"; LocalSwitch {} }
    }
    InlineNote { text: AppState.hasBattery ? "" : "This computer has no battery, so battery settings are hidden." }
    PaneFooter { Button { text: "Schedule…" } }
}
