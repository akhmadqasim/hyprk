import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > Vocal Shortcuts (ax-acc-vocal-shortcuts-00).
AxPage {
    Card {
        AxRow { h: 66; ctlY: 22; iconId: "ax-vocalshortcuts"; label: "Vocal Shortcuts"; subWidth: 323
                sub: "Teach your Mac to recognize a custom phrase you can say to quickly perform an action. Audio is processed on Mac."
                Button { text: "Set Up" } }
    }
    PaneFooter {}
}
