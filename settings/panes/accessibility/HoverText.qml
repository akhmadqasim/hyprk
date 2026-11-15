import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > Hover Text (ax-acc-hover-text-00). No backend: the switches keep their own state.
// Hover Text's ⓘ opens "Hover Text Settings" (MAC-ANSWERS-14.md R14.4, live/settings-r14/acc-hover-text--info-dark.png):
// a sheet 470 x 510: the title 30 pt in; a card with Activation modifier (pop-up, "⌘ Command") and the activation
// lock switch (off); "Appearance" with its line; a card of six 38 pt rows: Text size (a stepper field, 60 pt) and five
// pop-ups on "Default"; Done. The two labels under the capture's blur and the American spelling are the extension's
// own strings (AccessibilitySettingsExtension.appex Localizable.loctable, en: hoverText.*). The pop-ups' other items are
// not on a shot: each has the Mac's value alone. The ⓘ of Hover Color and Hover Typing were not opened on the Mac.
AxPage {
    Card {
        AxRow { h: 52; info: true; label: "Hover Text"; objectName: "hoverTextRow"
                sub: "Press ⌘ to display a large-text view of the item under the pointer."; LocalSwitch {}
                onInfoClicked: settings.open() }
    }
    Card {
        AxRow { h: 52; info: true; label: "Hover Color"
                sub: "Press ⌃ to describe the color under the pointer."; LocalSwitch {} }
    }
    Card {
        AxRow { h: 38; info: true; label: "Hover Typing"; LocalSwitch {} }
    }
    PaneFooter {}
    SubSheet {
        id: settings
        objectName: "hoverTextSettings"
        sheetWidth: 470; sheetHeight: 510
        Text { x: 30; y: 19.5; text: "Hover Text Settings"; font: Typography.headline; color: Theme.label }
        Card {
            x: 20; y: 45.5; width: 430
            AxRow { h: 37; ctlY: 18.5; label: "Activation modifier"; LocalPopup { model: ["⌘ Command"] } }
            AxRow { h: 37; label: "Triple-press modifier to set activation lock"; LocalSwitch {} }
        }
        Text { x: 30; y: 150.5; text: "Appearance"; font: Typography.headline; color: Theme.label }
        Text { x: 30; y: 167.5; text: "Shares appearance settings with Hover Color"; font: Typography.subheadline; color: Theme.label }
        Card {
            x: 20; y: 192; width: 430
            AxRow { h: 38; ctlY: 18.5; label: "Text size"; AxStepper { value: 60; from: 1; unit: "pt" } }
            AxRow { h: 38; ctlY: 18.5; label: "Text font"; LocalPopup { model: ["Default"] } }
            AxRow { h: 38; ctlY: 18.5; label: "Text color"; LocalPopup { model: ["Default"] } }
            AxRow { h: 38; ctlY: 18.5; label: "Background color"; LocalPopup { model: ["Default"] } }
            AxRow { h: 38; ctlY: 18.5; label: "Border color"; LocalPopup { model: ["Default"] } }
            AxRow { h: 37.5; ctlY: 18.5; label: "Element-highlight color"; LocalPopup { model: ["Default"] } }
        }
    }
}
