import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > Live Speech (ax-acc-live-speech-00). No backend: the controls keep their own state. The Saved row's
// bookmark symbol is not in the decoded set yet (themes/icons/sf-symbols), so it draws nothing.
AxPage {
    Card {
        AxRow { h: 83.5; ctlY: 19; iconId: "ax-livespeech"; label: "Live Speech"; subWidth: 355.5
                sub: "With Live Speech, you can type to speak aloud or directly into applications like FaceTime. Click the icon in the menu bar to show or hide Live Speech."
                LocalSwitch { controlSize: "small" } }
        AxRow { h: 38.25; ctlY: 18.5; label: "System speech language"; LocalPopup { model: ["Use System Language"] } }
        AxRow { h: 41.25; ctlY: 18.25; info: true; label: "Voice"; LocalPopup { model: ["Use System Voice"] } }
        AxRow { h: 37.5; ctlY: 18.5; label: "Font size"; AxStepper { value: 32; from: 1; unit: "pt" } }
    }
    Card {
        title: "Categories"
        Repeater {
            model: [{ t: "Recent", g: "clock" }, { t: "Saved", g: "bookmark" }]
            AxRow {
                required property var modelData
                required property int index
                h: 36.5; textX: 36; label: modelData.t; symbol: modelData.g
                Item { width: 6; height: 10; SfSymbol { name: "chevron.forward"; weight: "semibold"; pointSize: 10.5; color: Theme.tertiaryLabel } }
            }
        }
    }
    PaneFooter { Button { text: "Add Category…" } }
}
