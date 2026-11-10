import QtQuick
import "../.."
import "../../controls"

// Accessibility > Pointer Control. Mouse and trackpad speeds live in their panes;
// alternate control methods have no Linux backend here.
Column {
    id: page
    property var ctl
    property var info
    spacing: Theme.content.sectionGap

    Card {
        title: "Mouse & Trackpad"
        FormRow {
            label: "Double-click speed"; dim: true
            MacSlider { width: 220; enabled_: false; leftText: "Slow"; rightText: "Fast"; value: 0.5 }
        }
        FormRow { label: "Spring-loading"; dim: true; MacSwitch { enabled_: false } }
        FormRow { label: "Ignore built-in trackpad when mouse or wireless trackpad is present"; dim: true; MacSwitch { enabled_: false } }
    }
    PaneFooter { help: false; MacButton { text: "Trackpad Options…" } MacButton { text: "Mouse Options…" } }
    Card {
        title: "Alternate Control Methods"
        FormRow { label: "Mouse Keys"; dim: true; sublabel: "Move the pointer with the keyboard."; MacSwitch { enabled_: false } }
        FormRow { label: "Alternate pointer actions"; dim: true; sublabel: "Use a keyboard key, a switch or a facial expression to click."; MacSwitch { enabled_: false } }
        FormRow { label: "Head pointer"; dim: true; sublabel: "Move the pointer with your head, tracked by the camera."; MacSwitch { enabled_: false } }
    }
    InlineNote { text: "These need a Hyprland pointer helper that isn't available yet." }
    PaneFooter {}
}
