import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > Keyboard (ax-acc-keyboard-00). No backend in Hyprland / xkbcommon for these: the switches keep their
// own state. Keyboard Settings… opens the Keyboard pane.
AxPage {
    Card {
        AxRow { h: 184; info: true; label: "Full Keyboard Access"; subWidth: 372
                sub: "Full Keyboard Access allows the computer to be controlled with a keyboard. Use keyboard shortcuts to navigate through all controls and perform actions."
                sub2Y: 75
                sub2: "• To show help: Tab H\n• To move forward: Tab\n• To move backward: ⇧ Tab\n• To activate: Space\n• To move inside groups: ↑, ↓, ← and →\n• To move to next item: ⌃ Tab\n• To move to previous item: ⌃ ⇧ Tab"
                LocalSwitch {} }
        AxRow { h: 48; ctlY: 22; subWidth: 230.5; sub: "Additional keyboard shortcuts can be set in Keyboard settings."
                Button { text: "Keyboard Settings…"; onClicked: AppState.navigate("keyboard", "") } }
    }
    Card {
        AxRow { h: 67; info: true; label: "Sticky Keys"; subWidth: 361.5
                sub: "Sticky Keys allows modifier keys to be set without having to hold the key down."; LocalSwitch {} }
        AxRow { h: 66; info: true; label: "Slow Keys"; subWidth: 366
                sub: "Slow Keys adjusts the amount of time between when a key is pressed and when it is activated."; LocalSwitch {} }
    }
    Card {
        AxRow { h: 67; info: true; label: "Accessibility Keyboard"; subWidth: 347.5
                sub: "The Accessibility Keyboard lets you type and interact with macOS without using a hardware keyboard."; LocalSwitch {} }
        AxRow { h: 48; ctlY: 22; subWidth: 328; sub: "The Panel Editor allows you to customize the panels shown by Accessibility Keyboard."
                Button { text: "Panel Editor…" } }
    }
    PaneFooter {}
}
