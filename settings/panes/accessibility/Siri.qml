import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > Siri (ax-acc-siri-00). No backend: the controls keep their own state.
AxPage {
    Card {
        AxRow { h: 66; label: "Listen for atypical speech"; subWidth: 371.5
                sub: "Expands the speech patterns Siri will listen for to help improve speech recognition."; LocalSwitch {} }
    }
    Card {
        AxRow { h: 58.5; label: "Spoken Responses"
                sub2: "Siri will speak responses when you speak to Siri."; sub2Y: 34.5
                AxRadio { model: ["Always Silent", "Speak Back for Voice Input"]; currentIndex: 1 } }
    }
    Card {
        AxRow { h: 44; ctlY: 22; sub: "Siri shortcut keys and settings can be adjusted in Siri settings."
                Button { text: "Siri Settings…" } }
    }
    PaneFooter {}
}
