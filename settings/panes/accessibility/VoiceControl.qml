import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > Voice Control (ax-acc-voice-control-00). No backend: the controls keep their own state.
AxPage {
    Card {
        AxRow { h: 67.1; labelY: 10.1; ctlY: 19; iconId: "ax-voicecontrol"; label: "Voice Control"; subWidth: 350.5
                sub: "Voice Control allows you to use your voice to edit text and interact with your computer even when you are on a call."
                LocalSwitch { controlSize: "small" } }
        AxRow { h: 41.25; ctlY: 18.4; label: "Language"; LocalPopup { model: ["English (United States)"] } }
        AxRow { h: 41.25; ctlY: 18.4; label: "Microphone"; LocalPopup { model: ["Automatic"] } }
        AxRow { h: 37.5; label: "Show hints"; LocalSwitch { checked: true } }
        AxRow { h: 36.4; label: "Play sound when command is recognized"; LocalSwitch {} }
    }
    Card {
        AxRow { h: 38.25; labelY: 10.1; ctlY: 18.5; label: "Overlay"
                LocalPopup { model: ["None", "Item Numbers", "Item Names", "Numbered Grid"] } }
        AxRow { h: 36.75; label: "Fade overlay after inactivity"; LocalSwitch {} }
    }
    Card {
        AxRow { h: 66; ctlY: 18; label: "Voice Control Tutorial"; subWidth: 270
                sub: "Learn and practice Voice Control commands in this interactive tutorial."
                Button { text: "Open Tutorial…" } }
    }
    Card {
        AxRow { h: 94; label: "Improve assistive voice features"; subWidth: 402
                sub: "Help Apple improve assistive voice features by sharing audio recordings and transcripts of your Vocal Shortcuts and Voice Control interactions. This information is sent only with your consent and is submitted anonymously to Apple."
                LocalSwitch {} }
    }
    PaneFooter {
        Button { text: "Commands…" }
        Button { text: "Vocabulary…" }
        // the "…" menu button (MAC-ANSWERS-14.md R14.4, live/settings-r14/acc-voice-control--options-menu-dark.png:
        // AXMenuButton 61.5 x 24, its menu 223 x 165 opening upward): what the six items open is not on a shot, a pick
        // closes the menu
        PullDown {
            objectName: "voiceControlMore"
            above: true
            items: [{ title: "Import Vocabulary…" }, { title: "Export Vocabulary…" }, { title: "Delete All Vocabulary…" }, { sep: true },
                    { title: "Import Custom Commands…" }, { title: "Export Custom Commands…" }, { title: "Delete All Custom Commands…" }]
        }
    }
}
