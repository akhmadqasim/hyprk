import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > Personal Voice (ax-acc-personal-voice-00). No backend: the switches keep their own state.
AxPage {
    Item {
        width: parent.width; height: 59.5
        Text { x: 10; text: "Personal Voice"; font: Typography.headline; color: Theme.label }
        Text { x: 10; y: 17.5; width: 436.5; wrapMode: Text.WordWrap; lineHeight: 14; lineHeightMode: Text.FixedHeight
               text: "Personal Voice is a simple and secure way to create a voice that sounds like you. It can be used with Live Speech, Read & Speak, VoiceOver and augmented speech apps."
               font: Typography.subheadline; color: Theme.secondaryLabel }
    }
    Card {
        AxListRow { h: 37; textY: 10; sep: false; centered: true; text: "No Personal Voices" }
        AxRow { h: 44; ctlY: 22; Button { text: "Create a Personal Voice" } }
    }
    Card {
        AxRow { h: 52; label: "Share across devices"; sub: "Use Personal Voice on all your devices with iCloud."; LocalSwitch {} }
    }
    Card {
        AxRow { h: 67; label: "Allow applications to use your Personal Voice"; subWidth: 395
                sub: "Allow applications to request to use Personal Voice to speak aloud through your device’s speaker or during calls."
                LocalSwitch {} }
        AxListRow { h: 24.5; centered: true; text: "No Items" }
        AxListBar { glyphs: [{ name: "minus", on: false }] }
    }
    PaneFooter {}
}
