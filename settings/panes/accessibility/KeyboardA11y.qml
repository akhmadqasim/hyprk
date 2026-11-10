import QtQuick
import "../.."
import "../../controls"

// Accessibility > Keyboard. Hyprland (xkbcommon) has no Sticky Keys or Slow Keys,
// so those rows are disabled with a note instead of pretending.
Column {
    id: page
    property var ctl
    property var info
    spacing: Theme.content.sectionGap

    Card {
        FormRow {
            label: "Full Keyboard Access"; dim: true
            sublabel: "Use the keyboard to move between controls. GTK and Qt apps already do this with Tab."
            MacSwitch { enabled_: false }
        }
    }
    Card {
        title: "Physical Keyboard"
        FormRow {
            label: "Sticky Keys"; dim: true
            sublabel: "Press modifier keys one at a time for shortcuts."
            MacSwitch { enabled_: false }
        }
        FormRow {
            label: "Slow Keys"; dim: true
            sublabel: "Add a delay between when a key is pressed and when it's accepted."
            MacSwitch { enabled_: false }
        }
    }
    InlineNote { text: "Hyprland doesn't support Sticky Keys or Slow Keys yet. Key repeat is in Keyboard settings." }
    Card {
        title: "Accessibility Keyboard"
        FormRow {
            label: "Accessibility Keyboard"; dim: true
            sublabel: "An onscreen keyboard needs a Wayland input-method keyboard such as wvkbd."
            MacSwitch { enabled_: false }
        }
    }
    PaneFooter { MacButton { text: "Keyboard Settings…" } }
}
