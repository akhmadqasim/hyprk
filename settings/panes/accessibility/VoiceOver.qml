import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// Accessibility > VoiceOver = the Orca screen reader (scripts/a11y-orca.sh).
// ⌘F5 toggles it anywhere (bound by state/accessibility.lua). Without Orca the
// switch is disabled with a note.
Column {
    id: page
    property var ctl
    property var info
    spacing: Theme.content.sectionGap

    Card {
        FormRow {
            label: "VoiceOver"; dim: !page.ctl.hasOrca
            sublabel: page.ctl.hasOrca
                ? "Speaks what's on the screen, using the Orca screen reader. Toggle it with ⌘F5."
                : "Install the Orca screen reader (package orca) to use VoiceOver here."
            Switch {
                enabled: page.ctl.hasOrca
                checked: page.ctl.orcaRunning
                onToggled: on => page.ctl.setVoiceOver(on)
            }
        }
    }
    PaneFooter {
        help: false
        Button { text: "Open VoiceOver Tutorial…"; enabled: false }
        Button { text: "Open VoiceOver Utility…"; enabled: page.ctl.hasOrca
                    onClicked: Backend.run(["sh", "-c", "setsid orca -s >/dev/null 2>&1 &"]) }
    }
    InlineNote { text: page.ctl.hasOrca ? "Orca reads apps that expose AT-SPI (GTK, Qt, Firefox, Chromium). The shell's own panels are not read yet." : "" }
    // ⌘F5 can toggle Orca behind our back; re-check now and then while the page is open
    Timer { interval: 5000; repeat: true; running: page.visible; onTriggered: page.ctl.refreshOrca() }
}
