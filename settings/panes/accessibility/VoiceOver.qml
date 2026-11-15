import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > VoiceOver (ax-acc-voiceover-00, acc-voiceover-00-*.png). The switch runs the Orca screen reader where
// it is installed (scripts/a11y-orca.sh; ⌘F5 toggles it anywhere), else it keeps its own state.
AxPage {
    id: page
    property bool _local: false
    Card {
        AxRow {
            h: 113
            iconId: "ax-voiceover"
            label: "VoiceOver"
            sub: "VoiceOver provides spoken and brailled descriptions of items on the computer screen and provides control of the computer through the use of the keyboard."
            subWidth: 354.5
            sub2: "To toggle VoiceOver, quickly press Touch ID three times while holding the Command key."
            sub2Y: 75
            ctlY: 19
            Switch {
                controlSize: "small"
                checked: page.ctl.hasOrca ? page.ctl.orcaRunning : page._local
                onToggled: on => { if (page.ctl.hasOrca) page.ctl.setVoiceOver(on); else page._local = on; }
            }
        }
    }
    PaneFooter {
        Button { text: "Open VoiceOver Tutorial…" }
        Button { text: "Open VoiceOver Utility…"
                 onClicked: if (page.ctl.hasOrca) Backend.run(["sh", "-c", "setsid orca -s >/dev/null 2>&1 &"]) }
    }
    // ⌘F5 can toggle Orca behind our back; re-check now and then while the page is open
    Timer { interval: 5000; repeat: true; running: page.visible; onTriggered: page.ctl.refreshOrca() }
}
